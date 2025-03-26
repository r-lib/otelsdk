tracer_new <- function(provider, name, ...) {
  self <- new_object(
    "otel_tracer",
    start_span = function(name = NULL, attributes = NULL, links = NULL,
                          options = NULL, scope = parent.frame()) {
      span_new(
        self, name = name, attributes = attributes, links = links,
        options = options, scope = scope
      )
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
    finish_all_sessions = function() {
      .Call(otel_finish_all_sessions)
    },
    flush = function() {
      self$provider$flush()
    },
    name = NULL
  )
  self$provider <- provider
  self$name <- name
  self$xptr <- .Call(otel_get_tracer, self$provider$xptr, self$name)
  self
}
