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
#include "opentelemetry/exporters/memory/in_memory_metric_data.h"
#include "opentelemetry/exporters/otlp/otlp_file_client_options.h"

namespace trace_api      = opentelemetry::trace;
namespace trace_sdk      = opentelemetry::sdk::trace;
namespace logs_api       = opentelemetry::logs;
namespace logs_sdk       = opentelemetry::sdk::logs;
namespace metrics_api    = opentelemetry::metrics;
namespace metrics_sdk    = opentelemetry::sdk::metrics;
namespace nostd          = opentelemetry::nostd;
namespace memory         = opentelemetry::exporter::memory;
namespace common_sdk     = opentelemetry::sdk::common;
namespace otlp           = opentelemetry::exporter::otlp;

struct otel_span {
  nostd::shared_ptr<trace_api::Span> ptr;
};

struct otel_tracer_provider {
  std::unique_ptr<trace_sdk::TracerProvider> ptr;
  std::fstream stream;
  std::shared_ptr<memory::InMemorySpanData> spandata;
  bool shutdown_called;
};

struct otel_tracer {
  nostd::shared_ptr<trace_api::Tracer> ptr;
};

struct otel_logger_provider {
  std::unique_ptr<logs_sdk::LoggerProvider> ptr;
  std::fstream stream;
  bool shutdown_called;
};

struct otel_logger {
  nostd::shared_ptr<logs_api::Logger> ptr;
  int minimum_severity;
};

struct otel_meter_provider {
  std::unique_ptr<metrics_sdk::MeterProvider> ptr;
  std::fstream stream;
  std::shared_ptr<memory::CircularBufferInMemoryMetricData> metricdata;
  bool shutdown_called;
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

int cc2c_otel_string(const std::string &str, struct otel_string &s);
int cc2c_otel_string(const nostd::string_view &sv, struct otel_string &s);
int cc2c_otel_string(
  const trace_api::TraceId &trace_id, struct otel_string &s);
int cc2c_otel_string(
  const trace_api::SpanId &span_id, struct otel_string &s);

template<class Compare>
int cc2c_otel_strings(
  const std::multimap<std::string, std::string, Compare> &map,
  struct otel_strings &outp) {

  size_t sz = map.size();
  outp.a = (struct otel_string*)
    malloc(sizeof(struct otel_string) * sz * 2);
  if (!outp.a) return 1;
  size_t idx = 0;
  for (auto it: map) {
    if (idx >= sz) break;
    if (cc2c_otel_string(it.first, outp.a[idx++])) return 1;
    if (cc2c_otel_string(it.second, outp.a[idx++])) return 1;
  }
  return 0;
}

int cc2c_otel_trace_flags(
  const trace_api::TraceFlags &flags, struct otel_trace_flags &cflags);

int cc2c_otel_instrumentation_scope(
  trace_sdk::InstrumentationScope &is,
  struct otel_instrumentation_scope &cis) noexcept;

int cc2c_otel_attribute(
    const std::string &key, const common_sdk::OwnedAttributeValue &attr,
    struct otel_attribute &cattr);

template<typename T>
int cc2c_otel_attributes(const T &attrs, struct otel_attributes &cattrs) {
  try {
    size_t sz = attrs.size();
    cattrs.a = (struct otel_attribute*)
      malloc(sizeof(struct otel_attribute) * sz);
    if (!cattrs.a) return 1;
    cattrs.count = sz;

    size_t i = 0;
    for (auto it: attrs) {
      if (i >= sz) break;
      const std::string &key = it.first;
      const common_sdk::OwnedAttributeValue &val = it.second;
      if (cc2c_otel_attribute(key, val, cattrs.a[i++])) return 1;
    }

    return 0;

  } catch (...) {
    otel_attributes_free(&cattrs);
    return 1;
  }
}

int cc2c_otel_boolean_array(
  const std::vector<bool> &a, struct otel_boolean_array &ca);
int cc2c_otel_int64_array(
  const std::vector<int64_t> &a, struct otel_int64_array &ca);
int cc2c_otel_int64_array(
  const std::vector<int32_t> &a, struct otel_int64_array &ca);
int cc2c_otel_double_array(
  const std::vector<double> &a, struct otel_double_array &ca);
int cc2c_otel_double_array(
  const std::vector<uint32_t> &a, struct otel_double_array &ca);
int cc2c_otel_double_array(
  const std::vector<uint64_t> &a, struct otel_double_array &ca);
int cc2c_otel_double_array(
  const std::vector<uint8_t> &a, struct otel_double_array &ca);
int cc2c_otel_string_array(
  const std::vector<std::string> &a, struct otel_string_array &ca);

int cc2c_otel_events(
  const std::vector<trace_sdk::SpanDataEvent> &events,
  struct otel_events &cevents);
int cc2c_otel_links(
  const std::vector<trace_sdk::SpanDataLink> &links,
  struct otel_span_links &clinks);

void c2cc_file_exporter_options(
  const struct otel_file_exporter_options &options,
  otlp::OtlpFileClientFileSystemOptions &backeend_opts);
void cc2c_file_exporter_options(
    const otlp::OtlpFileClientFileSystemOptions &backend_opts,
    struct otel_file_exporter_options &options);

#endif
