test_that("otel_meter_provider_file_options_defaults_", {
  expect_snapshot({
    meter_provider_file$options()
  })
})

test_that("otel_meter_provider_memory_get_metrics_", {
  #
})
