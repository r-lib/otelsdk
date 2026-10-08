library(testthat)
library(otelsdk)

if (Sys.getenv("NOT_CRAN") != "") {
  test_check("otelsdk")
}
