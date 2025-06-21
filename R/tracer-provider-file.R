file_exporter_file_envvar <-
  "OTEL_EXPORTER_OTLP_FILE"
file_exporter_traces_file_envvar <-
  "OTEL_EXPORTER_OTLP_TRACES_FILE"
file_exporter_metrics_file_envvar <-
  "OTEL_EXPORTER_OTLP_METRICS_FILE"
file_exporter_logs_file_envvar <-
  "OTEL_EXPORTER_OTLP_LOGS_FILE"

file_exporter_alias_envvar <-
  "OTEL_EXPORTER_OTLP_FILE_ALIAS"
file_exporter_traces_alias_envvar <-
  "OTEL_EXPORTER_OTLP_TRACES_FILE_ALIAS"
file_exporter_metrics_alias_envvar <-
  "OTEL_EXPORTER_OTLP_METRICS_FILE_ALIAS"
file_exporter_logs_alias_envvar <-
  "OTEL_EXPORTER_OTLP_LOGS_FILE_ALIAS"

file_exporter_flush_interval_envvar <-
  "OTEL_EXPORTER_OTLP_FILE_FLUSH_INTERVAL"
file_exporter_traces_flush_interval_envvar <-
  "OTEL_EXPORTER_OTLP_TRACES_FILE_FLUSH_INTERVAL"
file_exporter_metrics_flush_interval_envvar <-
  "OTEL_EXPORTER_OTLP_METRICS_FILE_FLUSH_INTERVAL"
file_exporter_logs_flush_interval_envvar <-
  "OTEL_EXPORTER_OTLP_LOGS_FILE_FLUSH_INTERVAL"

file_exporter_flush_count_envvar <-
  "OTEL_EXPORTER_OTLP_FILE_FLUSH_COUNT"
file_exporter_traces_flush_count_envvar <-
  "OTEL_EXPORTER_OTLP_TRACES_FILE_FLUSH_COUNT"
file_exporter_metrics_flush_count_envvar <-
  "OTEL_EXPORTER_OTLP_METRICS_FILE_FLUSH_COUNT"
file_exporter_logs_flush_count_envvar <-
  "OTEL_EXPORTER_OTLP_LOGS_FILE_FLUSH_COUNT"

file_exporter_file_size_envvar <-
  "OTEL_EXPORTER_OTLP_FILE_file_SIZE"
file_exporter_traces_file_size_envvar <-
  "OTEL_EXPORTER_OTLP_TRACES_FILE_FILE_SIZE"
file_exporter_metrics_file_size_envvar <-
  "OTEL_EXPORTER_OTLP_METRICS_FILE_FILE_SIZE"
file_exporter_logs_file_size_envvar <-
  "OTEL_EXPORTER_OTLP_LOGS_FILE_FILE_SIZE"

file_exporter_rotate_size_envvar <-
  "OTEL_EXPORTER_OTLP_FILE_ROTATE_SIZE"
file_exporter_traces_rotate_size_envvar <-
  "OTEL_EXPORTER_OTLP_TRACES_FILE_ROTATE_SIZE"
file_exporter_metrics_rotate_size_envvar <-
  "OTEL_EXPORTER_OTLP_METRICS_FILE_ROTATE_SIZE"
file_exporter_logs_rotate_size_envvar <-
  "OTEL_EXPORTER_OTLP_LOGS_FILE_ROTATE_SIZE"

tracer_provider_file_new <- function(
  file_pattern = NULL,
  alias_pattern = NULL,
  flush_interval = NULL,
  flush_count = NULL,
  file_size = NULL,
  rotate_size = NULL
) {
  file_pattern <- as_string(file_pattern) %||%
    get_env(file_exporter_traces_file_envvar) %||%
    get_env(file_exporter_file_envvar)
  alias_pattern <- as_string(alias_pattern) %||%
    get_env(file_exporter_traces_alias_envvar) %||%
    get_env(file_exporter_alias_envvar) %||%
    empty_atomic_as_null(sub("%N", "latest", file_pattern))
  flush_interval <- as_difftime_spec(flush_interval) %||%
    as_difftime_env(file_exporter_traces_flush_interval_envvar) %||%
    as_difftime_env(file_exporter_flush_interval_envvar)
  flush_count <- as_count(flush_count, null = TRUE) %||%
    as_count_env(file_exporter_traces_flush_count_envvar, positive = TRUE) %||%
    as_count_env(file_exporter_flush_count_envvar, positive = TRUE)
  file_size <- as_bytes(file_size) %||%
    as_bytes_env(file_exporter_traces_file_size_envvar) %||%
    as_bytes_env(file_exporter_file_size_envvar)
  rotate_size <- as_bytes(rotate_size) %||%
    as_count_env(file_exporter_traces_rotate_size_envvar) %||%
    as_count_env(file_exporter_rotate_size_envvar)

  self <- new_object(
    c("otel_tracer_provider_file", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
      ccall(otel_tracer_provider_flush, self$xptr)
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
  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_file, options, attributes)
  self
}

#' Tracer provider to write traces into a JSONL file
#' @export

tracer_provider_file <- list(
  new = tracer_provider_file_new
)
