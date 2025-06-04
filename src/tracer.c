#include <errno.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common_r.h"
#include "errors.h"

SEXP otel_tracer_provider_memory_get_spans(SEXP provider) {
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

  struct otel_span_data_t data = { 0 };
  if (otel_tracer_provider_memory_get_spans_(tracer_provider_, &data)) {
    R_THROW_MAYBE_SYSTEM_ERROR("Cannot get spans from memory tracer provider");
  }

  SEXP res = PROTECT(Rf_allocVector(VECSXP, data.count));
  const char *nms[] = {
    "trace_id", "span_id", "name", "flags", "parent", "description",
    "resource_attributes", "schema_url", "instrumentation_scope", "kind",
    "status", "start_time", "duration", "attributes", "events", "links", ""
  };
  SEXP posix_class = PROTECT(R_NilValue);
  if (data.count > 0) {
    UNPROTECT(1);
    posix_class = PROTECT(Rf_allocVector(STRSXP, 2));
    SET_STRING_ELT(posix_class, 0, Rf_mkChar("POSIXct"));
    SET_STRING_ELT(posix_class, 1, Rf_mkChar("POSIXt"));
  }
  for (int i = 0; i < data.count; i++) {
    SET_VECTOR_ELT(res, i, Rf_mkNamed(VECSXP, nms));
    SEXP xi = VECTOR_ELT(res, i);
    SET_VECTOR_ELT(xi, 0, c2r_otel_string(&data.a[i].trace_id));
    SET_VECTOR_ELT(xi, 1, c2r_otel_string(&data.a[i].span_id));
    SET_VECTOR_ELT(xi, 2, c2r_otel_string(&data.a[i].name));
    SET_VECTOR_ELT(xi, 3, c2r_otel_trace_flags(&data.a[i].flags));
    SET_VECTOR_ELT(xi, 4, c2r_otel_string(&data.a[i].parent));
    SET_VECTOR_ELT(xi, 5, c2r_otel_string(&data.a[i].description));
    SET_VECTOR_ELT(xi, 6, c2r_otel_attributes(&data.a[i].resource_attributes));
    SET_VECTOR_ELT(xi, 7, c2r_otel_string(&data.a[i].schema_url));
    SET_VECTOR_ELT(xi, 8, c2r_otel_instrumentation_scope(
      &data.a[i].instrumentation_scope));
    SET_VECTOR_ELT(xi, 9,
      Rf_ScalarString(STRING_ELT(otel_span_kinds, data.a[i].kind)));
    SET_VECTOR_ELT(xi, 10,
      Rf_ScalarString(STRING_ELT(otel_span_status_codes,data.a[i].status)));
    SET_VECTOR_ELT(xi, 11, Rf_ScalarReal(data.a[i].start_time));
    Rf_setAttrib(VECTOR_ELT(xi, 11), R_ClassSymbol, posix_class);
    SET_VECTOR_ELT(xi, 12, Rf_ScalarReal(data.a[i].duration));
    SET_VECTOR_ELT(xi, 13, c2r_otel_attributes(&data.a[i].attributes));
    SET_VECTOR_ELT(xi, 14, c2r_otel_events(&data.a[i].events));
    SET_VECTOR_ELT(xi, 15, c2r_otel_span_links(&data.a[i].links));
    Rf_setAttrib(xi, R_ClassSymbol, Rf_mkString("otel_span_data"));
  }
  otel_span_data_free(&data);
  UNPROTECT(2);
  return res;
}
