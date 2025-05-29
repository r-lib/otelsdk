#ifndef OTEL_R_COMMON_H
#define OTEL_R_COMMON_H

#include "otel_common.h"

extern SEXP otel_span_kinds;
extern SEXP otel_span_status_codes;

SEXP rf_get_list_element(const SEXP list, const char *str);
SEXP rf_otel_string_to_strsxp(struct otel_string *s);

void r2c_attribute(
  const char *name, SEXP value, struct otel_attribute *attr);
void r2c_attributes(SEXP r, struct otel_attributes *c);

SEXP c2r_otel_trace_flags(const struct otel_trace_flags_t *flags);

SEXP c2r_otel_instrumentation_scope(
  const struct otel_instrumentation_scope_t *is);

#endif
