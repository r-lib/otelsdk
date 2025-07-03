#include "otel_common.h"
#include "otel_common_cpp.h"

#include "opentelemetry/sdk/common/attribute_utils.h"
#include "opentelemetry/exporters/otlp/otlp_file_client_options.h"

namespace common_sdk = opentelemetry::sdk::common;
namespace otlp       = opentelemetry::exporter::otlp;

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
  if (sz == 0) {
    s.s = nullptr;
  } else {
    s.s = (char*) malloc(sz);
    if (!s.s) {
      return 1;
    }
    memcpy(s.s, str.c_str(), sz);
  }
  s.size = sz;
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
    const trace_api::TraceFlags &flags, struct otel_trace_flags &cflags) {
  cflags.is_sampled = flags.IsSampled();
  cflags.is_random = flags.IsRandom();
  return 0;
}

int cc2c_otel_instrumentation_scope(
    trace_sdk::InstrumentationScope &is,
    struct otel_instrumentation_scope &cis) noexcept {
  try {
    const std::string &nm = is.GetName();
    const std::string &vs = is.GetVersion();
    const std::string &su = is.GetSchemaURL();
    const trace_sdk::InstrumentationScopeAttributes &at = is.GetAttributes();
    if (cc2c_otel_string(nm, cis.name)) throw std::runtime_error("");
    if (cc2c_otel_string(vs, cis.version)) throw std::runtime_error("");
    if (cc2c_otel_string(su, cis.schema_url)) throw std::runtime_error("");
    if (cc2c_otel_attributes(at, cis.attributes)) throw std::runtime_error("");
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

int cc2c_otel_events(
    const std::vector<trace_sdk::SpanDataEvent> &events,
    struct otel_events &cevents) {
  try {
    size_t sz = events.size();
    cevents.a = (struct otel_event*)
      malloc(sizeof(struct otel_event) * sz);
    if (!cevents.a) return 1;
    cevents.count = sz;

    size_t i = 0;
    for (auto it: events) {
      std::string name = it.GetName();
      std::chrono::nanoseconds ts = it.GetTimestamp().time_since_epoch();
      cevents.a[i].timestamp = ts.count() / 1000.0 / 1000.0 / 1000.0;
      const std::unordered_map<std::string, common_sdk::OwnedAttributeValue>
        &attr = it.GetAttributes();
      if (cc2c_otel_string(name, cevents.a[i].name)) {
        throw std::runtime_error("");
      }
      if (cc2c_otel_attributes(attr, cevents.a[i].attributes)) {
        throw std::runtime_error("");
      }
      i++;
    }

    return 0;

  } catch (...) {
    otel_events_free(&cevents);
    return 1;
  }

  return 0;
}

int cc2c_otel_links(
    const std::vector<trace_sdk::SpanDataLink> &links,
    struct otel_span_links &clinks) {
  try {
    size_t sz = links.size();
    clinks.a = (struct otel_span_link*)
      malloc(sizeof(struct otel_span_link) * sz);
    if (!clinks.a) return 1;
    clinks.count = sz;

    size_t i = 0;
    for (auto it: links) {
      const trace_api::SpanContext &spc = it.GetSpanContext();
      const trace_api::TraceId &trace_id = spc.trace_id();
      if (cc2c_otel_string(trace_id, clinks.a[i].trace_id)) {
        throw std::runtime_error("");
      }
      const trace_api::SpanId &span_id = spc.span_id();
      if (cc2c_otel_string(span_id, clinks.a[i].span_id)) {
        throw std::runtime_error("");
      }
      const std::unordered_map<std::string, common_sdk::OwnedAttributeValue>
        &attr = it.GetAttributes();
      if (cc2c_otel_attributes(attr, clinks.a[i].attributes)) {
        throw std::runtime_error("");
      }
      i++;
    }

    return 0;

  } catch (...) {
    otel_span_links_free(&clinks);
    return 1;
  }

  return 0;
}

void c2cc_file_exporter_options(
    const struct otel_file_exporter_options &options,
    otlp::OtlpFileClientFileSystemOptions &backend_opts) {
  if (options.has_file_pattern) {
    backend_opts.file_pattern = options.file_pattern.s;
  }
  if (options.has_alias_pattern) {
    backend_opts.alias_pattern = options.alias_pattern.s;
  }
  if (options.has_flush_interval) {
    backend_opts.flush_interval =
      std::chrono::microseconds((int64_t) options.flush_interval);
  }
  if (options.has_flush_count) {
    backend_opts.flush_count = options.flush_count;
  }
  if (options.has_file_size) {
    backend_opts.file_size = options.file_size;
  }
  if (options.has_rotate_size) {
    backend_opts.rotate_size = options.rotate_size;
  }
}

void cc2c_file_exporter_options(
    const otlp::OtlpFileClientFileSystemOptions &backend_opts,
    struct otel_file_exporter_options &options
) {
  options.has_file_pattern = 1;
  cc2c_otel_string(backend_opts.file_pattern, options.file_pattern);
  options.has_alias_pattern = 1;
  cc2c_otel_string(backend_opts.alias_pattern, options.alias_pattern);
  options.has_flush_interval = 1;
  options.flush_interval =
    std::chrono::duration<double>(backend_opts.flush_interval).count();
  options.has_flush_count = 1;
  options.flush_count = backend_opts.flush_count;
  options.has_file_size = 1;
  options.file_size = backend_opts.file_size;
  options.has_rotate_size = 1;
  options.rotate_size = backend_opts.rotate_size;
}
