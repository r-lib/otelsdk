test_that("finalizers", {
  do <- function() {
    mp <- meter_provider_memory_new()
    mtr <- mp$get_meter()
    ctr <- mtr$create_counter("ctr")
    udctr <- mtr$create_up_down_counter("udctr")
    hst <- mtr$create_histogram("hst")
    gge <- mtr$create_gauge("gge")
    mp$shutdown()
  }
  do()
  gc()
  gc()
  expect_true(TRUE)
})

test_that("otel_meter_provider_memory_get_metrics error", {
  expect_snapshot(
    ccall(otel_meter_provider_memory_get_metrics, 1:10)
  )

  x <- ccall(create_empty_xptr)
  expect_snapshot(
    error = TRUE,
    ccall(otel_meter_provider_memory_get_metrics, x)
  )
})

test_that("otel_get_meter error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_get_meter, 1L, "foo", NULL, NULL, NULL)
    ccall(otel_get_meter, x, "foo", NULL, NULL, NULL)
  })
})

test_that("otel_meter_provider_flush error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_meter_provider_flush, 1L, NULL)
    ccall(otel_meter_provider_flush, x, NULL)
  })
})

test_that("otel_meter_provider_shutdown error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_meter_provider_shutdown, 1L, NULL)
    ccall(otel_meter_provider_shutdown, x, NULL)
  })
})

test_that("otel_create_counter error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_create_counter, 1L, NULL, NULL, NULL)
    ccall(otel_create_counter, x, NULL, NULL, NULL)
  })
})

test_that("otel_counter_add error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_counter_add, 1L, NULL, NULL, NULL)
    ccall(otel_counter_add, x, NULL, NULL, NULL)
  })
})

test_that("otel_create_up_down_counter error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_create_up_down_counter, 1L, NULL, NULL, NULL)
    ccall(otel_create_up_down_counter, x, NULL, NULL, NULL)
  })
})

test_that("otel_up_down_counter_add error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_up_down_counter_add, 1L, NULL, NULL, NULL)
    ccall(otel_up_down_counter_add, x, NULL, NULL, NULL)
  })
})

test_that("otel_create_histogram error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_create_histogram, 1L, NULL, NULL, NULL)
    ccall(otel_create_histogram, x, NULL, NULL, NULL)
  })
})

test_that("otel_histogram_record error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_histogram_record, 1L, NULL, NULL, NULL)
    ccall(otel_histogram_record, x, NULL, NULL, NULL)
  })
})

test_that("otel_create_gauge error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_create_gauge, 1L, NULL, NULL, NULL)
    ccall(otel_create_gauge, x, NULL, NULL, NULL)
  })
})

test_that("otel_gauge_record error", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_gauge_record, 1L, NULL, NULL, NULL)
    ccall(otel_gauge_record, x, NULL, NULL, NULL)
  })
})
