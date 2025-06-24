test_that("sessions auto-close", {
  expect_active_span <- function(id) {
    if (inherits(id, "otel_span")) {
      id <- id$get_context()$get_span_id()
    }
    active <- otel::get_active_span_context()$get_span_id()
    expect_equal(active, id)
  }

  serial2 <- function() {
    otel::start_span("serial2")
  }

  serial <- function() {
    ser <- otel::start_span("serial")
    serial2()
  }

  start_sess <- function() {
    opts <- new.env(parent = emptyenv())
    opts$otel_session <- otel::start_span("sess", scope = NULL)
    s1 <- otel::start_span("1")
    opts
  }

  work_sess <- function(opts) {
    opts$otel_session$activate()
    sp2 <- otel::start_span("2")
    serial()
  }

  end_sess <- function(opts) {
    opts$otel_session$activate()
    sp3 <- otel::start_span("3")
    opts$otel_session$end()
  }

  spns <- with_otel_record({
    fun <- function() {
      spn0 <- otel::start_span("0")
      opts <- start_sess()
      spn01 <- otel::start_span("01")
      work_sess(opts)
      spn02 <- otel::start_span("02")
      end_sess(opts)
    }
    fun()
  })[["traces"]]

  expect_equal(
    sort(names(spns)),
    sort(c(0:3, "01", "02", "sess", "serial", "serial2"))
  )
  expect_equal(spns[["0"]]$parent, otel::invalid_span_id)
  expect_equal(spns[["1"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["2"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["3"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["01"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["02"]]$parent, spns[["01"]]$span_id)
  expect_equal(spns[["sess"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["serial"]]$parent, spns[["2"]]$span_id)
  expect_equal(spns[["serial2"]]$parent, spns[["serial"]]$span_id)
})

test_that("sessions, suggested practices", {
  expect_active_span <- function(id) {
    if (inherits(id, "otel_span")) {
      id <- id$get_context()$get_span_id()
    }
    active <- otel::get_active_span_context()$get_span_id()
    expect_equal(active, id)
  }

  serial2 <- function() {
    otel::start_span("serial2")
  }

  serial <- function() {
    ser <- otel::start_span("serial")
    serial2()
  }

  start_sess <- function() {
    opts <- new.env(parent = emptyenv())
    opts$otel_session <- otel::start_span("sess", scope = NULL)
    s1 <- otel::start_span("1")
    opts
  }

  work_sess <- function(opts) {
    otel::local_active_span(opts$otel_session)
    sp2 <- otel::start_span("2")
    serial()
  }

  end_sess <- function(opts) {
    otel::local_active_span(opts$otel_session)
    sp3 <- otel::start_span("3")
    opts$otel_session$end()
  }

  spns <- with_otel_record({
    fun <- function() {
      spn0 <- otel::start_span("0")
      opts <- start_sess()
      spn01 <- otel::start_span("01")
      work_sess(opts)
      spn02 <- otel::start_span("02")
      end_sess(opts)
    }
    fun()
  })[["traces"]]

  expect_equal(
    sort(names(spns)),
    sort(c(0:3, "01", "02", "sess", "serial", "serial2"))
  )
  expect_equal(spns[["0"]]$parent, otel::invalid_span_id)
  expect_equal(spns[["1"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["2"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["3"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["01"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["02"]]$parent, spns[["01"]]$span_id)
  expect_equal(spns[["sess"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["serial"]]$parent, spns[["2"]]$span_id)
  expect_equal(spns[["serial2"]]$parent, spns[["serial"]]$span_id)
})

test_that("nested sessions", {
  create_inner_span <- function(name, tracer) {
    tracer$start_span(name, scope = NULL)
  }

  spans <- otelsdk::with_otel_record({
    trc <- otel::get_tracer("test")

    outer <- trc$start_span("outer", scope = NULL, options = list(parent = NA))

    # Emulate two "concurrent" operations that create session spans.
    inner1 <- create_inner_span("inner1", trc)
    inner2 <- create_inner_span("inner2", trc)

    inner1$end()
    inner2$end()
    outer$end()
  })[["traces"]]

  expect_equal(spans[["inner1"]]$parent, spans[["outer"]]$span_id)
  expect_equal(spans[["inner2"]]$parent, spans[["outer"]]$span_id)
})
