local_span_processors <- function(.local_envir = parent.frame()) {
  old <- the$span_processors
  old_loaded <- the$span_processors_env_loaded
  the$span_processors <- list()
  the$span_processors_env_loaded <- TRUE
  withr::defer(
    {
      the$span_processors <- old
      the$span_processors_env_loaded <- old_loaded
    },
    envir = .local_envir
  )
}

record_span <- function(name = "s", tracer = "mytracer", ...) {
  with_otel_record(function() {
    trc <- otel::get_tracer(tracer)
    spn <- trc$start_span(name, ...)
    spn$end()
  })[["traces"]]
}

test_that("on_start can add attributes", {
  local_span_processors()
  add_span_processor(on_start = function(span, info) {
    span$set_attribute("app.user", "joe")
  })
  spns <- record_span()
  expect_equal(spns[["s"]]$attributes$app.user, "joe")
})

test_that("info argument", {
  local_span_processors()
  info <- NULL
  add_span_processor(on_start = function(span, info) {
    info <<- info
  })
  record_span("myspan", tracer = "org.r-lib.mytracer")
  expect_equal(info$name, "myspan")
  expect_equal(info$tracer_name, "org.r-lib.mytracer")
  expect_equal(info$kind, "internal")
  expect_null(info$parent)

  record_span("myspan", options = list(kind = "server"))
  expect_equal(info$kind, "server")
})

test_that("multiple processors run in order", {
  local_span_processors()
  calls <- character()
  add_span_processor(on_start = function(span, info) calls <<- c(calls, "a"))
  add_span_processor(on_start = function(span, info) calls <<- c(calls, "b"))
  record_span()
  expect_equal(calls, c("a", "b"))
})

test_that("same id replaces processor, remove_span_processor", {
  local_span_processors()
  calls <- character()
  id <- add_span_processor(
    id = "p",
    on_start = function(span, info) calls <<- c(calls, "a")
  )
  expect_equal(id, "p")
  add_span_processor(
    id = "p",
    on_start = function(span, info) calls <<- c(calls, "b")
  )
  record_span()
  expect_equal(calls, "b")

  expect_true(remove_span_processor("p"))
  expect_false(remove_span_processor("p"))
  record_span()
  expect_equal(calls, "b")
})

test_that("generated ids are unique", {
  local_span_processors()
  id1 <- add_span_processor()
  id2 <- add_span_processor()
  expect_true(is_string(id1))
  expect_false(id1 == id2)
  expect_equal(names(the$span_processors), c(id1, id2))
  # processors without on_start are skipped
  expect_silent(record_span())
})

test_that("failing processor does not break the span", {
  local_span_processors()
  add_span_processor(id = "bad", on_start = function(span, info) stop("boo"))
  add_span_processor(on_start = function(span, info) {
    span$set_attribute("ok", TRUE)
  })
  expect_message(
    spns <- record_span(),
    "span processor 'bad': boo",
    class = "otel_error_message"
  )
  expect_true(spns[["s"]]$attributes$ok)
})

test_that("failing processor errors in dev mode", {
  local_span_processors()
  add_span_processor(on_start = function(span, info) stop("boo"))
  span <- list(is_recording = function() TRUE)
  expect_error(run_span_processors_dev(span, list()), "boo")
})

test_that("processor that starts a span does not recurse", {
  local_span_processors()
  ncalls <- 0L
  add_span_processor(on_start = function(span, info) {
    ncalls <<- ncalls + 1L
    trc <- otel::get_tracer("inner")
    trc$start_span("inner")$end()
  })
  spns <- record_span()
  expect_equal(ncalls, 1L)
  expect_setequal(names(spns), c("s", "inner"))
})

test_that("processors are not called for non-recording spans", {
  local_span_processors()
  called <- FALSE
  add_span_processor(on_start = function(span, info) called <<- TRUE)
  span <- list(is_recording = function() FALSE)
  run_span_processors(span, list())
  expect_false(called)
})

test_that("add_span_processor argument checks", {
  local_span_processors()
  expect_snapshot(error = TRUE, {
    add_span_processor(on_start = "foo")
    add_span_processor(id = 1L)
    add_span_processor(NULL, "myid")
    add_span_processor(on_end = function(span, info) NULL)
    remove_span_processor(NULL)
  })
})

test_that("OTEL_R_SPAN_PROCESSORS", {
  local_span_processors()
  the$span_processors_env_loaded <- FALSE
  procs <- list(
    good = list(on_start = function(span, info) {
      span$set_attribute("from.env", TRUE)
    })
  )
  local_mocked_bindings(
    get_exported_object = function(pkg, name) procs[[name]]
  )
  withr::local_envvar(OTEL_R_SPAN_PROCESSORS = " pkg::good , ")
  spns <- record_span()
  expect_true(spns[["s"]]$attributes$from.env)
  expect_equal(names(the$span_processors), "env:pkg::good")

  # only loaded once
  the$span_processors <- list()
  spns <- record_span()
  expect_null(spns[["s"]]$attributes$from.env)
})

test_that("OTEL_R_SPAN_PROCESSORS errors", {
  local_span_processors()
  procs <- list(
    fun = function(span, info) NULL,
    notfun = list(on_start = "nope")
  )
  local_mocked_bindings(
    get_exported_object = function(pkg, name) {
      if (!name %in% names(procs)) {
        stop("object '", name, "' not found")
      }
      procs[[name]]
    }
  )
  withr::local_envvar(
    OTEL_R_SPAN_PROCESSORS = "bad,pkg::missing,pkg::fun,pkg::notfun"
  )
  expect_snapshot({
    load_span_processors_env()
  })
  expect_equal(length(the$span_processors), 0L)

  expect_error(load_span_processors_env_dev(), "pkg::name")
})

test_that("OTEL_R_SPAN_PROCESSORS unknown callbacks are ignored", {
  local_span_processors()
  the$span_processors_env_loaded <- FALSE
  procs <- list(
    newer = list(
      on_start = function(span, info) span$set_attribute("from.env", TRUE),
      on_end = function(span, info) NULL
    )
  )
  local_mocked_bindings(
    get_exported_object = function(pkg, name) procs[[name]]
  )
  withr::local_envvar(OTEL_R_SPAN_PROCESSORS = "pkg::newer")
  expect_snapshot(spns <- record_span())
  expect_true(spns[["s"]]$attributes$from.env)
  expect_equal(names(the$span_processors), "env:pkg::newer")
})

test_that("get_exported_object", {
  expect_identical(
    get_exported_object("otelsdk", "with_otel_record"),
    with_otel_record
  )
  expect_error(get_exported_object("otelsdk", "this_does_not_exist"))
})
