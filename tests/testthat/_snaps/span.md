# format_exception

    Code
      format_exception(base_error())
    Output
      $exception.message
      [1] "<simpleError in doTryCatch(return(expr), name, parentenv, handler): boo!>"

      $exception.stacktrace
      [1] "doTryCatch(return(expr), name, parentenv, handler)"

      $exception.type
      [1] "simpleError" "error"       "condition"


---

    Code
      format_exception(cli_error())
    Output
      $exception.message
       [1] "<error/rlang_error>"
       [2] "Error:"
       [3] "! Something went wrong."
       [4] "x You did not do the right thing."
       [5] "i You did another thing instead."
       [6] "---"
       [7] "Backtrace:"
       [8] "    x"
       [9] " 1. +-base::tryCatch(...)"
      [10] " 2. | \\-base (local) tryCatchList(expr, classes, parentenv, handlers)"
      [11] " 3. |   \\-base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])"
      [12] " 4. |     \\-base (local) doTryCatch(return(expr), name, parentenv, handler)"
      [13] " 5. \\-cli::cli_abort(...)"
      [14] " 6.   \\-rlang::abort(...)"

      $exception.stacktrace
      [1] "    x"
      [2] " 1. +-base::tryCatch(...)"
      [3] " 2. | \\-base (local) tryCatchList(expr, classes, parentenv, handlers)"
      [4] " 3. |   \\-base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])"
      [5] " 4. |     \\-base (local) doTryCatch(return(expr), name, parentenv, handler)"
      [6] " 5. \\-cli::cli_abort(...)"
      [7] " 6.   \\-rlang::abort(...)"

      $exception.type
      [1] "rlang_error" "error"       "condition"


---

    Code
      format_exception(processx_error())
    Output
      $exception.message
      [1] "<system_command_status_error/rlib_error_3_0/rlib_error/error>"
      [2] "Error in `processx::run(\"false\")`:"
      [3] "! System command 'false' failed"
      [4] "---"
      [5] "Exit status: 1"
      [6] "Stderr: <empty>"

      $exception.stacktrace
      [1] "processx::run(\"false\")"

      $exception.type
      [1] "system_command_status_error" "system_command_error"
      [3] "rlib_error_3_0"              "rlib_error"
      [5] "error"                       "condition"


---

    Code
      format_exception(callr_error())
    Output
      $exception.message
      [1] "<callr_error/rlib_error_3_0/rlib_error/error>"
      [2] "Error: "
      [3] "! in callr subprocess."
      [4] "Caused by error in `1 + \"\"`:"
      [5] "! non-numeric argument to binary operator"
      [6] "---"
      [7] "Subprocess backtrace:"
      [8] "1. base::.handleSimpleError(function (e) ..."
      [9] "2. global h(simpleError(msg, call))"

      $exception.stacktrace
      [1] "<stacktrace missing>"

      $exception.type
      [1] "callr_status_error" "callr_error"        "rlib_error_3_0"
      [4] "rlib_error"         "error"              "condition"


# span_context

    Code
      ctx$get_trace_flags()
    Output
      $is_sampled
      [1] TRUE

      $is_remote
      [1] FALSE
