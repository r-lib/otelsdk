#include <string.h>
#include <stdlib.h>

#include "Rinternals.h"

#include "otel_common.h"

void otel_string_free(struct otel_string *s) {
  if (!s) return;
  if (s->s) {
    free(s->s);
    s->s = NULL;
  }
  s->size = 0;
}

SEXP c2r_otel_string(const struct otel_string *s) {
  SEXP res = PROTECT(Rf_allocVector(STRSXP, 1));
  SET_STRING_ELT(res, 0, Rf_mkCharLenCE(s->s, s->size, CE_UTF8));
  UNPROTECT(1);
  return res;
}

SEXP c2r_otel_strings(const struct otel_strings *s) {
  SEXP res = PROTECT(Rf_allocVector(STRSXP, s->count));
  for (R_xlen_t i = 0; i < s->count; i++) {
    SET_STRING_ELT(res, i, c2r_otel_string(&s->a[i]));
  }
  UNPROTECT(1);
  return res;
}

SEXP c2r_otel_named_strings(const struct otel_strings *s) {
  R_xlen_t s2 = s->count;
  SEXP res = PROTECT(Rf_allocVector(STRSXP, s2 / 2));
  SEXP nms = PROTECT(Rf_allocVector(STRSXP, s2 / 2));
  R_xlen_t ii = 0, oi = 0;
  for (; ii < s2; ) {
    SET_STRING_ELT(res, oi, c2r_otel_string(&s->a[ii]));
    ii++;
    SET_STRING_ELT(nms, oi, c2r_otel_string(&s->a[ii]));
    ii++; oi++;
  }
  Rf_setAttrib(res, R_NamesSymbol, nms);
  UNPROTECT(2);
  return res;
}

void otel_instrumentation_scope_free(
    struct otel_instrumentation_scope_t *is) {
  if (!is) return;
  otel_string_free(&is->name);
  otel_string_free(&is->version);
  otel_string_free(&is->schema_url);
}

SEXP c2r_otel_instrumentation_scope(
    const struct otel_instrumentation_scope_t *is) {
  const char *nms[] = { "name", "version", "schema_url", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_string(&is->name));
  SET_VECTOR_ELT(res, 1, c2r_otel_string(&is->version));
  SET_VECTOR_ELT(res, 2, c2r_otel_string(&is->schema_url));
  Rf_setAttrib(
    res, R_ClassSymbol, Rf_mkString("otel_instrumentation_scope_data"));
  UNPROTECT(1);
  return res;
}

void otel_span_data_free(struct otel_span_data_t *cdata) {
  if (cdata) {
    if (cdata->a) {
      for (int i = 0; i < cdata->count; i++) {
        struct otel_span_data1_t *xi = &cdata->a[i];
        otel_string_free(&xi->trace_id);
        otel_string_free(&xi->span_id);
        otel_string_free(&xi->parent);
        otel_string_free(&xi->name);
        otel_string_free(&xi->description);
        otel_string_free(&xi->schema_url);
        otel_attributes_free(&xi->resource_attributes);
        otel_instrumentation_scope_free(&xi->instrumentation_scope);
        if (xi->description.s) {
          free(xi->description.s);
          xi->description.s = NULL;
          xi->description.size = 0;
        }
        otel_attributes_free(&xi->attributes);
        otel_events_free(&xi->events);
      }
      free(cdata->a);
      cdata->a = NULL;
      cdata->count = 0;
    }
  }
}

SEXP c2r_otel_trace_flags(const struct otel_trace_flags_t *flags) {
  const char *nms[] = { "sampled", "random", "" };
  SEXP res = Rf_mkNamed(LGLSXP, nms);
  LOGICAL(res)[0] = flags->is_sampled;
  LOGICAL(res)[1] = flags->is_random;
  return res;
}

void otel_string_array_free(struct otel_string_array *a) {
  if (!a) return;
  if (a->storage) {
    free(a->storage);
    a->storage = NULL;
  }
  if (a->a) {
    free(a->a);
    a->a = NULL;
  }
  a->count = 0;
}

void otel_boolean_array_free(struct otel_boolean_array *a) {
  if (!a) return;
  if (a->a) {
    free(a->a);
    a->a = NULL;
  }
  a->count = 0;
}

void otel_double_array_free(struct otel_double_array *a) {
  if (!a) return;
  if (a->a) {
    free(a->a);
    a->a = NULL;
  }
  a->count = 0;
}

void otel_int64_array_free(struct otel_int64_array *a) {
  if (!a) return;
  if (a->a) {
    free(a->a);
    a->a = NULL;
  }
  a->count = 0;
}

void otel_attribute_free(struct otel_attribute *attr) {
  if (!attr) return;
  if (attr->name) {
    free((void*) attr->name);
    attr->name = NULL;
  }
  switch (attr->type) {
    case k_string:
      otel_string_free(&attr->val.string);
      break;
    case k_boolean:
    case k_double:
    case k_int64:
      // nothing to do;
      break;
    case k_string_array:
      otel_string_array_free(&attr->val.string_array);
      break;
    case k_boolean_array:
      otel_boolean_array_free(&attr->val.boolean_array);
      break;
    case k_double_array:
      otel_double_array_free(&attr->val.dbl_array);
      break;
    case k_int64_array:
      otel_int64_array_free(&attr->val.int64_array);
      break;
    default:
      break;
  }
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
        attr->val.string_array.a = (char**) malloc(l * sizeof(char*));
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
        attr->val.int64_array.a = (int64_t*) malloc(l * sizeof(int64_t));
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

void otel_attributes_free(struct otel_attributes *attrs) {
  if (!attrs) return;
  if (attrs->a) {
    for (size_t i = 0; i < attrs->count; i++) {
      otel_attribute_free(&attrs->a[i]);
    }
    free(attrs->a);
    attrs->a = NULL;
  }
  attrs->count = 0;
}

void r2c_attributes(SEXP r, struct otel_attributes *c) {
  c->count = Rf_length(r);
  if (c->count == 0) {
    c->a = NULL;
    return;
  }

  c->a = (struct otel_attribute *)
    malloc(c->count * sizeof(struct otel_attribute));
  SEXP nms = Rf_getAttrib(r, R_NamesSymbol);
  for (R_len_t i = 0; i < c->count; i++) {
    r2c_attribute(CHAR(STRING_ELT(nms, i)), VECTOR_ELT(r, i), c->a + i);
  }
}

SEXP c2r_otel_attribute(const struct otel_attribute *attr) {
  SEXP res = R_NilValue;
  switch (attr->type) {
    case k_string:
      return Rf_ScalarString(Rf_mkCharLenCE(
        attr->val.string.s, attr->val.string.size, CE_UTF8));
      break;
    case k_boolean:
      return Rf_ScalarLogical(attr->val.boolean);
      break;
    case k_double:
      return Rf_ScalarReal(attr->val.dbl);
      break;
    case k_int64:
      return Rf_ScalarReal(attr->val.int64);
      break;
    case k_string_array:
      res = PROTECT(Rf_allocVector(STRSXP, attr->val.string_array.count));
      for (size_t i = 0; i < attr->val.string_array.count; i++) {
        const char *pi = attr->val.string_array.a[i];
        size_t l = strlen(pi);
        SET_STRING_ELT(res, i, Rf_mkCharLenCE(pi, l, CE_UTF8));
      }
      UNPROTECT(1);
      return res;
      break;
    case k_boolean_array:
      res = PROTECT(Rf_allocVector(LGLSXP, attr->val.boolean_array.count));
      memcpy(
        LOGICAL(res),
        attr->val.boolean_array.a,
        attr->val.boolean_array.count * sizeof(int)
      );
      UNPROTECT(1);
      return res;
      break;
    case k_double_array:
      res = PROTECT(Rf_allocVector(REALSXP, attr->val.dbl_array.count));
      memcpy(
        REAL(res),
        attr->val.dbl_array.a,
        attr->val.dbl_array.count * sizeof(double)
      );
      UNPROTECT(1);
      return res;
      break;
    case k_int64_array:
      res = PROTECT(Rf_allocVector(REALSXP, attr->val.int64_array.count));
      for (size_t i = 0; i < attr->val.int64_array.count; i++) {
        REAL(res)[i] = attr->val.int64_array.a[i];
      }
      UNPROTECT(1);
      return res;
      break;
    default:
      return R_NilValue;
      break;
  }
  return R_NilValue;
}

SEXP c2r_otel_attributes(const struct otel_attributes *attrs) {
  R_xlen_t nattrs = attrs->count;
  SEXP res = PROTECT(Rf_allocVector(VECSXP, nattrs));
  SEXP nms = PROTECT(Rf_allocVector(STRSXP, nattrs));
  for (R_xlen_t i = 0; i < nattrs; i++) {
    SET_VECTOR_ELT(res, i, c2r_otel_attribute(&attrs->a[i]));
    SET_STRING_ELT(nms, i, Rf_mkCharCE(attrs->a[i].name, CE_UTF8));
  }
  Rf_setAttrib(res, R_NamesSymbol, nms);

  UNPROTECT(2);
  return res;
}

void otel_event_free(struct otel_event *event) {
  if (!event) return;
  otel_string_free(&event->name);
  otel_attributes_free(&event->attributes);
}

void otel_events_free(struct otel_events *events) {
  if (!events) return;
  if (events->a) {
    for (size_t i = 0; i < events->count; i++) {
      otel_event_free(&events->a[i]);
    }
    free(events->a);
    events->a = NULL;
  }
  events->count = 0;
}

SEXP c2r_otel_events(const struct otel_events *events) {
  R_xlen_t nevents = events->count;
  SEXP res = PROTECT(Rf_allocVector(VECSXP, nevents));
  const char *evnms[] = { "name", "timestamp", "attributes", "" };
  SEXP posix_class = PROTECT(R_NilValue);
  if (events->count > 0) {
    UNPROTECT(1);
    posix_class = PROTECT(Rf_allocVector(STRSXP, 2));
    SET_STRING_ELT(posix_class, 0, Rf_mkChar("POSIXct"));
    SET_STRING_ELT(posix_class, 1, Rf_mkChar("POSIXt"));
  }
  for (R_xlen_t i = 0; i < nevents; i++) {
    SEXP ev = PROTECT(Rf_mkNamed(VECSXP, evnms));
    SET_VECTOR_ELT(ev, 0, c2r_otel_string(&events->a[i].name));
    SET_VECTOR_ELT(ev, 1, Rf_ScalarReal(events->a[i].timestamp));
    Rf_setAttrib(VECTOR_ELT(ev, 1), R_ClassSymbol, posix_class);
    SET_VECTOR_ELT(ev, 2, c2r_otel_attributes(&events->a[i].attributes));
    SET_VECTOR_ELT(res, i, ev);
    UNPROTECT(1);
  }

  UNPROTECT(2);
  return res;
}
