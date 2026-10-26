test_that("env vars are current for otel spec", {
  skip_on_cran()
  # If this fails, then you need to update docs.R, the version number
  # there, and also the support status of the new or modified enviromnent
  # variables, if any.
  # gh may print retry messages if rate limited, ignore those
  spec_version <- suppressMessages(
    gh::gh(
      "https://api.github.com/repos/{owner}/{repo}/releases/latest",
      owner = "open-telemetry",
      repo = "opentelemetry-specification"
    )$tag_name
  )
  expect_snapshot(spec_version)
})
