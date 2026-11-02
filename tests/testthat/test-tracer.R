test_that("tracer_new", {
  trc_prv <- tracer_provider_memory_new()
  expect_equal(
    class(trc_prv),
    c("otel_tracer_provider_memory", "otel_tracer_provider")
  )
  trc <- trc_prv$get_tracer("mytracer")
  expect_equal(class(trc), "otel_tracer")
})

test_that("start_local_active_span", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_local_active_span("spn1")
    expect_equal(class(spn1), "otel_span")
    spn2 <- trc$start_local_active_span("spn2")
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

test_that("start_span", {
  spns <- with_otel_record({
    trc <- otel::get_tracer("mytracer")
    sess <- trc$start_span("sess")
    sess$end()
  })[["traces"]]

  expect_equal(spns[["sess"]]$name, "sess")
})

test_that("get_active_span_context", {
  spid <- NULL
  spns <- with_otel_record(function() {
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_local_active_span("spn1")
    ctx <- trc$get_active_span_context()
    spid <<- ctx$get_span_id()
  })

  # a new span is active
  expect_equal(spid, spns[["traces"]][["spn1"]]$span_id)
})

test_that("flush", {
  trc_prv <- tracer_provider_stdstream_new()
  trc <- trc_prv$get_tracer("mytracer")
  expect_silent(trc$flush())
})

test_that("extract_http_context", {
  hdrs <- NULL
  trid <- NULL
  spid <- NULL
  spns <- with_otel_record(function() {
    trc <- otel::get_tracer("mytracer")
    spn1 <- trc$start_local_active_span("spn1")
    ctx <- trc$get_active_span_context()
    hdrs <<- ctx$to_http_headers()
    trid <<- ctx$get_trace_id()
    spid <<- ctx$get_span_id()
    spn1$end()
  })[["traces"]]

  spns2 <- with_otel_record(function() {
    trc <- otel::get_tracer("mytracer2")
    ctx <- trc$extract_http_context(hdrs)
    spn2 <- trc$start_local_active_span("spn2", options = list(parent = ctx))
  })[["traces"]]

  expect_equal(spns[["spn1"]][["trace_id"]], spns2[["spn2"]][["trace_id"]])
  expect_equal(spns[["spn1"]][["span_id"]], spns2[["spn2"]][["parent"]])
})

test_that("extract_http_context, invalid headers", {
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("mytracer")
  trid <- "4bf92f3577b34da6a3ce929d0e0e4736"
  spid <- "00f067aa0ba902b7"
  bad <- c(
    "foo",
    "00-abc-def-01",
    paste0("0x-", trid, "-", spid, "-01"),
    paste0("ff-", trid, "-", spid, "-01"),
    paste0("01-", trid, "-", spid, "-0"),
    paste0("00-", trid, "-", spid, "-01-extra"),
    paste0("00-", strrep("0", 32), "-", spid, "-01")
  )
  for (hdr in bad) {
    ctx <- trc$extract_http_context(c(traceparent = hdr))
    expect_false(ctx$is_valid(), info = hdr)
  }

  # future version may have extra fields
  ctx <- trc$extract_http_context(
    c(traceparent = paste0("01-", trid, "-", spid, "-01-extra"))
  )
  expect_true(ctx$is_valid())
  expect_equal(ctx$get_trace_id(), trid)
  expect_equal(ctx$get_span_id(), spid)
  expect_true(ctx$is_remote())

  # tracestate is kept
  ctx <- trc$extract_http_context(c(
    traceparent = paste0("00-", trid, "-", spid, "-01"),
    tracestate = "foo=bar"
  ))
  expect_true(ctx$is_valid())
  expect_equal(ctx$to_http_headers()[["tracestate"]], "foo=bar")
})

test_that("tracer_new when tracing is disabled", {
  fake(tracer_new, "find_instrumentation_scope", list(on = FALSE, name = "nm"))
  lgr <- tracer_new("name")
  expect_s3_class(lgr, "otel_tracer_noop")
})

test_that("otel_tracer_provider_flush", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_tracer_provider_flush, 1L)
    ccall(otel_tracer_provider_flush, x)
  })
})

test_that("otel_tracer_provider_shutdown", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_tracer_provider_shutdown, 1L)
    ccall(otel_tracer_provider_shutdown, x)
  })
})
