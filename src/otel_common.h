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

struct otel_http_header {
  struct otel_string name;
  struct otel_string value;
};

void otel_http_header_free(struct otel_http_header *h);

struct otel_http_headers {
  struct otel_http_header *a;
  size_t count;
};

void otel_http_headers_free(struct otel_http_headers *h);

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

struct otel_file_exporter_options {
  int has_file_pattern;
  struct otel_string file_pattern;
  int has_alias_pattern;
  struct otel_string alias_pattern;
  int has_flush_interval;
  double flush_interval;
  int has_flush_count;
  int flush_count;
  int has_file_size;
  double file_size;
  int has_rotate_size;
  int rotate_size;
};

void otel_file_exporter_options_free(struct otel_file_exporter_options *o);

// TODO: use otel_exporter_http_options for this as well
struct otel_provider_http_options {
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
  int aggregation_temporality;
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

struct otel_collector_log_record {
  struct otel_attributes attr;
  struct otel_string severity_text;
  struct otel_string event_name;
  struct otel_string trace_id;
  struct otel_string span_id;
  double time_stamp;
  double observed_time_stamp;
  int has_body;
  struct otel_string body;
  int dropped_attributes_count;
};

void otel_collector_log_record_free(struct otel_collector_log_record *lr);

struct otel_collector_scope_log {
  struct otel_string schema_url;
  int has_scope;
  // instrumentationscope
  struct otel_collector_log_record *log_records;
  size_t count;
};

void otel_collector_scope_log_free(struct otel_collector_scope_log *sl);

struct otel_collector_resource_log {
  struct otel_string schema_url;
  // TODO: resource
  struct otel_collector_scope_log *scope_logs;
  size_t count;
};

void otel_collector_resource_log_free(struct otel_collector_resource_log *rl);

struct otel_collector_resource_logs {
  struct otel_collector_resource_log *resource_logs;
  size_t count;
};

void otel_collector_resource_logs_free(struct otel_collector_resource_logs *rls);

// ---

struct otel_collector_metric {
  // TODO: metadata
  struct otel_string name;
  struct otel_string description;
  struct otel_string unit;
  // TODO: gauge field
  // TODO: sum field
  // TODO: histogram field
  // TODO: exponential histogram field
  // TODO: summary field
};

void otel_collector_metric_free(struct otel_collector_metric *cm);

// ---

struct otel_collector_scope_metric {
  struct otel_string schema_url;
  int has_scope;
  struct otel_collector_metric *metrics;
  size_t count;
};

void otel_collector_scope_metric_free(struct otel_collector_scope_metric *sl);

// ---

struct otel_collector_resource_metric {
  struct otel_string schema_url;
  // TODO: resource
  struct otel_collector_scope_metric *scope_metrics;
  size_t count;
};

void otel_collector_resource_metric_free(
  struct otel_collector_resource_metric *rm);

// ---

struct otel_collector_resource_metrics {
  struct otel_collector_resource_metric *resource_metrics;
  size_t count;
};

void otel_collector_resource_metrics_free(
  struct otel_collector_resource_metrics *rm);

// ---

struct otel_http_exporter_options {
  struct {
    char url;
    char content_type;
    char json_bytes_mapping;
    char use_json_name;
    char console_debug;
    char timeout;
    char http_headers;
    char ssl_insecure_skip_verify;
    char ssl_ca_cert_path;
    char ssl_ca_cert_string;
    char ssl_client_key_path;
    char ssl_client_key_string;
    char ssl_client_cert_path;
    char ssl_client_cert_string;
    char ssl_min_tls;
    char ssl_max_tls;
    char ssl_cipher;
    char ssl_cipher_suite;
    char compression;
    char retry_policy_max_attempts;
    char retry_policy_initial_backoff;
    char retry_policy_max_backoff;
    char retry_policy_backoff_multiplier;
  } isset;
  struct otel_string url;
  int content_type;
  int json_bytes_mapping;
  int use_json_name;                          // bool
  int console_debug;                          // bool
  double timeout;
  struct otel_http_headers http_headers;
  int ssl_insecure_skip_verify;               // bool
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
  int compression;
  int retry_policy_max_attempts;
  double retry_policy_initial_backoff;
  double retry_policy_max_backoff;
  double retry_policy_backoff_multiplier;
};

void otel_http_exporter_options_free(struct otel_http_exporter_options *o);

// ---

struct otel_bsp_options {
  struct {
    char max_queue_size;
    char schedule_delay;
    char max_export_batch_size;
  } isset;
  double max_queue_size;
  double schedule_delay;
  double max_export_batch_size;
};

void otel_bsp_options_free(struct otel_bsp_options *o);

int otel_bsp_defaults_(struct otel_bsp_options *options);
int otel_blrp_defaults_(struct otel_bsp_options *options);

// ---

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
  struct otel_http_exporter_options *options,
  struct otel_attributes *resource_attributes,
  struct otel_bsp_options *bsp_options);
int otel_tracer_provider_http_default_options_(
  struct otel_provider_http_options *opts);
void *otel_create_tracer_provider_memory_(
  int buffer_size, struct otel_attributes *resource_attributes);
void *otel_create_tracer_provider_file_(
  const struct otel_file_exporter_options *options,
  struct otel_attributes *resource_attributes);
void otel_tracer_provider_file_options_defaults_(
  struct otel_file_exporter_options *options);
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

void otel_logger_provider_finally_(void *logger_provider);
void *otel_create_logger_provider_stdstream_(
  const char *stream, struct otel_attributes *resource_attributes);
void *otel_create_logger_provider_http_(
  struct otel_http_exporter_options *options,
  struct otel_attributes *resource_attributes,
  struct otel_bsp_options *blrp_options);
int otel_logger_provider_http_default_options_(
  struct otel_provider_http_options *opts);
void *otel_create_logger_provider_file_(
  struct otel_file_exporter_options *options);
void otel_logger_provider_file_options_defaults_(
  struct otel_file_exporter_options *options);
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
  struct otel_http_exporter_options *options,
  struct otel_attributes *resource_attributes,
  int export_interval, int export_timeout,
  int aggregation_temporality_);
int otel_meter_provider_http_default_options_(
  struct otel_provider_http_options *opts);
void *otel_create_meter_provider_file_(
  int export_interval, int export_timeout,
  struct otel_file_exporter_options *options);
void otel_meter_provider_file_options_defaults_(
  struct otel_file_exporter_options *options);
void *otel_create_meter_provider_memory_(
    int export_interval, int export_timeout, int cbuffer_size,
    int ctemporality, struct otel_attributes *resource_attributes);
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

int otel_decode_log_record_(
  const char *str_, size_t len, struct otel_collector_resource_logs *rl_);
int otel_decode_metrics_record_(
  const char *str_, size_t len, struct otel_collector_resource_metrics *rl_);
int otel_encode_response_(
    int signal, int result, const char *errmsg, int rejected,
    int error_code, struct otel_string *str);

#ifdef __cplusplus
}
#endif

#endif
