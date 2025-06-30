meter_provider_http_new <- function(
  export_interval = 1000L,
  export_timeout = 500L
) {
  export_interval <- as_count(export_interval, positive = TRUE)
  export_timeout <- as_count(export_timeout, positive = TRUE)

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
    flush = function(timeout = NULL) {
      invisible(ccall(otel_meter_provider_flush, self$xptr, timeout))
    },
    shutdown = function(timeout = NULL) {
      ccall(otel_meter_provider_shutdown, self$xptr, timeout)
      invisible(self)
    }
  )

  self$xptr <- ccall(
    otel_create_meter_provider_http,
    export_interval,
    export_timeout
  )
  self
}

#' Meter provider to send collected metrics over HTTP
#' @export

meter_provider_http <- list(
  new = meter_provider_http_new
)
