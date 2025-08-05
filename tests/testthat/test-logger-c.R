test_that("otel_create_logger_provider_stdstream", {
  tmp <- tempfile(fileext = ".txt")
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_stdstream$new(list(output = tmp))
  lgr <- lp$get_logger("test")
  lgr$log("Hello there!")
  lp$flush()
  expect_true(file.size(tmp) > 0)
})

test_that("otel_create_logger_provider_http", {
  skip_on_cran()
  coll <- webfakes::local_app_process(collector_app())
  withr::local_envvar(OTEL_EXPORTER_OTLP_ENDPOINT = coll$url())
  lp <- logger_provider_http_new(
    opts = list(
      max_queue_size = 100,
      schedule_delay = 1,
      max_export_batch_size = 10
    )
  )
  lgr <- lp$get_logger("test")
  rm(lp, lgr)
  gc()
  gc()
  expect_true(TRUE)
})

test_that("otel_create_logger_provider_file", {
  tmp <- tempfile(fileext = ".jsonl")
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_file$new(list(file_pattern = tmp))
  lgr <- lp$get_logger()
  lgr$log("Hello there!")
  lp$flush()

  expect_true(file.size(tmp) > 0)
})

test_that("otel_logger_provider_file_options_defaults", {
  expect_snapshot({
    logger_provider_file$options()
  })
})

test_that("otel_logger_provider_flush", {})
