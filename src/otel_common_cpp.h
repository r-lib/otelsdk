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
#include "opentelemetry/exporters/otlp/otlp_http_exporter_options.h"

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

std::string c2cc_otel_string(const struct otel_string& s);

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

  // # nocov start
  } catch (...) {
    otel_attributes_free(&cattrs);
    return 1;
  }
  // # nocov end
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

template<typename T>
void c2cc_otel_http_exporter_options(
  const struct otel_http_exporter_options &coptions,
  T &options);

void c2cc_otel_http_headers(
  const struct otel_http_headers &cheaders,
  otlp::OtlpHeaders &headers);

extern const char *otel_otlp_compression_names[];

template<typename T>
void c2cc_otel_http_exporter_options(
  const struct otel_http_exporter_options &coptions,
  T &options
) {
  if (coptions.isset.url) {
    options.url = c2cc_otel_string(coptions.url);
  }
  if (coptions.isset.content_type) {
    options.content_type =
      static_cast<otlp::HttpRequestContentType>(coptions.content_type);
  }
  if (coptions.isset.json_bytes_mapping) {
    options.json_bytes_mapping =
      static_cast<otlp::JsonBytesMappingKind>(coptions.json_bytes_mapping);
  }
  if (coptions.isset.use_json_name) {
    options.use_json_name = coptions.use_json_name;
  }
  if (coptions.isset.console_debug) {
    options.console_debug = coptions.console_debug;
  }
  if (coptions.isset.timeout) {
    options.timeout = std::chrono::milliseconds((int64_t)coptions.timeout);
  }
  if (coptions.isset.http_headers) {
    c2cc_otel_http_headers(coptions.http_headers, options.http_headers);
  }
  if (coptions.isset.ssl_insecure_skip_verify) {
    options.ssl_insecure_skip_verify = coptions.ssl_insecure_skip_verify;
  }
  if (coptions.isset.ssl_ca_cert_path) {
    options.ssl_ca_cert_path = c2cc_otel_string(coptions.ssl_ca_cert_path);
  }
  if (coptions.isset.ssl_ca_cert_string) {
    options.ssl_ca_cert_string =
      c2cc_otel_string(coptions.ssl_ca_cert_string);
  }
  if (coptions.isset.ssl_client_key_path) {
    options.ssl_ca_cert_string =
      c2cc_otel_string(coptions.ssl_client_key_path);
  }
  if (coptions.isset.ssl_client_key_string) {
    options.ssl_client_key_string =
      c2cc_otel_string(coptions.ssl_client_key_string);
  }
  if (coptions.isset.ssl_client_cert_path) {
    options.ssl_client_cert_path =
      c2cc_otel_string(coptions.ssl_client_cert_path);
  }
  if (coptions.isset.ssl_client_cert_string) {
    options.ssl_client_cert_string =
      c2cc_otel_string(coptions.ssl_client_cert_string);
  }
  if (coptions.isset.ssl_min_tls) {
    options.ssl_min_tls = c2cc_otel_string(coptions.ssl_min_tls);
  }
  if (coptions.isset.ssl_max_tls) {
    options.ssl_max_tls = c2cc_otel_string(coptions.ssl_max_tls);
  }
  if (coptions.isset.ssl_cipher) {
    options.ssl_cipher = c2cc_otel_string(coptions.ssl_cipher);
  }
  if (coptions.isset.ssl_cipher_suite) {
    options.ssl_cipher_suite = c2cc_otel_string(coptions.ssl_cipher_suite);
  }
  if (coptions.isset.compression) {
    options.compression = otel_otlp_compression_names[coptions.compression];
  }
  if (coptions.isset.retry_policy_max_attempts) {
    options.retry_policy_max_attempts = coptions.retry_policy_max_attempts;
  }
  if (coptions.isset.retry_policy_initial_backoff) {
    options.retry_policy_initial_backoff =
      std::chrono::milliseconds((int64_t) coptions.retry_policy_initial_backoff);
  }
  if (coptions.isset.retry_policy_max_backoff) {
    options.retry_policy_max_backoff =
      std::chrono::milliseconds((int64_t) coptions.retry_policy_max_backoff);
  }
  if (coptions.isset.retry_policy_backoff_multiplier) {
    options.retry_policy_backoff_multiplier =
      coptions.retry_policy_backoff_multiplier;
  }
}

template <typename T>
int otel_provider_http_default_options__(
  struct otel_provider_http_options &copts, T& opts) {

  cc2c_otel_string(opts.url, copts.url);
  switch(opts.content_type) {
    case otlp::HttpRequestContentType::kJson:
      copts.content_type = k_json;
      break;
    case otlp::HttpRequestContentType::kBinary:
      copts.content_type = k_binary;
      break;
    default:
      throw std::runtime_error("Internal error, unknown HTTP request content type");
      break;
  }
  copts.use_json_name = opts.use_json_name;
  copts.console_debug = opts.console_debug;
  copts.timeout = std::chrono::duration<double>(opts.timeout).count();
  cc2c_otel_strings(opts.http_headers, copts.http_headers);
  copts.ssl_insecure_skip_verify = opts.ssl_insecure_skip_verify;
  cc2c_otel_string(opts.ssl_ca_cert_path, copts.ssl_ca_cert_path);
  cc2c_otel_string(opts.ssl_ca_cert_string, copts.ssl_ca_cert_string);
  cc2c_otel_string(opts.ssl_client_key_path, copts.ssl_client_key_path);
  cc2c_otel_string(opts.ssl_client_key_string, copts.ssl_client_key_string);
  cc2c_otel_string(opts.ssl_client_cert_path, copts.ssl_client_cert_path);
  cc2c_otel_string(opts.ssl_client_cert_string, copts.ssl_client_cert_string);
  cc2c_otel_string(opts.ssl_min_tls, copts.ssl_min_tls);
  cc2c_otel_string(opts.ssl_max_tls, copts.ssl_max_tls);
  cc2c_otel_string(opts.ssl_cipher, copts.ssl_cipher);
  cc2c_otel_string(opts.ssl_cipher_suite, copts.ssl_cipher_suite);
  cc2c_otel_string(opts.compression, copts.compression);
  copts.retry_policy_max_attempts = opts.retry_policy_max_attempts;
  copts.retry_policy_initial_backoff = opts.retry_policy_initial_backoff.count();
  copts.retry_policy_max_backoff = opts.retry_policy_max_backoff.count();
  copts.retry_policy_backoff_multiplier = opts.retry_policy_backoff_multiplier;
  return 0;
}

#endif
