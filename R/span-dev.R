
span_base_new_dev <- function(
  tracer,
  xptr
) {
  self <- new_object(
    "otel_span",

    get_context = function() {
        xptr <- ccall(otel_span_get_context, self$xptr)
        span_context_new(xptr)
    },

    is_valid = function() {
        ccall(otel_span_is_valid, self$xptr)
    },

    is_recording = function() {
        ccall(otel_span_is_recording, self$xptr)
    },

    set_attribute = function(name, value = NULL) {
        name <- as_string(name, null = FALSE)
        value <- as_otel_attribute_value(value)
        ccall(otel_span_set_attribute, self$xptr, name, value)
      invisible(self)
    },

    add_event = function(name, attributes = NULL, timestamp = NULL) {
        name <- as_string(name, null = FALSE)
        attributes <- as_otel_attributes(attributes)
        timestamp <- as_timestamp(timestamp)
        ccall(otel_span_add_event, self$xptr, name, attributes, timestamp)
      invisible(self)
    },

    add_link = function(target, attributes) {
        target <- as_span(target)
        attributes <- as_otel_attributes(attributes)
        ccall(otel_span_add_link, self$xptr, target$xptr, attributes)
      invisible(self)
    },

    set_status = function(status_code = NULL, description = NULL) {
        status_code <- as_choice(status_code, the$span_status_codes)
        description <- as_string(description)
        ccall(otel_span_set_status, self$xptr, status_code, description)
      invisible(self)
    },

    update_name = function(name) {
        name <- as_string(name, null = FALSE)
        ccall(otel_span_update_name, self$xptr, name)
        self$name <- name
      invisible(self)
    },

    end = function(options = NULL, status_code = NULL) {
      # Must be called here, directly from end(), to see the return value
      # of the function that is exiting, if we are in on.exit().
      error_exit <- identical(returnValue(random_token), random_token)
        options <- as_end_span_options(options)
        # if NULL, then we leave it as is, maybe it was explicitly set
        if (!is.null(status_code)) {
          status_code <- as_choice(
            status_code,
            c(the$span_status_codes, "auto")
          )
          # if 'auto' then we are in 'on.exit()', check if this is an error
          if (status_code == 3L) {
            is_status_set <- ccall(otel_span_is_status_set, self$xptr)
            if (is_status_set) {
              status_code <- NULL
            } else if (error_exit) {
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
                identical(
                  exception$exception.stacktrace,
                  "<stacktrace missing>"
                )
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
        ccall(otel_span_end, self$xptr, options, status_code)
      invisible(self)
    },

    record_exception = function(error_condition, attributes = NULL, ...) {
        exception <- format_exception(error_condition)
        attributes <- as_otel_attributes(attributes)
        attr <- utils::modifyList(exception, as.list(attributes))
        self$add_event("exception", attributes = attr, ...)
      invisible(self)
    },

    activate = function(
      activation_scope = parent.frame(),
      end_on_exit = FALSE
    ) {
        force(end_on_exit)
        cscope <- ccall(otel_scope_start, self$xptr)
        if (!is.null(activation_scope)) {
          defer(
            {
              ccall(otel_scope_end, cscope)
              if (end_on_exit) self$end(status_code = "auto")
            },
            envir = activation_scope
          )
        } else {
          cscope
        }
    },

    deactivate = function(cscope) {
        ccall(otel_scope_end, cscope)
      invisible(NULL)
    },

    name = NULL
  )

  self$tracer <- tracer
  self$xptr <- xptr

  self
}

span_context_new_dev <- function(xptr) {
  self <- new_object(
    "otel_span_context",

    is_valid = function() {
        ccall(otel_span_context_is_valid, self$xptr)
    },
    get_trace_flags = function() {
        ccall(otel_span_context_get_trace_flags, self$xptr)
    },
    get_trace_id = function() {
        ccall(otel_span_context_get_trace_id, self$xptr)
    },
    get_span_id = function() {
        ccall(otel_span_context_get_span_id, self$xptr)
    },
    is_remote = function() {
        ccall(otel_span_context_is_remote, self$xptr)
    },
    is_sampled = function() {
        ccall(otel_span_context_is_sampled, self$xptr)
    },
    to_http_headers = function() {
        hdrs <- ccall(otel_span_context_to_headers, self$xptr)
        hdrs[hdrs != ""]
    }
  )
  self$xptr <- xptr

  self
}
