# fmt: skip file

# safe start
meter_new <- function(
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
      tryCatch({                                                     # safe
        counter_new(self, name, description, unit)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        noop_meter()$create_counter(NULL)                            # safe
      })                                                             # safe
    },
    create_up_down_counter = function(
      name,
      description = NULL,
      unit = NULL
    ) {
      tryCatch({                                                     # safe
        up_down_counter_new(self, name, description, unit)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        noop_meter()$create_up_down_counter(NULL)                    # safe
      })                                                             # safe
    },
    create_histogram = function(
      name,
      description = NULL,
      unit = NULL,
      boundaries = NULL
    ) {
      tryCatch({                                                     # safe
        histogram_new(self, name, description, unit, boundaries)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        noop_meter()$create_histogram(NULL)                          # safe
      })                                                             # safe
    },
    create_gauge = function(
      name,
      description = NULL,
      unit = NULL
    ) {
      tryCatch({                                                     # safe
        gauge_new(self, name, description, unit)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        noop_meter()$create_gauge(NULL)                              # safe
      })                                                             # safe
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
# safe end

# safe start
counter_new <- function(meter, name, description = NULL, unit = NULL) {
  self <- new_object(
    "otel_counter",
    add = function(
      value = 1L,
      attributes = NULL,
      span_context = NULL
    ) {
      tryCatch({                                                     # safe
        # TODO: check args
        value <- as.double(value)
        ccall(otel_counter_add, self$xptr, value, attributes, span_context)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
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
# safe end

# safe start
up_down_counter_new <- function(
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
      tryCatch({                                                     # safe
        # TODO: check args
        value <- as.double(value)
        ccall(
          otel_up_down_counter_add,
          self$xptr,
          value,
          attributes,
          span_context
        )
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
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
# safe end

# safe start
histogram_new <- function(
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
      tryCatch({                                                     # safe
        # TODO: check args
        value <- as.double(value)
        ccall(otel_histogram_record, self$xptr, value, attributes, span_context)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
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
# safe end

# safe start
gauge_new <- function(meter, name, description = NULL, unit = NULL) {
  self <- new_object(
    "otel_gauge",
    record = function(
      value,
      attributes = NULL,
      span_context = NULL
    ) {
      tryCatch({                                                     # safe
        # TODO: check args
        value <- as.double(value)
        ccall(otel_gauge_record, self$xptr, value, attributes, span_context)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
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
# safe end
