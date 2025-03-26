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
namespace nostd          = opentelemetry::nostd;

#include "otel_common.h"
#include "otel_common_cpp.h"

static void
otel_string_to_char(const std::string &inp, struct otel_string &outp) {
  size_t len = inp.length();
  if (outp.s) {
    if (outp.size <= len) {
      throw std::runtime_error("Intarnal error, buffer too short.");
    }
    memcpy(outp.s, inp.c_str(), len);
    outp.s[len] = '\0';
  } else {
    outp.size = len + 1;
  }
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

void *otel_create_tracer_provider_stdstream_(const char *stream) {
  int stdout = !strcmp(stream, "stdout");
  int stderr = !strcmp(stream, "stderr");
  struct otel_tracer_provider *tps = new otel_tracer_provider;

  if (stdout || stderr) {
    std::ostream &out = stdout ? std::cout : std::cerr;
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

void otel_tracer_provider_flush_(void *tracer_provider_) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  if (tps->stream.is_open()) {
    tps->stream.flush();
  }
}

void *otel_get_tracer_(void *tracer_provider_, const char *name) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  trace_sdk::TracerProvider &tracer_provider = *(tps->ptr);
  struct otel_tracer *ts = new otel_tracer;
  ts->ptr = tracer_provider.GetTracer(name);

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
