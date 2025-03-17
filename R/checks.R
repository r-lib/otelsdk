is_na <- function(x) {
  is.vector(x) && length(x) == 1 && is.na(x)
}

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

as_timestamp <- function(x, null = TRUE, call = NULL) {
  if (null && is.null(x)) return(x)
  if (inherits(x, "POSIXt") && length(x) == 1 && !is.na(x)) {
    return(as.double(x))
  }
  if (is.numeric(x) && length(x) == 1 && !is.na(x)) {
    return(as.double(x))
  }

  call <- call %||% match.call()
  if (inherits(x, "POSIXt") && length(x) == 0) {
    stop(
      "Invalid argument: ", call[[2]], " must be a time stamp (`POSIXt` ",
      "scalar or numeric scalar), but it is an empty vector."
    )
  } else if (inherits(x, "POSIXt") && length(x) > 1) {
    stop(
      "Invalid argument: ", call[[2]], " must be a time stamp (`POSIXt` ",
      "scalar or numeric scalar), but it is too long."
    )
  } else if (inherits(x, "POSIXt") && length(x) == 1 && is.na(x)) {
    stop(
      "Invalid argument: ", call[[2]], " must be a time stamp (`POSIXt` ",
      "scalar or numeric scalar), but it is `NA`."
    )
  } else {
    stop(
      "Invalid argument: ", call[[2]], " must be a time stamp (`POSIXt` ",
      "scalar or numeric scalar), but it is ", typename(x), "."
    )
  }
}

as_span <- function(x, null = TRUE, na = TRUE, call = NULL) {
  if (null && is.null(x)) return(x)
  if (na && is_na(x)) return(NA)
  if (inherits(x, "opentelemetry_span")) {
    return(x)
  }

  call <- call %||% match.call()
  stop(
    "Invalid argument: ", call[[2]], " must be a span object ",
    "(`opentelemetry_span`), but it is ", typename(x), "."
  )
}

as_choice <- function(x, choices, null = TRUE, call = NULL) {
  if (null && is.null(x)) return(choices[["default"]])
  if (is_string(x) && x %in% choices) return(x)

  call <- call %||% match.call()
  cchoices <- paste(choices, collapse = ", ")
  if (is_string(x)) {
    stop(
      "Invalid argument: ", call[[2]], " must be one of ", cchoices,
      ", but it is ", x, "."
    )
  } else {
    stop(
      "Invalid argument: ", call[[2]], " must be a string scalar, one of ",
      cchoices, ", but it is ", typename(x), "."
    )
  }
}

as_env <- function(x, null = TRUE, call = NULL) {
  if (null && is.null(x)) return(x)
  if (is.environment(x)) return(x)

  call <- call %||% match.call()
  stop(
    "Invalid argument: ", call[[2]], " must be an environment, but it is ",
    typename(x), "."
  )
}
