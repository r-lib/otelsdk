test_that("otel_logger_provider_finally_ ++", {
  # otel_logger_finally_
  # otel_create_logger_provider_file_
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_file$new(list(file_pattern = tmp))
  lgr <- lp$get_logger("test")
  rm(lp, lgr)
  gc()
  gc()
  expect_true(TRUE)
})

test_that("otel_logger_provider_file_options_defaults_", {
  expect_snapshot({
    logger_provider_file$options()
  })
})

test_that("otel_logger_provider_flush_", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_file$new(list(file_pattern = tmp))
  lgr <- lp$get_logger("test")
  lgr$log("Hello there!")
  lp$flush()
  expect_true(file.size(tmp) > 0)
})

test_that("otel_logger_provider_flush_ 2", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_stdstream$new(list(output = tmp))
  lgr <- lp$get_logger("test")
  lgr$log("Hello there!")
  lp$flush()
  expect_true(file.size(tmp) > 0)
})

test_that("otel_get_minimum_log_severity_ ++", {
  # otel_set_minimum_log_severity
  # otel_get_logger_
  # otel_logger_get_name_
  # to_severity
  # otel_logger_is_enabled_
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_file$new(list(file_pattern = tmp))
  lgr <- lp$get_logger("test")

  expect_equal(lgr$get_name(), "test")
  expect_true(lgr$is_enabled())

  expect_equal(lgr$get_minimum_severity(), c(info = 9))
  lgr$set_minimum_severity("debug")
  expect_equal(lgr$get_minimum_severity(), c(debug = 5))

  for (lvl in otel::log_severity_levels) {
    lgr$set_minimum_severity(lvl)
    expect_equal(unname(lgr$get_minimum_severity()), lvl)
  }
})

test_that("to_severity", {
  # otel_log_
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_file$new(list(file_pattern = tmp))
  lgr <- lp$get_logger("test")
  lgr$set_minimum_severity(1)
  for (lvl in otel::log_severity_levels) {
    lgr$log("Hello, level {lvl}!", severity = lvl)
  }
  lp$flush()
  lns <- readLines(tmp)
  lvls <- map_int(lns, USE.NAMES = FALSE, function(ln) {
    psd <- jsonlite::fromJSON(ln, simplifyVector = FALSE)
    lrs <- psd$resourceLogs[[1]]$scopeLogs[[1]]$logRecords
    lrs[[1]]$severityNumber
  })
  expect_equal(lvls, unname(otel::log_severity_levels))
})

test_that("otel_log_", {
  # hexchar
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_file$new(list(file_pattern = tmp))
  lgr <- lp$get_logger("test")
  trace_id <- strrep("a", nchar(otel::invalid_trace_id))
  span_id <- strrep("b", nchar(otel::invalid_span_id))
  ots <- structure(1754300727, class = c("POSIXct", "POSIXt"))
  lgr$log(
    "Hello, with trace id",
    trace_id = trace_id,
    span_id = span_id,
    observed_timestamp = ots
  )
  lp$flush()
  lns <- readLines(tmp)
  psd <- jsonlite::fromJSON(lns, simplifyVector = FALSE)
  lrs <- psd$resourceLogs[[1]]$scopeLogs[[1]]$logRecords
  expect_equal(lrs[[1]]$traceId, trace_id)
  expect_equal(lrs[[1]]$spanId, span_id)
  # ns to s
  ots2 <- as.double(
    substr(
      lrs[[1]]$observedTimeUnixNano,
      1,
      nchar(lrs[[1]]$observedTimeUnixNano) - 9
    )
  )
  expect_equal(ots2, as.double(ots))
})

test_that("otel_logger_provider_http_default_options_", {
  # otel_blrp_defaults_
  expect_snapshot({
    logger_provider_http$options()
  })
})
