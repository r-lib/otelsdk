test_that("meter_provider_http", {
  coll <- webfakes::local_app_process(collector_app())
  withr::local_envvar(OTEL_EXPORTER_OTLP_ENDPOINT = coll$url())
  mp <- meter_provider_http_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  ctr <- mtr$create_counter("ctr")
  ctr$add(1)
  ctr$add(10)
  mp$flush()

  cl_resp <- curl::curl_fetch_memory(coll$url("/metrics"))
  expect_equal(cl_resp$status_code, 200L)
  cl_mcs <- jsonlite::fromJSON(
    rawToChar(cl_resp$content),
    simplifyVector = FALSE
  )[[1]][[1]]
  mcs <- cl_mcs$scope_metrics[[1]]$metrics[[1]]
  expect_equal(mcs$name, "ctr")
})

test_that("meter_provider_http_options", {
  expect_snapshot({
    meter_provider_http_options()
  })
})
