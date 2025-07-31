#include <string.h>

#define R_USE_C99_IN_CXX 1
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#include "otel_common.h"
#include "otel_common_r.h"
#include "errors.h"
#include "cleancall.h"

SEXP otel_fail(void);
SEXP otel_error_object(void);
SEXP otel_init_constants(SEXP env);
SEXP otel_build_safe(void) {
#ifdef OTEL_BUILD_SAFE
  return ScalarLogical(TRUE);
#else
  return ScalarLogical(FALSE);
#endif
}

SEXP otel_create_tracer_provider_stdstream(SEXP options, SEXP attributes);
SEXP otel_create_tracer_provider_http(SEXP options, SEXP attributes);
SEXP otel_tracer_provider_http_options(void);
SEXP otel_create_tracer_provider_memory(SEXP options, SEXP attributes);
SEXP otel_create_tracer_provider_file(SEXP options, SEXP attributes);
SEXP otel_tracer_provider_file_options_defaults(void);
SEXP otel_tracer_provider_memory_get_spans(SEXP provider);
SEXP otel_tracer_provider_flush(SEXP provider);
SEXP otel_get_tracer(
  SEXP provider, SEXP name, SEXP version, SEXP schema_url,
  SEXP attributes);
SEXP otel_get_active_span_context(SEXP tracer);

SEXP otel_start_span(
  SEXP tracer, SEXP name, SEXP attributes, SEXP links, SEXP options);
SEXP otel_span_get_context(SEXP span);
SEXP otel_span_is_valid(SEXP span);
SEXP otel_span_is_recording(SEXP span);
SEXP otel_span_set_attribute(SEXP span, SEXP name, SEXP value);
SEXP otel_span_add_event(
  SEXP span, SEXP name, SEXP attributes, SEXP timestamp
);
// ABI v2
// SEXP otel_span_add_link(SEXP span, SEXP link);
SEXP otel_span_set_status(SEXP span, SEXP status_code, SEXP description);
SEXP otel_span_update_name(SEXP span, SEXP name);
SEXP otel_span_end(SEXP span, SEXP options, SEXP status_code);

SEXP otel_bsp_defaults(void);
SEXP otel_blrp_defaults(void);

SEXP otel_scope_start(SEXP span);
SEXP otel_scope_end(SEXP scope);

SEXP otel_span_id_size(void);
SEXP otel_trace_id_size(void);
SEXP otel_span_context_is_valid(SEXP span_context);
SEXP otel_span_context_get_trace_flags(SEXP span_context);
SEXP otel_span_context_get_trace_id(SEXP span_context);
SEXP otel_span_context_get_span_id(SEXP span_context);
SEXP otel_span_context_is_remote(SEXP span_context);
SEXP otel_span_context_is_sampled(SEXP span_context);
SEXP otel_span_context_to_headers(SEXP span_context);
SEXP otel_extract_http_context(SEXP headers);

SEXP otel_create_logger_provider_stdstream(SEXP options, SEXP attributes);
SEXP otel_create_logger_provider_http(SEXP options, SEXP attributes);
SEXP otel_logger_provider_http_options(void);
SEXP otel_create_logger_provider_file(SEXP options);
SEXP otel_logger_provider_file_options_defaults(void);
SEXP otel_get_logger(
  SEXP provider, SEXP name, SEXP minimum_severity, SEXP version,
  SEXP schema_url, SEXP attributes);
SEXP otel_logger_provider_flush(SEXP provider);

SEXP otel_get_minimum_log_severity(SEXP logger);
SEXP otel_set_minimum_log_severity(SEXP logger, SEXP mimimum_severity);
SEXP otel_logger_get_name(SEXP logger);
SEXP otel_emit_log_record(SEXP logger, SEXP log_record);
SEXP otel_logger_is_enabled(SEXP logger, SEXP severity, SEXP event_id);
SEXP otel_log(
  SEXP logger, SEXP format, SEXP severity, SEXP event_id, SEXP span_id,
  SEXP trace_id, SEXP trace_flags, SEXP timestamp, SEXP observed_timestamp,
  SEXP attributes);

SEXP otel_create_meter_provider_stdstream(SEXP options, SEXP attributes);
SEXP otel_create_meter_provider_http(SEXP options, SEXP attributes);
SEXP otel_meter_provider_http_options(void);
SEXP otel_create_meter_provider_file(
  SEXP export_interval, SEXP export_timeout, SEXP options);
SEXP otel_meter_provider_file_options_defaults(void);
SEXP otel_create_meter_provider_memory(SEXP options, SEXP attributes);
SEXP otel_meter_provider_memory_get_metrics(SEXP provider);
SEXP otel_get_meter(SEXP provider, SEXP name, SEXP version,
  SEXP schema_url, SEXP attributes);
SEXP otel_meter_provider_flush(SEXP provider, SEXP timeout);
SEXP otel_meter_provider_shutdown(SEXP provider, SEXP timeout);

SEXP otel_create_counter(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_counter_add(
  SEXP counter, SEXP value, SEXP attributes, SEXP context);

SEXP otel_create_up_down_counter(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_up_down_counter_add(
  SEXP up_down_counter, SEXP value, SEXP attributes, SEXP context);

SEXP otel_create_histogram(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_histogram_record(
  SEXP histogram, SEXP value, SEXP attributes, SEXP unit);

SEXP otel_create_gauge(
  SEXP meter, SEXP name, SEXP description, SEXP unit);
SEXP otel_gauge_record(
  SEXP gauge, SEXP value, SEXP attributes, SEXP unit);

SEXP otel_parse_log_record(SEXP str);
SEXP otel_parse_metrics_record(SEXP str);
SEXP otel_encode_response(
  SEXP signal_, SEXP result_, SEXP errmsg_, SEXP rejected_,
  SEXP error_code_);

SEXP rf_get_list_element(SEXP list, const char *str);
SEXP glue_(SEXP x, SEXP f, SEXP open_arg, SEXP close_arg, SEXP cli_arg);
SEXP trim_(SEXP x);
SEXP create_empty_xptr(void);

#ifdef GCOV_COMPILE

void __gcov_dump();
SEXP otel_gcov_flush() {
  REprintf("Flushing coverage info\n");
  __gcov_dump();
  return R_NilValue;
}

#else

SEXP otel_gcov_flush(void) {
  return R_NilValue;
}

#endif

#define CALLDEF(name, n) \
  { #name, (DL_FUNC)&name, n }

static const R_CallMethodDef callMethods[]  = {
  CLEANCALL_METHOD_RECORD,

  CALLDEF(otel_fail, 0),
  CALLDEF(otel_error_object, 0),
  CALLDEF(otel_init_constants, 1),
  CALLDEF(otel_build_safe, 0),

  CALLDEF(otel_create_tracer_provider_stdstream, 2),
  CALLDEF(otel_create_tracer_provider_http, 2),
  CALLDEF(otel_tracer_provider_http_options, 0),
  CALLDEF(otel_create_tracer_provider_memory, 2),
  CALLDEF(otel_create_tracer_provider_file, 2),
  CALLDEF(otel_tracer_provider_file_options_defaults, 0),
  CALLDEF(otel_tracer_provider_memory_get_spans, 1),
  CALLDEF(otel_tracer_provider_flush, 1),
  CALLDEF(otel_get_tracer, 5),
  CALLDEF(otel_get_active_span_context, 1),
  CALLDEF(otel_start_span, 5),
  CALLDEF(otel_span_get_context, 1),
  CALLDEF(otel_span_is_valid, 1),
  CALLDEF(otel_span_is_recording, 1),
  CALLDEF(otel_span_set_attribute, 3),
  CALLDEF(otel_span_add_event, 4),
  // ABI v2
  // CALLDEF(otel_span_add_link, 2),
  CALLDEF(otel_span_set_status, 3),
  CALLDEF(otel_span_update_name, 2),
  CALLDEF(otel_span_end, 3),
  CALLDEF(otel_bsp_defaults, 0),
  CALLDEF(otel_blrp_defaults, 0),
  CALLDEF(otel_scope_start, 1),
  CALLDEF(otel_scope_end, 1),

  CALLDEF(otel_span_id_size, 0),
  CALLDEF(otel_trace_id_size, 0),
  CALLDEF(otel_span_context_is_valid, 1),
  CALLDEF(otel_span_context_get_trace_flags, 1),
  CALLDEF(otel_span_context_get_trace_id, 1),
  CALLDEF(otel_span_context_get_span_id, 1),
  CALLDEF(otel_span_context_is_remote, 1),
  CALLDEF(otel_span_context_is_sampled, 1),
  CALLDEF(otel_span_context_to_headers, 1),
  CALLDEF(otel_extract_http_context, 1),

  CALLDEF(otel_create_logger_provider_stdstream, 2),
  CALLDEF(otel_create_logger_provider_http, 2),
  CALLDEF(otel_logger_provider_http_options, 0),
  CALLDEF(otel_create_logger_provider_file, 1),
  CALLDEF(otel_logger_provider_file_options_defaults, 0),
  CALLDEF(otel_get_minimum_log_severity, 1),
  CALLDEF(otel_set_minimum_log_severity, 2),
  CALLDEF(otel_logger_provider_flush, 1),
  CALLDEF(otel_get_logger, 6),
  CALLDEF(otel_logger_get_name, 1),
  CALLDEF(otel_emit_log_record, 2),
  CALLDEF(otel_logger_is_enabled, 3),
  CALLDEF(otel_log, 10),

  CALLDEF(otel_create_meter_provider_stdstream, 2),
  CALLDEF(otel_create_meter_provider_http, 2),
  CALLDEF(otel_meter_provider_http_options, 0),
  CALLDEF(otel_create_meter_provider_file, 3),
  CALLDEF(otel_meter_provider_file_options_defaults, 0),
  CALLDEF(otel_create_meter_provider_memory, 2),
  CALLDEF(otel_meter_provider_memory_get_metrics, 1),
  CALLDEF(otel_get_meter, 5),
  CALLDEF(otel_meter_provider_flush, 2),
  CALLDEF(otel_meter_provider_shutdown, 2),
  CALLDEF(otel_create_counter, 4),
  CALLDEF(otel_counter_add, 4),
  CALLDEF(otel_create_up_down_counter, 4),
  CALLDEF(otel_up_down_counter_add, 4),
  CALLDEF(otel_create_histogram, 4),
  CALLDEF(otel_histogram_record, 4),
  CALLDEF(otel_create_gauge, 4),
  CALLDEF(otel_gauge_record, 4),

  CALLDEF(otel_parse_log_record, 1),
  CALLDEF(otel_parse_metrics_record, 1),
  CALLDEF(otel_encode_response, 5),

  CALLDEF(glue_, 5),
  CALLDEF(trim_, 1),
  CALLDEF(create_empty_xptr, 0),
  CALLDEF(otel_gcov_flush, 0),

  { NULL, NULL, 0 }
};

extern void otel_init_context_storage(void);

void R_init_otelsdk(DllInfo *dll) {
  R_registerRoutines(dll, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
  cleancall_init();
}
