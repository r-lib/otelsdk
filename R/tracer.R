tracer_new <- function(
  provider,
  name = NULL,
  version = NULL,
  schema_url = NULL,
  attributes = NULL,
  ...
) {
  name <- as_string(name, null = TRUE)
  inst_scope <- find_instrumentation_scope(name)
  name <- name %||% inst_scope[["name"]]
  if (!inst_scope[["on"]]) {
    return(otel::tracer_provider_noop()$get_tracer(name))
  }

  self <- new_object(
    "otel_tracer",
    start_span = function(
      name = NULL,
      attributes = NULL,
      links = NULL,
      options = NULL,
      scope = parent.frame(),
      activation_scope = parent.frame()
    ) {
      span_new(
        self,
        name = name,
        attributes = attributes,
        links = links,
        options = options,
        scope = scope,
        activation_scope = activation_scope
      )
    },
    is_enabled = function(...) TRUE,
    get_active_span_context = function() {
      xptr <- ccall(otel_get_active_span_context, self$xptr)
      span_context_new(xptr)
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
