logger_provider_stdstream_new <- function(stream = NULL) {
  stream <- as_string(stream) %||%
    Sys.getenv(logger_provider_stdstream_output, "stdout")
  if (stream != "stdout" && stream != "stderr") {
    stream <- as_output_file(stream, null = FALSE)
  }
  self <- new_object(
    c("otel_logger_provider_stdstream", "otel_logger_provider"),
    get_logger = function(
      name = NULL,
      minimum_severity = "info",
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
      .Call(otel_logger_provider_flush, self$xptr)
    }
  )

  self$xptr <- .Call(otel_create_logger_provider_stdstream, stream)
  self
}

#' Logger provider to write to the standard output or standard error or
#' to a file
#' @export

logger_provider_stdstream <- list(
  new = logger_provider_stdstream_new
)
