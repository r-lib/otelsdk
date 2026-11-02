# Span processor example Shiny app

This app shows how to add attributes to the spans that Shiny creates,
without changing Shiny or the code that creates the spans. It uses
`otelsdk::add_span_processor()` to add two attributes to every span that
starts inside a Shiny session:

* `app.user`: the value of `session$user`, or `"anonymous"` if it is not
  set. `session$user` is set by Posit Connect and Shiny Server Pro, so
  you'll see `"anonymous"` when you run the app locally.
* `app.session.token`: the value of `session$token`, which is different
  for each browser session.

You can use these attributes to filter spans in your tracing backend,
e.g. to find all the spans of one user.

## Requirements

* Shiny 1.12.0 or later. This is the first version that creates
  OpenTelemetry spans.
* otel and otelsdk.

## Running the app

Write the spans to the standard error of the R process:

```sh
OTEL_TRACES_EXPORTER=stderr \
  R -q -e 'shiny::runApp(system.file(package = "otelsdk", "examples", "shiny-span-processor"))'
```

Or send them to an OTLP collector, e.g. a local Jaeger instance:

```sh
OTEL_TRACES_EXPORTER=otlp OTEL_SERVICE_NAME=span-processor-example \
  R -q -e 'shiny::runApp(system.file(package = "otelsdk", "examples", "shiny-span-processor"))'
```

Open the app in a browser, move the slider and click "Resample". The
`observe`, `reactive` and `output` spans have the `app.user` and
`app.session.token` attributes.

Spans that start when there is no current Shiny session do not get these
attributes, because `getDefaultReactiveDomain()` returns `NULL` there.

## Setting up the span processor from a package

You don't need to change the app code if you put the span processor in a
package. Define a named list of callbacks in the package and export it:

```r
#' @export
span_processor <- list(
  on_start = function(span, info) {
    session <- shiny::getDefaultReactiveDomain()
    if (is.null(session)) {
      return()
    }
    user <- if (is.null(session$user)) "anonymous" else session$user
    span$set_attribute("app.user", user)
  }
)
```

Then set the `OTEL_R_SPAN_PROCESSORS` environment variable when you start
the app:

```sh
OTEL_TRACES_EXPORTER=stderr OTEL_R_SPAN_PROCESSORS=mypkg::span_processor \
  R -q -e 'shiny::runApp("path/to/app")'
```

See `?otelsdk::add_span_processor` for details.
