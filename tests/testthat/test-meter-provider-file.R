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
  # The periodic reader might export between the two `add()` calls, so
  # there might be multiple lines. Temporality is cumulative, so the last
  # line has the final value.
  lns <- readLines(tmp)
  mtcs <- jsonlite::fromJSON(lns[length(lns)], simplifyVector = FALSE)
  md <- mtcs$resourceMetrics[[1]]$scopeMetrics[[1]]$metrics[[1]]
  expect_equal(md$name, "ctr")
  expect_equal(md$sum$dataPoints[[1]]$asDouble, 11)
})

test_that("meter_provider_file$options", {
  expect_snapshot({
    meter_provider_file$options()
  })
})

test_that("meter_provider_file to stdout and stderr", {
  fun <- function(output) {
    mp <- otelsdk::meter_provider_file$new(list(file_pattern = output))
    mtr <- mp$get_meter()
    ctr <- mtr$create_counter("ctr")
    ctr$add(11)
    mp$flush()
    mp$shutdown()
    invisible()
  }
  for (output in c("stdout", "stderr")) {
    withr::local_dir(withr::local_tempdir())
    res <- run_in_otelsdk_subprocess(fun, list(output = output))
    mtcs <- parse_jsonl_lines(res[[output]])
    expect_true(length(mtcs) >= 1L)
    md <- mtcs[[length(mtcs)]]$resourceMetrics[[1]]$scopeMetrics[[1]]$metrics[[
      1
    ]]
    expect_equal(md$name, "ctr")
    expect_equal(md$sum$dataPoints[[1]]$asDouble, 11)
    expect_equal(dir(), character())
  }
})
