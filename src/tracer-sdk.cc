#include <memory>
#include <stdexcept>
#include <utility>
#include <iostream>
#include <fstream>

#include "opentelemetry/exporters/otlp/otlp_http.h"
#include "opentelemetry/exporters/otlp/otlp_http_exporter_factory.h"
#include "opentelemetry/exporters/otlp/otlp_http_exporter_options.h"
#include "opentelemetry/exporters/otlp/otlp_environment.h"
#include "opentelemetry/exporters/ostream/span_exporter_factory.h"
#include "opentelemetry/exporters/memory/in_memory_span_exporter_factory.h"
#include "opentelemetry/sdk/trace/exporter.h"
#include "opentelemetry/sdk/trace/processor.h"
#include "opentelemetry/sdk/trace/simple_processor_factory.h"
#include "opentelemetry/sdk/trace/tracer_provider.h"
#include "opentelemetry/sdk/trace/tracer_provider_factory.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/trace/tracer_provider.h"
#include "opentelemetry/trace/tracer.h"

namespace trace_api      = opentelemetry::trace;
namespace trace_sdk      = opentelemetry::sdk::trace;
namespace trace_exporter = opentelemetry::exporter::trace;
namespace otlp           = opentelemetry::exporter::otlp;
namespace memory         = opentelemetry::exporter::memory;
namespace nostd          = opentelemetry::nostd;
namespace resource       = opentelemetry::sdk::resource;
namespace common_sdk     = opentelemetry::sdk::common;

#include "otel_common.h"
#include "otel_common_cpp.h"
#include "otel_attributes.h"

extern "C" {

void otel_tracer_provider_finally_(void *tracer_provider_) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  delete tps;
}

void otel_tracer_finally_(void *tracer_) {
  struct otel_tracer *ts = (struct otel_tracer *) tracer_;
  delete ts;
}

void otel_span_finally_(void *span_) {
  struct otel_span *span = (struct otel_span *) span_;
  delete span;
}

void otel_scope_finally_(void *scope_) {
  trace_api::Scope *scope = (trace_api::Scope*) scope_;
  delete scope;
}

void otel_span_context_finally_(void *span_context_) {
  trace_api::SpanContext *span_context =
    (trace_api::SpanContext*) span_context_;
  delete span_context;
}

void *otel_create_tracer_provider_stdstream_(const char *stream) {
  int sout = !strcmp(stream, "stdout");
  int serr = !strcmp(stream, "stderr");
  struct otel_tracer_provider *tps = new otel_tracer_provider;

  if (sout || serr) {
    std::ostream &out = sout ? std::cout : std::cerr;
    auto exporter  = trace_exporter::OStreamSpanExporterFactory::Create(out);
    auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));
    tps->ptr = trace_sdk::TracerProviderFactory::Create(std::move(processor));
    return (void*) tps;

  } else {
    tps->stream.open(stream, std::fstream::out | std::fstream::app);
    // no buffering, because we use this for testing
    tps->stream.rdbuf()->pubsetbuf(0,0);
    auto exporter  = trace_exporter::OStreamSpanExporterFactory::Create(tps->stream);
    auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));
    tps->ptr = trace_sdk::TracerProviderFactory::Create(std::move(processor));
    return tps;
  }
}

void *otel_create_tracer_provider_http_(void) {
  auto exporter  = otlp::OtlpHttpExporterFactory::Create();
  auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));

  struct otel_tracer_provider *tps = new otel_tracer_provider;
  tps->ptr = trace_sdk::TracerProviderFactory::Create(std::move(processor));

  return (void*) tps;
}

void *otel_create_tracer_provider_memory_(int buffer_size) {
  struct otel_tracer_provider *tps = new otel_tracer_provider;
  tps->spandata.reset(new memory::InMemorySpanData(buffer_size));
  auto exporter  = memory::InMemorySpanExporterFactory::Create(tps->spandata);
  auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));

  tps->ptr = trace_sdk::TracerProviderFactory::Create(std::move(processor));

  return (void*) tps;
}

#define BAIL_IF_NOT(x) do { \
  if (!(x)) { otel_span_data_free(cdata); return nullptr; } } while (0)

#define BAIL_IF(x) do { \
  if (x) { otel_span_data_free(cdata); return nullptr; } } while (0)

struct otel_span_data_t *otel_tracer_provider_memory_get_spans_(
    void *tracer_provider_, struct otel_span_data_t *cdata) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  memory::InMemorySpanData &spandata = *tps->spandata;
  std::vector<std::unique_ptr<trace_sdk::SpanData>> data = spandata.Get();
  cdata->a = (struct otel_span_data1_t*)
    malloc(sizeof(struct otel_span_data1_t) * data.size());
  BAIL_IF_NOT(cdata->a);
  cdata->count = data.size();
  for (auto i = 0; i < data.size(); i++) {
    trace_api::TraceId trace_id = data[i]->GetTraceId();
    BAIL_IF(cc2c_otel_string(trace_id, cdata->a[i].trace_id));
    trace_api::SpanId span_id = data[i]->GetSpanId();
    BAIL_IF(cc2c_otel_string(span_id, cdata->a[i].span_id));
    nostd::string_view name = data[i]->GetName();
    BAIL_IF(cc2c_otel_string(name, cdata->a[i].name));
    trace_api::SpanId parent_id = data[i]->GetParentSpanId();
    BAIL_IF(cc2c_otel_string(parent_id, cdata->a[i].parent));
    trace_api::SpanKind kind = data[i]->GetSpanKind();
    cdata->a[i].kind = static_cast<int>(kind);
    trace_api::StatusCode status = data[i]->GetStatus();
    cdata->a[i].status = static_cast<int>(status);
    nostd::string_view dsc = data[i]->GetDescription();
    BAIL_IF(cc2c_otel_string(dsc, cdata->a[i].description));
    std::chrono::nanoseconds st = data[i]->GetStartTime().time_since_epoch();
    cdata->a[i].start_time = st.count() / 1000.0 / 1000.0 / 1000.0;
    std::chrono::nanoseconds dur = data[i]->GetDuration();
    cdata->a[i].duration = dur.count() / 1000.0 / 1000.0 / 1000.0;
    trace_api::TraceFlags tf = data[i]->GetFlags();
    BAIL_IF(cc2c_otel_trace_flags(tf, cdata->a[i].flags));
    resource::Resource res = data[i]->GetResource();
    const std::string &schema_url = res.GetSchemaURL();
    BAIL_IF(cc2c_otel_string(schema_url, cdata->a[i].schema_url));
    std::unordered_map<std::string, common_sdk::OwnedAttributeValue> rattr =
      res.GetAttributes();
    BAIL_IF(cc2c_otel_attributes(rattr, cdata->a[i].resource_attributes));
    trace_sdk::InstrumentationScope is = data[i]->GetInstrumentationScope();
    BAIL_IF(cc2c_otel_instrumentation_scope(
      is, cdata->a[i].instrumentation_scope));
    std::unordered_map<std::string, common_sdk::OwnedAttributeValue> attr =
      data[i]->GetAttributes();
    BAIL_IF(cc2c_otel_attributes(attr, cdata->a[i].attributes));
    const std::vector<trace_sdk::SpanDataEvent> &events = data[i]->GetEvents();
    BAIL_IF(cc2c_otel_events(events, cdata->a[i].events));
  }
  return cdata;
}

void otel_tracer_provider_flush_(void *tracer_provider_) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  if (tps->stream.is_open()) {
    tps->stream.flush();
  }
}

void *otel_get_tracer_(
    void *tracer_provider_, const char *name, const char *version,
    const char *schema_url, struct otel_attributes *attributes) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  trace_sdk::TracerProvider &tracer_provider = *(tps->ptr);
  RKeyValueIterable attributes_(*attributes);
  struct otel_tracer *ts = new otel_tracer;
  ts->ptr = tracer_provider.GetTracer(
    name, version ? version : "", schema_url ? schema_url : "",
    &attributes_
  );

  return (void*) ts;
}

int otel_tracer_provider_http_default_options_(
  struct otel_tracer_provider_http_options_t *copts) {

  otlp::OtlpHttpExporterOptions *opts =
    new otlp::OtlpHttpExporterOptions();

  cc2c_otel_string(opts->url, copts->url);
  switch(opts->content_type) {
    case otlp::HttpRequestContentType::kJson:
      copts->content_type = k_json;
      break;
    case otlp::HttpRequestContentType::kBinary:
      copts->content_type = k_binary;
      break;
    default:
      throw std::runtime_error("Internal error, unknown HTTP request content type");
      break;
  }
  copts->use_json_name = opts->use_json_name;
  copts->console_debug = opts->console_debug;
  copts->timeout = std::chrono::duration<double>(opts->timeout).count();
  cc2c_otel_strings(opts->http_headers, copts->http_headers);
  copts->ssl_insecure_skip_verify = opts->ssl_insecure_skip_verify;
  cc2c_otel_string(opts->ssl_ca_cert_path, copts->ssl_ca_cert_path);
  cc2c_otel_string(opts->ssl_ca_cert_string, copts->ssl_ca_cert_string);
  cc2c_otel_string(opts->ssl_client_key_path, copts->ssl_client_key_path);
  cc2c_otel_string(opts->ssl_client_key_string, copts->ssl_client_key_string);
  cc2c_otel_string(opts->ssl_client_cert_path, copts->ssl_client_cert_path);
  cc2c_otel_string(opts->ssl_client_cert_string, copts->ssl_client_cert_string);
  cc2c_otel_string(opts->ssl_min_tls, copts->ssl_min_tls);
  cc2c_otel_string(opts->ssl_max_tls, copts->ssl_max_tls);
  cc2c_otel_string(opts->ssl_cipher, copts->ssl_cipher);
  cc2c_otel_string(opts->ssl_cipher_suite, copts->ssl_cipher_suite);
  cc2c_otel_string(opts->compression, copts->compression);
  copts->retry_policy_max_attempts = opts->retry_policy_max_attempts;
  copts->retry_policy_initial_backoff = opts->retry_policy_initial_backoff.count();
  copts->retry_policy_max_backoff = opts->retry_policy_max_backoff.count();
  copts->retry_policy_backoff_multiplier = opts->retry_policy_backoff_multiplier;
  return 0;
}

void otel_tracer_provider_http_default_options_del_(void *opts_) {
  otlp::OtlpHttpExporterOptions *opts =
    (otlp::OtlpHttpExporterOptions*) opts_;
  delete opts;
}

}
