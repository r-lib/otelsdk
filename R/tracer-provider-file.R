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
      tracer_new(self, name, version, schema_url, attributes, ...)
    },
    flush = function() {
      ccall(otel_tracer_provider_flush, self$xptr)
    }
  )

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_tracer_provider_file, opts, attributes)
  self
}

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
#' ```
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Value
#'
#' `tracer_provider_file$new()` returns an [otel::otel_tracer_provider]
#' object.
#'
#' # Options
#'
#' File exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' doc_file_exporter_options(
#'   tracer_provider_file_options_evs(),
#'   list(
#'     file_pattern = "trace-%N.jsonl",
#'     alias_pattern = "trace-latest.jsonl"
#'   )
#' )
#' ```
#'
#' @format NULL
#' @usage NULL
#' @export

tracer_provider_file <- list(
  new = tracer_provider_file_new,
  options = function() {
    utils::modifyList(
      as_tracer_provider_file_options(NULL),
      ccall(otel_tracer_provider_file_options_defaults)
    )
  }
)
