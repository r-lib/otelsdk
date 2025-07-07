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
#' @export

logger_provider_stdstream <- list(
  new = logger_provider_stdstream_new,
  options = logger_provider_stdstream_options
)
