# glue errors

    Code
      glue("{ no brace")
    Condition
      Error:
      ! Expecting '}'
    Code
      glue("{ 'no quote ", .cli = TRUE)
    Condition
      Error:
      ! Unterminated quote (')
    Code
      glue("{ \"no dquote ", .cli = TRUE)
    Condition
      Error:
      ! Unterminated quote (")
    Code
      glue("{ `no backtick ", .cli = TRUE)
    Condition
      Error:
      ! Unterminated quote (`)

# trim

    Code
      trim("\nfoo")
    Output
      [1] "foo"

---

    Code
      trim("foo\n   bar")
    Output
      [1] "foo\nbar"
    Code
      trim("foo\n   bar\n  ")
    Output
      [1] "foo\n bar"

---

    Code
      trim("foo\n   bar\n  \nbaz")
    Output
      [1] "foo\n   bar\n  \nbaz"

---

    Code
      trim("\n       \ta\n       \tb\n      \t\n       \tc")
    Output
      [1] "a\nb\n      \t\nc"

