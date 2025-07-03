meter_provider_file_new <- function(opts = NULL) {
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
    flush = function(timeout = NULL) {
      invisible(ccall(otel_meter_provider_flush, self$xptr, timeout))
    },
    shutdown = function(timeout = NULL) {
      ccall(otel_meter_provider_shutdown, self$xptr, timeout)
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

#' Meter provider to collect metrics in JSONL files
#' @export

meter_provider_file <- list(
  new = meter_provider_file_new,
  options = function() {
    utils::modifyList(
      as_meter_provider_file_options(NULL),
      ccall(otel_meter_provider_file_options_defaults)
    )
  }
)
