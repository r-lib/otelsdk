otel_save_cache <- function() {
  asNamespace("otel")$otel_save_cache()
}

otel_restore_cache <- function(copy) {
  asNamespace("otel")$otel_restore_cache(copy)
}

#' Record OpenTelemetry output, for testing purposes
#'
#' You can use this function to test the OpenTelemetry output is
#' correctly generated for your package or application.
#'
#' It evaluates the supplied expression, collects OpenTelemetry output
#' from it and returns it.
#'
#' @param expr Expression to evaluate.
#' @param provider_args A list of arguments to pass to the in-memory
#'   OpenTelemetry trace provider.
#' @param what Character vector, type(s) of OpenTelemetry output to collect.
#'   Currently only `"traces"` is supported.
#' @return A list with the output for each output type. Currently only
#'   contains `traces`.
#'
#' @export

with_otel_record <- function(expr, provider_args = list(), what = c("traces")) {
  # save current otel cache, restore on exit
  copy <- otel_save_cache()
  on.exit(otel_restore_cache(copy), add = TRUE)

  # create new providers
  tmp <- new.env(parent = emptyenv())
  if ("traces" %in% what) {
    tmp[["tracer_provider"]] <- do.call(
      tracer_provider_memory_new,
      provider_args
    )
  }
  otel_restore_cache(tmp)

  # record
  expr

  # return recorded results
  list(traces = tmp[["tracer_provider"]]$get_spans())
}
