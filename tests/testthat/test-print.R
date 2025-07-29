test_that("generic_print", {
  fake(generic_print, "format", function(x, ...) paste("line", x))
  expect_snapshot(out <- generic_print(1:3))
  expect_equal(out, 1:3)
})

test_that("generic_format", {
  x <- structure(list(a = 1, b = "foo"), class = "cls")
  expect_snapshot(writeLines(generic_format(x)))

  x <- structure(list(
    a = 1,
    attr = structure(list(x = 1:10), class = "otel_attributes"),
    b = "foo"
  ))
  expect_snapshot(writeLines(generic_format(x)))
})

test_that("with_width", {
  expect_snapshot(with_width(print(1:30), 40))
})

test_that("format.trace_flags", {
  expect_snapshot({
    tf1 <- structure(
      c(sampled = TRUE, random = TRUE),
      class = "otel_trace_flags"
    )
    format(tf1)
    tf2 <- structure(
      c(sampled = FALSE, random = FALSE),
      class = "otel_trace_flags"
    )
    format(tf2)
  })
})

test_that("format.otel_attributes", {
  expect_snapshot(
    writeLines(format(structure(
      list(),
      names = character(),
      class = "otel_attributes"
    )))
  )
  expect_snapshot(
    writeLines(format(structure(
      list(a = "this", b = 1:4),
      class = "otel_attributes"
    )))
  )
})

test_that("format.otel_span_data, print.otel_span_data", {
  spns <- with_otel_record(function() {
    otel::start_local_active_span("s", tracer = "org.r-lib.otel")
    trc <- otel::get_tracer("org.r-lib.otel")
  })[["traces"]]

  expect_snapshot(
    spns[["s"]],
    transform = transform_span_data
  )
})

test_that("format.otel_instrumentation_scope_data", {
  spns <- with_otel_record(function() {
    otel::start_local_active_span("s", tracer = "org.r-lib.otel")
    trc <- otel::get_tracer("org.r-lib.otel")
  })[["traces"]]

  expect_snapshot(writeLines(
    format(spns[["s"]][["instrumentation_scope"]])
  ))

  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer(
    "org.r-lib.otel",
    version = "0.1.0",
    schema_url = "https://opentelemetry.io/schemas/1.13.0",
    attributes = list(foo = 1:5, bar = "that")
  )
  sp <- trc$start_local_active_span("s")
  sp$end()
  spns <- tp$get_spans()

  expect_snapshot(
    spns[["s"]][["instrumentation_scope"]]
  )
})

test_that("format.otel_sum_point_data", {
  mp <- meter_provider_memory_new()
  mtr <- mp$get_meter()
  ctr <- mtr$create_counter("c")
  ctr$add(5)
  mp$flush()
  mp$shutdown()
  mtrs <- mp$get_metrics()
  # there are two reports, and the first one might be empty,
  # but this depends on the platforms and probably chance, so skip it
  expect_snapshot(
    mtrs[[2]],
    transform = transform_metric_data
  )
})

test_that("format.otel_histogram_point_data", {
  mp <- meter_provider_memory_new()
  mtr <- mp$get_meter()
  hst <- mtr$create_histogram("h")
  for (i in 1:10) {
    hst$record(i)
  }
  mp$flush()
  mp$shutdown()
  mtrs <- mp$get_metrics()
  # there are two reports, and the first one might be empty,
  # but this depends on the platforms and probably chance, so skip it
  expect_snapshot(
    mtrs[[2]],
    transform = transform_metric_data
  )
})

test_that("format.otel_last_value_point_data", {
  mp <- meter_provider_memory_new()
  mtr <- mp$get_meter()
  gge <- mtr$create_gauge("g")
  gge$record(5)
  mp$flush()
  mp$shutdown()
  mtrs <- mp$get_metrics()
  # there are two reports, and the first one might be empty,
  # but this depends on the platforms and probably chance, so skip it
  expect_snapshot(
    mtrs[[2]],
    transform = transform_metric_data
  )
})

test_that("format.otel_drop_point_data", {
  x <- structure(list(), class = "otel_drop_point_data")
  expect_snapshot(x)
})

test_that("format.otel_metrics_data", {
  mp <- meter_provider_memory_new()
  mtr <- mp$get_meter()
  ctr <- mtr$create_counter("c")
  ctr$add(5)
  mp$flush()
  mp$shutdown()
  mtrs <- mp$get_metrics()
  # there are two reports, and the first one might be empty,
  # but this depends on the platforms and probably chance, so skip it
  mtrs[[1]] <- NULL
  expect_snapshot(
    mtrs,
    transform = transform_metric_data
  )
})
