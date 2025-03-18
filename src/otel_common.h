#ifndef OTEL_COMMON_H
#define OTEL_COMMON_H

#ifdef __cplusplus
extern "C" {
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
void otel_scope_finally_(void *scope);
void otel_session_finally_(void *sess);

void *otel_create_tracer_provider_stdstream_(const char *stream);
void *otel_create_tracer_provider_http_(void);
void *otel_get_tracer_(void *tracer_provider, const char *name);
struct otel_scoped_span otel_start_span_(void *tracer, const char *name, void *parent);
void otel_span_end_(void *span, void *scope);

void *otel_start_session_(void);
void otel_activate_session_(void *id_);
void otel_deactivate_session_(void *id_);
void otel_finish_session_(void *id_);
void otel_finish_all_sessions_(void);

void otel_tracer_provider_http_default_options_(
  struct otel_tracer_provider_http_options_t *opts);

#ifdef __cplusplus
}
#endif

#endif
