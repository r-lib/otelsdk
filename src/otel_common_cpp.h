#ifndef OTEL_COMMON_CPP_H
#define OTEL_COMMON_CPP_H

#include <fstream>

#include "opentelemetry/sdk/trace/tracer_provider.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/sdk/logs/logger_provider.h"
#include "opentelemetry/sdk/metrics/meter_provider.h"
#include "opentelemetry/logs/provider.h"
#include "opentelemetry/sdk/metrics/sync_instruments.h"
#include "opentelemetry/exporters/memory/in_memory_span_data.h"

namespace trace_api      = opentelemetry::trace;
namespace trace_sdk      = opentelemetry::sdk::trace;
namespace logs_api       = opentelemetry::logs;
namespace logs_sdk       = opentelemetry::sdk::logs;
namespace metrics_api    = opentelemetry::metrics;
namespace metrics_sdk    = opentelemetry::sdk::metrics;
namespace nostd          = opentelemetry::nostd;
namespace memory         = opentelemetry::exporter::memory;

struct otel_span {
  nostd::shared_ptr<trace_api::Span> ptr;
};

struct otel_tracer_provider {
  std::unique_ptr<trace_sdk::TracerProvider> ptr;
  std::fstream stream;
  std::shared_ptr<memory::InMemorySpanData> spandata;
};

struct otel_tracer {
  nostd::shared_ptr<trace_api::Tracer> ptr;
};

struct otel_logger_provider {
  std::unique_ptr<logs_sdk::LoggerProvider> ptr;
  std::fstream stream;
};

struct otel_logger {
  nostd::shared_ptr<logs_api::Logger> ptr;
  int minimum_severity;
};

struct otel_meter_provider {
  std::unique_ptr<metrics_sdk::MeterProvider> ptr;
  std::fstream stream;
};

struct otel_meter {
  nostd::shared_ptr<metrics_api::Meter> ptr;
};

struct otel_counter {
  nostd::unique_ptr<metrics_api::Counter<double>> ptr;
};

struct otel_up_down_counter {
  nostd::unique_ptr<metrics_api::UpDownCounter<double>> ptr;
};

struct otel_histogram {
  nostd::unique_ptr<metrics_api::Histogram<double>> ptr;
};

struct otel_gauge {
  nostd::unique_ptr<metrics_api::Gauge<double>> ptr;
};

void otel_string_to_char(const std::string &inp, struct otel_string &outp);
void otel_string_to_char(
  const nostd::string_view &inp, struct otel_string &outp);

int otel_string_from_string (const std::string &str, struct otel_string *s);
int otel_string_from_string_view(
  const nostd::string_view &sv, struct otel_string *s);
int otel_string_from_trace_id(
  const trace_api::TraceId &trace_id, struct otel_string *s);
int otel_string_from_span_id(
  const trace_api::SpanId &span_id, struct otel_string *s);

int otel_instrumentation_scope_from(
  trace_sdk::InstrumentationScope &is,
  struct otel_instrumentation_scope_t *cis);

#endif
