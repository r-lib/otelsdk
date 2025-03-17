span <- list(
  new = function(
      tracer,
      name,
      attributes = NULL,
      links = NULL,
      options = NULL,
      scope) {

    options[["start_system_time"]] <-
      as_timestamp(options[["start_system_time"]])
    options[["start_steady_time"]] <-
      as_timestamp(options[["start_steady_time"]])
    options[["parent"]] <- as_span(options[["parent"]], na = TRUE)
    options[["kind"]] <- as_choice(options[["kind"]], span_kinds)
    scope <- as_env(scope)

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
    self$attributes <- attributes
    self$links <- links
    self$options <- options

    parent <- options[["parent"]][["xptr"]][[1]]
    self$xptr <- .Call(
      otel_start_span,
      self$tracer$xptr, self$name, attributes, links, options, parent
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
