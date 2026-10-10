#include "audio/json.h"
#include <charconv>
#include <format>

namespace fa::audio::json {

const Value* Value::find(std::string_view key) const {
  if (kind != Kind::Object) return nullptr;
  // Duplicate keys: the last one wins, as in Python's json.loads (the launcher this replaces).
  const Value* found = nullptr;
  for (auto& [k, v] : object)
    if (k == key) found = &v;
  return found;
}

namespace {

// Deep enough for any command the mod builds (compound > patch > envelope > point is 5), shallow enough that hostile
// input cannot exhaust the worker thread's stack.
constexpr int kMaxDepth = 64;

struct Parser {
  std::string_view s;
  size_t i = 0;
  std::string err;

  bool fail(std::string_view what) {
    if (err.empty()) err = std::format("{} at offset {}", what, i);
    return false;
  }

  void skip_ws() {
    while (i < s.size() && (s[i] == ' ' || s[i] == '\t' || s[i] == '\n' || s[i] == '\r')) i++;
  }

  bool literal(std::string_view word) {
    if (s.substr(i, word.size()) != word) return fail("invalid literal");
    i += word.size();
    return true;
  }

  static void append_utf8(std::string& out, uint32_t cp) {
    if (cp < 0x80) {
      out += static_cast<char>(cp);
    } else if (cp < 0x800) {
      out += static_cast<char>(0xC0 | (cp >> 6));
      out += static_cast<char>(0x80 | (cp & 0x3F));
    } else if (cp < 0x10000) {
      out += static_cast<char>(0xE0 | (cp >> 12));
      out += static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
      out += static_cast<char>(0x80 | (cp & 0x3F));
    } else {
      out += static_cast<char>(0xF0 | (cp >> 18));
      out += static_cast<char>(0x80 | ((cp >> 12) & 0x3F));
      out += static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
      out += static_cast<char>(0x80 | (cp & 0x3F));
    }
  }

  bool hex4(uint32_t& out) {
    if (i + 4 > s.size()) return fail("truncated \\u escape");
    out = 0;
    for (int k = 0; k < 4; k++) {
      char c = s[i++];
      out <<= 4;
      if (c >= '0' && c <= '9') out |= static_cast<uint32_t>(c - '0');
      else if (c >= 'a' && c <= 'f') out |= static_cast<uint32_t>(c - 'a' + 10);
      else if (c >= 'A' && c <= 'F') out |= static_cast<uint32_t>(c - 'A' + 10);
      else return fail("bad hex digit in \\u escape");
    }
    return true;
  }

  bool string(std::string& out) {
    i++;  // opening quote
    while (true) {
      if (i >= s.size()) return fail("unterminated string");
      char c = s[i++];
      if (c == '"') return true;
      if (static_cast<unsigned char>(c) < 0x20) return fail("control character in string");
      if (c != '\\') {
        out += c;
        continue;
      }
      if (i >= s.size()) return fail("unterminated escape");
      char e = s[i++];
      switch (e) {
        case '"': out += '"'; break;
        case '\\': out += '\\'; break;
        case '/': out += '/'; break;
        case 'b': out += '\b'; break;
        case 'f': out += '\f'; break;
        case 'n': out += '\n'; break;
        case 'r': out += '\r'; break;
        case 't': out += '\t'; break;
        case 'u': {
          uint32_t cp;
          if (!hex4(cp)) return false;
          if (cp >= 0xD800 && cp < 0xDC00 && s.substr(i, 2) == "\\u") {
            size_t save = i;
            i += 2;
            uint32_t lo;
            if (!hex4(lo)) return false;
            if (lo >= 0xDC00 && lo < 0xE000) cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
            else i = save;  // not a pair: emit the lone surrogate as-is and reread the second escape on its own
          }
          append_utf8(out, cp);
          break;
        }
        default: return fail("invalid escape");
      }
    }
  }

  bool number(Value& v) {
    size_t start = i;
    if (i < s.size() && s[i] == '-') i++;
    if (i >= s.size() || s[i] < '0' || s[i] > '9') return fail("invalid number");
    while (i < s.size() && ((s[i] >= '0' && s[i] <= '9') || s[i] == '.' || s[i] == 'e' || s[i] == 'E' || s[i] == '+' || s[i] == '-')) i++;
    double d = 0.0;
    auto [end, ec] = std::from_chars(s.data() + start, s.data() + i, d);
    if (ec != std::errc() || end != s.data() + i) {
      i = start;
      return fail("invalid number");
    }
    v.kind = Value::Kind::Number;
    v.number = d;
    return true;
  }

  bool value(Value& v, int depth) {
    if (depth > kMaxDepth) return fail("nesting too deep");
    skip_ws();
    if (i >= s.size()) return fail("unexpected end of input");
    char c = s[i];
    if (c == '{') {
      v.kind = Value::Kind::Object;
      i++;
      skip_ws();
      if (i < s.size() && s[i] == '}') {
        i++;
        return true;
      }
      while (true) {
        skip_ws();
        if (i >= s.size() || s[i] != '"') return fail("expected object key");
        std::string key;
        if (!string(key)) return false;
        skip_ws();
        if (i >= s.size() || s[i] != ':') return fail("expected ':'");
        i++;
        Value child;
        if (!value(child, depth + 1)) return false;
        v.object.emplace_back(std::move(key), std::move(child));
        skip_ws();
        if (i < s.size() && s[i] == ',') {
          i++;
          continue;
        }
        if (i < s.size() && s[i] == '}') {
          i++;
          return true;
        }
        return fail("expected ',' or '}'");
      }
    }
    if (c == '[') {
      v.kind = Value::Kind::Array;
      i++;
      skip_ws();
      if (i < s.size() && s[i] == ']') {
        i++;
        return true;
      }
      while (true) {
        Value child;
        if (!value(child, depth + 1)) return false;
        v.array.push_back(std::move(child));
        skip_ws();
        if (i < s.size() && s[i] == ',') {
          i++;
          continue;
        }
        if (i < s.size() && s[i] == ']') {
          i++;
          return true;
        }
        return fail("expected ',' or ']'");
      }
    }
    if (c == '"') {
      v.kind = Value::Kind::String;
      return string(v.string);
    }
    if (c == 't') {
      v.kind = Value::Kind::Bool;
      v.boolean = true;
      return literal("true");
    }
    if (c == 'f') {
      v.kind = Value::Kind::Bool;
      v.boolean = false;
      return literal("false");
    }
    if (c == 'n') {
      v.kind = Value::Kind::Null;
      return literal("null");
    }
    return number(v);
  }
};

}  // namespace

std::optional<Value> parse(std::string_view text, std::string& error) {
  Parser p{text};
  Value v;
  if (!p.value(v, 0)) {
    error = p.err;
    return std::nullopt;
  }
  p.skip_ws();
  if (p.i != text.size()) {
    p.fail("trailing characters");
    error = p.err;
    return std::nullopt;
  }
  return v;
}

std::string describe(const Value& v) {
  switch (v.kind) {
    case Value::Kind::Null: return "null";
    case Value::Kind::Bool: return v.boolean ? "true" : "false";
    case Value::Kind::Number: return std::format("number {}", v.number);
    case Value::Kind::String: return std::format("string \"{}\"", v.string);
    case Value::Kind::Array: return "array";
    case Value::Kind::Object: return "object";
  }
  return "?";
}

}  // namespace fa::audio::json
