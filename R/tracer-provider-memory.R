tracer_provider_memory_new <- function(buffer_size = 100) {
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
      .Call(otel_tracer_provider_memory_get_spans, self$xptr)
    }
  )

  buffer_size <- as_count(buffer_size, positive = TRUE)
  self$xptr <- .Call(otel_create_tracer_provider_memory, buffer_size)
  self
}

tracer_provider_memory <- list(
  new = tracer_provider_memory_new
)
