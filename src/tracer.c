#include <errno.h>
#include <string.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common_r.h"
#include "errors.h"

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

SEXP otel_create_tracer_provider_stdstream(SEXP options, SEXP attributes) {
  SEXP stream = rf_get_list_element(options, "output");
  const char *cstream = CHAR(STRING_ELT(stream, 0));
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  void *tracer_provider_ = otel_create_tracer_provider_stdstream_(
    cstream, &attributes_);
  SEXP xptr = R_MakeExternalPtr(tracer_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_tracer_provider_http(SEXP options, SEXP attributes) {
  struct otel_http_exporter_options options_;
  struct otel_attributes attributes_;
  r2c_otel_http_exporter_options(options, &options_);
  r2c_attributes(attributes, &attributes_);
  struct otel_bsp_options bsp_options;
  memset(&bsp_options.isset, 0, sizeof(bsp_options.isset));
  SEXP max_queue_size = rf_get_list_element(options, "max_queue_size");
  if ((bsp_options.isset.max_queue_size = !Rf_isNull(max_queue_size))) {
    bsp_options.max_queue_size = REAL(max_queue_size)[0];
  }
  SEXP schedule_delay = rf_get_list_element(options, "schedule_delay");
  if ((bsp_options.isset.schedule_delay = !Rf_isNull(schedule_delay))) {
    bsp_options.schedule_delay = REAL(schedule_delay)[0];
  }
  SEXP max_export_batch_size =
    rf_get_list_element(options, "max_export_batch_size");
  if ((bsp_options.isset.max_export_batch_size =
       !Rf_isNull(max_export_batch_size))) {
    bsp_options.max_export_batch_size = REAL(max_export_batch_size)[0];
  }
  void *tracer_provider_ =
    otel_create_tracer_provider_http_(&options_, &attributes_, &bsp_options);
  SEXP xptr = R_MakeExternalPtr(tracer_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_tracer_provider_memory(SEXP options, SEXP attributes) {
  SEXP buffer_size = rf_get_list_element(options, "buffer_size");
  int cbuffer_size = INTEGER(buffer_size)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  void *tracer_provider_ = otel_create_tracer_provider_memory_(
    cbuffer_size, &attributes_);
  SEXP xptr = R_MakeExternalPtr(tracer_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_tracer_provider_file(SEXP options, SEXP attributes) {
  struct otel_file_exporter_options options_;
  r2c_otel_file_exporter_options(options, &options_);
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);

  void *tracer_provider_ = otel_create_tracer_provider_file_(
    &options_, &attributes_);
  SEXP xptr = R_MakeExternalPtr(tracer_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_tracer_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_tracer_provider_file_options_defaults(void) {
  struct otel_file_exporter_options options_ = { 0 };
  otel_tracer_provider_file_options_defaults_(&options_);
  SEXP res = Rf_protect(c2r_otel_file_exporter_options(&options_));
  otel_file_exporter_options_free(&options_);
  Rf_unprotect(1);
  return res;
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
  int res = otel_tracer_provider_flush_(tracer_provider_);
  return Rf_ScalarLogical(res);
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

SEXP otel_get_active_span_context(SEXP tracer) {
  if (TYPEOF(tracer) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid tracer pointer.");
  }
  void *tracer_ = R_ExternalPtrAddr(tracer);
  if (!tracer_) {
    Rf_error("Opentelemetry tracer cleaned up already, internal error.");
  }

  void *span_context_ = otel_get_active_span_context_(tracer_);
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

const char *otel_http_request_content_type_str[] = {
  "http/json",
  "http/protobuf"
};

SEXP otel_tracer_provider_http_options(void) {
  struct otel_provider_http_options opts = { 0 };
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
  SET_VECTOR_ELT(res, 0, c2r_otel_string(&opts.url));
  SET_VECTOR_ELT(res, 1,
    Rf_mkString(otel_http_request_content_type_str[opts.content_type])
  );
  SET_VECTOR_ELT(res, 2, Rf_ScalarLogical(opts.use_json_name));
  SET_VECTOR_ELT(res, 3, Rf_ScalarLogical(opts.console_debug));
  SET_VECTOR_ELT(res, 4, Rf_ScalarReal(opts.timeout));
  SET_VECTOR_ELT(res, 5, c2r_otel_named_strings(&opts.http_headers));
  SET_VECTOR_ELT(res, 6, Rf_ScalarLogical(opts.ssl_insecure_skip_verify));
  SET_VECTOR_ELT(res, 7, c2r_otel_string(&opts.ssl_ca_cert_path));
  SET_VECTOR_ELT(res, 8, c2r_otel_string(&opts.ssl_ca_cert_string));
  SET_VECTOR_ELT(res, 9, c2r_otel_string(&opts.ssl_client_key_path));
  SET_VECTOR_ELT(res, 10, c2r_otel_string(&opts.ssl_client_key_string));
  SET_VECTOR_ELT(res, 11, c2r_otel_string(&opts.ssl_client_cert_path));
  SET_VECTOR_ELT(res, 12, c2r_otel_string(&opts.ssl_client_cert_string));
  SET_VECTOR_ELT(res, 13, c2r_otel_string(&opts.ssl_min_tls));
  SET_VECTOR_ELT(res, 14, c2r_otel_string(&opts.ssl_max_tls));
  SET_VECTOR_ELT(res, 15, c2r_otel_string(&opts.ssl_cipher));
  SET_VECTOR_ELT(res, 16, c2r_otel_string(&opts.ssl_cipher_suite));
  SET_VECTOR_ELT(res, 17, c2r_otel_string(&opts.compression));
  SET_VECTOR_ELT(res, 18, Rf_ScalarInteger(opts.retry_policy_max_attempts));
  SET_VECTOR_ELT(res, 19, Rf_ScalarReal(opts.retry_policy_initial_backoff));
  SET_VECTOR_ELT(res, 20, Rf_ScalarReal(opts.retry_policy_max_backoff));
  SET_VECTOR_ELT(res, 21, Rf_ScalarReal(opts.retry_policy_backoff_multiplier));

  UNPROTECT(1);
  return res;
}

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

  struct otel_span_data data = { 0 };
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

SEXP otel_bsp_defaults(void) {
  struct otel_bsp_options opts;
  if (otel_bsp_defaults_(&opts)) {
    otel_bsp_options_free(&opts);
    R_THROW_ERROR(
      "Cannot query default OpenTelemetry batch span processor options"
    );
  }
  const char *nms[] = {
    "max_queue_size", "schedule_delay", "max_export_batch_size", "" };
  SEXP res = Rf_protect(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, Rf_ScalarReal(opts.max_queue_size));
  SET_VECTOR_ELT(res, 1, Rf_ScalarReal(opts.schedule_delay));
  SET_VECTOR_ELT(res, 2, Rf_ScalarReal(opts.max_export_batch_size));

  // TODO: cleancall
  otel_bsp_options_free(&opts);
  Rf_unprotect(1);
  return res;
}
