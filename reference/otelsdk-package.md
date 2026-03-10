# otelsdk: R SDK and Exporters for OpenTelemetry

OpenTelemetry is a collection of tools, APIs, and SDKs used to
instrument, generate, collect, and export telemetry data (metrics, logs,
and traces) for analysis in order to understand your software's
performance and behavior. This package contains the OpenTelemetry SDK,
and exporters. Use this package to export traces, metrics, logs from
instrumented R code. Use the otel package to instrument your R code for
OpenTelemetry.

## Value

Not applicable.

## See also

Useful links:

- <https://otelsdk.r-lib.org>

- <https://github.com/r-lib/otelsdk>

- Report bugs at <https://github.com/r-lib/otelsdk/issues>

## Author

**Maintainer**: Gábor Csárdi <csardi.gabor@gmail.com>

Other contributors:

- Posit Software, PBC ([ROR](https://ror.org/03wc8by49)) \[copyright
  holder, funder\]

- opentelemetry-cpp authors \[contributor\]

## Examples

``` r
# Run your R script with OpenTelemetry tracing:
# OTEL_TRACER_EXPORTER=otlp R -f myapp.R
```
