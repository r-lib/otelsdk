format_trace_flags <- function(x) {
  paste(
    collapse = " ",
    c(
      if (is_true(x["sampled"])) "+sampled",
      if (is_false(x["sampled"])) "-sampled",
      if (is_true(x["random"])) "+random",
      if (is_false(x["random"])) "-random"
    )
  )
}

format_instrumentation_scope <- function(x) {
  x <- data.frame(row.names = names(x), key = names(x), value = I(unclass(x)))
  x$label <- paste0(format(x$key), " : ")
  x$fmt <- format1(x$value)
  lns <- paste0("    ", x$label, x$fmt)
  paste0(c("", lns), collapse = "\n")
}

format1 <- function(x, ...) {
  vapply(lapply(x, format, ...), paste0, character(1), collapse = "\n")
}

#' @export

format.otel_span_data <- function(x, ...) {
  x <- data.frame(row.names = names(x), key = names(x), value = I(unclass(x)))
  x$label <- paste0(format(x$key), " : ")
  x$fmt <- format1(x$value)
  if ("flags" %in% x$key) {
    x["flags", ]$fmt <- format_trace_flags(x["flags", ]$value[[1]])
  }
  if ("instrumentation_scope" %in% x$key) {
    x["instrumentation_scope", ]$fmt <-
      format_instrumentation_scope(x["instrumentation_scope", ]$value[[1]])
  }
  c(
    "<otel_span_data>",
    paste0(x$label, x$fmt)
  )
}

#' @export

print.otel_span_data <- function(x, ...) {
  writeLines(format(x, ...))
  invisible(x)
}
