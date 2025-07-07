tracer_provider_http_new <- function(opts = NULL) {
  opts <- as_tracer_provider_http_options(opts)
  self <- new_object(
    c("otel_tracer_provider_http", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
      ccall(otel_tracer_provider_flush, self$xptr)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_http, opts, attributes)
  self
}

tracer_provider_http_options <- function() {
  ropts <- as_tracer_provider_http_options(NULL)
  copts <- ccall(otel_tracer_provider_http_options)
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
  bspopts <- ccall(otel_bsp_defaults)
  ropts <- utils::modifyList(ropts, bspopts)

  ropts
}

#' Tracer provider to export over HTTP
#' @export

tracer_provider_http <- list(
  new = tracer_provider_http_new,
  options = tracer_provider_http_options
)
