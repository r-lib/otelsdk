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
#include "opentelemetry/exporters/otlp/otlp_file_client_options.h"
#include "opentelemetry/exporters/otlp/otlp_file_metric_exporter_factory.h"
#include "opentelemetry/exporters/otlp/otlp_file_metric_exporter_options.h"

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

void *otel_create_meter_provider_file_(
    int export_interval, int export_timeout,
    struct otel_file_exporter_options *options) {
  struct otel_meter_provider *mps = new otel_meter_provider;

  std::string version{"1.2.0"};
  std::string schema{"https://opentelemetry.io/schemas/1.2.0"};

  // Initialize and set the global MeterProvider
  metrics_sdk::PeriodicExportingMetricReaderOptions reader_options;
  reader_options.export_interval_millis =
    std::chrono::milliseconds(export_interval);
  reader_options.export_timeout_millis  =
    std::chrono::milliseconds(export_timeout);

  otlp::OtlpFileMetricExporterOptions opts;
  otlp::OtlpFileClientFileSystemOptions backend_opts =
    nostd::get<otlp::OtlpFileClientFileSystemOptions>(opts.backend_options);
  c2cc_file_exporter_options(*options, backend_opts);
  opts.backend_options = backend_opts;

  auto exporter = otlp::OtlpFileMetricExporterFactory::Create(opts);
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

#define BAIL(msg) do {                                    \
  throw std::runtime_error(""); } while (0)

int otel_meter_provider_memory_get_metrics_(
    void *meter_provider_, struct otel_metrics_data *cdata) {
  try {
    struct otel_meter_provider *mps =
      (struct otel_meter_provider *) meter_provider_;
    memory::CircularBufferInMemoryMetricData &metricdata = *mps->metricdata;
    std::vector<std::unique_ptr<metrics_sdk::ResourceMetrics>> data =
      metricdata.Get();

    cdata->count = data.size();
    cdata->a = (struct otel_resource_metrics*)
      malloc(sizeof(struct otel_resource_metrics) * cdata->count);
    if (!cdata->a) BAIL("Out of memory");

    size_t rmidx = 0;
    for (const auto &rm: data) {
      struct otel_resource_metrics &crm = cdata->a[rmidx++];
      crm.count = rm->scope_metric_data_.size();
      crm.scope_metric_data = (struct otel_scope_metrics *)
        malloc(sizeof(struct otel_scope_metrics) * crm.count);
      if (!crm.scope_metric_data) BAIL("");
      memset(crm.scope_metric_data, 0, sizeof(struct otel_scope_metrics) * crm.count);
      const common_sdk::AttributeMap &resattrs = rm->resource_->GetAttributes();
      if (cc2c_otel_attributes(resattrs, crm.attributes)) BAIL("");

      size_t smdidx = 0;
      for (const metrics_sdk::ScopeMetrics &smd: rm->scope_metric_data_) {
        struct otel_scope_metrics &csmd = crm.scope_metric_data[smdidx++];
        csmd.count = smd.metric_data_.size();
        csmd.metric_data = (struct otel_metric_data *)
          malloc(sizeof(struct otel_metric_data) * csmd.count);
        if (!csmd.metric_data) BAIL("");
        memset(csmd.metric_data, 0, sizeof(struct otel_metric_data) * csmd.count);

        const std::string &sn = smd.scope_->GetName();
        if (cc2c_otel_string(sn, csmd.instrumentation_scope.name)) BAIL("");
        const std::string &sv = smd.scope_->GetVersion();
        if (cc2c_otel_string(sv, csmd.instrumentation_scope.version)) BAIL("");
        const std::string &ssu = smd.scope_->GetSchemaURL();
        if (cc2c_otel_string(ssu, csmd.instrumentation_scope.schema_url)) BAIL("");
        const common_sdk::AttributeMap &sattr = smd.scope_->GetAttributes();
        if (cc2c_otel_attributes(sattr, csmd.instrumentation_scope.attributes)) BAIL("");

        size_t mdidx = 0;
        for (const metrics_sdk::MetricData &md: smd.metric_data_) {
          struct otel_metric_data &cmd = csmd.metric_data[mdidx++];
          cmd.count = md.point_data_attr_.size();
          cmd.point_data_attr = (struct otel_point_data_attributes*)
            malloc(sizeof(struct otel_point_data_attributes) * cmd.count);
          if (!cmd.point_data_attr) BAIL("");
          memset(cmd.point_data_attr, 0, sizeof(struct otel_point_data_attributes) * cmd.count);
          const metrics_sdk::InstrumentDescriptor &instr =
            md.instrument_descriptor;
          if (cc2c_otel_string(instr.name_, cmd.instrument_name)) BAIL("");
          if (cc2c_otel_string(instr.description_, cmd.instrument_description)) BAIL("");
          if (cc2c_otel_string(instr.unit_, cmd.instrument_unit)) BAIL("");
          cmd.instrument_type = static_cast<enum otel_instrument_type>(instr.type_);
          cmd.instrument_value_type = static_cast<enum otel_instrument_value_type>(instr.value_type_);
          const metrics_sdk::AggregationTemporality &at =
            md.aggregation_temporality;
          cmd.aggregation_temporality = static_cast<enum otel_aggregation_temporality>(at);
          std::chrono::nanoseconds start = md.start_ts.time_since_epoch();
          cmd.start_time = start.count() / 1000.0 / 1000.0 / 1000.0;
          std::chrono::nanoseconds end = md.end_ts.time_since_epoch();
          cmd.end_time = end.count() / 1000.0 / 1000.0 / 1000.0;
          size_t dpidx = 0;
          for (const metrics_sdk::PointDataAttributes &dp: md.point_data_attr_) {
            struct otel_point_data_attributes &cdp =
              cmd.point_data_attr[dpidx++];
            const metrics_sdk::PointAttributes &pattr = dp.attributes;
            if (cc2c_otel_attributes(pattr, cdp.attributes)) BAIL("");
            const metrics_sdk::PointType &pd = dp.point_data;

            if (nostd::holds_alternative<metrics_sdk::SumPointData>(pd)) {
              const metrics_sdk::SumPointData &d =
                nostd::get<metrics_sdk::SumPointData>(pd);
              cdp.point_type = k_sum_point_data;
              cdp.value.sum_point_data.is_monotonic = d.is_monotonic_;
              if (nostd::holds_alternative<int64_t>(d.value_)) {
                int64_t v = nostd::get<int64_t>(d.value_);
                cdp.value.sum_point_data.value_type = k_value_int64;
                cdp.value.sum_point_data.value.int64 = v;
              } else {
                double v = nostd::get<double>(d.value_);
                cdp.value.sum_point_data.value_type = k_value_double;
                cdp.value.sum_point_data.value.dbl = v;
              }
            } else if (nostd::holds_alternative<metrics_sdk::HistogramPointData>(pd)) {
              const metrics_sdk::HistogramPointData &d =
                nostd::get<metrics_sdk::HistogramPointData>(pd);
              cdp.point_type = k_histogram_point_data;
              if (nostd::holds_alternative<int64_t>(d.sum_)) {
                cdp.value.histogram_point_data.value_type = k_value_int64;
                cdp.value.histogram_point_data.sum.int64 =
                  nostd::get<int64_t>(d.sum_);
                cdp.value.histogram_point_data.min.int64 =
                  nostd::get<int64_t>(d.min_);
                cdp.value.histogram_point_data.max.int64 =
                  nostd::get<int64_t>(d.max_);
              } else {
                cdp.value.histogram_point_data.value_type = k_value_double;
                cdp.value.histogram_point_data.sum.dbl =
                  nostd::get<double>(d.sum_);
                cdp.value.histogram_point_data.min.dbl =
                  nostd::get<double>(d.min_);
                cdp.value.histogram_point_data.max.dbl =
                  nostd::get<double>(d.max_);
              }
              cdp.value.histogram_point_data.count = d.count_;
              cdp.value.histogram_point_data.record_min_max = d.record_min_max_;
              if (cc2c_otel_double_array(
                  d.boundaries_, cdp.value.histogram_point_data.boundaries)) {
                BAIL("");
              }
              if (cc2c_otel_double_array(
                  d.counts_, cdp.value.histogram_point_data.counts)) {
                BAIL("");
              }

            } else if (nostd::holds_alternative<metrics_sdk::LastValuePointData>(pd)) {
              const metrics_sdk::LastValuePointData &d =
                nostd::get<metrics_sdk::LastValuePointData>(pd);
              cdp.point_type = k_last_value_point_data;
              if (nostd::holds_alternative<int64_t>(d.value_)) {
                cdp.value.last_value_point_data.value_type = k_value_int64;
                cdp.value.last_value_point_data.value.int64 =
                  nostd::get<int64_t>(d.value_);
              } else {
                cdp.value.last_value_point_data.value_type = k_value_double;
                cdp.value.last_value_point_data.value.dbl =
                  nostd::get<double>(d.value_);
              }
              cdp.value.last_value_point_data.is_lastvalue_valid =
                d.is_lastvalue_valid_;
              std::chrono::nanoseconds t = d.sample_ts_.time_since_epoch();
              cdp.value.last_value_point_data.sample_ts =
                t.count() / 1000.0 / 1000.0 / 1000.0;

            } else if (nostd::holds_alternative<metrics_sdk::DropPointData>(pd)) {
              cdp.point_type = k_drop_point_data;
            } else {
              BAIL("");
            }
          }
        }
      }
    }

    return 0;
  } catch(...) {
    otel_metrics_data_free(cdata);
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
