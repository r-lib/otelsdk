test_that("logger_provider_http", {
  skip_on_cran()
  coll <- webfakes::local_app_process(collector_app())
  withr::local_envvar(OTEL_EXPORTER_OTLP_ENDPOINT = coll$url())
  lp <- logger_provider_http_new(opts = list(schedule_delay = 1))
  # on.exit(lp$shutdown(), add = TRUE)
  lgr <- lp$get_logger()
  lgr$log("Test!")
  lp$flush()

  # TODO: handle batched logs better, query /logs multiple times
  Sys.sleep(0.2)
  cl_resp <- curl::curl_fetch_memory(coll$url("/logs"))
  expect_equal(cl_resp$status_code, 200L)
  cl_logs <- jsonlite::fromJSON(
    rawToChar(cl_resp$content),
    simplifyVector = FALSE
  )[[1]][[1]]
  lr <- cl_logs$scope_logs[[1]]$log_records[[1]]
  expect_equal(lr$trace_id, "")
  expect_equal(lr$span_id, "")
  expect_equal(lr$severity_text, "INFO")
  expect_equal(lr$body, "Test!")
})

test_that("logger_provider_http_options", {
  expect_snapshot(logger_provider_http_options())
})
