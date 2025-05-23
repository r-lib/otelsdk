tracer_new <- function(
  provider,
  name = NULL,
  version = NULL,
  schema_url = NULL,
  attributes = NULL,
  ...
) {
  self <- new_object(
    "otel_tracer",
    start_span = function(
      name = NULL,
      attributes = NULL,
      links = NULL,
      options = NULL,
      scope = parent.frame()
    ) {
      span_new(
        self,
        name = name,
        attributes = attributes,
        links = links,
        options = options,
        scope = scope
      )
    },
    is_enabled = function(...) TRUE,
    get_current_span_context = function() {
      xptr <- .Call(otel_get_current_span_context, self$xptr)
      span_context_new(xptr)
    },
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
    extract_http_context = function(headers) {
      headers <- as_http_context_headers(headers)
      xptr <- .Call(otel_extract_http_context, headers)
      span_context_new(xptr)
    }
  )
  name <- name %||% get_env("OTEL_SERVICE_NAME") %||% "R"
  self$provider <- provider
  self$name <- as_string(name)
  self$version <- as_string(version)
  self$schema_url <- as_string(schema_url)
  self$attributes <- as_otel_attributes(attributes)
  self$xptr <- .Call(
    otel_get_tracer,
    self$provider$xptr,
    self$name,
    self$version,
    self$schema_url,
    self$attributes
  )
  self
}
