logger_provider_file_new <- function(
  file_pattern = NULL,
  alias_pattern = NULL,
  flush_interval = NULL,
  flush_count = NULL,
  file_size = NULL,
  rotate_size = NULL
) {
  file_pattern <- as_string(file_pattern) %||%
    get_env(file_exporter_logs_file_envvar) %||%
    get_env(file_exporter_file_envvar)
  alias_pattern <- as_string(alias_pattern) %||%
    get_env(file_exporter_logs_alias_envvar) %||%
    get_env(file_exporter_alias_envvar) %||%
    empty_atomic_as_null(sub("%N", "latest", file_pattern))
  flush_interval <- as_difftime_spec(flush_interval) %||%
    as_difftime_env(file_exporter_logs_flush_interval_envvar) %||%
    as_difftime_env(file_exporter_flush_interval_envvar)
  flush_count <- as_count(flush_count, null = TRUE) %||%
    as_count_env(file_exporter_logs_flush_count_envvar, positive = TRUE) %||%
    as_count_env(file_exporter_flush_count_envvar, positive = TRUE)
  file_size <- as_bytes(file_size) %||%
    as_bytes_env(file_exporter_logs_file_size_envvar) %||%
    as_bytes_env(file_exporter_file_size_envvar)
  rotate_size <- as_bytes(rotate_size) %||%
    as_count_env(file_exporter_logs_rotate_size_envvar) %||%
    as_count_env(file_exporter_rotate_size_envvar)

  self <- new_object(
    c("otel_logger_provider_file", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      logger_new(
        self,
        name,
        minimum_severity,
        version,
        schema_url,
        attributes,
        ...
      )
    },
    flush = function() {
      ccall(otel_logger_provider_flush, self$xptr)
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

  self$xptr <- ccall(otel_create_logger_provider_file, options)
  self
}

#' Logger provider to write log messages into a JSONL file.
#' @export

logger_provider_file <- list(
  new = logger_provider_file_new
)
