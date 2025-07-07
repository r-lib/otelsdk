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

as_timestamp <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }
  if (inherits(x, "POSIXt") && length(x) == 1 && !is.na(x)) {
    return(as.double(x))
  }
  if (is.numeric(x) && length(x) == 1 && !is.na(x)) {
    return(as.double(x))
  }

  if (inherits(x, "POSIXt") && length(x) == 0) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a time stamp \\
       (`POSIXt` scalar or numeric scalar), but it is an empty vector."
    ))
  } else if (inherits(x, "POSIXt") && length(x) > 1) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a time stamp \\
       (`POSIXt` scalar or numeric scalar), but it is too long."
    ))
  } else if (inherits(x, "POSIXt") && length(x) == 1 && is.na(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a time stamp \\
       (`POSIXt` scalar or numeric scalar), but it is `NA`."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a time stamp \\
      (`POSIXt` scalar or numeric scalar), but it is {typename(x)}."
    ))
  }
}

as_span <- function(
  x,
  null = TRUE,
  na = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }
  if (na && is_na(x)) {
    return(NA)
  }
  if (inherits(x, "otel_span")) {
    return(x)
  }

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must be a span object (`otel_span`), but it \\
     is {typename(x)}."
  ))
}

as_span_context <- function(
  x,
  null = TRUE,
  na = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }
  if (na && is_na(x)) {
    return(x)
  }
  if (inherits(x, "otel_span")) {
    return(x$get_context())
  }
  if (inherits(x, "otel_span_context")) {
    return(x)
  }

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must be a span context object \\
     (`otel_span_context`), but it is {typename(x)}."
  ))
}

as_span_parent <- function(
  x,
  null = TRUE,
  na = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
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

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must be a span (`otel_span`) or a span \\
     context (`otel_span_context`) object but it is {typename(x)}."
  ))
}

as_choice <- function(
  x,
  choices,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(match("default", names(choices)) - 1L)
  }
  if (is_string(x) && !is.na(mch <- match(tolower(x), choices))) {
    return(mch - 1L)
  }

  cchoices <- paste0("'", choices, "'", collapse = ", ")
  if (is_string(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be one of {cchoices}, but it is '{x}'."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a string scalar, one of \\
       {cchoices}, but it is {typename(x)}."
    ))
  }
}

as_env <- function(x, null = TRUE, arg = caller_arg(x), call = caller_env()) {
  if (null && is.null(x)) {
    return(x)
  }
  if (is.environment(x)) {
    return(x)
  }

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must be an environment, but it is {typename(x)}."
  ))
}

as_string <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }
  if (is_string(x)) {
    return(x)
  }

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must be a string scalar but it is \\
     {typename(x)}."
  ))
}

as_flag <- function(x, null = FALSE, arg = caller_arg(x), call = caller_env()) {
  if (null && is.null(x)) {
    return(x)
  }
  if (is_flag(x)) {
    return(x)
  }

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must a flag (logical scalar), but it is \\
     {typename(x)}."
  ))
}

as_flag_env <- function(ev, call = caller_env()) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  tvals <- c("true", "t", "yes", "on", "1")
  fvals <- c("false", "f", "no", "off", "0")
  if (tolower(val) %in% tvals) {
    return(TRUE)
  } else if (tolower(val) %in% fvals) {
    return(FALSE)
  }

  stop(cnd(
    call = call,
    "Invalid environment variable: '{ev}' must be 'true' or 'false' \\
     (case insensitive). It is '{val}'."
  ))
}

span_attr_types <- c(typeof(""), typeof(TRUE), typeof(1), typeof(1L))

as_otel_attribute_value <- function(
  x,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (typeof(x) %in% span_attr_types && !(hna <- anyNA(x))) {
    return(x)
  }

  if (!typeof(x) %in% span_attr_types) {
    ctypes <- collapse(span_attr_types, last = ", or ")
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be of type {ctypes}, but it is \\
       {typename(x)}."
    ))
  }
  if (hna) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must not contain missing (`NA`) values."
    ))
  }
}

as_otel_attributes <- function(
  attributes,
  arg = caller_arg(attributes),
  call = caller_env()
) {
  if (
    (is.list(attributes) || is.null(attributes)) &&
      is_named(attributes) &&
      all((tps <- map_chr(attributes, typeof)) %in% span_attr_types) &&
      all(!(hna <- map_lgl(attributes, anyNA)))
  ) {
    return(attributes)
  }

  if (!is.list(attributes)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list, but it is \\
       {typename(attributes)}."
    ))
  }

  if (!is_named(attributes)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list, but not all of its \\
       entries are named."
    ))
  }

  badtypes <- !(tps %in% span_attr_types)
  if (any(badtypes)) {
    ok <- collapse(span_attr_types)
    bd <- collapse(unique(tps[badtypes]))
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` can only contain types {ok}, but it \\
       contains {bd} types."
    ))
  }

  stop(cnd(
    call = call,
    "Invalid argument: the entries of `{arg}` must not contain missing \\
     (`NA`) values."
  ))
}

as_span_link <- function(link, arg = caller_arg(link), call = caller_env()) {
  if (inherits(link, "otel_span")) {
    return(list(link$xptr, list()))
  }
  if (is.list(link) && inherits(link[[1]], "otel_span")) {
    link[-1] <- as_otel_attributes(
      link[-1],
      arg = as_caller_arg(substitute(x[-1], list(x = arg[[1]]))),
      call = call
    )
    return(list(link[[1]]$xptr, link[-1]))
  }

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must be either an OpenTelemetry span \\
     (`otel_span`) object or a list with a span object as the first \\
     element and named span attributes as the rest."
  ))
}

as_span_links <- function(links, arg = caller_arg(links), call = caller_env()) {
  call <- call %||% match.call()
  if (is.list(links) || is.null(links)) {
    for (i in seq_along(links)) {
      links[[i]] <- as_span_link(
        links[[i]],
        arg = as_caller_arg(substitute(x[[i]], list(x = arg[[1]], i = i))),
        call = call
      )
    }
    return(links)
  }

  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` must be a named list, but it is \\
     {typename(links)}."
  ))
}

as_span_options <- function(
  options,
  arg = caller_arg(options),
  call = caller_env()
) {
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
    force(arg)
    options[["start_system_time"]] <- as_timestamp(
      options[["start_system_time"]],
      arg = as_caller_arg(substitute(
        x[["start_system_time"]],
        list(x = arg[[1]])
      )),
      call = call
    )
    options[["start_steady_time"]] <- as_timestamp(
      options[["start_steady_time"]],
      arg = as_caller_arg(substitute(
        x[["start_steady_time"]],
        list(x = arg[[1]])
      )),
      call = call
    )
    options[["parent"]] <- as_span_parent(
      options[["parent"]],
      na = TRUE,
      arg = as_caller_arg(substitute(x[["parent"]], list(x = arg[[1]]))),
      call = call
    )
    options[["kind"]] <- as_choice(
      options[["kind"]],
      the$span_kinds,
      arg = as_caller_arg(substitute(x[["kind"]], list(x = arg[[1]]))),
      call = call
    )
    return(options)
  }

  if (!is.list(options) && !is.null(options)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list of OpenTelemetry \\
       span options, but it is {typename(options)}."
    ))
  }

  if (!is_named(options)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list of OpenTelemetry \\
       span options, but not all of its entries are named."
    ))
  }

  bad <- unique(setdiff(names(options), nms))
  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` contains unknown OpenTelemetry span \\
     option{plural(length(bad))}: {collapse(bad)}. Known span options \\
     are: {collapse(nms)}."
  ))
}

as_end_span_options <- function(
  options,
  arg = caller_arg(options),
  call = caller_env()
) {
  nms <- c(
    "end_steady_time"
  )
  if (
    (is.list(options) || is.null(options)) &&
      is_named(options) &&
      all(names(options) %in% nms)
  ) {
    force(arg)
    options[["end_steady_time"]] <- as_timestamp(
      options[["end_steady_time"]],
      arg = as_caller_arg(substitute(
        x[["end_steady_time"]],
        list(x = arg[[1]])
      )),
      call = call
    )
    return(as.list(options))
  }

  if (!is.list(options) && !is.null(options)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list of OpenTelemetry end \\
       span options, but it is {typename(options)}."
    ))
  }

  if (!is_named(options)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list of OpenTelemetry end \\
       span options, but not all of its entries are named."
    ))
  }

  bad <- unique(setdiff(names(options), nms))
  stop(cnd(
    call = call,
    "Invalid argument: `{arg}` contains unknown OpenTelemetry end span \\
     options: {collapse(bad)}. Known end span options are: {collapse(nms)}."
  ))
}

as_output_file <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }

  x <- as_string(x, arg = arg, call = call)

  dn <- dirname(x)
  if (!file.exists(dn)) {
    stop(cnd(
      call = call,
      "Directory of OpenTelemetry output file '{x}' does not exist or it \\
      is not writeable."
    ))
  }

  # This is the closest thing to Unix `touch` that I could find.
  suppressWarnings(
    tryCatch(
      cat("", sep = "", file = x, append = TRUE),
      error = function(e) NULL
    )
  )

  if (!file.exists(x) || file.access(x, 2) != 0) {
    stop(cnd(call = call, "Cannot write to OpenTelemetry output file '{x}'."))
  }

  x
}

as_log_severity <- function(
  x,
  null = TRUE,
  spec = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }
  choices <- if (spec) log_severity_levels_spec() else otel::log_severity_levels
  if (is_string(x) && x %in% names(choices)) {
    return(choices[x])
  } else if (is_count(x) && x %in% choices) {
    return(as.integer(x))
  }

  if (is_string(x)) {
    cchoices <- paste0("'", names(choices), "'", collapse = ", ")
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be one of {cchoices}, but it is '{x}'."
    ))
  } else {
    specstr <- if (spec) {
      paste0(", or ", max(log_severity_levels_spec()))
    } else {
      ""
    }
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be an integer log level, between \\
       {min(choices)} and {max(otel::log_severity_levels)}{specstr}, \\
       but it is {if (is_count(x)) x else typename(x)}."
    ))
  }
}

# TODO
as_event_id <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  x # nocov
}

as_span_id <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }
  nc <- span_id_size() * 2L
  if (is_string(x) && nchar(x) == nc && grepl("^[0-9a-fA-F]+$", x)) {
    return(tolower(x))
  }

  if (is_string(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a span id, a string scalar \\
       containing {nc} hexadecimal digits, but it is '{x}'."
    ))
  } else if (is_string(x, na = TRUE)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a span id, a string scalar \\
       containing {nc} hexadecimal digits, but it is `NA`."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a span id, a string scalar \\
      containing {nc} hexadecimal digits, but it is {typename(x)}."
    ))
  }
}

as_trace_id <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(x)
  }
  nc <- trace_id_size() * 2L
  if (is_string(x) && nchar(x) == nc && grepl("^[0-9a-fA-F]+$", x)) {
    return(tolower(x))
  }

  if (is_string(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a trace id, a string \\
       scalar containing {nc} hexadecimal digits, but it is '{x}'."
    ))
  } else if (is_string(x, na = TRUE)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a trace id, a string \\
       scalar containing {nc} hexadecimal digits, but it is `NA`."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a trace id, a string \\
       scalar containing {nc} hexadecimal digits, but it is {typename(x)}."
    ))
  }
}

# TODO
as_trace_flags <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  x # nocov
}

is_count <- function(x, positive = FALSE) {
  limit <- if (positive) 1L else 0L
  is.numeric(x) && length(x) == 1 && !is.na(x) && x >= limit
}

as_count <- function(
  x,
  positive = FALSE,
  null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (is.null(x) && null) {
    return(x)
  }
  if (is_count(x, positive = positive)) {
    return(as.integer(x))
  }

  if (is_string(x)) {
    xi <- suppressWarnings(as.integer(x))
    if (is_count(xi, positive = positive)) {
      return(xi)
    }
  }

  limit <- if (positive) 1L else 0L
  if (is.numeric(x) && length(x) != 1) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be an integer scalar, not a vector."
    ))
  } else if (is.numeric(x) && length(x) == 1 && is.na(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must not be `NA`."
    ))
  } else if (is.numeric(x) && length(x) == 1 && !is.na(x) && x < limit) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be \\
      {if (positive) 'positive' else 'non-negative'}."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a \\
      {if (positive) 'positive' else 'non-negative'} integer scalar, \\
      but it is {typename(x)}."
    ))
  }
}

as_count_env <- function(ev, positive = FALSE, call = caller_env()) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  x <- suppressWarnings(as.integer(val))
  if (is_count(x, positive = positive)) {
    return(x)
  }
  proper <- if (positive) "positive" else "non-negative"
  stop(cnd(
    call = call,
    "Invalid environment variable: `{ev}` must be a {proper} integer. \\
     It is '{val}'."
  ))
}

as_http_context_headers <- function(
  headers,
  arg = caller_arg(headers),
  call = caller_env()
) {
  if ((is.list(headers) || is.character(headers)) && is_named(headers)) {
    # need to make a copy, coll caller_arg() still works
    headers_ <- headers
    names(headers_) <- tolower(names(headers_))
    headers_ <- as.list(headers_)
    traceparent <- headers_[["traceparent"]]
    tracestate <- headers_[["tracestate"]]
    if (
      (is.null(traceparent) || is_string(traceparent)) &&
        (is.null(tracestate) || is_string(tracestate))
    ) {
      return(list(traceparent = traceparent, tracestate = tracestate))
    }
  }

  if (!is.list(headers) || !is_named((headers))) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list, but it is a \\
       {typename(headers)}."
    ))
  } else if (!is.null(traceparent) && !is_string(traceparent)) {
    stop(cnd(
      call = call,
      "Invalid argument: the 'traceparent' entry of `{arg}` must be a \\
       string (character scalar), but it is a {typename(traceparent)}."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: the 'tracestate' entry of `{arg}` must be a \\
       string (character scalar), but it is a {typename(tracestate)}."
    ))
  }
}

# returns milliseconds
as_difftime_spec <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (is.null(x) && null) {
    return(x)
  }
  if (inherits(x, "difftime") && length(x) == 1 && !is.na(x)) {
    return(as.double(x, units = "secs") * 1000)
  }
  if (is_count(x, positive = TRUE)) {
    return(as.double(x))
  }
  if (is_string(x)) {
    us <- parse_time_spec(x)
    if (!is.na(us)) {
      return(us)
    }
  }

  if (inherits(x, "difftime")) {
    cmt <- if (length(x) != 1) "It has length {length(x)}." else "It is `NA`."
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must have length 1, and must not be \\
       `NA`. {cmt}"
    ))
  } else if (is_string(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a time interval specification, a \\
       positive number with a time unit suffix: us (microseconds), \\
       ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days)."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be an integer scalar (milliseconds), \\
       a 'difftime' scalar, or a time interval specification. A time \\
       interval specification is apositive number with a time unit \\
       suffix: us (microseconds), ms (milliseconds), s (seconds), \\
       m (minutes), h (hours) or d (days). But it is a {typename(x)}."
    ))
  }
}

as_difftime_env <- function(ev, call = caller_env()) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  xv <- suppressWarnings(as.double(val))
  if (!is.na(xv)) {
    return(xv)
  }
  us <- parse_time_spec(val)
  if (!is.na(us)) {
    return(us)
  }
  stop(cnd(
    call = call,
    "Invalid environment variable: {ev}='{val}'. It must be a time interval \\
     specification, a positive number with a time unit suffix: \\
     us (microseconds), ms (milliseconds), s (seconds), m (minutes), \\
     h (hours), or d (days)."
  ))
}

# x must be a sting (scalar character), only light argument checking
# Units: us / ms / s / m / h / d

time_spec_units <- rbind.data.frame(
  list(unit = "us", mult = 1 / 1000),
  list(unit = "micros", mult = 1 / 1000),
  list(unit = "microsec", mult = 1 / 1000),
  list(unit = "microsecs", mult = 1 / 1000),
  list(unit = "microsecond", mult = 1 / 1000),
  list(unit = "microseconds", mult = 1 / 1000),
  list(unit = "ms", mult = 1),
  list(unit = "millis", mult = 1),
  list(unit = "millisec", mult = 1),
  list(unit = "millisecs", mult = 1),
  list(unit = "millisecond", mult = 1),
  list(unit = "milliseconds", mult = 1),
  list(unit = "s", mult = 1000),
  list(unit = "sec", mult = 1000),
  list(unit = "secs", mult = 1000),
  list(unit = "second", mult = 1000),
  list(unit = "seconds", mult = 1000),
  list(unit = "m", mult = 60 * 1000),
  list(unit = "min", mult = 60 * 1000),
  list(unit = "mins", mult = 60 * 1000),
  list(unit = "minute", mult = 60 * 1000),
  list(unit = "minutes", mult = 60 * 1000),
  list(unit = "h", mult = 60 * 60 * 1000),
  list(unit = "hour", mult = 60 * 60 * 1000),
  list(unit = "hours", mult = 60 * 60 * 1000),
  list(unit = "d", mult = 24 * 60 * 60 * 1000),
  list(unit = "day", mult = 24 * 60 * 60 * 1000),
  list(unit = "days", mult = 24 * 60 * 60 * 1000)
)


# need to order to find the correct unit, e.g. need to prefer 'ms' over 's'
time_spec_units <- time_spec_units[
  order(nchar(time_spec_units$unit), decreasing = TRUE),
]

parse_time_spec <- function(x) {
  stopifnot(length(x) == 1)
  x <- tolower(x)
  wh <- which(endsWith(x, time_spec_units$unit))[1]
  if (is.na(wh)) {
    return(NA_real_)
  }
  x <- substr(x, 1, nchar(x) - nchar(time_spec_units$unit[wh]))
  suppressWarnings(as.double(x)) * unname(time_spec_units$mult[wh])
}

as_bytes <- function(x, null = TRUE, arg = caller_arg(x), call = caller_env()) {
  if (is.null(x) && null) {
    return(x)
  }
  if (is_count(x, positive = TRUE)) {
    return(as.double(x))
  }
  if (is_string(x)) {
    bts <- suppressWarnings(as.double(x))
    if (!is.na(bts)) {
      return(bts)
    }
    bts <- parse_bytes_spec(x)
    if (!is.na(bts)) {
      return(bts)
    }
  }

  if (is_string(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: could not interpret `{arg}` as a number of bytes. \\
       It must be a number with a unit suffix: one of \\
       B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be an integer (bytes) or a string \\
       scalar with a unit suffix. Known units are B, KB, KiB, MB, MiB, \\
       GB, GiB, TB, TiB, PB, PiB. But it is a {typename(x)}."
    ))
  }
}

as_bytes_env <- function(ev, call = caller_env()) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  bts <- suppressWarnings(as.integer(val))
  if (!is.na(bts)) {
    return(bts)
  }
  bts <- parse_bytes_spec(val)
  if (!is.na(bts)) {
    return(bts)
  }
  stop(cnd(
    call = call,
    "Invalid environment variable: {ev}='{val}'. It must be an integer \\
     with a unit suffix. Known units are B, KB, KiB, MB, MiB, GB, GiB, \\
     TB, TiB, PB, PiB."
  ))
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
  wh <- which(endsWith(x, bytes_spec_units$unit))[1]
  if (is.na(wh)) {
    return(NA_real_)
  }
  x <- substr(x, 1, nchar(x) - nchar(bytes_spec_units$unit[wh]))
  as.double(x) * unname(bytes_spec_units$mult[wh])
}

as_named_list <- function(x, arg = caller_arg(x), call = caller_env()) {
  if ((is.null(x) || is.list(x)) && is_named(x)) {
    return(x)
  }

  if (is.list(x) && !is_named(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list, but it is not named."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named list, but it is \\
       {typename(x)}."
    ))
  }
}

as_file_exporter_options <- function(
  opts,
  evs,
  arg = caller_arg(opts),
  call = NULL
) {
  opts <- as_named_list(opts, arg = arg, call = call)

  ma <- function(nm) {
    as_caller_arg(substitute(x[[n]], list(x = arg[[1]], n = nm)))
  }

  file_pattern <-
    as_string(opts$file_pattern, arg = ma("file_pattern"), call = call) %||%
    get_env(evs[["file_pattern"]]) %||%
    get_env(file_exporter_file_envvar)

  alias_pattern <-
    as_string(opts$alias_pattern, arg = ma("alias_pattern"), call = call) %||%
    get_env(evs[["alias_pattern"]]) %||%
    get_env(file_exporter_alias_envvar) %||%
    empty_atomic_as_null(sub("%N", "latest", file_pattern))

  flush_interval <-
    as_difftime_spec(
      opts$flush_interval,
      arg = ma("flush_interval"),
      call = call
    ) %||%
    as_difftime_env(evs[["flush_interval"]], call = call) %||%
    as_difftime_env(file_exporter_flush_interval_envvar, call = call)

  flush_count <-
    as_count(
      opts$flush_count,
      null = TRUE,
      arg = ma("flush_count"),
      call = call
    ) %||%
    as_count_env(evs[["flush_count"]], positive = TRUE, call = call) %||%
    as_count_env(file_exporter_flush_count_envvar, positive = TRUE, call = call)

  file_size <-
    as_bytes(opts$file_size, arg = ma("file_size"), call = call) %||%
    as_bytes_env(evs[["file_size"]], call = call) %||%
    as_bytes_env(file_exporter_file_size_envvar, call = call)

  rotate_size <-
    as_bytes(opts$rotate_size, arg = ma("rotate_size"), call = call) %||%
    as_count_env(evs[["rotate_size"]], call = call) %||%
    as_count_env(file_exporter_rotate_size_envvar, call = call)

  list(
    file_pattern = file_pattern,
    alias_pattern = alias_pattern,
    flush_interval = flush_interval,
    flush_count = flush_count,
    file_size = file_size,
    rotate_size = rotate_size
  )
}

check_known_options <- function(
  x,
  nms,
  arg = caller_arg(x),
  call = caller_env()
) {
  bad <- setdiff(names(x), nms)
  if (length(bad) > 0) {
    s <- plural(length(bad))
    badstr <- paste0("'", bad, "'", collapse = ", ")
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` has unknown option{s}: {badstr}."
    ))
  }
  x
}

as_logger_provider_file_options <- function(
  opts,
  arg = caller_arg(opts),
  call = caller_env()
) {
  evs = c(
    file_pattern = file_exporter_logs_file_envvar,
    alias_pattern = file_exporter_logs_alias_envvar,
    flush_interval = file_exporter_logs_flush_interval_envvar,
    flush_count = file_exporter_logs_flush_count_envvar,
    file_size = file_exporter_logs_file_size_envvar,
    rotate_size = file_exporter_logs_rotate_size_envvar
  )

  opts1 <- as_file_exporter_options(opts, evs = evs, arg = arg, call = call)
  check_known_options(opts, names(opts1), arg = arg, call = call)

  opts1
}

as_metric_reader_options <- function(
  opts,
  arg = caller_arg(opts),
  call = caller_env()
) {
  force(arg)
  opts <- as_named_list(opts, arg = arg, call = call)

  ma <- function(nm) {
    as_caller_arg(substitute(x[[nm]], list(x = arg[[1]], nm = nm)))
  }

  export_interval <-
    as_difftime_spec(
      opts$export_interval,
      arg = ma("export_interval"),
      call = call
    ) %||%
    as_difftime_env(metric_export_interval_envvar, call = call) %||%
    60000L
  export_timeout <-
    as_difftime_spec(
      opts$export_timeout,
      arg = ma("export_timeout"),
      call = call
    ) %||%
    as_difftime_env(metric_export_timeout_envvar, call = call) %||%
    30000L

  list(
    export_interval = export_interval,
    export_timeout = export_timeout
  )
}

as_meter_provider_file_options <- function(
  opts,
  arg = caller_arg(opts),
  call = caller_env()
) {
  evs = c(
    file_pattern = file_exporter_metrics_file_envvar,
    alias_pattern = file_exporter_metrics_alias_envvar,
    flush_interval = file_exporter_metrics_flush_interval_envvar,
    flush_count = file_exporter_metrics_flush_count_envvar,
    file_size = file_exporter_metrics_file_size_envvar,
    rotate_size = file_exporter_metrics_rotate_size_envvar
  )
  opts1 <- as_metric_reader_options(opts, arg = arg, call = call)
  opts2 <- as_file_exporter_options(opts, evs = evs, arg = arg, call = call)
  check_known_options(
    opts,
    c(names(opts1), names(opts2)),
    arg = arg,
    call = call
  )

  c(opts1, opts2)
}

as_tracer_provider_file_options <- function(
  opts,
  arg = caller_arg(opts),
  call = caller_env()
) {
  evs = c(
    file_pattern = file_exporter_traces_file_envvar,
    alias_pattern = file_exporter_traces_alias_envvar,
    flush_interval = file_exporter_traces_flush_interval_envvar,
    flush_count = file_exporter_traces_flush_count_envvar,
    file_size = file_exporter_traces_file_size_envvar,
    rotate_size = file_exporter_traces_rotate_size_envvar
  )

  opts1 <- as_file_exporter_options(opts, evs = evs, arg = arg, call = call)
  check_known_options(opts, names(opts1), arg = arg, call = call)

  opts1
}

otlp_content_type_values <- c(
  "json" = 0L,
  "application/json" = 0L,
  "binary" = 1L,
  "application/x-protobuf" = 1L
)

as_otlp_content_type <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(NULL)
  }
  if (is_string(x) && tolower(x) %in% names(otlp_content_type_values)) {
    return(otlp_content_type_values[tolower(x)])
  }

  vls <- paste0("'", names(otlp_content_type_values), "'", collapse = ", ")
  if (is_string(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be one of {vls}, but it is '{x}'."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: {arg} must a string, one of {vls}, but it is \\
       {typename(x)}."
    ))
  }
}

as_otlp_content_type_env <- function(ev, call = caller_env()) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  if (tolower(val) %in% names(otlp_content_type_values)) {
    return(otlp_content_type_values[tolower(val)])
  }

  vls <- paste0("'", names(otlp_content_type_values), "'", collapse = ", ")
  stop(cnd(
    call = call,
    "Invalid environment variable: '{ev}' must be one of {vls}, but it \\
     is '{val}'."
  ))
}

otlp_json_byte_mapping_choices <- c(default = "hexid", "base64", "hex")

as_otlp_json_bytes_mapping <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  as_choice(
    x,
    otlp_json_byte_mapping_choices,
    null = null,
    arg = arg,
    call = call
  )
}

as_otlp_json_bytes_mapping_env <- function(ev, call = caller_env()) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }

  w <- match(tolower(val), otlp_json_byte_mapping_choices)
  if (!is.na(w)) {
    return(w - 1L)
  }

  choices <- paste(otlp_json_byte_mapping_choices, collapse = ", ")
  stop(cnd(
    "Invalid environment variable: '{ev}' must be one of {choices} \\
     (case insensitive), but it is '{val}'."
  ))
}

otlp_compression_choices <- c(default = "none", "gzip")

as_otlp_compression <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  as_choice(x, otlp_compression_choices, null = null, arg = arg, call = call)
}

is_number <- function(x, positive = FALSE) {
  is.numeric(x) && length(x) == 1 && !is.na(x) && (!positive || x > 0)
}

as_number <- function(
  x,
  positive = FALSE,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(NULL)
  }
  if (is_number(x, positive = positive)) {
    return(as.double(x))
  }
  if (is_string(x)) {
    xd <- suppressWarnings(as.double(x))
    if (is_number(xd, positive = positive)) {
      return(xd)
    }
  }

  pos <- if (positive) "positive " else ""
  if (is.numeric(x) && length(x) != 1) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a numeric scalar, not a vector."
    ))
  } else if (is.numeric(x) && length(x) == 1 && is.na(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must not be `NA`."
    ))
  } else if (positive && is_number(x, positive = FALSE)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be positive."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a {pos}number, but it is \\
       {typename(x)}."
    ))
  }
}

as_number_env <- function(ev, positive = FALSE, call = caller_env()) {
  val <- get_env(ev)
  if (is.null(val)) {
    return(NULL)
  }
  x <- suppressWarnings(as.double(val))
  if (is_number(x, positive = positive)) {
    return(x)
  }
  pos <- if (positive) "positive " else ""
  stop(cnd(
    call = call,
    "Invalid environment variable: '{ev}' must be a {pos}number. It is '{val}'."
  ))
}

as_http_headers <- function(
  x,
  null = TRUE,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (null && is.null(x)) {
    return(NULL)
  }
  if (is.character(x) && is_named(x) && !anyNA(x)) {
    return(x)
  }

  if (is.character(x) && !is_named(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: all entries in `{arg}` must be a named."
    ))
  } else if (is.character(x)) {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must not contain `NA` values."
    ))
  } else {
    stop(cnd(
      call = call,
      "Invalid argument: `{arg}` must be a named character vector without \\
       `NA` values, but it is {typename(x)}."
    ))
  }
}

as_http_exporter_options <- function(
  opts,
  evs,
  arg = caller_arg(opts),
  call = caller_env()
) {
  opts <- as_named_list(opts, arg = arg, call = call)

  ma <- function(nm) {
    as_caller_arg(substitute(x[[nm]], list(x = arg[[1]], nm = nm)))
  }

  # - Options in spec: we let the CPP handle these, i.e. leave at NULL
  #   if unset in argument
  # - Options not in spec, but with CPP support: we override these with
  #   R specific env vars, pass them to CPP explicitly. So we need to
  #   set defaults for them here, to avoid looking up CPP specific env vars.
  # - Options not in spec and no CPP env vars: we introduce R
  #   specific env vars for these. No need to pass them to CPP, but we
  #   might as well, in case CPP introduces env vars for them.

  # in spec
  url <- as_string(opts$url, arg = ma("url"), call = call)

  # no support
  content_type <- as_otlp_content_type(
    opts$content_type,
    arg = ma("content_type"),
    call = call
  ) %||%
    as_otlp_content_type_env(evs["content_type"], call = call) %||%
    as_otlp_content_type_env(otlp_content_type_envvar, call = call) %||%
    as_otlp_content_type(otlp_content_type_default)

  # no support
  json_bytes_mapping <-
    as_otlp_json_bytes_mapping(
      opts$json_bytes_mapping,
      arg = ma("json_bytes_mapping"),
      call = call
    ) %||%
    as_otlp_json_bytes_mapping_env(
      evs[["json_bytes_mapping"]],
      call = call
    ) %||%
    as_otlp_json_bytes_mapping_env(
      otlp_json_bytes_mapping_envvar,
      call = call
    ) %||%
    otlp_json_bytes_mapping_default

  # no support
  use_json_name <- as_flag(
    opts$use_json_name,
    null = TRUE,
    arg = ma("use_json_name"),
    call = call
  ) %||%
    as_flag_env(evs[["use_json_name"]], call = call) %||%
    as_flag_env(otlp_use_json_name_envvar, call = call) %||%
    otlp_use_json_name_default

  # no support
  console_debug <- as_flag(
    opts$console_debug,
    null = TRUE,
    arg = ma("console_debug"),
    call = call
  ) %||%
    as_flag_env(evs[["console_debug"]], call = call) %||%
    as_flag_env(otlp_console_debug_envvar, call = call) %||%
    otlp_console_debug_default

  # in spec
  timeout <- as_difftime_spec(opts$timeout, arg = ma("timeout"), call = call)

  # in spec
  http_headers <- as_http_headers(
    opts$http_headers,
    arg = ma("http_headers"),
    call = call
  )

  # no support
  ssl_insecure_skip_verify <- as_flag(
    opts$ssl_insecure_skip_verify,
    null = TRUE,
    arg = ma("ssl_insecure_skip_verify"),
    call = call
  ) %||%
    as_flag_env(evs[["ssl_insecure_skip_verify"]], call = call) %||%
    as_flag_env(otlp_ssl_insecure_skip_verify_envvar, call = call) %||%
    otlp_ssl_insecure_skip_verify_default

  # in spec
  ssl_ca_cert_path <- as_string(
    opts$ssl_ca_cert_path,
    arg = ma("ssl_ca_cert_path"),
    call = call
  )

  # in spec
  ssl_ca_cert_string <- as_string(
    opts$ssl_ca_cert_string,
    arg = ma("ssl_ca_cert_string"),
    call = call
  )

  # in spec
  ssl_client_key_path <- as_string(
    opts$ssl_client_key_path,
    arg = ma("ssl_client_key_path"),
    call = call
  )

  # in spec
  ssl_client_key_string <- as_string(
    opts$ssl_client_key_string,
    arg = ma("ssl_client_key_string"),
    call = call
  )

  # in spec
  ssl_client_cert_path <- as_string(
    opts$ssl_client_cert_path,
    arg = ma("ssl_client_cert_path"),
    call = call
  )

  # in spec
  ssl_client_cert_string <- as_string(
    opts$ssl_client_cert_string,
    arg = ma("ssl_client_cert_string"),
    call = call
  )

  # cpp support
  ssl_min_tls <- as_string(
    opts$ssl_min_tls,
    arg = ma("ssl_min_tls"),
    call = call
  ) %||%
    get_env(evs[["ssl_min_tls"]]) %||%
    get_env(otlp_ssl_min_tls_envvar) %||%
    otlp_ssl_min_tls_default

  # cpp support
  ssl_max_tls <- as_string(
    opts$ssl_max_tls,
    arg = ma("ssl_max_tls"),
    call = call
  ) %||%
    get_env(evs[["ssl_max_tls"]]) %||%
    get_env(otlp_ssl_max_tls_envvar) %||%
    otlp_ssl_max_tls_default

  # cpp support
  ssl_cipher <- as_string(
    opts$ssl_cipher,
    arg = ma("ssl_cipher"),
    call = call
  ) %||%
    get_env(evs[["ssl_cipher"]]) %||%
    get_env(otlp_ssl_cipher_envvar) %||%
    otlp_ssl_cipher_default

  # cpp support
  ssl_cipher_suite <- as_string(
    opts$ssl_cipher_suite,
    arg = ma("ssl_cipher_suite"),
    call = call
  ) %||%
    get_env(evs[["ssl_cipher_suite"]]) %||%
    get_env(otlp_ssl_cipher_suite_envvar) %||%
    otlp_ssl_cipher_suite_default

  # in spec
  compression <- as_otlp_compression(
    opts$compression,
    arg = ma("compression"),
    call = call
  )

  # cpp support
  retry_policy_max_attempts <- as_count(
    opts$retry_policy_max_attempts,
    null = TRUE,
    positive = TRUE,
    arg = ma("retry_policy_max_attempts"),
    call = call
  ) %||%
    as_count_env(
      evs[["retry_policy_max_attempts"]],
      positive = TRUE,
      call = call
    ) %||%
    as_count_env(
      otlp_retry_policy_max_attempts_envvar,
      positive = TRUE,
      call = call
    ) %||%
    otlp_retry_policy_max_attempts_default

  # cpp support
  retry_policy_initial_backoff <- as_difftime_spec(
    opts$retry_policy_initial_backoff,
    arg = ma("retry_policy_initial_backoff"),
    call = call
  ) %||%
    as_difftime_env(evs[["retry_policy_initial_backoff"]], call = call) %||%
    as_difftime_env(otlp_retry_policy_initial_backoff_envvar, call = call) %||%
    otlp_retry_policy_initial_backoff_default

  # cpp support
  retry_policy_max_backoff <- as_difftime_spec(
    opts$retry_policy_max_backoff,
    arg = ma("retry_policy_max_backoff"),
    call = call
  ) %||%
    as_difftime_env(evs[["retry_policy_max_backoff"]], call = call) %||%
    as_difftime_env(otlp_retry_policy_max_backoff_envvar, call = call) %||%
    otlp_retry_policy_max_backoff_default

  # cpp support
  retry_policy_backoff_multiplier <- as_number(
    opts$retry_policy_backoff_multiplier,
    null = TRUE,
    positive = TRUE,
    arg = ma("retry_policy_backoff_multiplier"),
    call = call
  ) %||%
    as_number_env(evs[["retry_policy_backoff_multiplier"]], call = call) %||%
    as_number_env(
      otlp_retry_policy_backoff_multiplier_envvar,
      call = call
    ) %||%
    otlp_retry_policy_backoff_multiplier_default

  list(
    url = url,
    content_type = content_type,
    json_bytes_mapping = json_bytes_mapping,
    use_json_name = use_json_name,
    console_debug = console_debug,
    timeout = timeout,
    http_headers = http_headers,
    ssl_insecure_skip_verify = ssl_insecure_skip_verify,
    ssl_ca_cert_path = ssl_ca_cert_path,
    ssl_ca_cert_string = ssl_ca_cert_string,
    ssl_client_key_path = ssl_client_key_path,
    ssl_client_key_string = ssl_client_key_string,
    ssl_client_cert_path = ssl_client_cert_path,
    ssl_client_cert_string = ssl_client_cert_string,
    ssl_min_tls = ssl_min_tls,
    ssl_max_tls = ssl_max_tls,
    ssl_cipher = ssl_cipher,
    ssl_cipher_suite = ssl_cipher_suite,
    compression = compression,
    retry_policy_max_attempts = retry_policy_max_attempts,
    retry_policy_initial_backoff = retry_policy_initial_backoff,
    retry_policy_max_backoff = retry_policy_max_backoff,
    retry_policy_backoff_multiplier = retry_policy_backoff_multiplier
  )
}

as_tracer_provider_http_options <- function(
  opts,
  arg = caller_arg(opts),
  call = caller_env()
) {
  evs <- list(
    content_type = otlp_traces_content_type_envvar,
    json_bytes_mapping = otlp_traces_json_bytes_mapping_envvar,
    use_json_name = otlp_traces_use_json_name_envvar,
    console_debug = otlp_traces_console_debug_envvar,
    ssl_insecure_skip_verify = otlp_traces_ssl_insecure_skip_verify_envvar,
    ssl_min_tls = otlp_traces_ssl_min_tls_envvar,
    ssl_max_tls = otlp_traces_ssl_max_tls_envvar,
    ssl_cipher = otlp_traces_ssl_cipher_envvar,
    ssl_cipher_suite = otlp_traces_ssl_cipher_suite_envvar,
    retry_policy_max_attempts = otlp_traces_retry_policy_max_attempts_envvar,
    retry_policy_initial_backoff = otlp_traces_retry_policy_initial_backoff_envvar,
    retry_policy_max_backoff = otlp_traces_retry_policy_max_backoff_envvar,
    retry_policy_backoff_multiplier = otlp_traces_retry_policy_backoff_multiplier_envvar
  )

  opts1 <- as_http_exporter_options(opts, evs = evs, arg = arg, call = call)
  check_known_options(opts, names(opts1), arg = arg, call = call)

  opts1
}

as_logger_provider_http_options <- function(
  opts,
  arg = caller_arg(opts),
  call = caller_env()
) {
  evs <- list(
    content_type = otlp_logs_content_type_envvar,
    json_bytes_mapping = otlp_logs_json_bytes_mapping_envvar,
    use_json_name = otlp_logs_use_json_name_envvar,
    console_debug = otlp_logs_console_debug_envvar,
    ssl_insecure_skip_verify = otlp_logs_ssl_insecure_skip_verify_envvar,
    ssl_min_tls = otlp_logs_ssl_min_tls_envvar,
    ssl_max_tls = otlp_logs_ssl_max_tls_envvar,
    ssl_cipher = otlp_logs_ssl_cipher_envvar,
    ssl_cipher_suite = otlp_logs_ssl_cipher_suite_envvar,
    retry_policy_max_attempts = otlp_logs_retry_policy_max_attempts_envvar,
    retry_policy_initial_backoff = otlp_logs_retry_policy_initial_backoff_envvar,
    retry_policy_max_backoff = otlp_logs_retry_policy_max_backoff_envvar,
    retry_policy_backoff_multiplier = otlp_logs_retry_policy_backoff_multiplier_envvar
  )

  opts1 <- as_http_exporter_options(opts, evs = evs, arg = arg, call = call)
  check_known_options(opts, names(opts1), arg = arg, call = call)

  opts1
}
