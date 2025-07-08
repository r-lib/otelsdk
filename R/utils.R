`%||%` <- function(l, r) if (is.null(l)) r else l

is_true <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x) && x
}

is_false <- function(x) {
  is.logical(x) && length(x) == 1L && !is.na(x) && !x
}

defer <- function(expr, envir = parent.frame()) {
  finalizer <- as.call(list(function() expr))
  do.call(base::on.exit, list(finalizer, TRUE, FALSE), envir = envir)
}

map_chr <- function(X, FUN, ...) {
  vapply(X, FUN, FUN.VALUE = character(1), ...)
}

map_lgl <- function(X, FUN, ...) {
  vapply(X, FUN, FUN.VALUE = logical(1), ...)
}

drop_nulls <- function(x) {
  x[!map_lgl(x, is.null)]
}

get_env <- function(n) {
  v <- Sys.getenv(n)
  if (v != "") v else NULL
}

get_current_error <- function() {
  fail <- NULL
  err <- tryCatch(
    suppressWarnings(ccall(otel_error_object)),
    error = function(e) {
      fail <<- e
      NULL
    }
  )

  if (!is.null(fail)) {
    # tried, but failed
    m <- paste("Could not get the error message.", conditionMessage(fail))
    list(tried = TRUE, success = FALSE, object = NULL, error = m)
  } else if (!err[[1]]) {
    # didn't (couldn't) try
    m <- paste(
      "This version of otelsdk cannot get error messages.",
      "Make sure that you are using the latest version."
    )
    list(tried = FALSE, success = NA, object = NULL, error = m)
  } else if (is.null(err[[2]])) {
    # tried, but did not find any errors.
    m <- paste(
      "Cannot find error message, this is possibly a bug in the otelsdk",
      "package. Make sure that you are using the latest version."
    )
    list(tried = TRUE, success = FALSE, object = NULL, error = m)
  } else {
    # all good
    list(tried = TRUE, success = TRUE, object = err[[2]], error = NULL)
  }
}

plural <- function(x) {
  if (x == 0 || x > 1) "s" else ""
}

find_instrumentation_scope <- function(name = NULL) {
  otel::default_tracer_name(name)
}

empty_atomic_as_null <- function(x) {
  if (is.atomic(x) && length(x) == 0) {
    NULL
  } else {
    x
  }
}
