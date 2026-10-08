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
    do <- function(name = NULL) {
      trc <- otel::get_tracer("mytracer")
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

test_that("set_status, unset means it is set automatically", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    do <- function() {
      spn1 <- trc$start_local_active_span()
      spn1$set_status("Unset", description = "Testing preset Unset")
    }
    do()
  })[["traces"]]

  expect_equal(spns[[1]]$parent, "0000000000000000")
  expect_equal(spns[[1]]$status, "ok")
  expect_equal(spns[[1]]$description, "")
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

test_that("activate, deactivate manually", {
  # as used in ZCI
  env <- new.env()
  env$fun <- function() {
    fun2()
  }
  environment(env$fun) <- env
  env$fun2 <- function() {
    NULL
  }
  environment(env$fun2) <- env

  asNamespace("otel")$trace_env(env, name = "test")

  spns <- with_otel_record(function() {
    env$fun()
  })[["traces"]]

  expect_equal(names(spns), c("test::fun2", "test::fun"))
  expect_equal(spns[["test::fun2"]]$parent, spns[["test::fun"]]$span_id)
})

test_that("end_steady_time", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn <- trc$start_span("s", options = list(start_steady_time = 100))
    spn$end(options = list(end_steady_time = 105))
  })[["traces"]]

  expect_equal(spns[[1]]$duration, 5)
})

msg <- function(expr) {
  expect_message(val <- expr, class = "otel_error_message")
  val
}

test_that("span methods do not error", {
  trc_prv <- tracer_provider_memory_new()
  trc <- trc_prv$get_tracer("mytracer")
  spn <- trc$start_span("s")
  spn$end()

  local_mocked_bindings(ccall = function(...) stop("boo"))
  expect_s3_class(msg(spn$get_context()), "otel_span_context_noop")
  expect_false(msg(spn$is_valid()))
  expect_false(msg(spn$is_recording()))
  expect_identical(msg(spn$set_attribute("a", "b")), spn)
  expect_identical(msg(spn$add_event("e")), spn)
  expect_identical(msg(spn$add_link(spn)), spn)
  expect_identical(msg(spn$set_status("ok")), spn)
  expect_identical(msg(spn$update_name("new")), spn)
  expect_identical(msg(spn$end()), spn)
  expect_identical(msg(spn$record_exception(simpleError("boo"))), spn)
  expect_null(msg(spn$activate(NULL)))
  expect_null(msg(spn$deactivate(NULL)))
})

test_that("span methods do not error on bad arguments", {
  trc_prv <- tracer_provider_memory_new()
  trc <- trc_prv$get_tracer("mytracer")
  spn <- trc$start_span("s")
  on.exit(spn$end(), add = TRUE)
  expect_identical(msg(spn$set_attribute(1:2, "b")), spn)
  expect_identical(msg(spn$add_event(1:2)), spn)
  expect_identical(msg(spn$set_status("bogus")), spn)
  expect_identical(
    msg(spn$record_exception(simpleError("boo"), attributes = 1:3)),
    spn
  )
})

test_that("span methods error in dev mode", {
  trc_prv <- tracer_provider_memory_new()
  trc <- trc_prv$get_tracer("mytracer")
  spn <- span_base_new_dev(trc, NULL)
  local_mocked_bindings(ccall = function(...) stop("boo"))

  expect_error(spn$get_context())
  expect_error(spn$is_valid())
  expect_error(spn$is_recording())
  expect_error(spn$set_attribute("a", "b"))
  expect_error(spn$add_event("e"))
  expect_error(spn$add_link(spn))
  expect_error(spn$set_status("ok"))
  expect_error(spn$update_name("new"))
  expect_error(spn$end())
  expect_error(spn$record_exception(simpleError("boo")))
  expect_error(spn$activate(NULL))
  expect_error(spn$deactivate(NULL))
})

test_that("span context methods do not error", {
  local_mocked_bindings(ccall = function(...) stop("boo"))
  spc <- span_context_new(NULL)
  expect_false(msg(spc$is_valid()))
  expect_equal(msg(spc$get_trace_flags()), list())
  expect_equal(msg(spc$get_trace_id()), otel::invalid_trace_id)
  expect_equal(msg(spc$get_span_id()), otel::invalid_span_id)
  expect_false(msg(spc$is_remote()))
  expect_false(msg(spc$is_sampled()))
  expect_equal(
    msg(spc$to_http_headers()),
    structure(character(), names = character())
  )

  spc <- span_context_new_dev(NULL)
  expect_error(spc$is_valid())
  expect_error(spc$get_trace_flags())
  expect_error(spc$get_trace_id())
  expect_error(spc$get_span_id())
  expect_error(spc$is_remote())
  expect_error(spc$is_sampled())
  expect_error(spc$to_http_headers())
})

test_that("setup_dev_env", {
  env <- new.env()
  withr::local_envvar(OTEL_ENV = "dev")
  setup_dev_env(env)
  expect_identical(env$span_base_new, span_base_new_dev)
  expect_identical(env$span_context_new, span_context_new_dev)

  env <- new.env()
  withr::local_envvar(OTEL_ENV = NA_character_)
  setup_dev_env(env)
  expect_null(env$span_base_new)
})

test_that("R/span-dev.R is up to date", {
  skip_on_cran()
  root <- test_path("../..")
  skip_if_not(file.exists(file.path(root, "tools/template/dev.R")))
  out <- tempfile(fileext = ".R")
  on.exit(unlink(out), add = TRUE)
  withr::local_envvar(OTEL_DEV_API_OUTPUT_FILE = out)
  withr::local_dir(root)
  suppressMessages(source("tools/template/dev.R", local = new.env()))
  expect_equal(readLines(out), readLines("R/span-dev.R"))
})
