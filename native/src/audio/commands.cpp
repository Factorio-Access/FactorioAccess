#include "audio/commands.h"
#include <algorithm>
#include <format>

namespace fa::audio {

Param Param::constant(double v) {
  Param p;
  p.points_[0].value = v;
  return p;
}

std::optional<Param> Param::envelope(std::vector<TimePoint> points) {
  if (points.empty()) return std::nullopt;
  // Stable so points sharing a time keep the order the mod gave them.
  std::stable_sort(points.begin(), points.end(), [](const TimePoint& a, const TimePoint& b) { return a.time < b.time; });
  Param p;
  p.points_ = std::move(points);
  return p;
}

double Param::value(double t) const {
  const auto& pts = points_;
  if (t <= pts.front().time) return pts.front().value;
  if (t >= pts.back().time) return pts.back().value;
  for (size_t i = 0; i + 1 < pts.size(); i++) {
    const TimePoint& a = pts[i];
    const TimePoint& b = pts[i + 1];
    if (a.time <= t && t < b.time) {
      // The interpolation belongs to the later point: it says how the value arrives there.
      if (b.interpolation == Interpolation::Jump) return a.value;
      double f = (t - a.time) / (b.time - a.time);
      return a.value + f * (b.value - a.value);
    }
  }
  return pts.back().value;
}

namespace {

using json::Value;

// Python's float() accepts bools too (True is 1.0); keep that so the same inputs are accepted.
bool as_number(const Value& v, double& out) {
  if (v.is_number()) {
    out = v.number;
    return true;
  }
  if (v.is_bool()) {
    out = v.boolean ? 1.0 : 0.0;
    return true;
  }
  return false;
}

// Python truthiness for the fields the launcher read with bool(): looping and lpf.enabled.
bool as_truthy(const Value& v, bool& out, std::string& error, std::string_view field) {
  switch (v.kind) {
    case Value::Kind::Null: out = false; return true;
    case Value::Kind::Bool: out = v.boolean; return true;
    case Value::Kind::Number: out = v.number != 0.0; return true;
    default: error = std::format("{} must be a boolean, got {}", field, json::describe(v)); return false;
  }
}

// An optional number field: absent or null is nullopt (Python's dict.get returning None).
bool opt_number(const Value& obj, std::string_view key, std::optional<double>& out, std::string& error) {
  const Value* v = obj.find(key);
  if (!v || v->is_null()) return true;
  double d;
  if (!as_number(*v, d)) {
    error = std::format("{} must be a number, got {}", key, json::describe(*v));
    return false;
  }
  out = d;
  return true;
}

bool opt_string(const Value& obj, std::string_view key, std::optional<std::string>& out, std::string& error) {
  const Value* v = obj.find(key);
  if (!v || v->is_null()) return true;
  if (!v->is_string()) {
    error = std::format("{} must be a string, got {}", key, json::describe(*v));
    return false;
  }
  out = v->string;
  return true;
}

bool required_id(const Value& obj, std::string& out, std::string& error) {
  const Value* v = obj.find("id");
  if (!v) {
    error = "command missing id";
    return false;
  }
  if (!v->is_string()) {
    error = std::format("id must be a string, got {}", json::describe(*v));
    return false;
  }
  out = v->string;
  return true;
}

// A parameter that defaults when absent. Present-but-null is an error, as it was in the launcher.
bool param_field(const Value& obj, std::string_view key, double def, Param& out, std::string& error) {
  const Value* v = obj.find(key);
  if (!v) {
    out = Param::constant(def);
    return true;
  }
  auto p = parse_param(*v, error);
  if (!p) {
    error = std::format("{}: {}", key, error);
    return false;
  }
  out = std::move(*p);
  return true;
}

bool parse_source(const Value& v, SourceConfig& out, std::string& error) {
  if (!v.is_object()) {
    error = std::format("source must be an object, got {}", json::describe(v));
    return false;
  }
  const Value* kind = v.find("kind");
  if (kind && kind->is_string() && kind->string == "encoded_bytes") out.kind = SourceKind::EncodedBytes;
  else if (kind && kind->is_string() && kind->string == "waveform") out.kind = SourceKind::Waveform;
  else {
    error = std::format("Unknown source kind: {}", kind ? json::describe(*kind) : "missing");
    return false;
  }
  return opt_string(v, "name", out.name, error) && opt_string(v, "waveform", out.waveform, error) && opt_number(v, "frequency", out.frequency, error) &&
         opt_number(v, "non_looping_duration", out.non_looping_duration, error) && opt_number(v, "fade_out", out.fade_out, error);
}

bool parse_patch(const Value& data, PatchCommand& cmd, std::string& error) {
  if (const Value* lpf = data.find("lpf"); lpf && !lpf->is_null()) {
    if (!lpf->is_object()) {
      error = std::format("lpf must be an object, got {}", json::describe(*lpf));
      return false;
    }
    LpfConfig cfg;
    if (const Value* c = lpf->find("cutoff")) {
      if (!as_number(*c, cfg.cutoff)) {
        error = std::format("lpf cutoff must be a number, got {}", json::describe(*c));
        return false;
      }
    }
    if (const Value* e = lpf->find("enabled")) {
      if (!as_truthy(*e, cfg.enabled, error, "lpf enabled")) return false;
    }
    // The filter is immutable after creation, so a disabled one would only cost a second signal path for nothing.
    if (cfg.enabled) {
      cmd.lpf = cfg;
      Param fg;
      if (!param_field(data, "filter_gain", 1.0, fg, error)) return false;
      cmd.filter_gain = std::move(fg);
    }
  }

  if (!required_id(data, cmd.id, error)) return false;
  const Value* source = data.find("source");
  if (!source) {
    error = "patch command missing source";
    return false;
  }
  if (!parse_source(*source, cmd.source, error)) return false;
  if (!param_field(data, "volume", 1.0, cmd.volume, error)) return false;
  if (!param_field(data, "pan", 0.0, cmd.pan, error)) return false;
  if (const Value* l = data.find("looping")) {
    if (!as_truthy(*l, cmd.looping, error, "looping")) return false;
  }
  if (!param_field(data, "playback_rate", 1.0, cmd.playback_rate, error)) return false;
  if (const Value* st = data.find("start_time")) {
    if (!as_number(*st, cmd.start_time)) {
      error = std::format("start_time must be a number, got {}", json::describe(*st));
      return false;
    }
  }
  return true;
}

}  // namespace

std::optional<Param> parse_param(const Value& v, std::string& error) {
  double d;
  if (as_number(v, d)) return Param::constant(d);
  // Factorio's table_to_json writes an empty Lua table as {}, so treat that as the empty list it was meant to be.
  bool empty_object = v.is_object() && v.object.empty();
  if (v.is_array() || empty_object) {
    std::vector<TimePoint> points;
    for (const Value& item : v.array) {
      const Value* t = item.find("time");
      const Value* val = item.find("value");
      TimePoint p;
      if (!t || !as_number(*t, p.time) || !val || !as_number(*val, p.value)) {
        error = "envelope point needs numeric time and value";
        return std::nullopt;
      }
      // Anything but "jump" interpolates linearly, as the launcher did.
      const Value* interp = item.find("interpolation_from_prev");
      p.interpolation = interp && interp->is_string() && interp->string == "jump" ? Interpolation::Jump : Interpolation::Linear;
      points.push_back(p);
    }
    auto env = Param::envelope(std::move(points));
    if (!env) error = "TimeEnvelope requires at least one point";
    return env;
  }
  error = std::format("Invalid parameter value: {}", json::describe(v));
  return std::nullopt;
}

std::optional<Command> parse_command(const Value& data, std::string& error) {
  if (!data.is_object()) {
    error = std::format("command must be a JSON object, got {}", json::describe(data));
    return std::nullopt;
  }
  const Value* type = data.find("command");
  std::string_view name = type && type->is_string() ? std::string_view(type->string) : std::string_view();

  if (name == "stop") {
    StopCommand stop;
    if (!required_id(data, stop.id, error)) return std::nullopt;
    return Command{std::move(stop)};
  }
  if (name == "patch") {
    PatchCommand patch;
    if (!parse_patch(data, patch, error)) return std::nullopt;
    return Command{std::move(patch)};
  }
  if (name == "compound") {
    CompoundCommand compound;
    const Value* subs = data.find("commands");
    if (subs && !subs->is_array() && !(subs->is_object() && subs->object.empty())) {
      error = std::format("commands must be an array, got {}", json::describe(*subs));
      return std::nullopt;
    }
    if (subs) {
      for (size_t i = 0; i < subs->array.size(); i++) {
        auto sub = parse_command(subs->array[i], error);
        if (!sub) {
          error = std::format("sub-command {}: {}", i, error);
          return std::nullopt;
        }
        compound.commands.push_back(std::move(*sub));
      }
    }
    return Command{std::move(compound)};
  }
  error = std::format("Unknown command type: {}", type ? json::describe(*type) : "missing");
  return std::nullopt;
}

std::optional<Command> parse_command(std::string_view text, std::string& error) {
  auto v = json::parse(text, error);
  if (!v) {
    error = "invalid JSON: " + error;
    return std::nullopt;
  }
  return parse_command(*v, error);
}

namespace {

void validate_into(const Command& cmd, std::vector<std::string>& errors) {
  if (auto* p = std::get_if<PatchCommand>(&cmd.v)) {
    if (p->id.empty()) errors.push_back("Patch command missing id");
    if (p->start_time < 0) errors.push_back("start_time cannot be negative");
    const SourceConfig& src = p->source;
    if (src.kind == SourceKind::EncodedBytes) {
      if (!src.name || src.name->empty()) errors.push_back("encoded_bytes source missing name");
    } else {
      bool has_type = src.waveform && !src.waveform->empty();
      if (!has_type) errors.push_back("waveform source missing waveform type");
      if (!src.frequency) errors.push_back("waveform source missing frequency");
      if (has_type) {
        const std::string& w = *src.waveform;
        if (w != "sine" && w != "square" && w != "triangle" && w != "saw") errors.push_back(std::format("Unknown waveform type: {}", w));
      }
      if (src.fade_out) {
        if (*src.fade_out < 0) errors.push_back("fade_out cannot be negative");
        if (src.non_looping_duration && *src.fade_out > *src.non_looping_duration) errors.push_back("fade_out exceeds duration");
      }
    }
    if (p->lpf) {
      if (p->lpf->cutoff <= 0) errors.push_back("lpf cutoff must be positive");
      if (p->lpf->cutoff > 20000) errors.push_back("lpf cutoff exceeds audible range (20kHz)");
    }
  } else if (auto* s = std::get_if<StopCommand>(&cmd.v)) {
    if (s->id.empty()) errors.push_back("Stop command missing id");
  } else if (auto* c = std::get_if<CompoundCommand>(&cmd.v)) {
    if (c->commands.empty()) errors.push_back("Compound command has no sub-commands");
    for (size_t i = 0; i < c->commands.size(); i++) {
      std::vector<std::string> sub;
      validate_into(c->commands[i], sub);
      for (auto& e : sub) errors.push_back(std::format("sub-command {}: {}", i, e));
    }
  }
}

}  // namespace

std::vector<std::string> validate_command(const Command& cmd) {
  std::vector<std::string> errors;
  validate_into(cmd, errors);
  return errors;
}

}  // namespace fa::audio
