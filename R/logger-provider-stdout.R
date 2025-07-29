logger_provider_stdstream_new <- function(opts = NULL) {
  opts <- as_logger_provider_stdstream_options(opts)

  self <- new_object(
    c("otel_logger_provider_stdstream", "otel_logger_provider"),
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

  attributes <- as_otel_attributes(the$default_resource_attributes)
  self$xptr <- ccall(otel_create_logger_provider_stdstream, opts, attributes)
  self
}

logger_provider_stdstream_options <- function() {
  as_logger_provider_stdstream_options(NULL)
}

#' Logger provider to write to the standard output or standard error or
#' to a file
#'
#' @description
#' Writes logs to the standard output or error, or to a file. Useful for
#' debugging.
#'
#' # Usage
#'
#' Externally:
#' ```
#' OTEL_LOGS_EXPORTER=console
#' OTEL_LOGS_EXPORTER=stderr
#' ```
#'
#' From R:
#' ```
#' logger_provider_stdstream$new(opts = NULL)
#' logger_provider_stdstream$options()
#' ```
#'
#' # Arguments
#'
#' `opts`: Named list of options. See below.
#'
#' # Value
#'
#' `logger_provider_stdstream$new()` returns an [otel::otel_logger_provider]
#' object.
#'
#' `logger_provider_stdstream$options()` returns a named list, the current
#' values of the options.
#'
#' # Options
#'
#' ## Standard stream exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_stdstream_exporter_options(
#'   logger_provider_stdstream_options_evs()
#' ))
#' ```
#'
#' @format NULL
#' @usage NULL
#' @export

logger_provider_stdstream <- list(
  new = logger_provider_stdstream_new,
  options = logger_provider_stdstream_options
)
