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
