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
