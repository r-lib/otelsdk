#include <iostream>

#include "opentelemetry/nostd/shared_ptr.h"
#include "opentelemetry/sdk/version/version.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/trace/scope.h"
#include "opentelemetry/trace/tracer.h"
#include "opentelemetry/trace/tracer_provider.h"

namespace trace = opentelemetry::trace;
namespace nostd = opentelemetry::nostd;

#include "otel_common.h"
#include "otel_common_cpp.h"

extern "C" {

struct otel_scoped_span otel_start_span_(void *tracer_, const char *name,
                                         void* parent_) {
  struct otel_tracer *ts = (struct otel_tracer *) tracer_;
  trace::Tracer &tracer = *(ts->ptr);
  struct otel_span *ss = new struct otel_span;
  trace::StartSpanOptions opts;
  if (parent_) {
    struct otel_span *sparent = (struct otel_span *) parent_;
    trace::Span &parent = *(sparent->ptr);
    opts.parent = parent.GetContext();
  }
  ss->ptr = tracer.StartSpan(name, opts);
  trace::Scope *scope = new trace::Scope(ss->ptr);

  struct otel_scoped_span sspan = { ss, scope };
  return sspan;
}

void otel_span_end_(void *span_, void *scope_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  span.End();
  trace::Scope *scope = (trace::Scope*) scope_;
  delete scope;
}

}
