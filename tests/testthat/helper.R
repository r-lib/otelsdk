parse_otel_attributes <- function(attr) {
  on.exit(close(tc), add = TRUE)
  tc <- textConnection(attr)
  sort_named_list(as.list(as.data.frame(read.dcf(tc))))
}

parse_span_events <- function(events) {
  events <- strsplit(events, "\n")[[1]]
  events <- sub("^\t", "", events)
  parse_spans(events)
}

# TODO: should parse this in the data frame, really....
parse_spans <- function(path) {
  if (length(path) == 1 && file.exists(path)) {
    lns <- readLines(path)
  } else {
    lns <- path
  }
  # remove whitespace from key
  lns <- sub("^  ([a-z0-9A-Z]+)\\s*", "\\1", lns)
  # record separators
  lns[lns %in% c("{", "}")] <- ""
  on.exit(close(tc), add = TRUE)
  tc <- textConnection(lns)
  d <- as.data.frame(read.dcf(tc, keep.white = "events"))
  names(d) <- trimws(names(d))
  if ("resources" %in% names(d)) {
    d[["resources"]] <- I(lapply(d$resources, parse_otel_attributes))
  }
  if ("attributes" %in% names(d)) {
    d[["attributes"]] <- I(lapply(d$attributes, parse_otel_attributes))
  }
  if ("events" %in% names(d)) {
    d[["events"]] <- I(lapply(d$events, parse_span_events))
  }
  spans <- lapply(apply(d, 1, c, simplify = FALSE), as.list)
  names(spans) <- map_chr(spans, function(x) x$name %||% "")
  spans
}

transform_tempdir <- function(x) {
  x <- sub(tempdir(), "<tempdir>", x, fixed = TRUE)
  x <- sub(normalizePath(tempdir()), "<tempdir>", x, fixed = TRUE)
  x <- sub(
    normalizePath(tempdir(), winslash = "/"),
    "<tempdir>",
    x,
    fixed = TRUE
  )
  x <- sub("\\R\\", "/R/", x, fixed = TRUE)
  x <- sub("[\\\\/]file[a-zA-Z0-9]+", "/<tempfile>", x)
  x <- sub("[A-Z]:.*Rtmp[a-zA-Z0-9]+[\\\\/]", "<tempdir>/", x)
  x
}

transform_srcref <- function(x) {
  x <- sub(
    "[ ]*at ([a-zA-Z0-9.]+/R/)?[-a-zA-Z0-9]+[.]R:[0-9]+:[0-9]+?",
    "",
    x
  )
  # remove trailing spaces
  x <- sub("\\s+$", "", x)
  x
}

subm <- function(x, id, regex, replacement) {
  w <- grep(id, x)[1]
  if (is.na(w)) {
    return(x)
  }
  x[w] <- sub(regex, replacement, x[w])
  x
}

transform_span_data <- function(x) {
  x <- subm(x, "trace_id\\s*:", "[0-9a-f]{32}", "<trace-id>")
  x <- subm(x, "span_id\\s*:", "[0-9a-f]{16}", "<span-id>")
  x <- subm(x, "os[.]type\\s*:", ": [a-z0-9]+", ": <os-type>")
  x <- subm(x, "process[.]pid\\s*:", ": [0-9]+", ": <process-pid>")
  x <- subm(
    x,
    "process[.]runtime[.]description\\s*:",
    ": R.*$",
    ": <r-version-string>"
  )
  x <- subm(
    x,
    "telemetry[.]sdk[.]version\\s*:",
    ": [.0-9]+",
    ": <otel-version>"
  )
  x <- subm(x, "process[.]runtime[.]version\\s*:", ": [.0-9]+", ": <r-version>")
  x <- subm(x, "process[.]owner\\s*:", ": [a-z0-9]+$", ": <username>")
  x <- subm(x, "start_time\\s*:", ": .*$", ": <timestamp>")
  x <- subm(x, "duration\\s*:", ": [.0-9]*(e-[0-9]+)?$", ": <duration>")
  x
}

transform_metric_data <- function(x) {
  x <- subm(x, "start_time\\s*:", ": .*$", "<timestamp>")
  x <- subm(x, "end_time\\s*:", ": .*$", "<timestamp>")
  x <- subm(x, "sample_ts\\s*:", ": .*$", "<timestamp>")
  x
}

sort_named_list <- function(x) {
  if (!is_named(x) || length(x) < 1) {
    structure(x, names = character())
  } else if (length(x) == 1) {
    x
  } else {
    x[order(names(x))]
  }
}

record_object <- function(expr, envir = parent.frame()) {
  unixpath <- function(x) gsub("\\", "/", x, fixed = TRUE)
  rds <- unixpath(tempfile(fileext = ".rds"))
  rs <- unixpath(tempfile(fileext = ".R"))
  defer(unlink(c(rds, rs)), envir = envir)
  writeLines(
    c(deparse(expr), sprintf("saveRDS(.Last.value, '%s')", rds)),
    con = rs
  )
  callr::rscript(rs, show = FALSE)
  readRDS(rds)
}

base_error <- local({
  err <- NULL
  function() {
    if (!is.null(err)) {
      return(err)
    }
    err <<- record_object(quote(
      tryCatch(stop("boo!"), error = function(e) e)
    ))
    err
  }
})

cli_error <- local({
  err <- NULL
  function() {
    if (!is.null(err)) {
      return(err)
    }
    err <<- record_object(quote(
      tryCatch(
        cli::cli_abort(c(
          "Something went wrong.",
          "x" = "You did not do the {.emph right} thing.",
          "i" = "You did {.emph another} thing instead."
        )),
        error = function(e) e
      )
    ))
    err
  }
})

processx_error <- local({
  err <- NULL
  function() {
    if (!is.null(err)) {
      return(err)
    }
    err <<- record_object(quote(
      tryCatch(
        processx::run("false"),
        error = function(e) e
      )
    ))
    err
  }
})

callr_error <- local({
  err <- NULL
  function() {
    if (!is.null(err)) {
      return(err)
    }
    err <<- record_object(quote(
      tryCatch(
        callr::r(function() 1 + ""),
        error = function(e) e
      )
    ))
    err
  }
})
