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

# TODO: save this once at the beginning of the session, in C++ form
default_resource_attributes <- function() {
  # Attributes are not free, so we err on the side of parsimony as to what is
  # included by default.
  list(
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
}
