logger_new <- function(
  provider,
  name = NULL,
  minimum_severity = "info",
  version = NULL,
  schema_url = NULL,
  attributes = NULL,
  ...
) {
  self <- new_object(
    "otel_logger",
    get_name = function() {
      .Call(otel_logger_get_name, self$xptr)
    },
    # create_log_record = function() {
    #   log_record_new()
    # },
    # emit_log_record = function(log_record) {
    #   .Call(otel_emit_log_record, self$xptr, log_record)
    #   invisible(self)
    # },
    trace = function(msg = "", severity = "trace", ...) {
      self$log(msg = msg, severity = severity, ...)
    },
    debug = function(msg = "", severity = "debug", ...) {
      self$log(msg = msg, severity = severity, ...)
    },
    info = function(msg = "", severity = "info", ...) {
      self$log(msg = msg, severity = severity, ...)
    },
    warn = function(msg = "", severity = "warn", ...) {
      self$log(msg = msg, severity = severity, ...)
    },
    error = function(msg = "", severity = "error", ...) {
      self$log(msg = msg, severity = severity, ...)
    },
    fatal = function(msg = "", severity = "fatal", ...) {
      self$log(msg = msg, severity = severity, ...)
    },
    is_enabled = function(severity = "info", event_id = NULL) {
      severity <- as_log_severity(severity)
      event_id <- as_event_id(event_id)
      .Call(otel_logger_is_enabled, self$xptr, severity, event_id)
    },
    get_minimum_severity = function() {
      ms <- .Call(otel_get_minimum_log_severity, self$xptr)
      log_severity_levels[match(ms, log_severity_levels)]
    },
    set_minimum_severity = function(minimum_severity) {
      minimum_severity <- as_log_severity(minimum_severity)
      .Call(otel_set_minimum_log_severity, self$xptr, minimum_severity)
      invisible(self)
    },
    log = function(
      msg = "",
      severity = "info",
      event_id = NULL,
      span_id = NULL,
      trace_id = NULL,
      trace_flags = NULL,
      timestamp = Sys.time(),
      observed_timestamp = NULL,
      attributes = NULL,
      .envir = parent.frame()
    ) {
      msg <- as_string(msg, null = FALSE)
      severity <- as_log_severity(severity)
      event_id <- as_event_id(event_id)
      span_id <- as_span_id(span_id)
      trace_id <- as_trace_id(trace_id)
      trace_flags <- as_trace_flags(trace_flags)
      timestamp <- as_timestamp(timestamp)
      observed_timestamp <- as_timestamp(observed_timestamp)
      attributes <- as_otel_attributes(attributes)

      # `attributes` overwrites attributes in the message
      embedded_attributes <- extract_otel_attributes(
        msg,
        .envir = .envir
      )$attributes
      attributes <- utils::modifyList(embedded_attributes, as.list(attributes))

      .Call(
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
  name <- name %||% get_env("OTEL_SERVICE_NAME") %||% "R"
  self$provider <- provider
  minimum_severity <- as_log_severity(minimum_severity)
  self$name <- as_string(name)
  self$version <- as_string(version)
  self$schema_url <- as_string(schema_url)
  self$attributes <- as_otel_attributes(attributes)
  self$xptr <- .Call(
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

log_severity_levels <- c(
  "trace" = 1L,
  "trace2" = 2L,
  "trace3" = 3L,
  "trace4" = 4L,
  "debug" = 5L,
  "debug2" = 6L,
  "debug3" = 7L,
  "debug4" = 8L,
  "info" = 9L,
  "info2" = 10L,
  "info3" = 11L,
  "info4" = 12L,
  "warn" = 13L,
  "warn2" = 14L,
  "warn3" = 15L,
  "warn4" = 16L,
  "error" = 17L,
  "error2" = 18L,
  "error3" = 19L,
  "error4" = 20L,
  "fatal" = 21L,
  "fatal2" = 22L,
  "fatal3" = 23L,
  "fatal4" = 24L,
  NULL
)

log_severity_levels_spec <- c(
  "invalid" = 0L,
  log_severity_levels,
  "maximumseverity" = 255L,
  NULL
)
