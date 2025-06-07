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

SEXP c2r_otel_double_array(const struct otel_double_array *a);

SEXP c2r_otel_trace_flags(const struct otel_trace_flags *flags);

SEXP c2r_otel_instrumentation_scope(
  const struct otel_instrumentation_scope *is);

SEXP c2r_otel_attributes(const struct otel_attributes *attrs);
SEXP c2r_otel_events(const struct otel_events *events);
SEXP c2r_otel_span_links(const struct otel_span_links *links);

SEXP c2r_otel_sum_point_data(struct otel_sum_point_data *d);
SEXP c2r_otel_histogram_point_data(struct otel_histogram_point_data *d);
SEXP c2r_otel_last_value_point_data(struct otel_last_value_point_data *d);
SEXP c2r_otel_drop_point_data(struct otel_drop_point_data *d);
SEXP c2r_otel_point_data_attributes(struct otel_point_data_attributes *pda);
SEXP c2r_otel_metric1_data(struct otel_metric1_data *d);
SEXP c2r_otel_scope_metrics(struct otel_scope_metrics *sm);
SEXP c2r_otel_resource_metrics(struct otel_resource_metrics *rm);
SEXP c2r_otel_metric_data(const struct otel_metric_data *data);

#endif
