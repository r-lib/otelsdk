test_that("attribute types", {
  attr <- list(
    lgl1 = FALSE,
    lgl = c(TRUE, FALSE, TRUE),
    chr1 = "ok!",
    chr = c("a", "b", "c"),
    dbl1 = 1.0,
    dbl = c(1.0, 2.0),
    int1 = 2L,
    int = 2:4
  )

  spns <- with_otel_record(function() {
    sp <- otel::start_local_active_span("test", attributes = attr)
  })[["traces"]]

  attr2 <- spns[["test"]]$attributes
  expect_identical(attr2$lgl1, attr$lgl1)
  expect_identical(attr2$lgl, attr$lgl)
  expect_identical(attr2$chr1, attr$chr1)
  expect_identical(attr2$chr, attr$chr)
  expect_identical(attr2$dbl1, attr$dbl1)
  expect_identical(attr2$dbl, attr$dbl)
  # int is internally converted to double because it is int64_t in otel
  expect_identical(attr2$int1, as.double(attr$int1))
  expect_identical(attr2$int, as.double(attr$int))
})
