cnd <- function(
  ...,
  class = NULL,
  call = caller_env(),
  .envir = parent.frame()
) {
  call <- frame_get(call, sys.call)
  structure(
    list(message = glue(..., .envir = .envir), call = call),
    class = c(class, "error", "condition")
  )
}

caller_arg <- function(arg) {
  arg <- substitute(arg)
  expr <- do.call(substitute, list(arg), envir = caller_env())
  structure(list(expr), class = "otel_caller_arg")
}

as_caller_arg <- function(x) {
  structure(list(x), class = "otel_caller_arg")
}

as.character.otel_caller_arg <- function(x, ...) {
  lbl <- format(x[[1]])
  gsub("\n.*$", "...", lbl)
}

caller_env <- function(n = 1) {
  parent.frame(n + 1)
}

frame_get <- function(frame, accessor) {
  if (identical(frame, .GlobalEnv)) {
    return(NULL)
  }
  frames <- evalq(sys.frames(), frame)
  for (i in seq_along(frames)) {
    if (identical(frames[[i]], frame)) {
      return(accessor(i))
    }
  }
  NULL
}
