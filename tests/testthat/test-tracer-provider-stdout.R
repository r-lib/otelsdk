test_that("tracer_provider_stdstream", {
  tracer_provider <- tracer_provider_stdstream_new()
  tracer <- tracer_provider$get_tracer("mytracer")
  expect_true(TRUE)
})
