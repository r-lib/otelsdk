# add_span_processor argument checks

    Code
      add_span_processor(on_start = "foo")
    Condition
      Error in `add_span_processor()`:
      ! Invalid argument: `on_start` must be a function but it is a string.
    Code
      add_span_processor(id = 1L)
    Condition
      Error in `add_span_processor()`:
      ! Invalid argument: `id` must be a string scalar but it is an integer.
    Code
      add_span_processor(NULL, "myid")
    Condition
      Error in `add_span_processor()`:
      ! Invalid argument: unknown argument(s) in `...`. `id` must be named. Currently the only supported callback is `on_start`.
    Code
      add_span_processor(on_end = function(span, info) NULL)
    Condition
      Error in `add_span_processor()`:
      ! Invalid argument: unknown argument(s) in `...`. `id` must be named. Currently the only supported callback is `on_start`.
    Code
      remove_span_processor(NULL)
    Condition
      Error in `remove_span_processor()`:
      ! Invalid argument: `id` must be a string scalar but it is NULL.

# OTEL_R_SPAN_PROCESSORS errors

    Code
      load_span_processors_env()
    Message
      OpenTelemetry error: Invalid entry in `OTEL_R_SPAN_PROCESSORS`: 'bad'. It must have the form `pkg::name`.
      OpenTelemetry error: Cannot load span processor 'pkg::missing' from `OTEL_R_SPAN_PROCESSORS`: object 'missing' not found
      OpenTelemetry error: Invalid span processor in `OTEL_R_SPAN_PROCESSORS`: 'pkg::fun' must be a named list of callbacks, but it is a function.
      OpenTelemetry error: Invalid span processor in `OTEL_R_SPAN_PROCESSORS`: `on_start` of 'pkg::notfun' must be a function, but it is a string.

# OTEL_R_SPAN_PROCESSORS unknown callbacks are ignored

    Code
      spns <- record_span()
    Message
      OpenTelemetry: span processor 'pkg::newer' in `OTEL_R_SPAN_PROCESSORS` has unknown callback(s), these are ignored: 'on_end'. Supported callbacks: 'on_start'.

