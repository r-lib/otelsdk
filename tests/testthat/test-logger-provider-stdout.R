test_that("logger_provider_stdstream", {
  logger_provider <- logger_provider_stdstream_new()
  logger <- logger_provider$get_logger("mylogger")
  expect_true(logger$is_enabled())
  expect_equal(logger$get_minimum_severity(), log_severity_levels["info"])
})

test_that("log to file", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_stdstream$new(tmp)
  lgr <- lp$get_logger("mylogger")

  expect_true(lgr$is_enabled())
  expect_equal(lgr$get_minimum_severity(), log_severity_levels["info"])
  lgr$log("This is a simple log message")
  lgr$log("This is a warning", severity = "warn")

  type <- "structured"
  lgr$log("This is a {type} log message.")
  lgr$log(
    "This is a {type} log message with attributes",
    attributes = list(foo = "bar")
  )
  lp$flush()

  expect_true(file.exists(tmp))
  spns <- parse_spans(tmp)
  test_fields <- c(
    "severity_num",
    "severity_text",
    "body",
    "attributes",
    "trace_id",
    "span_id"
  )
  expect_snapshot({
    spns[[1]][test_fields]
    spns[[2]][test_fields]
    spns[[3]][test_fields]
    spns[[4]][test_fields]
  })
})
