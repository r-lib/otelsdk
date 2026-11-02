#include "opentelemetry/exporters/otlp/otlp_http_log_record_exporter.h"
#include "opentelemetry/exporters/otlp/otlp_http_log_record_exporter_factory.h"
#include "opentelemetry/exporters/otlp/otlp_file_client_options.h"
#include "opentelemetry/exporters/otlp/otlp_file_exporter_factory.h"
#include "opentelemetry/exporters/otlp/otlp_file_exporter_options.h"
#include "opentelemetry/exporters/otlp/otlp_file_log_record_exporter_factory.h"
#include "opentelemetry/exporters/otlp/otlp_file_log_record_exporter_options.h"
#include "opentelemetry/exporters/ostream/log_record_exporter_factory.h"
#include "opentelemetry/exporters/ostream/log_record_exporter.h"
#include "opentelemetry/sdk/logs/exporter.h"
#include "opentelemetry/sdk/logs/logger_context.h"
#include "opentelemetry/sdk/logs/logger_provider.h"
#include "opentelemetry/sdk/logs/logger_provider_factory.h"
#include "opentelemetry/sdk/logs/processor.h"
#include "opentelemetry/sdk/resource/resource.h"
#include "opentelemetry/sdk/logs/simple_log_record_processor_factory.h"
#include "opentelemetry/logs/logger_provider.h"
#include "opentelemetry/sdk/logs/batch_log_record_processor_options.h"

namespace logs_api       = opentelemetry::logs;
namespace logs_sdk       = opentelemetry::sdk::logs;
namespace logs_exporter  = opentelemetry::exporter::logs;
namespace otlp           = opentelemetry::exporter::otlp;
namespace common         = opentelemetry::common;
namespace resource       = opentelemetry::sdk::resource;

#include "otel_common.h"
#include "otel_common_cpp.h"
#include "otel_attributes.h"

extern "C" {

void otel_logger_provider_finally_(void *logger_provider_) {
  struct otel_logger_provider *lps =
    (struct otel_logger_provider *) logger_provider_;
  delete lps;
}

void otel_logger_finally_(void *logger_) {
  struct otel_logger *ts = (struct otel_logger *) logger_;
  delete ts;
}

void *otel_create_logger_provider_file_(
    struct otel_file_exporter_options *options) {
  opentelemetry::exporter::otlp::OtlpFileLogRecordExporterOptions opts;
  c2cc_file_exporter_backend(*options, opts.backend_options);

  auto exporter  = otlp::OtlpFileLogRecordExporterFactory::Create(opts);
  auto processor = logs_sdk::SimpleLogRecordProcessorFactory::Create(std::move(exporter));

  struct otel_logger_provider *lps = new otel_logger_provider();
  lps->ptr = logs_sdk::LoggerProviderFactory::Create(std::move(processor));

  return (void*) lps;
}

void *otel_create_logger_provider_memory_(
    int buffer_size, struct otel_attributes *resource_attributes) {
  RKeyValueIterable attributes_(*resource_attributes);
  struct otel_logger_provider *lps = new otel_logger_provider();
  lps->logdata.reset(new InMemoryLogData(buffer_size));
  auto exporter  = std::unique_ptr<logs_sdk::LogRecordExporter>(
    new InMemoryLogRecordExporter(lps->logdata));
  auto processor = logs_sdk::SimpleLogRecordProcessorFactory::Create(
    std::move(exporter));
  lps->ptr = logs_sdk::LoggerProviderFactory::Create(
    std::move(processor), resource::Resource::Create(&attributes_));

  return (void*) lps;
}

#define BAIL() throw std::runtime_error("");

static double timestamp_to_double(const common::SystemTimestamp &ts) {
  std::chrono::nanoseconds ns = ts.time_since_epoch();
  return ns.count() / 1000.0 / 1000.0 / 1000.0;
}

int otel_logger_provider_memory_get_logs_(
    void *logger_provider_, struct otel_log_data *cdata) {
  try {
    struct otel_logger_provider *lps =
      (struct otel_logger_provider *) logger_provider_;
    InMemoryLogData &logdata = *lps->logdata;
    std::vector<std::unique_ptr<logs_sdk::ReadWriteLogRecord>> data =
      logdata.Get();
    cdata->a = (struct otel_log_data1*)
      calloc(data.size() ? data.size() : 1, sizeof(struct otel_log_data1));
    if (!cdata->a) BAIL();
    cdata->count = data.size();
    for (size_t i = 0; i < data.size(); i++) {
      struct otel_log_data1 &out = cdata->a[i];
      const logs_sdk::ReadWriteLogRecord &rec = *data[i];

      // all zero ids mean that there is no trace or span
      const trace_api::TraceId &trace_id = rec.GetTraceId();
      if (trace_id.IsValid()) {
        if (cc2c_otel_string(trace_id, out.trace_id)) BAIL();
      }
      const trace_api::SpanId &span_id = rec.GetSpanId();
      if (span_id.IsValid()) {
        if (cc2c_otel_string(span_id, out.span_id)) BAIL();
      }
      const trace_api::TraceFlags &tf = rec.GetTraceFlags();
      if (cc2c_otel_trace_flags(tf, out.flags)) BAIL();

      const common_sdk::OwnedAttributeValue &body = rec.GetBody();
      if (nostd::holds_alternative<std::string>(body)) {
        if (cc2c_otel_string(nostd::get<std::string>(body), out.body)) BAIL();
      }

      out.severity = static_cast<int>(rec.GetSeverity());
      nostd::string_view sevtxt = rec.GetSeverityText();
      if (cc2c_otel_string(sevtxt, out.severity_text)) BAIL();
      nostd::string_view evname = rec.GetEventName();
      if (cc2c_otel_string(evname, out.event_name)) BAIL();
      out.timestamp = timestamp_to_double(rec.GetTimestamp());
      out.observed_timestamp = timestamp_to_double(rec.GetObservedTimestamp());

      const resource::Resource &res = rec.GetResource();
      const std::string &schema_url = res.GetSchemaURL();
      if (cc2c_otel_string(schema_url, out.schema_url)) BAIL();
      const std::unordered_map<std::string, common_sdk::OwnedAttributeValue>
        &rattr = res.GetAttributes();
      if (cc2c_otel_attributes(rattr, out.resource_attributes)) BAIL();

      // copy, the conversion function needs a non-const reference
      trace_sdk::InstrumentationScope is =rec.GetInstrumentationScope();
      if (cc2c_otel_instrumentation_scope(is, out.instrumentation_scope)) {
        BAIL();
      }

      const std::unordered_map<std::string, common_sdk::OwnedAttributeValue>
        &attr = rec.GetAttributes();
      if (cc2c_otel_attributes(attr, out.attributes)) BAIL();
    }
    return 0;
  } catch(...) {
    otel_log_data_free(cdata);
    return 1;
  }
}

void otel_logger_provider_file_options_defaults_(
  struct otel_file_exporter_options *options
) {
  opentelemetry::exporter::otlp::OtlpFileLogRecordExporterOptions opts;
  otlp::OtlpFileClientFileSystemOptions backend_opts =
    nostd::get<otlp::OtlpFileClientFileSystemOptions>(opts.backend_options);

  cc2c_file_exporter_options(backend_opts, *options);
}

int otel_logger_provider_flush_(void *logger_provider_) {
  struct otel_logger_provider *lps =
    (struct otel_logger_provider *) logger_provider_;
  logs_sdk::LoggerProvider &logger_provider = *(lps->ptr);
  int res = logger_provider.ForceFlush();
  if (lps->stream.is_open()) {
    lps->stream.flush();
  }
  return res;
}

int otel_logger_provider_shutdown_(void *logger_provider_) {
  struct otel_logger_provider *lps =
    (struct otel_logger_provider *) logger_provider_;
  logs_sdk::LoggerProvider &logger_provider = *(lps->ptr);
  int res = logger_provider.Shutdown();
  if (lps->stream.is_open()) {
    lps->stream.flush();
  }
  return res;
}

int otel_get_minimum_log_severity_(void *logger_) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  return ls->minimum_severity;
}

void otel_set_minimum_log_severity_(void *logger_, int minimum_severity_) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  ls->minimum_severity = minimum_severity_;
}

void *otel_get_logger_(
    void *logger_provider_, const char *name, int minimum_severity,
    const char *version, const char *schema_url,
    struct otel_attributes *attributes) {
  struct otel_logger_provider *lps =
    (struct otel_logger_provider *) logger_provider_;
  logs_sdk::LoggerProvider &logger_provider = *(lps->ptr);
  RKeyValueIterable attributes_(*attributes);
  struct otel_logger *ls = new otel_logger;
  ls->minimum_severity = minimum_severity;
  ls->ptr = logger_provider.GetLogger(
    name, name, version ? version : "", schema_url ? schema_url : "",
    attributes_);

  return (void*) ls;
}

int otel_logger_get_name_(void *logger_, struct otel_string *cname) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  logs_api::Logger &logger = *(ls->ptr);
  const nostd::string_view name = logger.GetName();
  return cc2c_otel_string(name, *cname);
}

logs_api::Severity to_severity(int x) {
  switch (x) {
    case 1: return logs_api::Severity::kTrace;
    case 2: return logs_api::Severity::kTrace2;
    case 3: return logs_api::Severity::kTrace3;
    case 4: return logs_api::Severity::kTrace4;

    case 5: return logs_api::Severity::kDebug;
    case 6: return logs_api::Severity::kDebug2;
    case 7: return logs_api::Severity::kDebug3;
    case 8: return logs_api::Severity::kDebug4;

    case 9: return logs_api::Severity::kInfo;
    case 10: return logs_api::Severity::kInfo2;
    case 11: return logs_api::Severity::kInfo3;
    case 12: return logs_api::Severity::kInfo4;

    case 13: return logs_api::Severity::kWarn;
    case 14: return logs_api::Severity::kWarn2;
    case 15: return logs_api::Severity::kWarn3;
    case 16: return logs_api::Severity::kWarn4;

    case 17: return logs_api::Severity::kError;
    case 18: return logs_api::Severity::kError2;
    case 19: return logs_api::Severity::kError3;
    case 20: return logs_api::Severity::kError4;

    case 21: return logs_api::Severity::kFatal;
    case 22: return logs_api::Severity::kFatal2;
    case 23: return logs_api::Severity::kFatal3;
    case 24: return logs_api::Severity::kFatal4;

    default: return logs_api::Severity::kInvalid; // # nocov LCOV_EXCL_LINE
  }
}

int otel_logger_is_enabled_(void *logger_, int severity_) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  return ls->minimum_severity <= severity_ ? 1 : 0;
}

static char hexchar(char c) {
  if(c >= '0' && c <= '9') {
    return c - '0';
  } else if (c >= 'A' && c <= 'F') {
    // # nocov start LCOV_EXCL_START
    return 10 + (c - 'A');
    // # nocov end LCOV_EXCL_STOP
  } else if (c >= 'a' && c <= 'f') {
    return 10 + (c - 'a');
  } else {
    // does not happen
    return 0; // # nocov LCOV_EXCL_LINE
  }
}

void otel_log_(
    void *logger_, const char *format_, int severity_,
    const char *span_id_, const char *trace_id_, void *timestamp_,
    void *observed_timestamp_, struct otel_attributes *attributes_) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  if (severity_ < ls->minimum_severity) return;
  logs_api::Logger &logger = *(ls->ptr);
  logs_api::Severity severity = to_severity(severity_);
  RKeyValueIterable attributes(*attributes_);

  nostd::unique_ptr<logs_api::LogRecord> lr = logger.CreateLogRecord();
  lr->SetSeverity(severity);
  lr->SetBody(format_);

  if (trace_id_) {
    // trace_id_ must have the right length
    uint8_t buf[trace_api::TraceId::kSize];
    for (int si = 0; si < trace_api::TraceId::kSize; si++) {
      buf[si] = hexchar(trace_id_[si * 2]) * 16 +
        hexchar(trace_id_[si * 2 + 1]);
    }
    nostd::span<const uint8_t, trace_api::TraceId::kSize>
      buf2(buf, trace_api::TraceId::kSize);
    trace_api::TraceId tid(buf2);
    lr->SetTraceId(tid);
  }

  if (span_id_) {
    // span_id_ must have the right length
    uint8_t buf[trace_api::SpanId::kSize];
    for (int si = 0; si < trace_api::SpanId::kSize; si++) {
      buf[si] = hexchar(span_id_[si * 2]) * 16 +
        hexchar(span_id_[si * 2 + 1]);
    }
    nostd::span<const uint8_t, trace_api::SpanId::kSize>
      buf2(buf, trace_api::SpanId::kSize);
    trace_api::SpanId tid(buf2);
    lr->SetSpanId(tid);
  }

  std::shared_ptr<common::SystemTimestamp> ts2(nullptr);
  if (timestamp_) {
    double *timestamp = (double*) timestamp_;
    std::chrono::duration<double, std::ratio<1, 1>> ts(*timestamp);
    ts2.reset(new common::SystemTimestamp(ts));
    lr->SetTimestamp(*ts2);
  }

   std::shared_ptr<common::SystemTimestamp> ots2(nullptr);
  if (observed_timestamp_) {
    double *observed_timestamp = (double*) observed_timestamp_;
    std::chrono::duration<double, std::ratio<1, 1>> ots(*observed_timestamp);
    ots2.reset(new common::SystemTimestamp(ots));
    lr->SetObservedTimestamp(*ots2);
  }

  attributes.ForEachKeyValue(
    [&] (nostd::string_view key, common::AttributeValue value) -> bool {
      lr->SetAttribute(key, value);
      return true;
  });

  logger.EmitLogRecord(std::move(lr));
}

int otel_logger_provider_http_default_options_(
  struct otel_provider_http_options *copts
) {
  otlp::OtlpHttpLogRecordExporterOptions opts;
  return otel_provider_http_default_options__(*copts, opts);
}

int otel_blrp_defaults_(struct otel_bsp_options *coptions) {
  logs_sdk::BatchLogRecordProcessorOptions options;
  coptions->max_queue_size = options.max_queue_size;
  coptions->schedule_delay = options.schedule_delay_millis.count();
  coptions->max_export_batch_size = options.max_export_batch_size;
  return 0;
}

} // extern "C"
