# otel_meter_provider_memory_get_metrics error

    Code
      ccall(otel_meter_provider_memory_get_metrics, 1:10)
    Condition
      Warning:
      OpenTelemetry: invalid meter provider pointer.
    Output
      NULL

---

    Code
      ccall(otel_meter_provider_memory_get_metrics, x)
    Condition
      Error:
      ! Opentelemetry meter provider cleaned up already, internal error.

# otel_get_meter error

    Code
      ccall(otel_get_meter, 1L, "foo", NULL, NULL, NULL)
    Condition
      Error:
      ! OpenTelemetry: invalid meter provider pointer.
    Code
      ccall(otel_get_meter, x, "foo", NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry meter provider cleaned up already, internal error.

# otel_meter_provider_flush error

    Code
      ccall(otel_meter_provider_flush, 1L, NULL)
    Condition
      Warning:
      OpenTelemetry: invalid meter provider pointer.
    Output
      NULL
    Code
      ccall(otel_meter_provider_flush, x, NULL)
    Condition
      Error:
      ! Opentelemetry meter provider cleaned up already, internal error.

# otel_meter_provider_shutdown error

    Code
      ccall(otel_meter_provider_shutdown, 1L, NULL)
    Condition
      Warning:
      OpenTelemetry: invalid meter provider pointer.
    Output
      NULL
    Code
      ccall(otel_meter_provider_shutdown, x, NULL)
    Condition
      Error:
      ! Opentelemetry meter provider cleaned up already, internal error.

# otel_create_counter error

    Code
      ccall(otel_create_counter, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid meter pointer
    Code
      ccall(otel_create_counter, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry meter cleaned up already, internal error.

# otel_counter_add error

    Code
      ccall(otel_counter_add, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid counter pointer
    Code
      ccall(otel_counter_add, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry counter cleaned up already, internal error.

# otel_create_up_down_counter error

    Code
      ccall(otel_create_up_down_counter, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid meter pointer
    Code
      ccall(otel_create_up_down_counter, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry meter cleaned up already, internal error.

# otel_up_down_counter_add error

    Code
      ccall(otel_up_down_counter_add, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid counter pointer
    Code
      ccall(otel_up_down_counter_add, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry up-down counter cleaned up already, internal error.

# otel_create_histogram error

    Code
      ccall(otel_create_histogram, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid meter pointer
    Code
      ccall(otel_create_histogram, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry meter cleaned up already, internal error.

# otel_histogram_record error

    Code
      ccall(otel_histogram_record, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid counter pointer
    Code
      ccall(otel_histogram_record, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry histogram cleaned up already, internal error.

# otel_create_gauge error

    Code
      ccall(otel_create_gauge, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid meter pointer
    Code
      ccall(otel_create_gauge, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry meter cleaned up already, internal error.

# otel_gauge_record error

    Code
      ccall(otel_gauge_record, 1L, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry: invalid counter pointer
    Code
      ccall(otel_gauge_record, x, NULL, NULL, NULL)
    Condition
      Error:
      ! Opentelemetry gauge cleaned up already, internal error.

