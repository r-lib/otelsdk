#pragma once

#include <chrono>
#include <deque>
#include <memory>
#include <mutex>
#include <vector>

#include "opentelemetry/sdk/common/exporter_utils.h"
#include "opentelemetry/sdk/logs/exporter.h"
#include "opentelemetry/sdk/logs/read_write_log_record.h"

// opentelemetry-cpp has in-memory exporters for spans and metrics, but not
// for log records, so this is our own.

namespace otel_logs_sdk = opentelemetry::sdk::logs;

// Circular buffer of log records. The oldest records are dropped if the
// buffer is full.
class InMemoryLogData {
public:
  explicit InMemoryLogData(size_t capacity) : capacity_(capacity) { }

  void Add(std::unique_ptr<otel_logs_sdk::ReadWriteLogRecord> record) {
    std::lock_guard<std::mutex> guard(mutex_);
    if (capacity_ == 0) return;
    while (records_.size() >= capacity_) {
      records_.pop_front();
    }
    records_.push_back(std::move(record));
  }

  // Returns the records and empties the buffer.
  std::vector<std::unique_ptr<otel_logs_sdk::ReadWriteLogRecord>> Get() {
    std::lock_guard<std::mutex> guard(mutex_);
    std::vector<std::unique_ptr<otel_logs_sdk::ReadWriteLogRecord>> res;
    res.reserve(records_.size());
    for (auto &r : records_) {
      res.push_back(std::move(r));
    }
    records_.clear();
    return res;
  }

private:
  size_t capacity_;
  std::mutex mutex_;
  std::deque<std::unique_ptr<otel_logs_sdk::ReadWriteLogRecord>> records_;
};

class InMemoryLogRecordExporter final : public otel_logs_sdk::LogRecordExporter {
public:
  explicit InMemoryLogRecordExporter(std::shared_ptr<InMemoryLogData> data)
    : data_(data), shutdown_(false) { }

  std::unique_ptr<otel_logs_sdk::Recordable> MakeRecordable() noexcept override {
    return std::unique_ptr<otel_logs_sdk::Recordable>(
      new otel_logs_sdk::ReadWriteLogRecord());
  }

  opentelemetry::sdk::common::ExportResult Export(
      const opentelemetry::nostd::span<
        std::unique_ptr<otel_logs_sdk::Recordable>> &records) noexcept override {
    if (shutdown_) {
      return opentelemetry::sdk::common::ExportResult::kFailure;
    }
    for (auto &record : records) {
      // we created these in MakeRecordable()
      auto rec = static_cast<otel_logs_sdk::ReadWriteLogRecord*>(
        record.release());
      data_->Add(std::unique_ptr<otel_logs_sdk::ReadWriteLogRecord>(rec));
    }
    return opentelemetry::sdk::common::ExportResult::kSuccess;
  }

  bool ForceFlush(std::chrono::microseconds) noexcept override {
    return true;
  }

  bool Shutdown(std::chrono::microseconds) noexcept override {
    shutdown_ = true;
    return true;
  }

private:
  std::shared_ptr<InMemoryLogData> data_;
  bool shutdown_;
};
