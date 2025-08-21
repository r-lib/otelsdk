#include <iostream>
#include <cstdlib>
#include <cstring>

#include "opentelemetry/nostd/shared_ptr.h"
#include "opentelemetry/sdk/version/version.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/trace/scope.h"
#include "opentelemetry/trace/tracer.h"
#include "opentelemetry/trace/tracer_provider.h"
#include "opentelemetry/common/key_value_iterable.h"
#include "opentelemetry/trace/propagation/http_trace_context.h"
#include "opentelemetry/trace/propagation/detail/string.h"

namespace trace   = opentelemetry::trace;
namespace nostd   = opentelemetry::nostd;
namespace common  = opentelemetry::common;
namespace detail  = opentelemetry::trace::propagation::detail;
namespace context = opentelemetry::context;

#include "otel_common.h"
#include "otel_common_cpp.h"
#include "otel_attributes.h"

std::vector<nostd::string_view> otel_string_array_to_vec(
    struct otel_string_array &s) {
  std::vector<nostd::string_view> v(s.count);
  for (size_t i = 0; i < s.count; i++) {
    v[i] = s.a[i];
  }
  return v;
}

class RSpanContextKeyValueIterable:
  public trace::SpanContextKeyValueIterable {
public:
  RSpanContextKeyValueIterable(struct otel_links &links) : links_(links) {
    num_real_links = 0;
    for (size_t i = 0; i < links_.count; i++) {
      if (links_.a[i].span) num_real_links++;
    }
  }
  virtual bool ForEachKeyValue(
    nostd::function_ref<
      bool(trace::SpanContext, const common::KeyValueIterable&)
    > callback) const noexcept {
    for (size_t i = 0; i < links_.count; i++) {
      if (!links_.a[i].span) continue;
      struct otel_span *ss = (struct otel_span *) links_.a[i].span;
      trace::Span &span = *(ss->ptr);
      trace::SpanContext ctx = span.GetContext();
      RKeyValueIterable attr(links_.a[i].attr);
      callback(ctx, attr);
    }
    return(true);
  }

  virtual size_t size() const noexcept {
    return num_real_links;
  }

private:
  otel_links &links_;
  size_t num_real_links;
};

extern "C" {

void *otel_get_active_span_context_(void *tracer_) {
  struct otel_tracer *ts = (struct otel_tracer *) tracer_;
  trace::Tracer &tracer = *(ts->ptr);

  nostd::shared_ptr<trace_api::Span> span = tracer.GetCurrentSpan();
  trace_api::SpanContext *span_context =
    new trace_api::SpanContext { span->GetContext() };
  return (void*) span_context;
}

void * otel_start_span_(
  void *tracer_,
  const char *name,
  struct otel_attributes *attributes_,
  struct otel_links *links_,
  double *start_system_time_,
  double *start_steady_time_,
  void* parent_,
  int is_root_span_,
  int span_kind_) {

  RKeyValueIterable attributes(*attributes_);
  RSpanContextKeyValueIterable links(*links_);

  trace::StartSpanOptions opts;
  context::Context ctx;
  if (is_root_span_) {
    ctx = ctx.SetValue(trace_api::kIsRootSpanKey, true);
    opts.parent = ctx;
  } else if (parent_) {
    trace_api::SpanContext *pctx = (trace_api::SpanContext*) parent_;
    if (pctx->IsValid()) {
      opts.parent = *((trace_api::SpanContext*) parent_);
    }
  }
  if (start_system_time_) {
    std::chrono::duration<double, std::ratio<1, 1>> ts(*start_system_time_);
    common::SystemTimestamp ts2(ts);
    opts.start_system_time = ts2;
  }
  if (start_steady_time_) {
    std::chrono::duration<double, std::ratio<1, 1>> ts(*start_steady_time_);
    common::SteadyTimestamp ts2(ts);
    opts.start_steady_time = ts2;
  }
  switch (span_kind_) {
    case 0: opts.kind = trace::SpanKind::kInternal; break;
    case 1: opts.kind = trace::SpanKind::kServer; break;
    case 2: opts.kind = trace::SpanKind::kClient; break;
    case 3: opts.kind = trace::SpanKind::kProducer; break;
    case 4: opts.kind = trace::SpanKind::kConsumer; break;
    default: break;
  }

  struct otel_tracer *ts = (struct otel_tracer *) tracer_;
  trace::Tracer &tracer = *(ts->ptr);
  struct otel_span *ss = new struct otel_span;
  ss->ptr = tracer.StartSpan(name, attributes, links, opts);

  return (void *) ss;
}

void *otel_span_get_context_(void *span_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  trace_api::SpanContext *span_context =
    new trace_api::SpanContext { span.GetContext() };
  return (void*) span_context;
}

int otel_span_is_valid_(void *span_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  trace_api::SpanContext span_context {span.GetContext()};
  bool valid = span_context.IsValid();
  return valid;
}

int otel_span_is_recording_(void *span_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  return span.IsRecording();
}

void otel_span_set_attribute_(void *span_, struct otel_attribute *attr) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  switch (attr->type) {
    case k_string: {
        nostd::string_view v(attr->val.string.s);
        span.SetAttribute(attr->name, v);
      }
      break;
    case k_boolean: {
        bool v = attr->val.boolean;
        span.SetAttribute(attr->name, v);
      }
      break;
    case k_double: {
        double v = attr->val.dbl;
        span.SetAttribute(attr->name, v);
      }
      break;
    case k_int64: {
        int64_t v = attr->val.int64;
        span.SetAttribute(attr->name, v);
      }
      break;
    case k_string_array: {
        std::vector<nostd::string_view> v =
          otel_string_array_to_vec(attr->val.string_array);
        nostd::span<const nostd::string_view> vv(v.data(), v.size());
        span.SetAttribute(attr->name, vv);
      }
      break;
    case k_boolean_array: {
        size_t c = attr->val.boolean_array.count;
        bool *v = new bool[c];
        for (size_t i = 0; i < c; i++) {
          v[i] = attr->val.boolean_array.a[i];
        }
        nostd::span<const bool> vv(v, c);
        span.SetAttribute(attr->name, vv);
        delete [] v;
      }
      break;
    case k_double_array: {
        nostd::span<const double> vv(
          attr->val.dbl_array.a,
          attr->val.dbl_array.count
        );
        span.SetAttribute(attr->name, vv);
      }
      break;
    case k_int64_array: {
        nostd::span<const int64_t> vv(
          attr->val.int64_array.a,
          attr->val.int64_array.count
        );
        span.SetAttribute(attr->name, vv);
      }
      break;
    default:
      break;
  }
}

void otel_span_add_event_(
    void *span_,
    const char *name,
    struct otel_attributes *attributes_,
    void *timestamp_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);

  RKeyValueIterable attributes(*attributes_);

  if (timestamp_) {
    double *timestamp = (double*) timestamp_;
    std::chrono::duration<double, std::ratio<1, 1>> ts(*timestamp);
    common::SystemTimestamp ts2(ts);
    span.AddEvent(name, ts2, attributes);
  } else {
    span.AddEvent(name, attributes);
  }
}

void otel_span_end_(void *span_, double *end_steady_time_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  trace::EndSpanOptions opts;
  if (end_steady_time_) {
    std::chrono::duration<double, std::ratio<1, 1>> ts(*end_steady_time_);
    common::SteadyTimestamp ts2(ts);
    opts.end_steady_time = ts2;
  }
  span.End();
}

void *otel_scope_start_(void *span_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Scope *scope = new trace::Scope(ss->ptr);
  return (void*) scope;
}

void otel_scope_end_(void *scope_) {
  trace::Scope *scope = (trace::Scope*) scope_;
  delete scope;
}

void otel_span_set_status_(
    void *span_,
    int status_code_,
    char *description_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  trace::StatusCode status_code;
  switch (status_code_) {
    case 0: status_code = trace::StatusCode::kUnset; break;
    case 1: status_code = trace::StatusCode::kOk; break;
    case 2: status_code = trace::StatusCode::kError; break;
    default: break;
  }

  if (description_) {
    span.SetStatus(status_code, description_);
  } else {
    span.SetStatus(status_code);
  }
}

void otel_span_update_name_(void *span_, const char *name_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  span.UpdateName(name_);
}

int otel_span_context_is_valid_(void* span_context_) {
  trace::SpanContext *span_context = (trace::SpanContext*) span_context_;
  return span_context->IsValid();
}

char otel_span_context_get_trace_flags_(void* span_context_) {
  trace::SpanContext *span_context = (trace::SpanContext*) span_context_;
  return span_context->trace_flags().flags();
}

int otel_trace_id_size_(void) {
  return trace_api::TraceId::kSize;
}

void otel_span_context_get_trace_id_(void* span_context_, char* buf) {
  trace::SpanContext *span_context = (trace::SpanContext*) span_context_;
  nostd::span<char, 2 * trace_api::TraceId::kSize>
    buf2(buf, 2 * trace_api::TraceId::kSize);
  span_context->trace_id().ToLowerBase16(buf2);
}

int otel_span_id_size_(void) {
  return trace_api::SpanId::kSize;
}

void otel_span_context_get_span_id_(void* span_context_, char* buf) {
  trace::SpanContext *span_context = (trace::SpanContext*) span_context_;
  nostd::span<char, 2 * trace_api::SpanId::kSize>
    buf2(buf, 2 * trace_api::SpanId::kSize);
  span_context->span_id().ToLowerBase16(buf2);
}

int otel_span_context_is_remote_(void* span_context_) {
  trace::SpanContext *span_context = (trace::SpanContext*) span_context_;
  return span_context->IsRemote();
}

int otel_span_context_is_sampled_(void* span_context_) {
  trace::SpanContext *span_context = (trace::SpanContext*) span_context_;
  return span_context->IsSampled();
}

// TODO: use HttpTraceContext class instead of doing this manually
void otel_span_context_to_headers_(
    void *span_context_, struct otel_string *traceparent,
    struct otel_string *tracestate) {
  trace::SpanContext *span_context = (trace::SpanContext*) span_context_;

  // traceparent
  auto kTraceParentSize = trace::propagation::kTraceParentSize;
  auto kTraceIdSize = trace::propagation::kTraceIdSize;
  auto kSpanIdSize = trace::propagation::kSpanIdSize;
  traceparent->s = (char*) malloc(kTraceParentSize);
  if (!traceparent->s) {
    return;
  }
  traceparent->size = kTraceParentSize;
  traceparent->s[0] = '0';
  traceparent->s[1] = '0';
  traceparent->s[2] = '-';
  span_context->trace_id().ToLowerBase16(
      nostd::span<char, 2 * trace::TraceId::kSize>
      {&traceparent->s[3], kTraceIdSize});
  traceparent->s[kTraceIdSize + 3] = '-';
  span_context->span_id().ToLowerBase16(
      nostd::span<char, 2 * trace::SpanId::kSize>
      {&traceparent->s[kTraceIdSize + 4], kSpanIdSize});
  traceparent->s[kTraceIdSize + kSpanIdSize + 4] = '-';
  span_context->trace_flags().ToLowerBase16(
      nostd::span<char, 2>{&traceparent->s[kTraceIdSize + kSpanIdSize + 5], 2});

  // tracestate
  auto &trace_state = span_context->trace_state();
  std::string hdr = trace_state->ToHeader();
  tracestate->s = (char*) malloc(hdr.size());
  if (!tracestate->s) {
    free(traceparent->s);
    traceparent->s = NULL;
    traceparent->size = 0;
    return;
  }
  tracestate->size = hdr.size();
  memcpy(tracestate->s, hdr.c_str(), tracestate->size);
}

// TODO: use HttpTraceContext class instead of doing this manually
static trace::SpanContext otel_extract_http_context__(
    nostd::string_view trace_parent, nostd::string_view trace_state) {
  std::array<nostd::string_view, 4> fields{};
  if (detail::SplitString(trace_parent, '-', fields.data(), 4) != 4) {
    return trace::SpanContext::GetInvalid();
  }

  nostd::string_view version_hex     = fields[0];
  nostd::string_view trace_id_hex    = fields[1];
  nostd::string_view span_id_hex     = fields[2];
  nostd::string_view trace_flags_hex = fields[3];

  auto kVersionSize = trace::propagation::kVersionSize;
  auto kTraceIdSize = trace::propagation::kTraceIdSize;
  auto kSpanIdSize = trace::propagation::kSpanIdSize;
  auto kTraceFlagsSize = trace::propagation::kTraceFlagsSize;
  auto kTraceParentSize = trace::propagation::kTraceParentSize;

  constexpr uint8_t kInvalidVersion        = 0xFF;
  constexpr uint8_t kDefaultAssumedVersion = 0x00;

  if (version_hex.size() != kVersionSize ||
      trace_id_hex.size() != kTraceIdSize ||
      span_id_hex.size() != kSpanIdSize ||
      trace_flags_hex.size() != kTraceFlagsSize) {
    return trace::SpanContext::GetInvalid();
  }

  if (!detail::IsValidHex(version_hex) ||
      !detail::IsValidHex(trace_id_hex) ||
      !detail::IsValidHex(span_id_hex) ||
      !detail::IsValidHex(trace_flags_hex)) {
    return trace::SpanContext::GetInvalid();
  }

  uint8_t version_binary;
  detail::HexToBinary(version_hex, &version_binary, sizeof(version_binary));
  if (version_binary == kInvalidVersion) {
    // invalid version encountered
    return trace::SpanContext::GetInvalid();
  }

  // See https://www.w3.org/TR/trace-context/#versioning-of-traceparent
  if (version_binary > kDefaultAssumedVersion) {
    // higher than default version detected
    if (trace_parent.size() < kTraceParentSize) {
      return trace::SpanContext::GetInvalid();
    }
  } else {
    // version is either lower or same as the default version
    if (trace_parent.size() != kTraceParentSize) {
      return trace::SpanContext::GetInvalid();
    }
  }

  trace::TraceId trace_id =
    trace::propagation::HttpTraceContext::TraceIdFromHex(trace_id_hex);
  trace::SpanId span_id   =
    trace::propagation::HttpTraceContext::SpanIdFromHex(span_id_hex);

  if (!trace_id.IsValid() || !span_id.IsValid()) {
    return trace::SpanContext::GetInvalid();
  }

  return trace::SpanContext(
    trace_id, span_id,
    trace::propagation::HttpTraceContext::TraceFlagsFromHex(trace_flags_hex),
    true, trace::TraceState::FromHeader(trace_state));
}

void *otel_extract_http_context_(
    const char *traceparent_, const char *tracestate_) {
  nostd::string_view trace_parent { traceparent_ ? traceparent_ : "" };
  nostd::string_view trace_state { tracestate_ ? tracestate_ : "" };
  trace::SpanContext *span_context = new trace::SpanContext {
   otel_extract_http_context__(trace_parent, trace_state) };
  return (void*) span_context;
}

} // extern "C"
