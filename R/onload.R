the <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  the$span_kinds <- otel::span_kinds
  the$span_status_codes <- otel::span_status_codes
  .Call(otel_init_constants, the)
}
