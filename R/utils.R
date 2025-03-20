`%||%` <- function(l, r) if (is.null(l)) r else l

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
