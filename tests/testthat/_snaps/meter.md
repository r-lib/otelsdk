# meter, histogram with invalid boundaries

    Code
      mtr$create_histogram("hst", boundaries = c(2, 1))
    Condition
      Error in `histogram_new()`:
      ! Invalid argument: `boundaries` must be strictly increasing.

