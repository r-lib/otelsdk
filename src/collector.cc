#include <iostream>

#include "opentelemetry/proto/collector/trace/v1/trace_service.pb.h"
#include "opentelemetry/proto/collector/logs/v1/logs_service.pb.h"
#include "opentelemetry/proto/collector/metrics/v1/metrics_service.pb.h"
#include "opentelemetry/proto/trace/v1/trace.pb.h"
#include "opentelemetry/proto/logs/v1/logs.pb.h"
#include "opentelemetry/proto/metrics/v1/metrics.pb.h"
#include "opentelemetry/proto/common/v1/common.pb.h"
#include "opentelemetry/proto/collector/common/v1/status.pb.h"

#include "otel_common.h"
#include "otel_common_cpp.h"
#include "errors.h"

namespace cltrace   = opentelemetry::proto::collector::trace::v1;
namespace cllogs    = opentelemetry::proto::collector::logs::v1;
namespace clmetrics = opentelemetry::proto::collector::metrics::v1;
namespace trace     = opentelemetry::proto::trace::v1;
namespace logs      = opentelemetry::proto::logs::v1;
namespace metrics   = opentelemetry::proto::metrics::v1;
namespace common    = opentelemetry::proto::common::v1;

// TODO: attributes
int otel_decode_log_record_(
  const char *str_, size_t len,
  struct otel_collector_resource_logs *rls_
) {
  try {
    cllogs::ExportLogsServiceRequest elsr;
    std::string str(str_, len);
    if (!elsr.ParseFromString(str)) {
      return 1;
    }
    size_t rl_size = elsr.resource_logs_size();
    rls_->resource_logs = (struct otel_collector_resource_log*)
      calloc(rl_size, sizeof(struct otel_collector_resource_log));
    if (!rls_->resource_logs) throw std::runtime_error("Out of memory");
    rls_->count = rl_size;
    for (size_t rli = 0; rli < rl_size; rli++) {
      const logs::ResourceLogs &rl = elsr.resource_logs(rli);
      struct otel_collector_resource_log *rl_ = &rls_->resource_logs[rli];
      cc2c_otel_string(rl.schema_url(), rl_->schema_url);
      size_t sl_size = rl.scope_logs_size();
      rl_->scope_logs = (struct otel_collector_scope_log*)
        calloc(sl_size, sizeof(struct otel_collector_scope_log));
      if (!rl_->scope_logs) throw std::runtime_error("Out of memory");
      rl_->count = sl_size;
      for (size_t sli = 0; sli < sl_size; sli++) {
        const logs::ScopeLogs &sl = rl.scope_logs(sli);
        struct otel_collector_scope_log *sl_ = &rl_->scope_logs[sli];
        cc2c_otel_string(sl.schema_url(), sl_->schema_url);
        size_t lr_size = sl.log_records_size();
        sl_->log_records = (struct otel_collector_log_record*)
          calloc(lr_size, sizeof(struct otel_collector_log_record));
        if (!sl_->log_records) throw std::runtime_error("Out of memory");
        sl_->count = lr_size;
        for (size_t lri = 0; lri < lr_size; lri++) {
          const logs::LogRecord &lr = sl.log_records(lri);
          struct otel_collector_log_record *lr_ = &sl_->log_records[lri];
          cc2c_otel_string(lr.severity_text(), lr_->severity_text);
          cc2c_otel_string(lr.trace_id(), lr_->trace_id);
          cc2c_otel_string(lr.span_id(), lr_->span_id);
          cc2c_otel_string(lr.event_name(), lr_->event_name);
          lr_->has_body = lr.has_body();
          lr_->time_stamp = lr.time_unix_nano();
          lr_->observed_time_stamp = lr.observed_time_unix_nano();
          lr_->dropped_attributes_count = lr.dropped_attributes_count();

          lr_->body = { nullptr, 0 };
          if (lr_->has_body) {
            common::AnyValue body = lr.body();
            if (body.has_string_value()) {
              cc2c_otel_string(body.string_value(), lr_->body);
            }
          }
        }
      }
    }
    return 0;

  } catch(...) {
    otel_collector_resource_logs_free(rls_);
    return 1;
  }
}

int otel_decode_metrics_record_(
  const char *str_, size_t len,
  struct otel_collector_resource_metrics *rms_
) {
  try {
    clmetrics::ExportMetricsServiceRequest emsr;
    std::string str(str_, len);
    if (!emsr.ParseFromString(str)) {
      return 1;
    }
    size_t rm_size = emsr.resource_metrics_size();
    rms_->resource_metrics = (struct otel_collector_resource_metric*)
      calloc(rm_size, sizeof(struct otel_collector_resource_metric));
    rms_->count = rm_size;
    for (size_t rmi = 0; rmi < rm_size; rmi++) {
      const metrics::ResourceMetrics &rm = emsr.resource_metrics(rmi);
      struct otel_collector_resource_metric *rm_ = &rms_->resource_metrics[rmi];
      cc2c_otel_string(rm.schema_url(), rm_->schema_url);
      size_t sm_size = rm.scope_metrics_size();
      rm_->scope_metrics = (struct otel_collector_scope_metric*)
        calloc(sm_size, sizeof(struct otel_collector_scope_metric));
      if (!rm_->scope_metrics) throw std::runtime_error("Out of memory");
      rm_->count = sm_size;
      for (size_t smi = 0; smi < sm_size; smi++) {
        const metrics::ScopeMetrics &sm = rm.scope_metrics(smi);
        struct otel_collector_scope_metric *sm_ = &rm_->scope_metrics[smi];
        cc2c_otel_string(sm.schema_url(), sm_->schema_url);
        size_t m_size = sm.metrics_size();
        sm_->metrics = (struct otel_collector_metric*)
          calloc(m_size, sizeof(struct otel_collector_metric));
        if (!sm_->metrics) throw std::runtime_error("Out of memory");
        sm_->count = m_size;
        for (size_t mi = 0; mi < m_size; mi++) {
          const metrics::Metric &m = sm.metrics(mi);
          struct otel_collector_metric *m_ = &sm_->metrics[mi];
          cc2c_otel_string(m.name(), m_->name);
          cc2c_otel_string(m.description(), m_->description);
          cc2c_otel_string(m.unit(), m_->unit);
        }
      }
    }

    return 0;
  } catch(...) {
    otel_collector_resource_metrics_free(rms_);
    return 1;
  }
}


#define OTLP_SIGNAL_TRACES 0
#define OTLP_SIGNAL_METRICS 1
#define OTLP_SIGNAL_LOGS 2

#define OTLP_SUCCESS 0
#define OTLP_PARTIAL_SUCCESS 1
#define OTLP_FAILURE 2

int otel_encode_response_(
  int signal, int result, const char *errmsg_, int rejected,
  int error_code, struct otel_string *str_
) {
  try {
    std::string str;
    if (result == OTLP_FAILURE) {
      google::rpc::Status pbmsg;
      if (errmsg_) {
        std::string errmsg(errmsg_);
        pbmsg.set_message(errmsg);
      }
      pbmsg.set_code(error_code);
      pbmsg.SerializeToString(&str);
    } else if (signal == OTLP_SIGNAL_TRACES) {
      if (result == OTLP_SUCCESS) {
        cltrace::ExportTraceServiceResponse pbmsg;
        pbmsg.SerializeToString(&str);

      } else {
        cltrace::ExportTracePartialSuccess pbmsg;
        if (errmsg_) {
          std::string errmsg(errmsg_);
          pbmsg.set_error_message(errmsg);
        }
        pbmsg.set_rejected_spans(rejected);
        pbmsg.SerializeToString(&str);
      }
    } else if (signal == OTLP_SIGNAL_LOGS) {
      if (result == OTLP_SUCCESS) {
        cllogs::ExportLogsServiceResponse pbmsg;
        pbmsg.SerializeToString(&str);

      } else {
        cllogs::ExportLogsPartialSuccess pbmsg;
        if (errmsg_) {
          std::string errmsg(errmsg_);
          pbmsg.set_error_message(errmsg);
        }
        pbmsg.set_rejected_log_records(rejected);
        pbmsg.SerializeToString(&str);
      }
    } else if (signal == OTLP_SIGNAL_METRICS) {
      if (result == OTLP_SUCCESS) {
        clmetrics::ExportMetricsServiceResponse pbmsg;
        pbmsg.SerializeToString(&str);

      } else {
        clmetrics::ExportMetricsPartialSuccess pbmsg;
        if (errmsg_) {
          std::string errmsg(errmsg_);
          pbmsg.set_error_message(errmsg);
        }
        pbmsg.set_rejected_data_points(rejected);
        pbmsg.SerializeToString(&str);
      }
    }

    cc2c_otel_string(str, *str_);
    return 0;

  } catch(...) {
    return 1;
  }
}
