# Package index

## Other Documentation

This is the reference manual of the otelsdk package. Other forms of
documentation:

- [Getting
  Started](https://otel.r-lib.org/reference/gettingstarted.html), a
  tutorial and cookbook for instrumentation.
- [Collecting telemetry
  data](https://otelsdk.r-lib.org/dev/reference/collecting.md), a
  tutorial and cookbook on telemetry data collection.

## Configuration

- [`Environment Variables`](https://otelsdk.r-lib.org/dev/reference/environmentvariables.md)
  : Environment variables to configure otelsdk
- [`Time Interval Options`](https://otelsdk.r-lib.org/dev/reference/timeintervaloptions.md)
  : Time Interval Options
- [`File Size Options`](https://otelsdk.r-lib.org/dev/reference/filesizeoptions.md)
  : File Size Options

## Traces

- [`tracer_provider_file`](https://otelsdk.r-lib.org/dev/reference/tracer_provider_file.md)
  : Tracer provider to write traces into a JSONL file
- [`tracer_provider_http`](https://otelsdk.r-lib.org/dev/reference/tracer_provider_http.md)
  : Tracer provider to export traces over HTTP
- [`tracer_provider_memory`](https://otelsdk.r-lib.org/dev/reference/tracer_provider_memory.md)
  : In-memory tracer provider for testing
- [`tracer_provider_stdstream`](https://otelsdk.r-lib.org/dev/reference/tracer_provider_stdstream.md)
  : Tracer provider to write to the standard output or standard error or
  to a file

## Logs

- [`logger_provider_file`](https://otelsdk.r-lib.org/dev/reference/logger_provider_file.md)
  : Logger provider to write log messages into a JSONL file.
- [`logger_provider_http`](https://otelsdk.r-lib.org/dev/reference/logger_provider_http.md)
  : Logger provider to log over HTTP
- [`logger_provider_stdstream`](https://otelsdk.r-lib.org/dev/reference/logger_provider_stdstream.md)
  : Logger provider to write to the standard output or standard error or
  to a file

## Metrics

- [`meter_provider_file`](https://otelsdk.r-lib.org/dev/reference/meter_provider_file.md)
  : Meter provider to collect metrics in JSONL files
- [`meter_provider_http`](https://otelsdk.r-lib.org/dev/reference/meter_provider_http.md)
  : Meter provider to send collected metrics over HTTP
- [`meter_provider_memory`](https://otelsdk.r-lib.org/dev/reference/meter_provider_memory.md)
  : In-memory meter provider for testing
- [`meter_provider_stdstream`](https://otelsdk.r-lib.org/dev/reference/meter_provider_stdstream.md)
  : Meter provider to write to the standard output or standard error or
  to a file

## Utility functions

- [`with_otel_record()`](https://otelsdk.r-lib.org/dev/reference/with_otel_record.md)
  : Record OpenTelemetry output, for testing purposes
