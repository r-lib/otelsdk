test_that("named and unnamed spans", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_local_active_span()
    spn2 <- trc$start_local_active_span("my")
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
      spn1 <- trc$start_local_active_span(name)
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
      spn1 <- trc$start_local_active_span(name)
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
  spn1 <- trc$start_local_active_span()
  expect_true(spn1$is_recording())
})

test_that("set_attribute", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_local_active_span()
    spn2 <- trc$start_local_active_span("my")
    spn2$set_attribute("key", letters[1:3])
    spn1$set_attribute("key", "gone")
    spn2$end()
    spn1$set_attribute("key", "updated")
    spn1$end()
  })[["traces"]]

  expect_equal(
    spns[[1]]$attributes,
    structure(list(key = letters[1:3]), class = "otel_attributes")
  )
  expect_equal(
    spns[[2]]$attributes,
    structure(list(key = "updated"), class = "otel_attributes")
  )
})

test_that("add_event", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_local_active_span()
    spn2 <- trc$start_local_active_span("my")
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
    structure(list(x = letters[1:4]), class = "otel_attributes")
  )
})

test_that("set_status", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    do <- function() {
      spn1 <- trc$start_local_active_span()
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
    spn1 <- trc$start_local_active_span()
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
    spn1 <- trc$start_local_active_span()
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
  expect_snapshot(
    {
      format_exception(base_error())
    },
    transform = function(x) trimws(x, which = "right")
  )
  expect_snapshot(
    {
      format_exception(cli_error())
    },
    transform = function(x) trimws(transform_srcref(x), which = "right")
  )
  expect_snapshot(
    {
      format_exception(processx_error())
    },
    transform = function(x) trimws(x, which = "right")
  )
  expect_snapshot(
    {
      format_exception(callr_error())
    },
    transform = function(x) trimws(x, which = "right")
  )
})

test_that("create a root span", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_local_active_span("1")
    spn2 <- trc$start_local_active_span("2", options = list(parent = NA))
    spn2$end()
    spn1$end()
  })[["traces"]]

  expect_equal(length(spns), 2)
  expect_equal(spns[[1]]$parent, otel::invalid_span_id)
  expect_equal(spns[[2]]$parent, otel::invalid_span_id)
})

test_that("get_context", {
  spid1 <- spid2 <- NULL
  spns <- with_otel_record(function() {
    trc <- otel::get_tracer()
    spn <- trc$start_local_active_span("1")
    spid1 <<- spn$get_context()$get_span_id()
    spid2 <<- trc$get_active_span_context()$get_span_id()
  })[["traces"]]

  expect_false(is.null(spid1))
  expect_false(is.null(spid2))
  expect_equal(spid1, spid2)
  expect_equal(spid1, spns[["1"]][["span_id"]])
})

test_that("is_valid", {
  spns <- with_otel_record(function() {
    trc <- otel::get_tracer()
    spn <- trc$start_local_active_span("1")
    expect_true(spn$is_valid())
  })[["traces"]]
})

test_that("span_context", {
  spns <- with_otel_record(function() {
    trc <- otel::get_tracer()
    spn <- trc$start_local_active_span("1")
    ctx <- spn$get_context()
    expect_true(ctx$is_valid())
    expect_snapshot(
      ctx$get_trace_flags(),
      transform = function(x) trimws(x, which = "right")
    )
    actx <- trc$get_active_span_context()
    expect_equal(actx$get_trace_id(), ctx$get_trace_id())
    expect_false(ctx$is_remote())
    expect_true(ctx$is_sampled())
  })[["traces"]]
})

# test_that("span_context$to_http_headers", {})
