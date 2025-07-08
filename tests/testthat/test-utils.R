test_that("%||%", {
  expect_equal(NULL %||% "foo", "foo")
  expect_equal("foo" %||% stop(), "foo")
})

test_that("is_true", {
  expect_true(is_true(TRUE))
  expect_true(is_true(c(foo = TRUE)))
  expect_true(is_true(structure(TRUE, class = "ccc")))

  expect_false(is_true(1))
  expect_false(is_true(logical()))
  expect_false(is_true(c(TRUE, TRUE)))
  expect_false(is_true(NA))
  expect_false(is_true(FALSE))
})

test_that("is_false", {
  expect_true(is_false(FALSE))
  expect_true(is_false(c(foo = FALSE)))
  expect_true(is_false(structure(FALSE, class = "ccc")))

  expect_false(is_false(1))
  expect_false(is_false(logical()))
  expect_false(is_false(c(FALSE, FALSE)))
  expect_false(is_false(NA))
  expect_false(is_false(TRUE))
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

test_that("get_env", {
  withr::local_envvar(TESTENVVAR = "testenvvar")
  expect_equal(get_env("TESTENVVAR"), "testenvvar")
  withr::local_envvar(TESTENVVAR = NA_character_)
  expect_null(get_env("TESTENVVAR"))
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
    ccall(otel_fail)
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

test_that("get_current_error, failure", {
  fake(get_current_error, "ccall", function(...) stop("Shucks."))
  expect_snapshot({
    get_current_error()
  })
  fake(get_current_error, "ccall", list(FALSE))
  expect_snapshot({
    get_current_error()
  })
})

test_that("plural", {
  expect_equal(plural(0), "s")
  expect_equal(plural(1), "")
  expect_equal(plural(2), "s")
})

test_that("find_tracer_name", {
  fake(find_tracer_name, "otel::default_tracer_name", list(name = "good"))
  expect_equal(find_tracer_name(), "good")
})

test_that("empty_atomic_as_null", {
  expect_equal(empty_atomic_as_null(character()), NULL)
  expect_equal(empty_atomic_as_null(logical()), NULL)
  expect_equal(empty_atomic_as_null(integer()), NULL)
  expect_equal(empty_atomic_as_null(double()), NULL)
  expect_equal(empty_atomic_as_null(list()), list())
})
