#' @keywords internal
#' @aliases otelsdk-package
"_PACKAGE"

#' @useDynLib otelsdk, .registration = TRUE
NULL

dummy <- function() {
  otel::get_tracer
}
