# In-memory tracer provider for testing

Collects spans in memory. This is useful for testing your instrumented R
package or application.

[`with_otel_record()`](https://otelsdk.r-lib.org/dev/reference/with_otel_record.md)
uses this tracer provider. Use
[`with_otel_record()`](https://otelsdk.r-lib.org/dev/reference/with_otel_record.md)
in your tests to record telemetry and check that it is correct.

## Value

`tracer_provider_memory$new()` returns an
[otel::otel_tracer_provider](https://otel.r-lib.org/reference/otel_tracer_provider.html)
object. `tp$get_spans()` returns a named list of recorded spans, with
the span names as names.

`tracer_provider_memory$options()` returns a named list, the current
values for all options.

## Usage

    tp <- tracer_provider_memory$new(opts = NULL)
    tp$get_spans()
    tracer_provider_memory$options()

`tp$get_spans()` erases the internal buffer of the tracer provider.

## Arguments

- `opts`: Named list of options. See below.

## Options

### Memory exporter options

- `buffer_size`: buffer size, this is the maximum number of spans or
  metrics measurements that the provider can record. Must be positive.
  Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_MEMORY_TRACES_BUFFER_SIZE` environment
    variable, or

  - the `OTEL_R_EXPORTER_MEMORY_BUFFER_SIZE` environment variable, or

  - the default is `100`.

## Examples

``` r
tracer_provider_memory$options()
#> $buffer_size
#> [1] 100
#> 
```
