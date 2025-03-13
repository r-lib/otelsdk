test_that("HTTP tracer provider defaults", {
  expect_snapshot({
    tracer_provider_http_options()
  })
})
