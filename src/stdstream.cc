#include <iostream>
#include <fstream>
#include <utility>

#include "opentelemetry/exporters/ostream/span_exporter_factory.h"
#include "opentelemetry/sdk/trace/exporter.h"
#include "opentelemetry/sdk/trace/processor.h"
#include "opentelemetry/sdk/trace/simple_processor_factory.h"
#include "opentelemetry/sdk/trace/tracer_provider.h"
#include "opentelemetry/sdk/trace/tracer_provider_factory.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/trace/tracer_provider.h"
#include "opentelemetry/trace/tracer.h"

#include "opentelemetry/exporters/ostream/metric_exporter_factory.h"
#include "opentelemetry/metrics/meter_provider.h"
#include "opentelemetry/sdk/metrics/export/periodic_exporting_metric_reader_factory.h"
#include "opentelemetry/sdk/metrics/export/periodic_exporting_metric_reader_options.h"
#include "opentelemetry/sdk/metrics/export/metric_producer.h"
#include "opentelemetry/sdk/metrics/instruments.h"
#include "opentelemetry/sdk/metrics/meter_provider.h"
#include "opentelemetry/sdk/metrics/meter_provider_factory.h"
#include "opentelemetry/sdk/metrics/meter_context_factory.h"

#include "opentelemetry/exporters/ostream/log_record_exporter_factory.h"
#include "opentelemetry/exporters/ostream/log_record_exporter.h"
#include "opentelemetry/exporters/otlp/otlp_http_log_record_exporter.h"
#include "opentelemetry/exporters/otlp/otlp_http_log_record_exporter_factory.h"
#include "opentelemetry/sdk/logs/exporter.h"
#include "opentelemetry/sdk/logs/logger_context.h"
#include "opentelemetry/sdk/logs/logger_provider.h"
#include "opentelemetry/sdk/logs/logger_provider_factory.h"
#include "opentelemetry/sdk/logs/processor.h"
#include "opentelemetry/sdk/logs/simple_log_record_processor_factory.h"
#include "opentelemetry/logs/logger_provider.h"

#include "opentelemetry/sdk/resource/resource.h"

namespace trace_api        = opentelemetry::trace;
namespace trace_sdk        = opentelemetry::sdk::trace;
namespace trace_exporter   = opentelemetry::exporter::trace;
namespace metrics_exporter = opentelemetry::exporter::metrics;
namespace metrics_api      = opentelemetry::metrics;
namespace resource         = opentelemetry::sdk::resource;
namespace logs_api         = opentelemetry::logs;
namespace logs_sdk         = opentelemetry::sdk::logs;
namespace logs_exporter    = opentelemetry::exporter::logs;

#include "otel_common.h"
#include "otel_common_cpp.h"
#include "otel_attributes.h"

void *otel_create_tracer_provider_stdstream_(
  const char *stream, struct otel_attributes *resource_attributes) {
  int sout = !strcmp(stream, "stdout");
  int serr = !strcmp(stream, "stderr");
  struct otel_tracer_provider *tps = new otel_tracer_provider();
  RKeyValueIterable attributes_(*resource_attributes);

  if (sout || serr) {
    std::ostream &out = sout ? std::cout : std::cerr;
    auto exporter  = trace_exporter::OStreamSpanExporterFactory::Create(out);
    auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));
    tps->ptr = trace_sdk::TracerProviderFactory::Create(
      std::move(processor), resource::Resource::Create(&attributes_));
    return (void*) tps;

  } else {
    tps->stream.open(stream, std::fstream::out | std::fstream::app);
    // no buffering, because we use this for testing
    tps->stream.rdbuf()->pubsetbuf(0,0);
    auto exporter  = trace_exporter::OStreamSpanExporterFactory::Create(tps->stream);
    auto processor = trace_sdk::SimpleSpanProcessorFactory::Create(std::move(exporter));
    tps->ptr = trace_sdk::TracerProviderFactory::Create(
      std::move(processor), resource::Resource::Create(&attributes_));
    return tps;
  }
}

void *otel_create_meter_provider_stdstream_(
    const char *stream, int export_interval, int export_timeout) {
  int sout = !strcmp(stream, "stdout");
  int serr = !strcmp(stream, "stderr");
  struct otel_meter_provider *mps = new otel_meter_provider();

  std::string version{"1.2.0"};
  std::string schema{"https://opentelemetry.io/schemas/1.2.0"};

  // Initialize and set the global MeterProvider
  metrics_sdk::PeriodicExportingMetricReaderOptions reader_options;
  reader_options.export_interval_millis =
    std::chrono::milliseconds(export_interval);
  reader_options.export_timeout_millis  =
    std::chrono::milliseconds(export_timeout);

  if (sout || serr) {
    std::ostream &out = sout ? std::cout : std::cerr;
    auto exporter = metrics_exporter::OStreamMetricExporterFactory::Create(out);
    auto reader = metrics_sdk::PeriodicExportingMetricReaderFactory::Create(
      std::move(exporter),
      reader_options
    );
    auto context = metrics_sdk::MeterContextFactory::Create();
    context->AddMetricReader(std::move(reader));

    mps->ptr = metrics_sdk::MeterProviderFactory::Create(std::move(context));
    return (void*) mps;

  } else {
    mps->stream.open(stream, std::fstream::out | std::fstream::app);
    // no buffering, because we use this for testing
    mps->stream.rdbuf()->pubsetbuf(0,0);
    auto exporter = metrics_exporter::OStreamMetricExporterFactory::Create(mps->stream);
    auto reader = metrics_sdk::PeriodicExportingMetricReaderFactory::Create(
      std::move(exporter),
      reader_options
    );
    auto context = metrics_sdk::MeterContextFactory::Create();
    context->AddMetricReader(std::move(reader));

    mps->ptr = metrics_sdk::MeterProviderFactory::Create(std::move(context));
    return (void*) mps;
  }
}

void *otel_create_logger_provider_stdstream_(const char *stream) {
  int sout = !strcmp(stream, "stdout");
  int serr = !strcmp(stream, "stderr");
  struct otel_logger_provider *tps = new otel_logger_provider();

  if (sout || serr) {
    std::ostream &out = sout ? std::cout : std::cerr;
    auto exporter  = logs_exporter::OStreamLogRecordExporterFactory::Create(out);
    auto processor = logs_sdk::SimpleLogRecordProcessorFactory::Create(std::move(exporter));
    tps->ptr = logs_sdk::LoggerProviderFactory::Create(std::move(processor));
    return (void*) tps;

  } else {
    tps->stream.open(stream, std::fstream::out | std::fstream::app);
    // no buffering, because we use this for testing
    tps->stream.rdbuf()->pubsetbuf(0,0);
    auto exporter  = logs_exporter::OStreamLogRecordExporterFactory::Create(tps->stream);
    auto processor = logs_sdk::SimpleLogRecordProcessorFactory::Create(std::move(exporter));
    tps->ptr = logs_sdk::LoggerProviderFactory::Create(std::move(processor));
    return tps;
  }
}

void *otel_create_logger_provider_http_(
  struct otel_http_exporter_options *options_,
  struct otel_attributes *resource_attributes
) {
  otlp::OtlpHttpLogRecordExporterOptions options;
  c2cc_otel_http_exporter_options<otlp::OtlpHttpLogRecordExporterOptions>(*options_, options);
  auto exporter  = otlp::OtlpHttpLogRecordExporterFactory::Create(options);
  auto processor = logs_sdk::SimpleLogRecordProcessorFactory::Create(std::move(exporter));

  RKeyValueIterable attributes_(*resource_attributes);
  struct otel_logger_provider *lps = new otel_logger_provider();
  lps->ptr = logs_sdk::LoggerProviderFactory::Create(
    std::move(processor),
    resource::Resource::Create(&attributes_)
  );

  return (void*) lps;
}
