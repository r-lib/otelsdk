library(testthat)
library(otelsdk)

if (Sys.getenv("NOT_CRAN") != "") {
  if (requireNamespace("testthatlabs", quietly = TRUE)) {
    test_check(
      "otelsdk",
      reporter = asNamespace("testthatlabs")$non_interactive_reporter$new(
        "otelsdk"
      )
    )
  } else {
    test_check("otelsdk")
  }
}
