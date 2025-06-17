#include <map>

#include "opentelemetry/context/context.h"
#include "opentelemetry/context/runtime_context.h"
#include "opentelemetry/trace/span.h"

#include "otel_common.h"
#include "otel_common_cpp.h"

namespace ctx   = opentelemetry::context;
namespace nostd = opentelemetry::nostd;
namespace trace = opentelemetry::trace;

nostd::shared_ptr<ctx::RuntimeContextStorage> &GetRContextStorage();

namespace r_otel {

class SessionId {
public:
  SessionId() : id(std::to_string(nxt())) {}
  friend bool operator<(const SessionId& l, const SessionId& r) {
    return l.id < r.id;
  }
  friend bool operator==(const SessionId& l, const SessionId& r) {
    return l.id == r.id;
  }
  friend bool operator!=(const SessionId& l, const SessionId& r) {
    return l.id != r.id;
  }
  const std::string &Get() { return id; }

private:
  std::string id;
  int64_t nxt() {
    static int64_t counter = 1;
    return counter++;
  }
};

class RContextStorage : public ctx::RuntimeContextStorage {
public:
  RContextStorage() noexcept = default;

  ctx::Context GetCurrent() noexcept override {
    return GetStack().Top();
  }

  bool Detach(ctx::Token &token) noexcept override {
    // In most cases, the context to be detached is on the top of the stack.
    if (token == GetStack().Top())
    {
      GetStack().Pop();
      return true;
    }

    if (!GetStack().Contains(token))
    {
      return false;
    }

    while (!(token == GetStack().Top()))
    {
      GetStack().Pop();
    }

    GetStack().Pop();

    return true;
  }

  nostd::unique_ptr<ctx::Token>
  Attach(const ctx::Context &context) noexcept override {
    GetStack().Push(context);
    return CreateToken(context);
  }

  SessionId StartSession() {
    return GetStackSet().NewStack();
  }

  std::pair<bool, SessionId> GetCurrentSession() {
    return GetStackSet().GetCurrentStackId();
  }

  void ActivateSession(SessionId &id) {
    GetStackSet().SelectStack(id);
  }

  void DeactivateSession() {
    GetStackSet().UnselectStack();
  }

  void FinishSession(SessionId &id) {
    GetStackSet().RemoveStack(id);
  }

  void FinishAllSessions() {
    GetStackSet().RemoveAllStacks();
  }

private:
  // A nested class to store the attached contexts in a stack.
  class Stack
  {
  public:
    Stack() noexcept : size_(0), capacity_(0), base_(nullptr) {}

    // Pops the top Context off the stack.
    void Pop() noexcept
    {
      if (size_ == 0)
      {
        return;
      }
      // Store empty Context before decrementing `size`, to ensure
      // the shared_ptr object (if stored in prev context object ) are released.
      // The stack is not resized, and the unused memory would be reutilised
      // for subsequent context storage.
      base_[size_ - 1] = ctx::Context();
      size_ -= 1;
    }

    bool Contains(const ctx::Token &token) const noexcept
    {
      for (size_t pos = size_; pos > 0; --pos)
      {
        if (token == base_[pos - 1])
        {
          return true;
        }
      }

      return false;
    }

    // Returns the Context at the top of the stack.
    ctx::Context Top() const noexcept
    {
      if (size_ == 0)
      {
        return ctx::Context();
      }
      return base_[size_ - 1];
    }

    // Pushes the passed in context pointer to the top of the stack
    // and resizes if necessary.
    void Push(const ctx::Context &context) noexcept
    {
      size_++;
      if (size_ > capacity_)
      {
        Resize(size_ * 2);
      }
      base_[size_ - 1] = context;
    }

    // Reallocates the storage array to the pass in new capacity size.
    void Resize(size_t new_capacity) noexcept
    {
      size_t old_size = size_ - 1;
      if (new_capacity == 0)
      {
        new_capacity = 2;
      }
      ctx::Context *temp = new ctx::Context[new_capacity];
      if (base_ != nullptr)
      {
        // vs2015 does not like this construct considering it unsafe:
        // - std::copy(base_, base_ + old_size, temp);
        // Ref.
        // https://stackoverflow.com/questions/12270224/xutility2227-warning-c4996-std-copy-impl
        for (size_t i = 0; i < (std::min)(old_size, new_capacity); i++)
        {
          temp[i] = base_[i];
        }
        delete[] base_;
      }
      base_     = temp;
      capacity_ = new_capacity;
    }

    ~Stack() noexcept { delete[] base_; }

    size_t size_;
    size_t capacity_;
    ctx::Context *base_;
  };

  class StackSet {
  public:
    StackSet() : is_default_(true) { }

    Stack &GetCurrentStack() {
      if (is_default_) {
        return default_;
      } else {
        return sessions_[current_];
      }
    }

    std::pair<bool, SessionId> GetCurrentStackId() {
      if (is_default_) {
        return std::pair<bool, SessionId>(true, SessionId());
      } else {
        return std::pair<bool, SessionId>(false, current_);
      }
    }

    SessionId NewStack() {
      is_default_ = false;
      current_ = SessionId();
      sessions_[current_] = Stack();
      active_session.push_back(current_);
      return current_;
    }

    void SelectStack(SessionId &id) {
      if (active_session.size() == 0 || active_session.back() != id) {
        active_session.push_back(id);
      }
      is_default_ = false;
      current_ = id;
    }

    void UnselectStack() {
      if (active_session.size() > 0) active_session.pop_back();
      while (active_session.size() > 0 &&
             sessions_.find(active_session.back()) == sessions_.end()) {
        active_session.pop_back();
      }
      if (active_session.size() == 0) {
        is_default_ = true;
      } else {
        current_ = active_session.back();
      }
    }

    void RemoveStack(SessionId &id) {
      sessions_.erase(id);
      if (current_ == id) {
        UnselectStack();
      }
    }

    // not used currently?
    void RemoveAllStacks(void) {
      sessions_.clear();
      active_session.clear();
      is_default_ = true;
    }

    ~StackSet() noexcept { }

    bool is_default_;
    Stack default_;
    std::map<SessionId, Stack> sessions_;
    SessionId current_;
    std::vector<SessionId> active_session;
  };

  StackSet &GetStackSet() {
    static StackSet stackset_ = StackSet();
    return stackset_;
  }

  Stack &GetStack() {
    return GetStackSet().GetCurrentStack();
  }

  std::pair<bool, SessionId> GetStackId() {
    return GetStackSet().GetCurrentStackId();
  }
};

SessionId StartSession() {
  nostd::shared_ptr<ctx::RuntimeContextStorage> &str = GetRContextStorage();
  r_otel::RContextStorage *rstr =
    static_cast<r_otel::RContextStorage*>(str.get());
  return rstr->StartSession();
}

void ActivateSession(SessionId &id) {
  nostd::shared_ptr<ctx::RuntimeContextStorage> &str = GetRContextStorage();
  r_otel::RContextStorage *rstr =
    static_cast<r_otel::RContextStorage*>(str.get());
  rstr->ActivateSession(id);
}

void DeactivateSession() {
  nostd::shared_ptr<ctx::RuntimeContextStorage> &str = GetRContextStorage();
  r_otel::RContextStorage *rstr =
    static_cast<r_otel::RContextStorage*>(str.get());
  rstr->DeactivateSession();
}

void FinishSession(SessionId &id) {
  nostd::shared_ptr<ctx::RuntimeContextStorage> &str = GetRContextStorage();
  r_otel::RContextStorage *rstr =
    static_cast<r_otel::RContextStorage*>(str.get());
  rstr->FinishSession(id);
}

void FinishAllSessions(void) {
  nostd::shared_ptr<ctx::RuntimeContextStorage> &str = GetRContextStorage();
  r_otel::RContextStorage *rstr =
    static_cast<r_otel::RContextStorage*>(str.get());
  rstr->FinishAllSessions();
}

} // namespace r_otel

nostd::shared_ptr<ctx::RuntimeContextStorage> &GetRContextStorage() {
  static nostd::shared_ptr<ctx::RuntimeContextStorage>
    storage(new r_otel::RContextStorage);
  return storage;
}

void otel_init_context_storage_(void) {
  nostd::shared_ptr<ctx::RuntimeContextStorage> storage =
    GetRContextStorage();
  ctx::RuntimeContext::SetRuntimeContextStorage(storage);
}

extern "C" {

void otel_init_context_storage(void) {
  otel_init_context_storage_();
}

void otel_session_finally_(void *id_) {
  r_otel::SessionId *id = (r_otel::SessionId*) id_;
  r_otel::FinishSession(*id);
  delete id;
}

void otel_session_copy_finally_(void *id_) {
  r_otel::SessionId *id = (r_otel::SessionId*) id_;
  delete id;
}

void *otel_session_start_() {
  r_otel::SessionId *id = new r_otel::SessionId{r_otel::StartSession()};
  return (void*) id;
}

void otel_session_activate_(void *id_) {
  r_otel::SessionId *id = (r_otel::SessionId*) id_;
  r_otel::ActivateSession(*id);
}

void otel_session_deactivate_(void *id_) {
  r_otel::DeactivateSession();
}

int otel_debug_current_session_(struct otel_session *sess) {
  try {
    nostd::shared_ptr<ctx::RuntimeContextStorage> &str = GetRContextStorage();
    r_otel::RContextStorage *rstr =
      static_cast<r_otel::RContextStorage*>(str.get());
    ctx::Context cctx = rstr->GetCurrent();
    ctx::ContextValue spanv = cctx.GetValue(trace::kSpanKey);
    if (nostd::holds_alternative<nostd::shared_ptr<trace::Span>>(spanv)) {
      const trace::Span &span =
        *nostd::get<nostd::shared_ptr<trace::Span>>(spanv);
      trace::SpanContext spanctx = span.GetContext();
      const trace::TraceId &trace_id = spanctx.trace_id();
      const trace::SpanId &span_id = spanctx.span_id();
      cc2c_otel_string(trace_id, sess->trace_id);
      cc2c_otel_string(span_id, sess->span_id);
    }
    return 0;

  } catch(...) {
    otel_session_free(sess);
    return 1;
  }
}

void otel_debug_sessions_(struct otel_sessions *sess) {
  // TODO
}

}

void *otel_get_current_session_() {
  nostd::shared_ptr<ctx::RuntimeContextStorage> &str = GetRContextStorage();
  r_otel::RContextStorage *rstr =
    static_cast<r_otel::RContextStorage*>(str.get());
  std::pair<bool, r_otel::SessionId> crnt = rstr->GetCurrentSession();
  if (crnt.first) {
    return nullptr;
  } else {
    r_otel::SessionId *id = new r_otel::SessionId();
    *id = crnt.second;
    return id;
  }
}
