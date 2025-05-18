test_that("named and unnamed spans", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  spn2 <- trc$start_span("my")
  spn2$end()
  spn1$end()
  trc$flush()

  spns <- parse_spans(tmp)
  expect_equal(spns[[1]]$name, "my")
  expect_equal(spns[[2]]$name, default_span_name)
})

test_that("close span automatically", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  do <- function(name = NULL) {
    spn1 <- trc$start_span(name)
  }
  do("1")
  do("2")
  trc$flush()

  spns <- parse_spans(tmp)
  # they are not stacked
  expect_equal(spns[[1]]$parent_span_id, "0000000000000000")
  expect_equal(spns[[2]]$parent_span_id, "0000000000000000")
  expect_equal(spns[[1]]$status, "Ok")
  expect_equal(spns[[2]]$status, "Ok")
})

test_that("close span automatically, on error", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  do <- function(name = NULL) {
    spn1 <- trc$start_span(name)
    stop("oops")
  }
  try(do("1"), silent = TRUE)
  try(do("2"), silent = TRUE)
  trc$flush()

  spns <- parse_spans(tmp)
  # they are not stacked
  expect_equal(spns[[1]]$parent_span_id, "0000000000000000")
  expect_equal(spns[[2]]$parent_span_id, "0000000000000000")
  expect_equal(spns[[1]]$status, "Error")
  expect_equal(spns[[2]]$status, "Error")
})

test_that("is_recording", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  expect_true(spn1$is_recording())
})

test_that("set_attribute", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  spn2 <- trc$start_span("my")
  spn2$set_attribute("key", letters[1:3])
  spn1$set_attribute("key", "gone")
  spn2$end()
  spn1$set_attribute("key", "updated")
  spn1$end()
  trc$flush()

  spns <- parse_spans(tmp)
  expect_equal(spns[[1]]$attributes, list(key = "[a,b,c]"))
  expect_equal(spns[[2]]$attributes, list(key = "updated"))
})

test_that("add_event", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  spn2 <- trc$start_span("my")
  spn2$add_event("ev", attributes = list(key = "value", key2 = 1:5))
  spn2$add_event("ev2", attributes = list(x = letters[1:4]))
  spn2$end()
  spn1$end()
  trc$flush()

  spns <- parse_spans(tmp)
  expect_equal(length(spns[[1]]$events), 2)
  expect_equal(spns[[1]]$events[[1]]$name, "ev")
  expect_equal(
    spns[[1]]$events[[1]]$attributes,
    list(key = "value", key2 = "[1,2,3,4,5]")
  )
  expect_equal(spns[[1]]$events[[2]]$name, "ev2")
  expect_equal(
    spns[[1]]$events[[2]]$attributes,
    list(x = "[a,b,c,d]")
  )
})

test_that("set_status", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  do <- function() {
    spn1 <- trc$start_span()
    spn1$set_status("Unset", description = "Testing preset Unset")
  }
  do()
  trc$flush()

  spns <- parse_spans(tmp)
  expect_equal(spns[[1]]$parent_span_id, "0000000000000000")
  expect_equal(spns[[1]]$status, "Unset")
  expect_equal(spns[[1]]$description, "Testing preset Unset")
})

test_that("update_name", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  spn1$update_name("good")
  spn1$end()
  trc$flush()
  spns <- parse_spans(tmp)
  expect_equal(spns[[1]]$name, "good")
})

test_that("record_exception", {
  # output from cli / processx / rlang might change
  skip_on_cran()
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  spn1$record_exception(base_error())
  spn1$end()
  trc$flush()
  spns <- parse_spans(tmp)
  expect_equal(names(spns[[1]]$events), "exception")
  expect_match(
    spns[[1]]$events[[1]]$attributes$exception.message,
    "boo!",
    fixed = TRUE
  )
  expect_match(
    spns[[1]]$events[[1]]$attributes$exception.stacktrace,
    "doTryCatch"
  )
  expect_equal(
    spns[[1]]$events[[1]]$attributes$exception.type,
    "[simpleError,error,condition]"
  )
})

test_that("format_exception", {
  expect_snapshot({
    format_exception(base_error())
  })
  expect_snapshot(
    {
      format_exception(cli_error())
    },
    transform = transform_srcref
  )
  expect_snapshot({
    format_exception(processx_error())
  })
  expect_snapshot({
    format_exception(callr_error())
  })
})
