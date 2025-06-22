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

  if (.trim) {
    text <- trim(text)
  }

  f <- function(expr) {
    eval_func <- as.character(.transformer(expr, .envir) %||% character())
  }

  res <- ccall(glue_, text, f, .open, .close, .cli)

  paste0(unlist(res), collapse = "")
}

identity_transformer <- function(text, envir) {
  eval(parse(text = text, keep.source = FALSE), envir)
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
