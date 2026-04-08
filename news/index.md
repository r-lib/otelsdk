# Changelog

## otelsdk 0.2.4

CRAN release: 2026-04-08

- otel and otelsdk now support R 4.2.x on Windows.

## otelsdk 0.2.3

CRAN release: 2026-03-10

- otelsdk now compiles with older libprotobuf, e.g. on RHEL 8. It also
  handles it better when multiple versions of libprotobuf and protoc are
  available, by using `pkg-config` to find protobuf.

## otelsdk 0.2.2

CRAN release: 2025-10-07

- No user visible changes.

## otelsdk 0.2.1

CRAN release: 2025-09-23

- otelsdk now compiles on macOS if `cmake` was installed from the
  installer and is not on the `PATH`.

- Documentation update for the new Otel 1.49.0 specification. The new
  `OTEL_ENTITIES` environment variable is not supported yet.

## otelsdk 0.2.0

CRAN release: 2025-09-10

First release on CRAN.
