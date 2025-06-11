generic_print <- function(x, ...) {
  writeLines(format(x, ...))
  invisible(x)
}

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

print.otel_span_data <- generic_print

#' @export

format.otel_instrumentation_scope_data <- function(x, ...) {
  c(
    "<otel_instrumentation_scope_data>",
    paste0("name:       ", x$name),
    paste0("version:    ", x$version),
    paste0("schema_url: ", x$schema_url)
  )
}

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

format.otel_point_data_attributes <- function(x, ...) {
  c(
    "<otel_point_data_attributes>",
    paste0("attributes: ", format_attributes(x[["attributes"]])),
    paste0("point_type: ", x[["point_type"]]),
    format(x[["value"]])
  )
}

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
    paste0("attributes:", format_attributes(x[["attributes"]])),
    paste0("scope_metric_data [", length(x[["scope_metric_data"]]), "]:"),
    paste0("    ", unlist(lapply(x[["scope_metric_data"]], format)))
  )
}

#' @export

print.otel_resource_metrics <- generic_print
