logger_provider_http_new <- function() {
  self <- new_object(
    c("otel_logger_provider_http",
      "otel_logger_provider"),
    get_logger = function(name = NULL, ...) {
      logger_new(self, name, ...)
    },
    flush = function() {
      # noop currenrly
    }
  )

  self$xptr <- .Call(otel_create_logger_provider_http)
  self
}

#' Logger provider to log over HTTP
#' @export

logger_provider_http <- list(
  new = logger_provider_http_new
)
