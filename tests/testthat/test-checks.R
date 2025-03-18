test_that("is.na", {
  expect_true(is_na(NA))
  expect_true(is_na(NA_character_))
  expect_true(is_na(NA_complex_))
  expect_true(is_na(NA_integer_))
  expect_true(is_na(NA_real_))

  expect_false(is_na(1))
  expect_false(is_na(NULL))
  expect_false(is_na(c(NA, NA)))
})

test_that("is_string", {
  expect_true(is_string("foo"))
  expect_true(is_string(c(name = "foo")))

  expect_false(is_string(1))
  expect_false(is_string(letters))
  expect_false(is_string(NA_character_))
  expect_false(is_string(character()))
})

test_that("as_timestamp", {
  t <- structure(1742214039.31794, class = c("POSIXct", "POSIXt"))
  expect_snapshot({
    as_timestamp(NULL)
    as_timestamp(t)
    as_timestamp(as.double(t))
    as_timestamp(as.integer(t))
  })

  b1 <- mtcars
  b2 <- Sys.Date()
  b3 <- c(Sys.time(), Sys.time())
  b4 <- as.POSIXct(NA)
  b5 <- 1:2
  b6 <- Sys.time()[integer()]
  expect_snapshot(error = TRUE, {
    as_timestamp(b1)
    as_timestamp(b2)
    as_timestamp(b3)
    as_timestamp(b4)
    as_timestamp(b5)
    as_timestamp(b6)
  })
})

test_that("as_span", {
  sp <- structure(list(), class = "otel_span")
  expect_snapshot({
    as_span(NULL)
    as_span(NA)
    as_span(NA_character_)
    as_span(sp)
  })

  b1 <- mtcars
  expect_snapshot(error = TRUE, {
    as_span(b1)
  })
})

test_that("as_choice", {
  expect_snapshot({
    as_choice(NULL, c(default = "foo", "bar"))
    as_choice("foo", c(default = "foo", "bar"))
    as_choice("bar", c(default = "foo", "bar"))
  })

  b1 <- "foobar"
  b2 <- 1:10
  expect_snapshot(error = TRUE, {
    as_choice(b1, c(default = "foo", "bar"))
    as_choice(b2, c(default = "foo", "bar"))
  })
})
