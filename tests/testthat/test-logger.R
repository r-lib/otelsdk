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
