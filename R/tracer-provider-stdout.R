tracer_provider_stdstream_new <- function(opts = NULL) {
  opts <- as_tracer_provider_stdstream_options(opts)
  self <- new_object(
    c("otel_tracer_provider_stdstream", "otel_tracer_provider"),
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
  self$xptr <- ccall(otel_create_tracer_provider_stdstream, opts, attributes)
  self
}

tracer_provider_stdstream_options <- function() {
  as_tracer_provider_stdstream_options(NULL)
}

#' Tracer provider to write to the standard output or standard error or
#' to a file
#' @export

tracer_provider_stdstream <- list(
  new = tracer_provider_stdstream_new,
  options = tracer_provider_stdstream_options
)
