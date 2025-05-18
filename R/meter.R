meter_new <- function(provider, name = NULL, ...) {
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
  name <- name %||% get_env("OTEL_SERVICE_NAME") %||% "R"
  self$provider <- provider
  self$name <- name
  self$xptr <- .Call(otel_get_meter, self$provider$xptr, self$name)
  self
}

counter_new <- function(meter, name, description = NULL, unit = NULL) {
  self <- new_object(
    "otel_counter",
    add = function(value = 1L, attributes = NULL, context = NULL) {
      # TODO: check args
      value <- as.double(value)
      .Call(otel_counter_add, self$xptr, value, attributes, context)
    }
  )
  self$xptr <- .Call(
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
    add = function(value = 1L, attributes = NULL, context = NULL) {
      # TODO: check args
      value <- as.double(value)
      .Call(otel_up_down_counter_add, self$xptr, value, attributes, context)
    }
  )
  self$xptr <- .Call(
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
    record = function(value, attributes = NULL, context = NULL) {
      # TODO: check args
      value <- as.double(value)
      .Call(otel_histogram_record, self$xptr, value, attributes, context)
    }
  )
  self$xptr <- .Call(
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
    record = function(value, attributes = NULL, context = NULL) {
      # TODO: check args
      value <- as.double(value)
      .Call(otel_gauge_record, self$xptr, value, attributes, context)
    }
  )
  self$xptr <- .Call(
    otel_create_gauge,
    meter$xptr,
    name,
    description,
    unit
  )
  self
}
