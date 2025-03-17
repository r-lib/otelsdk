`%||%` <- function(l, r) if (is.null(l)) r else l

defer <- function(expr, envir = parent.frame()) {
  finalizer <- as.call(list(function() expr))
  do.call(base::on.exit, list(finalizer, TRUE, FALSE), envir = envir)
}
