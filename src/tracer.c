#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common_r.h"

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

  struct otel_span_data_t *data =
    otel_tracer_provider_memory_get_spans_(tracer_provider_);

  // TODO: data leaks on error, need to use cleancall
  SEXP res = PROTECT(Rf_allocVector(VECSXP, data->count));
  const char *nms[] = {
    "trace_id", "span_id", "name", "flags", "parent", "description",
    "schema_url", "instrumentation_scope", "kind", "status", "start_time",
    "duration", ""
  };
  for (int i = 0; i < data->count; i++) {
    SET_VECTOR_ELT(res, i, Rf_mkNamed(VECSXP, nms));
    SEXP xi = VECTOR_ELT(res, i);
    SET_VECTOR_ELT(xi, 0, rf_otel_string_to_strsxp(&data->a[i].trace_id));
    SET_VECTOR_ELT(xi, 1, rf_otel_string_to_strsxp(&data->a[i].span_id));
    SET_VECTOR_ELT(xi, 2, rf_otel_string_to_strsxp(&data->a[i].name));
    SET_VECTOR_ELT(xi, 3, Rf_ScalarString(Rf_mkCharLen(data->a[i].flags, 2)));
    SET_VECTOR_ELT(xi, 4, rf_otel_string_to_strsxp(&data->a[i].parent));
    SET_VECTOR_ELT(xi, 5, rf_otel_string_to_strsxp(&data->a[i].description));
    SET_VECTOR_ELT(xi, 6, rf_otel_string_to_strsxp(&data->a[i].schema_url));
    SET_VECTOR_ELT(xi, 7, c2r_otel_instrumentation_scope(
      &data->a[i].instrumentation_scope));
    SET_VECTOR_ELT(xi, 8, Rf_ScalarInteger(data->a[i].kind));
    SET_VECTOR_ELT(xi, 9, Rf_ScalarInteger(data->a[i].status));
    SET_VECTOR_ELT(xi, 10, Rf_ScalarReal(data->a[i].start_time));
    SET_VECTOR_ELT(xi, 11, Rf_ScalarReal(data->a[i].duration));
    Rf_setAttrib(xi, R_ClassSymbol, Rf_mkString("otel_span_data"));
  }
  otel_span_data_free(data);
  UNPROTECT(1);
  return res;
}
