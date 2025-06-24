test_that("tracer_provider_http", {
  tracer_provider <- tracer_provider_http_new()
  tracer <- tracer_provider$get_tracer("mytracer")
  tracer$flush()
  expect_true(TRUE)
})

test_that("HTTP tracer provider defaults", {
  expect_snapshot({
    tracer_provider_http_options()
  })
})
