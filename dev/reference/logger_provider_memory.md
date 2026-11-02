# In-memory logger provider for testing

Collects log records in memory. This is useful for testing your
instrumented R package or application.

## Value

`logger_provider_memory$new()` returns an
[otel::otel_logger_provider](https://otel.r-lib.org/reference/otel_logger_provider.html)
object. `lp$get_logs()` returns an unnamed list of recorded log records,
in the order they were emitted. If the buffer is full, then the oldest
log records are dropped.

`logger_provider_memory$options()` returns a named list, the current
values for all options.

## Usage

    lp <- logger_provider_memory$new(opts = NULL)
    lp$get_logs()
    logger_provider_memory$options()

`lp$get_logs()` erases the internal buffer of the logger provider.

## Arguments

- `opts`: Named list of options. See below.

## Options

### Memory exporter options

- `buffer_size`: buffer size, this is the maximum number of spans or
  metrics measurements that the provider can record. Must be positive.
  Value is set from

  - the `opts` argument, or

  - the `OTEL_R_EXPORTER_MEMORY_LOGS_BUFFER_SIZE` environment variable,
    or

  - the `OTEL_R_EXPORTER_MEMORY_BUFFER_SIZE` environment variable, or

  - the default is `100`.

## Examples

``` r
logger_provider_memory$options()
#> $buffer_size
#> [1] 100
#> 
```
