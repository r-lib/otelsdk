#' Tracer provider to write to the standard output or standard error
#' @export

tracer_provider_stdstream <- list(
  new = function(stream = c("stdout", "stderr")) {
    stream <- match.arg(stream)
    self <- new_object(
      c("opentelemetry_tracer_provider_stdstream",
        "opentelemetry_tracer_provider"),
      get_tracer = function(name, ...) {
        tracer$new(self, name, ...)
      }
    )

    self$xptr <- .Call(otel_create_tracer_provider_stdstream, stream)
    self
  }
)
