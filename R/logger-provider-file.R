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
