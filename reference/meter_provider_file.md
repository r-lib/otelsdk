# Meter provider to collect metrics in JSONL files

This is the [OTLP file
exporter](https://opentelemetry.io/docs/specs/otel/protocol/file-exporter/).
It writes measurements to a JSONL file, each measurement is a line in
the file, a valid JSON value. The line separator is `\n`. The preferred
file extension is `jsonl`.

Select this tracer provider with `OTEL_METRICS_EXPORTER=otlp/file`.

## Value

`meter_provider_file$new()` returns an
[otel::otel_meter_provider](https://otel.r-lib.org/reference/otel_meter_provider.html)
object.

`meter_provider_file$options()` returns a named list, the current values
of the options.

## Usage

Externally:

    OTEL_METRICS_EXPORTER=otlp/file

From R:

    meter_provider_file$new(opts = NULL)
    meter_provider_file$options()

## Arguments

- `opts`: Named list of options. See below.

## Options

### File exporter options

- `file_pattern`: Output file pattern. Value is set from:

  - `opts` argument, or

  - `OTEL_EXPORTER_OTLP_METRICS_FILE` environment variable, or

  - `OTEL_EXPORTER_OTLP_FILE` environment variable, or

  - the default is: `metrics-%N.jsonl`.

  May contain placeholders, see below.

- `alias_pattern`: The file which always point to the latest file. Value
  is set from:

  - `opts` argument, or

  - `OTEL_EXPORTER_OTLP_METRICS_FILE_ALIAS` environment variable, or

  - `OTEL_EXPORTER_OTLP_FILE_ALIAS environment variable`, or

  - the default is: `metrics-latest.jsonl`.

  May contain placeholders, see below.

- `flush_interval`: Interval to force flush output. A time interval
  specification, see [Time Interval
  Options](https://otelsdk.r-lib.org/reference/timeintervaloptions.md).
  Value is set from

  - `opts` argument, or

  - `OTEL_EXPORTER_OTLP_METRICS_FILE_FLUSH_INTERVAL` environment
    variable, or

  - `OTEL_EXPORTER_OTLP_FILE_FLUSH_INTERVAL` environment variable, or

  - the default is `30s`, thirty seconds.

- `flush_count`: Force flush output after every `flush_count` records.
  Value is set from

  - `opts` argument, or

  - `OTEL_EXPORTER_OTLP_METRICS_FILE_FLUSH_COUNT` environment variable,
    or

  - `OTEL_EXPORTER_OTLP_FILE_FLUSH_COUNT` environment variable, or

  - the default is `256`.

- `file_size`: File size to rotate output files. A file size
  specification, see [File Size
  Options](https://otelsdk.r-lib.org/reference/filesizeoptions.md).
  Value is set from

  - `opts` argument, or

  - `OTEL_EXPORTER_OTLP_METRICS_FILE_FILE_SIZE` environment variable, or

  - `OTEL_EXPORTER_OTLP_FILE_FILE_SIZE` environment variable, or

  - the default is `20MB`.

- `rotate_size`: How many rotated output files to keep. Value is set
  from

  - `opts` argument, or

  - `OTEL_EXPORTER_OTLP_METRICS_FILE_ROTATE_SIZE` environment variable,
    or

  - `OTEL_EXPORTER_OTLP_FILE_ROTATE_SIZE` environment variable, or

  - the default is `10`.

Special placeholders are available for `file_pattern` and
`alias_pattern`:

- `%Y`: Writes year as a 4 digit decimal number.

- `%y`: Writes last 2 digits of year as a decimal number (range
  `[00,99]`).

- `%m`: Writes month as a decimal number (range `[01,12]`).

- `%j`: Writes day of the year as a decimal number (range `[001,366]`).

- `%d`: Writes day of the month as a decimal number (range `[01,31]`).

- `%w`: Writes weekday as a decimal number, where Sunday is 0 (range
  `[0-6]`).

- `%H`: Writes hour as a decimal number, 24 hour clock (range
  `[00-23]`).

- `%I`: Writes hour as a decimal number, 12 hour clock (range
  `[01,12]`).

- `%M`: Writes minute as a decimal number (range `[00,59]`).

- `%S`: Writes second as a decimal number (range `[00,60]`).

- `%F`: Equivalent to `%Y-%m-%d` (the ISO 8601 date format).

- `%T`: Equivalent to `%H:%M:%S` (the ISO 8601 time format).

- `%R`: Equivalent to `%H:%M`.

- `%N`: Rotate index, start from 0.

- `%n`: Rotate index, start from 1.

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
meter_provider_file$options()
#> $export_interval
#> [1] 60000
#> 
#> $export_timeout
#> [1] 30000
#> 
#> $file_pattern
#> [1] "metrics-%N.jsonl"
#> 
#> $alias_pattern
#> [1] "metrics-latest.jsonl"
#> 
#> $flush_interval
#> [1] 30
#> 
#> $flush_count
#> [1] 256
#> 
#> $file_size
#> [1] 20971520
#> 
#> $rotate_size
#> [1] 10
#> 
```
