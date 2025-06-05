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
  if ("attributes" %in% x$key) {
    x["attributes", ]$fmt <- format_attributes(x["attributes", ]$value[[1]])
  }
  lns <- paste0("    ", x$label, x$fmt)
  paste0(c("", lns), collapse = "\n")
}

format_attributes <- function(x) {
  opt <- options(width = getOption("width") - 9)
  on.exit(options(opt), add = TRUE)
  paste(
    collapse = "\n",
    c(
      "",
      unlist(mapply(names(x), x, FUN = function(n, x) {
        if (is_string(x)) {
          paste0("    ", format(n, width = 23), ": ", encodeString(x))
        } else {
          fmt <- utils::capture.output(print(x))
          c(
            paste0("    ", n, ":"),
            paste0("        ", fmt)
          )
        }
      }))
    )
  )
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
  if ("attributes" %in% x$key) {
    x["attributes", ]$fmt <-
      format_attributes(x["attributes", ]$value[[1]])
  }
  if ("resource_attributes" %in% x$key) {
    x["resource_attributes", ]$fmt <-
      format_attributes(x["resource_attributes", ]$value[[1]])
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
