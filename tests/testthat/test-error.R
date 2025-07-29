test_that("cnd", {
  one <- 1
  two <- 2
  boo <- function() {
    cnd("This is {one} {two}")
  }
  expect_snapshot(boo())
})

test_that("caller_arg", {
  # testted well in test-checks.R
  expect_true(TRUE)
})

test_that("as_caller_arg", {
  # testted well in test-checks.R
  expect_true(TRUE)
})

test_that("as.character.otel_caller_arg", {
  # testted well in test-checks.R
  expect_true(TRUE)
})

test_that("caller_env", {
  # testted well in test-checks.R
  expect_true(TRUE)
})

test_that("frame_get", {
  # special cases
  skip_on_cran()
  expect_null(frame_get(.GlobalEnv))
  fake(frame_get, "evalq", function(...) list())
  expect_null(frame_get(environment(), sys.frame))
})
