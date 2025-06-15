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
    "process.runtime.version" = as.character(getRversion()),
    "process.runtime.description" = R.version.string,
    # See: https://opentelemetry.io/docs/specs/semconv/resource/process/#process
    "process.pid" = Sys.getpid(),
    "process.owner" = Sys.info()['user'],
    # See: https://opentelemetry.io/docs/specs/semconv/resource/os/
    "os.type" = tolower(Sys.info()['sysname'])
  )
  the$span_kinds <- span_kinds
  the$span_status_codes <- span_status_codes
  ccall(otel_init_constants, the)
}

# Cannot get this from otel because an otel .onLoad might trigger an
# otelsdk load, and the otelsdk .onLoad cannot refer to a half-loaded
# otel in this case.

span_kinds <- c(
  default = "internal",
  "server",
  "client",
  "producer",
  "consumer"
)

span_status_codes <- c(default = "unset", "ok", "error")
