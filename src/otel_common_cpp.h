#ifndef OTEL_COMMON_CPP_H
#define OTEL_COMMON_CPP_H

#include <fstream>

#include "opentelemetry/sdk/trace/tracer_provider.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/sdk/logs/logger_provider.h"
#include "opentelemetry/logs/provider.h"

namespace trace_api      = opentelemetry::trace;
namespace trace_sdk      = opentelemetry::sdk::trace;
namespace logs_api       = opentelemetry::logs;
namespace logs_sdk       = opentelemetry::sdk::logs;
namespace nostd          = opentelemetry::nostd;

struct otel_span {
  nostd::shared_ptr<trace_api::Span> ptr;
};

struct otel_tracer_provider {
  std::unique_ptr<trace_sdk::TracerProvider> ptr;
  std::fstream stream;
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
};

void otel_string_to_char(const std::string &inp, struct otel_string &outp);
void otel_string_to_char(const nostd::string_view &inp, struct otel_string &outp);

#endif
