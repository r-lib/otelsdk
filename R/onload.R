the <- new.env(parent = emptyenv())

# nocov start
.onLoad <- function(libname, pkgname) {
  the$span_kinds <- span_kinds
  the$span_status_codes <- span_status_codes
  the$default_resource_attributes <- default_resource_attributes()
  ccall(otel_init_constants, the)
}
# nocov end
