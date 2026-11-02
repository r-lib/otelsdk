test_that("logger_provider_memory", {
  lp <- logger_provider_memory_new()
  lgr <- lp$get_logger("mylogger")
  lgr$info("hello", attributes = list(foo = "bar", n = 2L))
  lgr$warn("careful")
  lgr$debug("not recorded")

  logs <- lp$get_logs()
  expect_length(logs, 2)
  expect_s3_class(logs[[1]], "otel_log_data")
  expect_equal(logs[[1]]$body, "hello")
  expect_equal(logs[[1]]$severity, c(info = 9L))
  expect_equal(logs[[1]]$attributes$foo, "bar")
  expect_equal(logs[[1]]$attributes$n, 2L)
  expect_equal(logs[[1]]$instrumentation_scope$name, "mylogger")
  expect_s3_class(logs[[1]]$timestamp, "POSIXct")
  expect_equal(logs[[1]]$trace_id, "")
  expect_equal(logs[[1]]$span_id, "")
  expect_equal(logs[[2]]$body, "careful")
  expect_equal(logs[[2]]$severity, c(warn = 13L))

  # buffer is emptied
  expect_equal(lp$get_logs(), list())
})

test_that("logger_provider_memory records trace and span ids", {
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("mytracer")
  lp <- logger_provider_memory_new()
  lgr <- lp$get_logger("mylogger")
  sp <- trc$start_span("myspan")
  lgr$info("in span", span_context = sp$get_context())
  sp$end()
  logs <- lp$get_logs()
  expect_length(logs, 1)
  expect_match(logs[[1]]$trace_id, "^[0-9a-f]{32}$")
  expect_match(logs[[1]]$span_id, "^[0-9a-f]{16}$")
  expect_equal(logs[[1]]$span_id, sp$get_context()$get_span_id())
})

test_that("logger_provider_memory buffer size", {
  lp <- logger_provider_memory_new(list(buffer_size = 3))
  lgr <- lp$get_logger("mylogger")
  for (i in 1:5) {
    lgr$info(paste("msg", i))
  }
  logs <- lp$get_logs()
  expect_equal(
    vapply(logs, "[[", "", "body"),
    c("msg 3", "msg 4", "msg 5")
  )
})

test_that("logger_provider_memory, resource attributes", {
  lp <- logger_provider_memory_new()
  lp$get_logger()$info("hi")
  logs <- lp$get_logs()
  expect_true("service.name" %in% names(logs[[1]]$resource_attributes))
})

test_that("flush, shutdown", {
  lp <- logger_provider_memory_new()
  lgr <- lp$get_logger()
  lgr$info("before")
  expect_no_error(lp$flush())
  expect_identical(lp$shutdown(), lp)
  lgr$info("after")
  expect_equal(vapply(lp$get_logs(), "[[", "", "body"), "before")
})

test_that("with_otel_record records logs", {
  rec <- with_otel_record({
    otel::log_info("first")
    otel::log_warn("second")
    "done"
  })
  expect_equal(rec$value, "done")
  expect_equal(vapply(rec$logs, "[[", "", "body"), c("first", "second"))
  expect_equal(rec$logs[[2]]$severity, c(warn = 13L))

  rec2 <- with_otel_record(otel::log_info("not recorded"), what = "traces")
  expect_null(rec2$logs)
})

test_that("with_otel_record, logs with span ids", {
  rec <- with_otel_record({
    spn <- otel::start_local_active_span("myspan")
    otel::log_info("in span")
    spn$end()
  })
  expect_equal(names(rec$traces), "myspan")
  expect_equal(rec$logs[[1]]$span_id, rec$traces[[1]]$span_id)
  expect_equal(rec$logs[[1]]$trace_id, rec$traces[[1]]$trace_id)
})

test_that("logger_provider_memory_options", {
  expect_snapshot({
    logger_provider_memory_options()
  })
})
