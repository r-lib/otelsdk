span_new <- function(
  tracer,
  name = NULL,
  attributes = NULL,
  links = NULL,
  options = NULL,
  scope) {

  name <- name %||% default_span_name
  name <- as_string(name)
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
      self$status_set <- TRUE
      invisible(self)
    },

    update_name = function(name) {
      name <- as_string(name, null = FALSE)
      .Call(otel_span_update_name, self$xptr, name)
      invisible(self)
    },

    end = function(options = NULL, status_code = NULL) {
      options <- as_end_span_options(options)
      # if NULL, then we leave it as is, maybe it was explicitly set
      if (!is.null(status_code)) {
        status_code <- as_choice(status_code, c(span_status_codes, "auto"))
        # if 'auto' then we are in 'on.exit()', check if this is an error
        # hopefully returnValue() works for this
        if (status_code == 3L) {
          if (self$status_set) {
            status_code <- NULL
          } else if (identical(returnValue(random_token), random_token)) {
            status_code <- 2L
          } else {
            status_code <- 1L
          }
        }
      }
      .Call(otel_span_end, self$xptr, options, status_code)
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
  self$status_set <- FALSE

  parent <- options[["parent"]][["xptr"]][[1]]
  self$xptr <- .Call(
    otel_start_span,
    self$tracer$xptr, self$name, attributes, links, options
  )
  self$scoped <- FALSE
  if (!is.null(scope) && !is_na(scope)) {
    self$scoped <- TRUE
    defer(self$end(status_code = "auto"), envir = scope)
  }

  self
}

default_span_name <- "<NA>"

random_token <- "DxMi8lklYBT6z835eeMF1AjL90ioUMIP"

span_kinds <- c(
  default = "internal", "server", "client", "producer", "consumer"
)

span_status_codes <- c(default = "unset", "ok", "error")
