test_that("env vars are current for otel spec", {
  skip_on_cran()
  # If this fails, then you need to update docs.R, the version number
  # there, and also the support status of the new or modified enviromnent
  # variables, if any.
  expect_snapshot(
    gh::gh(
      "https://api.github.com/repos/{owner}/{repo}/releases/latest",
      owner = "open-telemetry",
      repo = "opentelemetry-specification"
    )$tag_name
  )
})
