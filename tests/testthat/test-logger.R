test_that("get_default_log_severity", {
  withr::local_envvar(structure(names = otel_log_level_var, NA_character_))
  expect_equal(get_default_log_severity(), otel_log_level_default)

  withr::local_envvar(structure(names = otel_log_level_var, "debug2"))
  expect_equal(get_default_log_severity(), "debug2")

  withr::local_envvar(structure(names = otel_log_level_var, "14"))
  expect_equal(get_default_log_severity(), 14L)

  withr::local_envvar(structure(names = otel_log_level_var, "25"))
  expect_snapshot(error = TRUE, {
    get_default_log_severity()
  })

  withr::local_envvar(structure(names = otel_log_level_var, "whatup"))
  expect_snapshot(error = TRUE, {
    get_default_log_severity()
  })
})

test_that("logger_provider_stdstream", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_stdstream_new(tmp)
  lgr <- lp$get_logger("mylogger")
  expect_equal(lgr$get_name(), "mylogger")
  expect_true(lgr$is_enabled("info"))
  expect_false(lgr$is_enabled("debug"))
  expect_equal(lgr$get_minimum_severity(), c(info = 9L))

  x <- 1:3
  lgr$trace("trace! {x}", attributes = list(a = letters[1:3]))
  lgr$debug("debug! {x}", attributes = list(a = letters[1:3]))
  lgr$log("log! {x}", severity = "debug", attributes = list(a = letters[1:3]))
  lp$flush()
  lns <- readLines(tmp)
  expect_equal(length(lns), 0L)

  lgr$info("info! {x}", attributes = list(a = letters[1:3]))
  lp$flush()
  lns <- readLines(tmp)
  expect_true(any(grepl("severity_text.*INFO", lns)))

  lgr$warn("warn! {x}", attributes = list(a = letters[1:3]))
  lp$flush()
  lns <- readLines(tmp)
  expect_true(any(grepl("severity_text.*WARN", lns)))

  lgr$error("error! {x}", attributes = list(a = letters[1:3]))
  lp$flush()
  lns <- readLines(tmp)
  expect_true(any(grepl("severity_text.*ERROR", lns)))

  lgr$fatal("fatal! {x}", attributes = list(a = letters[1:3]))
  lp$flush()
  lns <- readLines(tmp)
  expect_true(any(grepl("severity_text.*FATAL", lns)))

  lgr$set_minimum_severity("trace")
  lgr$trace("trace! {x}", attributes = list(a = letters[1:3]))
  lp$flush()
  lns <- readLines(tmp)
  expect_true(any(grepl("severity_text.*TRACE", lns)))

  lgr$debug("debug! {x}", attributes = list(a = letters[1:3]))
  lp$flush()
  lns <- readLines(tmp)
  expect_true(any(grepl("severity_text.*DEBUG", lns)))
})

test_that("log levels", {
  coll <- webfakes::local_app_process(collector_app())
  withr::local_envvar(OTEL_EXPORTER_OTLP_ENDPOINT = coll$url())
  lp <- logger_provider_http_new()
  lgr <- lp$get_logger("mylogger")
  lgr$set_minimum_severity("trace")
  for (lv in names(otel::log_severity_levels)) {
    lgr$log(lv, severity = lv)
  }
  lp$flush()

  cl_resp <- curl::curl_fetch_memory(coll$url("/logs"))
  logs <- jsonlite::fromJSON(rawToChar(cl_resp$content), simplifyVector = FALSE)
  expect_equal(length(logs), length(otel::log_severity_levels))
  for (i in seq_along(logs)) {
    expect_equal(
      logs[[i]][[1]]$scope_logs[[1]]$log_records[[1]]$severity_text,
      toupper(names(otel::log_severity_levels)[i])
    )
  }
})

test_that("span_context", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  lp <- logger_provider_stdstream_new(tmp)
  lgr <- lp$get_logger("org.r-lib.otel")
  tp <- tracer_provider_memory_new()
  trc <- tp$get_tracer("org.r-lib.otel")

  lgr$info("span context test")
  lp$flush()
  lns <- readLines(tmp)
  expect_true(any(grepl("trace_id\\s*:\\s*0{32}", lns)))
  expect_true(any(grepl("span_id\\s*:\\s*0{16}", lns)))

  sp1 <- trc$start_span("s")
  lgr$info("span context test")
  lp$flush()
  sp1$end()
  lns <- readLines(tmp)
  spns <- tp$get_spans()

  expect_true(any(grepl(
    paste0("trace_id\\s*:\\s*", spns[["s"]]$trace_id),
    lns
  )))
  expect_true(any(grepl(paste0("span_id\\s*:\\s*", spns[["s"]]$span_id), lns)))

  sp2 <- trc$start_span("s2")
  lgr$info("span context test", span_context = sp2)
  lgr$flush()
  sp2$end()
  lns <- readLines(tmp)
  spns <- tp$get_spans()

  expect_true(any(grepl(
    paste0("trace_id\\s*:\\s*", spns[["s2"]]$trace_id),
    lns
  )))
  expect_true(any(grepl(paste0("span_id\\s*:\\s*", spns[["s2"]]$span_id), lns)))
})

test_that("log_severity_levels_spec", {
  expect_snapshot(log_severity_levels_spec())
})

test_that("otel_logger_provider_flush", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_logger_provider_flush, 1L)
    ccall(otel_logger_provider_flush, x)
  })
})

test_that("otel_get_logger", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_get_logger, 1L, "foo", 1L, NULL, NULL, NULL)
    ccall(otel_get_logger, x, "foo", 1L, NULL, NULL, NULL)
  })
})

test_that("otel_get_minimum_log_severity", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_get_minimum_log_severity, 1L)
    ccall(otel_get_minimum_log_severity, x)
  })
})

test_that("otel_set_minimum_log_severity", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_set_minimum_log_severity, 1L, 1L)
    ccall(otel_set_minimum_log_severity, x, 1L)
  })
})

test_that("otel_logger_get_name", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_logger_get_name, 1L)
    ccall(otel_logger_get_name, x)
  })
})

test_that("otel_logger_is_enabled", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(otel_logger_is_enabled, 1L, 1L, NULL)
    ccall(otel_logger_is_enabled, x, 1L, NULL)
  })
})

test_that("otel_log", {
  x <- ccall(create_empty_xptr)
  expect_snapshot(error = TRUE, {
    ccall(
      otel_log,
      1L,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL
    )
    ccall(
      otel_log,
      x,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL
    )
  })
})
