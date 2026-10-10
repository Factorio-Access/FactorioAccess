#pragma once
#include <cstddef>
#include <functional>
#include <string>
#include <string_view>

namespace fa::ui {

// A value-equatable key. Stands in for C#'s `object` used as a dictionary key (structural control
// keys, Tab-stop keys, region keys, menu row keys): there it was "a string, or a composite such as a
// (region, row, col) tuple", compared with Equals(). Here it is either
//   - empty      — the C# null (no key: a node outside any region, a hand-built node with no stop), or
//   - a string   — the common case, including composites the caller has already flattened, or
//   - a pointer  — opaque identity, for ControlId::for_object where the backing object doubles as
//                  the key (equality collapses to identity).
// Deliberately NOT a general variant: the engine-free core must not depend on game types, and every
// composite key the C# actually built was a string concatenation.
class Key {
 public:
  Key() = default;  // the C# null key
  Key(std::string text) : kind_(Kind::String), text_(std::move(text)) {}
  Key(const char* text) : kind_(Kind::String), text_(text) {}
  Key(std::string_view text) : kind_(Kind::String), text_(text) {}
  static Key pointer(const void* p) {
    Key k;
    k.kind_ = Kind::Pointer;
    k.pointer_ = p;
    return k;
  }

  bool empty() const { return kind_ == Kind::Null; }
  bool is_string() const { return kind_ == Kind::String; }
  bool is_pointer() const { return kind_ == Kind::Pointer; }
  // The string payload; empty when this key is not a string.
  const std::string& text() const { return text_; }
  // The pointer payload; null when this key is not a pointer.
  const void* pointer_value() const { return kind_ == Kind::Pointer ? pointer_ : nullptr; }
  std::string to_string() const;

  friend bool operator==(const Key& a, const Key& b) {
    if (a.kind_ != b.kind_) return false;
    switch (a.kind_) {
      case Kind::Null: return true;
      case Kind::String: return a.text_ == b.text_;
      case Kind::Pointer: return a.pointer_ == b.pointer_;
    }
    return false;
  }
  friend bool operator!=(const Key& a, const Key& b) { return !(a == b); }

  std::size_t hash() const;

 private:
  enum class Kind { Null, String, Pointer };
  Kind kind_ = Kind::Null;
  std::string text_;
  const void* pointer_ = nullptr;
};

/// The identity of a control (graph node) — a two-tier identity so focus can be followed across
/// rebuilds even when the world shifts under us. Ported from Tanglebeep (with permission), which
/// upgraded Factorio Access's plain string node key.
///
/// **Reference** (optional) is the game/domain object a node was derived from (a VM, a UIElement, an
/// item), compared by reference identity — here a `const void*`, because the engine-free core must
/// not know any game type and only ever compares the address. **StructuralKey** (always present) is
/// a value-equatable key (see Key).
///
/// Two controls are "the same" when their references are identical (tier 1 — a perfect match that
/// follows an object that MOVED, its structural key changing) OR their structural keys are equal
/// (tier 2 — follows a logical control whose backing object was rebuilt: new instance, same identity).
///
/// Equality/hashing is defined on the structural key ALONE, so it is a stable dictionary key (the
/// graph stores nodes and traversal order by it). The reference tier is metadata, applied explicitly
/// during focus reconciliation via reference_matches().
class ControlId {
 public:
  /// A control identified only by a structural key (no backing object).
  static ControlId structural(Key structural_key) { return ControlId(nullptr, std::move(structural_key)); }
  /// A control with both tiers: a backing object and a structural key.
  static ControlId referenced(const void* reference, Key structural_key) {
    return ControlId(reference, std::move(structural_key));
  }
  /// A control identified by a backing object only — the object doubles as the structural key
  /// (equality collapses to identity). For wrapping a raw widget with no better key.
  static ControlId for_object(const void* reference);

  /// The originating game/domain object, or null. Matched by reference identity.
  const void* reference() const { return reference_; }
  /// The value-equatable structural identity. Never empty.
  const Key& structural_key() const { return structural_key_; }

  /// Tier-1 test: is `obj` this control's backing object?
  bool reference_matches(const void* obj) const { return reference_ != nullptr && reference_ == obj; }

  friend bool operator==(const ControlId& a, const ControlId& b) {
    return a.structural_key_ == b.structural_key_;
  }
  friend bool operator!=(const ControlId& a, const ControlId& b) { return !(a == b); }

  std::string to_string() const;

 private:
  ControlId(const void* reference, Key structural_key);
  const void* reference_ = nullptr;
  Key structural_key_;
};

}  // namespace fa::ui

template <>
struct std::hash<fa::ui::Key> {
  std::size_t operator()(const fa::ui::Key& k) const noexcept { return k.hash(); }
};

template <>
struct std::hash<fa::ui::ControlId> {
  std::size_t operator()(const fa::ui::ControlId& id) const noexcept {
    return id.structural_key().hash();
  }
};
