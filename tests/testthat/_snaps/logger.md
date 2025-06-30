# get_default_log_severity

    Code
      get_default_log_severity()
    Condition
      Error in `get_default_log_severity()`:
      ! Invalid OpenTelemetry log level from the OTEL_LOG_LEVEL environment variable. Must be one of trace, trace2, trace3, trace4, debug, debug2, debug3, debug4, info, info2, info3, info4, warn, warn2, warn3, warn4, error, error2, error3, error4, fatal, fatal2, fatal3, fatal4, but it is '25'.

---

    Code
      get_default_log_severity()
    Condition
      Error in `get_default_log_severity()`:
      ! Invalid OpenTelemetry log level from the OTEL_LOG_LEVEL environment variable. Must be one of trace, trace2, trace3, trace4, debug, debug2, debug3, debug4, info, info2, info3, info4, warn, warn2, warn3, warn4, error, error2, error3, error4, fatal, fatal2, fatal3, fatal4, but it is 'whatup'.

# log_severity_levels_spec

    Code
      log_severity_levels_spec()
    Output
              invalid           trace          trace2          trace3          trace4 
                    0               1               2               3               4 
                debug          debug2          debug3          debug4            info 
                    5               6               7               8               9 
                info2           info3           info4            warn           warn2 
                   10              11              12              13              14 
                warn3           warn4           error          error2          error3 
                   15              16              17              18              19 
               error4           fatal          fatal2          fatal3          fatal4 
                   20              21              22              23              24 
      maximumseverity 
                  255 

