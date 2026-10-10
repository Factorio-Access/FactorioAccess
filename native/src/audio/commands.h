#pragma once
// The audio command language: parsing the JSON the mod sends (scripts/launcher-audio.lua) into commands, validating them,
// and evaluating time envelopes. No engine or device here, so all of it is testable on its own.
#include <optional>
#include <string>
#include <string_view>
#include <variant>
#include <vector>
#include "audio/json.h"

namespace fa::audio {

enum class Interpolation { Linear, Jump };

struct TimePoint {
  double time = 0.0;  // seconds since the sound started
  double value = 0.0;
  Interpolation interpolation = Interpolation::Linear;  // how to get here from the previous point
};

// A static value or a time envelope. Both are a sorted list of points: a static value is one point.
class Param {
 public:
  Param() : points_{TimePoint{}} {}
  static Param constant(double v);
  // nullopt when `points` is empty: an envelope needs at least one point.
  static std::optional<Param> envelope(std::vector<TimePoint> points);

  double value(double time_seconds) const;
  bool is_constant() const { return points_.size() <= 1; }
  const std::vector<TimePoint>& points() const { return points_; }

 private:
  std::vector<TimePoint> points_;
};

struct LpfConfig {
  double cutoff = 1000.0;  // Hz
  bool enabled = true;
};

enum class SourceKind { EncodedBytes, Waveform };

struct SourceConfig {
  SourceKind kind = SourceKind::Waveform;
  std::optional<std::string> name;  // encoded_bytes: asset name handed to the loader
  std::optional<std::string> waveform;  // sine, square, triangle, saw
  std::optional<double> frequency;
  std::optional<double> non_looping_duration;
  std::optional<double> fade_out;  // seconds, waveform only
};

struct StopCommand {
  std::string id;
};

struct PatchCommand {
  std::string id;
  SourceConfig source;
  Param volume = Param::constant(1.0);
  Param pan = Param::constant(0.0);
  bool looping = false;
  Param playback_rate = Param::constant(1.0);
  double start_time = 0.0;  // seconds from now; 0 starts immediately
  std::optional<LpfConfig> lpf;  // only present when enabled: a disabled filter is dropped at parse time
  std::optional<Param> filter_gain;  // 0 unfiltered, 1 fully filtered; present exactly when lpf is
};

struct Command;

struct CompoundCommand {
  std::vector<Command> commands;
};

struct Command {
  std::variant<StopCommand, PatchCommand, CompoundCommand> v;
};

// Parses one command string. On failure returns nullopt and sets `error`.
std::optional<Command> parse_command(std::string_view text, std::string& error);
std::optional<Command> parse_command(const json::Value& v, std::string& error);
std::optional<Param> parse_param(const json::Value& v, std::string& error);

// Semantic checks on a parsed command. Empty when valid. Compound errors are prefixed with "sub-command N: ".
std::vector<std::string> validate_command(const Command& cmd);

}  // namespace fa::audio
