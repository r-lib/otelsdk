#include <iostream>

#include "opentelemetry/nostd/shared_ptr.h"
#include "opentelemetry/sdk/version/version.h"
#include "opentelemetry/trace/provider.h"
#include "opentelemetry/trace/scope.h"
#include "opentelemetry/trace/tracer.h"
#include "opentelemetry/trace/tracer_provider.h"
#include "opentelemetry/common/key_value_iterable.h"

namespace trace  = opentelemetry::trace;
namespace nostd  = opentelemetry::nostd;
namespace common = opentelemetry::common;

#include "otel_common.h"
#include "otel_common_cpp.h"

std::vector<nostd::string_view> otel_string_array_to_vec(
    struct otel_string_array &s) {
  std::vector<nostd::string_view> v(s.count);
  for (auto i = 0; i < s.count; i++) {
    v[i] = s.a[i];
  }
  return v;
}

class RKeyValueIterable : public common::KeyValueIterable {
public:
  RKeyValueIterable(struct otel_attributes &attributes)
    : attributes_(attributes) { }

  virtual bool ForEachKeyValue(
      nostd::function_ref<bool(nostd::string_view, common::AttributeValue)>
      callback) const noexcept {
    for (auto i = 0; i < attributes_.count; i++) {
      struct otel_attribute &attr = attributes_.a[i];
      bool cont = true;
      switch (attr.type) {
        case k_string:
          cont = callback(attr.name, attr.val.string.s);
          break;
        case k_boolean:
          cont = callback(attr.name, attr.val.boolean);
          break;
        case k_double:
          cont = callback(attr.name, attr.val.dbl);
          break;
        case k_int64:
          cont = callback(attr.name, attr.val.int64);
          break;
        case k_string_array: {
            std::vector<nostd::string_view> v =
              otel_string_array_to_vec(attr.val.string_array);
            nostd::span<const nostd::string_view> vv(v.data(), v.size());
            cont = callback(attr.name, vv);
          }
          break;
        case k_boolean_array: {
            size_t c = attr.val.boolean_array.count;
            bool *v = new bool[c];
            for (auto i = 0; i < c; i++) {
              v[i] = attr.val.boolean_array.a[i];
            }
            nostd::span<const bool> vv(v, c);
            cont = callback(attr.name, vv);
            delete [] v;
          }
          break;
        case k_double_array: {
            nostd::span<const double> vv(
              attr.val.dbl_array.a,
              attr.val.dbl_array.count
            );
            cont = callback(attr.name, vv);
          }
          break;
        case k_int64_array: {
            nostd::span<const int64_t> vv(
              attr.val.int64_array.a,
              attr.val.int64_array.count
            );
            cont = callback(attr.name, vv);
          }
          break;
        default:
          // noexcept, but this cannot happen, anyway.
          break;
      }
      if (!cont) return(false);
    }
    return(true);
  }

  virtual size_t size() const noexcept {
    return attributes_.count;
  }

private:
  struct otel_attributes &attributes_;
};

class RSpanContextKeyValueIterable:
  public trace::SpanContextKeyValueIterable {
public:
  RSpanContextKeyValueIterable(struct otel_links &links) : links_(links) {
    num_real_links = 0;
    for (auto i = 0; i < links_.count; i++) {
      if (links_.a[i].span) num_real_links++;
    }
  }
  virtual bool ForEachKeyValue(
    nostd::function_ref<
      bool(trace::SpanContext, const common::KeyValueIterable&)
    > callback) const noexcept {
    for (auto i = 0; i < links_.count; i++) {
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

struct otel_scoped_span otel_start_span_(
  void *tracer_,
  const char *name,
  struct otel_attributes *attributes_,
  struct otel_links *links_,
  double *start_system_time_,
  double *start_steady_time_,
  void* parent_,
  int span_kind_) {

  RKeyValueIterable attributes(*attributes_);
  RSpanContextKeyValueIterable links(*links_);

  trace::StartSpanOptions opts;
  if (parent_) {
    struct otel_span *sparent = (struct otel_span *) parent_;
    trace::Span &parent = *(sparent->ptr);
    opts.parent = parent.GetContext();
  }
  if (start_system_time_) {
    double *start_system_time = (double*) start_system_time_;
    std::chrono::duration<double, std::ratio<1, 1>> ts(*start_system_time);
    common::SystemTimestamp ts2(ts);
    opts.start_system_time = ts2;
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
  ss->ptr = tracer.StartSpan(name, attributes, opts);
  trace::Scope *scope = new trace::Scope(ss->ptr);

  struct otel_scoped_span sspan = { ss, scope };
  return sspan;
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
        for (auto i = 0; i < c; i++) {
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

void otel_span_end_(void *span_, void *scope_) {
  struct otel_span *ss = (struct otel_span *) span_;
  trace::Span &span = *(ss->ptr);
  span.End();
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

}
