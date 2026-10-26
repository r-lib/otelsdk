test_that("tracer_provider_file", {
  tmp <- tempfile(fileext = "jsonl")
  on.exit(unlink(tmp), add = TRUE)
  withr::local_envvar(
    structure(tmp, names = file_exporter_traces_file_envvar)
  )

  tp <- tracer_provider_file_new()
  trc <- tp$get_tracer()
  sp1 <- trc$start_local_active_span("s1")
  sp1$end()
  tp$flush()

  expect_true(file.exists(tmp))
  spn <- jsonlite::fromJSON(tmp, simplifyVector = FALSE)
  expect_equal(spn$resourceSpans[[1]]$scopeSpans[[1]]$spans[[1]]$name, "s1")
})

test_that("tracer_provider_file$options", {
  expect_snapshot({
    tracer_provider_file$options()
  })
})

test_that("tracer_provider_file to stdout and stderr", {
  fun <- function(output) {
    tp <- otelsdk::tracer_provider_file$new(list(file_pattern = output))
    trc <- tp$get_tracer()
    sp1 <- trc$start_local_active_span("s1")
    sp1$end()
    tp$flush()
    invisible()
  }
  for (output in c("stdout", "stderr")) {
    withr::local_dir(withr::local_tempdir())
    res <- run_in_otelsdk_subprocess(fun, list(output = output))
    spn <- parse_jsonl_lines(res[[output]])
    expect_equal(length(spn), 1L)
    expect_equal(
      spn[[1]]$resourceSpans[[1]]$scopeSpans[[1]]$spans[[1]]$name,
      "s1"
    )
    expect_equal(dir(), character())
  }
})
