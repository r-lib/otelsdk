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

#include "otel_common.h"
#include "otel_common_cpp.h"
#include "otel_attributes.h"

void otel_string_to_char(const std::string &inp, struct otel_string &outp) {
  size_t len = inp.length();
  if (outp.s) {
    if (outp.size <= len) {
      throw std::runtime_error("Internal error, buffer too short.");
    }
    memcpy(outp.s, inp.c_str(), len);
    outp.s[len] = '\0';
  } else {
    outp.size = len + 1;
  }
}

void otel_string_to_char(const nostd::string_view &inp, struct otel_string &outp) {
  size_t len = inp.length();
  if (outp.s) {
    if (outp.size <= len) {
      throw std::runtime_error("Internal error, buffer too short.");
    }
    memcpy(outp.s, inp.data(), len);
    outp.s[len] = '\0';
  } else {
    outp.size = len + 1;
  }
}

int otel_string_from_trace_id(
    const trace_api::TraceId &trace_id, struct otel_string *s) {
  const auto sz = trace_api::TraceId::kSize;
  s->s = (char*) malloc(2 * sz);
  if (!s->s) {
    return 1;
  }
  s->size = 2 * sz;
  trace_id.ToLowerBase16(nostd::span<char, 2 * sz>(s->s, 2 * sz));
  return 0;
}

int otel_string_from_span_id(
    const trace_api::SpanId &span_id, struct otel_string *s) {
  const auto sz = trace_api::SpanId::kSize;
  s->s = (char*) malloc(2 * sz);
  if (!s->s) {
    return 1;
  }
  s->size = 2 * sz;
  span_id.ToLowerBase16(nostd::span<char, 2 * sz>(s->s, 2 * sz));
  return 0;
}

int otel_string_from_string (const std::string &str, struct otel_string *s) {
  const auto sz = str.size();
  s->s = (char*) malloc(sz);
  if (!s->s) {
    return 1;
  }
  s->size = sz;
  memcpy(s->s, str.c_str(), sz);
  return 0;
}

int otel_string_from_string_view(
    const nostd::string_view &sv, struct otel_string *s) {
  const auto sz = sv.size();
  s->s = (char*) malloc(sz);
  if (!s->s) {
    return 1;
  }
  s->size = sz;
  memcpy(s->s, sv.data(), sz);
  return 0;
}

int otel_trace_flags_from(
    const trace_api::TraceFlags &flags, struct otel_trace_flags_t *cflags) {
  cflags->is_sampled = flags.IsSampled();
  cflags->is_random = flags.IsRandom();
  return 0;
}

int otel_instrumentation_scope_from(
    trace_sdk::InstrumentationScope &is,
    struct otel_instrumentation_scope_t *cis) {
  const std::string &nm = is.GetName();
  const std::string &vs = is.GetVersion();
  const std::string &su = is.GetSchemaURL();
  if (otel_string_from_string(nm, &cis->name)) return 1;
  if (otel_string_from_string(vs, &cis->version)) return 1;
  if (otel_string_from_string(su, &cis->schema_url)) return 1;
  return 0;
}

template<class Compare>
static void otel_multimap_to_char(
  const std::multimap<std::string, std::string, Compare> &map,
  struct otel_strings &outp) {

  if (outp.s) {
    char *s = outp.s;
    size_t chk_size = 0;
    for (auto it = map.begin(); it != map.end(); it++) {
      size_t flen = it->first.length();
      size_t slen = it->second.length();
      chk_size += flen + slen + 2;
      if (outp.size < chk_size) {
        throw std::runtime_error("Internal error, buffer too short");
      }
      memcpy(s, it->first.c_str(), flen);
      s[flen] = '\0';
      s += flen + 1;
      memcpy(s, it->second.c_str(), slen);
      s[slen] = '\0';
      s += slen + 1;
    }
  } else {
    outp.count = map.size() * 2;
    outp.size = map.size() * 2;
    for (auto it = map.begin(); it != map.end(); it++) {
      outp.size += it->first.length() + it->second.length();
    }
  }
}

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

struct otel_span_data_t *otel_tracer_provider_memory_get_spans_(void *tracer_provider_) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  memory::InMemorySpanData &spandata = *tps->spandata;
  std::vector<std::unique_ptr<trace_sdk::SpanData>> data = spandata.Get();
  struct otel_span_data_t *cdata = (struct otel_span_data_t*)
    malloc(sizeof(struct otel_span_data_t));
  BAIL_IF_NOT(cdata);
  cdata->a = (struct otel_span_data1_t*)
    malloc(sizeof(struct otel_span_data1_t) * data.size());
  BAIL_IF_NOT(cdata->a);
  cdata->count = data.size();
  for (auto i = 0; i < data.size(); i++) {
    trace_api::TraceId trace_id = data[i]->GetTraceId();
    BAIL_IF(otel_string_from_trace_id(trace_id, &cdata->a[i].trace_id));
    trace_api::SpanId span_id = data[i]->GetSpanId();
    BAIL_IF(otel_string_from_span_id(span_id, &cdata->a[i].span_id));
    nostd::string_view name = data[i]->GetName();
    BAIL_IF(otel_string_from_string_view(name, &cdata->a[i].name));
    trace_api::SpanId parent_id = data[i]->GetParentSpanId();
    BAIL_IF(otel_string_from_span_id(parent_id, &cdata->a[i].parent));
    trace_api::SpanKind kind = data[i]->GetSpanKind();
    cdata->a[i].kind = static_cast<int>(kind);
    trace_api::StatusCode status = data[i]->GetStatus();
    cdata->a[i].status = static_cast<int>(status);
    nostd::string_view dsc = data[i]->GetDescription();
    BAIL_IF(otel_string_from_string_view(dsc, &cdata->a[i].description));
    std::chrono::nanoseconds st = data[i]->GetStartTime().time_since_epoch();
    cdata->a[i].start_time = st.count() / 1000.0 / 1000.0 / 1000.0;
    std::chrono::nanoseconds dur = data[i]->GetDuration();
    cdata->a[i].duration = dur.count() / 1000.0 / 1000.0 / 1000.0;
    trace_api::TraceFlags tf = data[i]->GetFlags();
    BAIL_IF(otel_trace_flags_from(tf, &cdata->a[i].flags));
    resource::Resource res = data[i]->GetResource();
    const std::string &schema_url = res.GetSchemaURL();
    BAIL_IF(otel_string_from_string(schema_url, &cdata->a[i].schema_url));
    trace_sdk::InstrumentationScope is = data[i]->GetInstrumentationScope();
    BAIL_IF(otel_instrumentation_scope_from(
      is, &cdata->a[i].instrumentation_scope));
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

void otel_tracer_provider_http_default_options_(
  struct otel_tracer_provider_http_options_t *copts) {

  otlp::OtlpHttpExporterOptions *opts =
    new otlp::OtlpHttpExporterOptions();

  otel_string_to_char(opts->url, copts->url);
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
  otel_multimap_to_char(opts->http_headers, copts->http_headers);
  copts->ssl_insecure_skip_verify = opts->ssl_insecure_skip_verify;
  otel_string_to_char(opts->ssl_ca_cert_path, copts->ssl_ca_cert_path);
  otel_string_to_char(opts->ssl_ca_cert_string, copts->ssl_ca_cert_string);
  otel_string_to_char(opts->ssl_client_key_path, copts->ssl_client_key_path);
  otel_string_to_char(opts->ssl_client_key_string, copts->ssl_client_key_string);
  otel_string_to_char(opts->ssl_client_cert_path, copts->ssl_client_cert_path);
  otel_string_to_char(opts->ssl_client_cert_string, copts->ssl_client_cert_string);
  otel_string_to_char(opts->ssl_min_tls, copts->ssl_min_tls);
  otel_string_to_char(opts->ssl_max_tls, copts->ssl_max_tls);
  otel_string_to_char(opts->ssl_cipher, copts->ssl_cipher);
  otel_string_to_char(opts->ssl_cipher_suite, copts->ssl_cipher_suite);
  otel_string_to_char(opts->compression, copts->compression);
  copts->retry_policy_max_attempts = opts->retry_policy_max_attempts;
  copts->retry_policy_initial_backoff = opts->retry_policy_initial_backoff.count();
  copts->retry_policy_max_backoff = opts->retry_policy_max_backoff.count();
  copts->retry_policy_backoff_multiplier = opts->retry_policy_backoff_multiplier;
}

void otel_tracer_provider_http_default_options_del_(void *opts_) {
  otlp::OtlpHttpExporterOptions *opts =
    (otlp::OtlpHttpExporterOptions*) opts_;
  delete opts;
}

}
