#include <string.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "otel_common.h"
#include "otel_common_r.h"
#include "errors.h"
#include "cleancall.h"

SEXP otel_fail(void);
SEXP otel_error_object(void);
SEXP otel_init_constants(SEXP env);

SEXP otel_create_tracer_provider_stdstream(SEXP stream);
SEXP otel_create_tracer_provider_http(void);
SEXP otel_create_tracer_provider_memory(SEXP buffer_size);
SEXP otel_tracer_provider_memory_get_spans(SEXP provider);
SEXP otel_tracer_provider_flush(SEXP provider);
SEXP otel_get_tracer(
  SEXP provider, SEXP name, SEXP version, SEXP schema_url,
  SEXP attributes);
SEXP otel_get_current_span_context(SEXP tracer);

SEXP otel_start_span(
  SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options,
  SEXP parent
);
SEXP otel_span_get_context(SEXP span);
SEXP otel_span_is_valid(SEXP span);
SEXP otel_span_is_recording(SEXP span);
SEXP otel_span_set_attribute(SEXP span, SEXP name, SEXP value);
SEXP otel_span_add_event(
  SEXP span, SEXP name, SEXP attributes, SEXP timestamp
);
// ABI v2
// SEXP otel_span_add_link(SEXP span, SEXP link);
SEXP otel_span_set_status(SEXP span, SEXP status_code, SEXP description);
SEXP otel_span_update_name(SEXP span, SEXP name);
SEXP otel_span_end(SEXP span, SEXP options, SEXP status_code);

SEXP otel_span_id_size(void);
SEXP otel_trace_id_size(void);
SEXP otel_span_context_is_valid(SEXP span_context);
SEXP otel_span_context_get_trace_flags(SEXP span_context);
SEXP otel_span_context_get_trace_id(SEXP span_context);
SEXP otel_span_context_get_span_id(SEXP span_context);
SEXP otel_span_context_is_remote(SEXP span_context);
SEXP otel_span_context_is_sampled(SEXP span_context);
SEXP otel_span_context_to_headers(SEXP span_context);
SEXP otel_extract_http_context(SEXP headers);

SEXP otel_start_session(void);
SEXP otel_activate_session(SEXP sess);
SEXP otel_deactivate_session(SEXP sess);
SEXP otel_finish_session(SEXP sess);
SEXP otel_finish_all_sessions(void);

SEXP otel_tracer_provider_http_options(void);

SEXP otel_create_logger_provider_stdstream(SEXP stream);
SEXP otel_create_logger_provider_http(void);
SEXP otel_get_logger(
  SEXP provider, SEXP name, SEXP minimum_severity, SEXP version,
  SEXP schema_url, SEXP attributes);
SEXP otel_logger_provider_flush(SEXP provider);

SEXP otel_get_minimum_log_severity(SEXP logger);
SEXP otel_set_minimum_log_severity(SEXP logger, SEXP mimimum_severity);
SEXP otel_logger_get_name(SEXP logger);
SEXP otel_emit_log_record(SEXP logger, SEXP log_record);
SEXP otel_logger_is_enabled(SEXP logger, SEXP severity, SEXP event_id);
SEXP otel_log(
  SEXP logger, SEXP format, SEXP severity, SEXP event_id, SEXP span_id,
  SEXP trace_id, SEXP trace_flags, SEXP timestamp, SEXP observed_timestamp,
  SEXP attributes);

SEXP otel_create_meter_provider_stdstream(
  SEXP stream, SEXP export_interval, SEXP export_timeout);
SEXP otel_create_meter_provider_http(
  SEXP export_interval, SEXP export_timeout);
SEXP otel_get_meter(SEXP provider, SEXP name, SEXP version,
  SEXP schema_url, SEXP attributes);
SEXP otel_meter_provider_flush(SEXP provider, SEXP timeout);
SEXP otel_meter_provider_shutdown(SEXP provider, SEXP timeout);

SEXP otel_create_counter(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_counter_add(
  SEXP counter, SEXP value, SEXP attributes, SEXP context);

SEXP otel_create_up_down_counter(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_up_down_counter_add(
  SEXP up_down_counter, SEXP value, SEXP attributes, SEXP context);

SEXP otel_create_histogram(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_histogram_record(
  SEXP histogram, SEXP value, SEXP attributes, SEXP unit);

SEXP otel_create_gauge(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_gauge_record(
  SEXP gauge, SEXP value, SEXP attributes, SEXP unit);

SEXP rf_get_list_element(SEXP list, const char *str);
SEXP glue_(SEXP x, SEXP f, SEXP open_arg, SEXP close_arg, SEXP cli_arg);
SEXP trim_(SEXP x);

#define CALLDEF(name, n) \
  { #name, (DL_FUNC)&name, n }

static const R_CallMethodDef callMethods[]  = {
  CLEANCALL_METHOD_RECORD,

  CALLDEF(otel_fail, 0),
  CALLDEF(otel_error_object, 0),
  CALLDEF(otel_init_constants, 1),

  CALLDEF(otel_create_tracer_provider_stdstream, 1),
  CALLDEF(otel_create_tracer_provider_http, 0),
  CALLDEF(otel_create_tracer_provider_memory, 1),
  CALLDEF(otel_tracer_provider_memory_get_spans, 1),
  CALLDEF(otel_tracer_provider_flush, 1),
  CALLDEF(otel_get_tracer, 5),
  CALLDEF(otel_get_current_span_context, 1),
  CALLDEF(otel_start_span, 5),
  CALLDEF(otel_span_get_context, 1),
  CALLDEF(otel_span_is_valid, 1),
  CALLDEF(otel_span_is_recording, 1),
  CALLDEF(otel_span_set_attribute, 3),
  CALLDEF(otel_span_add_event, 4),
  // ABI v2
  // CALLDEF(otel_span_add_link, 2),
  CALLDEF(otel_span_set_status, 3),
  CALLDEF(otel_span_update_name, 2),
  CALLDEF(otel_span_end, 3),

  CALLDEF(otel_span_id_size, 0),
  CALLDEF(otel_trace_id_size, 0),
  CALLDEF(otel_span_context_is_valid, 1),
  CALLDEF(otel_span_context_get_trace_flags, 1),
  CALLDEF(otel_span_context_get_trace_id, 1),
  CALLDEF(otel_span_context_get_span_id, 1),
  CALLDEF(otel_span_context_is_remote, 1),
  CALLDEF(otel_span_context_is_sampled, 1),
  CALLDEF(otel_span_context_to_headers, 1),
  CALLDEF(otel_extract_http_context, 1),

  CALLDEF(otel_start_session, 0),
  CALLDEF(otel_activate_session, 1),
  CALLDEF(otel_deactivate_session, 1),
  CALLDEF(otel_finish_session, 1),
  CALLDEF(otel_finish_all_sessions, 0),
  CALLDEF(otel_tracer_provider_http_options, 0),

  CALLDEF(otel_create_logger_provider_stdstream, 1),
  CALLDEF(otel_create_logger_provider_http, 0),
  CALLDEF(otel_get_minimum_log_severity, 1),
  CALLDEF(otel_set_minimum_log_severity, 2),
  CALLDEF(otel_logger_provider_flush, 1),
  CALLDEF(otel_get_logger, 6),
  CALLDEF(otel_logger_get_name, 1),
  CALLDEF(otel_emit_log_record, 2),
  CALLDEF(otel_logger_is_enabled, 3),
  CALLDEF(otel_log, 10),

  CALLDEF(otel_create_meter_provider_stdstream, 3),
  CALLDEF(otel_create_meter_provider_http, 2),
  CALLDEF(otel_get_meter, 5),
  CALLDEF(otel_meter_provider_flush, 2),
  CALLDEF(otel_meter_provider_shutdown, 2),
  CALLDEF(otel_create_counter, 4),
  CALLDEF(otel_counter_add, 4),
  CALLDEF(otel_create_up_down_counter, 4),
  CALLDEF(otel_up_down_counter_add, 4),
  CALLDEF(otel_create_histogram, 4),
  CALLDEF(otel_histogram_record, 4),
  CALLDEF(otel_create_gauge, 4),
  CALLDEF(otel_gauge_record, 4),

  CALLDEF(glue_, 5),
  CALLDEF(trim_, 1),
  { NULL, NULL, 0 }
};

extern void otel_init_context_storage(void);

SEXP otel_fail(void) {
  Rf_error("from C");
  return R_NilValue;
}

void R_init_otelsdk(DllInfo *dll) {
  R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
  cleancall_init();
  otel_init_context_storage();
}

SEXP otel_span_kinds = NULL;
SEXP otel_span_status_codes = NULL;

SEXP otel_init_constants(SEXP env) {
  R_PreserveObject(env);
  otel_span_kinds = Rf_findVarInFrame(env, Rf_install("span_kinds"));
  otel_span_status_codes =
    Rf_findVarInFrame(env, Rf_install("span_status_codes"));
  return R_NilValue;
}

void otel_tracer_provider_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid tracer provider pointer."
    );
    return;
  }
  void *tracer_provider_ = R_ExternalPtrAddr(x);
  if (tracer_provider_) {
    otel_tracer_provider_finally_(tracer_provider_);
    R_ClearExternalPtr(x);
  }
}

void otel_tracer_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid tracer pointer.");
    return;
  }
  void *tracer_ = R_ExternalPtrAddr(x);
  if (tracer_) {
    otel_tracer_finally_(tracer_);
    R_ClearExternalPtr(x);
  }
}

void otel_span_context_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid span context pointer.");
    return;
  }
  void *span_context_ = R_ExternalPtrAddr(x);
  if (span_context_) {
    otel_span_context_finally_(span_context_);
    R_ClearExternalPtr(x);
  }
}

void otel_session_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid session pointer.");
    return;
  }
  void *sess_ = R_ExternalPtrAddr(x);
  if (sess_) {
    otel_session_finally_(sess_);
    R_ClearExternalPtr(x);
  }
}

SEXP otel_create_tracer_provider_stdstream(SEXP stream) {
  const char *cstream = CHAR(STRING_ELT(stream, 0));
  void *tracer_provider_ = otel_create_tracer_provider_stdstream_(cstream);
  SEXP xptr = R_MakeExternalPtr(tracer_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_tracer_provider_http(void) {
  void *tracer_provider_ = otel_create_tracer_provider_http_();
  SEXP xptr = R_MakeExternalPtr(tracer_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_tracer_provider_memory(SEXP buffer_size) {
  int cbuffer_size = INTEGER(buffer_size)[0];
  void *tracer_provider_ = otel_create_tracer_provider_memory_(cbuffer_size);
  SEXP xptr = R_MakeExternalPtr(tracer_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_tracer_provider_flush(SEXP provider) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid tracer provider pointer."
    );
    return R_NilValue;
  }
  void *tracer_provider_ = R_ExternalPtrAddr(provider);
  if (!tracer_provider_) {
    Rf_error(
      "Opentelemetry tracer provider cleaned up already, internal error."
    );
  }
  otel_tracer_provider_flush_(tracer_provider_);
  return R_NilValue;
}

SEXP otel_get_tracer(
    SEXP provider, SEXP name, SEXP version, SEXP schema_url,
    SEXP attributes) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid tracer provider pointer.");
  }
  void *tracer_provider_ = R_ExternalPtrAddr(provider);
  if (!tracer_provider_) {
    Rf_error(
      "Opentelemetry tracer provider cleaned up already, internal error."
    );
  }
  const char *name_ = CHAR(STRING_ELT(name, 0));
  const char *version_ =
    Rf_isNull(version) ? NULL : CHAR(STRING_ELT(version, 0));
  const char *schema_url_ =
    Rf_isNull(schema_url) ? NULL : CHAR(STRING_ELT(schema_url, 0));
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  void *tracer_ = otel_get_tracer_(
    tracer_provider_, name_, version_, schema_url_, &attributes_);
  SEXP xptr = R_MakeExternalPtr(tracer_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_get_current_span_context(SEXP tracer) {
  if (TYPEOF(tracer) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid tracer pointer.");
  }
  void *tracer_ = R_ExternalPtrAddr(tracer);
  if (!tracer_) {
    Rf_error("Opentelemetry tracer cleaned up already, internal error.");
  }

  void *span_context_ = otel_get_current_span_context_(tracer_);
  SEXP xptr = R_MakeExternalPtr(span_context_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_span_context_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_span_id_size(void) {
  int sz = otel_span_id_size_();
  return Rf_ScalarInteger(sz);
}

SEXP otel_trace_id_size(void) {
  int sz = otel_trace_id_size_();
  return Rf_ScalarInteger(sz);
}

SEXP otel_start_session(void) {
  void *sess_ = otel_start_session_();
  SEXP res = PROTECT(R_MakeExternalPtr(sess_, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(res, otel_session_finally, (Rboolean) 1);
  UNPROTECT(1);
  return res;
}

SEXP otel_activate_session(SEXP sess) {
  if (TYPEOF(sess) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid session pointer.");
  }
  void *sess_ = R_ExternalPtrAddr(sess);
  if (!sess_) {
    Rf_error(
      "OpenTelemetry error: invalid session id, session already ended?"
    );
  }
  otel_activate_session_(sess_);
  return R_NilValue;
}

SEXP otel_deactivate_session(SEXP sess) {
  if (TYPEOF(sess) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid session pointer.");
  }
  void *sess_ = R_ExternalPtrAddr(sess);
  if (sess_) {
    otel_deactivate_session_(sess_);
  }
  return R_NilValue;
}

SEXP otel_finish_session(SEXP sess) {
  if (TYPEOF(sess) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid session pointer.");
  }
  void *sess_ = R_ExternalPtrAddr(sess);
  if (sess_) {
    otel_finish_session_(sess_);
  }
  return R_NilValue;
}

SEXP otel_finish_all_sessions(void) {
  otel_finish_all_sessions_();
  return R_NilValue;
}

const char *otel_http_request_content_type_str[] = {
  "json",
  "binary"
};

SEXP otel_tracer_provider_http_options(void) {
  struct otel_tracer_provider_http_options_t opts = { 0 };
  if (otel_tracer_provider_http_default_options_(&opts)) {
    R_THROW_SYSTEM_ERROR("Failed to query OpenTelemetry HTTP options");
  }

  const char *nms[] = {
    "url",
    "content_type",
    "use_json_name",
    "console_debug",
    "timeout",
    "http_headers",
    "ssl_insecure_skip_verify",
    "ssl_ca_cert_path",
    "ssl_ca_cert_string",
    "ssl_client_key_path",
    "ssl_client_key_string",
    "ssl_client_cert_path",
    "ssl_client_cert_string",
    "ssl_min_tls",
    "ssl_max_tls",
    "ssl_cipher",
    "ssl_cipher_suite",
    "compression",
    "retry_policy_max_attempts",
    "retry_policy_initial_backoff",
    "retry_policy_max_backoff",
    "retry_policy_backoff_multiplier",
    ""
  };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, Rf_mkString(opts.url.s));
  SET_VECTOR_ELT(res, 1,
    Rf_mkString(otel_http_request_content_type_str[opts.content_type])
  );
  SET_VECTOR_ELT(res, 2, Rf_ScalarLogical(opts.use_json_name));
  SET_VECTOR_ELT(res, 3, Rf_ScalarLogical(opts.console_debug));
  SET_VECTOR_ELT(res, 4, Rf_ScalarReal(opts.timeout));
  SET_VECTOR_ELT(res, 5, c2r_otel_named_strings(&opts.http_headers));
  SET_VECTOR_ELT(res, 6, Rf_ScalarLogical(opts.ssl_insecure_skip_verify));
  SET_VECTOR_ELT(res, 7, c2r_otel_string(&opts.ssl_ca_cert_path));
  SET_VECTOR_ELT(res, 8, Rf_mkString(opts.ssl_ca_cert_string.s));
  SET_VECTOR_ELT(res, 9, Rf_mkString(opts.ssl_client_key_path.s));
  SET_VECTOR_ELT(res, 10, Rf_mkString(opts.ssl_client_key_string.s));
  SET_VECTOR_ELT(res, 11, Rf_mkString(opts.ssl_client_cert_path.s));
  SET_VECTOR_ELT(res, 12, Rf_mkString(opts.ssl_client_cert_string.s));
  SET_VECTOR_ELT(res, 13, Rf_mkString(opts.ssl_min_tls.s));
  SET_VECTOR_ELT(res, 14, Rf_mkString(opts.ssl_max_tls.s));
  SET_VECTOR_ELT(res, 15, Rf_mkString(opts.ssl_cipher.s));
  SET_VECTOR_ELT(res, 16, Rf_mkString(opts.ssl_cipher_suite.s));
  SET_VECTOR_ELT(res, 17, Rf_mkString(opts.compression.s));
  SET_VECTOR_ELT(res, 18, Rf_ScalarInteger(opts.retry_policy_max_attempts));
  SET_VECTOR_ELT(res, 19, Rf_ScalarReal(opts.retry_policy_initial_backoff));
  SET_VECTOR_ELT(res, 20, Rf_ScalarReal(opts.retry_policy_max_backoff));
  SET_VECTOR_ELT(res, 21, Rf_ScalarReal(opts.retry_policy_backoff_multiplier));

  UNPROTECT(1);
  return res;
}
