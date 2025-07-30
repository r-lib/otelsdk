#! /bin/sh

mfns <- c(
  "man/environmentvariables.Rd"
)

for (fn in mfns) {
  lns <- readLines(fn)
  flt <- grep("^\\\\alias[{]OTEL_", lns, value = TRUE, invert = TRUE)
  writeLines(flt, fn)
}
