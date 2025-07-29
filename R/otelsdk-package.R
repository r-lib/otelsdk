#' @keywords internal
#' @aliases otelsdk-package
#' @importFrom otel start_span
#' @return Not applicable.
#' @examples
#' # Run your R script with OpenTelemetry tracing:
#' # OTEL_TRACER_EXPORTER=otlp R -f myapp.R
"_PACKAGE"

#' @useDynLib otelsdk, .registration = TRUE
NULL
