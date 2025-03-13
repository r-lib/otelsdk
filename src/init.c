#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "otel_common.h"

SEXP otel_create_tracer_provider_stdout(void);
SEXP otel_create_tracer_provider_http(void);
SEXP otel_get_tracer(SEXP provider, SEXP name);

SEXP otel_start_span(SEXP tracer, SEXP name, SEXP parent);
SEXP otel_span_end(SEXP scoped_span);

SEXP otel_tracer_provider_http_default_url(void);

#define CALLDEF(name, n) \
  { #name, (DL_FUNC)&name, n }

static const R_CallMethodDef callMethods[]  = {
  CALLDEF(otel_create_tracer_provider_stdout, 0),
  CALLDEF(otel_create_tracer_provider_http, 0),
  CALLDEF(otel_get_tracer, 2),
  CALLDEF(otel_start_span, 3),
  CALLDEF(otel_span_end, 1),
  CALLDEF(otel_tracer_provider_http_default_url, 0),
  { NULL, NULL, 0 }
};

void R_init_opentelemetry(DllInfo *dll) {
  R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
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

SEXP otel_create_tracer_provider_stdout(void) {
  void *tracer_provider_ = otel_create_tracer_provider_stdout_();
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

SEXP otel_start_span(SEXP tracer, SEXP name, SEXP parent) {
  void *tracer_ = R_ExternalPtrAddr(tracer);
  if (!tracer_) {
    Rf_error("Opentelemetry tracer cleaned up already, internal error.");
  }
  void *parent_ = NULL;
  if (!Rf_isNull(parent)) {
    parent_ = R_ExternalPtrAddr(parent);
  }
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

SEXP otel_tracer_provider_http_default_url(void) {
  size_t len;
  otel_tracer_provider_http_default_url_(NULL, &len);
  SEXP res = PROTECT(Rf_allocVector(RAWSXP, ++len));
  otel_tracer_provider_http_default_url_((char*)RAW(res), &len);
  UNPROTECT(1);
  return res;
}
