# Tracer provider to write to the standard output or standard error or to a file

Writes spans to the standard output or error, or to a file. Useful for
debugging.

## Value

`tracer_provider_stdstream$new()` returns an
[otel::otel_tracer_provider](https://otel.r-lib.org/reference/otel_tracer_provider.html)
object.

`tracer_provider_stdstream$options()` returns a named list, the current
values of the options.

## Usage

Externally:

    OTEL_TRACES_EXPORTER=console
    OTEL_TRACES_EXPORTER=stderr

From R:

    tracer_provider_stdstream$new(opts = NULL)
    tracer_provider_stdstream$options()

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

  - the `OTEL_R_EXPORTER_STDSTREAM_TRACES_OUTPUT` environment variable,
    or

  - the `OTEL_R_EXPORTER_STDSTREAM_OUTPUT` environment variable, or

  - the default is `"stdout"`.

## Examples

``` r
tracer_provider_stdstream$options()
#> $output
#> [1] "stdout"
#> 
```
