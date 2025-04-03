parse_span_attributes <- function(attr) {
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
    d[["resources"]] <- I(lapply(d$resources, parse_span_attributes))
  }
  if ("attributes" %in% names(d)) {
    d[["attributes"]] <- I(lapply(d$attributes, parse_span_attributes))
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
    "<tempdir>", x,
    fixed = TRUE
  )
  x <- sub("\\R\\", "/R/", x, fixed = TRUE)
  x <- sub("[\\\\/]file[a-zA-Z0-9]+", "/<tempfile>", x)
  x <- sub("[A-Z]:.*Rtmp[a-zA-Z0-9]+[\\\\/]", "<tempdir>/", x)
  x
}

sort_named_list <- function(x) {
  if (!is_named(x)) {
    x
  } else {
    x[order(names(x))]
  }
}
