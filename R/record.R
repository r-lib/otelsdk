otel_save_cache <- function() {
  asNamespace("otel")$otel_save_cache()
}

otel_restore_cache <- function(copy) {
  asNamespace("otel")$otel_restore_cache(copy)
}

#' Record OpenTelemetry output, for testing purposes
#'
#' You can use this function to test that OpenTelemetry output is
#' correctly generated for your package or application.
#'
#' It evaluates the supplied expression, collects OpenTelemetry output
#' from it and returns it.
#'
#' Note: `with_otel_record()` cannot record logs yet.
#'
#' `with_otel_record()` uses [tracer_provider_memory] and
#' [meter_provider_memory] internally.
#'
#' @param expr Expression to evaluate.
#' @param what Character vector, type(s) of OpenTelemetry output to collect.
#' @param tracer_opts Named list of options to pass to the tracer provider.
#' @param meter_opts Named list of options to pass to the meter provider.
#' @return A list with the output for each output type. Entries:
#'   * `value`: value of `expr`.
#'   * `traces`: the recorded spans, if requested in `what`.
#'   * `metrics`: the recorded metrics measurements, if requested in `what`.
#'
#' @export
#' @examples
#' spns <- with_otel_record({
#'   trc <- otel::get_tracer("mytracer")
#'   spn1 <- trc$start_local_active_span()
#'   spn2 <- trc$start_local_active_span("my")
#'   spn2$end()
#'   spn1$end()
#'   NULL
#' })
#' spns

with_otel_record <- function(
  expr,
  what = c("traces", "metrics"),
  tracer_opts = list(),
  meter_opts = list()
) {
  # save current otel cache, restore on exit
  copy <- otel_save_cache()
  on.exit(otel_restore_cache(copy), add = TRUE)

  # create new providers
  tmp <- new.env(parent = emptyenv())
  if ("traces" %in% what) {
    tmp[["tracer_provider"]] <- tracer_provider_memory_new(tracer_opts)
  }
  if ("metrics" %in% what) {
    tmp[["meter_provider"]] <- meter_provider_memory_new(meter_opts)
    on.exit(tmp[["meter_provider"]]$shutdown(), add = TRUE)
  }
  otel_restore_cache(tmp)

  # record
  if (is.function(value <- expr)) {
    value <- value()
  }

  # return recorded results
  list(
    value = value,
    traces = if ("traces" %in% what) {
      tmp[["tracer_provider"]]$get_spans()
    },
    metrics = if ("metrics" %in% what) {
      tmp[["meter_provider"]]$get_metrics()
    }
  )
}
