the <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  the$span_kinds <- span_kinds
  the$span_status_codes <- span_status_codes
  the$default_resource_attributes <- default_resource_attributes()
  ccall(otel_init_constants, the)
  setup_dev_env()
}

setup_dev_env <- function(envir = asNamespace(.packageName)) {
  ev <- tolower(Sys.getenv("OTEL_ENV"))
  if (ev %in% c("dev", "devel", "development")) {
    assign("span_base_new", span_base_new_dev, envir = envir)
    assign("span_context_new", span_context_new_dev, envir = envir)
  }
}
