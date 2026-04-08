#include <string.h>
#include <stdlib.h>

#include <Rinternals.h>
#include <Rversion.h>

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

#if (defined(R_VERSION) && R_VERSION < R_Version(4, 5, 0))
#define R_getVar(x,y,z) Rf_findVarInFrame(x,y)
#endif

SEXP otel_init_constants(SEXP env) {
  R_PreserveObject(env);
  otel_span_kinds = R_getVar(Rf_install("span_kinds"), env, TRUE);
  otel_span_status_codes =
    R_getVar(Rf_install("span_status_codes"), env, TRUE);
  return R_NilValue;
}

SEXP create_empty_xptr(void ) {
  SEXP xptr = R_MakeExternalPtr(NULL, R_NilValue, R_NilValue);
  return xptr;
}
