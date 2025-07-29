logger_provider_file_new <- function(opts = NULL) {
  opts <- as_logger_provider_file_options(opts)

  self <- new_object(
    c("otel_logger_provider_file", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      logger_new(
        self,
        name,
        minimum_severity,
        version,
        schema_url,
        attributes,
        ...
      )
    },
    flush = function() {
      ccall(otel_logger_provider_flush, self$xptr)
    }
  )

  self$xptr <- ccall(otel_create_logger_provider_file, opts)
  self
}

#' Logger provider to write log messages into a JSONL file.
#'
#' @description
#' This is the [OTLP file exporter](
#'   https://opentelemetry.io/docs/specs/otel/protocol/file-exporter/).
#' It writes logs to a JSONL file, each log is a line in the file,
#' a valid JSON value. The line separator is `\n`. The preferred file
#' extension is `jsonl`.
#'
#' Select this tracer provider with `OTEL_LOGS_EXPORTER=otlp/file`.
#'
#' # Usage
#'
#' Externally:
#' ```
#' OTEL_LOGS_EXPORTER=otlp/file
#' ```
#'
#' From R:
#' ```
#' logger_provider_file$new(opts = NULL)
#' logger_provider_file$options()
#' ```
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Value
#'
#' `logger_provider_file$new()` returns an [otel::otel_logger_provider]
#' object.
#'
#' `logger_provider_file$options()` returns a named list, the current
#' values of the options.
#'
#' # Options
#'
#' ## File exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_file_exporter_options(
#'   logger_provider_file_options_evs(),
#'   logger_provider_file$options()
#' ))
#' ```
#'
#' @format NULL
#' @usage NULL
#' @export

logger_provider_file <- list(
  new = logger_provider_file_new,
  options = function() {
    utils::modifyList(
      as_logger_provider_file_options(NULL),
      ccall(otel_logger_provider_file_options_defaults)
    )
  }
)
