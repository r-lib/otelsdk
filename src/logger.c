#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common.h"

void r2c_attributes(SEXP r, struct otel_attributes *c);

SEXP otel_logger_get_name(SEXP logger) {
  if (TYPEOF(logger) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid logger pointer");
  }
  void *logger_ = R_ExternalPtrAddr(logger);
  if (!logger_) {
    Rf_error("Opentelemetry logger cleaned up already, internal error.");
  }

  struct otel_string cname = { 0 };
  otel_logger_get_name_(logger_, &cname);
  SEXP rname = PROTECT(Rf_allocVector(RAWSXP, cname.size));
  cname.s = (char*) RAW(rname);
  otel_logger_get_name_(logger_, &cname);
  SEXP name = PROTECT(Rf_mkString((char*) RAW(rname)));

  UNPROTECT(2);
  return name;
}

SEXP otel_emit_log_record(SEXP logger, SEXP log_record) {

}

SEXP otel_log_trace(SEXP logger, SEXP args) {

}

SEXP otel_log_debug(SEXP logger, SEXP args) {

}

SEXP otel_log_info(SEXP logger, SEXP args) {

}

SEXP otel_log_warn(SEXP logger, SEXP args) {

}

SEXP otel_log_error(SEXP logger, SEXP args) {

}

SEXP otel_log_fatal(SEXP logger, SEXP args) {

}

SEXP otel_logger_is_enabled(SEXP logger, SEXP severiry, SEXP event_id) {

}

SEXP otel_log(
    SEXP logger, SEXP severity, SEXP format, SEXP event_id,
    SEXP attributes) {
  if (TYPEOF(logger) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid logger pointer");
  }
  void *logger_ = R_ExternalPtrAddr(logger);
  if (!logger_) {
    Rf_error("Opentelemetry logger cleaned up already, internal error.");
  }

  int severity_ = INTEGER(severity)[0];
  const char *format_ = CHAR(STRING_ELT(format, 0));
  // TODO: event_id
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  otel_log_(logger_, severity_, format_, &attributes_);
  return R_NilValue;
}
