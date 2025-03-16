span <- list(
  new = function(
      tracer,
      name,
      parent = NULL,
      span_kind = "internal",
      attributes = NULL,
      links = NULL,
      start_timestamp = NULL,
      scope) {

    if (!is.null(parent) && is_na(parent) &&
        !inherits(parent, "opentelemetry_span")) {
      stop(
        "`parent` must be an `opentelemetry_span` object when ",
        "creating an Opentelemetry span"
      )
    }

    self <- new_object(
      "opentelemetry_span",
      get_context = function() {
        # TODO?
      },

      is_recording = function() {
        TRUE
      },

      set_attribute = function(name, value = NULL) {
        invisible(self)
      },

      add_event = function(name, attributes = NULL, timestamp = NULL) {
        invisible(self)
      },

      add_link = function(link) {
        invisible(self)
      },

      set_status = function(
        status_code = c("unset", "ok", "error"),
        description = NULL) {
          invisible(self)
        },

      update_name = function(name) {
        invisible(self)
      },

      end = function() {
        .Call(otel_span_end, self$xptr)
        invisible(self)
      },

      record_exception = function(attributes = NULL) {
        invisible(self)
      },

      name = NULL
    )

    self$tracer <- tracer
    self$name <- name
    self$parent <- parent
    self$span_kind <- span_kind
    self$attributes <- attributes
    self$links <- links
    self$start_timestamp <- start_timestamp
    self$xptr <- .Call(otel_start_span, self$tracer$xptr, self$name, self$parent$xptr[[1]])
    self$scoped <- FALSE
    if (!is.null(scope) && !is_na(scope)) {
      if (!is.environment(scope)) {
        stop("Opentelemetry span scope must be an environment.")
      }
      self$scoped <- TRUE
      defer(self$end(), envir = scope)
    }

    self
  }
)
