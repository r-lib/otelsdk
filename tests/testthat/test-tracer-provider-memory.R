test_that("flush, shutdown", {
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer()
  sp1 <- trc$start_span("testspan")
  sp1$end()
  expect_true(tp$flush())
  expect_identical(tp$shutdown(), tp)
  expect_equal(names(tp$get_spans()), "testspan")
})

test_that("tracer_provider_memory_options", {
  expect_snapshot({
    tracer_provider_memory_options()
  })
})
