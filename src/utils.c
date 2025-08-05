#include <string.h>
#include <stdlib.h>

#include "Rinternals.h"

#include "otel_common.h"

SEXP rf_get_list_element(SEXP list, const char *str) {
  SEXP elmt = R_NilValue;
  SEXP names = PROTECT(Rf_getAttrib(list, R_NamesSymbol));
  R_xlen_t len = Rf_xlength(list);

  for (R_xlen_t i = 0; i < len; i++) {
    if (!strcmp(CHAR(STRING_ELT(names, i)), str)) {
       elmt = VECTOR_ELT(list, i);
       break;
    }
  }
  UNPROTECT(1);
  return elmt;
}

SEXP otel_fail(void) {
  Rf_error("from C");
  return R_NilValue;
}

SEXP otel_span_kinds = NULL;
SEXP otel_span_status_codes = NULL;

SEXP otel_init_constants(SEXP env) {
  R_PreserveObject(env);
  otel_span_kinds = Rf_findVarInFrame(env, Rf_install("span_kinds"));
  otel_span_status_codes =
    Rf_findVarInFrame(env, Rf_install("span_status_codes"));
  return R_NilValue;
}

SEXP create_empty_xptr(void ) {
  SEXP xptr = R_MakeExternalPtr(NULL, R_NilValue, R_NilValue);
  return xptr;
}
