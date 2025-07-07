#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common.h"
#include "otel_common_r.h"
#include "errors.h"

void r2c_attributes(SEXP r, struct otel_attributes *c);

void otel_logger_provider_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid logger provider pointer."
    );
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *logger_provider_ = R_ExternalPtrAddr(x);
  if (logger_provider_) {
    otel_logger_provider_finally_(logger_provider_);
    R_ClearExternalPtr(x);
  }
}

void otel_logger_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    // # nocov start LCOV_EXCL_START
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid logger pointer.");
    return;
    // # nocov end LCOV_EXCL_STOP
  }
  void *logger_ = R_ExternalPtrAddr(x);
  if (logger_) {
    otel_logger_finally_(logger_);
    R_ClearExternalPtr(x);
  }
}

SEXP otel_create_logger_provider_stdstream(SEXP options, SEXP attributes) {
  SEXP stream = rf_get_list_element(options, "output");
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  const char *cstream = CHAR(STRING_ELT(stream, 0));
  void *logger_provider_ = otel_create_logger_provider_stdstream_(
    cstream, &attributes_);
  SEXP xptr = R_MakeExternalPtr(logger_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_logger_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_logger_provider_http(SEXP options, SEXP attributes) {
  struct otel_http_exporter_options options_;
  struct otel_attributes attributes_;
  r2c_otel_http_exporter_options(options, &options_);
  r2c_attributes(attributes, &attributes_);
  void *logger_provider_ = otel_create_logger_provider_http_(
    &options_, &attributes_);
  SEXP xptr = R_MakeExternalPtr(logger_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_logger_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_logger_provider_file(SEXP options) {
  struct otel_file_exporter_options options_ = { 0 };
  r2c_otel_file_exporter_options(options, &options_);
  void *logger_provider_ = otel_create_logger_provider_file_(&options_);
  otel_file_exporter_options_free(&options_);
  SEXP xptr = R_MakeExternalPtr(logger_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_logger_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_logger_provider_file_options_defaults(void) {
  struct otel_file_exporter_options options_ = { 0 };
  otel_logger_provider_file_options_defaults_(&options_);
  SEXP res = Rf_protect(c2r_otel_file_exporter_options(&options_));
  otel_file_exporter_options_free(&options_);
  Rf_unprotect(1);
  return res;
}

SEXP otel_logger_provider_flush(SEXP provider) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid logger provider pointer."
    );
    return R_NilValue;
  }
  void *logger_provider_ = R_ExternalPtrAddr(provider);
  if (!logger_provider_) {
    Rf_error(
      "Opentelemetry logger provider cleaned up already, internal error."
    );
  }
  otel_logger_provider_flush_(logger_provider_);
  return R_NilValue;
}

SEXP otel_get_logger(
    SEXP provider, SEXP name, SEXP minimum_severity, SEXP version,
    SEXP schema_url, SEXP attributes) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid logger provider pointer.");
  }
  void *logger_provider_ = R_ExternalPtrAddr(provider);
  if (!logger_provider_) {
    Rf_error(
      "Opentelemetry logger provider cleaned up already, internal error."
    );
  }
  const char *name_ = CHAR(STRING_ELT(name, 0));
  const char *version_ =
    Rf_isNull(version) ? NULL : CHAR(STRING_ELT(version, 0));
  const char *schema_url_ =
    Rf_isNull(schema_url) ? NULL : CHAR(STRING_ELT(schema_url, 0));
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  int minimum_severity_ = INTEGER(minimum_severity)[0];
  void *logger_ = otel_get_logger_(
    logger_provider_, name_, minimum_severity_, version_, schema_url_,
    &attributes_);
  SEXP xptr = R_MakeExternalPtr(logger_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_logger_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_get_minimum_log_severity(SEXP logger) {
  if (TYPEOF(logger) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid logger pointer");
  }
  void *logger_ = R_ExternalPtrAddr(logger);
  if (!logger_) {
    Rf_error("Opentelemetry logger cleaned up already, internal error.");
  }

  int minimum_severity = otel_get_minimum_log_severity_(logger_);
  return Rf_ScalarInteger(minimum_severity);
}

SEXP otel_set_minimum_log_severity(SEXP logger, SEXP minimum_severity) {
  if (TYPEOF(logger) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid logger pointer");
  }
  void *logger_ = R_ExternalPtrAddr(logger);
  if (!logger_) {
    Rf_error("Opentelemetry logger cleaned up already, internal error.");
  }

  int minimum_severity_ = INTEGER(minimum_severity)[0];
  otel_set_minimum_log_severity_(logger_, minimum_severity_);
  return R_NilValue;
}

SEXP otel_logger_get_name(SEXP logger) {
  if (TYPEOF(logger) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid logger pointer");
  }
  void *logger_ = R_ExternalPtrAddr(logger);
  if (!logger_) {
    Rf_error("Opentelemetry logger cleaned up already, internal error.");
  }

  struct otel_string cname = { 0 };
  if (otel_logger_get_name_(logger_, &cname)) {
    // # nocov start LCOV_EXCL_START
    Rf_error("Out of memory when allocating OpenTelemetry logger name");
    // # nocov end LCOV_EXCL_STOP
  }
  SEXP name = Rf_ScalarString(Rf_mkCharLen(cname.s, cname.size));
  // TODO: use cleancall
  otel_string_free(&cname);
  return name;
}

// # nocov start LCOV_EXCL_START
SEXP otel_emit_log_record(SEXP logger, SEXP log_record) {
  // TODO
  return R_NilValue;
}
// # nocov end LCOV_EXCL_STOP

SEXP otel_logger_is_enabled(SEXP logger, SEXP severity, SEXP event_id) {
  if (TYPEOF(logger) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid logger pointer");
  }
  void *logger_ = R_ExternalPtrAddr(logger);
  if (!logger_) {
    Rf_error("Opentelemetry logger cleaned up already, internal error.");
  }
  int severity_ = INTEGER(severity)[0];
  int enabled = otel_logger_is_enabled_(logger_, severity_);
  return Rf_ScalarLogical(enabled);
}

SEXP otel_log(
    SEXP logger, SEXP format, SEXP severity, SEXP event_id, SEXP span_id,
    SEXP trace_id, SEXP trace_flags, SEXP timestamp, SEXP observed_timestamp,
    SEXP attributes) {
  if (TYPEOF(logger) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid logger pointer");
  }
  void *logger_ = R_ExternalPtrAddr(logger);
  if (!logger_) {
    Rf_error("Opentelemetry logger cleaned up already, internal error.");
  }

  const char *format_ = CHAR(STRING_ELT(format, 0));
  int severity_ = INTEGER(severity)[0];
  // TODO: event_id
  const char *trace_id_ =
    Rf_isNull(trace_id) ? NULL : CHAR(STRING_ELT(trace_id, 0));
  const char *span_id_ =
    Rf_isNull(span_id) ? NULL : CHAR(STRING_ELT(span_id, 0));
  // TODO: trace_flags
  void *timestamp_ = NULL;
  if (!Rf_isNull(timestamp)) {
    timestamp_ = REAL(timestamp);
  }
  void *observed_timestamp_ = NULL;
  if (!Rf_isNull(observed_timestamp)) {
    observed_timestamp_ = REAL(observed_timestamp);
  }
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  otel_log_(
    logger_, format_, severity_, span_id_, trace_id_, timestamp_,
    observed_timestamp_, &attributes_);
  return R_NilValue;
}

SEXP otel_logger_provider_http_options(void) {
  struct otel_provider_http_options opts = { 0 };
  if (otel_logger_provider_http_default_options_(&opts)) {
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
