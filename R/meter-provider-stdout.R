meter_provider_stdstream_new <- function(opts = NULL) {
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
    flush = function(timeout = NULL) {
      # TODO: check arg
      ccall(otel_meter_provider_flush, self$xptr, timeout)
    },
    shutdown = function(timeout = NULL) {
      ccall(otel_meter_provider_shutdown, self$xptr, timeout)
      invisible(self)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_meter_provider_stdstream, opts, attributes)
  self
}

meter_provider_stdstream_options <- function() {
  as_meter_provider_stdstream_options(NULL)
}

#' Meter provider to write to the standard output or standard error or
#' to a file
#' @export

meter_provider_stdstream <- list(
  new = meter_provider_stdstream_new,
  options = meter_provider_stdstream_options
)
