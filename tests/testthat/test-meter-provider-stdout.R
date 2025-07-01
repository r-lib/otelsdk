test_that("meter_provider_strout", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  mp <- meter_provider_stdstream_new(tmp)
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  ctr <- mtr$create_counter("ctr")
  ctr$add(1)
  ctr$add(10)
  mp$flush()
  lns <- readLines(tmp)
  expect_snapshot(
    lns,
    transform = transform_meter_provider_file
  )
})
