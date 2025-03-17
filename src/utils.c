#include <string.h>

#include "Rinternals.h"

SEXP rf_get_list_element(SEXP list, const char *str) {
  SEXP elmt = R_NilValue;
  SEXP names = PROTECT(Rf_getAttrib(list, R_NamesSymbol));

  for (R_xlen_t i = 0; i < Rf_xlength(list); i++) {
    if (strcmp(CHAR(STRING_ELT(names, i)), str) == 0) {
       elmt = VECTOR_ELT(list, i);
       break;
    }
  }
  UNPROTECT(1);
  return elmt;
}
