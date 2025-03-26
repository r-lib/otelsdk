test_that("named and unnamed spans", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  spn2 <- trc$start_span("my")
  spn2$end()
  spn1$end()
  trc$flush()

  spns <- parse_spans(tmp)
  expect_equal(spns[[1]]$name, "my")
  expect_equal(spns[[2]]$name, default_span_name)
})

test_that("close span automatically", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  do <- function(name = NULL) {
    spn1 <- trc$start_span(name)
  }
  do("1")
  do("2")
  trc$flush()

  spns <- parse_spans(tmp)
  # they are not stacked
  expect_equal(spns[[1]]$parent_span_id, "0000000000000000")
  expect_equal(spns[[2]]$parent_span_id, "0000000000000000")
})

test_that("is_recording", {
  tmp <- tempfile(fileext = "otel")
  on.exit(unlink(tmp), add = TRUE)
  trc_prv <- tracer_provider_stdstream_new(tmp)
  trc <- trc_prv$get_tracer("mytracer")
  spn1 <- trc$start_span()
  expect_true(spn1$is_recording())
})

test_that("set_attribute", {

})

test_that("add_event", {

})

test_that("set_status", {

})

test_that("update_data", {

})

test_that("record_exception", {

})
