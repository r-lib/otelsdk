#ifndef OTEL_COMMON_H
#define OTEL_COMMON_H

#ifdef __cplusplus
#include <cstdint>
#include <cstddef>
extern "C" {
#else
#include "stdint.h"
#include "stddef.h"
#endif

enum otel_http_request_content_type {
  k_json,
  k_binary
};

struct otel_string {
  char *s;
  size_t size;
};

void otel_string_free(struct otel_string *s);

struct otel_strings {
  struct otel_string *a;
  size_t count;
};

void otel_strings_free(struct otel_strings *s);

enum otel_attribute_type {
  k_string,
  k_boolean,
  k_double,
  k_int64,
  k_string_array,
  k_boolean_array,
  k_double_array,
  k_int64_array
};

// if storage == NULL, then it does not own the strings
struct otel_string_array {
  char **a;
  char *storage;
  size_t count;
};

void otel_string_array_free(struct otel_string_array *a);

struct otel_boolean_array {
  int *a;
  size_t count;
};

void otel_boolean_array_free(struct otel_boolean_array *a);

struct otel_double_array {
  double *a;
  size_t count;
};

void otel_double_array_free(struct otel_double_array *a);

struct otel_int64_array {
  int64_t *a;
  size_t count;
};

void otel_int64_array_free(struct otel_int64_array *a);

struct otel_attribute {
  enum otel_attribute_type type;
  const char *name;
  union {
    struct otel_string string;
    int boolean;
    double dbl;
    int64_t int64;
    struct otel_string_array string_array;
    struct otel_boolean_array boolean_array;
    struct otel_double_array dbl_array;
    struct otel_int64_array int64_array;
  } val;
};

void otel_attribute_free(struct otel_attribute *attr);

struct otel_attributes {
  struct otel_attribute *a;
  size_t count;
};

void otel_attributes_free(struct otel_attributes *attrs);

struct otel_link {
  void *span;
  struct otel_attributes attr;
};

struct otel_links {
  struct otel_link *a;
  size_t count;
};

struct otel_tracer_provider_http_options {
  struct otel_string url;
  enum otel_http_request_content_type content_type;
  int use_json_name;
  int console_debug;
  double timeout;
  struct otel_strings http_headers;
  int ssl_insecure_skip_verify;
  struct otel_string ssl_ca_cert_path;
  struct otel_string ssl_ca_cert_string;
  struct otel_string ssl_client_key_path;
  struct otel_string ssl_client_key_string;
  struct otel_string ssl_client_cert_path;
  struct otel_string ssl_client_cert_string;
  struct otel_string ssl_min_tls;
  struct otel_string ssl_max_tls;
  struct otel_string ssl_cipher;
  struct otel_string ssl_cipher_suite;
  struct otel_string compression;
  int retry_policy_max_attempts;
  double retry_policy_initial_backoff;
  double retry_policy_max_backoff;
  double retry_policy_backoff_multiplier;
};

struct otel_trace_flags {
  int is_sampled;
  int is_random;
};

struct otel_instrumentation_scope {
  struct otel_string name;
  struct otel_string version;
  struct otel_string schema_url;
  struct otel_attributes attributes;
};

void otel_instrumentation_scope_free(
  struct otel_instrumentation_scope *is);

struct otel_event {
  struct otel_string name;
  double timestamp;
  struct otel_attributes attributes;
};

struct otel_events {
  struct otel_event *a;
  size_t count;
};

void otel_event_free(struct otel_event *event);
void otel_events_free(struct otel_events *events);

struct otel_span_link {
  struct otel_string trace_id;
  struct otel_string span_id;
  struct otel_attributes attributes;
};

struct otel_span_links {
  struct otel_span_link *a;
  size_t count;
};

void otel_span_link_free(struct otel_span_link *link);
void otel_span_links_free(struct otel_span_links *links);

struct otel_span_data1 {
  struct otel_string trace_id;
  struct otel_string span_id;
  // SpanContext does not seem useful?
  struct otel_string parent;
  struct otel_string name;
  struct otel_trace_flags flags;
  int kind;
  int status;
  struct otel_string schema_url;
  struct otel_string description;
  struct otel_attributes resource_attributes;
  struct otel_instrumentation_scope instrumentation_scope;
  double start_time;
  double duration;
  struct otel_attributes attributes;
  struct otel_events events;
  struct otel_span_links links;
};

struct otel_span_data {
  struct otel_span_data1 *a;
  size_t count;
};

void otel_span_data_free(struct otel_span_data *cdata);

enum otel_value_type {
  k_value_int64,
  k_value_double
};

extern const char *otel_value_type_names[];

union otel_value {
  int64_t int64;
  double dbl;
};

struct otel_sum_point_data {
  enum otel_value_type value_type;
  union otel_value value;
  int is_monotonic;
};

void otel_sum_point_data_free(struct otel_sum_point_data *d);

struct otel_histogram_point_data {
  struct otel_double_array boundaries;
  enum otel_value_type value_type;
  union otel_value sum;
  union otel_value min;
  union otel_value max;
  struct otel_double_array counts;
  int64_t count;
  int record_min_max;
};

void otel_histogram_point_data_free(struct otel_histogram_point_data *d);

struct otel_last_value_point_data {
  enum otel_value_type value_type;
  union otel_value value;
  int is_lastvalue_valid;
  double sample_ts;
};

void otel_last_value_point_data_free(struct otel_last_value_point_data *d);

struct otel_drop_point_data {
  // do data in this one, but a C struct needs something to be
  // ABI compatible with C++
  int dummy;
};

void otel_drop_point_data_free(struct otel_drop_point_data *d);

enum otel_point_type {
  k_sum_point_data,
  k_histogram_point_data,
  k_last_value_point_data,
  k_drop_point_data
};

extern const char *otel_point_type_names[];

struct otel_point_data_attributes {
  struct otel_attributes attributes;
  enum otel_point_type point_type;
  union {
    struct otel_sum_point_data sum_point_data;
    struct otel_histogram_point_data histogram_point_data;
    struct otel_last_value_point_data last_value_point_data;
    struct otel_drop_point_data drop_point_data;
  } value;
};

void otel_point_data_attributes_free(struct otel_point_data_attributes *pda);

enum otel_instrument_type {
  k_counter,
  k_histogram,
  k_updown_counter,
  k_observable_counter,
  k_observable_gauge,
  k_observable_updown_counter,
  k_gauge
};

extern const char *otel_instrument_type_names[];

enum otel_instrument_value_type {
  k_value_type_int,
  k_value_type_long,
  k_value_type_float,
  k_value_type_double
};

union otel_instrument_value {
  int intval;
  long longval;
  float floatval;
  double doubleval;
};

extern const char *otel_instrument_value_type_names[];

enum otel_aggregation_temporality {
  k_unspecified,
  k_delta,
  k_cumulative
};

extern const char *otel_aggregation_temporality_names[];

struct otel_metric_data {
  struct otel_point_data_attributes *point_data_attr;
  size_t count;
  struct otel_string instrument_name;
  struct otel_string instrument_description;
  struct otel_string instrument_unit;
  enum otel_instrument_type instrument_type;
  enum otel_instrument_value_type instrument_value_type;
  enum otel_aggregation_temporality aggregation_temporality;
  double start_time;
  double end_time;
};

void otel_metric_data_free(struct otel_metric_data *d);

struct otel_scope_metrics {
  struct otel_metric_data *metric_data;
  size_t count;
  struct otel_instrumentation_scope instrumentation_scope;
};

void otel_scope_metrics_free(struct otel_scope_metrics *sm);

struct otel_resource_metrics {
  struct otel_scope_metrics *scope_metric_data;
  size_t count;
  struct otel_attributes attributes;
};

void otel_resource_metrics_free(struct otel_resource_metrics *rm);

struct otel_metrics_data {
  struct otel_resource_metrics *a;
  size_t count;
};

void otel_metrics_data_free(struct otel_metrics_data *cdata);

extern const char *otel_http_request_content_type_str[];

void otel_tracer_provider_finally_(void *tracer_provider);
void otel_tracer_finally_(void *tracer);
void otel_span_finally_(void *span);
void otel_span_context_finally_(void *span_context_);
void otel_scope_finally_(void *scope);
void otel_logger_finally_(void *logger);
void otel_meter_finally_(void *meter);
void otel_counter_finally_(void *counter);
void otel_up_down_counter_finally_(void *up_down_counter);
void otel_histogram_finally_(void *histogram);
void otel_gauge_finally_(void *gauge);

void *otel_create_tracer_provider_stdstream_(
  const char *stream, struct otel_attributes *resource_attributes);
void *otel_create_tracer_provider_http_(
  struct otel_attributes *resource_attributes);
void *otel_create_tracer_provider_memory_(
  int buffer_size, struct otel_attributes *resource_attributes);
void *otel_create_tracer_provider_file_(
  const char *file_pattern, const char *alias_pattern, double *flush_interval,
  int *flush_count, double *file_size, int *rotate_size,
  struct otel_attributes *resource_attributes);
int otel_tracer_provider_memory_get_spans_(
  void *tracer_provider, struct otel_span_data *cdata);
int otel_tracer_provider_flush_(void *tracer_provider);
void *otel_get_tracer_(
    void *tracer_provider_, const char *name, const char *version,
    const char *schema_url, struct otel_attributes *attributes);
void *otel_get_active_span_context_(void *tracer);

void *otel_start_span_(
  void *tracer,
  const char *name,
  struct otel_attributes *attr,
  struct otel_links *links,
  double *start_system_time,
  double *start_steady_time,
  void *parent,
  int is_root_span,
  int span_kind
);
void *otel_span_get_context_(void *span);
int otel_span_is_valid_(void *span);
int otel_span_is_recording_(void *span);
void otel_span_set_attribute_(void *span, struct otel_attribute *attr);
void otel_span_add_event_(
  void *span,
  const char *name,
  struct otel_attributes *attr,
  void *timestamp
);
void otel_span_set_status_(
  void *span_,
  int status_code_,
  char *description_
);
void otel_span_update_name_(void *span_, const char *name_);
void otel_span_end_(void *span, double *end_steady_time);

void *otel_scope_start_(void *span);
void otel_scope_end_(void *scope);

int otel_span_context_is_valid_(void* span_context);
char otel_span_context_get_trace_flags_(void* span_context);
int otel_trace_id_size_(void);
void otel_span_context_get_trace_id_(void* span_context, char *buf);
int otel_span_id_size_(void);
void otel_span_context_get_span_id_(void* span_context, char *buf);
int otel_span_context_is_remote_(void* span_context);
int otel_span_context_is_sampled_(void* span_context);
void otel_span_context_to_headers_(
  void *span_context, struct otel_string *traceparent,
  struct otel_string *tracestate);
void *otel_extract_http_context_(
  const char *traceparent, const char *tracestate);

int otel_tracer_provider_http_default_options_(
  struct otel_tracer_provider_http_options *opts);

void otel_logger_provider_finally_(void *logger_provider);
void *otel_create_logger_provider_stdstream_(const char *stream);
void *otel_create_logger_provider_http_(void);
void otel_logger_provider_flush_(void *tracer_provider);
int otel_get_minimum_log_severity_(void *logger);
void otel_set_minimum_log_severity_(void *logger, int minimum_severity);
void *otel_get_logger_(
  void *logger_provider, const char *name, int minimum_severity,
  const char *version, const char *schema_url,
  struct otel_attributes *attributes);
int otel_logger_get_name_(void *logger, struct otel_string *name);
int otel_logger_is_enabled_(void *logger_, int severity_);
void otel_log_(
  void *logger_, const char *format_, int severity_, const char *span_id_,
  const char *trace_id_, void *timestamp, void *observed_timestamp,
  struct otel_attributes *attr);

void otel_meter_provider_finally_(void *logger_provider);
void *otel_create_meter_provider_stdstream_(
  const char *stream, int export_interval, int export_timeout);
void *otel_create_meter_provider_http_(
  int export_interval, int export_timeout);
void *otel_create_meter_provider_memory_(
    int export_interval, int export_timeout, int cbuffer_size,
    int ctemporality);
int otel_meter_provider_memory_get_metrics_(
  void *meter_provider_, struct otel_metrics_data *data);
void otel_meter_provider_flush_(void *tracer_provider, int timeout);
void otel_meter_provider_shutdown_(void *tracer_provider, int timeout);
void *otel_get_meter_(
  void *meter_provider, const char *name, const char *version,
  const char *schema_url, struct otel_attributes *attributes);

void *otel_create_counter_(
  void *meter_, const char *name, const char *description,
  const char *unit);
void otel_counter_add_(
  void *counter_, double cvalue, struct otel_attributes *attributes_);

void *otel_create_up_down_counter_(
  void *meter_, const char *name, const char *description,
  const char *unit);
void otel_up_down_counter_add_(
  void *up_down_counter_, double cvalue, struct
  otel_attributes *attributes_);

void *otel_create_histogram_(
  void *meter_, const char *name, const char *description, const char *unit);
void otel_histogram_record_(
  void *histogram_, double cvalue, struct otel_attributes *attributes_);

void *otel_create_gauge_(
  void *meter_, const char *name, const char *description, const char *unit);
void otel_gauge_record_(
  void *gauge_, double cvalue, struct otel_attributes *attributes_);

#ifdef __cplusplus
}
#endif

#endif
