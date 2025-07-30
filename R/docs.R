#' @name Collecting Telemetry Data
#' @title Collecting Telemetry Data
#' @rdname collecting
#' @aliases collecting
#' @description
#' This page is about collecting telemetry data from instrumented R
#' packages. If you need help with instrumenting your R package, see
#' \link[otel:Getting Started]{Getting Started} in the otel package.
#'
#' @details
#' ```{r child = "tools/dox/collecting.Rmd"}
#' ```
#'
#' @return Not applicable.
#' @examples
#' # See above
NULL

doc_evs <- function() {
  c(
    "OTEL_SDK_DISABLED",
    "OTEL_RESOURCE_ATTRIBUTES",
    "OTEL_SERVICE_NAME",
    "OTEL_LOG_LEVEL",

    "OTEL_EXPORTER_OTLP_PROTOCOL",
    "OTEL_EXPORTER_OTLP_TRACES_PROTOCOL",
    "OTEL_EXPORTER_OTLP_METRICS_PROTOCOL",
    "OTEL_EXPORTER_OTLP_LOGS_PROTOCOL",

    "OTEL_EXPORTER_OTLP_PROTOCOL",
    "OTEL_EXPORTER_OTLP_TRACES_PROTOCOL",
    "OTEL_EXPORTER_OTLP_METRICS_PROTOCOL",
    "OTEL_EXPORTER_OTLP_LOGS_PROTOCOL",

    otlp_use_json_name_envvar,
    otlp_traces_use_json_name_envvar,
    otlp_metrics_use_json_name_envvar,
    otlp_logs_use_json_name_envvar,

    otlp_console_debug_envvar,
    otlp_traces_console_debug_envvar,
    otlp_metrics_console_debug_envvar,
    otlp_logs_console_debug_envvar,

    "OTEL_EXPORTER_OTLP_TIMEOUT",
    "OTEL_EXPORTER_OTLP_TRACES_TIMEOUT",
    "OTEL_EXPORTER_OTLP_METRICS_TIMEOUT",
    "OTEL_EXPORTER_OTLP_LOGS_TIMEOUT",

    "OTEL_EXPORTER_OTLP_HEADERS",
    "OTEL_EXPORTER_OTLP_TRACES_HEADERS",
    "OTEL_EXPORTER_OTLP_METRICS_HEADERS",
    "OTEL_EXPORTER_OTLP_LOGS_HEADERS",

    otlp_ssl_insecure_skip_verify_envvar,
    otlp_traces_ssl_insecure_skip_verify_envvar,
    otlp_metrics_ssl_insecure_skip_verify_envvar,
    otlp_logs_ssl_insecure_skip_verify_envvar,

    "OTEL_EXPORTER_OTLP_CERTIFICATE",
    "OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE",
    "OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE",
    "OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE",

    "OTEL_EXPORTER_OTLP_CERTIFICATE_STRING",
    "OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE_STRING",
    "OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE_STRING",
    "OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE_STRING",

    "OTEL_EXPORTER_OTLP_CLIENT_KEY",
    "OTEL_EXPORTER_OTLP_TRACES_CLIENT_KEY",
    "OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY",
    "OTEL_EXPORTER_OTLP_LOGS_CLIENT_KEY",

    "OTEL_EXPORTER_OTLP_CLIENT_KEY_STRING",
    "OTEL_EXPORTER_OTLP_TRACES_CLIENT_KEY_STRING",
    "OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY_STRING",
    "OTEL_EXPORTER_OTLP_LOGS_CLIENT_KEY_STRING",

    "OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE",
    "OTEL_EXPORTER_OTLP_TRACES_CLIENT_CERTIFICATE",
    "OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE",
    "OTEL_EXPORTER_OTLP_LOGS_CLIENT_CERTIFICATE",

    "OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE_STRING",
    "OTEL_EXPORTER_OTLP_TRACES_CLIENT_CERTIFICATE_STRING",
    "OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE_STRING",
    "OTEL_EXPORTER_OTLP_LOGS_CLIENT_CERTIFICATE_STRING",

    otlp_ssl_min_tls_envvar,
    otlp_traces_ssl_min_tls_envvar,
    otlp_metrics_ssl_min_tls_envvar,
    otlp_logs_ssl_min_tls_envvar,

    otlp_ssl_max_tls_envvar,
    otlp_traces_ssl_max_tls_envvar,
    otlp_metrics_ssl_max_tls_envvar,
    otlp_logs_ssl_max_tls_envvar,

    otlp_ssl_cipher_envvar,
    otlp_traces_ssl_cipher_envvar,
    otlp_metrics_ssl_cipher_envvar,
    otlp_logs_ssl_cipher_envvar,

    otlp_ssl_cipher_suite_envvar,
    otlp_traces_ssl_cipher_suite_envvar,
    otlp_metrics_ssl_cipher_suite_envvar,
    otlp_logs_ssl_cipher_suite_envvar,

    "OTEL_EXPORTER_OTLP_COMPRESSION",
    "OTEL_EXPORTER_OTLP_TRACES_COMPRESSION",
    "OTEL_EXPORTER_OTLP_METRICS_COMPRESSION",
    "OTEL_EXPORTER_OTLP_LOGS_COMPRESSION",

    otlp_retry_policy_max_attempts_envvar,
    otlp_traces_retry_policy_max_attempts_envvar,
    otlp_metrics_retry_policy_max_attempts_envvar,
    otlp_logs_retry_policy_max_attempts_envvar,

    otlp_retry_policy_initial_backoff_envvar,
    otlp_traces_retry_policy_initial_backoff_envvar,
    otlp_metrics_retry_policy_initial_backoff_envvar,
    otlp_logs_retry_policy_initial_backoff_envvar,

    otlp_retry_policy_max_backoff_envvar,
    otlp_traces_retry_policy_max_backoff_envvar,
    otlp_metrics_retry_policy_max_backoff_envvar,
    otlp_logs_retry_policy_max_backoff_envvar,

    otlp_retry_policy_backoff_multiplier_envvar,
    otlp_traces_retry_policy_backoff_multiplier_envvar,
    otlp_metrics_retry_policy_backoff_multiplier_envvar,
    otlp_logs_retry_policy_backoff_multiplier_envvar,

    file_exporter_file_envvar,
    file_exporter_traces_file_envvar,
    file_exporter_metrics_file_envvar,
    file_exporter_logs_file_envvar,

    file_exporter_alias_envvar,
    file_exporter_traces_alias_envvar,
    file_exporter_metrics_alias_envvar,
    file_exporter_logs_alias_envvar,

    file_exporter_flush_interval_envvar,
    file_exporter_traces_flush_interval_envvar,
    file_exporter_metrics_flush_interval_envvar,
    file_exporter_logs_flush_interval_envvar,

    file_exporter_flush_count_envvar,
    file_exporter_traces_file_size_envvar,
    file_exporter_metrics_file_size_envvar,
    file_exporter_logs_file_size_envvar,

    file_exporter_file_size_envvar,
    file_exporter_traces_file_size_envvar,
    file_exporter_metrics_file_size_envvar,
    file_exporter_logs_file_size_envvar,

    file_exporter_rotate_size_envvar,
    file_exporter_traces_rotate_size_envvar,
    file_exporter_metrics_rotate_size_envvar,
    file_exporter_logs_rotate_size_envvar,

    "OTEL_BSP_SCHEDULE_DELAY",
    "OTEL_BSP_MAX_QUEUE_SIZE",
    "OTEL_BSP_MAX_EXPORT_BATCH_SIZE",

    metric_export_interval_envvar,
    metric_export_timeout_envvar,

    otlp_aggregation_temporality_envvar,

    stdstream_output_envvar,
    tracer_provider_stdstream_output_envvar,
    meter_provider_stdstream_output_envvar,
    logger_provider_stdstream_output_envvar,

    memory_buffer_size_envvar,
    memory_traces_buffer_size_envvar,
    memory_metrics_buffer_size_envvar,
    memory_buffer_size_envvar
  )
}

#' Environment variables to configure otelsdk
#' @name Environment Variables
#' @rdname environmentvariables
#' @eval paste("@aliases", "OTEL_ENV", otel:::doc_evs(), otelsdk:::doc_evs())
#'
#' @description
#' See also the [Environment Variables][otel::Environment Variables] in
#' the otel package, which is charge of selecting the exporters to use.
#'
#' # The OpenTelemetry Specification
#'
#' Most of these environment variables are based on the [OpenTelemetry
#' Specification](
#'   https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
#' ), version 1.47.0.
#'
#' The environment variables with an '`OTEL_R_`' prefix are not (yet) in the
#' standard, and are specific for the otel and otelsdk R packages.
#'
#' # General SDK Configuration
#'
#' * `OTEL_SDK_DISABLED`
#'
#'   Set to a 'true' value to disable the SDK for all signals.
#'
#' * `OTEL_RESOURCE_ATTRIBUTES`
#'
#'   Key-value pairs to be used as resource attributes. See the
#'   [Resource SDK](
#'     https://opentelemetry.io/docs/specs/otel/resource/sdk/#specifying-resource-information-via-an-environment-variable)
#'   for more details.
#'
#' * `OTEL_SERVICE_NAME`
#'
#'   Sets the value of the [`service.name`](
#'     https://opentelemetry.io/docs/specs/semconv/resource/#service)
#'   resource attribute.
#'
#' * `OTEL_LOG_LEVEL`
#'
#'   Log level used by the [SDK internal logger](
#'     https://opentelemetry.io/docs/specs/otel/error-handling/#self-diagnostics).
#'   In R it is also used for the default log level of the OpenTelemetry
#'   loggers.
#'
#' ```{r child = system.file(package = "otel", "dox/ev-exporters.Rmd")}
#' ```
#'
#' ```{r child = system.file(package = "otel", "dox/ev-suppress.Rmd")}
#' ```
#'
#' ```{r child = system.file(package = "otel", "dox/ev-zci.Rmd")}
#' ```
#'
#' ```{r child = system.file(package = "otel", "dox/ev-others.Rmd")}
#' ```
#'
#' # OTLP/HTTP Exporters
#'
#' These environment variables are used by [tracer_provider_http],
#' [meter_provider_http] and [logger_provider_http].
#'
#' For every set of environment variables, the signal specific ones have
#' priority over the generic one.
#'
#' * `OTEL_EXPORTER_OTLP_ENDPOINT` |
#'   `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` |
#'   `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` |
#'   `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`
#'
#'   OTLP URL to send telemetry data to. When the generic environment
#'   variable is used, the exporter appends the signal specific endpoint
#'   to it. The signal specific environment variables are used as is.
#'   More in the [OpenTelemetry specification](
#'     https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls-for-otlphttp).
#'
#' * `OTEL_EXPORTER_OTLP_PROTOCOL` |
#'   `OTEL_EXPORTER_OTLP_TRACES_PROTOCOL` |
#'   `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL` |
#'   `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL`
#'
#'   The transport protocol. Possible values:
#'   `r paste0('\u0060', names(otlp_content_type_values), '\u0060', collapse = ', ')`.
#'
#' * ``r otlp_json_bytes_mapping_envvar`` |
#'   ``r otlp_traces_json_bytes_mapping_envvar`` |
#'   ``r otlp_metrics_json_bytes_mapping_envvar`` |
#'   ``r otlp_logs_json_bytes_mapping_envvar``
#'
#'   Encoding used for trace ids and spans id. Possible values:
#'   `r paste0('\u0060', otlp_json_byte_mapping_choices, '\u0060', collapse = ', ')`.
#'
#' * ``r otlp_use_json_name_envvar`` |
#'   ``r otlp_traces_use_json_name_envvar`` |
#'   ``r otlp_metrics_use_json_name_envvar`` |
#'   ``r otlp_logs_use_json_name_envvar``
#'
#'   Whether to use json name of protobuf field to set the key of json.
#'   A boolean value (flag, `true` or `false`).
#'
#' * ``r otlp_console_debug_envvar`` |
#'   ``r otlp_traces_console_debug_envvar`` |
#'   ``r otlp_metrics_console_debug_envvar`` |
#'   ``r otlp_logs_console_debug_envvar``
#'
#'   Whether to print debug messages to the console. A boolean value (flag,
#'   `true` or `false`).
#'
#' * `OTEL_EXPORTER_OTLP_TIMEOUT` |
#'   `OTEL_EXPORTER_OTLP_TRACES_TIMEOUT` |
#'   `OTEL_EXPORTER_OTLP_METRICS_TIMEOUT` |
#'   `OTEL_EXPORTER_OTLP_LOGS_TIMEOUT`
#'
#'   HTTP timeout in milliseconds.
#'
#' * `OTEL_EXPORTER_OTLP_HEADERS` |
#'   `OTEL_EXPORTER_OTLP_TRACES_HEADERS` |
#'   `OTEL_EXPORTER_OTLP_METRICS_HEADERS` |
#'   `OTEL_EXPORTER_OTLP_LOGS_HEADERS`
#'
#'   Additional HTTP headers to send. E.g. `Authorization` is commonly
#'   used. It must be a comma separated list of headers, each in the
#'   `header=value` form.
#'
#' * ``r otlp_ssl_insecure_skip_verify_envvar`` |
#'   ``r otlp_traces_ssl_insecure_skip_verify_envvar`` |
#'   ``r otlp_metrics_ssl_insecure_skip_verify_envvar`` |
#'   ``r otlp_logs_ssl_insecure_skip_verify_envvar``
#'
#'   Whether to disable SSL. A boolean value (flag, `true` or `false`).
#'
#' * `OTEL_EXPORTER_OTLP_CERTIFICATE` |
#'   `OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE` |
#'   `OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE` |
#'   `OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE`
#'
#'   CA certificate, path to a file.
#'
#' * `OTEL_EXPORTER_OTLP_CERTIFICATE_STRING` |
#'   `OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE_STRING` |
#'   `OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE_STRING` |
#'   `OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE_STRING`
#'
#'   CA certificate, as a string.
#'
#' * `OTEL_EXPORTER_OTLP_CLIENT_KEY` |
#'   `OTEL_EXPORTER_OTLP_TRACES_CLIENT_KEY` |
#'   `OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY` |
#'   `OTEL_EXPORTER_OTLP_LOGS_CLIENT_KEY`
#'
#'   SSL client key, path to a file.
#'
#' * `OTEL_EXPORTER_OTLP_CLIENT_KEY_STRING` |
#'   `OTEL_EXPORTER_OTLP_TRACES_CLIENT_KEY_STRING` |
#'   `OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY_STRING` |
#'   `OTEL_EXPORTER_OTLP_LOGS_CLIENT_KEY_STRING`
#'
#'   SSL client key as a string.
#'
#' * `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE` |
#'   `OTEL_EXPORTER_OTLP_TRACES_CLIENT_CERTIFICATE` |
#'   `OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE` |
#'   `OTEL_EXPORTER_OTLP_LOGS_CLIENT_CERTIFICATE`
#'
#'   SSL client certificate, path to a file.
#'
#' * `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE_STRING` |
#'   `OTEL_EXPORTER_OTLP_TRACES_CLIENT_CERTIFICATE_STRING` |
#'   `OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE_STRING` |
#'   `OTEL_EXPORTER_OTLP_LOGS_CLIENT_CERTIFICATE_STRING`
#'
#'   SSL client certificate, as a string.
#'
#' * ``r otlp_ssl_min_tls_envvar`` |
#'   ``r otlp_traces_ssl_min_tls_envvar`` |
#'   ``r otlp_metrics_ssl_min_tls_envvar`` |
#'   ``r otlp_logs_ssl_min_tls_envvar``
#'
#'   Minimum TLS version.
#'
#' * ``r otlp_ssl_max_tls_envvar`` |
#'   ``r otlp_traces_ssl_max_tls_envvar`` |
#'   ``r otlp_metrics_ssl_max_tls_envvar`` |
#'   ``r otlp_logs_ssl_max_tls_envvar``
#'
#'   Maximum TLS version.
#'
#' * ``r otlp_ssl_cipher_envvar`` |
#'   ``r otlp_traces_ssl_cipher_envvar`` |
#'   ``r otlp_metrics_ssl_cipher_envvar`` |
#'   ``r otlp_logs_ssl_cipher_envvar``
#'
#'   TLS cipher.
#'
#' * ``r otlp_ssl_cipher_suite_envvar`` |
#'   ``r otlp_traces_ssl_cipher_suite_envvar`` |
#'   ``r otlp_metrics_ssl_cipher_suite_envvar`` |
#'   ``r otlp_logs_ssl_cipher_suite_envvar``
#'
#'   TLS cipher suite.
#'
#' * `OTEL_EXPORTER_OTLP_COMPRESSION` |
#'   `OTEL_EXPORTER_OTLP_TRACES_COMPRESSION` |
#'   `OTEL_EXPORTER_OTLP_METRICS_COMPRESSION` |
#'   `OTEL_EXPORTER_OTLP_LOGS_COMPRESSION`
#'
#'   Compression to use.
#'   `r paste0('\u0060', otlp_compression_choices, '\u0060', collapse = ', ')`.
#'
#' * ``r otlp_retry_policy_max_attempts_envvar`` |
#'   ``r otlp_traces_retry_policy_max_attempts_envvar`` |
#'   ``r otlp_metrics_retry_policy_max_attempts_envvar`` |
#'   ``r otlp_logs_retry_policy_max_attempts_envvar``
#'
#'   The maximum number of call attempts, including the original attempt.
#'
#' * ``r otlp_retry_policy_initial_backoff_envvar`` |
#'   ``r otlp_traces_retry_policy_initial_backoff_envvar`` |
#'   ``r otlp_metrics_retry_policy_initial_backoff_envvar`` |
#'   ``r otlp_logs_retry_policy_initial_backoff_envvar``
#'
#'   The maximum initial back-off delay between retry attempts.
#'   The actual backoff delay is uniform random between zero and this.
#'   It is in milliseconds.
#'
#' * ``r otlp_retry_policy_max_backoff_envvar`` |
#'   ``r otlp_traces_retry_policy_max_backoff_envvar`` |
#'   ``r otlp_metrics_retry_policy_max_backoff_envvar`` |
#'   ``r otlp_logs_retry_policy_max_backoff_envvar``
#'
#'   The maximum backoff places an upper limit on exponential backoff
#'   growth.
#'
#' * ``r otlp_retry_policy_backoff_multiplier_envvar`` |
#'   ``r otlp_traces_retry_policy_backoff_multiplier_envvar`` |
#'   ``r otlp_metrics_retry_policy_backoff_multiplier_envvar`` |
#'   ``r otlp_logs_retry_policy_backoff_multiplier_envvar``
#'
#'   The backoff will be multiplied by this value after each retry attempt.
#'
#' # OTLP/FILE Exporters
#'
#' These environment variables are used by [tracer_provider_file],
#' [meter_provider_file] and [logger_provider_file].
#'
#' For every set of environment variables, the signal specific ones have
#' priority over the generic one.
#'
#' * ``r file_exporter_file_envvar`` |
#'   ``r file_exporter_traces_file_envvar`` |
#'   ``r file_exporter_metrics_file_envvar`` |
#'   ``r file_exporter_logs_file_envvar``
#'
#'   Output file pattern. May contain placeholders, see the manual pages
#'   of the providers, linked at the beginning of the section.
#'
#' * ``r file_exporter_alias_envvar`` |
#'   ``r file_exporter_traces_alias_envvar`` |
#'   ``r file_exporter_metrics_alias_envvar`` |
#'   ``r file_exporter_logs_alias_envvar``
#'
#'   The file which always point to the latest file.
#'   May contain placeholders, see the manual pages
#'   of the providers, linked at the beginning of the section.
#'
#' * ``r file_exporter_flush_interval_envvar`` |
#'   ``r file_exporter_traces_flush_interval_envvar`` |
#'   ``r file_exporter_metrics_flush_interval_envvar`` |
#'   ``r file_exporter_logs_flush_interval_envvar``
#'
#'   Interval to force flush output. A time interval specification, see
#'   \link{Time Interval Options}.
#'
#' * ``r file_exporter_flush_count_envvar`` |
#'   ``r file_exporter_traces_file_size_envvar`` |
#'   ``r file_exporter_metrics_file_size_envvar`` |
#'   ``r file_exporter_logs_file_size_envvar``
#'
#'   Force flush output after every `flush_count` records.
#'
#' * ``r file_exporter_file_size_envvar`` |
#'   ``r file_exporter_traces_file_size_envvar`` |
#'   ``r file_exporter_metrics_file_size_envvar`` |
#'   ``r file_exporter_logs_file_size_envvar``
#'
#'   File size to rotate output files. A file size specification, see
#'   \link{File Size Options}.
#'
#' * ``r file_exporter_rotate_size_envvar`` |
#'   ``r file_exporter_traces_rotate_size_envvar`` |
#'   ``r file_exporter_metrics_rotate_size_envvar`` |
#'   ``r file_exporter_logs_rotate_size_envvar``
#'
#'   How many rotated output files to keep.
#'
#' # Batch Processor
#'
#' These environment variables are used by [tracer_provider_http],
#' and [logger_provider_http].
#'
#' * `OTEL_BSP_SCHEDULE_DELAY`
#'
#'   The maximum buffer/queue size. After the size is reached, spans are
#'   dropped. Must be positive.
#'
#' * `OTEL_BSP_MAX_QUEUE_SIZE`
#'
#'   The maximum batch size of every export. It must be smaller or equal
#'   to max_queue_size. Must be positive.
#'
#' * `OTEL_BSP_MAX_EXPORT_BATCH_SIZE`
#'
#'   The time interval between two consecutive exports, in milliseconds.
#'
#' # Metric Reader
#'
#' These environment variables are used by [meter_provider_http],
#' [meter_provider_stdstream] [meter_provider_memory] and
#' [meter_provider_file].
#'
#' * ``r metric_export_interval_envvar``
#'
#'   The time interval between the start of two export attempts, in
#'   milliseconds.
#'
#' * ``r metric_export_timeout_envvar``
#'
#'   Maximum allowed time to export data, in milliseconds.
#'
#' # Metric Exporters
#'
#' These environment variables are used by [meter_provider_http] and
#' [meter_provider_memory].
#'
#' * ``r otlp_aggregation_temporality_envvar``
#'
#'   Aggregation temporality. Possible values:
#'   `r paste0('\u0060', otlp_aggregation_temporality_choices, '\u0060', collapse = ', ')`.
#'   See the [OpenTelemetry data model](
#'     https://opentelemetry.io/docs/specs/otel/metrics/data-model/#temporality).
#'
#' # Standard Stream Exporters
#'
#' These environment variables are used by [tracer_provider_stdstream],
#' [meter_provider_stdstream] and [logger_provider_stdstream].
#'
#' The signal specific environment variables have priority over the generic
#' one.
#'
#' * ``r stdstream_output_envvar`` |
#'   ``r tracer_provider_stdstream_output_envvar`` |
#'   ``r meter_provider_stdstream_output_envvar`` |
#'   ``r logger_provider_stdstream_output_envvar``
#'
#'   Where to write the output. Can be
#'    - `stdout`: write output to the standard output,
#'    - `stderr`: write output to the standard error,
#'    - another string: write output to a file. (To write output to a file
#'      named `stdout` or `"stderr`, use a `./` prefix.)
#'
#' # In-Memory Exporters
#'
#' These environment variables are used by [tracer_provider_memory] and
#' [meter_provider_memory].
#'
#' The signal specific environment variables have priority over the generic
#' one.
#'
#' * ``r memory_buffer_size_envvar`` |
#'   ``r memory_traces_buffer_size_envvar`` |
#'   ``r memory_metrics_buffer_size_envvar`` |
#'   ``r memory_buffer_size_default``
#'
#'   Buffer size, this is the maximum number of spans or metrics
#'   measurements that the provider can record.
#'
#' # Support Matrix of all OpenTelemetry Environment Variables for R
#'
#' | *Name*                                          | *Supported*
#' |:------------------------------------------------|:------------
#' | `OTEL_SDK_DISABLED`                             | +
#' | `OTEL_RESOURCE_ATTRIBUTES`                      | +
#' | `OTEL_SERVICE_NAME`                             | +
#' | `OTEL_LOG_LEVEL`                                | +
#' | `OTEL_PROPAGATORS`                              | -
#' | `OTEL_BSP_SCHEDULE_DELAY`                       | +
#' | `OTEL_BSP_EXPORT_TIMEOUT`                       | -
#' | `OTEL_BSP_MAX_QUEUE_SIZE`                       | +
#' | `OTEL_BSP_MAX_EXPORT_BATCH_SIZE`                | +
#' | `OTEL_EXPORTER_OTLP_ENDPOINT`                   | +
#' | `OTEL_EXPORTER_OTLP_*_ENDPOINT`                 | +
#' | `OTEL_EXPORTER_OTLP_INSECURE`                   | -
#' | `OTEL_EXPORTER_OTLP_*_INSECURE`                 | -
#' | `OTEL_EXPORTER_OTLP_CERTIFICATE`                | +
#' | `OTEL_EXPORTER_OTLP_*_CERTIFICATE`              | +
#' | `OTEL_EXPORTER_OTLP_CLIENT_KEY`                 | +
#' | `OTEL_EXPORTER_OTLP_*_CLIENT_KEY`               | +
#' | `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE`         | +
#' | `OTEL_EXPORTER_OTLP_CLIENT_*_CERTIFICATE`       | +
#' | `OTEL_EXPORTER_OTLP_HEADERS`                    | +
#' | `OTEL_EXPORTER_OTLP_*_HEADERS`                  | +
#' | `OTEL_EXPORTER_OTLP_COMPRESSION`                | +
#' | `OTEL_EXPORTER_OTLP_*_COMPRESSION`              | +
#' | `OTEL_EXPORTER_OTLP_PROTOCOL`                   | +
#' | `OTEL_EXPORTER_OTLP_*_PROTOCOL`                 | +
#' | `OTEL_EXPORTER_OTLP_SPAN_INSECURE` (obsolete)   | -
#' | `OTEL_EXPORTER_OTLP_METRIC_INSECURE` (obsolete) | -
#' | `OTEL_EXPORTER_ZIPKIN_ENDPOINT`                 | -
#' | `OTEL_EXPORTER_ZIPKIN_TIMEOUT`                  | -
#' | `OTEL_EXPORTER_PROMETHEUS_HOST`                 | -
#' | `OTEL_EXPORTER_PROMETHEUS_PORT`                 | -
#' | `OTEL_TRACES_EXPORTER`                          | +
#' | `OTEL_METRICS_EXPORTER`                         | +
#' | `OTEL_LOGS_EXPORTER`                            | +
#' | `OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT`               | -
#' | `OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT`        | -
#' | `OTEL_SPAN_EVENT_COUNT_LIMIT`                   | -
#' | `OTEL_SPAN_LINK_COUNT_LIMIT`                    | -
#' | `OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT`              | -
#' | `OTEL_LINK_ATTRIBUTE_COUNT_LIMIT`               | -
#' | `OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT`          | -
#' | `OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT`   | -
#' | `OTEL_TRACES_SAMPLER`                           | -
#' | `OTEL_TRACES_SAMPLER_ARG`                       | -
#' | `OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT` (1)         | +
#' | `OTEL_ATTRIBUTE_COUNT_LIMIT` (1)                | +
#' | `OTEL_METRIC_EXPORT_INTERVAL`                   | +
#' | `OTEL_METRIC_EXPORT_TIMEOUT`                    | +
#' | `OTEL_METRICS_EXEMPLAR_FILTER`                  | -
#' | `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | -
#' | `OTEL_EXPORTER_OTLP_METRICS_DEFAULT_HISTOGRAM_AGGREGATION` | -
#' | `OTEL_EXPERIMENTAL_CONFIG_FILE`                 | -
#'
#' (1) In [otel::as_attributes()].
#'
#' @return Not applicable.
#' @seealso \link[otel:Environment Variables]{Environment Variables} in otel
#' @examples
#' # To start an R session using the OTLP exporter:
#' # OTEL_TRACES_EXPORTER=http R -q -f script.R
NULL

doc_file_exporter_options <- function(evs, def) {
  glue(
    "* `file_pattern`: Output file pattern. Value is set from:
       - `opts` argument, or
       - `{evs[['file_pattern']]}` environment variable, or
       - `{file_exporter_file_envvar}` environment variable, or
       - the default is: `{def[['file_pattern']]}`.

       May contain placeholders, see below.

     * `alias_pattern`: The file which always point to the latest file.
       Value is set from:
       - `opts` argument, or
       - `{evs[['alias_pattern']]}` environment variable, or
       - `{file_exporter_alias_envvar} environment variable`, or
       - the default is: `{def[['alias_pattern']]}`.

       May contain placeholders, see below.

     * `flush_interval`: Interval to force flush output. A time interval
       specification, see \\link{{Time Interval Options}}. Value is set from
       - `opts` argument, or
       - `{evs[['flush_interval']]}` environment variable, or
       - `{file_exporter_flush_interval_envvar}` environment variable, or
       - the default is `30s`, thirty seconds.

     * `flush_count`: Force flush output after every `flush_count` records.
       Value is set from
       - `opts` argument, or
       - `{evs[['flush_count']]}` environment variable, or
       - `{file_exporter_flush_count_envvar}` environment variable, or
       - the default is `256`.

     * `file_size`: File size to rotate output files. A file size
       specification, see \\link{{File Size Options}}. Value is set from
       - `opts` argument, or
       - `{evs[['file_size']]}` environment variable, or
       - `{file_exporter_file_size_envvar}` environment variable, or
       - the default is `20MB`.

     * `rotate_size`: How many rotated output files to keep. Value is set
       from
       - `opts` argument, or
       - `{evs[['rotate_size']]}` environment variable, or
       - `{file_exporter_rotate_size_envvar}` environment variable, or
       - the default is `10`.

     Special placeholders are available for `file_pattern` and
     `alias_pattern`:

     * `%Y`: Writes year as a 4 digit decimal number.
     * `%y`: Writes last 2 digits of year as a decimal number (range `[00,99]`).
     * `%m`: Writes month as a decimal number (range `[01,12]`).
     * `%j`: Writes day of the year as a decimal number (range `[001,366]`).
     * `%d`: Writes day of the month as a decimal number (range `[01,31]`).
     * `%w`: Writes weekday as a decimal number, where Sunday is 0
             (range `[0-6]`).
     * `%H`: Writes hour as a decimal number, 24 hour clock (range `[00-23]`).
     * `%I`: Writes hour as a decimal number, 12 hour clock (range `[01,12]`).
     * `%M`: Writes minute as a decimal number (range `[00,59]`).
     * `%S`: Writes second as a decimal number (range `[00,60]`).
     * `%F`: Equivalent to `%Y-%m-%d` (the ISO 8601 date format).
     * `%T`: Equivalent to `%H:%M:%S` (the ISO 8601 time format).
     * `%R`: Equivalent to `%H:%M`.
     * `%N`: Rotate index, start from 0.
     * `%n`: Rotate index, start from 1.
    "
  )
}

doc_http_exporter_options <- function(which, evs, def) {
  glue(
    "
    * `url`: OTLP URL to send telemetry data to. Value is set from
      - the `opts` argument, needs to point to the {which} endpoint, or
      - `OTEL_EXPORTER_OTLP_{toupper(which)}_ENDPOINT` environment variable,
        needs to point to the {which} endpoint, or
      - `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable + `/v1/{which}`, or
      - the default is `{def[['url']]}`.

    * `content_type`: data format used, JSON or binary. Possible values:
      {paste0('`\"', names(otlp_content_type_values), '\"`', collapse = ', ')}.
      Value if set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_PROTOCOL` environment
        variable, or
      - the `OTEL_EXPORTER_OTLP_PROTOCOL` environment variable, or
      - the default is
        `\"{names(def[['content_type']])}\"`.

    * `json_bytes_mapping`: encoding used for trace id and span id.
      Possible values:
      {paste0('`\"', otlp_json_byte_mapping_choices, '\"`', collapse = ', ')}.
      Value is set from
      - the `opts` argument, or
      - the `{evs[['json_bytes_mapping']]}` environment variable, or
      - the `{otlp_json_bytes_mapping_envvar}` environment variable, or
      - the default is `\"{otlp_json_bytes_mapping_default}\"`.

    * `use_json_name`: whether to use json name of protobuf field to set
      the key of json. A flag. Value is set from
      - the `opts` argument, or
      - the `{evs[['use_json_name']]}` environment variable, or
      - the `{otlp_use_json_name_envvar}` environment variable, or
      - the default is `{otlp_use_json_name_default}`.

    * `console_debug`: whether to print debug messages to the console.
      Value is set from
      - the `opts` argument, or
      - the `{evs[['console_debug']]}` environment variable, or
      - the `{otlp_console_debug_envvar}` environment variable, or
      - the default is `{otlp_console_debug_default}`.

    * `timeout`: HTTP timeout in milliseconds. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_TIMEOUT}` environment
        variable, or
      - the `OTEL_EXPORTER_OTLP_TIMEOUT` environment variable, or
      - the default is `10000`.

    * `http_headers`: additional HTTP headers to send, e.g. `Authorization`
      is commonly used. A named character vector without `NA` values.
      Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_HEADERS` environment
        variable, or
      - the `OTEL_EXPORTER_OTLP_HEADERS` environment variable, or
      - the default is an empty named character vector.
      When specified in environment variables, it must be a comma separated
      list of headers, each in the `header=value` form.

    * `ssl_insecure_skip_verify`: whether to disable SSL. Value is set from
      - the `opts` argument, or
      - the `{evs[['ssl_insecure_skip_verify']]}` environment variable, or
      - the `{otlp_ssl_insecure_skip_verify_envvar}` environment variable, or
      - the default is `{otlp_ssl_insecure_skip_verify_default}`.

    * `ssl_ca_cert_path`: CA certificate, path to a file. Empty string uses
      the system default. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_CERTIFICATE` environment
        variable, or
      - the `OTEL_EXPORTER_OTLP_CERTIFICATE` environment variable, or
      - the default is `{def[['ssl_ca_cert_path']]}`.

    * `ssl_ca_cert_string`: CA certificate, as a string. Empty string uses
      the system default. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_CERTIFICATE_STRING`
        environment variable, or
      - the `OTEL_EXPORTER_OTLP_CERTIFICATE_STRING` environment variable, or
      - the default is `{def[['ssl_ca_cert_string']]}`.

    * `ssl_client_key_path`: SSL client key, path to a file. Empty string
      uses the system default. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_CLIENT_KEY`
        environment variable, or
      - the `OTEL_EXPORTER_OTLP_CLIENT_KEY` environment variable, or
      - the default is `{def[['ssl_client_key_path']]}`.

    * `ssl_client_key_string`: SSL client key as a string. Empty string
      uses the system default. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_CLIENT_KEY_STRING`
        environment variable, or
      - the `OTEL_EXPORTER_OTLP_CLIENT_KEY_STRING` environment
        variable, or
      - the default is `{def[['ssl_client_key_string']]}`.

    * `ssl_client_cert_path`: SSL client certificate, path to a file.
      Empty string uses the system default. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_CLIENT_CERTIFICATE`
        environment variable, or
      - the `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE` environment variable, or
      - the default is `{def[['ssl_client_cert_path']]}`.

    * `ssl_client_cert_string`: SSL client certificate, as a string.
      Empty string uses the system default. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_CLIENT_CERTIFICATE_STRING`
        environment variable, or
      - the `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE_STRING` environment
        variable, or
      - the default is `{def[['ssl_client_cert_string']]}`.

    * `ssl_min_tls`: minimum TLS version. Empty string uses the system
      default. Value is set from
      - the `opts` argument, or
      - the `{evs[['ssl_min_tls']]}` environment variable, or
      - the `{otlp_ssl_min_tls_envvar}` environment variable, or
      - the default is `{otlp_ssl_min_tls_default}`.

    * `ssl_max_tls`: maximum TLS version. Empty string uses the system
      default. Value is set from
      - the `opts` argument, or
      - the `{evs[['ssl_max_tls']]}` environment variable, or
      - the `{otlp_ssl_max_tls_envvar}` environment variable, or
      - the default is `{otlp_ssl_max_tls_default}`.

    * `ssl_cipher`: TLS cipher. Empty string uses the system default.
      Value is set from
      - the `opts` argument, or
      - the `{evs[['ssl_cipher']]}` environment variable, or
      - the `{otlp_ssl_cipher_envvar}` environment variable, or
      - the default is `{otlp_ssl_cipher_default}`.

    * `ssl_cipher_suite`: TLS cipher suite. Empty string uses the system
      default. Value is set from
      - the `opts` argument, or
      - the `{evs[['ssl_cipher_suite']]}` environment variable, or
      - the `{otlp_ssl_cipher_suite_envvar}` environment variable, or
      - the default is `{otlp_ssl_cipher_suite_default}`.

    * `compression`: compression to use. Possible values are
      {paste0('`\"', otlp_compression_choices, '\"`', collapse = ', ')}.
      Value is the set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_COMPRESSION` environment
        variable, or
      - the `OTEL_EXPORTER_OTLP_COMPRESSION` environment variable, or
      - the default is `{otlp_compression_choices['default']}`.

    * `retry_policy_max_attempts`: the maximum number of call attempts,
      including the original attempt. Value is set from
      - the `opts` argument, or
      - the `{evs[['retry_policy_max_attempts']]}` environment variable, or
      - the `{otlp_retry_policy_max_attempts_envvar}` environment variable, or
      - the default is `{otlp_retry_policy_max_attempts_default}`.

    * `retry_policy_initial_backoff`: the maximum initial back-off delay
      between retry attempts. The actual backoff delay is uniform random
      between zero and this. Value is set from
      - the `opts` argument, or
      - the `{evs[['retry_policy_initial_backoff']]}` environment variable, or
      - the `{otlp_retry_policy_initial_backoff_envvar}` environment
        variable, or
      - the default is `{otlp_retry_policy_initial_backoff_default}`.

    * `retry_policy_max_backoff`: the maximum backoff places an upper limit
      on exponential backoff growth. Value is set from
      - the `opts` argument, or
      - the `{evs[['retry_policy_max_backoff']]}` environment variable, or
      - the `{otlp_retry_policy_max_backoff_envvar}` environment variable, or
      - the default is `{otlp_retry_policy_max_backoff_default}`.

    * `retry_policy_backoff_multiplier`: the backoff will be multiplied by
      this value after each retry attempt. Value is set from
      - the `opts` argument, or
      - the `{evs[['retry_policy_backoff_multiplier']]}` environment
        variable, or
      - the `{otlp_retry_policy_backoff_multiplier_envvar}` environment
        variable, or
      - the default is `{otlp_retry_policy_backoff_multiplier_default}`.
    "
  )
}

doc_batch_processor_options <- function(def) {
  glue(
    "
    * `max_queue_size`: The maximum buffer/queue size. After the size is
      reached, spans are dropped. Must be positive. Value is set from
      - the `opts` argument, or
      - the `OTEL_BSP_MAX_QUEUE_SIZE` environment variable, or
      - the default is `{def[['max_queue_size']]}`.

    * `max_export_batch_size`: the maximum batch size of every export.
      It must be smaller or equal to max_queue_size. Must be positive.
      Value is set from
      - the `opts` argument, or
      - the `OTEL_BSP_MAX_EXPORT_BATCH_SIZE` environment variable, or
      - the default is `{def[['max_export_batch_size']]}`.

    * `schedule_delay`: the time interval between two consecutive exports,
      in milliseconds. Value is set from
      - the `opts` argument` or
      - the `OTEL_BSP_SCHEDULE_DELAY` environment variable, or
      - the default is `{def[['schedule_delay']]}`.
    "
  )
}

doc_memory_exporter_options <- function(evs) {
  glue(
    "
    * `buffer_size`: buffer size, this is the maximum number of spans or
      metrics measurements that the provider can record.
      Must be positive. Value is set from
      - the `opts` argument, or
      - the `{evs[['buffer_size']]}` environment variable, or
      - the `{memory_buffer_size_envvar}` environment variable, or
      - the default is `{memory_buffer_size_default}`.
    "
  )
}

doc_stdstream_exporter_options <- function(evs) {
  glue(
    "
    * `output`: where to write the output. Can be
      - `\"stdout\"`: write output to the standard output,
      - `\"stderr\"`: write output to the standard error,
      - another string: write output to a file. (To write output to a file
        named `\"stdout\"` or `\"stderr\"`, use a `./` prefix.)

      Value is set from
      - the `opts` argument, or
      - the `{evs[['output']]}` environment variable, or
      - the `{stdstream_output_envvar}` environment variable, or
      - the default is `\"stdout\"`.
    "
  )
}

doc_metric_reader_options <- function() {
  glue(
    "
    * `export_interval`: the time interval between the
      start of two export attempts, in milliseconds. Value is set from
      - the `opts` argument, or
      - the `{metric_export_interval_envvar}` environment variable, or
      - the default is `60000`.

    * `export_timeout`: Maximum allowed time to export data, in
      milliseconds. Value is set from
      - the `opts` argument, or
      - the `{metric_export_timeout_envvar}` environment variable, or
      - the default is `30000`.
    "
  )
}

doc_metric_exporter_options <- function() {
  glue(
    "
    * `aggregation_temporality`: possible values:
      {paste0('`\"', otlp_aggregation_temporality_choices, '\"`',
        collapse = ', ')}. See the [OpenTelemetry data model](
        https://opentelemetry.io/docs/specs/otel/metrics/data-model/#temporality).
      Value is set from
      - the `opts` argument, or
      - the `{otlp_aggregation_temporality_envvar}` environment variable, or
      - the default is `\"{otlp_aggregation_temporality_default}\"`.
    "
  )
}

#' @name Time Interval Options
#' @title Time Interval Options
#' @rdname timeintervaloptions
#' @description
#' otel and otelsdk accept time interval options in the following format:
#' - A [base::difftime] object.
#' - A positive numeric scalar, interpreted as number of milliseconds.
#'   It may be fractional.
#' - A string scalar with a positive number and a time unit suffix.
#'   Possible time units: us (microseconds), ms (milliseconds), s (seconds),
#'   m (minutes), h (hours), d (days).
#'
#' When the time interval is specified in an environment variable, it may be:
#' - A positive number, interpreted as number of milliseconds.
#'   It may be fractional.
#' - A positive number with a time unit suffix.
#'   Possible time units: us (microseconds), ms (milliseconds), s (seconds),
#'   m (minutes), h (hours), d (days).
#' @examples
#' # Write pending telemetry data to the output file every 5 seconds:
#' # OTEL_EXPORTER_OTLP_FILE_FLUSH_INTERVAL=5s
#' @return Not applicable.
NULL

#' @name File Size Options
#' @title File Size Options
#' @rdname filesizeoptions
#' @description
#' otel and otelsdk accept file size options in the following format:
#' - As a positive numeric scalar, interpreted as number of bytes.
#' - A string scalar with a positive number and a unit suffix.
#'   Possible units: B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB.
#'   Units are case insensitive.
#' @examples
#' # Maximum output file size is 128 MiB:
#' # OTEL_EXPORTER_OTLP_FILE_FILE_SIZE=128MiB
#' @return Not applicable.
NULL
