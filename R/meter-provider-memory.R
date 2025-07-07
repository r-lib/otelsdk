meter_provider_memory_new <- function(opts = NULL) {
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

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_memory, opts, attributes)
  self
}

meter_provider_memory_options <- function() {
  as_meter_provider_memory_options(NULL)
}

#' In-memory meter provider for debugging
#' @export

meter_provider_memory <- list(
  new = meter_provider_memory_new,
  options = meter_provider_memory_options
)
