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

as_count <- function(x, positive = FALSE, null = FALSE, call = NULL) {
  if (is.null(x) && null) {
    return(x)
  }
  if (is_count(x, positive = positive)) {
    return(as.integer(x))
  }

  if (is_string(x)) {
    xi <- suppressWarnings(as.integer(x))
    if (is_count(x, positive = positive)) {
      return(xi)
    }
  }

  call <- call %||% match.call()
  limit <- if (positive) 1L else 0L
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

as_count_env <- function(ev, positive = FALSE) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  x <- suppressWarnings(as.integer(val))
  if (is_count(x, positive = positive)) {
    return(x)
  }
  limit <- if (positive) 1L else 0L
  proper <- if (positive) "positive" else "non-negative"
  stop(glue(c(
    "Invalid environment variable: {ev} must be a {proper} integer."
  )))
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

as_difftime_spec <- function(x, null = TRUE, call = NULL) {
  if (is.null(x) && null) {
    return(x)
  }
  if (inherits(x, "difftime") && length(x) == 1 && !is.na(x)) {
    return(as.double(x, units = "secs") * 1000 * 1000)
  }
  if (is_count(x, positive = TRUE)) {
    return(as.double(x) * 1000 * 1000)
  }
  if (is_string(x)) {
    us <- parse_time_spec(x)
    if (!is.na(us)) {
      return(us)
    }
  }

  call <- call %||% match.call()
  if (inherits(x, "difftime")) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must have length 1, and must ",
      "not be `NA`."
    )))
  } else if (is_string(x)) {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be a time interval ",
      "specification, a positive number with a time unit suffix: ",
      "us (microseconds), ms (milliseconds), s (seconds), m (minutes), ",
      "h (hours), or d (days)."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be an integer scalar ",
      "(seconds), a 'difftime' scalar, or a time interval specification. ",
      "A time interval specification is apositive number with a time unit ",
      "suffix: us (microseconds), ms (milliseconds), s (seconds), ",
      "m (minutes), h (hours) or d (days). But it is a {typename(x)}."
    )))
  }
}

as_difftime_env <- function(ev) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  us <- parse_time_spec(val)
  if (!is.na(us)) {
    return(us)
  }
  stop(glue(c(
    "Invalid environment variable: {ev}='{val}'. It must be a time interval ",
    "specification, a positive number with a time unit suffix: ",
    "us (microseconds), ms (milliseconds), s (seconds), m (minutes), ",
    "h (hours), or d (days)."
  )))
}

# x must be a sting (scalar character), only light argument checking
# Units: us / ms / s / m / h / d

time_spec_units <- rbind.data.frame(
  list(unit = "us", mult = 1),
  list(unit = "micros", mult = 1),
  list(unit = "microsec", mult = 1),
  list(unit = "microsecs", mult = 1),
  list(unit = "microsecond", mult = 1),
  list(unit = "microseconds", mult = 1),
  list(unit = "ms", mult = 1000),
  list(unit = "millis", mult = 1000),
  list(unit = "millisec", mult = 1000),
  list(unit = "millisecs", mult = 1000),
  list(unit = "millisecond", mult = 1000),
  list(unit = "milliseconds", mult = 1000),
  list(unit = "s", mult = 1000 * 1000),
  list(unit = "sec", mult = 1000 * 1000),
  list(unit = "secs", mult = 1000 * 1000),
  list(unit = "second", mult = 1000 * 1000),
  list(unit = "seconds", mult = 1000 * 1000),
  list(unit = "m", mult = 60 * 1000 * 1000),
  list(unit = "min", mult = 60 * 1000 * 1000),
  list(unit = "mins", mult = 60 * 1000 * 1000),
  list(unit = "minute", mult = 60 * 1000 * 1000),
  list(unit = "minutes", mult = 60 * 1000 * 1000),
  list(unit = "h", mult = 60 * 60 * 1000 * 1000),
  list(unit = "hour", mult = 60 * 60 * 1000 * 1000),
  list(unit = "hours", mult = 60 * 60 * 1000 * 1000),
  list(unit = "d", mult = 24 * 60 * 1000 * 1000),
  list(unit = "day", mult = 24 * 60 * 1000 * 1000),
  list(unit = "days", mult = 24 * 60 * 1000 * 1000)
)


# need to order to find the correct unit, e.g. need to prefer 'ms' over 's'
time_spec_units <- time_spec_units[
  order(nchar(time_spec_units$unit), decreasing = TRUE),
]

parse_time_spec <- function(x) {
  stopifnot(length(x) == 1)
  x <- tolower(x)
  wh <- which(endsWith(x, names(time_spec_units$unit)))[1]
  if (is.na(wh)) {
    return(NA_real_)
  }
  x <- substr(x, 1, nchar(x) - nchar(time_spec_units$unit[wh]))
  as.double(x) * unname(time_spec_units$mult[wh])
}

as_bytes <- function(x, null = TRUE, call = NULL) {
  if (is.null(x) && null) {
    return(x)
  }
  if (is_count(x, positive = TRUE)) {
    return(as.double(x))
  }
  if (is_string(x)) {
    bts <- parse_bytes_spec(x)
    if (!is.na(bts)) {
      return(bts)
    }
  }

  call <- call %||% match.call()
  if (is_string(x)) {
    stop(glue(c(
      "Invalid argument: could not interpret {format(call[[2]])} as a ",
      "number of bytes. It must be a number with unit suffix: one of ",
      "B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB."
    )))
  } else {
    stop(glue(c(
      "Invalid argument: {format(call[[2]])} must be an integer (bytes) ",
      "or a string sclar with a unit suffix. Known units are B, KB, KiB",
      "MB, MiB, GB, GiB, TB, TiB, PB, PiB. But it is a {typename(x)}."
    )))
  }
}

as_bytes_env <- function(ev) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  bts <- parse_bytes_spec(val)
  if (!is.na(bts)) {
    return(bts)
  }
  stop(glue(c(
    "Invalid environment variable: {ev}='{val}'. It must be an integer ",
    "with a unit suffix. Known units are B, KB, KiB, MB, MiB, GB, GiB, ",
    "TB, TiB, PB, PiB."
  )))
}

bytes_spec_units <- rbind.data.frame(
  list(unit = "b", mult = 1),
  list(unit = "byte", mult = 1),
  list(unit = "bytes", mult = 1),
  list(unit = "kb", mult = 1000),
  list(unit = "kilobyte", mult = 1000),
  list(unit = "kilobytes", mult = 1000),
  list(unit = "mb", mult = 1000 * 1000),
  list(unit = "megabyte", mult = 1000 * 1000),
  list(unit = "megabytes", mult = 1000 * 1000),
  list(unit = "gb", mult = 1000 * 1000 * 1000),
  list(unit = "gigabyte", mult = 1000 * 1000 * 1000),
  list(unit = "gigabytes", mult = 1000 * 1000 * 1000),
  list(unit = "tb", mult = 1000 * 1000 * 1000 * 1000),
  list(unit = "terabyte", mult = 1000 * 1000 * 1000 * 1000),
  list(unit = "terabytes", mult = 1000 * 1000 * 1000 * 1000),
  list(unit = "pb", mult = 1000 * 1000 * 1000 * 1000 * 1000),
  list(unit = "petabyte", mult = 1000 * 1000 * 1000 * 1000 * 1000),
  list(unit = "petabytes", mult = 1000 * 1000 * 1000 * 1000 * 1000),

  list(unit = "kib", mult = 1024),
  list(unit = "kibibyte", mult = 1024),
  list(unit = "kibibytes", mult = 1024),
  list(unit = "mib", mult = 1024 * 1024),
  list(unit = "mebibyte", mult = 1024 * 1024),
  list(unit = "mebibytes", mult = 1024 * 1024),
  list(unit = "gib", mult = 1024 * 1024 * 1024),
  list(unit = "gibibyte", mult = 1024 * 1024 * 1024),
  list(unit = "gibibytes", mult = 1024 * 1024 * 1024),
  list(unit = "tib", mult = 1024 * 1024 * 1024 * 1024),
  list(unit = "tebibyte", mult = 1024 * 1024 * 1024 * 1024),
  list(unit = "tebibytes", mult = 1024 * 1024 * 1024 * 1024),
  list(unit = "pib", mult = 1024 * 1024 * 1024 * 1024 * 1024),
  list(unit = "pebibyte", mult = 1024 * 1024 * 1024 * 1024 * 1024),
  list(unit = "pebibytes", mult = 1024 * 1024 * 1024 * 1024 * 1024)
)

# need to order to find the correct unit, e.g. need to prefer 'kb' over 'b'
bytes_spec_units <- bytes_spec_units[
  order(nchar(bytes_spec_units$unit), decreasing = TRUE),
]

parse_bytes_spec <- function(x) {
  stopifnot(length(x) == 1)
  x <- tolower(x)
  wh <- which(endsWith(x, names(bytes_spec_units$unit)))[1]
  if (is.na(wh)) {
    return(NA_real_)
  }
  x <- substr(x, 1, nchar(x) - nchar(bytes_spec_units$unit[wh]))
  as.double(x) * unname(bytes_spec_units$mult[wh])
}
