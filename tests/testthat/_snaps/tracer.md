# otel_tracer_provider_flush

    Code
      ccall(otel_tracer_provider_flush, 1L)
    Condition
      Warning:
      OpenTelemetry: invalid tracer provider pointer.
    Output
      NULL
    Code
      ccall(otel_tracer_provider_flush, x)
    Condition
      Error:
      ! Opentelemetry tracer provider cleaned up already, internal error.

# otel_tracer_provider_shutdown

    Code
      ccall(otel_tracer_provider_shutdown, 1L)
    Condition
      Warning:
      OpenTelemetry: invalid tracer provider pointer.
    Output
      NULL
    Code
      ccall(otel_tracer_provider_shutdown, x)
    Condition
      Error:
      ! Opentelemetry tracer provider cleaned up already, internal error.

