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
    for (nm in dev_function_names) {
      fn <- get(paste0(nm, "_dev"))
      assign(nm, fn, envir = envir)
      # exported objects, e.g. `tracer_provider_http$new()`
      obj <- sub("_new$", "", nm)
      if (exists(obj, envir = envir, inherits = FALSE)) {
        val <- get(obj, envir = envir, inherits = FALSE)
        if (is.list(val) && "new" %in% names(val)) {
          val[["new"]] <- fn
          assign(obj, val, envir = envir)
        }
      }
    }
  }
}
