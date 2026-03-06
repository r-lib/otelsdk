# Meter provider to write to the standard output or standard error or to a file

Writes metrics measurements to the standard output or error, or to a
file. Useful for debugging.

## Value

`meter_provider_stdstream$new()` returns an
[otel::otel_meter_provider](https://otel.r-lib.org/reference/otel_meter_provider.html)
object.

`meter_provider_stdstream$options()` returns a named list, the current
values of the options.

## Usage

Externally:

    OTEL_METRICS_EXPORTER=console
    OTEL_METRICS_EXPORTER=stderr

From R:

    meter_provider_stdstream$new(opts = NULL)
    meter_provider_stdstream$options()

## Arguments

`opts`: Named list of options. See below.

## Options

### Standard stream exporter options

- `output`: where to write the output. Can be

  - `"stdout"`: write output to the standard output,

  - `"stderr"`: write output to the standard error,

  - another string: write output to a file. (To write output to a file
    named `"stdout"` or `"stderr"`, use a `./` prefix.)

  Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_STDSTREAM_METRICS_OUTPUT` environment variable,
    or

  - the `OTEL_R_EXPORTER_STDSTREAM_OUTPUT` environment variable, or

  - the default is `"stdout"`.

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

## Examples

``` r
meter_provider_stdstream$options()
#> $output
#> [1] "stdout"
#> 
#> $export_interval
#> [1] 60000
#> 
#> $export_timeout
#> [1] 30000
#> 
```
