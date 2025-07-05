# as_timestamp

    Code
      as_timestamp(NULL)
    Output
      NULL
    Code
      as_timestamp(t)
    Output
      [1] 1742214039
    Code
      as_timestamp(as.double(t))
    Output
      [1] 1742214039
    Code
      as_timestamp(as.integer(t))
    Output
      [1] 1742214039

---

    Code
      helper(b1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ts` must be a time stamp (`POSIXt` scalar or numeric scalar), but it is a data frame.
    Code
      helper(b2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ts` must be a time stamp (`POSIXt` scalar or numeric scalar), but it is a <Date> object.
    Code
      helper(b3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ts` must be a time stamp (`POSIXt` scalar or numeric scalar), but it is too long.
    Code
      helper(b4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ts` must be a time stamp (`POSIXt` scalar or numeric scalar), but it is `NA`.
    Code
      helper(b5)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ts` must be a time stamp (`POSIXt` scalar or numeric scalar), but it is an integer vector.
    Code
      helper(b6)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ts` must be a time stamp (`POSIXt` scalar or numeric scalar), but it is an empty vector.

# as_span

    Code
      as_span(NULL)
    Output
      NULL
    Code
      as_span(NA)
    Output
      [1] NA
    Code
      as_span(NA_character_)
    Output
      [1] NA
    Code
      as_span(sp)
    Output
      list()
      attr(,"class")
      [1] "otel_span"

---

    Code
      helper(b1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `s` must be a span object (`otel_span`), but it is a data frame.

# as_span_context

    Code
      as_span_context(NULL)
    Output
      NULL
    Code
      as_span_context(NA)
    Output
      [1] NA
    Code
      as_span_context(NA_character_)
    Output
      [1] NA
    Code
      as_span_context(spc)
    Output
      list()
      attr(,"class")
      [1] "otel_span_context"

---

    Code
      helper(b1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `spc` must be a span context object (`otel_span_context`), but it is a data frame.

# as_span_parent

    Code
      helper(b1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `spp` must be a span (`otel_span`) or a span context (`otel_span_context`) object but it is a data frame.

# as_choice

    Code
      as_choice(NULL, c(default = "foo", "bar"))
    Output
      [1] 0
    Code
      as_choice("foo", c(default = "foo", "bar"))
    Output
      [1] 0
    Code
      as_choice("bar", c(default = "foo", "bar"))
    Output
      [1] 1

---

    Code
      helper(b1, c(default = "foo", "bar"))
    Condition
      Error in `helper()`:
      ! Invalid argument: `ch` must be one of foo, bar, but it is foobar.
    Code
      helper(b2, c(default = "foo", "bar"))
    Condition
      Error in `helper()`:
      ! Invalid argument: `ch` must be a string scalar, one of foo, bar, but it is an integer vector.

# as_env

    Code
      helper(e1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `e` must be an environment, but it is an integer vector.
    Code
      helper(e2, null = FALSE)
    Condition
      Error in `helper()`:
      ! Invalid argument: `e` must be an environment, but it is NULL.

# as_string

    Code
      helper(s1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `s` must be a string scalar but it is a number.
    Code
      helper(s2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `s` must be a string scalar but it is an empty character vector.
    Code
      helper(s3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `s` must be a string scalar but it is a character vector.
    Code
      helper(s4, null = FALSE)
    Condition
      Error in `helper()`:
      ! Invalid argument: `s` must be a string scalar but it is NULL.

---

    Code
      helper(s)
    Condition
      Error in `helper()`:
      ! Invalid argument: `s` must be a string scalar but it is an integer vector.

# as_flag

    Code
      helper(b1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `f` must a flag (logical scalar), but it is an integer vector.

# as_otel_attribute_value

    Code
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `oav` must be of type character, logical, double, or integer, but it is an empty list.
    Code
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `oav` must not contain missing (`NA`) values.
    Code
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `oav` must not contain missing (`NA`) values.
    Code
      helper(v4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `oav` must not contain missing (`NA`) values.
    Code
      helper(v5)
    Condition
      Error in `helper()`:
      ! Invalid argument: `oav` must not contain missing (`NA`) values.

# as_otel_attributes

    Code
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `att` must be a named list, but it is an integer vector.
    Code
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `att` must be a named list, but not all of its entries are named.
    Code
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `att` can only contain types character, logical, double, and integer, but it contains list types.
    Code
      helper(v4)
    Condition
      Error in `helper()`:
      ! Invalid argument: the entries of `att` must not contain missing (`NA`) values.

# as_span_link

    Code
      link <- 1:10
      helper(link)
    Condition
      Error in `helper()`:
      ! Invalid argument: `spl` must be either an OpenTelemetry span (`otel_span`) object or a list with a span object as the first element and named span attributes as the rest.
    Code
      link <- list(sl, "foo", "bar")
      helper(link)
    Condition
      Error in `helper()`:
      ! Invalid argument: `spl[-1]` must be a named list, but not all of its entries are named.
    Code
      link <- list(sl, a = "1", b = c(1, NA))
      helper(link)
    Condition
      Error in `helper()`:
      ! Invalid argument: the entries of `spl[-1]` must not contain missing (`NA`) values.

# as_span_links

    Code
      links <- 1:10
      helper(links)
    Condition
      Error in `helper()`:
      ! Invalid argument: `spls` must be a named list, but it is an integer vector.
    Code
      links <- list(1:10)
      helper(links)
    Condition
      Error in `helper()`:
      ! Invalid argument: `spls[[1L]]` must be either an OpenTelemetry span (`otel_span`) object or a list with a span object as the first element and named span attributes as the rest.

# as_span_options

    Code
      options <- 1:10
      helper(options)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts` must be a named list of OpenTelemetry span options, but it is an integer vector.
    Code
      options <- list("foo")
      helper(options)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts` must be a named list of OpenTelemetry span options, but not all of its entries are named.
    Code
      options <- list(kind = "internal", foo = "notgood")
      helper(options)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts` contains unknown OpenTelemetry span option: foo. Known span options are: start_system_time, start_steady_time, parent, and kind.
    Code
      options <- list(kind = 10)
      helper(options)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts[["kind"]]` must be a string scalar, one of internal, server, client, producer, consumer, but it is a number.

# as_end_span_options

    Code
      o1 <- 1:10
      helper(o1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts` must be a named list of OpenTelemetry end span options, but it is an integer vector.
    Code
      o2 <- list("foo")
      helper(o2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts` must be a named list of OpenTelemetry end span options, but not all of its entries are named.
    Code
      o3 <- list(end_steady_time = t, foo = "notgood")
      helper(o3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts` contains unknown OpenTelemetry end span options: foo. Known end span options are: end_steady_time.
    Code
      o4 <- list(end_steady_time = "bad")
      helper(o4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `opts[["end_steady_time"]]` must be a time stamp (`POSIXt` scalar or numeric scalar), but it is a string.

# as_output_file

    Code
      helper(tmp3)
    Condition
      Error in `helper()`:
      ! Directory of OpenTelemetry output file '<tempdir>/<tempfile>/output' does not exist or it is not writeable.

---

    Code
      helper(tmp3)
    Condition
      Error in `helper()`:
      ! Cannot write to OpenTelemetry output file '<tempdir>/<tempfile>/output'.

# as_log_severity

    Code
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ls` must be one of trace, trace2, trace3, trace4, debug, debug2, debug3, debug4, info, info2, info3, info4, warn, warn2, warn3, warn4, error, error2, error3, error4, fatal, fatal2, fatal3, fatal4, but it is foobar.
    Code
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ls` must be an integer log level, between 1 and 24, but it is an integer vector.
    Code
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ls` must be an integer log level, between 1 and 24, but it is 200.
    Code
      helper(v4, spec = TRUE)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ls` must be an integer log level, between 0 and 24, or 255, but it is 200.
    Code
      helper(v5)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ls` must be an integer log level, between 1 and 24, but it is 0.
    Code
      helper(v6)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ls` must be an integer log level, between 1 and 24, but it is 255.

# as_span_id

    Code
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `sid` must be a span id, a string scalar containing 16 hexadecimal digits, but it is 'badcafebadcafeb'.
    Code
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `sid` must be a span id, a string scalar containing 16 hexadecimal digits, but it is `NA`.
    Code
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `sid` must be a span id, a string scalar containing 16 hexadecimal digits, but it is 'XXXXXXXXXXXXXXXX'.
    Code
      helper(v4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `sid` must be a span id, a string scalar containing 16 hexadecimal digits, but it is an integer vector.

# as_trace_id

    Code
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `tid` must be a trace id, a string scalar containing 32 hexadecimal digits, but it is 'badcafebadcafebadcafebadcafebad'.
    Code
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `tid` must be a trace id, a string scalar containing 32 hexadecimal digits, but it is `NA`.
    Code
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `tid` must be a trace id, a string scalar containing 32 hexadecimal digits, but it is 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'.
    Code
      helper(v4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `tid` must be a trace id, a string scalar containing 32 hexadecimal digits, but it is an integer vector.

# as_count

    Code
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must be an integer scalar, not a vector.
    Code
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must not be `NA`.
    Code
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must not be `NA`.
    Code
      helper(v4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must be non-negative.
    Code
      helper(v5, positive = TRUE)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must be positive.
    Code
      helper(v6)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must be a non-negative integer scalar, but it is a data frame.
    Code
      helper(v7)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must be a non-negative integer scalar, but it is a string.

# as_count_env

    Code
      helper("FOO")
    Condition
      Error in `helper()`:
      ! Invalid environment variable: `FOO` must be a non-negative integer. It is 'oops'.

---

    Code
      helper("FOO")
    Condition
      Error in `helper()`:
      ! Invalid environment variable: `FOO` must be a non-negative integer. It is '-1'.

---

    Code
      helper("FOO", positive = TRUE)
    Condition
      Error in `helper()`:
      ! unused argument (positive = TRUE)

# as_http_context_headers

    Code
      v1 <- 1:10
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `hdr` must be a named list, but it is a an integer vector.
    Code
      v2 <- list(traceparent = TRUE)
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: the 'traceparent' entry of `hdr` must be a string (character scalar), but it is a `TRUE`.
    Code
      v3 <- list(tracestate = raw(10))
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: the 'tracestate' entry of `hdr` must be a string (character scalar), but it is a a raw vector.

# as_difftime_spec

    Code
      v1 <- as.difftime(NA_real_, units = "secs")
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `dt` must have length 1, and must not be `NA`. It is `NA`.
    Code
      v2 <- as.difftime(1:2, units = "secs")
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `dt` must have length 1, and must not be `NA`. It has length {length(x)}.
    Code
      v3 <- "foo"
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `dt` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v4 <- "0"
      helper(v4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `dt` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v5 <- raw(10)
      helper(v5)
    Condition
      Error in `helper()`:
      ! Invalid argument: `dt` must be an integer scalar (milliseconds), a 'difftime' scalar, or a time interval specification. A time interval specification is apositive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours) or d (days). But it is a a raw vector.

# as_difftime_env

    Code
      local({
        withr::local_envvar(FOO = "qqq")
        helper("FOO")
      })
    Condition
      Error in `helper()`:
      ! Invalid environment variable: FOO='qqq'. It must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).

# as_bytes

    Code
      v1 <- "notgood"
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: could not interpret `b` as a number of bytes. It must be a number with a unit suffix: one of B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB.
    Code
      v2 <- 1:5
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `b` must be an integer (bytes) or a string scalar with a unit suffix. Known units are B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB. But it is a an integer vector.

# as_bytes_env

    Code
      local({
        withr::local_envvar(FOO = "100www")
        helper("FOO")
      })
    Condition
      Error in `helper()`:
      ! Invalid environment variable: FOO='100www'. It must be an integer with a unit suffix. Known units are B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB.

