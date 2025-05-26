# Compared to glue::glue(), these are fixed:
# - .sep = ""
# - .trim = TRUE
# - .null = character()
# - .literal = TRUE
# - .comment = ""
#
# we also don't allow passing in data as arguments, and `text` is
# a single argument, no need to `paste()` etc.

glue <- function(
  text,
  .envir = parent.frame(),
  .transformer = identity_transformer,
  .open = "{",
  .close = "}",
  .cli = FALSE,
  .trim = TRUE
) {
  text <- paste0(text, collapse = "")

  if (length(text) < 1L) {
    return("")
  }

  if (is.na(text)) {
    return("")
  }

  if (.trim) {
    text <- trim(text)
  }

  f <- function(expr) {
    eval_func <- as.character(.transformer(expr, .envir) %||% character())
  }

  res <- .Call(glue_, text, f, .open, .close, .cli)

  res <- drop_null(res)
  if (any(lengths(res) == 0L)) {
    return(character(0L))
  }

  res[] <- lapply(res, function(x) replace(x, is.na(x), "NA"))

  do.call(paste0, res)
}

identity_transformer <- function(text, envir) {
  eval(parse(text = text, keep.source = FALSE), envir)
}

drop_null <- function(x) {
  x[!vapply(x, is.null, logical(1L))]
}

create_collector_transformer <- function(record) {
  record
  function(text, envir) {
    val <- eval(parse(text = text, keep.source = FALSE), envir)
    val <- as_otel_attribute_value(val)
    record[[text]] <- val
    eval(parse(text = text, keep.source = FALSE), envir)
  }
}

extract_otel_attributes <- function(
  text,
  .envir = parent.frame(),
  .attributes = NULL,
  .transformer = NULL,
  ...
) {
  record <- as.environment(.attributes %||% new.env(parent = emptyenv()))
  .transformer <- .transformer %||% create_collector_transformer(record)
  prsd <- glue(text, .envir = .envir, .transformer = .transformer, ...)
  list(text = prsd, attributes = as.list(record))
}
