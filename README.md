
<!-- README.md is generated from README.Rmd. Please edit that file -->

# otelsdk

> OpenTelemetry SDK for R packages and projects

<!-- badges: start -->

![lifecycle](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)
[![R-CMD-check](https://github.com/r-lib/otelsdk/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/otelsdk/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/otelsdk/graph/badge.svg?token=GAqo3S38e7)](https://codecov.io/gh/r-lib/otelsdk)
<!-- badges: end -->

High-quality, ubiquitous, and portable telemetry to enable effective
observability. [OpenTelemetry](https://opentelemetry.io/docs/) is a
collection of tools, APIs, and SDKs used to instrument, generate,
collect, and export telemetry data (metrics, logs, and traces) for
analysis in order to understand your software’s performance and
behavior.

Use the [otel](https://github.com/r-lib/otel) package as a dependency if
you want to instrument your R package or project for OpenTelemetry.

Use this package (otelsdk) to produce OpenTelemetry output from an R
package or project that was instrumented with the otel package.

## Installation

> [!WARNING]
> This package is experimental and may introduce breaking
> changes any time. It probably works best with the latest commit of the
> [otel](https://github.com/r-lib/otel) package.

You can install the development version of otel from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("r-lib/otelsdk")
```

## Usage

- Instrument your R package or project using the
  [otel](https://github.com/r-lib/otel) package.
- Choose an exporter from the otelsdk package. The `http` exporter sends
  OpenTelemetry output through OTLP/HTTP.
- Set the `OTEL_TRACES_EXPORTER` environment variable to point to the
  exporter of your choice. E.g. for OTLP/HTTP set
  `OTEL_TRACES_EXPORTER=http`.
- Start R and your app. Telemetry data will be exported to the chosen
  exporter.

> [!TIP]
> If you have Docker, you can start a
> [Jaeger](https://www.jaegertracing.io/) container on the default port:
>
>     docker run --rm --name jaeger \
>      -p 16686:16686 \
>      -p 4317:4317 \
>      -p 4318:4318 \
>      -p 5778:5778 \
>      -p 9411:9411 \
>      jaegertracing/jaeger:2.4.0

## License

MIT © Posit, PBC
