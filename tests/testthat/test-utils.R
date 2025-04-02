test_that("%||%", {
  expect_equal(NULL %||% "foo", "foo")
  expect_equal("foo" %||% stop(), "foo")
})

test_that("defer", {
  x <- NULL
  do <- function() {
    defer(x <<- 1)
  }
  do()
  expect_equal(x, 1)
})

test_that("map_chr", {
  expect_equal(
    map_chr(seq_along(letters), function(i) letters[[i]]),
    letters
  )
  expect_equal(
    map_chr(1:3, function(i) c("x" = letters[i])),
    letters[1:3]
  )
  expect_equal(
    map_chr(c(a = 1, b = 2, c = 3), function(i) letters[i]),
    c("a" = "a", "b" = "b", "c" = "c")
  )

  expect_snapshot(error = TRUE, {
    map_chr(1:3, sqrt)
  })
})

test_that("map_lgl", {
  expect_equal(
    map_lgl(1:5, function(i) i %% 2 == 0),
    c(FALSE, TRUE, FALSE, TRUE, FALSE)
  )
  expect_equal(
    map_lgl(c(a = 1, b = 2), function(i) i %% 2 == 0),
    c(a = FALSE, b = TRUE)
  )
})

test_that("get_current_error", {
  skip_on_cran()

  # plain error string
  err <- NULL
  f <- function() {
    on.exit(err <<- get_current_error(), add = TRUE)
    stop("boo!")
  }
  tryCatch(f(), error = function(e) NULL)
  expect_equal(
    err,
    list(tried = TRUE, success = TRUE, object = "boo!", error = NULL)
  )

  # error object
  err <- NULL
  errobj <- structure(
    list(message = "booo!"),
    class = c("custom_error", "error", "condition")
  )
  f <- function() {
    on.exit(err <<- get_current_error(), add = TRUE)
    stop(errobj)
  }
  tryCatch(f(), error = function(e) NULL)
  expect_equal(
    err,
    list(tried = TRUE, success = TRUE, object = errobj, error = NULL)
  )

  # error from C code
  err <- NULL
  f <- function() {
    on.exit(err <<- get_current_error(), add = TRUE)
    .Call(otel_fail)
  }
  tryCatch(f(), error = function(e) NULL)
  expect_equal(
    err,
    list(tried = TRUE, success = TRUE, object = "from C", error = NULL)
  )

  # no error
  expect_snapshot({
    get_current_error()
  })

  # no error, from on.exit()
  err <- NULL
  f <- function() {
    on.exit(err <<- get_current_error(), add = TRUE)
    "success!"
  }
  tryCatch(f(), error = function(e) NULL)
  expect_snapshot({
    err
  })
})
