test_that("tracer_new", {
  trc_prv <- tracer_provider_memory_new()
  expect_equal(
    class(trc_prv),
    c("otel_tracer_provider_memory", "otel_tracer_provider")
  )
  trc <- trc_prv$get_tracer("mytracer")
  expect_equal(class(trc), "otel_tracer")
})

test_that("start_span", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_span("spn1")
    expect_equal(class(spn1), "otel_span")
    spn2 <- trc$start_span("spn2")
    spn2$end()
    spn1$end()
  })[["traces"]]

  expect_equal(length(spns), 2)
  expect_equal(spns[[1]]$name, "spn2")
  expect_equal(spns[[2]]$name, "spn1")
  expect_match(spns[[1]]$trace_id, "^[0-9a-f]+$")
  expect_equal(spns[[1]]$trace_id, spns[[2]]$trace_id)
  expect_match(spns[[1]]$span_id, "^[0-9a-f]+$")
  expect_match(spns[[2]]$span_id, "^[0-9a-f]+$")
  expect_match(spns[[1]]$parent, "^[0-9a-f]+$")
  expect_equal(spns[[2]]$parent, "0000000000000000")
  expect_equal(spns[[1]]$parent, spns[[2]]$span_id)
  expect_true(
    Sys.time() - spns[[1]]$start_time < as.difftime(3, units = "secs")
  )
  expect_true(spns[[1]]$duration < 3)
  expect_equal(spns[[1]]$kind, "internal")
  expect_equal(spns[[1]]$status, "unset")
  # expect_equal(spns[[1]]$resources$service.name, "unknown_service")
  # expect_equal(spns[[1]]$`instr-lib`, "mytracer")
})

test_that("is_enabled", {
  trc_prv <- tracer_provider_stdstream_new()
  trc <- trc_prv$get_tracer("mytracer")
  expect_true(trc$is_enabled())
})

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
    sess1$deactivate_session() # 0
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

  nms <- vapply(spns, "[[", "", "name")
  expect_equal(nms, c("11", "1", "sess1", "2", "01", "0", "sess2"))
  names(spns) <- nms
  expect_equal(spns[["0"]]$parent, "0000000000000000")
  expect_equal(spns[["1"]]$parent, spns[["sess1"]]$span_id)
  expect_equal(spns[["2"]]$parent, spns[["sess2"]]$span_id)
  expect_equal(spns[["11"]]$parent, spns[["1"]]$span_id)
  expect_equal(spns[["01"]]$parent, spns[["0"]]$span_id)
})
