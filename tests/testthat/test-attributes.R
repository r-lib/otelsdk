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

test_that("length one arrays are kept as arrays", {
  attr <- list(
    lgl1 = as.array(FALSE),
    chr1 = as.array("stop"),
    dbl1 = as.array(1.0),
    int1 = matrix(2L),
    chr = as.array(c("a", "b")),
    scalar = "stop"
  )

  spns <- with_otel_record(function() {
    sp <- otel::start_local_active_span("test", attributes = attr)
    sp$set_attribute("set", array("stop"))
  })[["traces"]]

  attr2 <- spns[["test"]]$attributes
  expect_identical(attr2$lgl1, as.array(FALSE))
  expect_identical(attr2$chr1, as.array("stop"))
  expect_identical(attr2$dbl1, as.array(1.0))
  expect_identical(attr2$int1, as.array(2.0))
  # longer arrays are not marked
  expect_identical(attr2$chr, c("a", "b"))
  expect_identical(attr2$scalar, "stop")
  expect_identical(attr2$set, as.array("stop"))
})

test_that("length one arrays are exported as arrays", {
  tmp <- tempfile(fileext = "jsonl")
  on.exit(unlink(tmp), add = TRUE)
  withr::local_envvar(
    structure(tmp, names = file_exporter_traces_file_envvar)
  )

  tp <- tracer_provider_file_new()
  trc <- tp$get_tracer()
  sp1 <- trc$start_local_active_span(
    "s1",
    attributes = list(arr = as.array("stop"), scl = "stop")
  )
  sp1$end()
  tp$flush()

  spn <- jsonlite::fromJSON(tmp, simplifyVector = FALSE)
  attrs <- spn$resourceSpans[[1]]$scopeSpans[[1]]$spans[[1]]$attributes
  names(attrs) <- vapply(attrs, "[[", "", "key")
  expect_equal(
    attrs$arr$value,
    list(arrayValue = list(values = list(list(stringValue = "stop"))))
  )
  expect_equal(attrs$scl$value, list(stringValue = "stop"))
})
