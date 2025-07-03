tracer_provider_file_new <- function(opts = NULL) {
  opts <- as_tracer_provider_file_options(opts)

  self <- new_object(
    c("otel_tracer_provider_file", "otel_tracer_provider"),
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
  self$xptr <- ccall(otel_create_tracer_provider_file, opts, attributes)
  self
}

#' Tracer provider to write traces into a JSONL file
#' @export

tracer_provider_file <- list(
  new = tracer_provider_file_new,
  options = function() {
    utils::modifyList(
      as_tracer_provider_file_options(NULL),
      ccall(otel_tracer_provider_file_options_defaults)
    )
  }
)
