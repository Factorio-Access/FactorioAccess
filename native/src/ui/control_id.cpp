#include "ui/control_id.h"

#include <cstdint>
#include <stdexcept>

namespace fa::ui {

std::string Key::to_string() const {
  switch (kind_) {
    case Kind::Null: return std::string();
    case Kind::String: return text_;
    case Kind::Pointer: {
      // Identity keys have no printable form; the address is the only thing that distinguishes them.
      static const char* kDigits = "0123456789abcdef";
      auto v = reinterpret_cast<std::uintptr_t>(pointer_);
      std::string out = "obj#";
      for (int shift = static_cast<int>(sizeof(v)) * 8 - 4; shift >= 0; shift -= 4)
        out.push_back(kDigits[(v >> shift) & 0xF]);
      return out;
    }
  }
  return std::string();
}

std::size_t Key::hash() const {
  switch (kind_) {
    case Kind::Null: return 0;
    case Kind::String: return std::hash<std::string>{}(text_);
    case Kind::Pointer: return std::hash<const void*>{}(pointer_);
  }
  return 0;
}

ControlId::ControlId(const void* reference, Key structural_key)
    : reference_(reference), structural_key_(std::move(structural_key)) {
  if (structural_key_.empty()) throw std::invalid_argument("ControlId: structural key is required");
}

ControlId ControlId::for_object(const void* reference) {
  if (reference == nullptr) throw std::invalid_argument("ControlId::for_object: reference is required");
  return ControlId(reference, Key::pointer(reference));
}

std::string ControlId::to_string() const {
  return reference_ == nullptr ? "ControlId(" + structural_key_.to_string() + ")"
                               : "ControlId(" + structural_key_.to_string() + ", ref=" +
                                     Key::pointer(reference_).to_string() + ")";
}

}  // namespace fa::ui
