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
              otel_string_array_to_vec(attr.val.string_array
            );
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

extern "C" {

struct otel_scoped_span otel_start_span_(
  void *tracer_,
  const char *name,
  struct otel_attributes *attributes_,
  void* parent_) {

  RKeyValueIterable attributes(*attributes_);

  trace::StartSpanOptions opts;
  if (parent_) {
    struct otel_span *sparent = (struct otel_span *) parent_;
    trace::Span &parent = *(sparent->ptr);
    opts.parent = parent.GetContext();
  }

  struct otel_tracer *ts = (struct otel_tracer *) tracer_;
  trace::Tracer &tracer = *(ts->ptr);
  struct otel_span *ss = new struct otel_span;
  ss->ptr = tracer.StartSpan(name, attributes, opts);
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
