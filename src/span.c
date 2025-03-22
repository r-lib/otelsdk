#include <string.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common.h"

SEXP rf_get_list_element(SEXP list, const char *str);

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
    SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options) {

  void *tracer_ = R_ExternalPtrAddr(tracer);
  if (!tracer_) {
    Rf_error("Opentelemetry tracer cleaned up already, internal error.");
  }

  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);

  struct otel_links links_ = { NULL, 0 };
  links_.count = Rf_length(links);
  if (links_.count > 0) {
    links_.a = (struct otel_link*)
      R_alloc(links_.count, sizeof(struct otel_link));
    for (R_len_t i = 0; i < links_.count; i++) {
      SEXP scoped_span = VECTOR_ELT(VECTOR_ELT(links, i), 0);
      SEXP linked_span = VECTOR_ELT(scoped_span, 0);
      links_.a[i].span = R_ExternalPtrAddr(linked_span);
      SEXP attr = VECTOR_ELT(VECTOR_ELT(links, i), 1);
      r2c_attributes(attr, &links_.a[i].attr);
    }
  }

  void *parent_ = NULL;
  SEXP parent = rf_get_list_element(options, "parent");
  if (!Rf_isNull(parent)) {
    parent_ = R_ExternalPtrAddr(parent);
  }
  double *start_system_time_ = NULL;
  SEXP start_system_time =
    rf_get_list_element(options, "start_system_time");
  if (!Rf_isNull(start_system_time)) {
    start_system_time_ = REAL(start_system_time);
  }
  double *start_steady_time_ = NULL;
  SEXP start_steady_time =
    rf_get_list_element(options, "start_steady_time");
  if (!Rf_isNull(start_steady_time)) {
    start_steady_time_ = REAL(start_steady_time);
  }
  SEXP span_kind = rf_get_list_element(options, "kind");
  int span_kind_ = INTEGER(span_kind)[0];

  const char *name_ = CHAR(STRING_ELT(name, 0));
  struct otel_scoped_span sspan = otel_start_span_(
    tracer_,
    name_,
    &attributes_,
    &links_,
    start_system_time_,
    start_steady_time_,
    parent_,
    span_kind_
  );
  SEXP res = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(res, 0, R_MakeExternalPtr(sspan.span, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(VECTOR_ELT(res, 0), otel_span_finally, (Rboolean) 1);
  SET_VECTOR_ELT(res, 1, R_MakeExternalPtr(sspan.scope, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(VECTOR_ELT(res, 1), otel_scope_finally, (Rboolean) 1);
  UNPROTECT(1);
  return res;
}

// TODO: maybe we don't need to get the context explicitly
// SEXP otel_span_get_context(SEXP span) {
//   // TODO
//   return R_NilValue;
// }

SEXP otel_span_is_recording(SEXP scoped_span) {
  SEXP span = VECTOR_ELT(scoped_span, 0);
  void *span_ = R_ExternalPtrAddr(span);
  int res = 0;
  if (span_) {
    res = otel_span_is_recording_(span_);
  }
  return Rf_ScalarLogical(res);
}

SEXP otel_span_set_attribute(SEXP scoped_span, SEXP name, SEXP value) {
  SEXP span = VECTOR_ELT(scoped_span, 0);
  void *span_ = R_ExternalPtrAddr(span);
  if (span_) {
    struct otel_attribute attr;
    r2c_attribute(CHAR(STRING_ELT(name, 0)),value, &attr);
    otel_span_set_attribute_(span_, &attr);
  }
  return R_NilValue;
}

SEXP otel_span_add_event(
    SEXP scoped_span, SEXP name, SEXP attributes, SEXP timestamp) {
  SEXP span = VECTOR_ELT(scoped_span, 0);
  void *span_ = R_ExternalPtrAddr(span);
  if (span_) {
    const char *name_ = CHAR(STRING_ELT(name, 0));
    struct otel_attributes attributes_;
    r2c_attributes(attributes, &attributes_);
    void *timestamp_ = NULL;
    if (!Rf_isNull(timestamp)) {
      timestamp_ = REAL(timestamp);
    }
    otel_span_add_event_(span_, name_, &attributes_, timestamp_);
  }
  return R_NilValue;
}

// ABI v2
// SEXP otel_span_add_link(SEXP span, SEXP link) {
//   // TODO
//   return R_NilValue;
// }

SEXP otel_span_set_status(
    SEXP scoped_span, SEXP status_code, SEXP description) {
  SEXP span = VECTOR_ELT(scoped_span, 0);
  void *span_ = R_ExternalPtrAddr(span);
  if (span_) {
    int status_code_ = INTEGER(status_code)[0];
    char *description_ = NULL;
    if (!Rf_isNull(description)) {
      description_ = (char*) CHAR(STRING_ELT(description, 0));
    }
    otel_span_set_status_(span_, status_code_, description_);
  }
  return R_NilValue;
}

SEXP otel_span_update_name(SEXP scoped_span, SEXP name) {
  SEXP span = VECTOR_ELT(scoped_span, 0);
  void *span_ = R_ExternalPtrAddr(span);
  if (span_) {
    const char *name_ = CHAR(STRING_ELT(name, 0));
    otel_span_update_name_(span_, name_);
  }
  return R_NilValue;
}

SEXP otel_span_end(SEXP scoped_span, SEXP options) {
  SEXP span = VECTOR_ELT(scoped_span, 0);
  SEXP scope = VECTOR_ELT(scoped_span, 1);
  void *span_ = R_ExternalPtrAddr(span);
  void *scope_ = R_ExternalPtrAddr(scope);
  if (span_ && scope_) {
    double *end_steady_time_ = NULL;
    SEXP end_steady_time =
      rf_get_list_element(options, "end_steady_time");
    if (!Rf_isNull(end_steady_time)) {
      end_steady_time_ = REAL(end_steady_time);
    }
    otel_span_end_(span_, scope_, end_steady_time_);
    R_ClearExternalPtr(scope);
  }
  return R_NilValue;
}
