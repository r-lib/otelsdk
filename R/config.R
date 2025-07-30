stdstream_output_envvar <-
  "OTEL_R_EXPORTER_STDSTREAM_OUTPUT"
tracer_provider_stdstream_output_envvar <-
  "OTEL_R_EXPORTER_STDSTREAM_TRACES_OUTPUT"
logger_provider_stdstream_output_envvar <-
  "OTEL_R_EXPORTER_STDSTREAM_LOGS_OUTPUT"
meter_provider_stdstream_output_envvar <-
  "OTEL_R_EXPORTER_STDSTREAM_METRICS_OUTPUT"

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
  "OTEL_EXPORTER_OTLP_FILE_FILE_SIZE"
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

metric_export_interval_envvar <- "OTEL_METRIC_EXPORT_INTERVAL"
metric_export_timeout_envvar <- "OTEL_METRIC_EXPORT_TIMEOUT"

otlp_json_bytes_mapping_default <- "hexid"
otlp_json_bytes_mapping_envvar <-
  "OTEL_R_EXPORTER_OTLP_JSON_BYTES_MAPPING"
otlp_traces_json_bytes_mapping_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_JSON_BYTES_MAPPING"
otlp_metrics_json_bytes_mapping_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_JSON_BYTES_MAPPING"
otlp_logs_json_bytes_mapping_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_JSON_BYTES_MAPPING"

otlp_use_json_name_default <- FALSE
otlp_use_json_name_envvar <-
  "OTEL_R_EXPORTER_OTLP_USE_JSON_NAME"
otlp_traces_use_json_name_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_USE_JSON_NAME"
otlp_metrics_use_json_name_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_USE_JSON_NAME"
otlp_logs_use_json_name_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_USE_JSON_NAME"

otlp_console_debug_default <- FALSE
otlp_console_debug_envvar <-
  "OTEL_R_EXPORTER_OTLP_CONSOLE_DEBUG"
otlp_traces_console_debug_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_CONSOLE_DEBUG"
otlp_metrics_console_debug_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_CONSOLE_DEBUG"
otlp_logs_console_debug_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_CONSOLE_DEBUG"

otlp_ssl_insecure_skip_verify_default <- FALSE
otlp_ssl_insecure_skip_verify_envvar <-
  "OTEL_R_EXPORTER_OTLP_SSL_INSECURE_SKIP_VERIFY"
otlp_traces_ssl_insecure_skip_verify_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_SSL_INSECURE_SKIP_VERIFY"
otlp_metrics_ssl_insecure_skip_verify_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_SSL_INSECURE_SKIP_VERIFY"
otlp_logs_ssl_insecure_skip_verify_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_SSL_INSECURE_SKIP_VERIFY"

otlp_ssl_min_tls_default <- ""
otlp_ssl_min_tls_envvar <- "OTEL_R_EXPORTER_OTLP_SSL_MIN_TLS"
otlp_traces_ssl_min_tls_envvar <- "OTEL_R_EXPORTER_OTLP_TRACES_SSL_MIN_TLS"
otlp_metrics_ssl_min_tls_envvar <- "OTEL_R_EXPORTER_OTLP_METRICS_SSL_MIN_TLS"
otlp_logs_ssl_min_tls_envvar <- "OTEL_R_EXPORTER_OTLP_LOGS_SSL_MIN_TLS"

otlp_ssl_max_tls_default <- ""
otlp_ssl_max_tls_envvar <- "OTEL_R_EXPORTER_OTLP_SSL_MAX_TLS"
otlp_traces_ssl_max_tls_envvar <- "OTEL_R_EXPORTER_OTLP_TRACES_SSL_MAX_TLS"
otlp_metrics_ssl_max_tls_envvar <- "OTEL_R_EXPORTER_OTLP_METRICS_SSL_MAX_TLS"
otlp_logs_ssl_max_tls_envvar <- "OTEL_R_EXPORTER_OTLP_LOGS_SSL_MAX_TLS"

otlp_ssl_cipher_default <- ""
otlp_ssl_cipher_envvar <- "OTEL_R_EXPORTER_OTLP_SSL_CIPHER"
otlp_traces_ssl_cipher_envvar <- "OTEL_R_EXPORTER_OTLP_TRACES_SSL_CIPHER"
otlp_metrics_ssl_cipher_envvar <- "OTEL_R_EXPORTER_OTLP_METRICS_SSL_CIPHER"
otlp_logs_ssl_cipher_envvar <- "OTEL_R_EXPORTER_OTLP_LOGS_SSL_CIPHER"

otlp_ssl_cipher_suite_default <- ""
otlp_ssl_cipher_suite_envvar <-
  "OTEL_R_EXPORTER_OTLP_SSL_CIPHER_SUITE"
otlp_traces_ssl_cipher_suite_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_SSL_CIPHER_SUITE"
otlp_metrics_ssl_cipher_suite_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_SSL_CIPHER_SUITE"
otlp_logs_ssl_cipher_suite_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_SSL_CIPHER_SUITE"

otlp_retry_policy_max_attempts_default <- 5L
otlp_retry_policy_max_attempts_envvar <-
  "OTEL_R_EXPORTER_OTLP_RETRY_POLICY_MAX_ATTEMPTS"
otlp_traces_retry_policy_max_attempts_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_MAX_ATTEMPTS"
otlp_metrics_retry_policy_max_attempts_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_MAX_ATTEMPTS"
otlp_logs_retry_policy_max_attempts_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_MAX_ATTEMPTS"

otlp_retry_policy_initial_backoff_default <- 1.0 * 1000
otlp_retry_policy_initial_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_RETRY_POLICY_INITIAL_BACKOFF"
otlp_traces_retry_policy_initial_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_INITIAL_BACKOFF"
otlp_metrics_retry_policy_initial_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_INITIAL_BACKOFF"
otlp_logs_retry_policy_initial_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_INITIAL_BACKOFF"

otlp_retry_policy_max_backoff_default <- 5.0 * 1000
otlp_retry_policy_max_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_RETRY_POLICY_MAX_BACKOFF"
otlp_traces_retry_policy_max_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_MAX_BACKOFF"
otlp_metrics_retry_policy_max_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_MAX_BACKOFF"
otlp_logs_retry_policy_max_backoff_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_MAX_BACKOFF"

otlp_retry_policy_backoff_multiplier_default <- 1.5
otlp_retry_policy_backoff_multiplier_envvar <-
  "OTEL_R_EXPORTER_OTLP_RETRY_POLICY_BACKOFF_MULTIPLIER"
otlp_traces_retry_policy_backoff_multiplier_envvar <-
  "OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_BACKOFF_MULTIPLIER"
otlp_metrics_retry_policy_backoff_multiplier_envvar <-
  "OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_BACKOFF_MULTIPLIER"
otlp_logs_retry_policy_backoff_multiplier_envvar <-
  "OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_BACKOFF_MULTIPLIER"

otlp_aggregation_temporality_envvar <-
  "OTEL_R_EXPORTER_OTLP_AGGREGATION_TEMPORALITY"
otlp_aggregation_temporality_default <- "cumulative"

memory_buffer_size_envvar <-
  "OTEL_R_EXPORTER_MEMORY_BUFFER_SIZE"
memory_traces_buffer_size_envvar <-
  "OTEL_R_EXPORTER_MEMORY_TRACES_BUFFER_SIZE"
memory_metrics_buffer_size_envvar <-
  "OTEL_R_EXPORTER_MEMORY_METRICS_BUFFER_SIZE"
memory_logs_buffer_size_envvar <-
  "OTEL_R_EXPORTER_MEMORY_LOGS_BUFFER_SIZE"
memory_buffer_size_default <- 100L
