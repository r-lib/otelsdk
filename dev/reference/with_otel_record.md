# Record OpenTelemetry output, for testing purposes

You can use this function to test that OpenTelemetry output is correctly
generated for your package or application.

## Usage

``` r
with_otel_record(
  expr,
  what = c("traces", "metrics"),
  tracer_opts = list(),
  meter_opts = list()
)
```

## Arguments

- expr:

  Expression to evaluate.

- what:

  Character vector, type(s) of OpenTelemetry output to collect.

- tracer_opts:

  Named list of options to pass to the tracer provider.

- meter_opts:

  Named list of options to pass to the meter provider.

## Value

A list with the output for each output type. Entries:

- `value`: value of `expr`.

- `traces`: the recorded spans, if requested in `what`.

- `metrics`: the recorded metrics measurements, if requested in `what`.

## Details

It evaluates the supplied expression, collects OpenTelemetry output from
it and returns it.

Note: `with_otel_record()` cannot record logs yet.

`with_otel_record()` uses
[tracer_provider_memory](https://otelsdk.r-lib.org/dev/reference/tracer_provider_memory.md)
and
[meter_provider_memory](https://otelsdk.r-lib.org/dev/reference/meter_provider_memory.md)
internally.

## Examples

``` r
spns <- with_otel_record({
  trc <- otel::get_tracer("mytracer")
  spn1 <- trc$start_local_active_span()
  spn2 <- trc$start_local_active_span("my")
  spn2$end()
  spn1$end()
  NULL
})
spns
#> $value
#> NULL
#> 
#> $traces
#> $traces$my
#> <otel_span_data>
#> trace_id              : d309cc59b108bf4106b2901cee81d674
#> span_id               : 74e9d2f6a4abbcdb
#> name                  : my
#> flags                 : +sampled -random
#> parent                : 1f9443000a8ee8c5
#> description           : 
#> resource_attributes   : 
#>     os.type                     : linux
#>     process.owner               : runner
#>     process.pid                 : 8512
#>     process.runtime.description : R version 4.5.2 (2025-10-31)
#>     process.runtime.name        : R
#>     process.runtime.version     : 4.5.2
#>     service.name                : unknown_service
#>     telemetry.sdk.language      : R
#>     telemetry.sdk.name          : opentelemetry
#>     telemetry.sdk.version       : 0.2.2.9000
#> schema_url            : 
#> instrumentation_scope : 
#>     <otel_instrumentation_scope_data>
#>     name       : mytracer
#>     version    : 
#>     schema_url : 
#>     attributes : 
#> kind                  : internal
#> status                : unset
#> start_time            : 2026-03-07 20:32:46
#> duration              : 0.000166302
#> attributes            : 
#> events                : 
#> links                 : 
#> 
#> $traces$`<NA>`
#> <otel_span_data>
#> trace_id              : d309cc59b108bf4106b2901cee81d674
#> span_id               : 1f9443000a8ee8c5
#> name                  : <NA>
#> flags                 : +sampled -random
#> parent                : 0000000000000000
#> description           : 
#> resource_attributes   : 
#>     os.type                     : linux
#>     process.owner               : runner
#>     process.pid                 : 8512
#>     process.runtime.description : R version 4.5.2 (2025-10-31)
#>     process.runtime.name        : R
#>     process.runtime.version     : 4.5.2
#>     service.name                : unknown_service
#>     telemetry.sdk.language      : R
#>     telemetry.sdk.name          : opentelemetry
#>     telemetry.sdk.version       : 0.2.2.9000
#> schema_url            : 
#> instrumentation_scope : 
#>     <otel_instrumentation_scope_data>
#>     name       : mytracer
#>     version    : 
#>     schema_url : 
#>     attributes : 
#> kind                  : internal
#> status                : unset
#> start_time            : 2026-03-07 20:32:46
#> duration              : 0.000615413
#> attributes            : 
#> events                : 
#> links                 : 
#> 
#> 
#> $metrics
#> <otel_metrics_data>
#> <otel_resouce_metrics>
#> attributes:
#>     os.type                     : linux
#>     process.owner               : runner
#>     process.pid                 : 8512
#>     process.runtime.description : R version 4.5.2 (2025-10-31)
#>     process.runtime.name        : R
#>     process.runtime.version     : 4.5.2
#>     service.name                : unknown_service
#>     telemetry.sdk.language      : R
#>     telemetry.sdk.name          : opentelemetry
#>     telemetry.sdk.version       : 0.2.2.9000
#> scope_metric_data [0]:
#>     
#> 
```
