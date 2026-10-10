#pragma once
// A small JSON reader for the audio command strings. The commands are tiny and arrive a few at a time, so this favours
// simplicity over speed. It never throws: parse() reports failure through its error string.
#include <optional>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace fa::audio::json {

struct Value {
  enum class Kind { Null, Bool, Number, String, Array, Object };
  Kind kind = Kind::Null;
  bool boolean = false;
  double number = 0.0;
  std::string string;
  std::vector<Value> array;
  // Insertion order is kept and lookups are linear: objects here have a handful of keys.
  std::vector<std::pair<std::string, Value>> object;

  bool is_null() const { return kind == Kind::Null; }
  bool is_bool() const { return kind == Kind::Bool; }
  bool is_number() const { return kind == Kind::Number; }
  bool is_string() const { return kind == Kind::String; }
  bool is_array() const { return kind == Kind::Array; }
  bool is_object() const { return kind == Kind::Object; }
  // nullptr when this is not an object or the key is absent. A key present with a null value returns that null value.
  const Value* find(std::string_view key) const;
};

// Parses exactly one JSON document (surrounding whitespace allowed). On failure returns nullopt and fills `error`.
std::optional<Value> parse(std::string_view text, std::string& error);

// Short description of a value for error messages ("number 5", "string \"x\"", "object").
std::string describe(const Value& v);

}  // namespace fa::audio::json
