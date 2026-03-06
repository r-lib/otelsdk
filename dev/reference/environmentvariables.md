# Environment variables to configure otelsdk

See also the Environment Variables in the otel package, which is charge
of selecting the exporters to use.

## Value

Not applicable.

## The OpenTelemetry Specification

Most of these environment variables are based on the [OpenTelemetry
Specification](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/),
version 1.55.0.

The environment variables with an '`OTEL_R_`' prefix are not (yet) in
the standard, and are specific for the otel and otelsdk R packages.

## General SDK Configuration

- `OTEL_SDK_DISABLED`

  Set to a 'true' value to disable the SDK for all signals.

- `OTEL_RESOURCE_ATTRIBUTES`

  Key-value pairs to be used as resource attributes. See the [Resource
  SDK](https://opentelemetry.io/docs/specs/otel/resource/sdk/#specifying-resource-information-via-an-environment-variable)
  for more details.

- `OTEL_SERVICE_NAME`

  Sets the value of the
  [`service.name`](https://opentelemetry.io/docs/specs/semconv/resource/#service)
  resource attribute.

- `OTEL_LOG_LEVEL`

  Log level used by the [SDK internal
  logger](https://opentelemetry.io/docs/specs/otel/error-handling/#self-diagnostics).
  In R it is also used for the default log level of the OpenTelemetry
  loggers.

## Selecting Exporters

otel is responsible for selecting the providers to use for traces, logs
and metrics. You can use the environment variables below to point the
otel functions to the desired providers.

If none of these environment variables are set, then otel will not emit
any telemetry data.

- `OTEL_TRACES_EXPORTER`

  The name of the selected tracer provider. See
  [`otel::get_default_tracer_provider()`](https://otel.r-lib.org/reference/get_default_tracer_provider.html)
  for the possible values.

- `OTEL_R_TRACES_EXPORTER`

  R specific version of `OTEL_TRACES_EXPORTER`.

- `OTEL_LOGS_EXPORTER`

  The name of the selected logger provider. See
  [`otel::get_default_logger_provider()`](https://otel.r-lib.org/reference/get_default_logger_provider.html)
  for the possible values.

- `OTEL_R_LOGS_EXPORTER`

  R specific version of `OTEL_LOGS_EXPORTER`.

- `OTEL_METRICS_EXPORTER`

  The name of the selected meter provider. See
  [`otel::get_default_meter_provider()`](https://otel.r-lib.org/reference/get_default_meter_provider.html)
  for the possible values.

- `OTEL_R_METRICS_EXPORTER`

  R specific version of `OTEL_METRICS_EXPORTER`.

## Suppressing Instrumentation Scopes (R Packages)

otel has two environment variables to fine tune which instrumentation
scopes (i.e. R packages, typically) emit telemetry data. By default,
i.e. if neither of these are set, all packages emit telemetry data.

- `OTEL_R_EMIT_SCOPES`

  Set this environment variable to a comma separated string of
  instrumentation scope names or R package names to restrict telemetry
  to these packages only. The name of the instrumentation scope is the
  same as the name of the tracer, logger or meter, see
  [`otel::default_tracer_name()`](https://otel.r-lib.org/reference/default_tracer_name.html).

  You can mix package names and instrumentation scope names and you can
  also use wildcards (globbing). For example the value

  OTEL_R_EMIT_SCOPES="org.r-lib.\*,dplyr"

  selects all packages with an instrumentation scope that starts with
  `org.r-lib.` and also dplyr.

- `OTEL_R_SUPPRESS_SCOPES`

  Set this environment variable to a comma separated string of
  instrumentation scope names or R package names to suppress telemetry
  data from these packages. The name of the instrumentation scope is the
  same as the name of the tracer, logger or meter, see
  [`otel::default_tracer_name()`](https://otel.r-lib.org/reference/default_tracer_name.html).

  You can mix package names and instrumentation scope names and you can
  also use wildcards (globbing). For example the value

  OTEL_R_SUPPRESS_SCOPES="org.r-lib.\*,dplyr"

  excludes packages with an instrumentation scope that starts with
  `org.r-lib.` and also dplyr.

## Zero Code Instrumentation

otel can instrument R packages for OpenTelemetry data collection without
changing their source code. This relies on changing the code of the R
functions manually using
[`base::trace()`](https://rdrr.io/r/base/trace.html) and can be
configured using environment variables.

- `OTEL_R_INSTRUMENT_PKGS`

  Set `OTEL_R_INSTRUMENT_PKGS` to a comma separated list of packages to
  instrument. The automatic instrumentation happens when the otel
  package is loaded, so in general it is best to set this environment
  variable before loading R.

- `OTEL_R_INSTRUMENT_PKGS_<pkg>_INCLUDE`

  For an automatically instrumented package, set this environment
  variable to only instrument a subset of its functions. It is parsed as
  a comma separated string of function names, which may also include `?`
  and `*` wildcards (globbing).

- `OTEL_R_INSTRUMENT_PKGS_<pkg>_EXCLUDE`

  For an automatically instrumented package, set this environment
  variable to exclude some functions from instrumentation. It has the
  same syntax as its `*_INCLUDE` pair. If both are set, then inclusion
  is applied and the exclusion.

## Attribute Limits

- `OTEL_ATTRIBUTE_COUNT_LIMIT`

  Set this environment variable to limit the number of attributes for a
  single span, log record, metric measurement, etc. If unset, the
  default limit is 128 attributes. Note that only attributes specified
  with
  [`otel::as_attributes()`](https://otel.r-lib.org/reference/as_attributes.html)
  are subject to this environment variable.

- `OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT`

  Set this environment variable to limit the length of vectors in
  attributes for a single span, log record, metric measurement, etc. If
  unset, there is no limit on the lengths of vectors in attributes. Note
  that only attributes specified with
  [`otel::as_attributes()`](https://otel.r-lib.org/reference/as_attributes.html)
  are subject to this environment variable.

## OTLP/HTTP Exporters

These environment variables are used by
[tracer_provider_http](https://otelsdk.r-lib.org/dev/reference/tracer_provider_http.md),
[meter_provider_http](https://otelsdk.r-lib.org/dev/reference/meter_provider_http.md)
and
[logger_provider_http](https://otelsdk.r-lib.org/dev/reference/logger_provider_http.md).

For every set of environment variables, the signal specific ones have
priority over the generic one.

- `OTEL_EXPORTER_OTLP_ENDPOINT` \| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`
  \| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` \|
  `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`

  OTLP URL to send telemetry data to. When the generic environment
  variable is used, the exporter appends the signal specific endpoint to
  it. The signal specific environment variables are used as is. More in
  the [OpenTelemetry
  specification](https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls-for-otlphttp).

- `OTEL_EXPORTER_OTLP_PROTOCOL` \| `OTEL_EXPORTER_OTLP_TRACES_PROTOCOL`
  \| `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL` \|
  `OTEL_EXPORTER_OTLP_LOGS_PROTOCOL`

  The transport protocol. Possible values: `http/json`, `http/protobuf`.

- `OTEL_R_EXPORTER_OTLP_JSON_BYTES_MAPPING` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_JSON_BYTES_MAPPING` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_JSON_BYTES_MAPPING` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_JSON_BYTES_MAPPING`

  Encoding used for trace ids and spans id. Possible values: `hexid`,
  `base64`, `hex`.

- `OTEL_R_EXPORTER_OTLP_USE_JSON_NAME` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_USE_JSON_NAME` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_USE_JSON_NAME` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_USE_JSON_NAME`

  Whether to use json name of protobuf field to set the key of json. A
  boolean value (flag, `true` or `false`).

- `OTEL_R_EXPORTER_OTLP_CONSOLE_DEBUG` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_CONSOLE_DEBUG` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_CONSOLE_DEBUG` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_CONSOLE_DEBUG`

  Whether to print debug messages to the console. A boolean value (flag,
  `true` or `false`).

- `OTEL_EXPORTER_OTLP_TIMEOUT` \| `OTEL_EXPORTER_OTLP_TRACES_TIMEOUT` \|
  `OTEL_EXPORTER_OTLP_METRICS_TIMEOUT` \|
  `OTEL_EXPORTER_OTLP_LOGS_TIMEOUT`

  HTTP timeout in milliseconds.

- `OTEL_EXPORTER_OTLP_HEADERS` \| `OTEL_EXPORTER_OTLP_TRACES_HEADERS` \|
  `OTEL_EXPORTER_OTLP_METRICS_HEADERS` \|
  `OTEL_EXPORTER_OTLP_LOGS_HEADERS`

  Additional HTTP headers to send. E.g. `Authorization` is commonly
  used. It must be a comma separated list of headers, each in the
  `header=value` form.

- `OTEL_R_EXPORTER_OTLP_SSL_INSECURE_SKIP_VERIFY` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_SSL_INSECURE_SKIP_VERIFY` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_SSL_INSECURE_SKIP_VERIFY` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_SSL_INSECURE_SKIP_VERIFY`

  Whether to disable SSL. A boolean value (flag, `true` or `false`).

- `OTEL_EXPORTER_OTLP_CERTIFICATE` \|
  `OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE` \|
  `OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE` \|
  `OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE`

  CA certificate, path to a file.

- `OTEL_EXPORTER_OTLP_CERTIFICATE_STRING` \|
  `OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE_STRING` \|
  `OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE_STRING` \|
  `OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE_STRING`

  CA certificate, as a string.

- `OTEL_EXPORTER_OTLP_CLIENT_KEY` \|
  `OTEL_EXPORTER_OTLP_TRACES_CLIENT_KEY` \|
  `OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY` \|
  `OTEL_EXPORTER_OTLP_LOGS_CLIENT_KEY`

  SSL client key, path to a file.

- `OTEL_EXPORTER_OTLP_CLIENT_KEY_STRING` \|
  `OTEL_EXPORTER_OTLP_TRACES_CLIENT_KEY_STRING` \|
  `OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY_STRING` \|
  `OTEL_EXPORTER_OTLP_LOGS_CLIENT_KEY_STRING`

  SSL client key as a string.

- `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE` \|
  `OTEL_EXPORTER_OTLP_TRACES_CLIENT_CERTIFICATE` \|
  `OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE` \|
  `OTEL_EXPORTER_OTLP_LOGS_CLIENT_CERTIFICATE`

  SSL client certificate, path to a file.

- `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE_STRING` \|
  `OTEL_EXPORTER_OTLP_TRACES_CLIENT_CERTIFICATE_STRING` \|
  `OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE_STRING` \|
  `OTEL_EXPORTER_OTLP_LOGS_CLIENT_CERTIFICATE_STRING`

  SSL client certificate, as a string.

- `OTEL_R_EXPORTER_OTLP_SSL_MIN_TLS` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_SSL_MIN_TLS` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_SSL_MIN_TLS` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_SSL_MIN_TLS`

  Minimum TLS version.

- `OTEL_R_EXPORTER_OTLP_SSL_MAX_TLS` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_SSL_MAX_TLS` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_SSL_MAX_TLS` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_SSL_MAX_TLS`

  Maximum TLS version.

- `OTEL_R_EXPORTER_OTLP_SSL_CIPHER` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_SSL_CIPHER` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_SSL_CIPHER` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_SSL_CIPHER`

  TLS cipher.

- `OTEL_R_EXPORTER_OTLP_SSL_CIPHER_SUITE` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_SSL_CIPHER_SUITE` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_SSL_CIPHER_SUITE` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_SSL_CIPHER_SUITE`

  TLS cipher suite.

- `OTEL_EXPORTER_OTLP_COMPRESSION` \|
  `OTEL_EXPORTER_OTLP_TRACES_COMPRESSION` \|
  `OTEL_EXPORTER_OTLP_METRICS_COMPRESSION` \|
  `OTEL_EXPORTER_OTLP_LOGS_COMPRESSION`

  Compression to use. `none`, `gzip`.

- `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_MAX_ATTEMPTS` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_MAX_ATTEMPTS` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_MAX_ATTEMPTS` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_MAX_ATTEMPTS`

  The maximum number of call attempts, including the original attempt.

- `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_INITIAL_BACKOFF` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_INITIAL_BACKOFF` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_INITIAL_BACKOFF` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_INITIAL_BACKOFF`

  The maximum initial back-off delay between retry attempts. The actual
  backoff delay is uniform random between zero and this. It is in
  milliseconds.

- `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_MAX_BACKOFF` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_MAX_BACKOFF` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_MAX_BACKOFF` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_MAX_BACKOFF`

  The maximum backoff places an upper limit on exponential backoff
  growth.

- `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_BACKOFF_MULTIPLIER` \|
  `OTEL_R_EXPORTER_OTLP_TRACES_RETRY_POLICY_BACKOFF_MULTIPLIER` \|
  `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_BACKOFF_MULTIPLIER` \|
  `OTEL_R_EXPORTER_OTLP_LOGS_RETRY_POLICY_BACKOFF_MULTIPLIER`

  The backoff will be multiplied by this value after each retry attempt.

## OTLP/FILE Exporters

These environment variables are used by
[tracer_provider_file](https://otelsdk.r-lib.org/dev/reference/tracer_provider_file.md),
[meter_provider_file](https://otelsdk.r-lib.org/dev/reference/meter_provider_file.md)
and
[logger_provider_file](https://otelsdk.r-lib.org/dev/reference/logger_provider_file.md).

For every set of environment variables, the signal specific ones have
priority over the generic one.

- `OTEL_EXPORTER_OTLP_FILE` \| `OTEL_EXPORTER_OTLP_TRACES_FILE` \|
  `OTEL_EXPORTER_OTLP_METRICS_FILE` \| `OTEL_EXPORTER_OTLP_LOGS_FILE`

  Output file pattern. May contain placeholders, see the manual pages of
  the providers, linked at the beginning of the section.

- `OTEL_EXPORTER_OTLP_FILE_ALIAS` \|
  `OTEL_EXPORTER_OTLP_TRACES_FILE_ALIAS` \|
  `OTEL_EXPORTER_OTLP_METRICS_FILE_ALIAS` \|
  `OTEL_EXPORTER_OTLP_LOGS_FILE_ALIAS`

  The file which always point to the latest file. May contain
  placeholders, see the manual pages of the providers, linked at the
  beginning of the section.

- `OTEL_EXPORTER_OTLP_FILE_FLUSH_INTERVAL` \|
  `OTEL_EXPORTER_OTLP_TRACES_FILE_FLUSH_INTERVAL` \|
  `OTEL_EXPORTER_OTLP_METRICS_FILE_FLUSH_INTERVAL` \|
  `OTEL_EXPORTER_OTLP_LOGS_FILE_FLUSH_INTERVAL`

  Interval to force flush output. A time interval specification, see
  [Time Interval
  Options](https://otelsdk.r-lib.org/dev/reference/timeintervaloptions.md).

- `OTEL_EXPORTER_OTLP_FILE_FLUSH_COUNT` \|
  `OTEL_EXPORTER_OTLP_TRACES_FILE_FILE_SIZE` \|
  `OTEL_EXPORTER_OTLP_METRICS_FILE_FILE_SIZE` \|
  `OTEL_EXPORTER_OTLP_LOGS_FILE_FILE_SIZE`

  Force flush output after every `flush_count` records.

- `OTEL_EXPORTER_OTLP_FILE_FILE_SIZE` \|
  `OTEL_EXPORTER_OTLP_TRACES_FILE_FILE_SIZE` \|
  `OTEL_EXPORTER_OTLP_METRICS_FILE_FILE_SIZE` \|
  `OTEL_EXPORTER_OTLP_LOGS_FILE_FILE_SIZE`

  File size to rotate output files. A file size specification, see [File
  Size
  Options](https://otelsdk.r-lib.org/dev/reference/filesizeoptions.md).

- `OTEL_EXPORTER_OTLP_FILE_ROTATE_SIZE` \|
  `OTEL_EXPORTER_OTLP_TRACES_FILE_ROTATE_SIZE` \|
  `OTEL_EXPORTER_OTLP_METRICS_FILE_ROTATE_SIZE` \|
  `OTEL_EXPORTER_OTLP_LOGS_FILE_ROTATE_SIZE`

  How many rotated output files to keep.

## Batch Processor

These environment variables are used by
[tracer_provider_http](https://otelsdk.r-lib.org/dev/reference/tracer_provider_http.md),
and
[logger_provider_http](https://otelsdk.r-lib.org/dev/reference/logger_provider_http.md).

- `OTEL_BSP_SCHEDULE_DELAY`

  The maximum buffer/queue size. After the size is reached, spans are
  dropped. Must be positive.

- `OTEL_BSP_MAX_QUEUE_SIZE`

  The maximum batch size of every export. It must be smaller or equal to
  max_queue_size. Must be positive.

- `OTEL_BSP_MAX_EXPORT_BATCH_SIZE`

  The time interval between two consecutive exports, in milliseconds.

## Metric Reader

These environment variables are used by
[meter_provider_http](https://otelsdk.r-lib.org/dev/reference/meter_provider_http.md),
[meter_provider_stdstream](https://otelsdk.r-lib.org/dev/reference/meter_provider_stdstream.md)
[meter_provider_memory](https://otelsdk.r-lib.org/dev/reference/meter_provider_memory.md)
and
[meter_provider_file](https://otelsdk.r-lib.org/dev/reference/meter_provider_file.md).

- `OTEL_METRIC_EXPORT_INTERVAL`

  The time interval between the start of two export attempts, in
  milliseconds.

- `OTEL_METRIC_EXPORT_TIMEOUT`

  Maximum allowed time to export data, in milliseconds.

## Metric Exporters

These environment variables are used by
[meter_provider_http](https://otelsdk.r-lib.org/dev/reference/meter_provider_http.md)
and
[meter_provider_memory](https://otelsdk.r-lib.org/dev/reference/meter_provider_memory.md).

- `OTEL_R_EXPORTER_OTLP_AGGREGATION_TEMPORALITY`

  Aggregation temporality. Possible values: `unspecified`, `delta`,
  `cumulative`, `lowmemory`. See the [OpenTelemetry data
  model](https://opentelemetry.io/docs/specs/otel/metrics/data-model/#temporality).

## Standard Stream Exporters

These environment variables are used by
[tracer_provider_stdstream](https://otelsdk.r-lib.org/dev/reference/tracer_provider_stdstream.md),
[meter_provider_stdstream](https://otelsdk.r-lib.org/dev/reference/meter_provider_stdstream.md)
and
[logger_provider_stdstream](https://otelsdk.r-lib.org/dev/reference/logger_provider_stdstream.md).

The signal specific environment variables have priority over the generic
one.

- `OTEL_R_EXPORTER_STDSTREAM_OUTPUT` \|
  `OTEL_R_EXPORTER_STDSTREAM_TRACES_OUTPUT` \|
  `OTEL_R_EXPORTER_STDSTREAM_METRICS_OUTPUT` \|
  `OTEL_R_EXPORTER_STDSTREAM_LOGS_OUTPUT`

  Where to write the output. Can be

  - `stdout`: write output to the standard output,

  - `stderr`: write output to the standard error,

  - another string: write output to a file. (To write output to a file
    named `stdout` or `"stderr`, use a `./` prefix.)

## In-Memory Exporters

These environment variables are used by
[tracer_provider_memory](https://otelsdk.r-lib.org/dev/reference/tracer_provider_memory.md)
and
[meter_provider_memory](https://otelsdk.r-lib.org/dev/reference/meter_provider_memory.md).

The signal specific environment variables have priority over the generic
one.

- `OTEL_R_EXPORTER_MEMORY_BUFFER_SIZE` \|
  `OTEL_R_EXPORTER_MEMORY_TRACES_BUFFER_SIZE` \|
  `OTEL_R_EXPORTER_MEMORY_METRICS_BUFFER_SIZE` \|
  `OTEL_R_EXPORTER_MEMORY_BUFFER_SIZE`

  Buffer size, this is the maximum number of spans or metrics
  measurements that the provider can record.

## Support Matrix of all OpenTelemetry Environment Variables for R

|                                                            |             |
|------------------------------------------------------------|-------------|
| *Name*                                                     | *Supported* |
| `OTEL_SDK_DISABLED`                                        | \+          |
| `OTEL_ENTITIES`                                            | \-          |
| `OTEL_RESOURCE_ATTRIBUTES`                                 | \+          |
| `OTEL_SERVICE_NAME`                                        | \+          |
| `OTEL_LOG_LEVEL`                                           | \+          |
| `OTEL_PROPAGATORS`                                         | \-          |
| `OTEL_BSP_SCHEDULE_DELAY`                                  | \+          |
| `OTEL_BSP_EXPORT_TIMEOUT`                                  | \-          |
| `OTEL_BSP_MAX_QUEUE_SIZE`                                  | \+          |
| `OTEL_BSP_MAX_EXPORT_BATCH_SIZE`                           | \+          |
| `OTEL_EXPORTER_OTLP_ENDPOINT`                              | \+          |
| `OTEL_EXPORTER_OTLP_*_ENDPOINT`                            | \+          |
| `OTEL_EXPORTER_OTLP_INSECURE`                              | \-          |
| `OTEL_EXPORTER_OTLP_*_INSECURE`                            | \-          |
| `OTEL_EXPORTER_OTLP_CERTIFICATE`                           | \+          |
| `OTEL_EXPORTER_OTLP_*_CERTIFICATE`                         | \+          |
| `OTEL_EXPORTER_OTLP_CLIENT_KEY`                            | \+          |
| `OTEL_EXPORTER_OTLP_*_CLIENT_KEY`                          | \+          |
| `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE`                    | \+          |
| `OTEL_EXPORTER_OTLP_CLIENT_*_CERTIFICATE`                  | \+          |
| `OTEL_EXPORTER_OTLP_HEADERS`                               | \+          |
| `OTEL_EXPORTER_OTLP_*_HEADERS`                             | \+          |
| `OTEL_EXPORTER_OTLP_COMPRESSION`                           | \+          |
| `OTEL_EXPORTER_OTLP_*_COMPRESSION`                         | \+          |
| `OTEL_EXPORTER_OTLP_PROTOCOL`                              | \+          |
| `OTEL_EXPORTER_OTLP_*_PROTOCOL`                            | \+          |
| `OTEL_EXPORTER_OTLP_SPAN_INSECURE` (obsolete)              | \-          |
| `OTEL_EXPORTER_OTLP_METRIC_INSECURE` (obsolete)            | \-          |
| `OTEL_EXPORTER_ZIPKIN_ENDPOINT`                            | \-          |
| `OTEL_EXPORTER_ZIPKIN_TIMEOUT`                             | \-          |
| `OTEL_EXPORTER_PROMETHEUS_HOST`                            | \-          |
| `OTEL_EXPORTER_PROMETHEUS_PORT`                            | \-          |
| `OTEL_TRACES_EXPORTER`                                     | \+          |
| `OTEL_METRICS_EXPORTER`                                    | \+          |
| `OTEL_LOGS_EXPORTER`                                       | \+          |
| `OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT`                          | \-          |
| `OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT`                   | \-          |
| `OTEL_SPAN_EVENT_COUNT_LIMIT`                              | \-          |
| `OTEL_SPAN_LINK_COUNT_LIMIT`                               | \-          |
| `OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT`                         | \-          |
| `OTEL_LINK_ATTRIBUTE_COUNT_LIMIT`                          | \-          |
| `OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT`                     | \-          |
| `OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT`              | \-          |
| `OTEL_TRACES_SAMPLER`                                      | \-          |
| `OTEL_TRACES_SAMPLER_ARG`                                  | \-          |
| `OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT` (1)                    | \+          |
| `OTEL_ATTRIBUTE_COUNT_LIMIT` (1)                           | \+          |
| `OTEL_METRIC_EXPORT_INTERVAL`                              | \+          |
| `OTEL_METRIC_EXPORT_TIMEOUT`                               | \+          |
| `OTEL_METRICS_EXEMPLAR_FILTER`                             | \-          |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE`        | \-          |
| `OTEL_EXPORTER_OTLP_METRICS_DEFAULT_HISTOGRAM_AGGREGATION` | \-          |
| `OTEL_EXPERIMENTAL_CONFIG_FILE`                            | \-          |
| `OTEL_CONFIG_FILE`                                         | \-          |

\(1\) In
[`otel::as_attributes()`](https://otel.r-lib.org/reference/as_attributes.html).

## See also

[Environment
Variables](https://otel.r-lib.org/reference/environmentvariables.html)
in otel

## Examples

``` r
# To start an R session using the OTLP exporter:
# OTEL_TRACES_EXPORTER=http R -q -f script.R
```
