# fmt: skip file

# safe start
logger_provider_memory_new <- function(opts = NULL) {
  opts <- as_logger_provider_memory_options(opts)

  self <- new_object(
    c("otel_logger_provider_memory", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      tryCatch({                                                     # safe
        logger_new(
          self,
          name,
          minimum_severity,
          version,
          schema_url,
          attributes,
          ...
        )
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        noop_logger()                                                # safe
      })                                                             # safe
    },
    flush = function() {
      tryCatch({                                                     # safe
        ccall(otel_logger_provider_flush, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        invisible(NULL)                                              # safe
      })                                                             # safe
    },
    shutdown = function() {
      tryCatch({                                                     # safe
        ccall(otel_logger_provider_shutdown, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },
    get_logs = function() {
      tryCatch({                                                     # safe
        logs <- ccall(otel_logger_provider_memory_get_logs, self$xptr)
        lapply(logs, function(x) {
          x[["severity"]] <-
            otel::log_severity_levels[match(
              x[["severity"]],
              otel::log_severity_levels
            )]
          x
        })
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        list()                                                       # safe
      })                                                             # safe
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_logger_provider_memory, opts, attributes)
  self
}
# safe end

logger_provider_memory_options <- function() {
  as_logger_provider_memory_options(NULL)
}

#' In-memory logger provider for testing
#'
#' @description
#' Collects log records in memory. This is useful for testing your
#' instrumented R package or application.
#'
#' # Usage
#'
#' ```
#' lp <- logger_provider_memory$new(opts = NULL)
#' lp$get_logs()
#' logger_provider_memory$options()
#' ```
#'
#' `lp$get_logs()` erases the internal buffer of the logger provider.
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Options
#'
#' ## Memory exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_memory_exporter_options(logger_provider_memory_options_evs()))
#' ```
#'
#' @return
#' `logger_provider_memory$new()` returns an [otel::otel_logger_provider]
#' object. `lp$get_logs()` returns an unnamed list of recorded log records,
#' in the order they were emitted. If the buffer is full, then the oldest
#' log records are dropped.
#'
#' `logger_provider_memory$options()` returns a named list, the current
#' values for all options.
#'
#' @usage NULL
#' @format NULL
#' @export
#' @examples
#' logger_provider_memory$options()

logger_provider_memory <- list(
  new = logger_provider_memory_new,
  options = logger_provider_memory_options
)
