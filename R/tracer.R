tracer <- list(
  new = function(provider, name, ...) {
    self <- new_object(
      "opentelemetry_tracer",
      start_span = function(name, ..., scope = parent.frame()) {
        span$new(self, name, ..., scope = scope)
      },
      is_enabled = function(...) TRUE,
      name = NULL
    )
    self$provider <- provider
    self$name <- name
    self$xptr <- .Call(otel_get_tracer, self$provider$xptr, self$name)
    self
  }
)
