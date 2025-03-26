test_that("tracer_new", {
  trc_prv <- tracer_provider_stdstream_new()
  expect_equal(
    class(trc_prv),
    c("otel_tracer_provider_stdstream", "otel_tracer_provider")
  )
  trc <- trc_prv$get_tracer("mytracer")
  expect_equal(class(trc), "otel_tracer")
})

test_that("start_span", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span("spn1")
  expect_equal(class(spn1), "otel_span")
  spn2 <- trc$start_span("spn2")
  spn2$end()
  spn1$end()
  trc_prv$flush()

  spns <- parse_spans(tmp)
  expect_equal(length(spns), 2)
  expect_equal(spns[[1]]$name, "spn2")
  expect_equal(spns[[2]]$name, "spn1")
  expect_match(spns[[1]]$trace_id, "^[0-9a-f]+$")
  expect_equal(spns[[1]]$trace_id, spns[[2]]$trace_id)
  expect_match(spns[[1]]$span_id, "^[0-9a-f]+$")
  expect_match(spns[[2]]$span_id, "^[0-9a-f]+$")
  expect_match(spns[[1]]$parent_span_id, "^[0-9a-f]+$")
  expect_equal(spns[[2]]$parent_span_id, "0000000000000000")
  expect_equal(spns[[1]]$parent_span_id, spns[[2]]$span_id)
  expect_match(spns[[1]]$start, "^[0-9]+$")
  expect_match(spns[[1]]$duration, "^[0-9]+$")
  expect_equal(spns[[1]]$`span kind`, "Internal")
  expect_equal(spns[[1]]$status, "Unset")
  expect_equal(spns[[1]]$service.name, "unknown_service")
  expect_equal(spns[[1]]$`instr-lib`, "mytracer")
})

test_that("is_enabled", {
  trc_prv <- tracer_provider_stdstream_new()
  trc <- trc_prv$get_tracer("mytracer")
  expect_true(trc$is_enabled())
})

test_that("sessions", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")

  spn0 <- trc$start_span("0")        # 0

  sess1 <- trc$start_session()       # 1
  spn1 <- trc$start_span("1")        # 1

  sess2 <- trc$start_session()       # 2
  spn2 <- trc$start_span("2")        # 2

  trc$activate_session(sess1)        # 1
  spn11 <- trc$start_span("11")      # 1
  trc$deactivate_session(sess1)      # 1
  trc$finish_session(sess1)          # 1
  spn11$end()                        # 1
  spn1$end()                         # 1

  spn2$end()                         # 2
  trc$finish_all_sessions()          # 2

  spn01 <- trc$start_span("01")      # 0
  spn01$end()                        # 0
  spn0$end()                         # 0

  trc$flush()
  spns <- parse_spans(tmp)
  expect_equal(names(spns), c("11", "1", "2", "01", "0"))
  expect_equal(spns[["0"]]$parent_span_id, "0000000000000000")
  expect_equal(spns[["1"]]$parent_span_id, "0000000000000000")
  expect_equal(spns[["2"]]$parent_span_id, "0000000000000000")
  expect_equal(spns[["11"]]$parent_span_id, spns[["1"]]$span_id)
  expect_equal(spns[["01"]]$parent_span_id, spns[["0"]]$span_id)
})
