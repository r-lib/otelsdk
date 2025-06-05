the <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  # Attributes are not free, so we err on the side of parsimony as to what is
  # included by default.
  the$default_resource_attributes <- list(
    # See: https://opentelemetry.io/docs/specs/semconv/resource/#telemetry-sdk
    "telemetry.sdk.language" = "R",
    "telemetry.sdk.name" = "opentelemetry",
    "telemetry.sdk.version" = as.character(utils::packageVersion("otelsdk")),
    # See: https://opentelemetry.io/docs/specs/semconv/resource/process/#process-runtimes
    "process.runtime.name" = "R",
    "process.runtime.version" = paste0(R.version$major, ".", R.version$minor),
    "process.runtime.description" = R.version.string,
    # See: https://opentelemetry.io/docs/specs/semconv/resource/process/#process
    "process.pid" = Sys.getpid(),
    "process.owner" = Sys.info()['user'],
    # See: https://opentelemetry.io/docs/specs/semconv/resource/os/
    "os.type" = tolower(Sys.info()['sysname'])
  )
  the$span_kinds <- otel::span_kinds
  the$span_status_codes <- otel::span_status_codes
  .Call(otel_init_constants, the)
}
