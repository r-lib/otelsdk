test_that("logger_provider_file", {
  tmp <- tempfile(fileext = ".jsonl")
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_file_new(list(file_pattern = tmp))
  lgr <- lp$get_logger("org.r-lib.otel")
  expect_true(lgr$is_enabled())
  expect_equal(lgr$get_minimum_severity(), otel::log_severity_levels["info"])
  expect_equal(lgr$get_minimum_severity(), c(info = 9L))

  x <- 1:3
  lgr$trace("trace! {x}", attributes = list(a = letters[1:3]))
  lgr$debug("debug! {x}", attributes = list(a = letters[1:3]))
  lgr$log("log! {x}", severity = "debug", attributes = list(a = letters[1:3]))
  lp$flush()

  if (file.exists(tmp)) {
    lns <- readLines(tmp)
  } else {
    lns <- character()
  }
  expect_equal(length(lns), 0L)

  lgr$warn("warn! {x}", attributes = list(a = letters[1:3]))
  lp$flush()
  expect_true(file.exists(tmp))
  lns <- readLines(tmp)
  obj <- jsonlite::fromJSON(lns[[1]], simplifyVector = FALSE)
  expect_equal(
    obj$resourceLogs[[1]]$scopeLogs[[1]]$logRecords[[1]]$severityText,
    "WARN"
  )

  lgr$error(
    "error! {x}",
    observed_timestamp = Sys.time(),
    attributes = list(a = letters[1:3])
  )
  lp$flush()
  lns <- readLines(tmp)
  obj <- jsonlite::fromJSON(lns[[2]], simplifyVector = FALSE)
  expect_equal(
    obj$resourceLogs[[1]]$scopeLogs[[1]]$logRecords[[1]]$severityText,
    "ERROR"
  )
})
