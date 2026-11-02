# Add or remove a span processor

A span processor is a set of callbacks that otelsdk calls for every
span, no matter which package or function created it. You can use a span
processor to add attributes to spans that are created by code you do not
control, e.g. to add the current user to every span that Shiny creates.

## Usage

``` r
add_span_processor(on_start = NULL, ..., id = NULL)

remove_span_processor(id)
```

## Arguments

- on_start:

  Function to call when a span starts, or `NULL`. See details below.

- ...:

  Reserved for more callbacks in the future. Must be empty.

- id:

  Id of the span processor, a string. For `add_span_processor()` it may
  be `NULL`, then a new id is generated. If a span processor with the
  same id already exists, it is replaced. For `remove_span_processor()`
  it is the id returned by `add_span_processor()`.

## Value

`add_span_processor()` returns the id of the span processor, invisibly.
`remove_span_processor()` returns `TRUE` if the span processor was
removed and `FALSE` if there was no span processor with this id,
invisibly.

## Details

Span processors are part of the OpenTelemetry SDK, not the API, so they
are meant to be set up by whoever configures the telemetry output of an
app, not by the authors of instrumented packages.

Span processors are global: they apply to the spans of all tracer
providers.

Currently span processors only support an `on_start` callback.

### `on_start`

The `on_start` callback is called right after a span has started, for
every span that is recording. It is called with two arguments:

- `span`: the new span, an `otel_span` object. You can call its methods,
  e.g. `span$set_attribute()` or `span$set_attributes()`.

- `info`: a named list with more information about the span:

  - `name`: span name.

  - `tracer_name`: name of the tracer that created the span. This is
    usually the name of the instrumented package.

  - `kind`: span kind, a string.

  - `parent`: the `parent` span option, if it was set explicitly when
    starting the span, or `NULL`.

The return value of `on_start` is ignored.

If a callback fails, otelsdk emits an `otel_error_message` message, and
continues with the next span processor. The span is still created. Set
the `OTEL_ENV=dev` environment variable to get errors instead.

If a callback starts a new span, span processors are not called for that
span.

### Setting up span processors from an environment variable

Use the `OTEL_R_SPAN_PROCESSORS` environment variable to set up span
processors that are defined in packages, without changing the code of
the app. It is a comma separated list of `pkg::name` entries. Each entry
must refer to a named list of callbacks, e.g.:

    span_processor <- list(
      on_start = function(span, info) {
        span$set_attribute("deployment.region", "eu-west-1")
      }
    )

and then

    OTEL_R_SPAN_PROCESSORS=mypkg::span_processor

otelsdk reads `OTEL_R_SPAN_PROCESSORS` when the first span is started.
The id of these span processors is `env:` followed by the entry, e.g.
`env:mypkg::span_processor`.

If the list has callbacks that this version of otelsdk does not support,
otelsdk ignores them with a message, and uses the rest of the span
processor. This way a package can define callbacks for newer otelsdk
versions and still work with older ones.

### Example Shiny app

This span processor adds the user and the session token to every span
that starts inside a Shiny session:

    # Add the Shiny user and session token to every span that Shiny creates
    # for this app. See README.md in this directory for how to run it.

    library(shiny)

    otelsdk::add_span_processor(
      id = "shiny-session",
      on_start = function(span, info) {
        session <- shiny::getDefaultReactiveDomain()
        if (is.null(session)) {
          return()
        }
        user <- if (is.null(session$user)) "anonymous" else session$user
        span$set_attribute("app.user", user)
        span$set_attribute("app.session.token", session$token)
      }
    )

    ui <- fluidPage(
      titlePanel("Span processor example"),
    ...

See the full example app, with instructions for running it, in the
`examples/shiny-span-processor` directory of the installed otelsdk
package:

    system.file(package = "otelsdk", "examples", "shiny-span-processor")

## Examples

``` r
id <- add_span_processor(
  on_start = function(span, info) {
    span$set_attribute("tracer", info$tracer_name)
  }
)
spns <- with_otel_record({
  trc <- otel::get_tracer("mytracer")
  spn <- trc$start_local_active_span("myspan")
  spn$end()
})
spns$traces$myspan$attributes
#> $tracer
#> [1] "mytracer"
#> 
#> attr(,"class")
#> [1] "otel_attributes"
remove_span_processor(id)
```
