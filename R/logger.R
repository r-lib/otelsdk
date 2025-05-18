logger_new <- function(provider, name = NULL, ...) {
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
    # trace = function(...) {
    #   args <- as_log_args(list(...))
    #   .Call(otel_log_trace, self$xptr, args)
    #   invisible(self)
    # },
    # debug = function(...) {
    #   args <- as_log_args(list(...))
    #   .Call(otel_log_debug, self$xptr, args)
    #   invisible(self)
    # },
    # info = function(...) {
    #   args <- as_log_args(list(...))
    #   .Call(otel_log_info, self$xptr, args)
    #   invisible(self)
    # },
    # warn = function(...) {
    #   args <- as_log_args(list(...))
    #   .Call(otel_log_warn, self$xptr, args)
    #   invisible(self)
    # },
    # error = function(...) {
    #   args <- as_log_args(list(...))
    #   .Call(otel_log_error, self$xptr, args)
    #   invisible(self)
    # },
    # fatal = function(...) {
    #   args <- as_log_args(list(...))
    #   .Call(otel_log_fatal, self$xptr, args)
    #   invisible(self)
    # },
    # is_enabled = function(severity, event_id = NULL) {
    #   severity <- as_severity(severity)
    #   event_id <- as_event_id(event_id)
    #   .Call(otel_logger_is_enabled, self$xptr, severity, event_id);
    # },
    log = function(severity, format, event_id = NULL, attributes = NULL) {
      severity <- as_log_severity(severity)
      format <- as_string(format, null = FALSE)
      event_id <- as_event_id(event_id)
      attributes <- as_span_attributes(attributes)
      .Call(otel_log, self$xptr, severity, format, event_id, attributes)
      invisible(self)
    },
    flush = function() {
      self$provider$flush()
    },
    name = NULL
  )
  name <- name %||% get_env("OTEL_SERVICE_NAME") %||% "R"
  self$provider <- provider
  self$name <- name
  self$xptr <- .Call(otel_get_logger, self$provider$xptr, self$name)
  self
}

# log_record_new <- function() {
#   # TODO
# }

log_severity_levels <- c(
  "invalid" = 0L,
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
