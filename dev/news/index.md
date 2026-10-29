# Changelog

## otelsdk (development version)

- The default alias pattern of the file exporters, used when only the
  file pattern is set, does not contain date and time placeholders any
  more. Previously a file pattern like `trace-%F-%T-%N.jsonl` created a
  new alias file for every output file
  ([\#70](https://github.com/r-lib/otelsdk/issues/70)).

- Setting the metric export interval or timeout, via the
  `OTEL_METRIC_EXPORT_INTERVAL` or `OTEL_METRIC_EXPORT_TIMEOUT`
  environment variables, or the `export_interval` or `export_timeout`
  options, does not fail any more
  ([\#79](https://github.com/r-lib/otelsdk/issues/79)).

- The `create_histogram()` method of meters now has a `boundaries`
  argument, to set explicit bucket boundaries for the histogram
  (r-lib/otel#49).

- Length one attribute values that are R arrays, e.g. created with
  [`as.array()`](https://rdrr.io/r/base/array.html), are now recorded as
  arrays, instead of scalars (r-lib/otel#48).

- Spans ended automatically, without an error, now keep the `unset`
  status, instead of being set to `ok` (r-lib/otel#30).

- Spans now have a `set_attributes()` method, to set multiple attributes
  at once (r-lib/otel#35).

- The span object returned by
  [`otel::get_active_span()`](https://otel.r-lib.org/reference/get_active_span.html)
  now has the correct span name in `$name`
  ([\#80](https://github.com/r-lib/otelsdk/issues/80)).

- The file tracer, logger and meter providers now write to the standard
  output or standard error if the `file_pattern` option is `stdout` or
  `stderr`. otel uses this for the `otlp/stdout` exporter
  (r-lib/otel#18).

- The `end_steady_time` option of the
  [`end()`](https://rdrr.io/r/stats/start.html) method of spans is now
  correctly used for the end time of the span.

- Documentation update for the new Otel 1.62.0 specification.

- otelsdk now bundles opentelemetry-cpp 1.30.0. Notable changes:

  - The default `schedule_delay` of the batch log processor is now 1000
    ms, instead of 5000 ms.
  - New trace IDs now have the W3C `random` trace flag set.

## otelsdk 0.2.4

CRAN release: 2026-04-08

- otel and otelsdk now support R 4.2.x on Windows.

## otelsdk 0.2.3

CRAN release: 2026-03-10

- otelsdk now compiles with older libprotobuf, e.g. on RHEL 8. It also
  handles it better when multiple versions of libprotobuf and protoc are
  available, by using `pkg-config` to find protobuf.

## otelsdk 0.2.2

CRAN release: 2025-10-07

- No user visible changes.

## otelsdk 0.2.1

CRAN release: 2025-09-23

- otelsdk now compiles on macOS if `cmake` was installed from the
  installer and is not on the `PATH`.

- Documentation update for the new Otel 1.49.0 specification. The new
  `OTEL_ENTITIES` environment variable is not supported yet.

## otelsdk 0.2.0

CRAN release: 2025-09-10

First release on CRAN.
