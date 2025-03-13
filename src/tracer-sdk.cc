#include <memory>
#include <stdexcept>
#include <utility>
#include <iostream>

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

void *otel_create_tracer_provider_stdout_(void) {
  auto exporter  = trace_exporter::OStreamSpanExporterFactory::Create();
  auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));

  struct otel_tracer_provider *tps = new otel_tracer_provider;
  tps->ptr = trace_sdk::TracerProviderFactory::Create(std::move(processor));

  return (void*) tps;
}

void *otel_create_tracer_provider_http_(void) {
  auto exporter  = otlp::OtlpHttpExporterFactory::Create();
  auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));

  struct otel_tracer_provider *tps = new otel_tracer_provider;
  tps->ptr = trace_sdk::TracerProviderFactory::Create(std::move(processor));

  return (void*) tps;
}

void *otel_get_tracer_(void *tracer_provider_, const char *name) {
  struct otel_tracer_provider *tps =
    (struct otel_tracer_provider *) tracer_provider_;
  trace_sdk::TracerProvider &tracer_provider = *(tps->ptr);
  struct otel_tracer *ts = new otel_tracer;
  ts->ptr = tracer_provider.GetTracer(name);

  return (void*) ts;
}

void otel_tracer_provider_http_default_url_(char *buffer, size_t *buf_len) {
  std::string url = otlp::GetOtlpDefaultHttpTracesEndpoint();
  size_t len = url.length();
  if (buffer) {
    if (*buf_len <= len) {
      throw std::runtime_error("Internal error, buffer too short");
    }
    memcpy(buffer, url.c_str(), len);
    buffer[len] = '\0';
  } else {
    *buf_len = len;
  }
}

}
