test_that("meter, counter", {
  mp <- meter_provider_memory_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  expect_true(mtr$is_enabled())
  ctr <- mtr$create_counter("ctr")
  ctr$add(1)
  ctr$add(10)
  mp$flush()
  mp$shutdown()
  mrcs <- mp$get_metrics()
  md <- mrcs[[2]][["scope_metric_data"]][[1]][["metric_data"]][[1]]
  expect_equal(md[["instrument_name"]], "ctr")
  expect_equal(md[["instrument_type"]], "counter")
  expect_equal(md[["instrument_value_type"]], "double")
  expect_equal(md[["point_data_attr"]][[1]][["value"]][["value"]], 11)
})

test_that("meter, up_down_counter", {
  mp <- meter_provider_memory_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  udc <- mtr$create_up_down_counter("udctr")
  udc$add(1)
  udc$add(10)
  mp$flush()
  mp$shutdown()
  mrcs <- mp$get_metrics()
  md <- mrcs[[2]][["scope_metric_data"]][[1]][["metric_data"]][[1]]
  expect_equal(md[["instrument_name"]], "udctr")
  expect_equal(md[["instrument_type"]], "up_down_counter")
  expect_equal(md[["instrument_value_type"]], "double")
  expect_equal(md[["point_data_attr"]][[1]][["value"]][["value"]], 11)
})

test_that("meter, histogram", {
  skip("unreliable")
  mp <- meter_provider_memory_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  hst <- mtr$create_histogram("hst")
  hst$record(1)
  hst$record(10)
  mp$flush()
  mp$shutdown()
  mrcs <- mp$get_metrics()
  md <- mrcs[[2]][["scope_metric_data"]][[1]][["metric_data"]][[1]]
  expect_equal(md[["instrument_name"]], "hst")
  expect_equal(md[["instrument_type"]], "histogram")
  expect_equal(md[["instrument_value_type"]], "double")
  expect_equal(md[["point_data_attr"]][[1]][["value"]][["sum"]], 11)
  expect_equal(md[["point_data_attr"]][[1]][["value"]][["min"]], 1)
  expect_equal(md[["point_data_attr"]][[1]][["value"]][["max"]], 10)
  expect_equal(md[["point_data_attr"]][[1]][["value"]][["count"]], 2)
})

test_that("meter, histogram with boundaries", {
  mp <- meter_provider_memory_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter("mtr1")
  hst <- mtr$create_histogram("hst", boundaries = c(1, 2, 4))
  # first boundaries win
  hst2 <- mtr$create_histogram("hst", boundaries = c(10, 20))
  hst3 <- mtr$create_histogram("hst")
  hst$record(0.5)
  hst2$record(3)
  hst3$record(100)
  # other histograms are not affected
  oth <- mtr$create_histogram("oth")
  oth$record(1)
  mtr2 <- mp$get_meter("mtr2")
  hst4 <- mtr2$create_histogram("hst")
  hst4$record(1)
  mp$flush()
  mp$shutdown()
  mrcs <- mp$get_metrics()

  # the number of reports varies, use the last one that has data
  find <- function(meter, inst) {
    res <- NULL
    for (r in mrcs) {
      for (sm in r[["scope_metric_data"]]) {
        if (sm[["instrumentation_scope"]][["name"]] != meter) {
          next
        }
        for (md in sm[["metric_data"]]) {
          if (md[["instrument_name"]] == inst) {
            res <- md[["point_data_attr"]][[1]][["value"]]
          }
        }
      }
    }
    res
  }
  default <- c(
    0,
    5,
    10,
    25,
    50,
    75,
    100,
    250,
    500,
    750,
    1000,
    2500,
    5000,
    7500,
    10000
  )

  hpd <- find("mtr1", "hst")
  expect_equal(hpd[["boundaries"]], c(1, 2, 4))
  expect_equal(hpd[["counts"]], c(1, 0, 1, 1))
  expect_equal(find("mtr1", "oth")[["boundaries"]], default)
  expect_equal(find("mtr2", "hst")[["boundaries"]], default)
})

test_that("meter, histogram with invalid boundaries", {
  mp <- meter_provider_memory_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  expect_snapshot(error = TRUE, {
    mtr$create_histogram("hst", boundaries = c(2, 1))
  })
})

test_that("meter, gauge", {
  skip("Unreliable")
  mp <- meter_provider_memory_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  udc <- mtr$create_gauge("gge")
  udc$record(1)
  udc$record(10)
  mp$flush()
  mp$shutdown()
  mrcs <- mp$get_metrics()
  md <- mrcs[[2]][["scope_metric_data"]][[1]][["metric_data"]][[1]]
  expect_equal(md[["instrument_name"]], "gge")
  expect_equal(md[["instrument_type"]], "gauge")
  expect_equal(md[["instrument_value_type"]], "double")
  expect_equal(md[["point_data_attr"]][[1]][["value"]][["value"]], 10)
})

test_that("meter_new when metrics are disabled", {
  fake(meter_new, "find_instrumentation_scope", list(on = FALSE, name = "nm"))
  mtr <- meter_new("name")
  expect_s3_class(mtr, "otel_meter_noop")
})

test_that("custom export interval and timeout (#79)", {
  tmp <- tempfile(fileext = ".jsonl")
  on.exit(unlink(c(tmp, paste0(tmp, "-a"))), add = TRUE)
  check <- function(opts, interval = NA_character_, timeout = NA_character_) {
    withr::local_envvar(
      OTEL_METRIC_EXPORT_INTERVAL = interval,
      OTEL_METRIC_EXPORT_TIMEOUT = timeout
    )
    mps <- list(
      meter_provider_stdstream_new(c(opts, list(output = tmp))),
      meter_provider_memory_new(opts),
      meter_provider_file_new(c(
        opts,
        list(file_pattern = tmp, alias_pattern = paste0(tmp, "-a"))
      )),
      meter_provider_http_new(c(opts, list(url = "http://127.0.0.1:1")))
    )
    for (mp in mps) {
      expect_true(inherits(mp, "otel_meter_provider"))
      mp$shutdown()
    }
  }
  check(list(export_interval = 5000L, export_timeout = 1000L))
  check(list(export_interval = 5000, export_timeout = 1000))
  check(list(export_interval = "5s", export_timeout = "1s"))
  check(list(
    export_interval = as.difftime(5, units = "secs"),
    export_timeout = as.difftime(1, units = "secs")
  ))
  check(NULL, interval = "5000", timeout = "1000")
  check(NULL, interval = "5s", timeout = "1s")
})
