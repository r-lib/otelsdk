is_na <- function(x) {
  is.vector(x) && length(x) == 1 && is.na(x)
}

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

is_named <- function(x) {
  nms <- names(x)
  length(x) == length(nms) && ! anyNA(nms) && all(nms != "")
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
  if (inherits(x, "otel_span")) {
    return(x)
  }

  call <- call %||% match.call()
  stop(
    "Invalid argument: ", call[[2]], " must be a span object ",
    "(`otel_span`), but it is ", typename(x), "."
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

as_string <- function(x, null = TRUE, call = NULL) {
  if (null & is.null(x)) return(x)
  if (is_string(x)) return(x)

  call <- call %||% match.call()
  stop(
    "Invalid argument: ", call[[2]], " must be a string scalar, but it is ",
    typename(x), "."
  )
}

span_attr_types <- c(typeof(""), typeof(TRUE), typeof(1), typeof(1L))

as_span_attributes <- function(attributes, call = NULL) {
  if ((is.list(attributes) || is.null(attributes)) &&
      is_named(attributes) &&
      all((tps <- map_chr(attributes, typeof)) %in% span_attr_types) &&
      all(!(hna <- map_lgl(attributes, anyNA)))) {
    return(attributes)
  }

  call <- call %||% match.call()
  if (!is.list(attributes)) {
    stop(
      "Invalid argument: ", call[[2]], " must be a named list, but it is ",
      typename(attributes), "."
    )
  }

  if (!is_named(attributes)) {
    stop(
      "Invalid argument: ", call[[2]], " must be a named list, but not ",
      "all of its entries are named."
    )
  }

  badtypes <- ! (tps %in% span_attr_types)
  if (any(badtypes)) {
    stop(
      "Invalid argument: ", call[[2]], " can only contain types ",
      paste(span_attr_types, collapse = ", "), ", but it contains ",
      paste(unique(tps[badtypes]), collapse = ", "), " types."
    )
  }

  stop(
    "Invalid argument: ", call[[2]], " its entries must not contain ",
    "missing (`NA`) values."
  )
}

as_span_links <- function(links) {
  # TODO
  links
}

as_span_options <- function(options) {
  options[["start_system_time"]] <-
    as_timestamp(options[["start_system_time"]])
  options[["start_steady_time"]] <-
    as_timestamp(options[["start_steady_time"]])
  options[["parent"]] <- as_span(options[["parent"]], na = TRUE)
  options[["kind"]] <- as_choice(options[["kind"]], span_kinds)
  options
}
