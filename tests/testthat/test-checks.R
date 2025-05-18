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

test_that("is_named", {
  expect_true(is_named(NULL))
  expect_true(is_named(character()))
  expect_true(is_named(c(a = "1")))
  expect_true(is_named(c(a = 1)))

  expect_false(is_named(1))
  expect_false(is_named(letters))
  expect_false(is_named(c(a = 1, 2, c = 3)))
  expect_false(is_named(structure(1:3, names = c(NA, "b", "c"))))
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

test_that("as_env", {
  expect_null(as_env(NULL))
  e <- new.env()
  expect_equal(as_env(e), e)

  e1 <- 1:10
  e2 <- NULL
  expect_snapshot(error = TRUE, {
    as_env(e1)
    as_env(e2, null = FALSE)
  })
})

test_that("as_string", {
  expect_null(as_string(NULL))
  expect_equal(as_string("foo"), "foo")
  expect_equal(as_string(c(a = "1")), c(a = "1"))

  s1 <- 1
  s2 <- character()
  s3 <- letters[1:2]
  s4 <- NULL
  expect_snapshot(error = TRUE, {
    as_string(s1)
    as_string(s2)
    as_string(s3)
    as_string(s4, null = FALSE)
  })
})

test_that("as_span_attribute_value", {
  expect_equal(as_span_attribute_value("a"), "a")
  expect_equal(as_span_attribute_value(TRUE), TRUE)
  expect_equal(as_span_attribute_value(1), 1)
  expect_equal(as_span_attribute_value(1L), 1L)

  v1 <- list()
  v2 <- c("a", NA)
  v3 <- c(TRUE, NA)
  v4 <- c(1, NA)
  v5 <- c(1L, NA)
  expect_snapshot(error = TRUE, {
    as_span_attribute_value(v1)
    as_span_attribute_value(v2)
    as_span_attribute_value(v3)
    as_span_attribute_value(v4)
    as_span_attribute_value(v5)
  })
})

test_that("as_span_attributes", {
  expect_null(as_span_attributes(NULL))
  v <- list(a = "a", b = TRUE, c = 1, d = 1L)
  expect_equal(as_span_attributes(v), v)

  v1 <- 1:10
  v2 <- list(1:10)
  v3 <- list(a = list())
  v4 <- list(a = c(1, NA, 2))
  expect_snapshot(error = TRUE, {
    as_span_attributes(v1)
    as_span_attributes(v2)
    as_span_attributes(v3)
    as_span_attributes(v4)
  })
})

test_that("as_span_link", {
  sl <- structure(list(xptr = "ptr"), class = "otel_span")
  expect_equal(as_span_link(sl), list("ptr", list()))
  expect_equal(as_span_link(list(sl)), list("ptr", list()))
  attr <- list(a = "a", b = TRUE, c = 1, d = 1L)
  expect_equal(
    as_span_link(c(list(sl), attr)),
    list("ptr", attr)
  )

  expect_snapshot(error = TRUE, {
    link <- 1:10
    as_span_link(link)
    link <- list(sl, "foo", "bar")
    as_span_link(link)
    link <- list(sl, a = "1", b = c(1, NA))
    as_span_link(link)
  })
})

test_that("as_span_links", {
  sl <- structure(list(xptr = "ptr"), class = "otel_span")
  expect_equal(
    as_span_links(list(sl)),
    list(list("ptr", list()))
  )
  expect_equal(
    as_span_links(list(list(sl, a = "1"))),
    list(list("ptr", list(a = "1")))
  )

  expect_snapshot(error = TRUE, {
    links <- 1:10
    as_span_links(links)
    links <- list(1:10)
    as_span_links(links)
  })
})

test_that("as_span_options", {
  t <- Sys.time()
  expect_equal(as_span_options(NULL), list(kind = 0L))
  expect_equal(
    as_span_options(list(start_system_time = t)),
    list(start_system_time = as.double(t), kind = 0L)
  )
  expect_equal(
    as_span_options(list(start_steady_time = t)),
    list(start_steady_time = as.double(t), kind = 0L)
  )
  p <- structure(list(xptr = "ptr"), class = "otel_span")
  expect_equal(
    as_span_options(list(parent = p)),
    list(parent = "ptr", kind = 0L)
  )
  expect_equal(
    as_span_options(list(kind = "client")),
    list(kind = 2L)
  )

  expect_snapshot(error = TRUE, {
    options <- 1:10
    as_span_options(options)
    options <- list("foo")
    as_span_options(options)
    options <- list(kind = "internal", foo = "notgood")
    as_span_options(options)
    options <- list(kind = 10)
    as_span_options(options)
  })
})

test_that("as_end_span_options", {
  t <- Sys.time()
  expect_equal(as_end_span_options(NULL), list())
  expect_equal(
    as_end_span_options(list(end_steady_time = t)),
    list(end_steady_time = as.double(t))
  )

  expect_snapshot(error = TRUE, {
    options <- 1:10
    as_end_span_options(options)
    options <- list("foo")
    as_end_span_options(options)
    options <- list(end_steady_time = t, foo = "notgood")
    as_end_span_options(options)
    options <- list(end_steady_time = "bad")
    as_end_span_options(options)
  })
})

test_that("as_output_file", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  expect_equal(as_output_file(NULL), NULL)
  expect_false(file.exists(tmp))
  expect_equal(as_output_file(tmp), tmp)
  expect_true(file.exists(tmp))

  tmp2 <- tempfile()
  on.exit(unlink(tmp2, recursive = TRUE), add = TRUE)
  tmp3 <- file.path(tmp2, "output")
  expect_snapshot(error = TRUE, transform = transform_tempdir, {
    as_output_file(tmp3)
  })

  dir.create(tmp2)
  file.create(tmp3)
  Sys.chmod(tmp3, "0100")
  expect_snapshot(error = TRUE, transform = transform_tempdir, {
    as_output_file(tmp3)
  })
})
