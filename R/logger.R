logger_new <- function(
  provider,
  name = NULL,
  minimum_severity = NULL,
  version = NULL,
  schema_url = NULL,
  attributes = NULL,
  ...
) {
  name <- as_string(name, null = TRUE)
  inst_scope <- find_instrumentation_scope(name)
  name <- name %||% inst_scope[["name"]]
  if (!inst_scope[["on"]]) {
    return(otel::logger_provider_noop$new()$get_logger(name))
  }

  self <- new_object(
    "otel_logger",
    get_name = function() {
      ccall(otel_logger_get_name, self$xptr)
    },
    # create_log_record = function() {
    #   log_record_new()
    # },
    # emit_log_record = function(log_record) {
    #   ccall(otel_emit_log_record, self$xptr, log_record)
    #   invisible(self)
    # },
    trace = function(msg = "", ...) {
      self$log(msg = msg, severity = "trace", ...)
    },
    debug = function(msg = "", ...) {
      self$log(msg = msg, severity = "debug", ...)
    },
    info = function(msg = "", ...) {
      self$log(msg = msg, severity = "info", ...)
    },
    warn = function(msg = "", ...) {
      self$log(msg = msg, severity = "warn", ...)
    },
    error = function(msg = "", ...) {
      self$log(msg = msg, severity = "error", ...)
    },
    fatal = function(msg = "", ...) {
      self$log(msg = msg, severity = "fatal", ...)
    },
    is_enabled = function(severity = "info", event_id = NULL) {
      severity <- as_log_severity(severity)
      event_id <- as_event_id(event_id)
      ccall(otel_logger_is_enabled, self$xptr, severity, event_id)
    },
    get_minimum_severity = function() {
      ms <- ccall(otel_get_minimum_log_severity, self$xptr)
      otel::log_severity_levels[match(ms, otel::log_severity_levels)]
    },
    set_minimum_severity = function(minimum_severity) {
      minimum_severity <- as_log_severity(minimum_severity)
      ccall(otel_set_minimum_log_severity, self$xptr, minimum_severity)
      invisible(self)
    },
    log = function(
      msg = "",
      severity = "info",
      event_id = NULL,
      span_context = NULL,
      span_id = NULL,
      trace_id = NULL,
      trace_flags = NULL,
      timestamp = Sys.time(),
      observed_timestamp = NULL,
      attributes = NULL
    ) {
      msg <- as_string(msg, null = FALSE)
      severity <- as_log_severity(severity)
      event_id <- as_event_id(event_id)
      span_context <- as_span_context(span_context)
      span_id <- as_span_id(span_id)
      trace_id <- as_trace_id(trace_id)
      trace_flags <- as_trace_flags(trace_flags)
      timestamp <- as_timestamp(timestamp)
      observed_timestamp <- as_timestamp(observed_timestamp)
      attributes <- as.list(as_otel_attributes(attributes))

      if (!is_na(span_context)) {
        span_context <- span_context %||% otel::get_active_span_context()
        if (span_context$is_valid()) {
          span_id <- span_id %||% span_context$get_span_id()
          trace_id <- trace_id %||% span_context$get_trace_id()
          trace_flags <- trace_flags %||% span_context$get_trace_flags()
        }
      }

      ccall(
        otel_log,
        self$xptr,
        msg,
        severity,
        event_id,
        span_id,
        trace_id,
        trace_flags,
        timestamp,
        observed_timestamp,
        attributes
      )
      invisible(self)
    },
    flush = function() {
      self$provider$flush()
    },
    name = NULL
  )
  self$provider <- provider
  minimum_severity <- as_log_severity(
    minimum_severity %||% get_default_log_severity()
  )
  self$name <- as_string(name)
  self$version <- as_string(version)
  self$schema_url <- as_string(schema_url)
  self$attributes <- as_otel_attributes(attributes)
  self$xptr <- ccall(
    otel_get_logger,
    self$provider$xptr,
    self$name,
    minimum_severity,
    self$version,
    self$schema_url,
    self$attributes
  )
  self
}

# log_record_new <- function() {
#   # TODO
# }

log_severity_levels_spec <- function() {
  c(
    "invalid" = 0L,
    otel::log_severity_levels,
    "maximumseverity" = 255L,
    NULL
  )
}

get_default_log_severity <- function() {
  level0 <- Sys.getenv(otel_log_level_var, otel_log_level_default)
  level <- tolower(level0)
  if (level %in% names(otel::log_severity_levels)) {
    return(level)
  }
  if (level %in% otel::log_severity_levels) {
    return(as.integer(level))
  }
  cchoices <- paste(names(otel::log_severity_levels), collapse = ", ")
  stop(glue(c(
    "Invalid OpenTelemetry log level from the {otel_log_level_var} ",
    "environment variable. Must be one of {cchoices}, but it is '{level0}'."
  )))
}

otel_log_level_var <- "OTEL_LOG_LEVEL"
otel_log_level_default <- "info"
