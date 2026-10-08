# otelsdk (development version)

* Span and span context methods do not throw errors any more. On failure
  they emit a message of class `otel_error_message` and return a default
  value, usually the span itself. Set `OTEL_ENV=dev` to get errors instead
  (r-lib/otel#36).

* The `end_steady_time` option of the `end()` method of spans is now
  correctly used for the end time of the span.

* Documentation update for the new Otel 1.61.0 specification.

# otelsdk 0.2.4

* otel and otelsdk now support R 4.2.x on Windows.

# otelsdk 0.2.3

* otelsdk now compiles with older libprotobuf, e.g. on RHEL 8. It also
  handles it better when multiple versions of libprotobuf and protoc
  are available, by using `pkg-config` to find protobuf.

# otelsdk 0.2.2

* No user visible changes.

# otelsdk 0.2.1

* otelsdk now compiles on macOS if `cmake` was installed from the installer
  and is not on the `PATH`.

* Documentation update for the new Otel 1.49.0 specification.
  The new `OTEL_ENTITIES` environment variable is not supported yet.

# otelsdk 0.2.0

First release on CRAN.
