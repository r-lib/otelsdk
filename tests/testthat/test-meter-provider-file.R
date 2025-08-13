test_that("meter_provider_file", {
  tmp <- tempfile(fileext = ".jsonl")
  tmp2 <- paste0(tmp, "-a")
  on.exit(unlink(c(tmp, tmp2)), add = TRUE)
  mp <- meter_provider_file_new(
    opts = list(file_pattern = tmp, alias_pattern = tmp2)
  )
  on.exit(mp$shutdown(), add = TRUE)
  mtr <- mp$get_meter()
  ctr <- mtr$create_counter("ctr")
  ctr$add(1)
  ctr$add(10)
  mp$flush()
  mp$shutdown()
  expect_true(file.exists(tmp))
  expect_true(file.exists(tmp2))
  mtcs <- jsonlite::fromJSON(readLines(tmp)[1], simplifyVector = FALSE)
  md <- mtcs$resourceMetrics[[1]]$scopeMetrics[[1]]$metrics[[1]]
  expect_equal(md$name, "ctr")
  expect_equal(md$sum$dataPoints[[1]]$asDouble, 11)
})

test_that("meter_provider_file$options", {
  expect_snapshot({
    meter_provider_file$options()
  })
})
