span <- list(
  new = function(
      tracer,
      name,
      attributes = NULL,
      links = NULL,
      options = NULL,
      scope) {

    attributes <- as_span_attributes(attributes)
    links <- as_span_links(links)
    options <- as_span_options(options)
    scope <- as_env(scope)

    self <- new_object(
      "otel_span",

      # TODO: maybe we don't need to get the context explicitly
      # get_context = function() {
      #   .Call(otel_span_get_context, self$xptr)
      # },

      is_recording = function() {
        .Call(otel_span_is_recording, self$xptr)
      },

      set_attribute = function(name, value = NULL) {
        name <- as_string(name, null = FALSE)
        value <- as_span_attribute_value(value)
        .Call(otel_span_set_attribute, self$xptr, name, value)
        invisible(self)
      },

      add_event = function(name, attributes = NULL, timestamp = NULL) {
        name <- as_string(name, null = FALSE)
        attributes <- as_span_attributes(attributes)
        timestamp <- as_timestamp(timestamp)
        .Call(otel_span_add_event, self$xptr, name, attributes, timestamp)
        invisible(self)
      },

      # This needs ABI v2
      # add_link = function(link) {
      #   .Call(otel_span_add_link, self$xptr, link)
      #   invisible(self)
      # },

      set_status = function(status_code = NULL, description = NULL) {
        status_code <- as_choice(status_code, span_status_codes)
        description <- as_string(description)
        .Call(otel_span_set_status, self$xptr, status_code, description)
        invisible(self)
      },

      update_name = function(name) {
        name <- as_string(name, null = FALSE)
        .Call(otel_span_update_name, self$xptr, name)
        invisible(self)
      },

      end = function(options = NULL) {
        options <- as_end_span_options(options)
        .Call(otel_span_end, self$xptr, options)
        invisible(self)
      },

      record_exception = function(attributes = NULL) {
        invisible(self)
      },

      name = NULL
    )

    self$tracer <- tracer
    self$name <- name
    self$attributes <- attributes
    self$links <- links
    self$options <- options

    parent <- options[["parent"]][["xptr"]][[1]]
    self$xptr <- .Call(
      otel_start_span,
      self$tracer$xptr, self$name, attributes, links, options
    )
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

span_kinds <- c(
  default = "internal", "server", "client", "producer", "consumer"
)

span_status_codes <- c(default = "unset", "ok", "error")
