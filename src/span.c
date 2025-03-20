#include <string.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common.h"

void otel_span_finally(SEXP x) {
  void *span_ = R_ExternalPtrAddr(x);
  if (span_) {
    otel_span_finally_(span_);
    R_ClearExternalPtr(x);
  }
}

void otel_scope_finally(SEXP x) {
  void *scope_ = R_ExternalPtrAddr(x);
  if (scope_) {
    otel_span_finally_(scope_);
    R_ClearExternalPtr(x);
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

SEXP otel_start_span(
  SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options,
  SEXP parent) {

  void *tracer_ = R_ExternalPtrAddr(tracer);
  if (!tracer_) {
    Rf_error("Opentelemetry tracer cleaned up already, internal error.");
  }
  void *parent_ = NULL;
  if (!Rf_isNull(parent)) {
    parent_ = R_ExternalPtrAddr(parent);
  }

  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);

  // TODO: links
  // TODO: rest of options

  const char *name_ = CHAR(STRING_ELT(name, 0));
  struct otel_scoped_span sspan = otel_start_span_(
    tracer_,
    name_,
    &attributes_,
    parent_
  );
  SEXP res = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(res, 0, R_MakeExternalPtr(sspan.span, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(VECTOR_ELT(res, 0), otel_span_finally, (Rboolean) 1);
  SET_VECTOR_ELT(res, 1, R_MakeExternalPtr(sspan.scope, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(VECTOR_ELT(res, 1), otel_scope_finally, (Rboolean) 1);
  UNPROTECT(1);
  return res;
}

SEXP otel_span_get_context(SEXP span) {
  // TODO
  return R_NilValue;
}

SEXP otel_span_is_recording(SEXP span) {
  // TODO
  return R_NilValue;
}

SEXP otel_span_set_attribute(SEXP span, SEXP name, SEXP value) {
  // TODO
  return R_NilValue;
}

SEXP otel_span_add_event(
  SEXP span, SEXP name, SEXP attributes, SEXP timestamp
) {
  // TODO
  return R_NilValue;
}

// ABI v2
// SEXP otel_span_add_link(SEXP span, SEXP link) {
//   // TODO
//   return R_NilValue;
// }

SEXP otel_span_set_status(SEXP span, SEXP status_code, SEXP description) {
  // TODO
  return R_NilValue;
}

SEXP otel_span_update_name(SEXP span, SEXP name) {
  // TODO
  return R_NilValue;
}

SEXP otel_span_end(SEXP scoped_span, SEXP options) {
  // TODO: options
  SEXP span = VECTOR_ELT(scoped_span, 0);
  SEXP scope = VECTOR_ELT(scoped_span, 1);
  void *span_ = R_ExternalPtrAddr(span);
  void *scope_ = R_ExternalPtrAddr(scope);
  if (span_ && scope_) {
    otel_span_end_(span_, scope_);
    R_ClearExternalPtr(scope);
  }
  return R_NilValue;
}
