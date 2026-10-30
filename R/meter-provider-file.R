# fmt: skip file

# safe start
meter_provider_file_new <- function(opts = NULL) {
  opts <- as_meter_provider_file_options(opts)

  self <- new_object(
    c("otel_meter_provider_file", "otel_meter_provider"),
    get_meter = function(
      name = NULL,
      version = NULL,
      schema_url = NULL,
      attributes = NULL,
      ...
    ) {
      tryCatch({                                                     # safe
        meter_new(self, name, version, schema_url, attributes, ...)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        noop_meter()                                                 # safe
      })                                                             # safe
    },
    flush = function() {
      tryCatch({                                                     # safe
        invisible(ccall(otel_meter_provider_flush, self$xptr, NULL))
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
        invisible(NULL)                                              # safe
      })                                                             # safe
    },
    shutdown = function() {
      tryCatch({                                                     # safe
        ccall(otel_meter_provider_shutdown, self$xptr, NULL)
      }, error = function(err) {                                     # safe
        errmsg("OpenTelemetry error: ", conditionMessage(err))       # safe
      })                                                             # safe
      invisible(self)
    }
  )

  self$xptr <- ccall(
    otel_create_meter_provider_file,
    opts[["export_interval"]],
    opts[["export_timeout"]],
    opts
  )
  self
}
# safe end

#' Meter provider to collect metrics in JSONL files
#'
#' @description
#' This is the [OTLP file exporter](
#'   https://opentelemetry.io/docs/specs/otel/protocol/file-exporter/).
#' It writes measurements to a JSONL file, each measurement is a line in
#' the file, a valid JSON value. The line separator is `\n`.
#' The preferred file extension is `jsonl`.
#'
#' Select this tracer provider with `OTEL_METRICS_EXPORTER=otlp/file`.
#'
#' Select `OTEL_METRICS_EXPORTER=otlp/stdout` to write to the standard
#' output instead of a file. This is the same as setting the `file_pattern`
#' option to `stdout`.
#'
#' # Usage
#'
#' Externally:
#' ```
#' OTEL_METRICS_EXPORTER=otlp/file
#' ```
#'
#' From R:
#' ```
#' meter_provider_file$new(opts = NULL)
#' meter_provider_file$options()
#' ```
#'
#' # Arguments
#'
#' - `opts`: Named list of options. See below.
#'
#' # Options
#'
#' ## File exporter options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_file_exporter_options(
#'   meter_provider_file_options_evs(),
#'   meter_provider_file$options()
#' ))
#' ```
#'
#' ## Metric reader options
#'
#' ```{r}
#' #| echo: FALSE
#' #| results: asis
#' cat(doc_metric_reader_options())
#' ```
#'
#' @return
#' `meter_provider_file$new()` returns an [otel::otel_meter_provider]
#' object.
#'
#' `meter_provider_file$options()` returns a named list, the current
#' values of the options.
#'
#' @format NULL
#' @usage NULL
#' @export
#' @examples
#' meter_provider_file$options()

meter_provider_file <- list(
  new = meter_provider_file_new,
  options = function() {
    utils::modifyList(
      as_meter_provider_file_options(NULL),
      ccall(otel_meter_provider_file_options_defaults)
    )
  }
)
