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
