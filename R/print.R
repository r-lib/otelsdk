generic_print <- function(x, ...) {
  writeLines(format(x, ...))
  invisible(x)
}

generic_format <- function(x, ...) {
  cls <- class(x)[1]
  x <- data.frame(row.names = names(x), key = names(x), value = I(unclass(x)))
  x$label <- paste0(format(x$key), " : ")
  x$fmt <- lapply(x$value, format, ...)
  c(
    paste0("<", cls, ">"),
    unlist(mapply(x$label, x$fmt, FUN = function(l, v) {
      if (length(v) == 0) {
        l
      } else if (length(v) == 1) {
        paste0(l, v)
      } else {
        c(l, paste0("    ", v))
      }
    }))
  )
}

with_width <- function(expr, width = getOption("width") - 4L) {
  opt <- options(width = width)
  on.exit(options(opt), add = TRUE)
  expr
}

#' @export

format.otel_trace_flags <- function(x, ...) {
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

#' @export

format.otel_attributes <- function(x, ...) {
  x <- x[order(names(x))]
  nms <- paste0(format(names(x)), " : ")
  as.character(unlist(mapply(nms, x, FUN = function(n, x) {
    if (is.atomic(x) && length(x) == 1) {
      paste0(n, encodeString(as.character(x)))
    } else {
      c(n, paste0("    ", with_width(utils::capture.output(print(x)))))
    }
  })))
}

#' @export

format.otel_span_data <- generic_format

#' @export

print.otel_span_data <- generic_print

#' @export

format.otel_instrumentation_scope_data <- generic_format

#' @export

print.otel_instrumentation_scope_data <- generic_print

#' @export

format.otel_sum_point_data <- function(x, ...) {
  c(
    "<otel_sum_point_data>",
    paste0("value_type  : ", x[["value_type"]]),
    paste0("value       : ", x[["value"]]),
    paste0("is_monotonic: ", x[["is_monotonic"]])
  )
}

#' @export

print.otel_sum_point_data <- generic_print

#' @export

format.otel_histogram_point_data <- function(x, ...) {
  opt <- options(width = getOption("width") - 9)
  on.exit(options(opt), add = TRUE)
  c(
    "<otel_histogram_point_data>",
    paste0("value_type    : ", x[["value_type"]]),
    paste0("record_min_max: ", x[["record_min_max"]]),
    paste0("sum           : ", x[["sum"]]),
    paste0("min           : ", x[["min"]]),
    paste0("max           : ", x[["max"]]),
    paste0("count         : ", x[["count"]]),
    paste0("counts [", length(x[["counts"]]), "]:"),
    paste0("    ", utils::capture.output(print(x[["counts"]]))),
    paste0("boundaries [", length(x[["boundaries"]]), "]:"),
    paste0("    ", utils::capture.output(print(x[["boundaries"]])))
  )
}

#' @export

print.otel_histogram_point_data <- generic_print

#' @export

format.otel_last_value_point_data <- function(x, ...) {
  c(
    "<otel_last_value_point_data>",
    paste0("value_type        : ", x[["value_type"]]),
    paste0("value             : ", x[["value"]]),
    paste0("is_lastvalue_valid: ", x[["is_lastvalue_valid"]]),
    paste0("sample_ts         : ", x[["sample_ts"]])
  )
}

#' @export

print.otel_last_value_point_data <- generic_print

#' @export

format.otel_drop_point_data <- function(x, ...) {
  c(
    "<otel_drop_point_data>"
  )
}

#' @export

print.otel_drop_point_data <- generic_print

#' @export

format.otel_point_data_attributes <- generic_format

#' @export

print.otel_point_data_attributes <- generic_print

#' @export

format.otel_metric_data <- function(x, ...) {
  c(
    "<otel_metric_data>",
    paste0("instrument_name        : ", x[["instrument_name"]]),
    paste0("instrument_description : ", x[["instrument_description"]]),
    paste0("instrument_unit        : ", x[["instrument_unit"]]),
    paste0("instrument_type        : ", x[["instrument_type"]]),
    paste0("instrument_value_type  : ", x[["instrument_value_type"]]),
    paste0("aggregation_temporality: ", x[["aggregation_temporality"]]),
    paste0("start_time             : ", x[["start_time"]]),
    paste0("end_time               : ", x[["end_time"]]),
    paste0("point_data_attributes [", length(x[["point_data_attr"]]), "]:"),
    paste0("    ", unlist(lapply(x[["point_data_attr"]], format)))
  )
}

#' @export

print.otel_metric_data <- generic_print

#' @export

format.otel_scope_metrics <- function(x, ...) {
  c(
    "<otel_scope_metrics>",
    "instrumentation_scope:",
    paste0("    ", format(x[["instrumentation_scope"]])),
    paste0("metric_data [", length(x[["metric_data"]]), "]:"),
    paste0("    ", unlist(lapply(x[["metric_data"]], format)))
  )
}

#' @export

print.otel_scope_metrics <- generic_print

#' @export

format.otel_resource_metrics <- function(x, ...) {
  c(
    "<otel_resouce_metrics>",
    "attributes:",
    paste0("    ", format(x[["attributes"]])),
    paste0("scope_metric_data [", length(x[["scope_metric_data"]]), "]:"),
    paste0("    ", unlist(lapply(x[["scope_metric_data"]], format)))
  )
}

#' @export

print.otel_resource_metrics <- generic_print

#' @export

format.otel_metrics_data <- function(x, ...) {
  c(
    "<otel_metrics_data>",
    unlist(lapply(x, format, ...))
  )
}

#' @export

print.otel_metrics_data <- generic_print
