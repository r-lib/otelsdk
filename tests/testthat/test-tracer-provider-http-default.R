test_that("multiplication works", {
  expect_snapshot({
    rawToChar(.Call(otel_tracer_provider_http_default_url))
  })
})
