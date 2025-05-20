#include "opentelemetry/exporters/otlp/otlp_http_log_record_exporter.h"
#include "opentelemetry/exporters/otlp/otlp_http_log_record_exporter_factory.h"
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

namespace logs_api       = opentelemetry::logs;
namespace logs_sdk       = opentelemetry::sdk::logs;
namespace logs_exporter  = opentelemetry::exporter::logs;
namespace otlp           = opentelemetry::exporter::otlp;
namespace common         = opentelemetry::common;

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

void *otel_create_logger_provider_stdstream_(const char *stream) {
  int sout = !strcmp(stream, "stdout");
  int serr = !strcmp(stream, "stderr");
  struct otel_logger_provider *tps = new otel_logger_provider;

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

void *otel_create_logger_provider_http_(void) {
  auto exporter  = otlp::OtlpHttpLogRecordExporterFactory::Create();
  auto processor = logs_sdk::SimpleLogRecordProcessorFactory::Create(std::move(exporter));

  struct otel_logger_provider *lps = new otel_logger_provider;
  lps->ptr = logs_sdk::LoggerProviderFactory::Create(std::move(processor));

  return (void*) lps;
}

void otel_logger_provider_flush_(void *logger_provider_) {
  struct otel_logger_provider *lps =
    (struct otel_logger_provider *) logger_provider_;
  if (lps->stream.is_open()) {
    lps->stream.flush();
  }
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

void *otel_logger_get_name_(void *logger_, struct otel_string *cname) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  logs_api::Logger &logger = *(ls->ptr);
  const nostd::string_view name = logger.GetName();
  otel_string_to_char(name, *cname);
  return NULL;
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

    default: return logs_api::Severity::kInvalid;
  }
}

int otel_logger_is_enabled_(void *logger_, int severity_) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  return ls->minimum_severity <= severity_ ? 1 : 0;
}

void otel_log_(
    void *logger_, int severity_, const char *format_,
    struct otel_attributes *attributes_) {
  struct otel_logger *ls = (struct otel_logger*) logger_;
  if (severity_ < ls->minimum_severity) return;
  logs_api::Logger &logger = *(ls->ptr);
  logs_api::Severity severity = to_severity(severity_);
  RKeyValueIterable attributes(*attributes_);

  logger.Log(severity, format_, attributes);
}

} // extern "C"
