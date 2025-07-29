logger_provider_http_new <- function(opts = NULL) {
  opts <- as_logger_provider_http_options(opts)
  self <- new_object(
    c("otel_logger_provider_http", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      logger_new(
        self,
        name,
        minimum_severity,
        version,
        schema_url,
        attributes,
        ...
      )
    },
    flush = function() {
      # noop currenrly
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_logger_provider_http, opts, attributes)
  self
}

logger_provider_http_options <- function() {
  ropts <- as_logger_provider_http_options(NULL)
  copts <- ccall(otel_logger_provider_http_options)
  # override the ones that are in the spec
  spec <- c(
    "url",
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

  # batch processor options are handled by CPP and are in the spec
  blpropts <- ccall(otel_blrp_defaults)
  ropts <- utils::modifyList(ropts, blpropts)

  ropts
}

#' Logger provider to log over HTTP
#'
#' @description
#' This is the OTLP HTTP exporter.
#'
#' # Usage
#'
#' Externally:
#' ```
#' OTEL_LOGS_EXPORTER=otlp
#' ```
#'
#' From R:
#' ```
#' logger_provider_http$new(opts = NULL)
#' logger_provider_http$options()
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
#'   "logs",
#'   logger_provider_http_options_evs(),
#'   logger_provider_http$options()
#' ))
#' ```
#'
#' ## Batch processor options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_batch_processor_options(logger_provider_http$options()))
#' ```
#'
#' @return
#' `logger_provider_http$new()` returns an [otel::otel_logger_provider]
#' object.
#'
#' `logger_provider_http$options()` returns a named list, the current
#' values for all options.
#'
#' @format NULL
#' @usage NULL
#' @export
#' @examples
#' logger_provider_http$options()

logger_provider_http <- list(
  new = logger_provider_http_new,
  options = logger_provider_http_options
)
