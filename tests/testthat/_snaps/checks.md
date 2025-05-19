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
      as_timestamp(b1)
    Condition
      Error in `as_timestamp()`:
      ! Invalid argument: b1 must be a time stamp (`POSIXt` scalar or numeric scalar), but it is a data frame.
    Code
      as_timestamp(b2)
    Condition
      Error in `as_timestamp()`:
      ! Invalid argument: b2 must be a time stamp (`POSIXt` scalar or numeric scalar), but it is a <Date> object.
    Code
      as_timestamp(b3)
    Condition
      Error in `as_timestamp()`:
      ! Invalid argument: b3 must be a time stamp (`POSIXt` scalar or numeric scalar), but it is too long.
    Code
      as_timestamp(b4)
    Condition
      Error in `as_timestamp()`:
      ! Invalid argument: b4 must be a time stamp (`POSIXt` scalar or numeric scalar), but it is `NA`.
    Code
      as_timestamp(b5)
    Condition
      Error in `as_timestamp()`:
      ! Invalid argument: b5 must be a time stamp (`POSIXt` scalar or numeric scalar), but it is an integer vector.
    Code
      as_timestamp(b6)
    Condition
      Error in `as_timestamp()`:
      ! Invalid argument: b6 must be a time stamp (`POSIXt` scalar or numeric scalar), but it is an empty vector.

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
      as_span(b1)
    Condition
      Error in `as_span()`:
      ! Invalid argument: b1 must be a span object (`otel_span`), but it is a data frame.

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
      as_choice(b1, c(default = "foo", "bar"))
    Condition
      Error in `as_choice()`:
      ! Invalid argument: b1 must be one of foo, bar, but it is foobar.
    Code
      as_choice(b2, c(default = "foo", "bar"))
    Condition
      Error in `as_choice()`:
      ! Invalid argument: b2 must be a string scalar, one of foo, bar, but it is an integer vector.

# as_env

    Code
      as_env(e1)
    Condition
      Error in `as_env()`:
      ! Invalid argument: e1 must be an environment, but it is an integer vector.
    Code
      as_env(e2, null = FALSE)
    Condition
      Error in `as_env()`:
      ! Invalid argument: e2 must be an environment, but it is NULL.

# as_string

    Code
      as_string(s1)
    Condition
      Error in `as_string()`:
      ! Invalid argument: s1 must be a string scalar, but it is a number.
    Code
      as_string(s2)
    Condition
      Error in `as_string()`:
      ! Invalid argument: s2 must be a string scalar, but it is an empty character vector.
    Code
      as_string(s3)
    Condition
      Error in `as_string()`:
      ! Invalid argument: s3 must be a string scalar, but it is a character vector.
    Code
      as_string(s4, null = FALSE)
    Condition
      Error in `as_string()`:
      ! Invalid argument: s4 must be a string scalar, but it is NULL.

# as_otel_attribute_value

    Code
      as_otel_attribute_value(v1)
    Condition
      Error in `as_otel_attribute_value()`:
      ! Invalid argument: v1 must be of type character, logical, double, or integer, but it is an empty list.
    Code
      as_otel_attribute_value(v2)
    Condition
      Error in `as_otel_attribute_value()`:
      ! Invalid argument: v2 must not contain missing (`NA`) values.
    Code
      as_otel_attribute_value(v3)
    Condition
      Error in `as_otel_attribute_value()`:
      ! Invalid argument: v3 must not contain missing (`NA`) values.
    Code
      as_otel_attribute_value(v4)
    Condition
      Error in `as_otel_attribute_value()`:
      ! Invalid argument: v4 must not contain missing (`NA`) values.
    Code
      as_otel_attribute_value(v5)
    Condition
      Error in `as_otel_attribute_value()`:
      ! Invalid argument: v5 must not contain missing (`NA`) values.

# as_otel_attributes

    Code
      as_otel_attributes(v1)
    Condition
      Error in `as_otel_attributes()`:
      ! Invalid argument: v1 must be a named list, but it is an integer vector.
    Code
      as_otel_attributes(v2)
    Condition
      Error in `as_otel_attributes()`:
      ! Invalid argument: v2 must be a named list, but not all of its entries are named.
    Code
      as_otel_attributes(v3)
    Condition
      Error in `as_otel_attributes()`:
      ! Invalid argument: v3 can only contain types character, logical, double, and integer, but it contains list types.
    Code
      as_otel_attributes(v4)
    Condition
      Error in `as_otel_attributes()`:
      ! Invalid argument: the entries of v4 must not contain missing (`NA`) values.

# as_span_link

    Code
      link <- 1:10
      as_span_link(link)
    Condition
      Error in `as_span_link()`:
      ! Invalid argument: link must be either an OpenTelemetry span (`otel_span`) object or a list with a span object as the first element and named span attributes as the rest.
    Code
      link <- list(sl, "foo", "bar")
      as_span_link(link)
    Condition
      Error in `as_otel_attributes()`:
      ! Invalid argument: link[-1] must be a named list, but not all of its entries are named.
    Code
      link <- list(sl, a = "1", b = c(1, NA))
      as_span_link(link)
    Condition
      Error in `as_otel_attributes()`:
      ! Invalid argument: the entries of link[-1] must not contain missing (`NA`) values.

# as_span_links

    Code
      links <- 1:10
      as_span_links(links)
    Condition
      Error in `as_span_links()`:
      ! Invalid argument: links must be a named list, but it is an integer vector.
    Code
      links <- list(1:10)
      as_span_links(links)
    Condition
      Error in `as_span_link()`:
      ! Invalid argument: links[[1L]] must be either an OpenTelemetry span (`otel_span`) object or a list with a span object as the first element and named span attributes as the rest.

# as_span_options

    Code
      options <- 1:10
      as_span_options(options)
    Condition
      Error in `as_span_options()`:
      ! Invalid argument: options must be a named list of OpenTelemetry span options, but it is an integer vector.
    Code
      options <- list("foo")
      as_span_options(options)
    Condition
      Error in `as_span_options()`:
      ! Invalid argument: options must be a named list of OpenTelemetry span options, but not all of its entries are named.
    Code
      options <- list(kind = "internal", foo = "notgood")
      as_span_options(options)
    Condition
      Error in `as_span_options()`:
      ! Invalid argument: options contains unknown OpenTelemetry span option: foo. Known span options are: start_system_time, start_steady_time, parent, and kind.
    Code
      options <- list(kind = 10)
      as_span_options(options)
    Condition
      Error in `as_choice()`:
      ! Invalid argument: options[["kind"]] must be a string scalar, one of internal, server, client, producer, consumer, but it is a number.

# as_end_span_options

    Code
      options <- 1:10
      as_end_span_options(options)
    Condition
      Error in `as_end_span_options()`:
      ! Invalid argument: options must be a named list of OpenTelemetry end span options, but it is an integer vector.
    Code
      options <- list("foo")
      as_end_span_options(options)
    Condition
      Error in `as_end_span_options()`:
      ! Invalid argument: options must be a named list of OpenTelemetry end span options, but not of its entries are named.
    Code
      options <- list(end_steady_time = t, foo = "notgood")
      as_end_span_options(options)
    Condition
      Error in `as_end_span_options()`:
      ! Invalid argument: options contains unknown OpenTelemetry end span options: foo. Known end span options are: end_steady_time.
    Code
      options <- list(end_steady_time = "bad")
      as_end_span_options(options)
    Condition
      Error in `as_timestamp()`:
      ! Invalid argument: options[["end_steady_time"]] must be a time stamp (`POSIXt` scalar or numeric scalar), but it is a string.

# as_output_file

    Code
      as_output_file(tmp3)
    Condition
      Error in `as_output_file()`:
      ! Directory of OpenTelemetry output file '<tempdir>/<tempfile>/output' does not exist or it is not writeable.

---

    Code
      as_output_file(tmp3)
    Condition
      Error in `as_output_file()`:
      ! Cannot write to OpenTelemetry output file '<tempdir>/<tempfile>/output'.

