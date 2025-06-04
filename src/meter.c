#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>

#include "otel_common.h"

void r2c_attributes(SEXP r, struct otel_attributes *c);

void otel_meter_provider_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return;
  }
  void *meter_provider_ = R_ExternalPtrAddr(x);
  if (meter_provider_) {
    otel_meter_provider_finally_(meter_provider_);
    R_ClearExternalPtr(x);
  }
}

void otel_meter_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid meter pointer.");
    return;
  }
  void *meter_ = R_ExternalPtrAddr(x);
  if (meter_) {
    otel_meter_finally_(meter_);
    R_ClearExternalPtr(x);
  }
}

SEXP otel_create_meter_provider_stdstream(
    SEXP stream, SEXP export_interval, SEXP export_timeout) {
  const char *cstream = CHAR(STRING_ELT(stream, 0));
  int cexport_interval = INTEGER(export_interval)[0];
  int cexport_timeout = INTEGER(export_timeout)[0];
  void *meter_provider_ = otel_create_meter_provider_stdstream_(
    cstream, cexport_interval, cexport_timeout);
  SEXP xptr = R_MakeExternalPtr(meter_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_meter_provider_http(
    SEXP export_interval, SEXP export_timeout) {
  int cexport_interval = INTEGER(export_interval)[0];
  int cexport_timeout = INTEGER(export_timeout)[0];
  void *meter_provider_ = otel_create_meter_provider_http_(
    cexport_interval, cexport_timeout);
  SEXP xptr = R_MakeExternalPtr(meter_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_create_meter_provider_memory(
    SEXP export_interval, SEXP export_timeout, SEXP buffer_size,
    SEXP temporality) {
  int cexport_interval = INTEGER(export_interval)[0];
  int cexport_timeout = INTEGER(export_timeout)[0];
  int cbuffer_size = INTEGER(buffer_size)[0];
  int ctemporality = INTEGER(temporality)[0];
  void *meter_provider_ = otel_create_meter_provider_memory_(
    cexport_interval, cexport_timeout, cbuffer_size, ctemporality);
  SEXP xptr = R_MakeExternalPtr(meter_provider_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_provider_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_meter_provider_memory_get_metrics(SEXP provider) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return R_NilValue;
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }

  struct otel_metric_data data = { 0 };
  otel_meter_provider_memory_get_metrics_(meter_provider_, &data);

  // TODO

  otel_metric_data_free(&data);
  return R_NilValue;
}

SEXP otel_get_meter(
    SEXP provider, SEXP name, SEXP version, SEXP schema_url,
    SEXP attributes) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_error("OpenTelemetry: invalid meter provider pointer.");
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }
  const char *name_ = CHAR(STRING_ELT(name, 0));
  const char *version_ =
    Rf_isNull(version) ? NULL : CHAR(STRING_ELT(version, 0));
  const char *schema_url_ =
    Rf_isNull(schema_url) ? NULL : CHAR(STRING_ELT(schema_url, 0));
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  void *meter_ = otel_get_meter_(
    meter_provider_, name_, version_, schema_url_, &attributes_);
  SEXP xptr = R_MakeExternalPtr(meter_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_meter_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_meter_provider_flush(SEXP provider, SEXP timeout) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return R_NilValue;
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }
  int ctimeout = Rf_isNull(timeout) ? -1 : INTEGER(timeout)[0];
  otel_meter_provider_flush_(meter_provider_, ctimeout);
  return R_NilValue;
}

SEXP otel_meter_provider_shutdown(SEXP provider, SEXP timeout) {
  if (TYPEOF(provider) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid meter provider pointer."
    );
    return R_NilValue;
  }
  void *meter_provider_ = R_ExternalPtrAddr(provider);
  if (!meter_provider_) {
    Rf_error(
      "Opentelemetry meter provider cleaned up already, internal error."
    );
  }
  int ctimeout = Rf_isNull(timeout) ? -1 : INTEGER(timeout)[0];
  otel_meter_provider_shutdown_(meter_provider_, ctimeout);
  return R_NilValue;
}

void otel_counter_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid counter pointer.");
    return;
  }
  void *counter_ = R_ExternalPtrAddr(x);
  if (counter_) {
    otel_counter_finally_(counter_);
    R_ClearExternalPtr(x);
  }
}

void otel_up_down_counter_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(
      R_NilValue,
      "OpenTelemetry: invalid up-down counter pointer."
    );
    return;
  }
  void *up_down_counter_ = R_ExternalPtrAddr(x);
  if (up_down_counter_) {
    otel_up_down_counter_finally_(up_down_counter_);
    R_ClearExternalPtr(x);
  }
}

void otel_histogram_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid histogram pointer.");
    return;
  }
  void *histogram_ = R_ExternalPtrAddr(x);
  if (histogram_) {
    otel_histogram_finally_(histogram_);
    R_ClearExternalPtr(x);
  }
}

void otel_gauge_finally(SEXP x) {
  if (TYPEOF(x) != EXTPTRSXP) {
    Rf_warningcall(R_NilValue, "OpenTelemetry: invalid gauge pointer.");
    return;
  }
  void *gauge_ = R_ExternalPtrAddr(x);
  if (gauge_) {
    otel_gauge_finally_(gauge_);
    R_ClearExternalPtr(x);
  }
}

SEXP otel_create_counter(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *counter_ =
    otel_create_counter_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(counter_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_counter_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_counter_add(
    SEXP counter, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(counter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *counter_ = R_ExternalPtrAddr(counter);
  if (!counter_) {
    Rf_error("Opentelemetry counter cleaned up already, internal error.");
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_counter_add_(counter_, cvalue, &attributes_);
  return R_NilValue;
}

SEXP otel_create_up_down_counter(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *up_down_counter_ =
    otel_create_up_down_counter_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(up_down_counter_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_up_down_counter_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_up_down_counter_add(
    SEXP up_down_counter, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(up_down_counter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *up_down_counter_ = R_ExternalPtrAddr(up_down_counter);
  if (!up_down_counter_) {
    Rf_error(
      "Opentelemetry up-down counter cleaned up already, internal error."
    );
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_up_down_counter_add_(up_down_counter_, cvalue, &attributes_);
  return R_NilValue;
}

SEXP otel_create_histogram(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *histogram_ =
    otel_create_histogram_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(histogram_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_histogram_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_histogram_record(
    SEXP histogram, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(histogram) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *histogram_ = R_ExternalPtrAddr(histogram);
  if (!histogram_) {
    Rf_error(
      "Opentelemetry histogram cleaned up already, internal error."
    );
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_histogram_record_(histogram_, cvalue, &attributes_);
  return R_NilValue;
}

SEXP otel_create_gauge(
    SEXP meter, SEXP name, SEXP description, SEXP unit) {
  if (TYPEOF(meter) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid meter pointer");
  }
  void *meter_ = R_ExternalPtrAddr(meter);
  if (!meter_) {
    Rf_error("Opentelemetry meter cleaned up already, internal error.");
  }

  const char *cname = CHAR(STRING_ELT(name, 0));
  const char *cdescription =
    Rf_isNull(description) ? NULL : CHAR(STRING_ELT(description, 0));
  const char *cunit = Rf_isNull(unit) ? NULL : CHAR(STRING_ELT(unit, 0));
  void *gauge_ =
    otel_create_gauge_(meter_, cname, cdescription, cunit);
  SEXP xptr = R_MakeExternalPtr(gauge_, R_NilValue, R_NilValue);
  R_RegisterCFinalizerEx(xptr, otel_gauge_finally, (Rboolean) 1);
  return xptr;
}

SEXP otel_gauge_record(
    SEXP gauge, SEXP value, SEXP attributes, SEXP context) {
  if (TYPEOF(gauge) != EXTPTRSXP) {
    Rf_error("Opentelemetry: invalid counter pointer");
  }
  void *gauge_ = R_ExternalPtrAddr(gauge);
  if (!gauge_) {
    Rf_error(
      "Opentelemetry gauge cleaned up already, internal error."
    );
  }
  double cvalue = REAL(value)[0];
  struct otel_attributes attributes_;
  r2c_attributes(attributes, &attributes_);
  // TODO: context
  otel_gauge_record_(gauge_, cvalue, &attributes_);
  return R_NilValue;
}
