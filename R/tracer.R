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
      xptr <- ccall(otel_get_current_span_context, self$xptr)
      span_context_new(xptr)
    },
    start_session = function() {
      ccall(otel_start_session)
    },
    activate_session = function(session) {
      ccall(otel_activate_session, session)
    },
    deactivate_session = function() {
      ccall(otel_deactivate_session)
    },
    finish_session = function(session) {
      ccall(otel_finish_session, session)
    },
    finish_all_sessions = function() {
      ccall(otel_finish_all_sessions)
    },
    flush = function() {
      self$provider$flush()
    },
    extract_http_context = function(headers) {
      headers <- as_http_context_headers(headers)
      xptr <- ccall(otel_extract_http_context, headers)
      span_context_new(xptr)
    }
  )
  name <- name %||% get_env("OTEL_SERVICE_NAME") %||% "R"
  self$provider <- provider
  self$name <- as_string(name)
  self$version <- as_string(version)
  self$schema_url <- as_string(schema_url)
  self$attributes <- as_otel_attributes(attributes)
  self$xptr <- ccall(
    otel_get_tracer,
    self$provider$xptr,
    self$name,
    self$version,
    self$schema_url,
    self$attributes
  )
  self
}

# for debugging

otel_current_session <- function() {
  ccall(otel_debug_current_session)
}

get_span_id <- function(span) {
  span$get_context()$get_span_id()
}
