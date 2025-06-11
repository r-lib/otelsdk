#include "opentelemetry/nostd/shared_ptr.h"
#include "opentelemetry/common/key_value_iterable.h"

namespace nostd  = opentelemetry::nostd;
namespace common = opentelemetry::common;

#include "otel_common.h"
#include "otel_common_cpp.h"

std::vector<nostd::string_view> otel_string_array_to_vec(
    struct otel_string_array &s);

class RKeyValueIterable : public common::KeyValueIterable {
public:
  RKeyValueIterable(struct otel_attributes &attributes)
    : attributes_(attributes) { }

  virtual bool ForEachKeyValue(
      nostd::function_ref<bool(nostd::string_view, common::AttributeValue)>
      callback) const noexcept {
    for (size_t i = 0; i < attributes_.count; i++) {
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
            for (size_t i = 0; i < c; i++) {
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
