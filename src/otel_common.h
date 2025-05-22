#ifndef OTEL_COMMON_H
#define OTEL_COMMON_H

#ifdef __cplusplus
#include <cstdint>
extern "C" {
#else
#include "stdint.h"
#endif

struct otel_scoped_span {
  void *span;
  void *scope;
};

enum otel_http_request_content_type {
  k_json,
  k_binary
};

struct otel_string {
  char *s;
  size_t size;
};

struct otel_strings {
  char *s;
  size_t count;
  size_t size;
};

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

struct otel_string_array {
  char **a;
  size_t count;
};

struct otel_boolean_array {
  int *a;
  size_t count;
};

struct otel_double_array {
  double *a;
  size_t count;
};

struct otel_int64_array {
  int64_t *a;
  size_t count;
};

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

struct otel_attributes {
  struct otel_attribute *a;
  size_t count;
};

struct otel_link {
  void *span;
  struct otel_attributes attr;
};

struct otel_links {
  struct otel_link *a;
  size_t count;
};

struct otel_tracer_provider_http_options_t {
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

extern const char *otel_http_request_content_type_str[];

void otel_tracer_provider_finally_(void *tracer_provider);
void otel_tracer_finally_(void *tracer);
void otel_span_finally_(void *span);
void otel_span_context_finally_(void *span_context_);
void otel_scope_finally_(void *scope);
void otel_session_finally_(void *sess);
void otel_logger_finally_(void *logger);
void otel_meter_finally_(void *meter);
void otel_counter_finally_(void *counter);
void otel_up_down_counter_finally_(void *up_down_counter);
void otel_histogram_finally_(void *histogram);
void otel_gauge_finally_(void *gauge);

void *otel_create_tracer_provider_stdstream_(const char *stream);
void *otel_create_tracer_provider_http_(void);
void otel_tracer_provider_flush_(void *tracer_provider);
void *otel_get_tracer_(
    void *tracer_provider_, const char *name, const char *version,
    const char *schema_url, struct otel_attributes *attributes);
void *otel_get_current_span_context_(void *tracer);

struct otel_scoped_span otel_start_span_(
  void *tracer,
  const char *name,
  struct otel_attributes *attr,
  struct otel_links *links,
  double *start_system_time,
  double *start_steady_time,
  void *parent,
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
void otel_span_end_(void *span, void *scope, double *end_steady_time);

int otel_span_context_is_valid_(void* span_context);
char otel_span_context_get_trace_flags_(void* span_context);
int otel_trace_id_size_(void);
void otel_span_context_get_trace_id_(void* span_context, char *buf);
int otel_span_id_size_(void);
void otel_span_context_get_span_id_(void* span_context, char *buf);
int otel_span_context_is_remote_(void* span_context);
int otel_span_context_is_sampled_(void* span_context);

void *otel_start_session_(void);
void otel_activate_session_(void *id_);
void otel_deactivate_session_(void *id_);
void otel_finish_session_(void *id_);
void otel_finish_all_sessions_(void);

void otel_tracer_provider_http_default_options_(
  struct otel_tracer_provider_http_options_t *opts);

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
void *otel_logger_get_name_(void *logger, struct otel_string *name);
int otel_logger_is_enabled_(void *logger_, int severity_);
void otel_log_(
  void *logger_, const char *format_, int severity_, void *timestamp,
  struct otel_attributes *attr);

void otel_meter_provider_finally_(void *logger_provider);
void *otel_create_meter_provider_stdstream_(
  const char *stream, int export_interval, int export_timeout);
void *otel_create_meter_provider_http_(
  int export_interval, int export_timeout);
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
