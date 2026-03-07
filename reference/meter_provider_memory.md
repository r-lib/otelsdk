# In-memory meter provider for testing

Collects metrics measurements in memory. This is useful for testing your
instrumented R package or application.

[`with_otel_record()`](https://otelsdk.r-lib.org/reference/with_otel_record.md)
uses this meter provider. Use
[`with_otel_record()`](https://otelsdk.r-lib.org/reference/with_otel_record.md)
in your tests to record telemetry and check that it is correct.

## Value

`meter_provider_memory$new()` returns an
[otel::otel_meter_provider](https://otel.r-lib.org/reference/otel_meter_provider.html)
object. `mp$get_metrics()` returns a named list of recorded metrics.

`meter_provider_memory$options()` returns a named list, the current
values for all options.

## Usage

    mp <- meter_provider_memory$new(opts = NULL)
    mp$get_metrics()
    meter_provider_memory$options()

`mp$get_metrics()` erases the internal buffer of the meter provider.

## Arguments

- `opts`: Named list of options. See below.

## Options

### Memory exporter options

- `buffer_size`: buffer size, this is the maximum number of spans or
  metrics measurements that the provider can record. Must be positive.
  Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_MEMORY_METRICS_BUFFER_SIZE` environment
    variable, or

  - the `OTEL_R_EXPORTER_MEMORY_BUFFER_SIZE` environment variable, or

  - the default is `100`.

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
meter_provider_memory$options()
#> $buffer_size
#> [1] 100
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
