span_new <- function(
  tracer,
  name = NULL,
  attributes = NULL,
  links = NULL,
  options = NULL,
  scope
) {
  name <- name %||% default_span_name
  name <- as_string(name)
  attributes <- as_otel_attributes(attributes)
  links <- as_span_links(links)
  options <- as_span_options(options)
  scope <- as_env(scope)

  self <- new_object(
    "otel_span",

    get_context = function() {
      xptr <- .Call(otel_span_get_context, self$xptr)
      span_context_new(xptr)
    },

    is_valid = function() {
      .Call(otel_span_is_valid, self$xptr)
    },

    is_recording = function() {
      .Call(otel_span_is_recording, self$xptr)
    },

    set_attribute = function(name, value = NULL) {
      name <- as_string(name, null = FALSE)
      value <- as_otel_attribute_value(value)
      .Call(otel_span_set_attribute, self$xptr, name, value)
      invisible(self)
    },

    add_event = function(name, attributes = NULL, timestamp = NULL) {
      name <- as_string(name, null = FALSE)
      attributes <- as_otel_attributes(attributes)
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
            err <- get_current_error()
            if (!err$tried || !isTRUE(err$success)) {
              # no error object because exiting or could not get it
              # create a stacktrace nevertheless
              cnd <- structure(
                list(message = "Unknown error"),
                class = c("error", "condition")
              )
            } else {
              cnd <- err$object
            }
            exception <- format_exception(cnd)
            if (
              identical(exception$exception.stacktrace, "<stacktrace missing>")
            ) {
              exception$exception.stacktrace <-
                utils::capture.output(traceback(sys.calls()))
            }
            tryCatch(
              self$add_event("exception", exception),
              error = function(err) NULL
            )
            status_code <- 2L
          } else {
            status_code <- 1L
          }
        }
      }
      .Call(otel_span_end, self$xptr, options, status_code)
      invisible(self)
    },

    record_exception = function(error_condition, attributes = NULL, ...) {
      exception <- format_exception(error_condition)
      attributes <- as_otel_attributes(attributes)
      attr <- utils::modifyList(exception, as.list(attributes))
      self$add_event("exception", attributes = attr, ...)
      invisible(self)
    },

    name = NULL
  )

  self$tracer <- tracer
  self$name <- name
  self$status_set <- FALSE

  self$xptr <- .Call(
    otel_start_span,
    self$tracer$xptr,
    self$name,
    attributes,
    links,
    options
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
  default = "internal",
  "server",
  "client",
  "producer",
  "consumer"
)

span_status_codes <- c(default = "unset", "ok", "error")

span_context_new <- function(xptr) {
  self <- new_object(
    "otel_span_context",

    is_valid = function() {
      .Call(otel_span_context_is_valid, self$xptr)
    },
    get_trace_flags = function() {
      .Call(otel_span_context_get_trace_flags, self$xptr)
    },
    get_trace_id = function() {
      .Call(otel_span_context_get_trace_id, self$xptr)
    },
    get_span_id = function() {
      .Call(otel_span_context_get_span_id, self$xptr)
    },
    is_remote = function() {
      .Call(otel_span_context_is_remote, self$xptr)
    },
    is_sampled = function() {
      .Call(otel_span_context_is_sampled, self$xptr)
    },
    to_http_headers = function() {
      hdrs <- .Call(otel_span_context_to_headers, self$xptr)
      hdrs[hdrs != ""]
    }
  )
  self$xptr <- xptr

  self
}

format_exception <- function(error_condition) {
  message <- tryCatch(
    utils::capture.output(error_condition),
    error = function(err) NULL
  ) %||%
    tryCatch(
      conditionMessage(error_condition),
      error = function(err) NULL
    ) %||%
    tryCatch(
      error_condition[["message"]],
      error = function(err) NULL
    ) %||%
    "<error message missing>"

  stacktrace <- if ("trace" %in% names(error_condition)) {
    tryCatch(
      utils::capture.output(error_condition[["trace"]]),
      error = function(err) NULL
    )
  }
  stacktrace <- stacktrace %||%
    tryCatch(
      {
        cl <- conditionCall(error_condition)
        if (!is.null(cl)) format(cl)
      },
      error = function(err) NULL
    ) %||%
    "<stacktrace missing>"

  type <- class(error_condition)

  list(
    exception.message = message,
    exception.stacktrace = stacktrace,
    exception.type = type
  )
}
