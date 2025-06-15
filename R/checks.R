is_na <- function(x) {
  is.vector(x) && length(x) == 1 && is.na(x)
}

is_string <- function(x, na = FALSE) {
  if (na) {
    is.character(x) && length(x) == 1
  } else {
    is.character(x) && length(x) == 1 && !is.na(x)
  }
}

is_flag <- function(x) {
  is.logical(x) && length(x) == 1 && !is.na(x)
}

is_named <- function(x) {
  nms <- names(x)
  length(x) == length(nms) && !anyNA(nms) && all(nms != "")
}

as_timestamp <- function(x, null = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  if (inherits(x, "POSIXt") && length(x) == 1 && !is.na(x)) {
    return(as.double(x))
  }
  if (is.numeric(x) && length(x) == 1 && !is.na(x)) {
    return(as.double(x))
  }

  call <- call %||% match.call()
  if (inherits(x, "POSIXt") && length(x) == 0) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a time stamp ",
      "(`POSIXt` scalar or numeric scalar), but it is an empty vector."
    )))
  } else if (inherits(x, "POSIXt") && length(x) > 1) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a time stamp ",
      "(`POSIXt` scalar or numeric scalar), but it is too long."
    )))
  } else if (inherits(x, "POSIXt") && length(x) == 1 && is.na(x)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a time stamp ",
      "(`POSIXt` scalar or numeric scalar), but it is `NA`."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a time stamp ",
      "(`POSIXt` scalar or numeric scalar), but it is {typename(x)}."
    )))
  }
}

as_span <- function(x, null = TRUE, na = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  if (na && is_na(x)) {
    return(NA)
  }
  if (inherits(x, "otel_span")) {
    return(x)
  }

  call <- call %||% match.call()
  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must be a span object ",
    "(`otel_span`), but it is {typename(x)}."
  )))
}

as_span_context <- function(x, null = TRUE, na = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  if (na && is_na(x)) {
    return(x)
  }
  if (inherits(x, "otel_span_context")) {
    return(x)
  }

  call <- call %||% match.call()
  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must be a span context object ",
    "(`otel_span_context`), but it is {typename(x)}."
  )))
}

as_span_parent <- function(x, null = TRUE, na = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  if (na && is_na(x)) {
    return(NA)
  }
  if (inherits(x, "otel_span")) {
    return(x$get_context()$xptr)
  } else if (inherits(x, "otel_span_context")) {
    return(x$xptr)
  }

  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must be a span (`otel_span`) ",
    "or a span context (`otel_span_context`) object but it is {typename(x)}."
  )))
}

as_choice <- function(x, choices, null = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(match("default", names(choices)) - 1L)
  }
  if (is_string(x) && !is.na(mch <- match(tolower(x), choices))) {
    return(mch - 1L)
  }

  call <- call %||% match.call()
  cchoices <- paste(choices, collapse = ", ")
  if (is_string(x)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be one of {cchoices}, ",
      "but it is {x}."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a string scalar, one ",
      "of {cchoices}, but it is {typename(x)}."
    )))
  }
}

as_env <- function(x, null = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  if (is.environment(x)) {
    return(x)
  }

  call <- call %||% match.call()
  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must be an environment, ",
    "but it is {typename(x)}."
  )))
}

as_string <- function(x, null = TRUE, call = NULL) {
  if (null & is.null(x)) {
    return(x)
  }
  if (is_string(x)) {
    return(x)
  }

  call <- call %||% match.call()
  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must be a string scalar, ",
    "but it is {typename(x)}."
  )))
}

as_flag <- function(x, call = NULL) {
  if (is_flag(x)) {
    return(x)
  }

  call <- call %||% match.call()
  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must a flag (logical scalar), ",
    "but it is {typename(x)}."
  )))
}

span_attr_types <- c(typeof(""), typeof(TRUE), typeof(1), typeof(1L))

as_otel_attribute_value <- function(x, call = NULL) {
  if (typeof(x) %in% span_attr_types && !(hna <- anyNA(x))) {
    return(x)
  }

  call <- call %||% match.call()
  if (!typeof(x) %in% span_attr_types) {
    ctypes <- collapse(span_attr_types, last = ", or ")
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be of type {ctypes}, ",
      "but it is {typename(x)}."
    )))
  }
  if (hna) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must not contain missing ",
      "(`NA`) values."
    )))
  }
}

as_otel_attributes <- function(attributes, call = NULL) {
  if (
    (is.list(attributes) || is.null(attributes)) &&
      is_named(attributes) &&
      all((tps <- map_chr(attributes, typeof)) %in% span_attr_types) &&
      all(!(hna <- map_lgl(attributes, anyNA)))
  ) {
    return(attributes)
  }

  call <- call %||% match.call()
  if (!is.list(attributes)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a named list, ",
      "but it is {typename(attributes)}."
    )))
  }

  if (!is_named(attributes)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a named list, but not ",
      "all of its entries are named."
    )))
  }

  badtypes <- !(tps %in% span_attr_types)
  if (any(badtypes)) {
    ok <- collapse(span_attr_types)
    bd <- collapse(unique(tps[badtypes]))
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} can only contain types ",
      "{ok}, but it contains {bd} types."
    )))
  }

  stop(glue(c(
    "Invalid argument: the entries of {format(call[[2]])} must not ",
    "contain missing (`NA`) values."
  )))
}

as_span_link <- function(link, call = NULL) {
  if (inherits(link, "otel_span")) {
    return(list(link$xptr, list()))
  }
  call <- call %||% match.call()
  if (is.list(link) && inherits(link[[1]], "otel_span")) {
    link[-1] <- as_otel_attributes(
      link[-1],
      call = substitute(as_otel_attributes(link[-1]), list(link = call[[2]]))
    )
    return(list(link[[1]]$xptr, link[-1]))
  }

  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must be either an ",
    "OpenTelemetry span (`otel_span`) object or a list with a span ",
    "object as the first element and named span attributes as the rest."
  )))
}

as_span_links <- function(links, call = NULL) {
  call <- call %||% match.call()
  if (is.list(links) || is.null(links)) {
    for (i in seq_along(links)) {
      links[[i]] <- as_span_link(
        links[[i]],
        call = as.call(substitute(as_span_link(links[[i]]), list(i = i)))
      )
    }
    return(links)
  }

  stop(glue(c(
    "Invalid argument: {format(call[[2]])} must be a named list, ",
    "but it is {typename(links)}."
  )))
}

as_span_options <- function(options, call = NULL) {
  nms <- c(
    "start_system_time",
    "start_steady_time",
    "parent",
    "kind"
  )
  if (
    (is.list(options) || is.null(options)) &&
      is_named(options) &&
      all(names(options) %in% nms)
  ) {
    options[["start_system_time"]] <-
      as_timestamp(options[["start_system_time"]])
    options[["start_steady_time"]] <-
      as_timestamp(options[["start_steady_time"]])
    options[["parent"]] <- as_span_parent(options[["parent"]], na = TRUE)
    options[["kind"]] <- as_choice(options[["kind"]], the$span_kinds)
    return(options)
  }

  call <- call %||% match.call()
  if (!is.list(options) && !is.null(options)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a named list of ",
      "OpenTelemetry span options, but it is {typename(options)}."
    )))
  }

  if (!is_named(options)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a named list of ",
      "OpenTelemetry span options, but not all of its entries are named."
    )))
  }

  bad <- unique(setdiff(names(options), nms))
  stop(glue(c(
    "Invalid argument: {format(call[[2]])} contains unknown OpenTelemetry ",
    "span option{plural(length(bad))}: {collapse(bad)}. Known span options ",
    "are: {collapse(nms)}."
  )))
}

as_end_span_options <- function(options, call = NULL) {
  nms <- c(
    "end_steady_time"
  )
  if (
    (is.list(options) || is.null(options)) &&
      is_named(options) &&
      all(names(options) %in% nms)
  ) {
    options[["end_steady_time"]] <-
      as_timestamp(options[["end_steady_time"]])
    return(as.list(options))
  }

  call <- call %||% match.call()
  if (!is.list(options) && !is.null(options)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a named list of ",
      "OpenTelemetry end span options, but it is {typename(options)}."
    )))
  }

  if (!is_named(options)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a named list of ",
      "OpenTelemetry end span options, but not of its entries are named."
    )))
  }

  bad <- unique(setdiff(names(options), nms))
  stop(glue(c(
    "Invalid argument: {format(call[[2]])} contains unknown ",
    "OpenTelemetry end span options: {collapse(bad)}. Known end ",
    "span options are: {collapse(nms)}."
  )))
}

as_output_file <- function(x, null = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }

  call <- call %||% match.call()
  x <- as_string(x, call = substitute(as_string(x), list(x = call[[2]])))

  dn <- dirname(x)
  if (!file.exists(dn)) {
    stop(glue(c(
      "Directory of OpenTelemetry output file '{x}' ",
      "does not exist or it is not writeable."
    )))
  }

  # This is the closest thing to Unix `touch` that I could find.
  suppressWarnings(
    tryCatch(
      cat("", sep = "", file = x, append = TRUE),
      error = function(e) NULL
    )
  )

  if (!file.exists(x) || file.access(x, 2) != 0) {
    stop(glue(c("Cannot write to OpenTelemetry output file '{x}'.")))
  }

  x
}

as_log_severity <- function(x, null = TRUE, spec = FALSE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  choices <- if (spec) log_severity_levels_spec() else otel::log_severity_levels
  if (is_string(x) && x %in% names(choices)) {
    return(choices[x])
  } else if (is_count(x) && x %in% choices) {
    return(as.integer(x))
  }

  call <- call %||% match.call()
  if (is_string(x)) {
    cchoices <- paste(names(choices), collapse = ", ")
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be one of {cchoices}, ",
      "but it is {x}."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be an integer log level, ",
      "between {min(choices)} and {max(otel::log_severity_levels)}",
      if (spec) {
        paste0(", or ", max(log_severity_levels_spec()))
      },
      ", but it is {if (is_count(x)) x else typename(x)}."
    )))
  }
}

# TODO
as_event_id <- function(x, null = TRUE, call = NULL) {
  x
}

as_span_id <- function(x, null = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  nc <- span_id_size() * 2L
  if (is_string(x) && nchar(x) == nc && grepl("^[0-9a-fA-F]+$", x)) {
    return(tolower(x))
  }

  call <- call %||% match.call()
  if (is_string(x)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a span id, a string ",
      "scalar containing {nc} hexadecimal digits, but it is '{x}'."
    )))
  } else if (is_string(x, na = TRUE)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a span id, a string ",
      "scalar containing {nc} hexadecimal digits, but it is `NA`."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a span id, a string ",
      "scalar containing {nc} hexadecimal digits, but it is {typename(x)}."
    )))
  }
}

as_trace_id <- function(x, null = TRUE, call = NULL) {
  if (null && is.null(x)) {
    return(x)
  }
  nc <- trace_id_size() * 2L
  if (is_string(x) && nchar(x) == nc && grepl("^[0-9a-fA-F]+$", x)) {
    return(tolower(x))
  }

  call <- call %||% match.call()
  if (is_string(x)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a trace id, a string ",
      "scalar containing {nc} hexadecimal digits, but it is '{x}'."
    )))
  } else if (is_string(x, na = TRUE)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a trace id, a string ",
      "scalar containing {nc} hexadecimal digits, but it is `NA`."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a trace id, a string ",
      "scalar containing {nc} hexadecimal digits, but it is {typename(x)}."
    )))
  }
}

# TODO
as_trace_flags <- function(x, null = TRUE, call = NULL) {
  x
}

is_count <- function(x, positive = FALSE) {
  limit <- if (positive) 1L else 0L
  is.numeric(x) && length(x) == 1 && !is.na(x) && x >= limit
}

as_count <- function(x, positive = FALSE, call = NULL) {
  limit <- if (positive) 1L else 0L
  if (is_count(x, positive = positive)) {
    return(as.integer(x))
  }

  call <- call %||% match.call()
  if (is.numeric(x) && length(x) != 1) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be an integer ",
      "scalar, not a vector."
    )))
  } else if (is.numeric(x) && length(x) == 1 && is.na(x)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must not be `NA`."
    )))
  } else if (is.numeric(x) && length(x) == 1 && !is.na(x) && x < limit) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be ",
      if (positive) "positive." else "non-negative."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a ",
      if (positive) "positive " else "non-negative ",
      "integer scalar, but it is {typename(x)}."
    )))
  }
}

as_http_context_headers <- function(headers, call = NULL) {
  if (is.list(headers) && is_named(headers)) {
    names(headers) <- tolower(names(headers))
    traceparent <- headers[["traceparent"]]
    tracestate <- headers[["tracestate"]]
    if (
      (is.null(traceparent) || is_string(traceparent)) &&
        (is.null(tracestate) || is_string(tracestate))
    ) {
      return(list(traceparent = traceparent, tracestate = tracestate))
    }
  }

  call <- call %||% match.call()
  if (!is.list(headers) || !is_named((headers))) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a named list, but it ",
      "is a {typename(headers)}."
    )))
  } else if (!is.null(traceparent) && !is_string(traceparent)) {
    stop(glue(c(
      "Invalid argument: the 'traceparent' entry of {format(call[[2]])} ",
      "must be a string (character scalar), but it is a ",
      "{typename(traceparent)}."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: the 'tracestate' entry of {format(call[[2]])} ",
      "must be a string (character scalar), but it is a ",
      "{typename(tracestate)}."
    )))
  }
}
