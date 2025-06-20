#include <string.h>
#include <stdlib.h>

#include "Rinternals.h"

#include "otel_common.h"
#include "otel_common_r.h"
#include "errors.h"

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
    struct otel_instrumentation_scope *is) {
  if (!is) return;
  otel_string_free(&is->name);
  otel_string_free(&is->version);
  otel_string_free(&is->schema_url);
  otel_attributes_free(&is->attributes);
}

SEXP c2r_otel_instrumentation_scope(
    const struct otel_instrumentation_scope *is) {
  const char *nms[] = { "name", "version", "schema_url", "attributes", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_string(&is->name));
  SET_VECTOR_ELT(res, 1, c2r_otel_string(&is->version));
  SET_VECTOR_ELT(res, 2, c2r_otel_string(&is->schema_url));
  SET_VECTOR_ELT(res, 3, c2r_otel_attributes(&is->attributes));
  Rf_setAttrib(
    res, R_ClassSymbol, Rf_mkString("otel_instrumentation_scope_data"));
  UNPROTECT(1);
  return res;
}

void otel_span_data_free(struct otel_span_data *cdata) {
  if (cdata) {
    if (cdata->a) {
      for (int i = 0; i < cdata->count; i++) {
        struct otel_span_data1 *xi = &cdata->a[i];
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

SEXP c2r_otel_trace_flags(const struct otel_trace_flags *flags) {
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

SEXP c2r_otel_double_array(const struct otel_double_array *a) {
  SEXP res = Rf_allocVector(REALSXP, a->count);
  memcpy(REAL(res), a->a, sizeof(double) * a->count);
  return res;
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

void r2c_file_exporter_options(
    SEXP options, struct otel_file_exporter_options *coptions) {
  SEXP file_pattern = rf_get_list_element(options, "file_pattern");
  coptions->file_pattern =
    Rf_isNull(file_pattern) ? NULL : CHAR(STRING_ELT(file_pattern, 0));
  SEXP alias_pattern = rf_get_list_element(options, "alias_pattern");
  coptions->alias_pattern =
    Rf_isNull(alias_pattern) ? NULL : CHAR(STRING_ELT(alias_pattern, 0));
  SEXP flush_interval = rf_get_list_element(options, "flush_interval");
  coptions->flush_interval =
    Rf_isNull(flush_interval) ? NULL : REAL(flush_interval);
  SEXP flush_count = rf_get_list_element(options, "flush_count");
  coptions->flush_count = Rf_isNull(flush_count) ? NULL : INTEGER(flush_count);
  SEXP file_size = rf_get_list_element(options, "file_size");
  coptions->file_size = Rf_isNull(file_size) ? NULL : REAL(file_size);
  SEXP rotate_size = rf_get_list_element(options, "rotate_size");
  coptions->rotate_size = Rf_isNull(rotate_size) ? NULL : INTEGER(rotate_size);
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

void otel_span_link_free(struct otel_span_link *link) {
  if (!link) return;
  otel_string_free(&link->trace_id);
  otel_string_free(&link->span_id);
  otel_attributes_free(&link->attributes);
}

void otel_span_links_free(struct otel_span_links *links) {
  if (!links) return;
  if (links->a) {
    for (size_t i = 0; i < links->count; i++) {
      otel_span_link_free(&links->a[i]);
    }
    free(links->a);
    links->a = NULL;
  }
  links->count = 0;
}

SEXP c2r_otel_span_links(const struct otel_span_links *links) {
  R_xlen_t nlinks = links->count;
  SEXP res = PROTECT(Rf_allocVector(VECSXP, nlinks));
  const char *lnknms[] = { "trace_id", "span_id", "attributes", "" };
  for (R_xlen_t i = 0; i < nlinks; i++) {
    SEXP lnk = PROTECT(Rf_mkNamed(VECSXP, lnknms));
    SET_VECTOR_ELT(lnk, 0, c2r_otel_string(&links->a[i].trace_id));
    SET_VECTOR_ELT(lnk, 1, c2r_otel_string(&links->a[i].span_id));
    SET_VECTOR_ELT(lnk, 2, c2r_otel_attributes(&links->a[i].attributes));
    SET_VECTOR_ELT(res, i, lnk);
    UNPROTECT(1);
  }

  UNPROTECT(1);
  return res;
}

void otel_sum_point_data_free(struct otel_sum_point_data *d) {
  if (!d) return;
  // nothing to do here
}

void otel_histogram_point_data_free(struct otel_histogram_point_data *d) {
  if (!d) return;
  otel_double_array_free(&d->boundaries);
  otel_double_array_free(&d->counts);
}

void otel_last_value_point_data_free(struct otel_last_value_point_data *d) {
  if (!d) return;
  // nothing to do here
}

void otel_drop_point_data_free(struct otel_drop_point_data *d) {
  if (!d) return;
  // nothing to do here
}

void otel_point_data_attributes_free(struct otel_point_data_attributes *pda) {
  if (!pda) return;
  otel_attributes_free(&pda->attributes);
  switch (pda->point_type) {
    case k_sum_point_data:
      otel_sum_point_data_free(&pda->value.sum_point_data);
      break;
    case k_histogram_point_data:
      otel_histogram_point_data_free(&pda->value.histogram_point_data);
      break;
    case k_last_value_point_data:
      otel_last_value_point_data_free(&pda->value.last_value_point_data);
      break;
    case k_drop_point_data:
      otel_drop_point_data_free(&pda->value.drop_point_data);
      break;
    default:
      break;
  }
}

void otel_metric_data_free(struct otel_metric_data *d) {
  if (!d) return;
  otel_string_free(&d->instrument_name);
  otel_string_free(&d->instrument_description);
  otel_string_free(&d->instrument_unit);
  if (d->point_data_attr) {
    for (size_t i = 0; i < d->count; i++) {
      otel_point_data_attributes_free(&d->point_data_attr[i]);
    }
    free(d->point_data_attr);
    d->point_data_attr = NULL;
  }
  d->count = 0;
}

void otel_scope_metrics_free(struct otel_scope_metrics *sm) {
  if (!sm) return;
  otel_instrumentation_scope_free(&sm->instrumentation_scope);
  if (sm->metric_data) {
    for (size_t i = 0; i < sm->count; i++) {
      otel_metric_data_free(&sm->metric_data[i]);
    }
    free(sm->metric_data);
    sm->metric_data = NULL;
  }
  sm->count = 0;
}

void otel_resource_metrics_free(struct otel_resource_metrics *rm) {
  if (!rm) return;
  otel_attributes_free(&rm->attributes);
  if (rm->scope_metric_data) {
    for (size_t i = 0; i < rm->count; i++) {
      otel_scope_metrics_free(&rm->scope_metric_data[i]);
    }
    free(rm->scope_metric_data);
    rm->scope_metric_data = NULL;
  }
  rm->count = 0;
}

void otel_metrics_data_free(struct otel_metrics_data *cdata) {
  if (!cdata) return;
  if (cdata->a) {
    for (size_t i = 0; i < cdata->count; i++) {
      otel_resource_metrics_free(&cdata->a[i]);
    }
    free(cdata->a);
    cdata->a = NULL;
  }
  cdata->count = 0;
}

SEXP c2r_otel_instrument_value_type(
    enum otel_instrument_value_type type, union otel_instrument_value *v) {
  double value = NA_REAL;
  switch (type) {
    case k_value_type_int:
      value = v->intval;
      break;
    case k_value_type_long:
      value = v->longval;
      break;
    case k_value_type_float:
      value = v->floatval;
      break;
    case k_value_type_double:
      value = v->doubleval;
      break;
    default:
      break;
  }
  return Rf_ScalarReal(value);
}

SEXP c2r_otel_value(enum otel_value_type type, union otel_value *v) {
  double value = NA_REAL;
  switch (type) {
    case k_value_int64:
      value = v->int64;
      break;
    case k_value_double:
      value = v->dbl;
      break;
    default:
      break;
  }
  return Rf_ScalarReal(value);
}

const char *otel_value_type_names[] = { "int64", "double" };
const size_t otel_value_type_names_size = 2;

SEXP c2r_otel_value_type(enum otel_value_type t) {
  if (t >= otel_value_type_names_size) {
    R_THROW_ERROR("Internal OpenTelemetry error, unknown value type");
  }
  return mkString(otel_value_type_names[t]);
}

SEXP c2r_otel_sum_point_data(struct otel_sum_point_data *d) {
  const char *nms[] = { "value_type", "value", "is_monotonic", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_value_type(d->value_type));
  SET_VECTOR_ELT(res, 1, c2r_otel_value(d->value_type, &d->value));
  SET_VECTOR_ELT(res, 2, Rf_ScalarLogical(d->is_monotonic));
  SEXP cls = PROTECT(Rf_mkString("otel_sum_point_data"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(2);
  return res;
}

SEXP c2r_otel_histogram_point_data(struct otel_histogram_point_data *d) {
  const char *nms[] = {
    "boundaries", "value_type", "sum", "min", "max", "counts", "count",
    "record_min_max", ""
  };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_double_array(&d->boundaries));
  SET_VECTOR_ELT(res, 1, c2r_otel_value_type(d->value_type));
  SET_VECTOR_ELT(res, 2, c2r_otel_value(d->value_type, &d->sum));
  SET_VECTOR_ELT(res, 3, c2r_otel_value(d->value_type, &d->min));
  SET_VECTOR_ELT(res, 4, c2r_otel_value(d->value_type, &d->max));
  SET_VECTOR_ELT(res, 5, c2r_otel_double_array(&d->counts));
  SET_VECTOR_ELT(res, 6, Rf_ScalarInteger(d->count));
  SET_VECTOR_ELT(res, 7, Rf_ScalarLogical(d->record_min_max));
  SEXP cls = PROTECT(Rf_mkString("otel_histogram_point_data"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(2);
  return res;
}

SEXP c2r_otel_last_value_point_data(struct otel_last_value_point_data *d) {
  const char *nms[] = {
    "value_type", "value", "is_lastvalue_valid", "sample_ts", ""
  };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_value_type(d->value_type));
  SET_VECTOR_ELT(res, 1, c2r_otel_value(d->value_type, &d->value));
  SET_VECTOR_ELT(res, 2, Rf_ScalarLogical(d->is_lastvalue_valid));
  SET_VECTOR_ELT(res, 3, Rf_ScalarReal(d->sample_ts));
  SEXP posix_class = PROTECT(Rf_allocVector(STRSXP, 2));
  SET_STRING_ELT(posix_class, 0, Rf_mkChar("POSIXct"));
  SET_STRING_ELT(posix_class, 1, Rf_mkChar("POSIXt"));
  Rf_setAttrib(VECTOR_ELT(res, 3), R_ClassSymbol, posix_class);
  SEXP cls = PROTECT(Rf_mkString("otel_last_value_point_data"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(3);
  return res;
}

SEXP c2r_otel_drop_point_data(struct otel_drop_point_data *d) {
  // no real data here
  const char *nms[] = { "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SEXP cls = PROTECT(Rf_mkString("otel_drop_point_data"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(2);
  return R_NilValue;
}

const char *otel_point_type_names[4] = {
  "sum_point_data", "histogram_point_data", "last_value_point_data",
  "drop_point_data"
};

SEXP c2r_otel_point_data_attributes(struct otel_point_data_attributes *pda) {
  const char *nms[] = { "attributes", "point_type", "value", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_attributes(&pda->attributes));
  if (pda->point_type >= sizeof(otel_point_type_names) / sizeof(const char *)) {
    R_THROW_ERROR(
      "Internal OpenTelemetry error, invalid otel_point_data_attributes "
      "point_type"
    );
  }
  SET_VECTOR_ELT(res, 1, Rf_mkString(otel_point_type_names[pda->point_type]));
  switch (pda->point_type) {
    case k_sum_point_data:
      SET_VECTOR_ELT(
        res, 2,
        c2r_otel_sum_point_data(&pda->value.sum_point_data)
      );
      break;
    case k_histogram_point_data:
      SET_VECTOR_ELT(
        res, 2,
        c2r_otel_histogram_point_data(&pda->value.histogram_point_data)
      );
      break;
    case k_last_value_point_data:
      SET_VECTOR_ELT(
        res, 2,
        c2r_otel_last_value_point_data(&pda->value.last_value_point_data)
      );
      break;
    case k_drop_point_data:
      SET_VECTOR_ELT(
        res, 2,
        c2r_otel_drop_point_data(&pda->value.drop_point_data)
      );
      break;
    default:
      break;
  }

  SEXP cls = PROTECT(Rf_mkString("otel_point_data_attributes"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(2);
  return res;
}

const char *otel_metrics_value_type_names[] = {
  "int", "long", "float", "double"
};
const size_t otel_metrics_value_type_names_size = 4;

const char *otel_instrument_type_names[] = {
  "counter", "histogram", "up_down_counter", "observable_counter",
  "observable_gauge", "observable_up_down_counter", "gauge"
};
const size_t otel_instrument_type_names_size = 7;

const char *otel_instrument_value_type_names[] = {
  "int", "long", "float", "double"
};
const size_t otel_instrument_value_type_names_size = 4;

const char *otel_aggregation_temporality_names[] = {
  "unspecified", "delta", "cumulative"
};
const size_t otel_aggregation_temporality_names_size = 3;

SEXP c2r_otel_metric_data(struct otel_metric_data *d) {
  const char *nms[] =
    { "instrument_name", "instrument_description", "instrument_unit",
      "instrument_type", "instrument_value_type", "aggregation_temporality",
      "start_time", "end_time", "point_data_attr", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_string(&d->instrument_name));
  SET_VECTOR_ELT(res, 1, c2r_otel_string(&d->instrument_description));
  SET_VECTOR_ELT(res, 2, c2r_otel_string(&d->instrument_unit));
  if (d->instrument_type >=
      sizeof(otel_instrument_type_names) / sizeof(const char*)) {
    R_THROW_ERROR(
      "Internal OpenTelemetry error, invalid otel_metric_data instrument_type"
    );
  }
  SET_VECTOR_ELT(res, 3,
    Rf_mkString(otel_instrument_type_names[d->instrument_type]));
  if (d->instrument_value_type >=
      sizeof(otel_instrument_value_type_names) / sizeof(const char*)) {
    R_THROW_ERROR(
      "Internal OpenTelemetry error, invalid otel_metric_data "
      "instrument_value_type"
    );
  }
  SET_VECTOR_ELT(res, 4,
    Rf_mkString(otel_instrument_value_type_names[d->instrument_value_type]));
  if (d->aggregation_temporality >=
      sizeof(otel_aggregation_temporality_names) / sizeof(const char*)) {
    R_THROW_ERROR(
      "Internal OpenTelemetry error, invalid otel_metric_data"
      "aggregation_temporality"
    );
  }
  SET_VECTOR_ELT(res, 5,
    Rf_mkString(otel_aggregation_temporality_names[d->aggregation_temporality]));
  SET_VECTOR_ELT(res, 6, Rf_ScalarReal(d->start_time));
  SET_VECTOR_ELT(res, 7, Rf_ScalarReal(d->end_time));
  SEXP posix_class = PROTECT(Rf_allocVector(STRSXP, 2));
  SET_STRING_ELT(posix_class, 0, Rf_mkChar("POSIXct"));
  SET_STRING_ELT(posix_class, 1, Rf_mkChar("POSIXt"));
  Rf_setAttrib(VECTOR_ELT(res, 6), R_ClassSymbol, posix_class);
  Rf_setAttrib(VECTOR_ELT(res, 7), R_ClassSymbol, posix_class);
  SET_VECTOR_ELT(res, 8, Rf_allocVector(VECSXP, d->count));
  for (size_t i = 0; i < d->count; i++) {
    SET_VECTOR_ELT(
      VECTOR_ELT(res, 8), i,
      c2r_otel_point_data_attributes(&d->point_data_attr[i])
    );
  }
  SEXP cls = PROTECT(Rf_mkString("otel_metric_data"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(3);
  return res;
}

SEXP c2r_otel_scope_metrics(struct otel_scope_metrics *sm) {
  const char *nms[] = { "instrumentation_scope", "metric_data", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(
    res, 0,
    c2r_otel_instrumentation_scope(&sm->instrumentation_scope)
  );
  SET_VECTOR_ELT(res, 1, Rf_allocVector(VECSXP, sm->count));
  for (size_t i = 0; i < sm->count; i++) {
    SET_VECTOR_ELT(
      VECTOR_ELT(res, 1), i,
      c2r_otel_metric_data(&sm->metric_data[i])
    );
  }

  SEXP cls = PROTECT(Rf_mkString("otel_scope_metrics"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(2);
  return res;
}

SEXP c2r_otel_resource_metrics(struct otel_resource_metrics *rm) {
  const char *nms[] = { "attributes", "scope_metric_data", "" };
  SEXP res = PROTECT(Rf_mkNamed(VECSXP, nms));
  SET_VECTOR_ELT(res, 0, c2r_otel_attributes(&rm->attributes));
  SET_VECTOR_ELT(res, 1, Rf_allocVector(VECSXP, rm->count));
  for (size_t i = 0; i < rm->count; i++) {
    SET_VECTOR_ELT(
      VECTOR_ELT(res, 1), i,
      c2r_otel_scope_metrics(&rm->scope_metric_data[i])
    );
  }
  SEXP cls = PROTECT(Rf_mkString("otel_resource_metrics"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(2);
  return res;
}

SEXP c2r_otel_metrics_data(const struct otel_metrics_data *data) {
  SEXP res = PROTECT(Rf_allocVector(VECSXP, data->count));
  for (size_t i = 0; i < data->count; i++) {
    SET_VECTOR_ELT(res, i, c2r_otel_resource_metrics(&data->a[i]));
  }
  SEXP cls = PROTECT(Rf_mkString("otel_metrics_data"));
  Rf_setAttrib(res, R_ClassSymbol, cls);
  UNPROTECT(2);
  return res;
}
