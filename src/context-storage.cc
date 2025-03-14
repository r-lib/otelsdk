#include "opentelemetry/context/context.h"
#include "opentelemetry/context/runtime_context.h"

namespace ctx   = opentelemetry::context;
namespace nostd = opentelemetry::nostd;

namespace r_otel {

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

private:
  // A nested class to store the attached contexts in a stack.
  class Stack
  {
    friend class RContextStorage;

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

  OPENTELEMETRY_API_SINGLETON Stack &GetStack()
  {
    static thread_local Stack stack_ = Stack();
    return stack_;
  }
};

} // namespace r_otel

void otel_init_context_storage_(void) {
  const nostd::shared_ptr<ctx::RuntimeContextStorage>
    storage(new r_otel::RContextStorage);
  ctx::RuntimeContext::SetRuntimeContextStorage(storage);
}

extern "C" {

extern void otel_init_context_storage(void) {
  otel_init_context_storage_();
}

}
