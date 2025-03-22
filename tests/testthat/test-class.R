test_that("new_object", {

  obj <- new_object(
    "myclass",
    method = function() "mymethod",
    getdata = function() self$data,
    data = "data"
  )

  expect_true(is.environment(obj))
  expect_equal(class(obj), "myclass")
  expect_equal(parent.env(obj), emptyenv())
  expect_equal(
    parent.env(environment(obj$method)),
    environment()
  )
  expect_equal(obj$method(), "mymethod")
  expect_equal(obj$data, "data")
  expect_equal(obj$getdata(), "data")
})
