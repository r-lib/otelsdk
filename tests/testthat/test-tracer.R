test_that("tracer_new", {
  tracer_provider <- tracer_provider_stdstream_new()
  expect_equal(
    class(tracer_provider),
    c("otel_tracer_provider_stdstream", "otel_tracer_provider")
  )
  tracer <- tracer_provider$get_tracer("mytracer")
  expect_equal(class(tracer), "otel_tracer")
})

test_that("start_span", {
  tmp <- tempfile(fileext = "otel")
  tracer_provider <- tracer_provider_stdstream_new(tmp)
  tracer <- tracer_provider$get_tracer("mytracer")
  span <- tracer$start_span("span1")
  expect_equal(class(span), "otel_span")
})

test_that("is_enabled", {
  tracer_provider <- tracer_provider_stdstream_new()
  tracer <- tracer_provider$get_tracer("mytracer")
  expect_true(tracer$is_enabled())
})

test_that("sessions", {
  skip("not ready for this yet")
  tracer_provider <- tracer_provider_stdstream_new()
  tracer <- tracer_provider$get_tracer("mytracer")

  span0 <- tracer$start_span()

  sess1 <- tracer$start_session()
  span1 <- tracer$start_span()

  sess2 <- tracer$start_session()
  span2 <- tracer$start_span()

  tracer$activate_session(sess1)
  span11 <- tracer$start_span()
  tracer$deactivate_session(sess1)
  tracer$finish_session(sess1)

  tracer$finish_session(sess2)

  span01 <- tracer$start_span()
  spen01$end()
  span0$end()
})
