# File Size Options

otel and otelsdk accept file size options in the following format:

- As a positive numeric scalar, interpreted as number of bytes.

- A string scalar with a positive number and a unit suffix. Possible
  units: B, KB, KiB, MB, MiB, GB, GiB, TB, TiB, PB, PiB. Units are case
  insensitive.

## Value

Not applicable.

## Examples

``` r
# Maximum output file size is 128 MiB:
# OTEL_EXPORTER_OTLP_FILE_FILE_SIZE=128MiB
```
