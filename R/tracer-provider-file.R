# fmt: skip file

# safe start
tracer_provider_file_new <- function(opts = NULL) {
  opts <- as_tracer_provider_file_options(opts)

  self <- new_object(
    c("otel_tracer_provider_file", "otel_tracer_provider"),
    get_tracer = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      tryCatch({                                                     # safe
        tracer_new(self, name, version, schema_url, attributes, ...)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        noop_tracer()                                                # safe
      })                                                             # safe
    },
    flush = function() {
      tryCatch({                                                     # safe
        ccall(otel_tracer_provider_flush, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        invisible(NULL)                                              # safe
      })                                                             # safe
    },
    shutdown = function() {
      tryCatch({                                                     # safe
        ccall(otel_tracer_provider_shutdown, self$xptr)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_file, opts, attributes)
  self
}
# safe end

#' Tracer provider to write traces into a JSONL file
#'
#' @description
#' This is the [OTLP file exporter](
#'   https://opentelemetry.io/docs/specs/otel/protocol/file-exporter/).
#' It writes spans to a JSONL file, each span is a line in the file,
#' a valid JSON value. The line separator is `\n`. The preferred file
#' extension is `jsonl`.
#'
#' Select this tracer provider with `OTEL_TRACES_EXPORTER=otlp/file`.
#'
#' Select `OTEL_TRACES_EXPORTER=otlp/stdout` to write to the standard
#' output instead of a file. This is the same as setting the `file_pattern`
#' option to `stdout`.
#'
#' # Usage
#'
#' Externally:
#' ```
#' OTEL_TRACES_EXPORTER=otlp/file
#' ```
#'
#' From R:
#' ```
#' tracer_provider_file$new(opts = NULL)
#' tracer_provider_file$options()
#' ```
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Options
#'
#' ## File exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_file_exporter_options(
#'   tracer_provider_file_options_evs(),
#'   tracer_provider_file$options()
#' ))
#' ```
#'
#' @return
#' `tracer_provider_file$new()` returns an [otel::otel_tracer_provider]
#' object.
#'
#' `tracer_provider_file$options()` returns a named list, the current
#' values of the options.
#'
#' @format NULL
#' @usage NULL
#' @export
#' @examples
#' tracer_provider_file$options()

tracer_provider_file <- list(
  new = tracer_provider_file_new,
  options = function() {
    utils::modifyList(
      as_tracer_provider_file_options(NULL),
      ccall(otel_tracer_provider_file_options_defaults)
    )
  }
)
