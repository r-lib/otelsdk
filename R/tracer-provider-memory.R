tracer_provider_memory_new <- function(opts = NULL) {
  opts <- as_tracer_provider_memory_options(opts)
  self <- new_object(
    c("otel_tracer_provider_memory", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
      # noop currently
    },
    get_spans = function() {
      spans <- ccall(otel_tracer_provider_memory_get_spans, self$xptr)
      names(spans) <- map_chr(spans, function(x) x[["name"]] %||% "")
      spans
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_memory, opts, attributes)
  self
}

tracer_provider_memory_options <- function() {
  as_tracer_provider_memory_options(NULL)
}

#' In-memory tracer provider for testing
#'
#' @description
#' Collects spans in memory. This is useful for testing your instrumented
#' R package or application.
#'
#' [with_otel_record()] uses this tracer provider.
#' Use [with_otel_record()] in your tests to record telemetry and check
#' that it is correct.
#'
#' # Usage
#'
#' ```
#' tp <- tracer_provider_memory$new(opts = NULL)
#' tp$get_spans()
#' tracer_provider_memory$options()
#' ```
#'
#' `tp$get_spans()` erases the internal buffer of the tracer provider.
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Options
#'
#' ## Memory exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_memory_exporter_options(tracer_provider_memory_options_evs()))
#' ```
#'
#' @return
#' `tracer_provider_memory$new()` returns an [otel::otel_tracer_provider]
#' object. `tp$get_spans()` returns a named list of recorded spans, with
#' the span names as names.
#'
#' `tracer_provider_memory$options()` returns a named list, the current
#' values for all options.
#'
#' @usage NULL
#' @format NULL
#' @export
#' @examples
#' tracer_provider_memory$options()

tracer_provider_memory <- list(
  new = tracer_provider_memory_new,
  options = tracer_provider_memory_options
)
