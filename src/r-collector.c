#include <string.h>

#include "Rinternals.h"

#include "otel_common.h"
#include "otel_common_r.h"
#include "errors.h"

SEXP otel_parse_log_record(SEXP str) {
  const char *str_ = (const char*) RAW(str);
  size_t len = Rf_length(str);
  struct otel_collector_resource_logs rl = { 0 };
  if (otel_decode_log_record_(str_, len, &rl)) {
    R_THROW_ERROR("Failed to parse Protobuf log message");
  }
  SEXP res = c2r_otel_collector_resource_logs(&rl);
  // TODO: cleancall
  otel_collector_resource_logs_free(&rl);
  return res;
}

SEXP otel_encode_response(
    SEXP signal_, SEXP result_, SEXP errmsg_, SEXP rejected_,
    SEXP error_code_) {
  const int signal = INTEGER(signal_)[0];
  const int result = INTEGER(result_)[0];
  const char *errmsg = Rf_isNull(errmsg_) ? 0 : CHAR(STRING_ELT(errmsg_, 0));
  const int rejected = INTEGER(rejected_)[0];
  const int error_code = INTEGER(error_code_)[0];
  struct otel_string msg = { 0 };
  if (otel_encode_response_(
      signal, result, errmsg, rejected, error_code, &msg)) {
    R_THROW_ERROR("Failed to encode Protobuf response");
  };
  SEXP res = Rf_protect(Rf_allocVector(RAWSXP, msg.size));
  memcpy(RAW(res), msg.s, msg.size);
  // TODO: cleancall
  otel_string_free(&msg);

  Rf_unprotect(1);
  return res;
}
