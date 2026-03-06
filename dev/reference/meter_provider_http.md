# Meter provider to send collected metrics over HTTP

This is the OTLP HTTP exporter.

Select this tracer provider with `OTEL_METRICS_EXPORTER=otlp`.

## Value

`meter_provider_http$new()` returns an
[otel::otel_meter_provider](https://otel.r-lib.org/reference/otel_meter_provider.html)
object.

`meter_provider_http$options()` returns a named list, the current values
for all options.

## Usage

Externally:

    OTEL_METRICS_EXPORTER=otlp

From R:

    meter_provider_http$new(opts = NULL)
    meter_provider_http$options()

## Arguments

- `opts`: Named list of options. See below.

## Options

### HTTP exporter options

- `url`: OTLP URL to send telemetry data to. Value is set from

  - the `opts` argument, needs to point to the metrics endpoint, or

  - `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` environment variable, needs to
    point to the metrics endpoint, or

  - `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable + `/v1/metrics`,
    or

  - the default is `http://localhost:4318/v1/metrics`.

- `content_type`: data format used, JSON or binary. Possible values:
  `"http/json"`, `"http/protobuf"`. Value if set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_PROTOCOL` environment variable, or

  - the `OTEL_EXPORTER_OTLP_PROTOCOL` environment variable, or

  - the default is `"http/protobuf"`.

- `json_bytes_mapping`: encoding used for trace id and span id. Possible
  values: `"hexid"`, `"base64"`, `"hex"`. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_JSON_BYTES_MAPPING` environment
    variable, or

  - the `OTEL_R_EXPORTER_OTLP_JSON_BYTES_MAPPING` environment variable,
    or

  - the default is `"hexid"`.

- `use_json_name`: whether to use json name of protobuf field to set the
  key of json. A flag. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_USE_JSON_NAME` environment
    variable, or

  - the `OTEL_R_EXPORTER_OTLP_USE_JSON_NAME` environment variable, or

  - the default is `FALSE`.

- `console_debug`: whether to print debug messages to the console. Value
  is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_CONSOLE_DEBUG` environment
    variable, or

  - the `OTEL_R_EXPORTER_OTLP_CONSOLE_DEBUG` environment variable, or

  - the default is `FALSE`.

- `timeout`: HTTP timeout in milliseconds. Value is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_TIMEOUT}` environment variable, or

  - the `OTEL_EXPORTER_OTLP_TIMEOUT` environment variable, or

  - the default is `10000`.

- `http_headers`: additional HTTP headers to send, e.g. `Authorization`
  is commonly used. A named character vector without `NA` values. Value
  is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_HEADERS` environment variable, or

  - the `OTEL_EXPORTER_OTLP_HEADERS` environment variable, or

  - the default is an empty named character vector. When specified in
    environment variables, it must be a comma separated list of headers,
    each in the `header=value` form.

- `ssl_insecure_skip_verify`: whether to disable SSL. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_SSL_INSECURE_SKIP_VERIFY`
    environment variable, or

  - the `OTEL_R_EXPORTER_OTLP_SSL_INSECURE_SKIP_VERIFY` environment
    variable, or

  - the default is `FALSE`.

- `ssl_ca_cert_path`: CA certificate, path to a file. Empty string uses
  the system default. Value is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE` environment variable,
    or

  - the `OTEL_EXPORTER_OTLP_CERTIFICATE` environment variable, or

  - the default is “.

- `ssl_ca_cert_string`: CA certificate, as a string. Empty string uses
  the system default. Value is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE_STRING` environment
    variable, or

  - the `OTEL_EXPORTER_OTLP_CERTIFICATE_STRING` environment variable, or

  - the default is “.

- `ssl_client_key_path`: SSL client key, path to a file. Empty string
  uses the system default. Value is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY` environment variable, or

  - the `OTEL_EXPORTER_OTLP_CLIENT_KEY` environment variable, or

  - the default is “.

- `ssl_client_key_string`: SSL client key as a string. Empty string uses
  the system default. Value is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_CLIENT_KEY_STRING` environment
    variable, or

  - the `OTEL_EXPORTER_OTLP_CLIENT_KEY_STRING` environment variable, or

  - the default is “.

- `ssl_client_cert_path`: SSL client certificate, path to a file. Empty
  string uses the system default. Value is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE` environment
    variable, or

  - the `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE` environment variable, or

  - the default is “.

- `ssl_client_cert_string`: SSL client certificate, as a string. Empty
  string uses the system default. Value is set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_CLIENT_CERTIFICATE_STRING`
    environment variable, or

  - the `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE_STRING` environment
    variable, or

  - the default is “.

- `ssl_min_tls`: minimum TLS version. Empty string uses the system
  default. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_SSL_MIN_TLS` environment variable,
    or

  - the `OTEL_R_EXPORTER_OTLP_SSL_MIN_TLS` environment variable, or

  - the default is “.

- `ssl_max_tls`: maximum TLS version. Empty string uses the system
  default. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_SSL_MAX_TLS` environment variable,
    or

  - the `OTEL_R_EXPORTER_OTLP_SSL_MAX_TLS` environment variable, or

  - the default is “.

- `ssl_cipher`: TLS cipher. Empty string uses the system default. Value
  is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_SSL_CIPHER` environment variable,
    or

  - the `OTEL_R_EXPORTER_OTLP_SSL_CIPHER` environment variable, or

  - the default is “.

- `ssl_cipher_suite`: TLS cipher suite. Empty string uses the system
  default. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_SSL_CIPHER_SUITE` environment
    variable, or

  - the `OTEL_R_EXPORTER_OTLP_SSL_CIPHER_SUITE` environment variable, or

  - the default is “.

- `compression`: compression to use. Possible values are `"none"`,
  `"gzip"`. Value is the set from

  - the `opts` argument, or

  - the `OTEL_EXPORTER_OTLP_METRICS_COMPRESSION` environment variable,
    or

  - the `OTEL_EXPORTER_OTLP_COMPRESSION` environment variable, or

  - the default is `none`.

- `retry_policy_max_attempts`: the maximum number of call attempts,
  including the original attempt. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_MAX_ATTEMPTS`
    environment variable, or

  - the `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_MAX_ATTEMPTS` environment
    variable, or

  - the default is `5`.

- `retry_policy_initial_backoff`: the maximum initial back-off delay
  between retry attempts. The actual backoff delay is uniform random
  between zero and this. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_INITIAL_BACKOFF`
    environment variable, or

  - the `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_INITIAL_BACKOFF` environment
    variable, or

  - the default is `1000`.

- `retry_policy_max_backoff`: the maximum backoff places an upper limit
  on exponential backoff growth. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_MAX_BACKOFF`
    environment variable, or

  - the `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_MAX_BACKOFF` environment
    variable, or

  - the default is `5000`.

- `retry_policy_backoff_multiplier`: the backoff will be multiplied by
  this value after each retry attempt. Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_METRICS_RETRY_POLICY_BACKOFF_MULTIPLIER`
    environment variable, or

  - the `OTEL_R_EXPORTER_OTLP_RETRY_POLICY_BACKOFF_MULTIPLIER`
    environment variable, or

  - the default is `1.5`.

### Metric reader options

- `export_interval`: the time interval between the start of two export
  attempts, in milliseconds. Value is set from

  - the `opts` argument, or

  - the `OTEL_METRIC_EXPORT_INTERVAL` environment variable, or

  - the default is `60000`.

- `export_timeout`: Maximum allowed time to export data, in
  milliseconds. Value is set from

  - the `opts` argument, or

  - the `OTEL_METRIC_EXPORT_TIMEOUT` environment variable, or

  - the default is `30000`.

### Metric exporter options

- `aggregation_temporality`: possible values: `"unspecified"`,
  `"delta"`, `"cumulative"`, `"lowmemory"`. See the [OpenTelemetry data
  model](https://opentelemetry.io/docs/specs/otel/metrics/data-model/#temporality).
  Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_OTLP_AGGREGATION_TEMPORALITY` environment
    variable, or

  - the default is `"cumulative"`.

## Examples

``` r
meter_provider_http$options()
#> $url
#> [1] "http://localhost:4318/v1/metrics"
#> 
#> $content_type
#> http/protobuf 
#>             1 
#> 
#> $json_bytes_mapping
#> [1] 0
#> 
#> $use_json_name
#> [1] FALSE
#> 
#> $console_debug
#> [1] FALSE
#> 
#> $timeout
#> [1] 10
#> 
#> $http_headers
#> named character(0)
#> 
#> $ssl_insecure_skip_verify
#> [1] FALSE
#> 
#> $ssl_ca_cert_path
#> [1] ""
#> 
#> $ssl_ca_cert_string
#> [1] ""
#> 
#> $ssl_client_key_path
#> [1] ""
#> 
#> $ssl_client_key_string
#> [1] ""
#> 
#> $ssl_client_cert_path
#> [1] ""
#> 
#> $ssl_client_cert_string
#> [1] ""
#> 
#> $ssl_min_tls
#> [1] ""
#> 
#> $ssl_max_tls
#> [1] ""
#> 
#> $ssl_cipher
#> [1] ""
#> 
#> $ssl_cipher_suite
#> [1] ""
#> 
#> $compression
#> [1] "none"
#> 
#> $retry_policy_max_attempts
#> [1] 5
#> 
#> $retry_policy_initial_backoff
#> [1] 1000
#> 
#> $retry_policy_max_backoff
#> [1] 5000
#> 
#> $retry_policy_backoff_multiplier
#> [1] 1.5
#> 
#> $export_interval
#> [1] 60000
#> 
#> $export_timeout
#> [1] 30000
#> 
#> $aggregation_temporality
#> cumulative 
#>          2 
#> 
```
