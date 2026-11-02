local_dev_mode <- function(.local_envir = parent.frame()) {
  fns <- structure(
    lapply(paste0(dev_function_names, "_dev"), get, envir = environment()),
    names = dev_function_names
  )
  do.call(local_mocked_bindings, c(fns, list(.env = .local_envir)))
}

test_that("tracer and span work in dev mode", {
  local_dev_mode()
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("mytracer")
  expect_s3_class(trc, "otel_tracer")

  spn1 <- trc$start_span("s1")
  spn2 <- trc$start_span("s2", links = list(spn1))
  expect_true(spn2$is_valid())
  expect_true(spn2$is_recording())
  expect_identical(spn2$set_attribute("a", "b"), spn2)
  expect_identical(spn2$set_attributes(list(c = 1, d = TRUE)), spn2)
  expect_identical(spn2$add_event("e", list(x = "y")), spn2)
  expect_identical(spn2$add_link(spn1, list(l = "1")), spn2)
  expect_identical(spn2$set_status("ok", "fine"), spn2)
  expect_identical(spn2$update_name("s2new"), spn2)
  expect_equal(spn2$name, "s2new")
  expect_error(spn2$name <- "foo", "update_name")
  expect_identical(spn2$record_exception(simpleError("boo")), spn2)

  cscope <- spn2$activate(NULL)
  expect_equal(
    trc$get_active_span_context()$get_span_id(),
    spn2$get_context()$get_span_id()
  )
  expect_equal(trc$get_active_span()$name, "s2new")
  expect_null(spn2$deactivate(cscope))

  ctx <- spn2$get_context()
  expect_true(ctx$is_valid())
  expect_false(ctx$is_remote())
  expect_true(ctx$is_sampled())
  expect_match(ctx$get_trace_id(), "^[0-9a-f]{32}$")
  expect_match(ctx$get_span_id(), "^[0-9a-f]{16}$")
  hdrs <- ctx$to_http_headers()
  expect_true("traceparent" %in% names(hdrs))
  ctx2 <- trc$extract_http_context(hdrs)
  expect_equal(ctx2$get_span_id(), ctx$get_span_id())

  expect_identical(spn2$end(), spn2)
  expect_identical(spn1$end(), spn1)
  trc$flush()

  spns <- tp$get_spans()
  expect_equal(sort(names(spns)), c("s1", "s2new"))
  expect_length(spns[["s2new"]]$links, 2)
  expect_equal(spns[["s2new"]]$status, "ok")
  expect_identical(tp$shutdown(), tp)
})

test_that("ending spans automatically in dev mode", {
  local_dev_mode()
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("mytracer")

  do <- function(name, status = NULL, error = FALSE) {
    spn <- trc$start_local_active_span(name)
    if (!is.null(status)) {
      spn$set_status(status)
    }
    if (error) stop("boo")
  }
  # no error, status stays unset
  do("ok")
  # status is already set
  do("set", status = "ok")
  # error
  try(do("err", error = TRUE), silent = TRUE)

  spns <- tp$get_spans()
  expect_equal(spns[["ok"]]$status, "unset")
  expect_equal(spns[["set"]]$status, "ok")
  expect_equal(spns[["err"]]$status, "error")
  expect_equal(spns[["err"]]$events[[1]]$name, "exception")
})

test_that("activate with end_on_exit in dev mode", {
  local_dev_mode()
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("mytracer")
  local({
    spn <- trc$start_span("s")
    spn$activate(end_on_exit = TRUE)
  })
  expect_equal(names(tp$get_spans()), "s")
})

test_that("tracer providers work in dev mode", {
  local_dev_mode()
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  prvs <- list(
    tracer_provider_file_new(list(file_pattern = tmp)),
    tracer_provider_http_new(),
    tracer_provider_stdstream_new(list(output = tmp))
  )
  for (prv in prvs) {
    expect_s3_class(prv$get_tracer("t"), "otel_tracer")
    prv$flush()
    expect_identical(prv$shutdown(), prv)
  }
})

test_that("logger works in dev mode", {
  local_dev_mode()
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("mytracer")
  lp <- logger_provider_memory_new()
  lgr <- lp$get_logger("mylogger")
  expect_s3_class(lgr, "otel_logger")
  expect_equal(lgr$get_name(), "mylogger")

  expect_identical(lgr$set_minimum_severity("trace"), lgr)
  expect_equal(lgr$get_minimum_severity(), otel::log_severity_levels["trace"])
  expect_true(lgr$is_enabled("debug"))

  spn <- trc$start_span("s")
  lgr$trace("trace", span_context = spn$get_context())
  spn$end()
  lgr$debug("debug")
  lgr$info("info")
  lgr$warn("warn")
  lgr$error("error")
  lgr$fatal("fatal")
  lgr$flush()

  logs <- lp$get_logs()
  expect_equal(
    map_chr(logs, "[[", "body"),
    c("trace", "debug", "info", "warn", "error", "fatal")
  )
  expect_equal(logs[[3]]$severity, otel::log_severity_levels["info"])
  expect_equal(logs[[1]]$span_id, spn$get_context()$get_span_id())
  expect_identical(lp$shutdown(), lp)
})

test_that("logger providers work in dev mode", {
  local_dev_mode()
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  prvs <- list(
    logger_provider_file_new(list(file_pattern = tmp)),
    logger_provider_http_new(),
    logger_provider_stdstream_new(list(output = tmp))
  )
  for (prv in prvs) {
    expect_s3_class(prv$get_logger("l"), "otel_logger")
    prv$flush()
    expect_identical(prv$shutdown(), prv)
  }
})

test_that("meter and instruments work in dev mode", {
  local_dev_mode()
  mp <- meter_provider_memory_new()
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter("mymeter")
  expect_s3_class(mtr, "otel_meter")
  expect_true(mtr$is_enabled())

  ctr <- mtr$create_counter("ctr")
  udc <- mtr$create_up_down_counter("udc")
  hst <- mtr$create_histogram("hst")
  gge <- mtr$create_gauge("gge")
  expect_identical(ctr$add(1), ctr)
  expect_identical(udc$add(-1), udc)
  expect_identical(hst$record(1), hst)
  expect_identical(gge$record(1), gge)
  mp$flush()
  expect_identical(mp$shutdown(), mp)
  expect_true(length(mp$get_metrics()) > 0)
})

test_that("meter providers work in dev mode", {
  local_dev_mode()
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  prvs <- list(
    meter_provider_file_new(list(file_pattern = tmp)),
    meter_provider_http_new(),
    meter_provider_stdstream_new(list(output = tmp))
  )
  for (prv in prvs) {
    expect_s3_class(prv$get_meter("m"), "otel_meter")
    prv$flush()
    expect_identical(prv$shutdown(), prv)
  }
})

test_that("disabled instrumentation scopes in dev mode", {
  local_dev_mode()
  fake(logger_new_dev, "find_instrumentation_scope", list(on = FALSE))
  fake(meter_new_dev, "find_instrumentation_scope", list(on = FALSE))
  fake(tracer_new_dev, "find_instrumentation_scope", list(on = FALSE))
  expect_s3_class(logger_new_dev(NULL, "l"), "otel_logger_noop")
  expect_s3_class(meter_new_dev(NULL, "m"), "otel_meter_noop")
  expect_s3_class(tracer_new_dev(NULL, "t"), "otel_tracer_noop")
})

test_that("span processors in dev mode", {
  local_dev_mode()
  old <- the$span_processors
  old_loaded <- the$span_processors_env_loaded
  on.exit(
    {
      the$span_processors <- old
      the$span_processors_env_loaded <- old_loaded
    },
    add = TRUE
  )
  the$span_processors <- list()
  the$span_processors_env_loaded <- FALSE

  procs <- list(
    good = list(on_start = function(span, info) {
      span$set_attribute("from.env", TRUE)
    }),
    empty = list()
  )
  local_mocked_bindings(
    get_exported_object = function(pkg, name) procs[[name]]
  )
  withr::local_envvar(OTEL_R_SPAN_PROCESSORS = "pkg::good,pkg::empty")

  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("mytracer")
  trc$start_span("s")$end()
  spns <- tp$get_spans()
  expect_true(spns[["s"]]$attributes$from.env)
  expect_equal(
    names(the$span_processors),
    c("env:pkg::good", "env:pkg::empty")
  )

  # empty env var
  withr::local_envvar(OTEL_R_SPAN_PROCESSORS = "")
  expect_null(load_span_processors_env_dev())

  # non-recording span
  span <- list(is_recording = function() FALSE)
  expect_null(run_span_processors_dev(span, list()))
})
