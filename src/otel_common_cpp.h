#ifndef OTEL_COMMON_CPP_H
#define OTEL_COMMON_CPP_H

#include "opentelemetry/sdk/trace/tracer_provider.h"
#include "opentelemetry/trace/provider.h"

namespace trace_api      = opentelemetry::trace;
namespace trace_sdk      = opentelemetry::sdk::trace;
namespace nostd          = opentelemetry::nostd;

struct otel_span {
  nostd::shared_ptr<trace_api::Span> ptr;
};

struct otel_tracer_provider {
  std::unique_ptr<trace_sdk::TracerProvider> ptr;
};

struct otel_tracer {
  nostd::shared_ptr<trace_api::Tracer> ptr;
};

#endif
