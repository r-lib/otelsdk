bad_provider <- list(flush = function() stop("boo"))

test_that("tracer methods do not error", {
  trc_prv <- tracer_provider_memory_new()
  trc <- trc_prv$get_tracer("mytracer")

  local_mocked_bindings(ccall = function(...) stop("boo"))
  expect_s3_class(msg(trc$start_span("s")), "otel_span_noop")
  expect_s3_class(msg(trc$start_local_active_span("s")), "otel_span_noop")
  expect_s3_class(
    msg(trc$get_active_span_context()),
    "otel_span_context_noop"
  )
  expect_s3_class(msg(trc$get_active_span()), "otel_span_noop")
  expect_s3_class(
    msg(trc$extract_http_context(list())),
    "otel_span_context_noop"
  )
  trc$provider <- bad_provider
  expect_null(msg(trc$flush()))
})

test_that("tracer methods do not error on bad arguments", {
  trc_prv <- tracer_provider_memory_new()
  trc <- trc_prv$get_tracer("mytracer")
  expect_s3_class(msg(trc$start_span(1:2)), "otel_span_noop")
  expect_s3_class(
    msg(trc$extract_http_context(1:2)),
    "otel_span_context_noop"
  )
})

test_that("tracer methods error in dev mode", {
  trc_prv <- tracer_provider_memory_new()
  trc <- tracer_new_dev(trc_prv, "mytracer")

  local_mocked_bindings(ccall = function(...) stop("boo"))
  expect_error(trc$start_span("s"))
  expect_error(trc$start_local_active_span("s"))
  expect_error(trc$get_active_span_context())
  expect_error(trc$get_active_span())
  expect_error(trc$extract_http_context(list()))
  trc$provider <- bad_provider
  expect_error(trc$flush())
})

test_that("logger methods do not error", {
  lgr_prv <- logger_provider_stdstream_new(list(output = tempfile()))
  lgr <- lgr_prv$get_logger("mylogger")

  local_mocked_bindings(ccall = function(...) stop("boo"))
  expect_equal(msg(lgr$get_name()), "mylogger")
  expect_false(msg(lgr$is_enabled()))
  expect_equal(
    msg(lgr$get_minimum_severity()),
    otel::log_severity_levels["info"]
  )
  expect_identical(msg(lgr$set_minimum_severity("debug")), lgr)
  expect_identical(msg(lgr$log("hello")), lgr)
  expect_identical(msg(lgr$info("hello")), lgr)
  lgr$provider <- bad_provider
  expect_null(msg(lgr$flush()))
})

test_that("logger methods do not error on bad arguments", {
  lgr_prv <- logger_provider_stdstream_new(list(output = tempfile()))
  lgr <- lgr_prv$get_logger("mylogger")
  expect_identical(msg(lgr$log(1:2)), lgr)
  expect_identical(msg(lgr$log("x", severity = "bogus")), lgr)
  expect_false(msg(lgr$is_enabled("bogus")))
  expect_identical(msg(lgr$set_minimum_severity("bogus")), lgr)
})

test_that("logger methods error in dev mode", {
  lgr_prv <- logger_provider_stdstream_new(list(output = tempfile()))
  lgr <- logger_new_dev(lgr_prv, "mylogger")

  local_mocked_bindings(ccall = function(...) stop("boo"))
  expect_error(lgr$get_name())
  expect_error(lgr$is_enabled())
  expect_error(lgr$get_minimum_severity())
  expect_error(lgr$set_minimum_severity("debug"))
  expect_error(lgr$log("hello"))
  lgr$provider <- bad_provider
  expect_error(lgr$flush())
})

test_that("meter and instrument methods do not error", {
  mtr_prv <- meter_provider_memory_new()
  mtr <- mtr_prv$get_meter("mymeter")
  ctr <- mtr$create_counter("ctr")
  udc <- mtr$create_up_down_counter("udc")
  hst <- mtr$create_histogram("hst")
  gge <- mtr$create_gauge("gge")

  local_mocked_bindings(ccall = function(...) stop("boo"))
  expect_s3_class(msg(mtr$create_counter("c")), "otel_counter_noop")
  expect_s3_class(
    msg(mtr$create_up_down_counter("c")),
    "otel_up_down_counter_noop"
  )
  expect_s3_class(msg(mtr$create_histogram("c")), "otel_histogram_noop")
  expect_s3_class(msg(mtr$create_gauge("c")), "otel_gauge_noop")

  expect_identical(msg(ctr$add(1)), ctr)
  expect_identical(msg(udc$add(1)), udc)
  expect_identical(msg(hst$record(1)), hst)
  expect_identical(msg(gge$record(1)), gge)
})

test_that("instrument methods return the instrument invisibly", {
  mtr_prv <- meter_provider_memory_new()
  mtr <- mtr_prv$get_meter("mymeter")
  ctr <- mtr$create_counter("ctr")
  expect_invisible(ctr$add(1))
  expect_identical(ctr$add(1), ctr)
})

test_that("meter methods do not error on bad arguments", {
  mtr_prv <- meter_provider_memory_new()
  mtr <- mtr_prv$get_meter("mymeter")
  expect_s3_class(
    msg(mtr$create_histogram("h", boundaries = "bogus")),
    "otel_histogram_noop"
  )
  ctr <- mtr$create_counter("ctr")
  expect_identical(msg(ctr$add(1, attributes = "bogus")), ctr)
})

test_that("meter and instrument methods error in dev mode", {
  mtr_prv <- meter_provider_memory_new()
  mtr <- meter_new_dev(mtr_prv, "mymeter")
  ctr <- counter_new_dev(mtr, "ctr")
  udc <- up_down_counter_new_dev(mtr, "udc")
  hst <- histogram_new_dev(mtr, "hst")
  gge <- gauge_new_dev(mtr, "gge")

  local_mocked_bindings(ccall = function(...) stop("boo"))
  expect_error(mtr$create_counter("c"))
  expect_error(mtr$create_up_down_counter("c"))
  expect_error(mtr$create_histogram("c"))
  expect_error(mtr$create_gauge("c"))
  expect_error(ctr$add(1))
  expect_error(udc$add(1))
  expect_error(hst$record(1))
  expect_error(gge$record(1))
})

provider_constructors <- function() {
  tmp <- tempfile()
  list(
    tracer_provider_file = list(
      tracer_provider_file_new,
      list(file_pattern = tmp)
    ),
    tracer_provider_http = list(tracer_provider_http_new, NULL),
    tracer_provider_memory = list(tracer_provider_memory_new, NULL),
    tracer_provider_stdstream = list(
      tracer_provider_stdstream_new,
      list(output = tmp)
    ),
    logger_provider_file = list(
      logger_provider_file_new,
      list(file_pattern = tmp)
    ),
    logger_provider_http = list(logger_provider_http_new, NULL),
    logger_provider_stdstream = list(
      logger_provider_stdstream_new,
      list(output = tmp)
    ),
    meter_provider_file = list(
      meter_provider_file_new,
      list(file_pattern = tmp)
    ),
    meter_provider_http = list(meter_provider_http_new, NULL),
    meter_provider_memory = list(meter_provider_memory_new, NULL),
    meter_provider_stdstream = list(
      meter_provider_stdstream_new,
      list(output = tmp)
    )
  )
}

test_that("provider methods do not error", {
  for (nm in names(prvs <- provider_constructors())) {
    prv <- prvs[[nm]][[1]](prvs[[nm]][[2]])
    local({
      local_mocked_bindings(ccall = function(...) stop("boo"))
      if (!is.null(prv$get_tracer)) {
        expect_s3_class(msg(prv$get_tracer("t")), "otel_tracer_noop")
      }
      if (!is.null(prv$get_logger)) {
        expect_s3_class(msg(prv$get_logger("l")), "otel_logger_noop")
      }
      if (!is.null(prv$get_meter)) {
        expect_s3_class(msg(prv$get_meter("m")), "otel_meter_noop")
      }
      # some flush() methods do nothing
      if (!grepl("_(memory|http)$", nm) || nm == "meter_provider_http") {
        expect_null(msg(prv$flush()))
      }
      if (!is.null(prv$shutdown)) {
        expect_identical(msg(prv$shutdown()), prv)
      }
      if (!is.null(prv$get_spans)) {
        expect_equal(msg(prv$get_spans()), list())
      }
      if (!is.null(prv$get_metrics)) {
        expect_equal(msg(prv$get_metrics()), list())
      }
    })
  }
})

test_that("provider methods error in dev mode", {
  for (nm in names(prvs <- provider_constructors())) {
    fn <- get(paste0(nm, "_new_dev"))
    prv <- fn(prvs[[nm]][[2]])
    local({
      local_mocked_bindings(ccall = function(...) stop("boo"))
      if (!is.null(prv$get_tracer)) {
        expect_error(prv$get_tracer("t"))
      }
      if (!is.null(prv$get_logger)) {
        expect_error(prv$get_logger("l"))
      }
      if (!is.null(prv$get_meter)) {
        expect_error(prv$get_meter("m"))
      }
      if (!is.null(prv$shutdown)) {
        expect_error(prv$shutdown())
      }
      if (!is.null(prv$get_spans)) {
        expect_error(prv$get_spans())
      }
      if (!is.null(prv$get_metrics)) {
        expect_error(prv$get_metrics())
      }
    })
  }
})

test_that("setup_dev_env", {
  env <- new.env()
  env$tracer_provider_http <- tracer_provider_http
  withr::local_envvar(OTEL_ENV = "dev")
  setup_dev_env(env)
  for (nm in dev_function_names) {
    expect_identical(env[[nm]], get(paste0(nm, "_dev")))
  }
  expect_identical(env$tracer_provider_http$new, tracer_provider_http_new_dev)
  expect_identical(
    env$tracer_provider_http$options,
    tracer_provider_http$options
  )

  env <- new.env()
  withr::local_envvar(OTEL_ENV = NA_character_)
  setup_dev_env(env)
  expect_null(env$span_base_new)
})

test_that("R/api-dev.R is up to date", {
  skip_on_cran()
  root <- test_path("../..")
  skip_if_not(file.exists(file.path(root, "tools/template/dev.R")))
  out <- tempfile(fileext = ".R")
  on.exit(unlink(out), add = TRUE)
  withr::local_envvar(OTEL_DEV_API_OUTPUT_FILE = out)
  withr::local_dir(root)
  suppressMessages(source("tools/template/dev.R", local = new.env()))
  expect_equal(readLines(out), readLines("R/api-dev.R"))
})
