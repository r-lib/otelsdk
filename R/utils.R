is_na <- function(x) {
  is.vector(x) && length(x) == 1 && is.na(x)
}

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

defer <- function(expr, envir = parent.frame()) {
  finalizer <- as.call(list(function() expr))
  do.call(base::on.exit, list(finalizer, TRUE, FALSE), envir = envir)
}
