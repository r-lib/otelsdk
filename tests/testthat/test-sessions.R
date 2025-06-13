test_that("sessions, manually closing everything", {
  expect_active_span <- function(id) {
    if (inherits(id, "otel_span")) {
      id <- id$get_context()$get_span_id()
    }
    expect_equal(otel_current_session()$span_id, id)
  }

  serial <- function() {
    ser <- otel::start_span("serial")
    ser$end()
  }

  start_sess <- function() {
    opts <- new.env(parent = emptyenv())
    opts$otel_session <- otel::start_session("sess")
    s1 <- otel::start_span("1")
    s1$end()
    opts$otel_session$deactivate_session()
    opts
  }

  work_sess <- function(opts) {
    opts$otel_session$activate_session()
    sp2 <- otel::start_span("2")
    serial()
    sp2$end()
    opts$otel_session$deactivate_session()
  }

  end_sess <- function(opts) {
    opts$otel_session$activate_session()
    sp3 <- otel::start_span("3")
    sp3$end()
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

  nms <- map_chr(spns, "[[", "name")
  names(spns) <- nms
  expect_equal(sort(nms), sort(c(0:3, "01", "02", "sess", "serial")))
  expect_equal(spns[["0"]]$parent, otel::invalid_span_id)
  expect_equal(spns[["1"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["2"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["3"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["01"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["02"]]$parent, spns[["01"]]$span_id)
  expect_equal(spns[["sess"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["serial"]]$parent, spns[["2"]]$span_id)
})

test_that("sessions auto-close", {
  expect_active_span <- function(id) {
    if (inherits(id, "otel_span")) {
      id <- id$get_context()$get_span_id()
    }
    expect_equal(otel_current_session()$span_id, id)
  }

  serial <- function() {
    ser <- otel::start_span("serial")
  }

  start_sess <- function() {
    opts <- new.env(parent = emptyenv())
    opts$otel_session <- otel::start_session("sess")
    s1 <- otel::start_span("1")
    opts
  }

  work_sess <- function(opts) {
    opts$otel_session$activate_session()
    sp2 <- otel::start_span("2")
    serial()
  }

  end_sess <- function(opts) {
    opts$otel_session$activate_session()
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

  nms <- map_chr(spns, "[[", "name")
  names(spns) <- nms
  expect_equal(sort(nms), sort(c(0:3, "01", "02", "sess", "serial")))
  expect_equal(spns[["0"]]$parent, otel::invalid_span_id)
  expect_equal(spns[["1"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["2"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["3"]]$parent, spns[["sess"]]$span_id)
  expect_equal(spns[["01"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["02"]]$parent, spns[["01"]]$span_id)
  expect_equal(spns[["sess"]]$parent, spns[["0"]]$span_id)
  expect_equal(spns[["serial"]]$parent, spns[["2"]]$span_id)
})
