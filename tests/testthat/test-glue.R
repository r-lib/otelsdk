test_that("glue", {
  # no input
  expect_equal(glue(NULL), "")

  # plain text
  expect_equal(glue("foo"), "foo")

  # trimming
  expect_equal(
    glue(
      "  foo \\
         bar
         baz"
    ),
    "foo bar\nbaz"
  )

  # interpolation
  expect_equal(glue("1+1={1+1}"), "1+1=2")
})

test_that("extract_otel_attributes", {
  x <- 1:2
  y <- letters[1:3]
  expect_equal(
    extract_otel_attributes("This {x} and that {y}."),
    list(text = "This 12 and that abc.", attributes = list(x = x, y = y))
  )
})
