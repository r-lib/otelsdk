meter_provider_http_new <- function(opts = NULL) {
  opts <- as_meter_provider_http_options(opts)

  self <- new_object(
    c("otel_meter_provider_http", "otel_meter_provider"),
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
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_http, opts, attributes)
  self
}

meter_provider_http_options <- function() {
  ropts <- as_meter_provider_http_options(NULL)
  copts <- ccall(otel_meter_provider_http_options)
  # override the ones that are in the spec
  spec <- c(
    "url",
    "content_type",
    "timeout",
    "http_headers",
    "ssl_ca_cert_path",
    "ssl_ca_cert_string",
    "ssl_client_key_path",
    "ssl_client_key_string",
    "ssl_client_cert_path",
    "ssl_client_cert_string",
    "compression"
  )
  ropts[spec] <- copts[spec]
  ropts[["content_type"]] <- as_otlp_content_type(ropts[["content_type"]])
  ropts
}

#' Meter provider to send collected metrics over HTTP
#'
#' @description
#' This is the OTLP HTTP exporter.
#'
#' Select this tracer provider with `OTEL_METRICS_EXPORTER=otlp`.
#'
#' # Usage
#'
#' Externally:
#' ```
#' OTEL_METRICS_EXPORTER=otlp
#' ```
#'
#' From R:
#' ```
#' meter_provider_http$new(opts = NULL)
#' meter_provider_http$options()
#' ```
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Options
#'
#' ## HTTP exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_http_exporter_options(
#'   "metrics",
#'   meter_provider_http_options_evs(),
#'   meter_provider_http$options()
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
#' ## Metric exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_metric_exporter_options())
#' ```
#'
#' @return
#' `meter_provider_http$new()` returns an [otel::otel_meter_provider]
#' object.
#'
#' `meter_provider_http$options()` returns a named list, the current
#' values for all options.
#'
#' @format NULL
#' @usage NULL
#' @export
#' @examples
#' meter_provider_http$options()

meter_provider_http <- list(
  new = meter_provider_http_new,
  options = meter_provider_http_options
)
