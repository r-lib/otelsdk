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

test_that("escaped delimiters", {
  expect_equal(glue("this {{ is verbatim }}"), "this { is verbatim }")
})

test_that("escaping", {
  expect_equal(glue("foo {'\\t\\t'} bar", .cli = TRUE), "foo \t\t bar")
  expect_equal(glue('foo {"\\t\\t"} bar', .cli = TRUE), "foo \t\t bar")
  expect_equal(
    glue("foo {`\\t\\t`} bar", .cli = TRUE, .transformer = function(x, ...) x),
    "foo `\\t\\t` bar"
  )
  expect_equal(
    glue("foo { # c } bar", .cli = TRUE, .transformer = function(x, ...) x),
    "foo  # c  bar"
  )

  expect_equal(
    glue("'fo`o\"#", .cli = TRUE, .transformer = function(x, ...) x),
    "'fo`o\"#"
  )
  expect_equal(
    glue('"fo`o\'#', .cli = TRUE, .transformer = function(x, ...) x),
    '"fo`o\'#'
  )
  expect_equal(
    glue("# foo", .transformer = function(x, ...) x),
    "# foo"
  )
  expect_equal(
    glue("x {# foo } y", .cli = TRUE, .transformer = function(x, ...) x),
    "x # foo  y"
  )
})

test_that("delim levels", {
  expect_equal(glue("{ '{ 1 + 1 }' }"), "{ 1 + 1 }")
})

test_that("glue errors", {
  expect_snapshot(error = TRUE, {
    glue("{ no brace")
    glue("{ 'no quote ", .cli = TRUE)
    glue('{ "no dquote ', .cli = TRUE)
    glue('{ `no backtick ', .cli = TRUE)
  })
})

test_that("trim", {
  # skip first newline
  expect_snapshot({
    trim("\nfoo")
  })

  # ignore last empty line for indent
  expect_snapshot({
    trim("foo\n   bar")
    trim("foo\n   bar\n  ")
  })

  # copy line of space if shorter than minimum indent
  expect_snapshot({
    trim("foo\n   bar\n  \nbaz")
  })

  # A line shorter than min_indent that contains only indentation should not be
  # trimmed, removed, or prepended to the next line.
  expect_snapshot({
    trim(
      "
       \ta
       \tb
      \t
       \tc"
    )
  })
})
