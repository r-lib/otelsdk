the <- new.env(parent = emptyenv())
the$span_id_size <- NULL
the$trace_id_size <- NULL

span_id_size <- function() {
  the[["span_id_size"]] %||%
    (assign("span_id_size", .Call(otel_span_id_size), envir = the))
}

trace_id_size <- function() {
  the[["trace_id_size"]] %||%
    (assign("trace_id_size", .Call(otel_trace_id_size), envir = the))
}
