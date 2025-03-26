parse_spans <- function(path) {
  lns <- readLines(path)
  # split by }
  lns[1] <- "}"
  lns <- lns[-length(lns)]
  lns <- lns[lns != "{"]
  spans <- split(lns, cumsum(lns == "}"))
  spans <- lapply(spans, function(x) x[-1])
  spans <- lapply(spans, function(x) {
    key <- trimws(sub(":.*$", "", x))
    val <- trimws(sub("^[^:]*:", "", x))
    structure(as.list(val), names = key)
  })
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
