#' Tracer provider to export over HTTP
#' @export

tracer_provider_http <- list(
  new = function() {
    self <- new_object(
      c("otel_tracer_provider_http",
        "otel_tracer_provider"),
      get_tracer = function(name, ...) {
        tracer$new(self, name, ...)
      }
    )

    self$xptr <- .Call(otel_create_tracer_provider_http)
    self
  },
  options = function() {
    .Call(otel_tracer_provider_http_options)
  }
)
