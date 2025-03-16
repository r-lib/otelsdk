tracer <- list(
  new = function(provider, name, ...) {
    self <- new_object(
      "opentelemetry_tracer",
      start_span = function(name, ..., scope = parent.frame()) {
        span$new(self, name, ..., scope = scope)
      },
      is_enabled = function(...) TRUE,
      start_session = function() {
        .Call(otel_start_session)
      },
      activate_session = function(session) {
        .Call(otel_activate_session, session)
      },
      deactivate_session = function(session) {
        .Call(otel_deactivate_session, session)
      },
      finish_session = function(session) {
        .Call(otel_finish_session, session)
      },
      name = NULL
    )
    self$provider <- provider
    self$name <- name
    self$xptr <- .Call(otel_get_tracer, self$provider$xptr, self$name)
    self
  }
)
