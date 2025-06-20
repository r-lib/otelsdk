tracer_provider_http_new <- function() {
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
  self$xptr <- ccall(otel_create_tracer_provider_http, attributes)
  self
}

tracer_provider_http_options <- function() {
  ccall(otel_tracer_provider_http_options)
}

#' Tracer provider to export over HTTP
#' @export

tracer_provider_http <- list(
  new = tracer_provider_http_new,
  options = tracer_provider_http_options
)
