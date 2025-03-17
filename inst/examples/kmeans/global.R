Sys.setenv(OTEL_SERVICE_NAME = "kmeans-shiny-app")
tracer <- opentelemetry::setup_default_tracer("kmeans-shiny-app")
app_span <- tracer$start_span("app", scope = NULL)
onStop(function() {
  # tracer$finish_all_sessions() TODO
  app_span$end()
  rm(tracer, app_span, envir = globalenv())
})
