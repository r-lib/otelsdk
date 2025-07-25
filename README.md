
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

### Compiling from source

To compile otelsdk from source, you need to install the protobuf library
first:

-   On Windows install the correct version of
    [Rtools](https://cran.r-project.org/bin/windows/Rtools/).

-   On Linux install the appropriate package from your distribution.

-   On macOS, you can use CRAN’s [protobuf
    build](https://mac.r-project.org/bin/) or Homebrew. If you are using
    CRAN’s build, then you must uninstall or unlink Homebrew protobuf:

        brew unlink protobuf

## Usage

-   Instrument your R package or project using the
    [otel](https://github.com/r-lib/otel) package.

-   Choose an exporter from the otelsdk package. The `http` exporter
    sends OpenTelemetry output through OTLP/HTTP.

-   Set the `OTEL_TRACES_EXPORTER` environment variable to point to the
    exporter of your choice. E.g. for OTLP/HTTP set
    `OTEL_TRACES_EXPORTER=http`.

-   If you are sending telemetry data through HTTP, then you typically
    need to configure the URL of your OpenTelemetry collector, and you
    possibly also need to supply a token in an HTTP header, possibly
    some resource attributes. Follow the instructions of the provider of
    your collector. They typically don’t have instructions for R, but
    generic instructions about environment variables will work for the
    otelsdk R package. E.g. for [Grafana](https://grafana.com/) you need
    something like

        OTEL_EXPORTER_OTLP_PROTOCOL="http"
        OTEL_EXPORTER_OTLP_ENDPOINT="https://otlp-gateway-prod-eu-central-0.grafana.net/otlp" \
        OTEL_RESOURCE_ATTRIBUTES="service.name=<name-of-your-app>,service.namespace=<name-of-your-namespace>,deployment.environment=test"
        OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic%20<base64-encoded-token>"

    See more example below.

-   Start R and your app. Telemetry data will be exported to the chosen
    exporter.

### Setup for remote collectors

There are a lot of services that offer an OpenTelemetry collector for
tracers, logs and metrics, many of them supporting all three of them.
There are also local apps that work as a collector. We tried otelsdk
with the following ones:

#### [Grafana](https://grafana.com/)

Follow the
[documentation](https://grafana.com/docs/grafana-cloud/send-data/otlp/send-data-otlp/#manual-opentelemetry-setup-for-advanced-users).
Create an API token. You’ll need to use the Grafana instrance ID as your
username, and the token as the password in HTTP Basic auth. E.g. in R do
this to get the base64 encoded token. `instance-id` is a (currently
seven digit) number and a string with a `glc_` prefix.

``` r
openssl::base64_encode("<instance-id>:<api-token>")
```

Then use this encoded token to set the `Authorization` header:

    OTEL_EXPORTER_OTLP_PROTOCOL="http"
    OTEL_EXPORTER_OTLP_ENDPOINT="https://otlp-gateway-prod-eu-central-0.grafana.net/otlp" \
    OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic%20<base64-encoded-token>"
    OTEL_RESOURCE_ATTRIBUTES="service.name=<name-of-your-app,service.namespace=<name-of-your-namespace>,deployment.environment=test"

Your endpoint URL is probably different, use the one that you see on
your dashboard.

If you want to export logs and/or metrics, set these environment
variables, respectively:


    OTEL_LOGS_EXPORTER=http
    OTEL_LOG_LEVEL=debug
    OTEL_METRICS_EXPORTER=http

It also makes sense to set the desired log level.

Grafana suggests running an OpenTelemetry collector on premise instead
of sending telemetry data to them directly. But nevertheless you can
start out without running your own collector, they call this “quick
start” mode.

#### [Pydantic Logfire](https://pydantic.dev/logfire)

Create a project and a write token. Note that the URLs you need to use
are different if you are within the EU! You probably need to replace
`us` with `eu` in the URL if you are in the EU. Set these environment
variables:

    OTEL_TRACES_EXPORTER=http
    OTEL_EXPORTER_OTLP_ENDPOINT="https://logfire-us.pydantic.dev"
    OTEL_EXPORTER_OTLP_HEADERS="Authorization=<your-write-token>"

For logs also set `OTEL_LOGS_EXPORTER` and the desired log level:

    OTEL_LOGS_EXPORTER=http
    OTEL_LOG_LEVEL=debug

For exporting metrics also set

    OTEL_METRICS_EXPORTER=http

### Setup for local collectors

#### [otel-tui](https://github.com/ymtdzzz/otel-tui)

`otel-tui` is a terminal app that supports traces, logs and metrics. It
is great for development, as you can keep all your telemetry local while
instrumenting your package or app. Follow the installation instructions
and then run the app from a terminal:

    otel-tui

It listens on the default port, so the setup is very simple, set these
environment variables (or a subset if you don’t want metrics or logs):

    OTEL_TRACES_EXPORTER=http
    OTEL_LOGS_EXPORTER=http
    OTEL_LOG_LEVEL=debug
    OTEL_METRICS_EXPORTER=http

#### [otel-desktop-viewer](https://github.com/CtrlSpice/otel-desktop-viewer)

`otel-desktop-viewer` is similar to `otel-tui`, but has a web UI. Follow
the installation instructions and start the app from a terminal:

    otel-desktop-viewer

It should start a new windows or tab in your local web browser. Set the
usual environment variable for your R app:

    OTEL_TRACES_EXPORTER=http

#### [Jaeger](https://www.jaegertracing.io/)

If you have Docker, you can start a
[Jaeger](https://www.jaegertracing.io/) container on the default port:

    docker run --rm --name jaeger \
     -p 16686:16686 \
     -p 4317:4317 \
     -p 4318:4318 \
     -p 5778:5778 \
     -p 9411:9411 \
     jaegertracing/jaeger:2.4.0

Go to `http://localhost:16686/` to view the Jaeger UI.

#### [SigNoz](https://github.com/SigNoz/signoz)

To run SigNoz locally with Docker, clone the repository at
<https://github.com/SigNoz/signoz>:

    git clone --depth 1 https://github.com/SigNoz/signoz

and then run Docker Compose from the `deploy/docker/` subdirectory:

    cd deploy/docker
    docker compose up

Go to `http://localhost:8080` to see the SigNoz UI.

## License

MIT © Posit, PBC
