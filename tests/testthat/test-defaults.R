test_that("span_kinds", {
  skip_on_cran()
  expect_snapshot(span_kinds)
  expect_equal(span_kinds, otel::span_kinds)
})

test_that("span_status_codes", {
  skip_on_cran()
  expect_snapshot(span_status_codes)
  expect_equal(span_status_codes, otel::span_status_codes)
})

test_that("default_resource_attributes", {
  da <- default_resource_attributes()
  expect_snapshot({
    da[["telemetry.sdk.language"]]
    da[["telemetry.sdk.name"]]
    da[["process.runtime.name"]]
  })
  expect_equal(
    da[["telemetry.sdk.version"]],
    as.character(utils::packageVersion("otelsdk"))
  )
  expect_equal(
    da[["process.runtime.version"]],
    as.character(getRversion())
  )
  expect_equal(
    da[["process.runtime.description"]],
    R.version.string
  )
  expect_equal(
    da[["process.pid"]],
    Sys.getpid()
  )
  expect_equal(
    da[["process.owner"]],
    Sys.info()["user"]
  )
  expect_equal(
    da[["os.type"]],
    tolower(Sys.info()['sysname'])
  )
})
