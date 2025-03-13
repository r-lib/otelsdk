Sys.setenv(OTEL_SERVICE_NAME = "kmeans-shiny-app")
tracer <- opentelemetry::setup_default_tracer("kmeans-shiny-app")
app_span <- tracer$start_span("app", parent = NULL, scope = NULL)
onStop(function() {
  app_span$end()
  rm(tracer, app_span, envir = globalenv())
})
