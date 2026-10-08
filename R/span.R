# safe start
span_base_new <- function(
  tracer,
  xptr
) {
  self <- new_object(
    "otel_span",

    get_context = function() {
      tryCatch({                                                     # safe
        xptr <- ccall(otel_span_get_context, self$xptr)
        span_context_new(xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        invalid_span_context()                                       # safe
      })                                                             # safe
    },

    is_valid = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_is_valid, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        FALSE                                                        # safe
      })                                                             # safe
    },

    is_recording = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_is_recording, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        FALSE                                                        # safe
      })                                                             # safe
    },

    set_attribute = function(name, value = NULL) {
      tryCatch({                                                     # safe
        name <- as_string(name, null = FALSE)
        value <- as_otel_attribute_value(value)
        ccall(otel_span_set_attribute, self$xptr, name, value)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },

    add_event = function(name, attributes = NULL, timestamp = NULL) {
      tryCatch({                                                     # safe
        name <- as_string(name, null = FALSE)
        attributes <- as_otel_attributes(attributes)
        timestamp <- as_timestamp(timestamp)
        ccall(otel_span_add_event, self$xptr, name, attributes, timestamp)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },

    add_link = function(target, attributes) {
      tryCatch({                                                     # safe
        target <- as_span(target)
        attributes <- as_otel_attributes(attributes)
        ccall(otel_span_add_link, self$xptr, target$xptr, attributes)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },

    set_status = function(status_code = NULL, description = NULL) {
      tryCatch({                                                     # safe
        status_code <- as_choice(status_code, the$span_status_codes)
        description <- as_string(description)
        ccall(otel_span_set_status, self$xptr, status_code, description)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },

    update_name = function(name) {
      tryCatch({                                                     # safe
        name <- as_string(name, null = FALSE)
        ccall(otel_span_update_name, self$xptr, name)
        self$name <- name
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },

    end = function(options = NULL, status_code = NULL) {
      # Must be called here, directly from end(), to see the return value
      # of the function that is exiting, if we are in on.exit().
      error_exit <- identical(returnValue(random_token), random_token)
      tryCatch({                                                     # safe
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
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },

    record_exception = function(error_condition, attributes = NULL, ...) {
      tryCatch({                                                     # safe
        exception <- format_exception(error_condition)
        attributes <- as_otel_attributes(attributes)
        attr <- utils::modifyList(exception, as.list(attributes))
        self$add_event("exception", attributes = attr, ...)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    },

    activate = function(
      activation_scope = parent.frame(),
      end_on_exit = FALSE
    ) {
      tryCatch({                                                     # safe
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
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        NULL                                                         # safe
      })                                                             # safe
    },

    deactivate = function(cscope) {
      tryCatch({                                                     # safe
        ccall(otel_scope_end, cscope)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(NULL)
    },

    name = NULL
  )

  self$tracer <- tracer
  self$xptr <- xptr

  self
}
# safe end

span_new <- function(
  tracer,
  name = NULL,
  attributes = NULL,
  links = NULL,
  options = NULL,
  scope = NULL,
  activation_scope = NULL
) {
  name <- name %||% default_span_name
  name <- as_string(name)
  attributes <- as_otel_attributes(attributes)
  links <- as_span_links(links)
  options <- as_span_options(options)
  scope <- as_env(scope)
  activation_scope <- as_env(activation_scope)

  xptr <- ccall(
    otel_start_span,
    tracer$xptr,
    name,
    attributes,
    links,
    options
  )

  self <- span_base_new(tracer, xptr)
  self$name <- name

  if (!is.null(scope)) {
    defer(self$end(status_code = "auto"), envir = scope)
  }
  if (!is.null(activation_scope)) {
    cscope <- ccall(otel_scope_start, self$xptr)
    defer(ccall(otel_scope_end, cscope), envir = activation_scope)
  }

  self
}

default_span_name <- "<NA>"

random_token <- "DxMi8lklYBT6z835eeMF1AjL90ioUMIP"

# safe start
span_context_new <- function(xptr) {
  self <- new_object(
    "otel_span_context",

    is_valid = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_context_is_valid, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        FALSE                                                        # safe
      })                                                             # safe
    },
    get_trace_flags = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_context_get_trace_flags, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        list()                                                       # safe
      })                                                             # safe
    },
    get_trace_id = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_context_get_trace_id, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        otel::invalid_trace_id                                       # safe
      })                                                             # safe
    },
    get_span_id = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_context_get_span_id, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        otel::invalid_span_id                                        # safe
      })                                                             # safe
    },
    is_remote = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_context_is_remote, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        FALSE                                                        # safe
      })                                                             # safe
    },
    is_sampled = function() {
      tryCatch({                                                     # safe
        ccall(otel_span_context_is_sampled, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        FALSE                                                        # safe
      })                                                             # safe
    },
    to_http_headers = function() {
      tryCatch({                                                     # safe
        hdrs <- ccall(otel_span_context_to_headers, self$xptr)
        hdrs[hdrs != ""]
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        structure(character(), names = character())                 # safe
      })                                                             # safe
    }
  )
  self$xptr <- xptr

  self
}
# safe end

invalid_span_context <- function() {
  otel::tracer_provider_noop$new()$get_tracer()$get_active_span_context()
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
