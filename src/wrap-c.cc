#include "otel_common.h"
#include "otel_common_cpp.h"

int cc2c_otel_string(
    const trace_api::TraceId &trace_id, struct otel_string &s) {
  const auto sz = trace_api::TraceId::kSize;
  s.s = (char*) malloc(2 * sz);
  if (!s.s) {
    return 1;
  }
  s.size = 2 * sz;
  trace_id.ToLowerBase16(nostd::span<char, 2 * sz>(s.s, 2 * sz));
  return 0;
}

int cc2c_otel_string(
    const trace_api::SpanId &span_id, struct otel_string &s) {
  const auto sz = trace_api::SpanId::kSize;
  s.s = (char*) malloc(2 * sz);
  if (!s.s) {
    return 1;
  }
  s.size = 2 * sz;
  span_id.ToLowerBase16(nostd::span<char, 2 * sz>(s.s, 2 * sz));
  return 0;
}

int cc2c_otel_string(const std::string &str, struct otel_string &s) {
  const auto sz = str.size();
  s.s = (char*) malloc(sz);
  if (!s.s) {
    return 1;
  }
  s.size = sz;
  memcpy(s.s, str.c_str(), sz);
  return 0;
}

int cc2c_otel_string(
    const nostd::string_view &sv, struct otel_string &s) {
  const auto sz = sv.size();
  s.s = (char*) malloc(sz);
  if (!s.s) {
    return 1;
  }
  s.size = sz;
  memcpy(s.s, sv.data(), sz);
  return 0;
}

int cc2c_otel_trace_flags(
    const trace_api::TraceFlags &flags, struct otel_trace_flags_t &cflags) {
  cflags.is_sampled = flags.IsSampled();
  cflags.is_random = flags.IsRandom();
  return 0;
}

int cc2c_otel_instrumentation_scope(
    trace_sdk::InstrumentationScope &is,
    struct otel_instrumentation_scope_t &cis) noexcept {
  try {
    const std::string &nm = is.GetName();
    const std::string &vs = is.GetVersion();
    const std::string &su = is.GetSchemaURL();
    if (cc2c_otel_string(nm, cis.name)) throw std::runtime_error("");
    if (cc2c_otel_string(vs, cis.version)) throw std::runtime_error("");
    if (cc2c_otel_string(su, cis.schema_url)) throw std::runtime_error("");
    return 0;
  } catch(...) {
    otel_instrumentation_scope_free(&cis);
    return 1;
  }
}

int cc2c_otel_attribute(
    const std::string &key, const common_sdk::OwnedAttributeValue &attr,
    struct otel_attribute &cattr) {
  try {
    cattr.name = strdup(key.c_str());
    if (!cattr.name) throw std::runtime_error("");

    if (nostd::holds_alternative<bool>(attr)) {
      cattr.type = k_boolean;
      cattr.val.boolean = nostd::get<bool>(attr);

    } else if (nostd::holds_alternative<int32_t>(attr)) {
      cattr.type = k_int64;
      cattr.val.int64 = nostd::get<int32_t>(attr);

    } else if (nostd::holds_alternative<uint32_t>(attr)) {
      cattr.type = k_double;
      cattr.val.dbl = nostd::get<uint32_t>(attr);

    } else if (nostd::holds_alternative<int64_t>(attr)) {
      cattr.type = k_int64;
      cattr.val.int64 = nostd::get<int64_t>(attr);

    } else if (nostd::holds_alternative<double>(attr)) {
      cattr.type = k_double;
      cattr.val.dbl = nostd::get<double>(attr);

    } else if (nostd::holds_alternative<std::string>(attr)) {
      cattr.type = k_string;
      const std::string &s = nostd::get<std::string>(attr);
      if (cc2c_otel_string(s, cattr.val.string)) throw std::runtime_error("");

    } else if (nostd::holds_alternative<std::vector<bool>>(attr)) {
      cattr.type = k_boolean_array;
      const std::vector<bool> &b = nostd::get<std::vector<bool>>(attr);
      if (cc2c_otel_boolean_array(b, cattr.val.boolean_array)) {
        throw std::runtime_error("");
      }

    } else if (nostd::holds_alternative<std::vector<int32_t>>(attr)) {
      cattr.type = k_int64_array;
      const std::vector<int32_t> &i = nostd::get<std::vector<int32_t>>(attr);
      if (cc2c_otel_int64_array(i, cattr.val.int64_array)) {
        throw std::runtime_error("");
      }

    } else if (nostd::holds_alternative<std::vector<uint32_t>>(attr)) {
      cattr.type = k_double_array;
      const std::vector<uint32_t> &i = nostd::get<std::vector<uint32_t>>(attr);
      if (cc2c_otel_double_array(i, cattr.val.dbl_array)) {
        throw std::runtime_error("");
      }

    } else if (nostd::holds_alternative<std::vector<int64_t>>(attr)) {
      cattr.type = k_int64_array;
      const std::vector<int64_t> &i = nostd::get<std::vector<int64_t>>(attr);
      if (cc2c_otel_int64_array(i, cattr.val.int64_array)) {
        throw std::runtime_error("");
      }

    } else if (nostd::holds_alternative<std::vector<double>>(attr)) {
      cattr.type = k_double_array;
      const std::vector<double> &i = nostd::get<std::vector<double>>(attr);
      if (cc2c_otel_double_array(i, cattr.val.dbl_array)) {
        throw std::runtime_error("");
      }

    } else if (nostd::holds_alternative<std::vector<std::string>>(attr)) {
      cattr.type = k_string_array;
      const std::vector<std::string> &i =
        nostd::get<std::vector<std::string>>(attr);
      if (cc2c_otel_string_array(i, cattr.val.string_array)) {
        throw std::runtime_error("");
      }

    } else if (nostd::holds_alternative<uint64_t>(attr)) {
      cattr.type = k_double;
      cattr.val.dbl = nostd::get<uint64_t>(attr);

    } else if (nostd::holds_alternative<std::vector<uint64_t>>(attr)) {
      cattr.type = k_double_array;
      const std::vector<uint64_t> &i = nostd::get<std::vector<uint64_t>>(attr);
      if (cc2c_otel_double_array(i, cattr.val.dbl_array)) {
        throw std::runtime_error("");
      }

    } else if (nostd::holds_alternative<std::vector<uint8_t>>(attr)) {
      cattr.type = k_double_array;
      const std::vector<uint8_t> &i = nostd::get<std::vector<uint8_t>>(attr);
      if (cc2c_otel_double_array(i, cattr.val.dbl_array)) {
        throw std::runtime_error("");
      }

    } else {
      return 2;
    }
    return 0;

  } catch(...) {
    otel_attribute_free(&cattr);
    return 1;
  }
}

int cc2c_otel_attributes(
    const std::unordered_map<std::string, common_sdk::OwnedAttributeValue> &attrs,
    struct otel_attributes &cattrs) {
  try {
    size_t sz = attrs.size();
    cattrs.a = (struct otel_attribute*)
      malloc(sizeof(struct otel_attribute) * sz);
    if (!cattrs.a) return 1;
    cattrs.count = sz;

    size_t i = 0;
    for (auto it: attrs) {
      const std::string &key = it.first;
      const common_sdk::OwnedAttributeValue &val = it.second;
      if (cc2c_otel_attribute(key, val, cattrs.a[i++])) return 1;
    }

    return 0;

  } catch (...) {
    otel_attributes_free(&cattrs);
    return 1;
  }
}

int cc2c_otel_boolean_array(
    const std::vector<bool> &a, struct otel_boolean_array &ca) {
  ca.a = (int*) malloc(sizeof(int) * a.size());
  if (!ca.a) return 1;
  ca.count = a.size();
  size_t i = 0;
  for (auto it: a) {
    ca.a[i++] = it;
  }
  return 0;
}

int cc2c_otel_int64_array(
    const std::vector<int64_t> &a, struct otel_int64_array &ca) {
  ca.a = (int64_t*) malloc(sizeof(int64_t) * a.size());
  if (!ca.a) return 1;
  ca.count = a.size();
  memcpy(ca.a, a.data(), sizeof(int64_t) * a.size());
  return 0;
}

int cc2c_otel_int64_array(
    const std::vector<int32_t> &a, struct otel_int64_array &ca) {
  ca.a = (int64_t*) malloc(sizeof(int64_t) * a.size());
  if (!ca.a) return 1;
  ca.count = a.size();
  size_t i = 0;
  for (auto it: a) {
    ca.a[i++] = it;
  }
  return 0;
}

int cc2c_otel_double_array(
    const std::vector<double> &a, struct otel_double_array &ca) {
  ca.a = (double*) malloc(sizeof(double) * a.size());
  if (!ca.a) return 1;
  ca.count = a.size();
  memcpy(ca.a, a.data(), sizeof(double) * a.size());
  return 0;
}

int cc2c_otel_double_array(
    const std::vector<uint32_t> &a, struct otel_double_array &ca) {
  ca.a = (double*) malloc(sizeof(double) * a.size());
  if (!ca.a) return 1;
  ca.count = a.size();
  size_t i = 0;
  for (auto it: a) {
    ca.a[i++] = it;
  }
  return 0;
}

int cc2c_otel_double_array(
    const std::vector<uint64_t> &a, struct otel_double_array &ca) {
  ca.a = (double*) malloc(sizeof(double) * a.size());
  if (!ca.a) return 1;
  ca.count = a.size();
  size_t i = 0;
  for (auto it: a) {
    ca.a[i++] = it;
  }
  return 0;
}

int cc2c_otel_double_array(
    const std::vector<uint8_t> &a, struct otel_double_array &ca) {
  ca.a = (double*) malloc(sizeof(double) * a.size());
  if (!ca.a) return 1;
  ca.count = a.size();
  size_t i = 0;
  for (auto it: a) {
    ca.a[i++] = it;
  }
  return 0;
}

// creates an owned string array
int cc2c_otel_string_array(
    const std::vector<std::string> &a, struct otel_string_array &ca) {
  ca.a = (char**) malloc(sizeof(char*) * a.size());
  if (!ca.a) return 1;

  size_t ts = 0;
  for (auto s: a) {
    ts += s.size() + 1;
  }
  ca.storage = (char*) malloc(ts);
  if (!ca.storage) {
    free(ca.a);
    ca.a = NULL;
    return 1;
  }
  ca.count = a.size();

  size_t idx = 0;
  char *pos = ca.storage;
  for (auto s: a) {
    ca.a[idx++] = pos;
    size_t l = s.size();
    memcpy(pos, s.c_str(), l);
    pos += l;
    *pos = '\0';
    pos++;
  }
  return 0;
}
