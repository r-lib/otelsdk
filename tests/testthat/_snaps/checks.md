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
      <otel_span>
      name: 
      methods:

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
      <otel_span_context>
      methods:
    Code
      as_span_context(sp)
    Output
      [1] "context"

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
      ! Invalid argument: `ch` must be one of 'foo', 'bar', but it is 'foobar'.
    Code
      helper(b2, c(default = "foo", "bar"))
    Condition
      Error in `helper()`:
      ! Invalid argument: `ch` must be a string scalar, one of 'foo', 'bar', but it is an integer vector.

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

# as_flag_env

    Code
      helper("FOO")
    Condition
      Error in `helper()`:
      ! Invalid environment variable: 'FOO' must be 'true' or 'false' (case insensitive). It is 'notgood'.

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
      ! Invalid argument: `opts[["kind"]]` must be a string scalar, one of 'internal', 'server', 'client', 'producer', 'consumer', but it is a number.

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
      ! Invalid argument: `ls` must be one of 'trace', 'trace2', 'trace3', 'trace4', 'debug', 'debug2', 'debug3', 'debug4', 'info', 'info2', 'info3', 'info4', 'warn', 'warn2', 'warn3', 'warn4', 'error', 'error2', 'error3', 'error4', 'fatal', 'fatal2', 'fatal3', 'fatal4', but it is 'foobar'.
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

# as_named_list

    Code
      v1 <- list(a = 1, 2)
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `nl` must be a named list, but it is not named.
    Code
      v2 <- 1:10
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `nl` must be a named list, but it is an integer vector.

# check_known_options

    Code
      helper(opts, c("a"))
    Condition
      Error in `helper()`:
      ! Invalid argument: `o` has unknown option: 'b'.
    Code
      helper(opts, character())
    Condition
      Error in `helper()`:
      ! Invalid argument: `o` has unknown options: 'a', 'b'.

# as_logger_provider_file_options

    Code
      v <- list(file_pattern = 1L)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["file_pattern"]]` must be a string scalar but it is an integer.
    Code
      v[["file_pattern"]] <- "foo"
      v[["alias_pattern"]] <- 1L
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["alias_pattern"]]` must be a string scalar but it is an integer.
    Code
      v[["alias_pattern"]] <- "foo"
      v[["flush_interval"]] <- mtcars
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["flush_interval"]]` must be an integer scalar (milliseconds), a 'difftime' scalar, or a time interval specification. A time interval specification is apositive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours) or d (days). But it is a a data frame.
    Code
      v[["flush_interval"]] <- 1L
      v[["flush_count"]] <- "notgood"
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["flush_count"]]` must be a non-negative integer scalar, but it is a string.
    Code
      v[["flush_count"]] <- 5L
      v[["file_size"]] <- "bad"
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: could not interpret `o[["file_size"]]` as a number of bytes. It must be a number with a unit suffix: one of B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB.
    Code
      v[["file_size"]] <- "10MB"
      v[["rotate_size"]] <- "oops"
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: could not interpret `o[["rotate_size"]]` as a number of bytes. It must be a number with a unit suffix: one of B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB.
    Code
      v[["rotate_size"]] <- "1MB"
      v[["bad_option"]] <- 1:10
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o` has unknown option: 'bad_option'.

# as_metric_reader_options

    Code
      v <- list(export_interval = "bad")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["export_interval"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v <- list(export_interval = "100s", export_timeout = "no")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["export_timeout"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).

# as_meter_provider_file_options

    Code
      v <- list(file_pattern = 1:10)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["file_pattern"]]` must be a string scalar but it is an integer vector.
    Code
      v <- list(bad = 100)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o` has unknown option: 'bad'.

# as_tracer_provider_file_options

    Code
      v <- list(file_pattern = 1:10)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["file_pattern"]]` must be a string scalar but it is an integer vector.
    Code
      v <- list(bad = 100)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o` has unknown option: 'bad'.

# as_otlp_content_type

    Code
      otlp_content_type_values
    Output
                        json       application/json                 binary 
                           0                      0                      1 
      application/x-protobuf 
                           1 

---

    Code
      v <- "foo"
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `ct` must be one of 'json', 'application/json', 'binary', 'application/x-protobuf', but it is 'foo'.
    Code
      v2 <- 1:10
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: ct must a string, one of 'json', 'application/json', 'binary', 'application/x-protobuf', but it is an integer vector.

# as_otlp_content_type_env

    Code
      helper("FOO")
    Condition
      Error in `helper()`:
      ! Invalid environment variable: 'FOO' must be one of 'json', 'application/json', 'binary', 'application/x-protobuf', but it is 'invalid'.

# as_otlp_json_bytes_mapping

    Code
      as_otlp_json_bytes_mapping("hexid")
    Output
      [1] 0
    Code
      as_otlp_json_bytes_mapping("BASE64")
    Output
      [1] 1
    Code
      as_otlp_json_bytes_mapping("hex")
    Output
      [1] 2

---

    Code
      val <- "notthis"
      helper(val)
    Condition
      Error in `helper()`:
      ! Invalid argument: `v` must be one of 'hexid', 'base64', 'hex', but it is 'notthis'.

# as_otlp_json_bytes_mapping_env

    Code
      as_otlp_json_bytes_mapping_env("FOO")
    Output
      [1] 2

---

    Code
      helper("FOO")
    Condition
      Error in `helper()`:
      ! Invalid environment variable: 'FOO' must be one of hexid, base64, hex (case insensitive), but it is 'bad'.

# as_otlp_compression

    Code
      as_otlp_compression("none")
    Output
      [1] 0
    Code
      as_otlp_compression("gzip")
    Output
      [1] 1

---

    Code
      v <- "uncomp"
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `c` must be one of 'none', 'gzip', but it is 'uncomp'.

# as_number

    Code
      v1 <- 1:4 / 2
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: `n` must be a numeric scalar, not a vector.
    Code
      v2 <- NA_real_
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `n` must not be `NA`.
    Code
      v3 <- 0
      helper(v3, positive = TRUE)
    Condition
      Error in `helper()`:
      ! Invalid argument: `n` must be positive.
    Code
      v4 <- mtcars
      helper(v4)
    Condition
      Error in `helper()`:
      ! Invalid argument: `n` must be a number, but it is a data frame.

# as_number_env

    Code
      helper("FOO")
    Condition
      Error in `helper()`:
      ! Invalid environment variable: 'FOO' must be a number. It is 'notanumber'.

---

    Code
      helper("FOO", positive = TRUE)
    Condition
      Error in `helper()`:
      ! Invalid environment variable: 'FOO' must be a positive number. It is '0'.

# as_http_headers

    Code
      v1 <- c("foo", x = "bar")
      helper(v1)
    Condition
      Error in `helper()`:
      ! Invalid argument: all entries in `h` must be a named.
    Code
      v2 <- c(a = "x", b = NA_character_)
      helper(v2)
    Condition
      Error in `helper()`:
      ! Invalid argument: `h` must not contain `NA` values.
    Code
      v3 <- 1:10
      helper(v3)
    Condition
      Error in `helper()`:
      ! Invalid argument: `h` must be a named character vector without `NA` values, but it is an integer vector.

# as_batch_processor_options

    Code
      opts <- list(max_queue_size = "bad")
      as_batch_processor_options(opts)
    Condition
      Error:
      ! Invalid argument: `opts[["max_queue_size"]]` must be a positive integer scalar, but it is a string.

# as_tracer_provider_http_options

    Code
      as_tracer_provider_http_options(NULL)
    Output
      $url
      NULL
      
      $content_type
      binary 
           1 
      
      $json_bytes_mapping
      [1] 0
      
      $use_json_name
      [1] FALSE
      
      $console_debug
      [1] FALSE
      
      $timeout
      NULL
      
      $http_headers
      NULL
      
      $ssl_insecure_skip_verify
      [1] FALSE
      
      $ssl_ca_cert_path
      NULL
      
      $ssl_ca_cert_string
      NULL
      
      $ssl_client_key_path
      NULL
      
      $ssl_client_key_string
      NULL
      
      $ssl_client_cert_path
      NULL
      
      $ssl_client_cert_string
      NULL
      
      $ssl_min_tls
      [1] ""
      
      $ssl_max_tls
      [1] ""
      
      $ssl_cipher
      [1] ""
      
      $ssl_cipher_suite
      [1] ""
      
      $compression
      [1] 0
      
      $retry_policy_max_attempts
      [1] 5
      
      $retry_policy_initial_backoff
      [1] 1000
      
      $retry_policy_max_backoff
      [1] 5000
      
      $retry_policy_backoff_multiplier
      [1] 1.5
      
      $max_queue_size
      NULL
      
      $max_export_batch_size
      NULL
      
      $schedule_delay
      NULL
      

---

    Code
      v <- list(url = 1)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["url"]]` must be a string scalar but it is a number.
    Code
      v <- list(content_type = "bad")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["content_type"]]` must be one of 'json', 'application/json', 'binary', 'application/x-protobuf', but it is 'bad'.
    Code
      v <- list(json_bytes_mapping = "no")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["json_bytes_mapping"]]` must be one of 'hexid', 'base64', 'hex', but it is 'no'.
    Code
      v <- list(use_json_name = "no")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["use_json_name"]]` must a flag (logical scalar), but it is a string.
    Code
      v <- list(console_debug = "yes")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["console_debug"]]` must a flag (logical scalar), but it is a string.
    Code
      v <- list(timeout = "xxx")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["timeout"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v <- list(http_headers = c("notgood"))
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: all entries in `o[["http_headers"]]` must be a named.
    Code
      v <- list(ssl_insecure_skip_verify = "notaflag")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_insecure_skip_verify"]]` must a flag (logical scalar), but it is a string.
    Code
      v <- list(ssl_ca_cert_path = 111)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_ca_cert_path"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_ca_cert_string = 222)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_ca_cert_string"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_key_path = 333)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_key_path"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_key_string = 444)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_key_string"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_cert_path = 555)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_cert_path"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_cert_string = 666)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_cert_string"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_min_tls = 777)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_min_tls"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_max_tls = 888)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_max_tls"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_cipher = 999)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_cipher"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_cipher_suite = 0)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_cipher"]]` must be a string scalar but it is a number.
    Code
      v <- list(compression = "pleaseno")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["compression"]]` must be one of 'none', 'gzip', but it is 'pleaseno'.
    Code
      v <- list(retry_policy_max_attempts = "notcount")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_max_attempts"]]` must be a positive integer scalar, but it is a string.
    Code
      v <- list(retry_policy_initial_backoff = "bad")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_initial_backoff"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v <- list(retry_policy_max_backoff = "stillbad")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_max_backoff"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v <- list(retry_policy_backoff_multiplier = NA_real_)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_backoff_multiplier"]]` must not be `NA`.

# as_logger_provider_http_options

    Code
      as_logger_provider_http_options(NULL)
    Output
      $url
      NULL
      
      $content_type
      binary 
           1 
      
      $json_bytes_mapping
      [1] 0
      
      $use_json_name
      [1] FALSE
      
      $console_debug
      [1] FALSE
      
      $timeout
      NULL
      
      $http_headers
      NULL
      
      $ssl_insecure_skip_verify
      [1] FALSE
      
      $ssl_ca_cert_path
      NULL
      
      $ssl_ca_cert_string
      NULL
      
      $ssl_client_key_path
      NULL
      
      $ssl_client_key_string
      NULL
      
      $ssl_client_cert_path
      NULL
      
      $ssl_client_cert_string
      NULL
      
      $ssl_min_tls
      [1] ""
      
      $ssl_max_tls
      [1] ""
      
      $ssl_cipher
      [1] ""
      
      $ssl_cipher_suite
      [1] ""
      
      $compression
      [1] 0
      
      $retry_policy_max_attempts
      [1] 5
      
      $retry_policy_initial_backoff
      [1] 1000
      
      $retry_policy_max_backoff
      [1] 5000
      
      $retry_policy_backoff_multiplier
      [1] 1.5
      
      $max_queue_size
      NULL
      
      $max_export_batch_size
      NULL
      
      $schedule_delay
      NULL
      

---

    Code
      v <- list(url = 1)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["url"]]` must be a string scalar but it is a number.
    Code
      v <- list(content_type = "bad")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["content_type"]]` must be one of 'json', 'application/json', 'binary', 'application/x-protobuf', but it is 'bad'.
    Code
      v <- list(json_bytes_mapping = "no")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["json_bytes_mapping"]]` must be one of 'hexid', 'base64', 'hex', but it is 'no'.
    Code
      v <- list(use_json_name = "no")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["use_json_name"]]` must a flag (logical scalar), but it is a string.
    Code
      v <- list(console_debug = "yes")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["console_debug"]]` must a flag (logical scalar), but it is a string.
    Code
      v <- list(timeout = "xxx")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["timeout"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v <- list(http_headers = c("notgood"))
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: all entries in `o[["http_headers"]]` must be a named.
    Code
      v <- list(ssl_insecure_skip_verify = "notaflag")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_insecure_skip_verify"]]` must a flag (logical scalar), but it is a string.
    Code
      v <- list(ssl_ca_cert_path = 111)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_ca_cert_path"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_ca_cert_string = 222)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_ca_cert_string"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_key_path = 333)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_key_path"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_key_string = 444)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_key_string"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_cert_path = 555)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_cert_path"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_client_cert_string = 666)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_client_cert_string"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_min_tls = 777)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_min_tls"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_max_tls = 888)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_max_tls"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_cipher = 999)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_cipher"]]` must be a string scalar but it is a number.
    Code
      v <- list(ssl_cipher_suite = 0)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["ssl_cipher"]]` must be a string scalar but it is a number.
    Code
      v <- list(compression = "pleaseno")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["compression"]]` must be one of 'none', 'gzip', but it is 'pleaseno'.
    Code
      v <- list(retry_policy_max_attempts = "notcount")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_max_attempts"]]` must be a positive integer scalar, but it is a string.
    Code
      v <- list(retry_policy_initial_backoff = "bad")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_initial_backoff"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v <- list(retry_policy_max_backoff = "stillbad")
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_max_backoff"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).
    Code
      v <- list(retry_policy_backoff_multiplier = NA_real_)
      helper(v)
    Condition
      Error in `helper()`:
      ! Invalid argument: `o[["retry_policy_backoff_multiplier"]]` must not be `NA`.

# as_aggregation_temporality_env

    Code
      as_aggregation_temporality_env("FOO")
    Condition
      Error:
      ! Invalid environment variable: 'FOO' must be one of 'unspecified', 'delta', 'cumulative', 'lowmemory' (case insensitive), bit it is 'notgood'.

# as_metric_exporter_options

    Code
      as_metric_exporter_options(list())
    Output
      $aggregation_temporality
      cumulative 
               2 
      
    Code
      as_metric_exporter_options(list(aggregation_temporality = "delta"))
    Output
      $aggregation_temporality
      delta 
          1 
      

---

    Code
      as_metric_exporter_options(o1)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_metric_exporter_options(o2)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_metric_exporter_options(o3)
    Condition
      Error:
      ! Invalid argument: `o3[["aggregation_temporality"]]` must be one of 'unspecified', 'delta', 'cumulative', 'lowmemory', but it is 'badvalue'.

# as_meter_provider_http_options

    Code
      as_meter_provider_http_options(list())
    Output
      $url
      NULL
      
      $content_type
      binary 
           1 
      
      $json_bytes_mapping
      [1] 0
      
      $use_json_name
      [1] FALSE
      
      $console_debug
      [1] FALSE
      
      $timeout
      NULL
      
      $http_headers
      NULL
      
      $ssl_insecure_skip_verify
      [1] FALSE
      
      $ssl_ca_cert_path
      NULL
      
      $ssl_ca_cert_string
      NULL
      
      $ssl_client_key_path
      NULL
      
      $ssl_client_key_string
      NULL
      
      $ssl_client_cert_path
      NULL
      
      $ssl_client_cert_string
      NULL
      
      $ssl_min_tls
      [1] ""
      
      $ssl_max_tls
      [1] ""
      
      $ssl_cipher
      [1] ""
      
      $ssl_cipher_suite
      [1] ""
      
      $compression
      [1] 0
      
      $retry_policy_max_attempts
      [1] 5
      
      $retry_policy_initial_backoff
      [1] 1000
      
      $retry_policy_max_backoff
      [1] 5000
      
      $retry_policy_backoff_multiplier
      [1] 1.5
      
      $export_interval
      [1] 60000
      
      $export_timeout
      [1] 30000
      
      $aggregation_temporality
      cumulative 
               2 
      
    Code
      as_meter_provider_http_options(list(export_interval = 100))
    Output
      $url
      NULL
      
      $content_type
      binary 
           1 
      
      $json_bytes_mapping
      [1] 0
      
      $use_json_name
      [1] FALSE
      
      $console_debug
      [1] FALSE
      
      $timeout
      NULL
      
      $http_headers
      NULL
      
      $ssl_insecure_skip_verify
      [1] FALSE
      
      $ssl_ca_cert_path
      NULL
      
      $ssl_ca_cert_string
      NULL
      
      $ssl_client_key_path
      NULL
      
      $ssl_client_key_string
      NULL
      
      $ssl_client_cert_path
      NULL
      
      $ssl_client_cert_string
      NULL
      
      $ssl_min_tls
      [1] ""
      
      $ssl_max_tls
      [1] ""
      
      $ssl_cipher
      [1] ""
      
      $ssl_cipher_suite
      [1] ""
      
      $compression
      [1] 0
      
      $retry_policy_max_attempts
      [1] 5
      
      $retry_policy_initial_backoff
      [1] 1000
      
      $retry_policy_max_backoff
      [1] 5000
      
      $retry_policy_backoff_multiplier
      [1] 1.5
      
      $export_interval
      [1] 100
      
      $export_timeout
      [1] 30000
      
      $aggregation_temporality
      cumulative 
               2 
      

---

    Code
      as_meter_provider_http_options(o1)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_meter_provider_http_options(o2)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_meter_provider_http_options(o3)
    Condition
      Error:
      ! Invalid argument: `o3[["export_interval"]]` must be a time interval specification, a positive number with a time unit suffix: us (microseconds), ms (milliseconds), s (seconds), m (minutes), h (hours), or d (days).

# as_stdstream_exporter_options

    Code
      as_stdstream_exporter_options(list(), evs)
    Output
      $output
      [1] "stdout"
      
    Code
      as_stdstream_exporter_options(list(output = "stderr"), evs)
    Output
      $output
      [1] "stderr"
      
    Code
      as_stdstream_exporter_options(list(output = "./stderr"), evs)
    Output
      $output
      [1] "./stderr"
      

---

    Code
      as_stdstream_exporter_options(o1, evs)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_stdstream_exporter_options(o2, evs)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_stdstream_exporter_options(o3, evs)
    Condition
      Error:
      ! Invalid argument: `o3[["output"]]` must be a string scalar but it is an integer vector.

# as_logger_provider_stdstream_options

    Code
      as_logger_provider_stdstream_options(list())
    Output
      $output
      [1] "stdout"
      
    Code
      as_logger_provider_stdstream_options(list(output = "stdout"))
    Output
      $output
      [1] "stdout"
      

---

    Code
      as_logger_provider_stdstream_options(o1)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_logger_provider_stdstream_options(o2)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_logger_provider_stdstream_options(o3)
    Condition
      Error:
      ! Invalid argument: `o3[["output"]]` must be a string scalar but it is an integer vector.

# as_meter_provider_stdstream_options

    Code
      as_meter_provider_stdstream_options(list())
    Output
      $output
      [1] "stdout"
      
      $export_interval
      [1] 60000
      
      $export_timeout
      [1] 30000
      
    Code
      as_meter_provider_stdstream_options(list(export_interval = "3s"))
    Output
      $output
      [1] "stdout"
      
      $export_interval
      [1] 3000
      
      $export_timeout
      [1] 30000
      

---

    Code
      as_meter_provider_stdstream_options(o1)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_meter_provider_stdstream_options(o2)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_meter_provider_stdstream_options(o3)
    Condition
      Error:
      ! Invalid argument: `o3[["output"]]` must be a string scalar but it is an integer vector.

# as_tracer_provider_stdstream_options

    Code
      as_tracer_provider_stdstream_options(list())
    Output
      $output
      [1] "stdout"
      
    Code
      as_tracer_provider_stdstream_options(list(output = "stdout"))
    Output
      $output
      [1] "stdout"
      

---

    Code
      as_tracer_provider_stdstream_options(o1)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_tracer_provider_stdstream_options(o2)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_tracer_provider_stdstream_options(o3)
    Condition
      Error:
      ! Invalid argument: `o3[["output"]]` must be a string scalar but it is an integer vector.
    Code
      as_tracer_provider_stdstream_options(o4)
    Condition
      Error:
      ! Invalid argument: `o4` has unknown option: 'unknown'.

# as_memory_exporter_options

    Code
      as_memory_exporter_options(list(), evs)
    Output
      $buffer_size
      [1] 100
      
    Code
      as_memory_exporter_options(list(buffer_size = 10), evs)
    Output
      $buffer_size
      [1] 10
      

---

    Code
      as_memory_exporter_options(o1, evs)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_memory_exporter_options(o2, evs)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_memory_exporter_options(o3, evs)
    Condition
      Error:
      ! Invalid argument: `o3[["buffer_size"]]` must be an integer scalar, not a vector.

# as_tracer_provider_memory_options

    Code
      as_tracer_provider_memory_options(list())
    Output
      $buffer_size
      [1] 100
      
    Code
      as_tracer_provider_memory_options(list(buffer_size = 15))
    Output
      $buffer_size
      [1] 15
      

---

    Code
      as_tracer_provider_memory_options(o1)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_tracer_provider_memory_options(o2)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_tracer_provider_memory_options(o3)
    Condition
      Error:
      ! Invalid argument: `o3[["buffer_size"]]` must be an integer scalar, not a vector.
    Code
      as_tracer_provider_memory_options(o4)
    Condition
      Error:
      ! Invalid argument: `o4` has unknown option: 'unknown'.

# as_meter_provider_memory_options

    Code
      as_meter_provider_memory_options(list())
    Output
      $buffer_size
      [1] 100
      
      $export_interval
      [1] 60000
      
      $export_timeout
      [1] 30000
      
      $aggregation_temporality
      cumulative 
               2 
      
    Code
      as_meter_provider_memory_options(list(buffer_size = 15))
    Output
      $buffer_size
      [1] 15
      
      $export_interval
      [1] 60000
      
      $export_timeout
      [1] 30000
      
      $aggregation_temporality
      cumulative 
               2 
      

---

    Code
      as_meter_provider_memory_options(o1)
    Condition
      Error:
      ! Invalid argument: `o1` must be a named list, but it is a string.
    Code
      as_meter_provider_memory_options(o2)
    Condition
      Error:
      ! Invalid argument: `o2` must be a named list, but it is not named.
    Code
      as_meter_provider_memory_options(o3)
    Condition
      Error:
      ! Invalid argument: `o3[["buffer_size"]]` must be an integer scalar, not a vector.
    Code
      as_meter_provider_memory_options(o4)
    Condition
      Error:
      ! Invalid argument: `o4` has unknown option: 'unknown'.

