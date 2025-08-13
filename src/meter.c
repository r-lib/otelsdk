#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common.h"
#include "otel_common_r.h"
#include "errors.h"

void r2c_attributes(SEXP r, struct otel_attributes *c);

void otel_meter_provider_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *meter_provider_ = R_ExternalPtrAddr(x);
  if (meter_provider_) {
    otel_meter_provider_finally_(meter_provider_);
    R_ClearExternalPtr(x);
  }
}

void otel_meter_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid meter pointer.");
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *meter_ = R_ExternalPtrAddr(x);
  if (meter_) {
    otel_meter_finally_(meter_);
    R_ClearExternalPtr(x);
  }
}

SEXP otel_create_meter_provider_stdstream(SEXP options, SEXP attributes) {
  struct otel_attributes attributes_;
  SEXP stream = rf_get_list_element(options, "output");
  r2c_attributes(attributes, &attributes_);
  const char *cstream = CHAR(STRING_ELT(stream, 0));
  int cexport_interval =
    INTEGER(rf_get_list_element(options, "export_interval"))[0];
  int cexport_timeout =
    INTEGER(rf_get_list_element(options, "export_timeout"))[0];
  void *meter_provider_ = otel_create_meter_provider_stdstream_(
    cstream, cexport_interval, cexport_timeout);
  SEXP xptr = R_MakeExternalPtr(meter_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_provider_finally, (Rboolean) 1);
  // TODO: cleancall
  otel_attributes_free(&attributes_);
  return xptr;
}

SEXP otel_create_meter_provider_http(SEXP options, SEXP attributes) {
  struct otel_http_exporter_options options_;
  struct otel_attributes attributes_;
  r2c_otel_http_exporter_options(options, &options_);
  r2c_attributes(attributes, &attributes_);
  int cexport_interval =
    INTEGER(rf_get_list_element(options, "export_interval"))[0];
  int cexport_timeout =
    INTEGER(rf_get_list_element(options, "export_timeout"))[0];
  int aggregation_temporality =
    INTEGER(rf_get_list_element(options, "aggregation_temporality"))[0];
  void *meter_provider_ = otel_create_meter_provider_http_(
    &options_, &attributes_, cexport_interval, cexport_timeout,
    aggregation_temporality);
  SEXP xptr = R_MakeExternalPtr(meter_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_provider_finally, (Rboolean) 1);
  // TODO: cleancall
  otel_http_exporter_options_free(&options_);
  otel_attributes_free(&attributes_);
  return xptr;
}

SEXP otel_create_meter_provider_file(
    SEXP export_interval, SEXP export_timeout, SEXP options) {
  int cexport_interval = INTEGER(export_interval)[0];
  int cexport_timeout = INTEGER(export_timeout)[0];
  struct otel_file_exporter_options options_ = { 0 };
  r2c_otel_file_exporter_options(options, &options_);
  void *meter_provider_ = otel_create_meter_provider_file_(
    cexport_interval, cexport_timeout, &options_);
  otel_file_exporter_options_free(&options_);
  SEXP xptr = R_MakeExternalPtr(meter_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_meter_provider_file_options_defaults(void) {
  struct otel_file_exporter_options options_ = { 0 };
  otel_meter_provider_file_options_defaults_(&options_);
  SEXP res = Rf_protect(c2r_otel_file_exporter_options(&options_));
  otel_file_exporter_options_free(&options_);
  Rf_unprotect(1);
  return res;
}

SEXP otel_create_meter_provider_memory(SEXP options, SEXP attributes) {
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  SEXP export_interval = rf_get_list_element(options, "export_interval");
  SEXP export_timeout = rf_get_list_element(options, "export_timeout");
  SEXP buffer_size = rf_get_list_element(options, "buffer_size");
  SEXP aggregation_temporality = rf_get_list_element(
    options, "aggregation_temporality");
  int cexport_interval = INTEGER(export_interval)[0];
  int cexport_timeout = INTEGER(export_timeout)[0];
  int cbuffer_size = INTEGER(buffer_size)[0];
  int ctemporality = INTEGER(aggregation_temporality)[0];
  void *meter_provider_ = otel_create_meter_provider_memory_(
    cexport_interval, cexport_timeout, cbuffer_size, ctemporality,
    &attributes_);
  SEXP xptr = R_MakeExternalPtr(meter_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_provider_finally, (Rboolean) 1);
  // TODO: cleancall
  otel_attributes_free(&attributes_);
  return xptr;
}

SEXP otel_meter_provider_memory_get_metrics(SEXP provider) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return R_NilValue;
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }

  struct otel_metrics_data data = { 0 };
  // # nocov start LCOV_EXCL_START
  if (otel_meter_provider_memory_get_metrics_(meter_provider_, &data)) {
    R_THROW_MAYBE_SYSTEM_ERROR(
      "Cannot retrieve recorded OpenTelemetry metrics"
    );
  }
  // # nocov end LCOV_EXCL_STOP

  SEXP res = c2r_otel_metrics_data(&data);

  otel_metrics_data_free(&data);
  return res;
}

SEXP otel_get_meter(
    SEXP provider, SEXP name, SEXP version, SEXP schema_url,
    SEXP attributes) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid meter provider pointer.");
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }
  const char *name_ = CHAR(STRING_ELT(name, 0));
  const char *version_ =
    Rf_isNull(version) ? NULL : CHAR(STRING_ELT(version, 0));
  const char *schema_url_ =
    Rf_isNull(schema_url) ? NULL : CHAR(STRING_ELT(schema_url, 0));
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  void *meter_ = otel_get_meter_(
    meter_provider_, name_, version_, schema_url_, &attributes_);
  SEXP xptr = R_MakeExternalPtr(meter_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_meter_provider_flush(SEXP provider, SEXP timeout) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return R_NilValue;
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }
  int ctimeout = Rf_isNull(timeout) ? -1 : INTEGER(timeout)[0];
  otel_meter_provider_flush_(meter_provider_, ctimeout);
  return R_NilValue;
}

SEXP otel_meter_provider_shutdown(SEXP provider, SEXP timeout) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return R_NilValue;
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }
  int ctimeout = Rf_isNull(timeout) ? -1 : INTEGER(timeout)[0];
  otel_meter_provider_shutdown_(meter_provider_, ctimeout);
  return R_NilValue;
}

void otel_counter_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid counter pointer.");
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *counter_ = R_ExternalPtrAddr(x);
  if (counter_) {
    otel_counter_finally_(counter_);
    R_ClearExternalPtr(x);
  }
}

void otel_up_down_counter_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid up-down counter pointer."
    );
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *up_down_counter_ = R_ExternalPtrAddr(x);
  if (up_down_counter_) {
    otel_up_down_counter_finally_(up_down_counter_);
    R_ClearExternalPtr(x);
  }
}

void otel_histogram_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid histogram pointer.");
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *histogram_ = R_ExternalPtrAddr(x);
  if (histogram_) {
    otel_histogram_finally_(histogram_);
    R_ClearExternalPtr(x);
  }
}

void otel_gauge_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid gauge pointer.");
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *gauge_ = R_ExternalPtrAddr(x);
  if (gauge_) {
    otel_gauge_finally_(gauge_);
    R_ClearExternalPtr(x);
  }
}

SEXP otel_create_counter(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *counter_ =
    otel_create_counter_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(counter_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_counter_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_counter_add(
    SEXP counter, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(counter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *counter_ = R_ExternalPtrAddr(counter);
  if (!counter_) {
    Rf_error("Opentelemetry counter cleaned up already, internal error.");
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_counter_add_(counter_, cvalue, &attributes_);
  return R_NilValue;
}

SEXP otel_create_up_down_counter(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *up_down_counter_ =
    otel_create_up_down_counter_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(up_down_counter_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_up_down_counter_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_up_down_counter_add(
    SEXP up_down_counter, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(up_down_counter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *up_down_counter_ = R_ExternalPtrAddr(up_down_counter);
  if (!up_down_counter_) {
    Rf_error(
      "Opentelemetry up-down counter cleaned up already, internal error."
    );
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_up_down_counter_add_(up_down_counter_, cvalue, &attributes_);
  return R_NilValue;
}

SEXP otel_create_histogram(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *histogram_ =
    otel_create_histogram_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(histogram_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_histogram_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_histogram_record(
    SEXP histogram, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(histogram) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *histogram_ = R_ExternalPtrAddr(histogram);
  if (!histogram_) {
    Rf_error(
      "Opentelemetry histogram cleaned up already, internal error."
    );
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_histogram_record_(histogram_, cvalue, &attributes_);
  return R_NilValue;
}

SEXP otel_create_gauge(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *gauge_ =
    otel_create_gauge_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(gauge_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_gauge_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_gauge_record(
    SEXP gauge, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(gauge) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *gauge_ = R_ExternalPtrAddr(gauge);
  if (!gauge_) {
    Rf_error(
      "Opentelemetry gauge cleaned up already, internal error."
    );
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_gauge_record_(gauge_, cvalue, &attributes_);
  return R_NilValue;
}

SEXP otel_meter_provider_http_options(void) {
  struct otel_provider_http_options opts = { 0 };
  if (otel_meter_provider_http_default_options_(&opts)) {
    R_THROW_SYSTEM_ERROR("Failed to query OpenTelemetry HTTP options"); // # nocov
  }                                                                     // # nocov

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

  otel_provider_http_options_free(&opts);
  UNPROTECT(1);
  return res;
}
