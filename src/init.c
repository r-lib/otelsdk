#include <string.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "otel_common.h"

SEXP otel_create_tracer_provider_stdstream(SEXP stream);
SEXP otel_create_tracer_provider_http(void);
SEXP otel_get_tracer(SEXP provider, SEXP name);

SEXP otel_start_span(
  SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options,
  SEXP parent
);
SEXP otel_span_end(SEXP scoped_span);

SEXP otel_start_session(void);
SEXP otel_activate_session(SEXP sess);
SEXP otel_deactivate_session(SEXP sess);
SEXP otel_finish_session(SEXP sess);
SEXP otel_finish_all_sessions(void);

SEXP otel_tracer_provider_http_options(void);

SEXP rf_get_list_element(SEXP list, const char *str);

#define CALLDEF(name, n) \
  { #name, (DL_FUNC)&name, n }

static const R_CallMethodDef callMethods[]  = {
  CALLDEF(otel_create_tracer_provider_stdstream, 1),
  CALLDEF(otel_create_tracer_provider_http, 0),
  CALLDEF(otel_get_tracer, 2),
  CALLDEF(otel_start_span, 6),
  CALLDEF(otel_span_end, 1),
  CALLDEF(otel_start_session, 0),
  CALLDEF(otel_activate_session, 1),
  CALLDEF(otel_deactivate_session, 1),
  CALLDEF(otel_finish_session, 1),
  CALLDEF(otel_finish_all_sessions, 0),
  CALLDEF(otel_tracer_provider_http_options, 0),
  { NULL, NULL, 0 }
};

extern void otel_init_context_storage(void);

void R_init_opentelemetry(DllInfo *dll) {
  R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
  otel_init_context_storage();
}

void otel_tracer_provider_finally(SEXP x) {
  void *tracer_provider_ = R_ExternalPtrAddr(x);
  if (tracer_provider_) {
    otel_tracer_provider_finally_(tracer_provider_);
    R_ClearExternalPtr(x);
  }
}

void otel_tracer_finally(SEXP x) {
  void *tracer_ = R_ExternalPtrAddr(x);
  if (tracer_) {
    otel_tracer_finally_(tracer_);
    R_ClearExternalPtr(x);
  }
}

void otel_span_finally(SEXP x) {
  void *span_ = R_ExternalPtrAddr(x);
  if (span_) {
    otel_span_finally_(span_);
    R_ClearExternalPtr(x);
  }
}

void otel_scope_finally(SEXP x) {
  void *scope_ = R_ExternalPtrAddr(x);
  if (scope_) {
    otel_span_finally_(scope_);
    R_ClearExternalPtr(x);
  }
}

void otel_session_finally(SEXP x) {
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

SEXP otel_get_tracer(SEXP provider, SEXP name) {
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

SEXP otel_start_span(
  SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options,
  SEXP parent) {

  void *tracer_ = R_ExternalPtrAddr(tracer);
  if (!tracer_) {
    Rf_error("Opentelemetry tracer cleaned up already, internal error.");
  }
  void *parent_ = NULL;
  if (!Rf_isNull(parent)) {
    parent_ = R_ExternalPtrAddr(parent);
  }

  // TODO: attributes
  // TODO: links
  // TODO: rest of options

  const char *name_ = CHAR(STRING_ELT(name, 0));
  struct otel_scoped_span sspan = otel_start_span_(tracer_, name_, parent_);
  SEXP res = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(res, 0, R_MakeExternalPtr(sspan.span, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(VECTOR_ELT(res, 0), otel_span_finally, (Rboolean) 1);
  SET_VECTOR_ELT(res, 1, R_MakeExternalPtr(sspan.scope, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(VECTOR_ELT(res, 1), otel_scope_finally, (Rboolean) 1);
  UNPROTECT(1);
  return res;
}

SEXP otel_span_end(SEXP scoped_span) {
  SEXP span = VECTOR_ELT(scoped_span, 0);
  SEXP scope = VECTOR_ELT(scoped_span, 1);
  void *span_ = R_ExternalPtrAddr(span);
  void *scope_ = R_ExternalPtrAddr(scope);
  if (span_ && scope_) {
    otel_span_end_(span_, scope_);
    R_ClearExternalPtr(scope);
  }
  return R_NilValue;
}

SEXP otel_start_session(void) {
  void *sess_ = otel_start_session_();
  SEXP res = PROTECT(R_MakeExternalPtr(sess_, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(res, otel_session_finally, (Rboolean) 1);
  UNPROTECT(1);
  return res;
}

SEXP otel_activate_session(SEXP sess) {
  void *sess_ = R_ExternalPtrAddr(sess);
  otel_activate_session_(sess_);
  return R_NilValue;
}

SEXP otel_deactivate_session(SEXP sess) {
  void *sess_ = R_ExternalPtrAddr(sess);
  otel_deactivate_session_(sess_);
  return R_NilValue;
}

SEXP otel_finish_session(SEXP sess) {
  void *sess_ = R_ExternalPtrAddr(sess);
  otel_finish_session_(sess_);
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

static SEXP raw_to_string(SEXP r, size_t count) {
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
