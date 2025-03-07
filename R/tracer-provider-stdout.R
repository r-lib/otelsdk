#' Tracer provider to write to the standard output
#' @export

tracer_provider_stdout <- list(
  new = function() {
    self <- new_object(
      c("opentelemetry_tracer_provider_stdout",
        "opentelemetry_tracer_provider"),
      get_tracer = function(name, ...) {
        tracer$new(self, name, ...)
      }
    )

    self$xptr <- .Call(otel_create_tracer_provider_stdout)
    self
  }
)
