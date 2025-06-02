#ifndef OTEL_R_COMMON_H
#define OTEL_R_COMMON_H

#include "otel_common.h"

extern SEXP otel_span_kinds;
extern SEXP otel_span_status_codes;

void r2c_attribute(
  const char *name, SEXP value, struct otel_attribute *attr);
void r2c_attributes(SEXP r, struct otel_attributes *c);

SEXP c2r_otel_string(const struct otel_string *s);
SEXP c2r_otel_strings(const struct otel_strings *s);
SEXP c2r_otel_named_strings(const struct otel_strings *s);

SEXP c2r_otel_trace_flags(const struct otel_trace_flags_t *flags);

SEXP c2r_otel_instrumentation_scope(
  const struct otel_instrumentation_scope_t *is);

SEXP c2r_otel_attributes(const struct otel_attributes *attrs);

#endif
