meter_provider_stdstream_new <- function(opts = NULL) {
  opts <- as_meter_provider_stdstream_options(opts)
  self <- new_object(
    c("otel_meter_provider_stdstream", "otel_meter_provider"),
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
      # TODO: check arg
      ccall(otel_meter_provider_flush, self$xptr, timeout)
    },
    shutdown = function(timeout = NULL) {
      ccall(otel_meter_provider_shutdown, self$xptr, timeout)
      invisible(self)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_stdstream, opts, attributes)
  self
}

meter_provider_stdstream_options <- function() {
  as_meter_provider_stdstream_options(NULL)
}

#' Meter provider to write to the standard output or standard error or
#' to a file
#'
#' @description
#' Writes metrics measurements to the standard output or error, or to a
#' file. Useful for debugging.
#'
#' # Usage
#'
#' Externally:
#' ```
#' OTEL_METRICS_EXPORTER=console
#' OTEL_METRICS_EXPORTER=stderr
#' ```
#'
#' From R:
#' ```
#' meter_provider_stdstream$new(opts = NULL)
#' meter_provider_stdstream$options()
#' ```
#'
#' # Arguments
#'
#' `opts`: Named list of options. See below.
#'
#' # Value
#'
#' `meter_provider_stdstream$new()` returns an [otel::otel_meter_provider]
#' object.
#'
#' `meter_provider_stdstream$options()` returns a named list, the current
#' values of the options.
#'
#' # Options
#'
#' ## Standard stream exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_stdstream_exporter_options(
#'   meter_provider_stdstream_options_evs()
#' ))
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
#' @format NULL
#' @usage NULL
#' @export

meter_provider_stdstream <- list(
  new = meter_provider_stdstream_new,
  options = meter_provider_stdstream_options
)
