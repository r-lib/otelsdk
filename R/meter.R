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
    return(otel::meter_provider_noop$get_logger(name))
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
      unit = NULL
    ) {
      histogram_new(self, name, description, unit)
    },
    create_gauge = function(
      name,
      description = NULL,
      unit = NULL
    ) {
      gauge_new(self, name, description, unit)
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

counter_new <- function(meter, name, description = NULL, unit = NULL) {
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
      # TODO: check args
      value <- as.double(value)
      ccall(
        otel_up_down_counter_add,
        self$xptr,
        value,
        attributes,
        span_context
      )
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

histogram_new <- function(meter, name, description = NULL, unit = NULL) {
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
    }
  )
  self$xptr <- ccall(
    otel_create_histogram,
    meter$xptr,
    name,
    description,
    unit
  )
  self
}

gauge_new <- function(meter, name, description = NULL, unit = NULL) {
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
