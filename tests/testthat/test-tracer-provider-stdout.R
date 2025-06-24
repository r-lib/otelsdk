test_that("tracer_provider_stdstream", {
  tracer_provider <- tracer_provider_stdstream_new()
  tracer <- tracer_provider$get_tracer("mytracer")
  expect_true(TRUE)
})

test_that("writing to a file", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  tp <- tracer_provider_stdstream$new(tmp)
  trc <- tp$get_tracer()
  sp1 <- trc$start_span("testspan")
  sp1$end()
  tp$flush()

  lns <- readLines(tmp)
  expect_true(any(grepl("name\\s*:\\s*testspan", lns)))
})
