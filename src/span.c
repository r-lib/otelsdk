#include <string.h>
#include <stdlib.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common.h"
#include "otel_common_r.h"

void r2c_attribute(
  const char *name, SEXP value, struct otel_attribute *attr);
void r2c_attributes(SEXP r, struct otel_attributes *c);

void otel_span_context_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid span context pointer.");
    return;
  }
  void *span_context_ = R_ExternalPtrAddr(x);
  if (span_context_) {
    otel_span_context_finally_(span_context_);
    R_ClearExternalPtr(x);
  }
}

void otel_span_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(x);
  if (span_) {
    otel_span_finally_(span_);
    R_ClearExternalPtr(x);
  }
}

void otel_scope_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid scope pointer.");
  }
  void *scope_ = R_ExternalPtrAddr(x);
  if (scope_) {
    otel_scope_finally_(scope_);
    R_ClearExternalPtr(x);
  }
}

SEXP otel_start_span(
    SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options,
    SEXP session) {

  if (TYPEOF(tracer) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid tracer pointer.");
  }
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
      SEXP linked_span = VECTOR_ELT(VECTOR_ELT(links, i), 0);
      if (TYPEOF(linked_span) != EXTPTRSXP) {
        Rf_error("OpenTelemetry: invalid span pointer to linked span.");
      }
      links_.a[i].span = R_ExternalPtrAddr(linked_span);
      SEXP attr = VECTOR_ELT(VECTOR_ELT(links, i), 1);
      r2c_attributes(attr, &links_.a[i].attr);
    }
  }

  void *parent_ = NULL;
  int is_root_span_ = 0;
  SEXP parent = rf_get_list_element(options, "parent");
  if (!Rf_isNull(parent)) {
    if (TYPEOF(parent) == LGLSXP && Rf_length(parent) == 1 &&
        LOGICAL(parent)[0] == NA_LOGICAL) {
      is_root_span_ = 1;
    } else {
      if (TYPEOF(parent) != EXTPTRSXP) {
        Rf_error("OpenTelemetry: invalid span pointer to parent span.");
      }
      parent_ = R_ExternalPtrAddr(parent);
    }
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
  void *span_ = otel_start_span_(
    tracer_,
    name_,
    &attributes_,
    &links_,
    start_system_time_,
    start_steady_time_,
    parent_,
    is_root_span_,
    span_kind_
  );
  SEXP res = PROTECT(R_MakeExternalPtr(span_, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(res, otel_span_finally, (Rboolean) 1);
  UNPROTECT(1);
  return res;
}

SEXP otel_get_active_span(SEXP tracer) {
  if (TYPEOF(tracer) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid tracer pointer.");
  }
  void *tracer_ = R_ExternalPtrAddr(tracer);
  if (!tracer_) {
    Rf_error("Opentelemetry tracer cleaned up already, internal error.");
  }

  void *span_ = otel_get_active_span_(tracer_);
  SEXP xptr = R_MakeExternalPtr(span_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_span_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_span_get_context(SEXP span) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(span);
  SEXP res = R_NilValue;
  if (span_) {
    void *span_context_ = otel_span_get_context_(span_);
    res = R_MakeExternalPtr(span_context_, R_NilValue, R_NilValue);
    R_RegisterCFinalizerEx(res, otel_span_context_finally, (Rboolean) 1);
  }
  return res;
}

SEXP otel_span_is_valid(SEXP span) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(span);
  int res = 0;
  if (span_) {
    res = otel_span_is_valid_(span_);
  }
  return Rf_ScalarLogical(res);
}

SEXP otel_span_is_recording(SEXP span) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(span);
  int res = 0;
  if (span_) {
    res = otel_span_is_recording_(span_);
  }
  return Rf_ScalarLogical(res);
}

SEXP otel_span_set_attribute(SEXP span, SEXP name, SEXP value) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(span);
  if (span_) {
    struct otel_attribute attr = { 0 };
    r2c_attribute(CHAR(STRING_ELT(name, 0)),value, &attr);
    otel_span_set_attribute_(span_, &attr);
    // TODO: cleancall
    otel_attribute_free(&attr);
  }
  return R_NilValue;
}

SEXP otel_span_add_event(
    SEXP span, SEXP name, SEXP attributes, SEXP timestamp) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
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
    // TODO: cleancall
    otel_attributes_free(&attributes_);
  }
  return R_NilValue;
}

// ABI v2
// SEXP otel_span_add_link(SEXP span, SEXP link) {
//   // TODO
//   return R_NilValue;
// }

SEXP otel_span_set_status(
    SEXP span, SEXP status_code, SEXP description) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
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

SEXP otel_span_update_name(SEXP span, SEXP name) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(span);
  if (span_) {
    const char *name_ = CHAR(STRING_ELT(name, 0));
    otel_span_update_name_(span_, name_);
  }
  return R_NilValue;
}

SEXP otel_span_end(
    SEXP span, SEXP options, SEXP status_code) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(span);
  if (span_) {
    if (!Rf_isNull(status_code)) {
      int status_code_ = INTEGER(status_code)[0];
      otel_span_set_status_(span_, status_code_, NULL);
    }
    double *end_steady_time_ = NULL;
    SEXP end_steady_time =
      rf_get_list_element(options, "end_steady_time");
    if (!Rf_isNull(end_steady_time)) {
      end_steady_time_ = REAL(end_steady_time);
    }
    otel_span_end_(span_, end_steady_time_);
  }
  return R_NilValue;
}

SEXP otel_scope_start(SEXP span) {
  if (TYPEOF(span) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span pointer.");
  }
  void *span_ = R_ExternalPtrAddr(span);
  if (!span_) {
    Rf_error("Cannot activate OpenTelemetry span, it already ended.");
  }
  void *scope_ = otel_scope_start_(span_);
  SEXP res = PROTECT(R_MakeExternalPtr(scope_, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(res, otel_scope_finally, (Rboolean) 1);
  UNPROTECT(1);
  return res;
}

SEXP otel_scope_end(SEXP scope) {
  if (TYPEOF(scope) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid scope pointer.");
  }
  void *scope_ = R_ExternalPtrAddr(scope);
  if (scope_) {
    otel_scope_end_(scope_);
    R_ClearExternalPtr(scope);
  }
  return R_NilValue;
}

SEXP otel_span_context_is_valid(SEXP span_context) {
  if (TYPEOF(span_context) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span context pointer.");
  }
  void *span_context_ = R_ExternalPtrAddr(span_context);
  int valid = otel_span_context_is_valid_(span_context_);
  return Rf_ScalarLogical(valid);
}

SEXP otel_span_context_get_trace_flags(SEXP span_context) {
  if (TYPEOF(span_context) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span context pointer.");
  }
  void *span_context_ = R_ExternalPtrAddr(span_context);
  int flags = otel_span_context_get_trace_flags_(span_context_);
  const char *trace_flags_names[] = { "is_sampled", "is_random", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, trace_flags_names));
  SET_VECTOR_ELT(res, 0, Rf_ScalarLogical(flags & 1));
  SET_VECTOR_ELT(res, 1, Rf_ScalarLogical(flags & 2));
  UNPROTECT(1);
  return res;
}

SEXP otel_span_context_get_trace_id(SEXP span_context) {
  if (TYPEOF(span_context) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span context pointer.");
  }
  void *span_context_ = R_ExternalPtrAddr(span_context);
  int idsize = otel_trace_id_size_() * 2;
  char *buf = malloc(idsize);
  if (!buf) {
    Rf_error("Out of memory when querying OpenTelemetry trace id");
  }
  otel_span_context_get_trace_id_(span_context_, buf);
  SEXP res = Rf_mkCharLen(buf, idsize);
  free(buf);
  return Rf_ScalarString(res);
}

SEXP otel_span_context_get_span_id(SEXP span_context) {
  if (TYPEOF(span_context) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span context pointer.");
  }
  void *span_context_ = R_ExternalPtrAddr(span_context);
  int idsize = otel_span_id_size_() * 2;
  char *buf = malloc(idsize);
  if (!buf) {
    Rf_error("Out of memory when querying OpenTelemetry span id");
  }
  otel_span_context_get_span_id_(span_context_, buf);
  SEXP res = Rf_mkCharLen(buf, idsize);
  free(buf);
  return Rf_ScalarString(res);
}

SEXP otel_span_context_is_remote(SEXP span_context) {
  if (TYPEOF(span_context) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span context pointer.");
  }
  void *span_context_ = R_ExternalPtrAddr(span_context);
  int remote = otel_span_context_is_remote_(span_context_);
  return Rf_ScalarLogical(remote);
}

SEXP otel_span_context_is_sampled(SEXP span_context) {
  if (TYPEOF(span_context) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span context pointer.");
  }
  void *span_context_ = R_ExternalPtrAddr(span_context);
  int sampled = otel_span_context_is_sampled_(span_context_);
  return Rf_ScalarLogical(sampled);
}

SEXP otel_span_context_to_headers(SEXP span_context) {
  if (TYPEOF(span_context) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid span context pointer.");
  }
  void *span_context_ = R_ExternalPtrAddr(span_context);
  struct otel_string traceparent = { NULL, 0 };
  struct otel_string tracestate = { NULL, 0 };

  otel_span_context_to_headers_(span_context_, &traceparent, &tracestate);
  if (!traceparent.s) {
    Rf_error("Cannot allocate memory for OpenTelemetry trace headers");
  }
  // TODO: this is a leak if the R API fails, need to use cleancall
  const char *nms[] = { "traceparent", "tracestate", "" };
  SEXP res = PROTECT(Rf_mkNamed(STRSXP, nms));
  SET_STRING_ELT(res, 0, Rf_mkCharLen(traceparent.s, traceparent.size));
  SET_STRING_ELT(res, 1, Rf_mkCharLen(tracestate.s, tracestate.size));
  free(traceparent.s);
  free(tracestate.s);
  UNPROTECT(1);
  return res;
}

SEXP otel_extract_http_context(SEXP headers) {
  const char *traceparent =
    Rf_isNull(VECTOR_ELT(headers, 0)) ? NULL :
    CHAR(STRING_ELT(VECTOR_ELT(headers, 0), 0));
  const char *tracestate =
    Rf_isNull(VECTOR_ELT(headers, 1)) ? NULL :
    CHAR(STRING_ELT(VECTOR_ELT(headers, 1), 0));
  void *span_context_ = otel_extract_http_context_(traceparent, tracestate);
  SEXP xptr = PROTECT(R_MakeExternalPtr(span_context_, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(xptr, otel_span_context_finally, (Rboolean) 1);
  UNPROTECT(1);
  return xptr;
}
