#include "opentelemetry/common/attribute_value.h"
#include "opentelemetry/exporters/ostream/metric_exporter_factory.h"
#include "opentelemetry/metrics/meter_provider.h"
#include "opentelemetry/sdk/metrics/aggregation/aggregation_config.h"
#include "opentelemetry/sdk/metrics/export/periodic_exporting_metric_reader_factory.h"
#include "opentelemetry/sdk/metrics/export/periodic_exporting_metric_reader_options.h"
#include "opentelemetry/sdk/metrics/export/metric_producer.h"
#include "opentelemetry/sdk/metrics/instruments.h"
#include "opentelemetry/sdk/metrics/meter_provider.h"
#include "opentelemetry/sdk/metrics/meter_provider_factory.h"
#include "opentelemetry/sdk/metrics/metric_reader.h"
#include "opentelemetry/sdk/metrics/push_metric_exporter.h"
#include "opentelemetry/sdk/metrics/meter_context.h"
#include "opentelemetry/sdk/metrics/meter_context_factory.h"
#include "opentelemetry/sdk/metrics/meter_provider.h"
#include "opentelemetry/sdk/metrics/meter_provider_factory.h"
#include "opentelemetry/sdk/metrics/metric_reader.h"
#include "opentelemetry/exporters/otlp/otlp_http.h"
#include "opentelemetry/exporters/otlp/otlp_http_metric_exporter_factory.h"
#include "opentelemetry/exporters/otlp/otlp_http_metric_exporter_options.h"
#include "opentelemetry/exporters/memory/in_memory_metric_exporter_factory.h"

namespace metrics_sdk      = opentelemetry::sdk::metrics;
namespace common           = opentelemetry::common;
namespace metrics_exporter = opentelemetry::exporter::metrics;
namespace metrics_api      = opentelemetry::metrics;
namespace otlp             = opentelemetry::exporter::otlp;
namespace memory           = opentelemetry::exporter::memory;

#include "otel_common.h"
#include "otel_common_cpp.h"
#include "otel_attributes.h"

extern "C" {

void otel_meter_provider_finally_(void *meter_provider_) {
  struct otel_meter_provider *mps =
    (struct otel_meter_provider *) meter_provider_;
  delete mps;
}

void otel_meter_finally_(void *meter_) {
  struct otel_meter *ms = (struct otel_meter *) meter_;
  delete ms;
}

void otel_counter_finally_(void *counter_) {
  struct otel_counter *cs = (struct otel_counter *) counter_;
  delete cs;
}

void otel_up_down_counter_finally_(void *up_down_counter_) {
  struct otel_up_down_counter *cs =
    (struct otel_up_down_counter *) up_down_counter_;
  delete cs;
}

void otel_histogram_finally_(void *histogram_) {
  struct otel_histogram *cs = (struct otel_histogram *) histogram_;
  delete cs;
}

void otel_gauge_finally_(void *gauge_) {
  struct otel_gauge *cs = (struct otel_gauge *) gauge_;
  delete cs;
}

void *otel_create_meter_provider_stdstream_(
    const char *stream, int export_interval, int export_timeout) {
  int sout = !strcmp(stream, "stdout");
  int serr = !strcmp(stream, "stderr");
  struct otel_meter_provider *mps = new otel_meter_provider;

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

void *otel_create_meter_provider_http_(
    int export_interval, int export_timeout) {
  struct otel_meter_provider *mps = new otel_meter_provider;

  std::string version{"1.2.0"};
  std::string schema{"https://opentelemetry.io/schemas/1.2.0"};

  // Initialize and set the global MeterProvider
  metrics_sdk::PeriodicExportingMetricReaderOptions reader_options;
  reader_options.export_interval_millis =
    std::chrono::milliseconds(export_interval);
  reader_options.export_timeout_millis  =
    std::chrono::milliseconds(export_timeout);

  auto exporter = otlp::OtlpHttpMetricExporterFactory::Create();
  auto reader = metrics_sdk::PeriodicExportingMetricReaderFactory::Create(
    std::move(exporter),
    reader_options
  );
  auto context = metrics_sdk::MeterContextFactory::Create();
  context->AddMetricReader(std::move(reader));

  mps->ptr = metrics_sdk::MeterProviderFactory::Create(std::move(context));
  return (void*) mps;
}

void *otel_create_meter_provider_memory_(
    int export_interval, int export_timeout, int buffer_size,
    int temporality) {
  struct otel_meter_provider *mps = new otel_meter_provider;
  mps->metricdata.reset(new memory::CircularBufferInMemoryMetricData(buffer_size));

  std::string version{"1.2.0"};
  std::string schema{"https://opentelemetry.io/schemas/1.2.0"};

  // Initialize and set the global MeterProvider
  metrics_sdk::PeriodicExportingMetricReaderOptions reader_options;
  reader_options.export_interval_millis =
    std::chrono::milliseconds(export_interval);
  reader_options.export_timeout_millis  =
    std::chrono::milliseconds(export_timeout);

  auto exporter = memory::InMemoryMetricExporterFactory::Create(mps->metricdata);
  auto reader = metrics_sdk::PeriodicExportingMetricReaderFactory::Create(
    std::move(exporter),
    reader_options
  );
  auto context = metrics_sdk::MeterContextFactory::Create();
  context->AddMetricReader(std::move(reader));

  mps->ptr = metrics_sdk::MeterProviderFactory::Create(std::move(context));
  return (void*) mps;
}

#define BAIL() throw std::runtime_error("");

int otel_meter_provider_memory_get_metrics_(
    void *meter_provider_, struct otel_metric_data_t *data) {
  try {
    struct otel_meter_provider *mps =
      (struct otel_meter_provider *) meter_provider_;
    memory::CircularBufferInMemoryMetricData &metricdata = *mps->metricdata;
    std::vector<std::unique_ptr<metrics_sdk::ResourceMetrics>> data =
      metricdata.Get();
    for (const auto &rm: data) {
      const common_sdk::AttributeMap &resattrs = rm->resource_->GetAttributes();
      for (const metrics_sdk::ScopeMetrics &smd: rm->scope_metric_data_) {
        const std::string &scopename = smd.scope_->GetName();
        const std::string &scopeversion = smd.scope_->GetVersion();
        const std::string &scopeschemaurl = smd.scope_->GetSchemaURL();
        const common_sdk::AttributeMap &scopeattr = smd.scope_->GetAttributes();
        for (const metrics_sdk::MetricData &md: smd.metric_data_) {
          const metrics_sdk::InstrumentDescriptor &instr =
            md.instrument_descriptor;
          const metrics_sdk::AggregationTemporality &at =
            md.aggregation_temporality;
          common::SystemTimestamp start = md.start_ts;
          common::SystemTimestamp end = md.end_ts;
          for (const metrics_sdk::PointDataAttributes &dp: md.point_data_attr_) {
            const metrics_sdk::PointAttributes &pattr = dp.attributes;
            const metrics_sdk::PointType &pd = dp.point_data;
//            cc2c_point_type(pd, struct otel_point_)
          }
        }
      }
    }


    return 0;
  } catch(...) {
    otel_metric_data_free(data);
    return 1;
  }
}

void otel_meter_provider_flush_(void *meter_provider_, int timeout) {
  struct otel_meter_provider *mps =
    (struct otel_meter_provider *) meter_provider_;
  metrics_sdk::MeterProvider &meter_provider = *(mps->ptr);
  if (timeout < 0) {
    meter_provider.ForceFlush();
  } else {
    meter_provider.ForceFlush((std::chrono::microseconds) timeout);
  }
  if (mps->stream.is_open()) {
    mps->stream.flush();
  }
}

void otel_meter_provider_shutdown_(void *meter_provider_, int timeout) {
  struct otel_meter_provider *mps =
    (struct otel_meter_provider *) meter_provider_;
  metrics_sdk::MeterProvider &meter_provider = *(mps->ptr);
  if (timeout < 0) {
    meter_provider.Shutdown();
  } else {
    meter_provider.Shutdown((std::chrono::microseconds) timeout);
  }
  if (mps->stream.is_open()) {
    mps->stream.flush();
  }
}

void *otel_get_meter_(
    void *meter_provider_, const char *name, const char *version,
    const char *schema_url, struct otel_attributes *attributes) {
  struct otel_meter_provider *mps =
    (struct otel_meter_provider *) meter_provider_;
  metrics_sdk::MeterProvider &meter_provider = *(mps->ptr);
  RKeyValueIterable attributes_(*attributes);
  struct otel_meter *ms = new otel_meter;
  ms->ptr = meter_provider.GetMeter(
    name, version ? version : "", schema_url ? schema_url : "",
    &attributes_);

  return (void*) ms;
}

void *otel_create_counter_(
    void *meter_, const char *name, const char *description,
    const char *unit) {
  struct otel_meter *ms = (struct otel_meter*) meter_;
  metrics_api::Meter &meter = *(ms->ptr);
  struct otel_counter *cs = new otel_counter;
  cs->ptr = meter.CreateDoubleCounter(
    name, description ? description : "", unit ? unit : "");

  return (void*) cs;
}

void otel_counter_add_(
    void *counter_, double cvalue, struct otel_attributes *attributes_) {
  struct otel_counter *cs = (struct otel_counter*) counter_;
  metrics_api::Counter<double> &counter = *(cs->ptr);
  RKeyValueIterable attributes(*attributes_);
  counter.Add(cvalue, attributes);
}

void *otel_create_up_down_counter_(
    void *meter_, const char *name, const char *description,
    const char *unit) {
  struct otel_meter *ms = (struct otel_meter*) meter_;
  metrics_api::Meter &meter = *(ms->ptr);
  struct otel_up_down_counter *cs = new otel_up_down_counter;
  cs->ptr = meter.CreateDoubleUpDownCounter(
    name, description ? description : "", unit ? unit : "");

  return (void*) cs;
}

void otel_up_down_counter_add_(
    void *up_down_counter_, double cvalue,
    struct otel_attributes *attributes_) {
  struct otel_up_down_counter *cs =
    (struct otel_up_down_counter*) up_down_counter_;
  metrics_api::UpDownCounter<double> &up_down_counter = *(cs->ptr);
  RKeyValueIterable attributes(*attributes_);
  up_down_counter.Add(cvalue, attributes);
}

void *otel_create_histogram_(
    void *meter_, const char *name, const char *description,
    const char *unit) {
  struct otel_meter *ms = (struct otel_meter*) meter_;
  metrics_api::Meter &meter = *(ms->ptr);
  struct otel_histogram *cs = new otel_histogram;
  cs->ptr = meter.CreateDoubleHistogram(
    name, description ? description : "", unit ? unit : "");

  return (void*) cs;
}

void otel_histogram_record_(
    void *histogram_, double cvalue, struct otel_attributes *attributes_) {
  struct otel_histogram *cs = (struct otel_histogram*) histogram_;
  metrics_api::Histogram<double> &histogram = *(cs->ptr);
  RKeyValueIterable attributes(*attributes_);
  histogram.Record(cvalue, attributes);
}

void *otel_create_gauge_(
    void *meter_, const char *name, const char *description,
    const char *unit) {
  struct otel_meter *ms = (struct otel_meter*) meter_;
  metrics_api::Meter &meter = *(ms->ptr);
  struct otel_gauge *cs = new otel_gauge;
  cs->ptr = meter.CreateDoubleGauge(
    name, description ? description : "", unit ? unit : "");

  return (void*) cs;
}

void otel_gauge_record_(
    void *gauge_, double cvalue, struct otel_attributes *attributes_) {
  struct otel_gauge *cs = (struct otel_gauge*) gauge_;
  metrics_api::Gauge<double> &gauge = *(cs->ptr);
  RKeyValueIterable attributes(*attributes_);
  gauge.Record(cvalue, attributes);
}

} // extern "C"
