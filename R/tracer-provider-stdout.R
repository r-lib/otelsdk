tracer_provider_stdstream_new <- function(stream = NULL) {
  stream <- as_string(stream) %||%
    Sys.getenv(tracer_provider_stdstream_output, "stdout")
  if (stream != "stdout" && stream != "stderr") {
    stream <- as_output_file(stream, null = FALSE)
  }
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
      .Call(otel_tracer_provider_flush, self$xptr)
    }
  )
  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- .Call(otel_create_tracer_provider_stdstream, stream, attributes)
  self
}

#' Tracer provider to write to the standard output or standard error or
#' to a file
#' @export

tracer_provider_stdstream <- list(
  new = tracer_provider_stdstream_new
)
