test_that("sessions", {
  expect_active_span <- function(id) {
    if (inherits(id, "otel_span")) {
      id <- id$get_context()$get_span_id()
    }
    expect_equal(otel_current_session()$span_id, id)
  }
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")

    expect_active_span("")
    spn0 <- trc$start_span("0") # 0
    expect_active_span(spn0)

    sess1 <- trc$start_session("sess1") # 1
    expect_active_span(sess1)
    spn1 <- trc$start_span("1") # 1
    expect_active_span(spn1)

    sess1$deactivate_session()
    expect_active_span(spn0)
    sess2 <- trc$start_session("sess2") # 2
    expect_active_span(sess2)
    spn2 <- trc$start_span("2") # 2
    expect_active_span(spn2)

    sess1$activate_session() # 1
    expect_active_span(spn1)
    spn11 <- trc$start_span("11") # 1
    expect_active_span(spn11)
    sess1$deactivate_session() # 2
    sess2$deactivate_session() # 0
    expect_active_span(spn0)
    spn11$end() # 0
    expect_active_span(spn0)
    spn1$end() # 0
    expect_active_span(spn0)
    sess1$end()
    expect_active_span(spn0)

    spn2$end() # 2
    expect_active_span(spn0)

    spn01 <- trc$start_span("01") # 0
    expect_active_span(spn01)
    spn01$end() # 0
    expect_active_span(spn0)
    spn0$end() # 0
    expect_active_span("")

    sess2$end()
    expect_active_span("")
  })[["traces"]]

  expect_equal(spns[["0"]]$parent, "0000000000000000")
  expect_equal(spns[["1"]]$parent, spns[["sess1"]]$span_id)
  expect_equal(spns[["2"]]$parent, spns[["sess2"]]$span_id)
  expect_equal(spns[["11"]]$parent, spns[["1"]]$span_id)
  expect_equal(spns[["01"]]$parent, spns[["0"]]$span_id)
})

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

  expect_equal(sort(names(spns)), sort(c(0:3, "01", "02", "sess", "serial")))
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

  serial2 <- function() {
    otel::start_span("serial2")
  }

  serial <- function() {
    ser <- otel::start_span("serial")
    serial2()
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
    expect_equal(otel_current_session()$span_id, id)
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
    opts$otel_session <- otel::start_session("sess")
    s1 <- otel::start_span("1", session = opts$otel_session)
    opts
  }

  work_sess <- function(opts) {
    sp2 <- otel::start_span("2", session = opts$otel_session)
    serial()
  }

  end_sess <- function(opts) {
    sp3 <- otel::start_span("3", session = opts$otel_session)
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
  create_inner_span <- function(name, tracer, session = NULL) {
    tracer$start_session(name, session = session)
  }

  spans <- otelsdk::with_otel_record({
    trc <- otel::get_tracer("test")

    # This example works with start_span(), but fails with start_session().
    outer <- trc$start_session("outer", options = list(parent = NA))

    # Emulate two "concurrent" operations that create session spans.
    inner1 <- create_inner_span("inner1", trc, session = outer)
    inner2 <- create_inner_span("inner2", trc, session = outer)

    inner1$end()
    inner2$end()
    outer$end()
  })[["traces"]]

  expect_equal(spans[["inner1"]]$parent, spans[["outer"]]$span_id)
  expect_equal(spans[["inner2"]]$parent, spans[["outer"]]$span_id)
})

test_that("nested sessions 2", {
  create_inner_span <- function(name, tracer) {
    tracer$start_session(name)
  }

  spans <- otelsdk::with_otel_record({
    trc <- otel::get_tracer("test")

    # This example works with start_span(), but fails with start_session().
    outer <- trc$start_session("outer", options = list(parent = NA))

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
