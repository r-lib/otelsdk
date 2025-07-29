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
#' @examples
#' # See above
NULL

#' Environment variables to configure otelsdk
#' @name Environment Variables
#' @rdname environmentvariables
#'
#' @description
#' See also the [Environment Variables][otel::Environment Variables] in
#' the otel package, which is charge of selecting the exporters to use.
#'
#' @details
#' TODO
#'
#' @return Not applicable.
#' @seealso [Environment Variables][otel::Environment Variables] in otel
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
      - the `{evs[['content_type']]}` environment variable, or
      - the `{otlp_content_type_envvar}` environment variable, or
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

    * `timeout`: HTTP timeout. A time interval specification, see
      \\link{{Time Interval Options}}. Value is set from
      - the `opts` argument, or
      - the `OTEL_EXPORTER_OTLP_{toupper(which)}_TIMEOUT}` environment
        variable, or
      - the `OTEL_EXPORTER_OTLP_TIMEOUT` environment variable, or
      - the default is `10s`.

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
      between zero and this. This is a time interval specification, see
      \\link{{Time Interval Options}}. Value is set from
      - the `opts` argument, or
      - the `{evs[['retry_policy_initial_backoff']]}` environment variable, or
      - the `{otlp_retry_policy_initial_backoff_envvar}` environment
        variable, or
      - the default is `{otlp_retry_policy_initial_backoff_default}ms`.

    * `retry_policy_max_backoff`: the maximum backoff places an upper limit
      on exponential backoff growth. This is a time interval specification,
      see \\link{{Time Interval Options}}. Value is set from
      - the `opts` argument, or
      - the `{evs[['retry_policy_max_backoff']]}` environment variable, or
      - the `{otlp_retry_policy_max_backoff_envvar}` environment variable, or
      - the default is `{otlp_retry_policy_max_backoff_default}ms`.

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

    * `schedule_delay`: the time interval between two consecutive exports.
      This is a time interval specification, see
      \\link{{Time Interval Options}}. Value is set from
      - the `opts` argument` or
      - the `OTEL_BSP_SCHEDULE_DELAY` environment variable, or
      - the default is `{def[['schedule_delay']]}ms`.
    "
  )
}

doc_memory_exporter_options <- function(evs) {
  glue(
    "
    * `buffer_size`: buffer size, this is the maximum number of spans or
      metrics measurements that the tracer provider can record.
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
      - the default is `\"stdout\"`.
    "
  )
}

doc_metric_reader_options <- function() {
  glue(
    "
    * `export_interval`: the time interval between the
      start of two export attempts. A time interval specification, see
      \\link{{Time Interval Options}}. Value is set from
      - the `opts` argument, or
      - the `{metric_export_interval_envvar}` environment variable, or
      - the default is `\"60s\"`.

    * `export_timeout`: Maximum allowed time to export data.
      A time interval specification, see
      \\link{{Time Interval Options}}. Value is set from
      - the `opts` argument, or
      - the `{metric_export_timeout_envvar}` environment variable, or
      - the default is `\"30s\"`.
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
#' @return Not applicable.
NULL
