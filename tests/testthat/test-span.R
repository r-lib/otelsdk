test_that("named and unnamed spans", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_span()
    spn2 <- trc$start_span("my")
    spn2$end()
    spn1$end()
  })[["traces"]]

  expect_equal(spns[[1]]$name, "my")
  expect_equal(spns[[2]]$name, default_span_name)
})

test_that("close span automatically", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    do <- function(name = NULL) {
      spn1 <- trc$start_span(name)
    }
    do("1")
    do("2")
  })[["traces"]]

  # they are not stacked
  expect_equal(spns[[1]]$parent, "0000000000000000")
  expect_equal(spns[[2]]$parent, "0000000000000000")
  expect_equal(spns[[1]]$status, "ok")
  expect_equal(spns[[2]]$status, "ok")
})

test_that("close span automatically, on error", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    do <- function(name = NULL) {
      spn1 <- trc$start_span(name)
      stop("oops")
    }
    try(do("1"), silent = TRUE)
    try(do("2"), silent = TRUE)
  })[["traces"]]

  # they are not stacked
  expect_equal(spns[[1]]$parent, "0000000000000000")
  expect_equal(spns[[2]]$parent, "0000000000000000")
  expect_equal(spns[[1]]$status, "error")
  expect_equal(spns[[2]]$status, "error")
})

test_that("is_recording", {
  trc_prv <- tracer_provider_memory_new()
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  expect_true(spn1$is_recording())
})

test_that("set_attribute", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_span()
    spn2 <- trc$start_span("my")
    spn2$set_attribute("key", letters[1:3])
    spn1$set_attribute("key", "gone")
    spn2$end()
    spn1$set_attribute("key", "updated")
    spn1$end()
  })[["traces"]]

  expect_equal(spns[[1]]$attributes, list(key = letters[1:3]))
  expect_equal(spns[[2]]$attributes, list(key = "updated"))
})

test_that("add_event", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_span()
    spn2 <- trc$start_span("my")
    spn2$add_event("ev", attributes = list(key = "value", key2 = 1:5))
    spn2$add_event("ev2", attributes = list(x = letters[1:4]))
    spn2$end()
    spn1$end()
  })[["traces"]]

  expect_equal(length(spns[[1]]$events), 2)
  expect_equal(spns[[1]]$events[[1]]$name, "ev")
  expect_equal(
    sort_named_list(spns[[1]]$events[[1]]$attributes),
    list(key = "value", key2 = as.double(1:5))
  )
  expect_equal(spns[[1]]$events[[2]]$name, "ev2")
  expect_equal(
    spns[[1]]$events[[2]]$attributes,
    list(x = letters[1:4])
  )
})

test_that("set_status", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    do <- function() {
      spn1 <- trc$start_span()
      spn1$set_status("Unset", description = "Testing preset Unset")
    }
    do()
  })[["traces"]]

  expect_equal(spns[[1]]$parent, "0000000000000000")
  expect_equal(spns[[1]]$status, "unset")
  expect_equal(spns[[1]]$description, "Testing preset Unset")
})

test_that("update_name", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_span()
    spn1$update_name("good")
    spn1$end()
  })[["traces"]]

  expect_equal(spns[[1]]$name, "good")
})

test_that("record_exception", {
  # output from cli / processx / rlang might change
  skip_on_cran()
  error_obj <- base_error()
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_span()
    spn1$record_exception(error_obj)
    spn1$end()
  })[["traces"]]

  expect_equal(spns[[1]][["events"]][[1]][["name"]], "exception")
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
    c("simpleError", "error", "condition")
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

test_that("create a root span", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_span("1")
    spn2 <- trc$start_span("2", options = list(parent = NA))
    spn2$end()
    spn1$end()
  })[["traces"]]

  expect_equal(length(spns), 2)
  expect_equal(spns[[1]]$parent, otel::invalid_span_id)
  expect_equal(spns[[2]]$parent, otel::invalid_span_id)
})
