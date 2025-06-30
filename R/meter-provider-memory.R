meter_provider_memory_new <- function(
  export_interval = 1000L,
  export_timeout = 500L,
  buffer_size = 100,
  temporality = c("unspecified", "delta", "cumulative")[1]
) {
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
    flush = function(timeout = NULL) {
      invisible(ccall(otel_meter_provider_flush, self$xptr, timeout))
    },
    shutdown = function(timeout = NULL) {
      ccall(otel_meter_provider_shutdown, self$xptr, timeout)
      invisible(self)
    },
    get_metrics = function() {
      ccall(otel_meter_provider_memory_get_metrics, self$xptr)
    }
  )

  export_interval <- as_count(export_interval, positive = TRUE)
  export_timeout <- as_count(export_timeout, positive = TRUE)
  buffer_size <- as_count(buffer_size, positive = TRUE)
  temporality <- as_choice(temporality, temporality_types, null = FALSE)
  self$xptr <- ccall(
    otel_create_meter_provider_memory,
    export_interval,
    export_timeout,
    buffer_size,
    temporality
  )
  self
}

meter_provider_memory <- list(
  new = meter_provider_memory_new
)

temporality_types <- c(default = "unspecified", "delta", "cumulative")
