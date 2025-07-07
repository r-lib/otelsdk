#ifndef OTEL_R_COMMON_H
#define OTEL_R_COMMON_H

#include "otel_common.h"

extern SEXP otel_span_kinds;
extern SEXP otel_span_status_codes;

SEXP rf_get_list_element(SEXP list, const char *str);

void otel_span_context_finally(SEXP x);

void r2c_otel_string(SEXP s, struct otel_string *cs);

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
SEXP c2r_otel_metric_data(struct otel_metric_data *d);
SEXP c2r_otel_scope_metrics(struct otel_scope_metrics *sm);
SEXP c2r_otel_resource_metrics(struct otel_resource_metrics *rm);
SEXP c2r_otel_metrics_data(const struct otel_metrics_data *data);

SEXP c2r_otel_collector_log_record(const struct otel_collector_log_record *lr);
SEXP c2r_otel_collector_scope_log(const struct otel_collector_scope_log *sl);
SEXP c2r_otel_collector_resource_log(
  const struct otel_collector_resource_log *rl);
SEXP c2r_otel_collector_resource_logs(
  const struct otel_collector_resource_logs *rl);

SEXP c2r_otel_collector_scope_metric(
  const struct otel_collector_scope_metric *sl);
SEXP c2r_otel_collector_resource_metric(
  const struct otel_collector_resource_metric *rm);
SEXP c2r_otel_collector_resource_metrics(
  const struct otel_collector_resource_metrics *rl);

void r2c_otel_file_exporter_options(
  SEXP options, struct otel_file_exporter_options *coptions);
SEXP c2r_otel_file_exporter_options(
  const struct otel_file_exporter_options *o);

void r2c_otel_http_exporter_options(
  SEXP options, struct otel_http_exporter_options *coptions);

#endif
