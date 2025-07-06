test_that("is.na", {
  expect_true(is_na(NA))
  expect_true(is_na(NA_character_))
  expect_true(is_na(NA_complex_))
  expect_true(is_na(NA_integer_))
  expect_true(is_na(NA_real_))

  expect_false(is_na(1))
  expect_false(is_na(NULL))
  expect_false(is_na(c(NA, NA)))
})

test_that("is_string", {
  expect_true(is_string("foo"))
  expect_true(is_string(c(name = "foo")))

  expect_false(is_string(1))
  expect_false(is_string(letters))
  expect_false(is_string(NA_character_))
  expect_false(is_string(character()))
})

test_that("is_named", {
  expect_true(is_named(NULL))
  expect_true(is_named(character()))
  expect_true(is_named(c(a = "1")))
  expect_true(is_named(c(a = 1)))

  expect_false(is_named(1))
  expect_false(is_named(letters))
  expect_false(is_named(c(a = 1, 2, c = 3)))
  expect_false(is_named(structure(1:3, names = c(NA, "b", "c"))))
})

test_that("as_timestamp", {
  t <- structure(1742214039.31794, class = c("POSIXct", "POSIXt"))
  expect_snapshot({
    as_timestamp(NULL)
    as_timestamp(t)
    as_timestamp(as.double(t))
    as_timestamp(as.integer(t))
  })

  helper <- function(ts) as_timestamp(ts)
  b1 <- mtcars
  b2 <- Sys.Date()
  b3 <- c(Sys.time(), Sys.time())
  b4 <- as.POSIXct(NA)
  b5 <- 1:2
  b6 <- Sys.time()[integer()]
  expect_snapshot(error = TRUE, {
    helper(b1)
    helper(b2)
    helper(b3)
    helper(b4)
    helper(b5)
    helper(b6)
  })
})

test_that("as_span", {
  sp <- structure(list(), class = "otel_span")
  expect_snapshot({
    as_span(NULL)
    as_span(NA)
    as_span(NA_character_)
    as_span(sp)
  })

  helper <- function(s) as_span(s)
  b1 <- mtcars
  expect_snapshot(error = TRUE, {
    helper(b1)
  })
})

test_that("as_span_context", {
  spc <- structure(list(), class = "otel_span_context")
  sp <- structure(list(get_context = function() "context"), class = "otel_span")
  expect_snapshot({
    as_span_context(NULL)
    as_span_context(NA)
    as_span_context(NA_character_)
    as_span_context(spc)
    as_span_context(sp)
  })

  helper <- function(spc) as_span_context(spc)
  b1 <- mtcars
  expect_snapshot(error = TRUE, {
    helper(b1)
  })
})

test_that("as_span_parent", {
  expect_null(as_span_parent(NULL, null = TRUE))
  expect_equal(as_span_parent(NA, na = TRUE), NA)
  span <- structure(
    list(get_context = function() list(xptr = "this")),
    class = "otel_span"
  )
  expect_equal(as_span_parent(span), "this")
  spanctx <- structure(list(xptr = "that"), class = "otel_span_context")
  expect_equal(as_span_parent(spanctx), "that")

  helper <- function(spp) as_span_parent(spp)
  b1 <- mtcars
  expect_snapshot(error = TRUE, {
    helper(b1)
  })
})

test_that("as_choice", {
  expect_snapshot({
    as_choice(NULL, c(default = "foo", "bar"))
    as_choice("foo", c(default = "foo", "bar"))
    as_choice("bar", c(default = "foo", "bar"))
  })

  helper <- function(ch, choices) as_choice(ch, choices)
  b1 <- "foobar"
  b2 <- 1:10
  expect_snapshot(error = TRUE, {
    helper(b1, c(default = "foo", "bar"))
    helper(b2, c(default = "foo", "bar"))
  })
})

test_that("as_env", {
  expect_null(as_env(NULL))
  e <- new.env()
  expect_equal(as_env(e), e)

  helper <- function(e, null = TRUE) as_env(e, null = null)
  e1 <- 1:10
  e2 <- NULL
  expect_snapshot(error = TRUE, {
    helper(e1)
    helper(e2, null = FALSE)
  })
})

test_that("as_string", {
  expect_null(as_string(NULL))
  expect_equal(as_string("foo"), "foo")
  expect_equal(as_string(c(a = "1")), c(a = "1"))

  helper <- function(s, null = TRUE) as_string(s, null = null)
  s1 <- 1
  s2 <- character()
  s3 <- letters[1:2]
  s4 <- NULL
  expect_snapshot(error = TRUE, {
    helper(s1)
    helper(s2)
    helper(s3)
    helper(s4, null = FALSE)
  })
  s <- 1:10
  expect_snapshot(error = TRUE, {
    helper(s)
  })
})

test_that("as_flag", {
  expect_null(as_flag(NULL, null = TRUE))
  expect_equal(as_flag(TRUE), TRUE)
  expect_equal(as_flag(FALSE), FALSE)
  b1 <- 1:10
  helper <- function(f) as_flag(f)
  expect_snapshot(error = TRUE, {
    helper(b1)
  })
})

test_that("as_flag_env", {
  withr::local_envvar(FOO = NA_character_)
  expect_null(as_flag_env("FOO"))

  true <- c("true", "TRue", "t", "yes", "on", "1")
  for (v in true) {
    withr::local_envvar(FOO = v)
    expect_true(as_flag_env("FOO"))
  }

  false <- c("false", "False", "F", "no", "off", "0")
  for (v in false) {
    withr::local_envvar(FOO = v)
    expect_false(as_flag_env("FOO"))
  }

  helper <- function(ev) as_flag_env(ev)
  withr::local_envvar(FOO = "notgood")
  expect_snapshot(error = TRUE, {
    helper("FOO")
  })
})

test_that("as_otel_attribute_value", {
  expect_equal(as_otel_attribute_value("a"), "a")
  expect_equal(as_otel_attribute_value(TRUE), TRUE)
  expect_equal(as_otel_attribute_value(1), 1)
  expect_equal(as_otel_attribute_value(1L), 1L)

  helper <- function(oav) as_otel_attribute_value(oav)
  v1 <- list()
  v2 <- c("a", NA)
  v3 <- c(TRUE, NA)
  v4 <- c(1, NA)
  v5 <- c(1L, NA)
  expect_snapshot(error = TRUE, {
    helper(v1)
    helper(v2)
    helper(v3)
    helper(v4)
    helper(v5)
  })
})

test_that("as_otel_attributes", {
  expect_null(as_otel_attributes(NULL))
  v <- list(a = "a", b = TRUE, c = 1, d = 1L)
  expect_equal(as_otel_attributes(v), v)

  helper <- function(att) as_otel_attributes(att)
  v1 <- 1:10
  v2 <- list(1:10)
  v3 <- list(a = list())
  v4 <- list(a = c(1, NA, 2))
  expect_snapshot(error = TRUE, {
    helper(v1)
    helper(v2)
    helper(v3)
    helper(v4)
  })
})

test_that("as_span_link", {
  sl <- structure(list(xptr = "ptr"), class = "otel_span")
  expect_equal(as_span_link(sl), list("ptr", list()))
  expect_equal(as_span_link(list(sl)), list("ptr", list()))
  attr <- list(a = "a", b = TRUE, c = 1, d = 1L)
  expect_equal(
    as_span_link(c(list(sl), attr)),
    list("ptr", attr)
  )

  helper <- function(spl) as_span_link(spl)
  expect_snapshot(error = TRUE, {
    link <- 1:10
    helper(link)
    link <- list(sl, "foo", "bar")
    helper(link)
    link <- list(sl, a = "1", b = c(1, NA))
    helper(link)
  })
})

test_that("as_span_links", {
  sl <- structure(list(xptr = "ptr"), class = "otel_span")
  expect_equal(
    as_span_links(list(sl)),
    list(list("ptr", list()))
  )
  expect_equal(
    as_span_links(list(list(sl, a = "1"))),
    list(list("ptr", list(a = "1")))
  )

  helper <- function(spls) as_span_links(spls)
  expect_snapshot(error = TRUE, {
    links <- 1:10
    helper(links)
    links <- list(1:10)
    helper(links)
  })
})

test_that("as_span_options", {
  t <- Sys.time()
  expect_equal(as_span_options(NULL), list(kind = 0L))
  expect_equal(
    as_span_options(list(start_system_time = t)),
    list(start_system_time = as.double(t), kind = 0L)
  )
  expect_equal(
    as_span_options(list(start_steady_time = t)),
    list(start_steady_time = as.double(t), kind = 0L)
  )
  p <- structure(list(xptr = "ptr"), class = "otel_span_context")
  expect_equal(
    as_span_options(list(parent = p)),
    list(parent = "ptr", kind = 0L)
  )
  expect_equal(
    as_span_options(list(kind = "client")),
    list(kind = 2L)
  )

  helper <- function(opts) as_span_options(opts)
  expect_snapshot(error = TRUE, {
    options <- 1:10
    helper(options)
    options <- list("foo")
    helper(options)
    options <- list(kind = "internal", foo = "notgood")
    helper(options)
    options <- list(kind = 10)
    helper(options)
  })
})

test_that("as_end_span_options", {
  t <- Sys.time()
  expect_equal(as_end_span_options(NULL), list())
  expect_equal(
    as_end_span_options(list(end_steady_time = t)),
    list(end_steady_time = as.double(t))
  )

  helper <- function(opts) as_end_span_options(opts)
  expect_snapshot(error = TRUE, {
    o1 <- 1:10
    helper(o1)
    o2 <- list("foo")
    helper(o2)
    o3 <- list(end_steady_time = t, foo = "notgood")
    helper(o3)
    o4 <- list(end_steady_time = "bad")
    helper(o4)
  })
})

test_that("as_output_file", {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)

  expect_equal(as_output_file(NULL), NULL)
  expect_false(file.exists(tmp))
  expect_equal(as_output_file(tmp), tmp)
  expect_true(file.exists(tmp))

  helper <- function(f) as_output_file(f)

  tmp2 <- tempfile()
  on.exit(unlink(tmp2, recursive = TRUE), add = TRUE)
  tmp3 <- file.path(tmp2, "output")
  expect_snapshot(error = TRUE, transform = transform_tempdir, {
    helper(tmp3)
  })

  # permissions do not matter if we are root
  skip_on_cran()
  if (
    !ps::ps_is_supported() ||
      (ps::ps_os_type()[["POSIX"]] && ps::ps_uids()[["effective"]] == 0)
  ) {
    skip("test does not work as root user")
  }
  dir.create(tmp2)
  file.create(tmp3)
  Sys.chmod(tmp3, "0100")
  expect_snapshot(error = TRUE, transform = transform_tempdir, {
    helper(tmp3)
  })
})

test_that("as_log_severity", {
  expect_null(as_log_severity(NULL))
  expect_equal(as_log_severity("warn"), c(warn = 13L))
  expect_equal(as_log_severity(10L), 10L)
  expect_equal(as_log_severity(0, spec = TRUE), 0L)
  expect_equal(as_log_severity(255, spec = TRUE), 255L)

  helper <- function(ls, spec = FALSE) as_log_severity(ls, spec = spec)
  v1 <- "foobar"
  v2 <- 1:10
  v3 <- 200
  v4 <- 200
  v5 <- 0
  v6 <- 255L
  expect_snapshot(error = TRUE, {
    helper(v1)
    helper(v2)
    helper(v3)
    helper(v4, spec = TRUE)
    helper(v5)
    helper(v6)
  })
})

test_that("as_event_id", {})

test_that("as_span_id", {
  expect_null(as_span_id(NULL))
  nc <- span_id_size() * 2L
  expect_equal(as_span_id(strrep("0", nc)), strrep("0", nc))
  expect_equal(as_span_id(strrep("a", nc)), strrep("a", nc))
  expect_equal(as_span_id(strrep("F", nc)), strrep("f", nc))

  helper <- function(sid) as_span_id(sid)
  v1 <- substr(strrep("badcafe", nc), 1, nc - 1)
  v2 <- NA_character_
  v3 <- strrep("X", nc)
  v4 <- 1:10
  expect_snapshot(error = TRUE, {
    helper(v1)
    helper(v2)
    helper(v3)
    helper(v4)
  })
})

test_that("as_trace_id", {
  expect_null(as_trace_id(NULL))
  nc <- trace_id_size() * 2L
  expect_equal(as_trace_id(strrep("0", nc)), strrep("0", nc))
  expect_equal(as_trace_id(strrep("a", nc)), strrep("a", nc))
  expect_equal(as_trace_id(strrep("F", nc)), strrep("f", nc))

  helper <- function(tid) as_trace_id(tid)
  v1 <- substr(strrep("badcafe", nc), 1, nc - 1)
  v2 <- NA_character_
  v3 <- strrep("X", nc)
  v4 <- 1:10
  expect_snapshot(error = TRUE, {
    helper(v1)
    helper(v2)
    helper(v3)
    helper(v4)
  })
})

test_that("as_trace_flags", {})

test_that("is_count", {
  expect_true(is_count(1L))
  expect_true(is_count(1))
  expect_true(is_count(0L))
  expect_true(is_count(0))

  expect_false(is_count(NA_integer_))
  expect_false(is_count(NA_real_))
  expect_false(is_count("1"))
  expect_false(is_count(1:10))
  expect_false(is_count(-1L))
  expect_false(is_count(-1))

  expect_true(is_count(1, positive = TRUE))
  expect_false(is_count(0, positive = TRUE))
  expect_false(is_count(0L, positive = TRUE))
})

test_that("as_count", {
  expect_null(as_count(NULL, null = TRUE))
  expect_equal(as_count(1L), 1L)
  expect_equal(as_count(1), 1L)
  expect_equal(as_count(0L), 0L)
  expect_equal(as_count(0), 0L)
  expect_equal(as_count(20L, positive = TRUE), 20L)
  expect_equal(as_count(20, positive = TRUE), 20L)

  expect_equal(as_count("20"), 20L)
  expect_equal(as_count("0"), 0L)

  helper <- function(c, ...) as_count(c, ...)
  v1 <- 1:10
  v2 <- NA_integer_
  v3 <- NA_real_
  v4 <- -1
  v5 <- 0
  v6 <- mtcars
  v7 <- "boo"
  expect_snapshot(error = TRUE, {
    helper(v1)
    helper(v2)
    helper(v3)
    helper(v4)
    helper(v5, positive = TRUE)
    helper(v6)
    helper(v7)
  })
})

test_that("as_count_env", {
  withr::local_envvar(FOO = NA_character_)
  expect_null(as_count_env("FOO"))

  withr::local_envvar(FOO = "10")
  expect_equal(as_count_env("FOO"), 10L)

  withr::local_envvar(FOO = "0")
  expect_equal(as_count_env("FOO"), 0L)

  helper <- function(ev) as_count_env(ev)
  withr::local_envvar(FOO = "oops")
  expect_snapshot(error = TRUE, {
    helper("FOO")
  })

  withr::local_envvar(FOO = "-1")
  expect_snapshot(error = TRUE, {
    helper("FOO")
  })

  withr::local_envvar(FOO = "0")
  expect_snapshot(error = TRUE, {
    helper("FOO", positive = TRUE)
  })
})

test_that("as_http_context_headers", {
  expect_equal(
    as_http_context_headers(list(TRACEPARENT = "tp", TRACESTATE = "ts")),
    list(traceparent = "tp", tracestate = "ts")
  )
  expect_equal(
    as_http_context_headers(list(TRACEPARENT = "tp")),
    list(traceparent = "tp", tracestate = NULL)
  )
  expect_equal(
    as_http_context_headers(list(TRACESTATE = "ts")),
    list(traceparent = NULL, tracestate = "ts")
  )
  expect_equal(
    as_http_context_headers(list()),
    list(traceparent = NULL, tracestate = NULL)
  )

  helper <- function(hdr) as_http_context_headers(hdr)
  v3 <- list(tracestate = raw(10))
  expect_snapshot(error = TRUE, {
    v1 <- 1:10
    helper(v1)
    v2 <- list(traceparent = TRUE)
    helper(v2)
    v3 <- list(tracestate = raw(10))
    helper(v3)
  })
})

test_that("as_difftime_spec", {
  expect_null(as_difftime_spec(NULL))
  expect_equal(
    as_difftime_spec(as.difftime(1.2, units = "secs")),
    1.2 * 1000
  )
  expect_equal(as_difftime_spec(5), 5)
  expect_equal(as_difftime_spec("1s"), 1 * 1000)

  helper <- function(dt) as_difftime_spec(dt)
  expect_snapshot(error = TRUE, {
    v1 <- as.difftime(NA_real_, units = "secs")
    helper(v1)
    v2 <- as.difftime(1:2, units = "secs")
    helper(v2)
    v3 <- "foo"
    helper(v3)
    v4 <- "0"
    helper(v4)
    v5 <- raw(10)
    helper(v5)
  })
})

test_that("as_difftime_env", {
  withr::local_envvar(FOO = NA_character_)
  expect_null(as_difftime_env("FOO"))

  withr::local_envvar(FOO = 1.4)
  expect_equal(as_difftime_env("FOO"), 1.4)

  withr::local_envvar(FOO = "1m")
  expect_equal(as_difftime_env("FOO"), 60 * 1000)

  helper <- function(ev) as_difftime_env(ev)
  expect_snapshot(
    error = TRUE,
    local({
      withr::local_envvar(FOO = "qqq")
      helper("FOO")
    })
  )
})

test_that("parse_time_spec", {
  expect_equal(parse_time_spec("1us"), 1 / 1000)
  expect_equal(parse_time_spec("1ms"), 1)
  expect_equal(parse_time_spec("2s"), 2 * 1000)
  expect_equal(parse_time_spec("3m"), 3 * 60 * 1000)
  expect_equal(parse_time_spec("4h"), 4 * 60 * 60 * 1000)
  expect_equal(parse_time_spec("5d"), 5 * 24 * 60 * 60 * 1000)
})

test_that("as_bytes", {
  expect_null(as_bytes(NULL))
  expect_equal(as_bytes(123), 123)
  expect_equal(as_bytes("456"), 456)
  expect_equal(as_bytes("1kib"), 1024)

  helper <- function(b) as_bytes(b)
  expect_snapshot(error = TRUE, {
    v1 <- "notgood"
    helper(v1)
    v2 <- 1:5
    helper(v2)
  })
})

test_that("as_bytes_env", {
  withr::local_envvar(FOO = NA_character_)
  expect_null(as_bytes_env("FOO"))

  withr::local_envvar(FOO = "100")
  expect_equal(as_bytes_env("FOO"), 100)

  withr::local_envvar(FOO = "2MB")
  expect_equal(as_bytes_env("FOO"), 2 * 1000 * 1000)

  helper <- function(ev) as_bytes_env((ev))
  expect_snapshot(
    error = TRUE,
    local({
      withr::local_envvar(FOO = "100www")
      helper("FOO")
    })
  )
})

test_that("parse_bytes_spec", {
  expect_equal(parse_bytes_spec("1b"), 1)
  expect_equal(parse_bytes_spec("2kb"), 2 * 1000)
  expect_equal(parse_bytes_spec("3mb"), 3 * 1000 * 1000)
  expect_equal(parse_bytes_spec("4GB"), 4 * 1000 * 1000 * 1000)
  expect_equal(parse_bytes_spec("5TB"), 5 * 1000 * 1000 * 1000 * 1000)
  expect_equal(parse_bytes_spec("6Pb"), 6 * 1000 * 1000 * 1000 * 1000 * 1000)
})

test_that("as_named_list", {
  expect_equal(as_named_list(NULL), NULL)
  expect_equal(as_named_list(list()), list())
  expect_equal(as_named_list(list(a = 1)), list(a = 1))

  helper <- function(nl) as_named_list(nl)
  expect_snapshot(error = TRUE, {
    v1 <- list(a = 1, 2)
    helper(v1)
    v2 <- 1:10
    helper(v2)
  })
})

test_that("as_file_exporter_options", {
  # tested via upstream
  expect_true(TRUE)
})

test_that("check_known_options", {
  opts <- list(a = 1, b = 2)
  expect_equal(check_known_options(opts, c("a", "b", "c")), opts)

  helper <- function(o, ...) check_known_options(o, ...)
  expect_snapshot(error = TRUE, {
    helper(opts, c("a"))
    helper(opts, character())
  })
})

test_that("as_logger_provider_file_options", {
  opts <- as_logger_provider_file_options(NULL)
  opts1 <- list(file_pattern = "foo-%N")
  expect_equal(
    as_logger_provider_file_options(opts1),
    modifyList(opts, c(opts1, list(alias_pattern = "foo-latest")))
  )

  helper <- function(o) as_logger_provider_file_options(o)
  expect_snapshot(error = TRUE, {
    v <- list(file_pattern = 1L)
    helper(v)
    v[["file_pattern"]] <- "foo"
    v[["alias_pattern"]] <- 1L
    helper(v)
    v[["alias_pattern"]] <- "foo"
    v[["flush_interval"]] <- mtcars
    helper(v)
    v[["flush_interval"]] <- 1L
    v[["flush_count"]] <- "notgood"
    helper(v)
    v[["flush_count"]] <- 5L
    v[["file_size"]] <- "bad"
    helper(v)
    v[["file_size"]] <- "10MB"
    v[["rotate_size"]] <- "oops"
    helper(v)
    v[["rotate_size"]] <- "1MB"
    v[["bad_option"]] <- 1:10
    helper(v)
  })
})

test_that("as_metric_reader_options", {
  opts <- list(
    export_interval = 500,
    export_timeout = 200
  )
  expect_equal(as_metric_reader_options(opts), opts)

  helper <- function(o) as_metric_reader_options(o)
  expect_snapshot(error = TRUE, {
    v <- list(export_interval = "bad")
    helper(v)
    v <- list(export_interval = "100s", export_timeout = "no")
    helper(v)
  })
})

test_that("as_meter_provider_file_options", {
  opts <- as_meter_provider_file_options(NULL)
  opts1 <- list(flush_interval = "1m")
  expect_equal(
    as_meter_provider_file_options(opts1),
    modifyList(opts, list(flush_interval = 1 * 60 * 1000))
  )

  helper <- function(o) as_meter_provider_file_options(o)
  expect_snapshot(error = TRUE, {
    v <- list(file_pattern = 1:10)
    helper(v)
    v <- list(bad = 100)
    helper(v)
  })
})

test_that("as_tracer_provider_file_options", {
  opts <- as_tracer_provider_file_options(NULL)
  opts1 <- list(flush_interval = "1m")
  expect_equal(
    as_tracer_provider_file_options(opts1),
    modifyList(opts, list(flush_interval = 1 * 60 * 1000))
  )

  helper <- function(o) as_tracer_provider_file_options(o)
  expect_snapshot(error = TRUE, {
    v <- list(file_pattern = 1:10)
    helper(v)
    v <- list(bad = 100)
    helper(v)
  })
})

test_that("as_otlp_content_type", {
  expect_snapshot(otlp_content_type_values)
  expect_equal(as_otlp_content_type("json"), c(json = 0L))
  expect_equal(as_otlp_content_type("binary"), c(binary = 1L))

  helper <- function(ct) as_otlp_content_type(ct)
  expect_snapshot(error = TRUE, {
    v <- "foo"
    helper(v)
    v2 <- 1:10
    helper(v2)
  })
})

test_that("as_otlp_content_type_env", {
  withr::local_envvar(FOO = NA_character_)
  expect_null(as_otlp_content_type_env("FOO"))

  withr::local_envvar(FOO = "application/json")
  expect_equal(as_otlp_content_type_env("FOO"), c("application/json" = 0L))

  withr::local_envvar(FOO = "invalid")
  helper <- function(ev) as_otlp_content_type_env(ev)
  expect_snapshot(error = TRUE, {
    helper("FOO")
  })
})

test_that("as_otlp_json_bytes_mapping", {
  expect_snapshot({
    as_otlp_json_bytes_mapping("hexid")
    as_otlp_json_bytes_mapping("BASE64")
    as_otlp_json_bytes_mapping("hex")
  })
  helper <- function(v) as_otlp_json_bytes_mapping(v)
  expect_snapshot(error = TRUE, {
    val <- "notthis"
    helper(val)
  })
})

test_that("as_otlp_json_bytes_mapping_env", {
  withr::local_envvar(FOO = NA_character_)
  expect_null(as_otlp_json_bytes_mapping_env("FOO"))

  withr::local_envvar(FOO = "hex")
  expect_snapshot(as_otlp_json_bytes_mapping_env("FOO"))

  helper <- function(ev) as_otlp_json_bytes_mapping_env(ev)
  withr::local_envvar(FOO = "bad")
  expect_snapshot(error = TRUE, {
    helper("FOO")
  })
})

test_that("as_otlp_compression", {
  expect_snapshot({
    as_otlp_compression("none")
    as_otlp_compression("gzip")
  })
  helper <- function(c) as_otlp_compression(c)
  expect_snapshot(error = TRUE, {
    v <- "uncomp"
    helper(v)
  })
})

test_that("is_number", {
  expect_true(is_number(1))
  expect_true(is_number(1L))
  expect_true(is_number(1 / 1000, positive = TRUE))

  expect_false(is_number(1:10 / 2))
  expect_false(is_number(numeric()))
  expect_false(is_number(NA_real_))
  expect_false(is_number(0, positive = TRUE))
  expect_false(is_number(-1, positive = TRUE))
})

test_that("as_number", {
  expect_equal(as_number(1L), 1L)
  expect_equal(as_number("2"), 2)

  helper <- function(n, ...) as_number(n, ...)
  expect_snapshot(error = TRUE, {
    v1 <- 1:4 / 2
    helper(v1)
    v2 <- NA_real_
    helper(v2)
    v3 <- 0
    helper(v3, positive = TRUE)
    v4 <- mtcars
    helper(v4)
  })
})

test_that("as_number_env", {
  withr::local_envvar(FOO = NA_character_)
  expect_null(as_number_env("FOO"))

  withr::local_envvar(FOO = "1")
  expect_equal(as_number_env("FOO"), 1)

  withr::local_envvar(FOO = "100")
  expect_equal(as_number_env("FOO", positive = TRUE), 100)

  helper <- function(ev, ...) as_number_env(ev, ...)
  withr::local_envvar(FOO = "notanumber")
  expect_snapshot(error = TRUE, {
    helper("FOO")
  })

  withr::local_envvar(FOO = "0")
  expect_snapshot(error = TRUE, {
    helper("FOO", positive = TRUE)
  })
})

test_that("as_http_headers", {
  expect_null(as_http_headers(NULL))
  h <- c(foo = "bar", bar = "baz")
  expect_equal(as_http_headers(h), h)

  helper <- function(h) as_http_headers(h)
  expect_snapshot(error = TRUE, {
    v1 <- c("foo", x = "bar")
    helper(v1)
    v2 <- c(a = "x", b = NA_character_)
    helper(v2)
    v3 <- 1:10
    helper(v3)
  })
})

test_that("as_http_exporter_options", {
  # tested upstream
  expect_true(TRUE)
})

test_that("as_tracer_provider_http_options", {
  expect_snapshot(as_tracer_provider_http_options(NULL))

  helper <- function(o) as_tracer_provider_http_options(o)
  expect_snapshot(error = TRUE, {
    v <- list(url = 1)
    helper(v)
    v <- list(content_type = "bad")
    helper(v)
    v <- list(json_bytes_mapping = "no")
    helper(v)
    v <- list(use_json_name = "no")
    helper(v)
    v <- list(console_debug = "yes")
    helper(v)
    v <- list(timeout = "xxx")
    helper(v)
    v <- list(http_headers = c("notgood"))
    helper(v)
    v <- list(ssl_insecure_skip_verify = "notaflag")
    helper(v)
    v <- list(ssl_ca_cert_path = 111)
    helper(v)
    v <- list(ssl_ca_cert_string = 222)
    helper(v)
    v <- list(ssl_client_key_path = 333)
    helper(v)
    v <- list(ssl_client_key_string = 444)
    helper(v)
    v <- list(ssl_client_cert_path = 555)
    helper(v)
    v <- list(ssl_client_cert_string = 666)
    helper(v)
    v <- list(ssl_min_tls = 777)
    helper(v)
    v <- list(ssl_max_tls = 888)
    helper(v)
    v <- list(ssl_cipher = 999)
    helper(v)
    v <- list(ssl_cipher_suite = 0)
    helper(v)
    v <- list(compression = "pleaseno")
    helper(v)
    v <- list(retry_policy_max_attempts = "notcount")
    helper(v)
    v <- list(retry_policy_initial_backoff = "bad")
    helper(v)
    v <- list(retry_policy_max_backoff = "stillbad")
    helper(v)
    v <- list(retry_policy_backoff_multiplier = NA_real_)
    helper(v)
  })
})
