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

# otel_logger_provider_flush

    Code
      ccall(otel_logger_provider_flush, 1L)
    Condition
      Warning:
      OpenTelemetry: invalid logger provider pointer.
    Output
      NULL
    Code
      ccall(otel_logger_provider_flush, x)
    Condition
      Error:
      ! Opentelemetry logger provider cleaned up already, internal error.

# otel_get_logger

    Code
      ccall(otel_get_logger, 1L, "foo", 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! OpenTelemetry: invalid logger provider pointer.
    Code
      ccall(otel_get_logger, x, "foo", 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry logger provider cleaned up already, internal error.

# otel_get_minimum_log_severity

    Code
      ccall(otel_get_minimum_log_severity, 1L)
    Condition
      Error:
      ! Opentelemetry: invalid logger pointer
    Code
      ccall(otel_get_minimum_log_severity, x)
    Condition
      Error:
      ! Opentelemetry logger cleaned up already, internal error.

# otel_set_minimum_log_severity

    Code
      ccall(otel_set_minimum_log_severity, 1L, 1L)
    Condition
      Error:
      ! Opentelemetry: invalid logger pointer
    Code
      ccall(otel_set_minimum_log_severity, x, 1L)
    Condition
      Error:
      ! Opentelemetry logger cleaned up already, internal error.

# otel_logger_get_name

    Code
      ccall(otel_logger_get_name, 1L)
    Condition
      Error:
      ! Opentelemetry: invalid logger pointer
    Code
      ccall(otel_logger_get_name, x)
    Condition
      Error:
      ! Opentelemetry logger cleaned up already, internal error.

# otel_logger_is_enabled

    Code
      ccall(otel_logger_is_enabled, 1L, 1L, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid logger pointer
    Code
      ccall(otel_logger_is_enabled, x, 1L, NULL)
    Condition
      Error:
      ! Opentelemetry logger cleaned up already, internal error.

# otel_log

    Code
      ccall(otel_log, 1L, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid logger pointer
    Code
      ccall(otel_log, x, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry logger cleaned up already, internal error.

