# fmt: skip file

logger_provider_file_new_dev <- function(opts = NULL) {
  opts <- as_logger_provider_file_options(opts)

  self <- new_object(
    c("otel_logger_provider_file", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        logger_new(
          self,
          name,
          minimum_severity,
          version,
          schema_url,
          attributes,
          ...
        )
    },
    flush = function() {
        ccall(otel_logger_provider_flush, self$xptr)
    }
  )

  self$xptr <- ccall(otel_create_logger_provider_file, opts)
  self
}

logger_provider_http_new_dev <- function(opts = NULL) {
  opts <- as_logger_provider_http_options(opts)
  self <- new_object(
    c("otel_logger_provider_http", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        logger_new(
          self,
          name,
          minimum_severity,
          version,
          schema_url,
          attributes,
          ...
        )
    },
    flush = function() {
      # noop currenrly
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_logger_provider_http, opts, attributes)
  self
}

logger_provider_stdstream_new_dev <- function(opts = NULL) {
  opts <- as_logger_provider_stdstream_options(opts)

  self <- new_object(
    c("otel_logger_provider_stdstream", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        logger_new(
          self,
          name,
          minimum_severity,
          version,
          schema_url,
          attributes,
          ...
        )
    },
    flush = function() {
        ccall(otel_logger_provider_flush, self$xptr)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_logger_provider_stdstream, opts, attributes)
  self
}

logger_new_dev <- function(
  provider,
  name = NULL,
  minimum_severity = NULL,
  version = NULL,
  schema_url = NULL,
  attributes = NULL,
  ...
) {
  name <- as_string(name, null = TRUE)
  inst_scope <- find_instrumentation_scope(name)
  name <- name %||% inst_scope[["name"]]
  if (!inst_scope[["on"]]) {
    return(otel::logger_provider_noop$new()$get_logger(name))
  }

  self <- new_object(
    "otel_logger",
    get_name = function() {
        ccall(otel_logger_get_name, self$xptr)
    },
    # create_log_record = function() {
    #   log_record_new()
    # },
    # emit_log_record = function(log_record) {
    #   ccall(otel_emit_log_record, self$xptr, log_record)
    #   invisible(self)
    # },
    trace = function(msg = "", ...) {
      self$log(msg = msg, severity = "trace", ...)
    },
    debug = function(msg = "", ...) {
      self$log(msg = msg, severity = "debug", ...)
    },
    info = function(msg = "", ...) {
      self$log(msg = msg, severity = "info", ...)
    },
    warn = function(msg = "", ...) {
      self$log(msg = msg, severity = "warn", ...)
    },
    error = function(msg = "", ...) {
      self$log(msg = msg, severity = "error", ...)
    },
    fatal = function(msg = "", ...) {
      self$log(msg = msg, severity = "fatal", ...)
    },
    is_enabled = function(severity = "info", event_id = NULL) {
        severity <- as_log_severity(severity)
        event_id <- as_event_id(event_id)
        ccall(otel_logger_is_enabled, self$xptr, severity, event_id)
    },
    get_minimum_severity = function() {
        ms <- ccall(otel_get_minimum_log_severity, self$xptr)
        otel::log_severity_levels[match(ms, otel::log_severity_levels)]
    },
    set_minimum_severity = function(minimum_severity) {
        minimum_severity <- as_log_severity(minimum_severity)
        ccall(otel_set_minimum_log_severity, self$xptr, minimum_severity)
      invisible(self)
    },
    log = function(
      msg = "",
      severity = "info",
      event_id = NULL,
      span_context = NULL,
      span_id = NULL,
      trace_id = NULL,
      trace_flags = NULL,
      timestamp = Sys.time(),
      observed_timestamp = NULL,
      attributes = NULL
    ) {
        msg <- as_string(msg, null = FALSE)
        severity <- as_log_severity(severity)
        event_id <- as_event_id(event_id)
        span_context <- as_span_context(span_context)
        span_id <- as_span_id(span_id)
        trace_id <- as_trace_id(trace_id)
        trace_flags <- as_trace_flags(trace_flags)
        timestamp <- as_timestamp(timestamp)
        observed_timestamp <- as_timestamp(observed_timestamp)
        attributes <- as.list(as_otel_attributes(attributes))

        if (!is_na(span_context)) {
          span_context <- span_context %||% otel::get_active_span_context()
          if (span_context$is_valid()) {
            span_id <- span_id %||% span_context$get_span_id()
            trace_id <- trace_id %||% span_context$get_trace_id()
            trace_flags <- trace_flags %||% span_context$get_trace_flags()
          }
        }

        ccall(
          otel_log,
          self$xptr,
          msg,
          severity,
          event_id,
          span_id,
          trace_id,
          trace_flags,
          timestamp,
          observed_timestamp,
          attributes
        )
      invisible(self)
    },
    flush = function() {
        self$provider$flush()
    },
    name = NULL
  )
  self$provider <- provider
  minimum_severity <- as_log_severity(
    minimum_severity %||% get_default_log_severity()
  )
  self$name <- as_string(name)
  self$version <- as_string(version)
  self$schema_url <- as_string(schema_url)
  self$attributes <- as_otel_attributes(attributes)
  self$xptr <- ccall(
    otel_get_logger,
    self$provider$xptr,
    self$name,
    minimum_severity,
    self$version,
    self$schema_url,
    self$attributes
  )
  self
}

meter_provider_file_new_dev <- function(opts = NULL) {
  opts <- as_meter_provider_file_options(opts)

  self <- new_object(
    c("otel_meter_provider_file", "otel_meter_provider"),
    get_meter = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        meter_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
        invisible(ccall(otel_meter_provider_flush, self$xptr, NULL))
    },
    shutdown = function() {
        ccall(otel_meter_provider_shutdown, self$xptr, NULL)
      invisible(self)
    }
  )

  self$xptr <- ccall(
    otel_create_meter_provider_file,
    opts[["export_interval"]],
    opts[["export_timeout"]],
    opts
  )
  self
}

meter_provider_http_new_dev <- function(opts = NULL) {
  opts <- as_meter_provider_http_options(opts)

  self <- new_object(
    c("otel_meter_provider_http", "otel_meter_provider"),
    get_meter = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        meter_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
        invisible(ccall(otel_meter_provider_flush, self$xptr, NULL))
    },
    shutdown = function() {
        ccall(otel_meter_provider_shutdown, self$xptr, NULL)
      invisible(self)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_http, opts, attributes)
  self
}

meter_provider_memory_new_dev <- function(opts = NULL) {
  opts <- as_meter_provider_memory_options(opts)
  self <- new_object(
    c("otel_meter_provider_memory", "otel_meter_provider"),
    get_meter = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        meter_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
        invisible(ccall(otel_meter_provider_flush, self$xptr, NULL))
    },
    shutdown = function() {
        ccall(otel_meter_provider_shutdown, self$xptr, NULL)
      invisible(self)
    },
    get_metrics = function() {
        ccall(otel_meter_provider_memory_get_metrics, self$xptr)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_memory, opts, attributes)
  self
}

meter_provider_stdstream_new_dev <- function(opts = NULL) {
  opts <- as_meter_provider_stdstream_options(opts)
  self <- new_object(
    c("otel_meter_provider_stdstream", "otel_meter_provider"),
    get_meter = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        meter_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
        ccall(otel_meter_provider_flush, self$xptr, NULL)
    },
    shutdown = function() {
        ccall(otel_meter_provider_shutdown, self$xptr, NULL)
      invisible(self)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_stdstream, opts, attributes)
  self
}

meter_new_dev <- function(
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
    return(otel::meter_provider_noop$new()$get_meter(name))
  }

  self <- new_object(
    "otel_meter",
    create_counter = function(
      name,
      description = NULL,
      unit = NULL
    ) {
        counter_new(self, name, description, unit)
    },
    create_up_down_counter = function(
      name,
      description = NULL,
      unit = NULL
    ) {
        up_down_counter_new(self, name, description, unit)
    },
    create_histogram = function(
      name,
      description = NULL,
      unit = NULL,
      boundaries = NULL
    ) {
        histogram_new(self, name, description, unit, boundaries)
    },
    create_gauge = function(
      name,
      description = NULL,
      unit = NULL
    ) {
        gauge_new(self, name, description, unit)
    },
    is_enabled = function() {
      TRUE
    }
  )
  self$provider <- provider
  self$name <- as_string(name)
  self$version <- as_string(version)
  self$schema_url <- as_string(schema_url)
  self$attributes <- as_otel_attributes(attributes)
  self$xptr <- ccall(
    otel_get_meter,
    self$provider$xptr,
    self$name,
    self$version,
    self$schema_url,
    self$attributes
  )
  self
}

counter_new_dev <- function(meter, name, description = NULL, unit = NULL) {
  self <- new_object(
    "otel_counter",
    add = function(
      value = 1L,
      attributes = NULL,
      span_context = NULL
    ) {
        # TODO: check args
        value <- as.double(value)
        ccall(otel_counter_add, self$xptr, value, attributes, span_context)
      invisible(self)
    }
  )
  self$xptr <- ccall(
    otel_create_counter,
    meter$xptr,
    name,
    description,
    unit
  )
  self
}

up_down_counter_new_dev <- function(
  meter,
  name,
  description = NULL,
  unit = NULL
) {
  self <- new_object(
    "otel_up_down_counter",
    add = function(
      value = 1L,
      attributes = NULL,
      span_context = NULL
    ) {
        # TODO: check args
        value <- as.double(value)
        ccall(
          otel_up_down_counter_add,
          self$xptr,
          value,
          attributes,
          span_context
        )
      invisible(self)
    }
  )
  self$xptr <- ccall(
    otel_create_up_down_counter,
    meter$xptr,
    name,
    description,
    unit
  )
  self
}

histogram_new_dev <- function(
  meter,
  name,
  description = NULL,
  unit = NULL,
  boundaries = NULL
) {
  boundaries <- as_histogram_boundaries(boundaries)
  self <- new_object(
    "otel_histogram",
    record = function(
      value,
      attributes = NULL,
      span_context = NULL
    ) {
        # TODO: check args
        value <- as.double(value)
        ccall(otel_histogram_record, self$xptr, value, attributes, span_context)
      invisible(self)
    }
  )
  self$xptr <- ccall(
    otel_create_histogram,
    meter$xptr,
    name,
    description,
    unit,
    boundaries
  )
  self
}

gauge_new_dev <- function(meter, name, description = NULL, unit = NULL) {
  self <- new_object(
    "otel_gauge",
    record = function(
      value,
      attributes = NULL,
      span_context = NULL
    ) {
        # TODO: check args
        value <- as.double(value)
        ccall(otel_gauge_record, self$xptr, value, attributes, span_context)
      invisible(self)
    }
  )
  self$xptr <- ccall(
    otel_create_gauge,
    meter$xptr,
    name,
    description,
    unit
  )
  self
}

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

    set_attributes = function(attributes = NULL) {
        attributes <- as_otel_attributes(attributes)
        ccall(otel_span_set_attributes, self$xptr, attributes)
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
              # no error, leave the status unset, see r-lib/otel#30
              status_code <- NULL
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
    }
  )

  self$tracer <- tracer
  self$xptr <- xptr
  # The name is kept in C, so all span objects that point to the same
  # span, e.g. the one from get_active_span(), see the same name.
  makeActiveBinding(
    "name",
    function(value) {
      if (!missing(value)) {
        stop("Use `update_name()` to change the name of a span.")
      }
      ccall(otel_span_get_name, self$xptr)
    },
    self
  )

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

tracer_provider_file_new_dev <- function(opts = NULL) {
  opts <- as_tracer_provider_file_options(opts)

  self <- new_object(
    c("otel_tracer_provider_file", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
        ccall(otel_tracer_provider_flush, self$xptr)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_file, opts, attributes)
  self
}

tracer_provider_http_new_dev <- function(opts = NULL) {
  opts <- as_tracer_provider_http_options(opts)
  self <- new_object(
    c("otel_tracer_provider_http", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
        ccall(otel_tracer_provider_flush, self$xptr)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_http, opts, attributes)
  self
}

tracer_provider_memory_new_dev <- function(opts = NULL) {
  opts <- as_tracer_provider_memory_options(opts)
  self <- new_object(
    c("otel_tracer_provider_memory", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
      # noop currently
    },
    get_spans = function() {
        spans <- ccall(otel_tracer_provider_memory_get_spans, self$xptr)
        names(spans) <- map_chr(spans, function(x) x[["name"]] %||% "")
        spans
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_memory, opts, attributes)
  self
}

tracer_provider_stdstream_new_dev <- function(opts = NULL) {
  opts <- as_tracer_provider_stdstream_options(opts)
  self <- new_object(
    c("otel_tracer_provider_stdstream", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
        tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
        ccall(otel_tracer_provider_flush, self$xptr)
    }
  )
  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_stdstream, opts, attributes)
  self
}

tracer_new_dev <- function(
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
    return(otel::tracer_provider_noop$new()$get_tracer(name))
  }

  self <- new_object(
    "otel_tracer",
    start_span = function(
      name = NULL,
      attributes = NULL,
      links = NULL,
      options = NULL
    ) {
        span_new(
          self,
          name = name,
          attributes = attributes,
          links = links,
          options = options,
          scope = NULL,
          activation_scope = NULL
        )
    },
    start_local_active_span = function(
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
    get_active_span = function() {
        xptr <- ccall(otel_get_active_span, self$xptr)
        span_base_new(self, xptr)
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

dev_function_names <- c(
  "logger_provider_file_new",
  "logger_provider_http_new",
  "logger_provider_stdstream_new",
  "logger_new",
  "meter_provider_file_new",
  "meter_provider_http_new",
  "meter_provider_memory_new",
  "meter_provider_stdstream_new",
  "meter_new",
  "counter_new",
  "up_down_counter_new",
  "histogram_new",
  "gauge_new",
  "span_base_new",
  "span_context_new",
  "tracer_provider_file_new",
  "tracer_provider_http_new",
  "tracer_provider_memory_new",
  "tracer_provider_stdstream_new",
  "tracer_new"
)
