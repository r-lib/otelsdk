#include <string.h>
#include <stdlib.h>

#include "Rinternals.h"

#include "otel_common.h"

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

SEXP rf_otel_string_to_strsxp(const struct otel_string *s) {
  SEXP cxp = PROTECT(Rf_mkCharLen(s->s, s->size));
  SEXP res = Rf_ScalarString(cxp);
  UNPROTECT(1);
  return res;
}

void r2c_attribute(
  const char *name, SEXP value, struct otel_attribute *attr) {

  attr->name = name;
  R_len_t l = Rf_length(value);
  switch (TYPEOF(value)) {
    case STRSXP:
      if (l == 1) {
        attr->type = k_string;
        attr->val.string.s = (char*) CHAR(STRING_ELT(value, 0));
        attr->val.string.size = strlen(attr->val.string.s);
      } else {
        attr->type = k_string_array;
        attr->val.string_array.a = (char**) R_alloc(l, sizeof(char*));
        for (R_len_t i = 0; i < l; i++) {
          attr->val.string_array.a[i] = (char*) CHAR(STRING_ELT(value, i));
        }
        attr->val.string_array.count = l;
      }
      break;
    case LGLSXP:
      if (l == 1) {
        attr->type = k_boolean;
        attr->val.boolean = LOGICAL(value)[0];
      } else {
        attr->type = k_boolean_array;
        attr->val.boolean_array.a = LOGICAL(value);
        attr->val.boolean_array.count = l;
      }
      break;
    case REALSXP:
      if (l == 1) {
        attr->type = k_double;
        attr->val.dbl = REAL(value)[0];
      } else {
        attr->type = k_double_array;
        attr->val.dbl_array.a = REAL(value);
        attr->val.dbl_array.count = l;
      }
      break;
    case INTSXP:
      if (l == 1) {
        attr->type = k_int64;
        attr->val.int64 = INTEGER(value)[0];
      } else {
        attr->type = k_int64_array;
        attr->val.int64_array.a = (int64_t*) R_alloc(l, sizeof(int64_t));
        for (R_len_t i = 0; i < l; i++) {
          attr->val.int64_array.a[i] = INTEGER(value)[i];
        }
        attr->val.int64_array.count = l;
      }
      break;
    default:
      Rf_error("Unknown OpenTelemetry attribute type: %d.", TYPEOF(value));
      break;
  }
}

void r2c_attributes(SEXP r, struct otel_attributes *c) {
  c->count = Rf_length(r);
  if (c->count == 0) {
    c->a = NULL;
    return;
  }

  c->a = (struct otel_attribute *)
    R_alloc(c->count, sizeof(struct otel_attribute));
  SEXP nms = Rf_getAttrib(r, R_NamesSymbol);
  for (R_len_t i = 0; i < c->count; i++) {
    r2c_attribute(CHAR(STRING_ELT(nms, i)), VECTOR_ELT(r, i), c->a + i);
  }
}

void otel_string_free(struct otel_string *s) {
  if (s->s) {
    free(s->s);
    s->s = NULL;
  }
  s->size = 0;
}

void otel_instrumentation_scope_free(
  struct otel_instrumentation_scope_t *is) {
    if (!is) return;
    otel_string_free(&is->name);
    otel_string_free(&is->version);
    otel_string_free(&is->schema_url);
  }

void otel_span_data_free(struct otel_span_data_t *cdata) {
  if (!cdata) {
    if (!cdata->a) {
      for (int i = 0; i < cdata->count; i++) {
        struct otel_span_data1_t *xi = &cdata->a[i];
        otel_string_free(&xi->trace_id);
        otel_string_free(&xi->span_id);
        otel_string_free(&xi->parent);
        otel_string_free(&xi->name);
        otel_string_free(&xi->description);
        otel_string_free(&xi->schema_url);
        otel_instrumentation_scope_free(&xi->instrumentation_scope);
        if (xi->description.s) {
          free(xi->description.s);
          xi->description.s = NULL;
          xi->description.size = 0;
        }
      }
      free(cdata->a);
      cdata->a = NULL;
      cdata->count = 0;
    }
    free(cdata);
  }
}

SEXP c2r_otel_trace_flags(const struct otel_trace_flags_t *flags) {
  const char *nms[] = { "sampled", "random", "" };
  SEXP res = Rf_mkNamed(LGLSXP, nms);
  LOGICAL(res)[0] = flags->is_sampled;
  LOGICAL(res)[1] = flags->is_random;
  return res;
}

SEXP c2r_otel_instrumentation_scope(
    const struct otel_instrumentation_scope_t *is) {
  const char *nms[] = { "name", "version", "schema_url", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, rf_otel_string_to_strsxp(&is->name));
  SET_VECTOR_ELT(res, 1, rf_otel_string_to_strsxp(&is->version));
  SET_VECTOR_ELT(res, 2, rf_otel_string_to_strsxp(&is->schema_url));
  Rf_setAttrib(
    res, R_ClassSymbol, Rf_mkString("otel_instrumentation_scope_data"));
  UNPROTECT(1);
  return res;
}
