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
      [1] "foo"
    Code
      as_choice("foo", c(default = "foo", "bar"))
    Output
      [1] "foo"
    Code
      as_choice("bar", c(default = "foo", "bar"))
    Output
      [1] "bar"

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

