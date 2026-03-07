# Time Interval Options

otel and otelsdk accept time interval options in the following format:

- A [base::difftime](https://rdrr.io/r/base/difftime.html) object.

- A positive numeric scalar, interpreted as number of milliseconds. It
  may be fractional.

- A string scalar with a positive number and a time unit suffix.
  Possible time units: us (microseconds), ms (milliseconds), s
  (seconds), m (minutes), h (hours), d (days).

When the time interval is specified in an environment variable, it may
be:

- A positive number, interpreted as number of milliseconds. It may be
  fractional.

- A positive number with a time unit suffix. Possible time units: us
  (microseconds), ms (milliseconds), s (seconds), m (minutes), h
  (hours), d (days).

## Value

Not applicable.

## Examples

``` r
# Write pending telemetry data to the output file every 5 seconds:
# OTEL_EXPORTER_OTLP_FILE_FLUSH_INTERVAL=5s
```
