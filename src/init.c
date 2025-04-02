#include <string.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "otel_common.h"

SEXP otel_fail(void);
SEXP otel_error_object(void);

SEXP otel_create_tracer_provider_stdstream(SEXP stream);
SEXP otel_create_tracer_provider_http(void);
SEXP otel_tracer_provider_flush(SEXP provider);
SEXP otel_get_tracer(SEXP provider, SEXP name);

SEXP otel_start_span(
  SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options,
  SEXP parent
);
// TODO: maybe we don't need to get the context explicitly
// SEXP otel_span_get_context(SEXP span);
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

SEXP otel_start_session(void);
SEXP otel_activate_session(SEXP sess);
SEXP otel_deactivate_session(SEXP sess);
SEXP otel_finish_session(SEXP sess);
SEXP otel_finish_all_sessions(void);

SEXP otel_tracer_provider_http_options(void);

SEXP rf_get_list_element(SEXP list, const char *str);
SEXP trim_(SEXP x);

#define CALLDEF(name, n) \
  { #name, (DL_FUNC)&name, n }

static const R_CallMethodDef callMethods[]  = {
  CALLDEF(otel_fail, 0),
  CALLDEF(otel_error_object, 0),

  CALLDEF(otel_create_tracer_provider_stdstream, 1),
  CALLDEF(otel_create_tracer_provider_http, 0),
  CALLDEF(otel_tracer_provider_flush, 1),
  CALLDEF(otel_get_tracer, 2),
  CALLDEF(otel_start_span, 5),
  // TODO: maybe we don't need to get the context explicitly
  // CALLDEF(otel_span_get_context, 1),
  CALLDEF(otel_span_is_recording, 1),
  CALLDEF(otel_span_set_attribute, 3),
  CALLDEF(otel_span_add_event, 4),
  // ABI v2
  // CALLDEF(otel_span_add_link, 2),
  CALLDEF(otel_span_set_status, 3),
  CALLDEF(otel_span_update_name, 2),
  CALLDEF(otel_span_end, 3),
  CALLDEF(otel_start_session, 0),
  CALLDEF(otel_activate_session, 1),
  CALLDEF(otel_deactivate_session, 1),
  CALLDEF(otel_finish_session, 1),
  CALLDEF(otel_finish_all_sessions, 0),
  CALLDEF(otel_tracer_provider_http_options, 0),

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
  otel_init_context_storage();
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

SEXP otel_get_tracer(SEXP provider, SEXP name) {
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
  void *tracer_ = otel_get_tracer_(tracer_provider_, name_);
  SEXP xptr = R_MakeExternalPtr(tracer_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_finally, (Rboolean) 1);
  return xptr;
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

SEXP raw_to_string(SEXP r, size_t count) {
  SEXP res = PROTECT(Rf_allocVector(STRSXP, count));
  char *s = (char*) RAW(r);
  for (int i = 0; i < count; i++) {
    size_t l = strlen(s);
    SET_STRING_ELT(res, i, Rf_mkCharLenCE(s, l, CE_UTF8));
    s += l + 1;
  }
  UNPROTECT(1);
  return res;
}

static SEXP raw_to_named_string(SEXP r, size_t count) {
  count /= 2;
  SEXP res = PROTECT(Rf_allocVector(STRSXP, count));
  SEXP nms = PROTECT(Rf_allocVector(STRSXP, count));
  char *s = (char*) RAW(r);
  for (int i = 0; i < count; i++) {
    size_t l = strlen(s);
    SET_STRING_ELT(res, i, Rf_mkCharLenCE(s, l, CE_UTF8));
    s += l + 1;
    l = strlen(s);
    SET_STRING_ELT(nms, i, Rf_mkCharLenCE(s, l, CE_UTF8));
    s += l + 1;
  }
  Rf_setAttrib(res, R_NamesSymbol, nms);
  UNPROTECT(2);
  return res;
}

SEXP otel_tracer_provider_http_options(void) {
  struct otel_tracer_provider_http_options_t opts = { 0 };
  otel_tracer_provider_http_default_options_(&opts);
  SEXP url = PROTECT(Rf_allocVector(RAWSXP, opts.url.size));
  opts.url.s = (char*) RAW(url);
  SEXP http_headers = PROTECT(Rf_allocVector(RAWSXP, opts.http_headers.size));
  opts.http_headers.s = (char*) RAW(http_headers);
  SEXP ssl_ca_cert_path = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_ca_cert_path.size));
  opts.ssl_ca_cert_path.s = (char*) RAW(ssl_ca_cert_path);
  SEXP ssl_ca_cert_string = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_ca_cert_string.size));
  opts.ssl_ca_cert_string.s = (char*) RAW(ssl_ca_cert_string);
  SEXP ssl_client_key_path = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_client_key_path.size));
  opts.ssl_client_key_path.s = (char*) RAW(ssl_client_key_path);
  SEXP ssl_client_key_string = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_client_key_string.size));
  opts.ssl_client_key_string.s = (char*) RAW(ssl_client_key_string);
  SEXP ssl_client_cert_path = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_client_cert_path.size));
  opts.ssl_client_cert_path.s = (char*) RAW(ssl_client_cert_path);
  SEXP ssl_client_cert_string = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_client_cert_string.size));
  opts.ssl_client_cert_string.s = (char*) RAW(ssl_client_cert_string);
  SEXP ssl_min_tls = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_min_tls.size));
  opts.ssl_min_tls.s = (char*) RAW(ssl_min_tls);
  SEXP ssl_max_tls = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_max_tls.size));
  opts.ssl_max_tls.s = (char*) RAW(ssl_max_tls);
  SEXP ssl_cipher = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_cipher.size));
  opts.ssl_cipher.s = (char*) RAW(ssl_cipher);
  SEXP ssl_cipher_suite = PROTECT(Rf_allocVector(RAWSXP, opts.ssl_cipher_suite.size));
  opts.ssl_cipher_suite.s = (char*) RAW(ssl_cipher_suite);
  SEXP compression = PROTECT(Rf_allocVector(RAWSXP, opts.compression.size));
  opts.compression.s = (char*) RAW(compression);

  otel_tracer_provider_http_default_options_(&opts);

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
  SET_VECTOR_ELT(res, 5,
    raw_to_named_string(http_headers, opts.http_headers.count)
  );
  SET_VECTOR_ELT(res, 6, Rf_ScalarLogical(opts.ssl_insecure_skip_verify));
  SET_VECTOR_ELT(res, 7, Rf_mkString(opts.ssl_ca_cert_path.s));
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

  UNPROTECT(14);
  return res;
}
