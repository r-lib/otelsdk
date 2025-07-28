#' @keywords internal
#' @aliases otelsdk-package
#' @importFrom otel start_span
"_PACKAGE"

#' @useDynLib otelsdk, .registration = TRUE
NULL

dummy <- function() {
  otel::get_tracer
}
