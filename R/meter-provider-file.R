meter_provider_file_new <- function(
  export_interval = 1000L,
  export_timeout = 500L,
  file_pattern = NULL,
  alias_pattern = NULL,
  flush_interval = NULL,
  flush_count = NULL,
  file_size = NULL,
  rotate_size = NULL
) {
  export_interval <- as_count(export_interval, positive = TRUE)
  export_timeout <- as_count(export_timeout, positive = TRUE)
  file_pattern <- as_string(file_pattern) %||%
    get_env(file_exporter_metrics_file_envvar) %||%
    get_env(file_exporter_file_envvar)
  alias_pattern <- as_string(alias_pattern) %||%
    get_env(file_exporter_metrics_alias_envvar) %||%
    get_env(file_exporter_alias_envvar) %||%
    empty_atomic_as_null(sub("%N", "latest", file_pattern))
  flush_interval <- as_difftime_spec(flush_interval) %||%
    as_difftime_env(file_exporter_metrics_flush_interval_envvar) %||%
    as_difftime_env(file_exporter_flush_interval_envvar)
  flush_count <- as_count(flush_count, null = TRUE) %||%
    as_count_env(file_exporter_metrics_flush_count_envvar, positive = TRUE) %||%
    as_count_env(file_exporter_flush_count_envvar, positive = TRUE)
  file_size <- as_bytes(file_size) %||%
    as_bytes_env(file_exporter_metrics_file_size_envvar) %||%
    as_bytes_env(file_exporter_file_size_envvar)
  rotate_size <- as_bytes(rotate_size) %||%
    as_count_env(file_exporter_metrics_rotate_size_envvar) %||%
    as_count_env(file_exporter_rotate_size_envvar)

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
      # noop
    },
    shutdown = function(timeout = NULL) {
      ccall(otel_meter_provider_shutdown, self$xptr, timeout)
      invisible(self)
    }
  )

  options <- list(
    file_pattern = file_pattern,
    alias_pattern = alias_pattern,
    flush_interval = flush_interval,
    flush_count = flush_count,
    file_size = file_size,
    rotate_size = rotate_size
  )

  self$xptr <- ccall(
    otel_create_meter_provider_file,
    export_interval,
    export_timeout,
    options
  )
  self
}

#' Meter provider to collect metrics in JSONL files
#' @export

meter_provider_file <- list(
  new = meter_provider_file_new
)
