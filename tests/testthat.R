# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)
library(otelsdk)

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
