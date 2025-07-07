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
  ropts
}

#' Logger provider to log over HTTP
#' @export

logger_provider_http <- list(
  new = logger_provider_http_new,
  options = logger_provider_http_options
)
