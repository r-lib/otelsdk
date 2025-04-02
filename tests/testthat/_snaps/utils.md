# map_chr

    Code
      map_chr(1:3, sqrt)
    Condition
      Error in `vapply()`:
      ! values must be type 'character',
       but FUN(X[[1]]) result is type 'double'

# get_current_error

    Code
      get_current_error()
    Output
      $tried
      [1] TRUE
      
      $success
      [1] FALSE
      
      $object
      NULL
      
      $error
      [1] "Cannot find error message, this is possibly a bug in the otelsdk package. Make sure that you are using the latest version."
      

---

    Code
      err
    Output
      $tried
      [1] TRUE
      
      $success
      [1] FALSE
      
      $object
      NULL
      
      $error
      [1] "Cannot find error message, this is possibly a bug in the otelsdk package. Make sure that you are using the latest version."
      

