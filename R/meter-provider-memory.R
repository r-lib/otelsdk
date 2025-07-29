meter_provider_memory_new <- function(opts = NULL) {
  opts <- as_meter_provider_memory_options(opts)
  self <- new_object(
    c("otel_meter_provider_memory", "otel_meter_provider"),
    get_meter = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      meter_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function(timeout = NULL) {
      invisible(ccall(otel_meter_provider_flush, self$xptr, timeout))
    },
    shutdown = function(timeout = NULL) {
      ccall(otel_meter_provider_shutdown, self$xptr, timeout)
      invisible(self)
    },
    get_metrics = function() {
      ccall(otel_meter_provider_memory_get_metrics, self$xptr)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_memory, opts, attributes)
  self
}

meter_provider_memory_options <- function() {
  as_meter_provider_memory_options(NULL)
}

#' In-memory meter provider for testing
#'
#' @description
#' Collects metrics measurements in memory. This is useful for testing your
#' instrumented R package or application.
#'
#' [with_otel_record()] uses this meter provider.
#' Use [with_otel_record()] in your tests to record telemetry and check
#' that it is correct.
#'
#' # Usage
#'
#' ```
#' mp <- meter_provider_memory$new(opts = NULL)
#' mp$get_metrics()
#' meter_provider_memory$options()
#' ```
#'
#' `mp$get_metrics()` erases the internal buffer of the meter provider.
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Value
#'
#' `meter_provider_memory$new()` returns an [otel::otel_meter_provider]
#' object. `mp$get_metrics()` returns a named list of recorded metrics.
#'
#' `meter_provider_memory$options()` returns a named list, the current
#' values for all options.
#'
#' # Options
#'
#' ## Memory exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_memory_exporter_options(meter_provider_memory_options_evs()))
#' ```
#'
#' ## Metric reader options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_metric_reader_options())
#' ```
#'
#' ## Metric exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_metric_exporter_options())
#' ```
#'
#' @usage NULL
#' @format NULL
#' @export

meter_provider_memory <- list(
  new = meter_provider_memory_new,
  options = meter_provider_memory_options
)
