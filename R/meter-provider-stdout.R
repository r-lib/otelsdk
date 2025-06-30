meter_provider_stdstream_new <- function(
  stream = NULL,
  export_interval = 1000L,
  export_timeout = 500L
) {
  stream <- as_string(stream) %||%
    Sys.getenv(meter_provider_stdstream_output, "stdout")
  if (stream != "stdout" && stream != "stderr") {
    stream <- as_output_file(stream, null = FALSE)
  }
  export_interval <- as_count(export_interval, positive = TRUE)
  export_timeout <- as_count(export_timeout, positive = TRUE)
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

  self$xptr <- ccall(
    otel_create_meter_provider_stdstream,
    stream,
    export_interval,
    export_timeout
  )
  self
}

#' Meter provider to write to the standard output or standard error or
#' to a file
#' @export

meter_provider_stdstream <- list(
  new = meter_provider_stdstream_new
)
