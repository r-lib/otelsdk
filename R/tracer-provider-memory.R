tracer_provider_memory_new <- function(opts = NULL) {
  opts <- as_tracer_provider_memory_options(opts)
  self <- new_object(
    c("otel_tracer_provider_memory", "otel_tracer_provider"),
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
      # noop currently
    },
    get_spans = function() {
      spans <- ccall(otel_tracer_provider_memory_get_spans, self$xptr)
      names(spans) <- map_chr(spans, function(x) x[["name"]] %||% "")
      spans
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_memory, opts, attributes)
  self
}

tracer_provider_memory_options <- function() {
  as_tracer_provider_memory_options(NULL)
}

#' @export

tracer_provider_memory <- list(
  new = tracer_provider_memory_new,
  options = tracer_provider_memory_options
)
