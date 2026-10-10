// Port of launcher-audio tests/test_commands.py, plus the shapes scripts/launcher-audio.lua actually emits.
#include <doctest/doctest.h>
#include <algorithm>
#include <cctype>
#include "audio/commands.h"

using namespace fa::audio;
using doctest::Approx;

namespace {

Command parse(const char* text) {
  std::string err;
  auto c = parse_command(text, err);
  REQUIRE_MESSAGE(c, err);
  return std::move(*c);
}

std::string parse_error(const char* text) {
  std::string err;
  auto c = parse_command(text, err);
  CHECK(!c);
  return err;
}

const PatchCommand& patch(const Command& c) {
  REQUIRE(std::holds_alternative<PatchCommand>(c.v));
  return std::get<PatchCommand>(c.v);
}

std::string lower(std::string s) {
  std::transform(s.begin(), s.end(), s.begin(), [](unsigned char ch) { return static_cast<char>(std::tolower(ch)); });
  return s;
}

bool any_error(const std::vector<std::string>& errors, std::initializer_list<const char*> needles) {
  return std::any_of(errors.begin(), errors.end(), [&](const std::string& e) {
    std::string l = lower(e);
    return std::all_of(needles.begin(), needles.end(), [&](const char* n) { return l.find(n) != std::string::npos; });
  });
}

}  // namespace

TEST_CASE("parse stop") {
  Command c = parse(R"({"command": "stop", "id": "sound_123"})");
  REQUIRE(std::holds_alternative<StopCommand>(c.v));
  CHECK(std::get<StopCommand>(c.v).id == "sound_123");
}

TEST_CASE("parse patch waveform") {
  Command c = parse(R"({"command": "patch", "id": "beep", "source": {"kind": "waveform", "waveform": "sine", "frequency": 440},
                        "volume": 0.5, "looping": true, "playback_rate": 1.0})");
  const PatchCommand& p = patch(c);
  CHECK(p.id == "beep");
  CHECK(p.source.kind == SourceKind::Waveform);
  CHECK(*p.source.waveform == "sine");
  CHECK(*p.source.frequency == 440);
  CHECK(p.looping);
  CHECK(p.volume.value(0) == 0.5);
}

TEST_CASE("parse patch encoded bytes") {
  Command c = parse(R"({"command": "patch", "id": "music", "source": {"kind": "encoded_bytes", "name": "song.mp3"},
                        "volume": 1.0, "pan": 0.5, "looping": false, "playback_rate": 1.5})");
  const PatchCommand& p = patch(c);
  CHECK(p.source.kind == SourceKind::EncodedBytes);
  CHECK(*p.source.name == "song.mp3");
  CHECK(p.pan.value(0) == 0.5);
  CHECK(p.playback_rate.value(0) == 1.5);
  CHECK(!p.looping);
}

TEST_CASE("parse patch with time envelope") {
  Command c = parse(R"({"command": "patch", "id": "fading", "source": {"kind": "waveform", "waveform": "sine", "frequency": 440},
                        "volume": [{"time": 0.0, "value": 0.0}, {"time": 1.0, "value": 1.0, "interpolation_from_prev": "linear"}],
                        "looping": false, "playback_rate": 1.0})");
  CHECK(patch(c).volume.value(0.5) == Approx(0.5));
}

TEST_CASE("parse patch defaults") {
  Command c = parse(R"({"command": "patch", "id": "test", "source": {"kind": "waveform", "waveform": "sine", "frequency": 440}})");
  const PatchCommand& p = patch(c);
  CHECK(p.volume.value(0) == 1.0);
  CHECK(p.pan.value(0) == 0.0);
  CHECK(p.playback_rate.value(0) == 1.0);
  CHECK(p.start_time == 0.0);
  CHECK(!p.looping);
  CHECK(!p.lpf);
  CHECK(!p.filter_gain);
}

TEST_CASE("parse patch start time and fade out") {
  Command c = parse(R"({"command": "patch", "id": "delayed", "start_time": 0.5,
                        "source": {"kind": "waveform", "waveform": "sine", "frequency": 440, "non_looping_duration": 1.0, "fade_out": 0.1}})");
  const PatchCommand& p = patch(c);
  CHECK(p.start_time == 0.5);
  CHECK(*p.source.fade_out == 0.1);
  CHECK(*p.source.non_looping_duration == 1.0);
}

TEST_CASE("lpf") {
  SUBCASE("enabled lpf brings filter_gain defaulting to fully filtered") {
    Command c = parse(R"({"command": "patch", "id": "f", "source": {"kind": "encoded_bytes", "name": "a.ogg"}, "lpf": {"cutoff": 500, "enabled": true}})");
    const PatchCommand& p = patch(c);
    REQUIRE(p.lpf);
    CHECK(p.lpf->cutoff == 500);
    REQUIRE(p.filter_gain);
    CHECK(p.filter_gain->value(0) == 1.0);
  }
  SUBCASE("cutoff and enabled default") {
    Command c = parse(R"({"command": "patch", "id": "f", "source": {"kind": "encoded_bytes", "name": "a.ogg"}, "lpf": {}, "filter_gain": 0.25})");
    const PatchCommand& p = patch(c);
    REQUIRE(p.lpf);
    CHECK(p.lpf->cutoff == 1000);
    CHECK(p.filter_gain->value(0) == 0.25);
  }
  SUBCASE("disabled lpf is stripped along with filter_gain") {
    Command c = parse(R"({"command": "patch", "id": "f", "source": {"kind": "encoded_bytes", "name": "a.ogg"}, "lpf": {"cutoff": 500, "enabled": false},
                          "filter_gain": 0.5})");
    CHECK(!patch(c).lpf);
    CHECK(!patch(c).filter_gain);
  }
  SUBCASE("cutoff validation") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "f", "source": {"kind": "encoded_bytes", "name": "a"}, "lpf": {"cutoff": 0}})")),
                    {"cutoff", "positive"}));
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "f", "source": {"kind": "encoded_bytes", "name": "a"}, "lpf": {"cutoff": 30000}})")),
                    {"cutoff", "audible"}));
  }
}

TEST_CASE("parse errors") {
  CHECK(parse_error(R"({"command": "unknown"})").find("Unknown command type") != std::string::npos);
  CHECK(parse_error(R"({"id": "x"})").find("Unknown command type") != std::string::npos);
  CHECK(parse_error(R"({"command": "patch", "id": "x", "source": {"kind": "midi"}})").find("Unknown source kind") != std::string::npos);
  CHECK(!parse_error(R"({"command": "patch", "id": "x"})").empty());  // no source
  CHECK(!parse_error(R"({"command": "patch", "source": {"kind": "waveform"}})").empty());  // no id
  CHECK(!parse_error(R"({"command": "stop"})").empty());
  CHECK(!parse_error(R"({"command": "stop", "id": 5})").empty());
  CHECK(!parse_error(R"({"command": "patch", "id": "x", "source": {"kind": "waveform"}, "volume": "loud"})").empty());
  CHECK(!parse_error(R"({"command": "patch", "id": "x", "source": {"kind": "waveform"}, "volume": null})").empty());
  CHECK(!parse_error(R"([1, 2])").empty());
  CHECK(parse_error("acmd 1 {").find("invalid JSON") != std::string::npos);
  CHECK(parse_error(R"({"command": "compound", "commands": [{"command": "stop", "id": "a"}, {"command": "nope"}]})").find("sub-command 1") !=
        std::string::npos);
}

TEST_CASE("validate") {
  SUBCASE("valid stop") { CHECK(validate_command(Command{StopCommand{"test"}}).empty()); }
  SUBCASE("stop missing id") {
    auto errors = validate_command(Command{StopCommand{""}});
    REQUIRE(!errors.empty());
    CHECK(lower(errors[0]).find("missing id") != std::string::npos);
  }
  SUBCASE("valid waveform patch") {
    CHECK(validate_command(parse(R"({"command": "patch", "id": "test", "source": {"kind": "waveform", "waveform": "sine", "frequency": 440}})")).empty());
  }
  SUBCASE("patch with empty id") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "", "source": {"kind": "waveform", "waveform": "sine", "frequency": 1}})")),
                    {"missing id"}));
  }
  SUBCASE("waveform missing type") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "test", "source": {"kind": "waveform", "frequency": 440}})")), {"waveform type"}));
  }
  SUBCASE("unknown waveform type") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "t", "source": {"kind": "waveform", "waveform": "noise", "frequency": 1}})")),
                    {"unknown waveform"}));
  }
  SUBCASE("waveform missing frequency") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "test", "source": {"kind": "waveform", "waveform": "sine"}})")), {"frequency"}));
  }
  SUBCASE("encoded bytes missing name") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "test", "source": {"kind": "encoded_bytes"}})")), {"name"}));
  }
  SUBCASE("negative start time") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "test", "start_time": -1.0,
                                               "source": {"kind": "waveform", "waveform": "sine", "frequency": 440}})")),
                    {"start_time", "negative"}));
  }
  SUBCASE("fade out exceeds duration") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "test",
                                               "source": {"kind": "waveform", "waveform": "sine", "frequency": 440,
                                                          "non_looping_duration": 0.5, "fade_out": 1.0}})")),
                    {"fade_out", "exceeds"}));
  }
  SUBCASE("negative fade out") {
    CHECK(any_error(validate_command(parse(R"({"command": "patch", "id": "t",
                                               "source": {"kind": "waveform", "waveform": "sine", "frequency": 1, "fade_out": -1}})")),
                    {"fade_out", "negative"}));
  }
}

TEST_CASE("compound") {
  SUBCASE("parse") {
    Command c = parse(R"({"command": "compound", "commands": [
                          {"command": "patch", "id": "note1", "start_time": 0.0, "source": {"kind": "waveform", "waveform": "sine", "frequency": 440}},
                          {"command": "patch", "id": "note2", "start_time": 0.5, "source": {"kind": "waveform", "waveform": "sine", "frequency": 880}}]})");
    REQUIRE(std::holds_alternative<CompoundCommand>(c.v));
    auto& subs = std::get<CompoundCommand>(c.v).commands;
    REQUIRE(subs.size() == 2);
    CHECK(patch(subs[0]).id == "note1");
    CHECK(patch(subs[0]).start_time == 0.0);
    CHECK(patch(subs[1]).id == "note2");
    CHECK(patch(subs[1]).start_time == 0.5);
  }
  SUBCASE("with stops") {
    Command c = parse(R"({"command": "compound", "commands": [{"command": "stop", "id": "sound1"}, {"command": "stop", "id": "sound2"}]})");
    for (auto& sub : std::get<CompoundCommand>(c.v).commands) CHECK(std::holds_alternative<StopCommand>(sub.v));
  }
  SUBCASE("empty compound is invalid, including the {} Factorio writes for an empty table") {
    CHECK(any_error(validate_command(parse(R"({"command": "compound", "commands": []})")), {"no sub-commands"}));
    CHECK(any_error(validate_command(parse(R"({"command": "compound", "commands": {}})")), {"no sub-commands"}));
    CHECK(any_error(validate_command(parse(R"({"command": "compound"})")), {"no sub-commands"}));
  }
  SUBCASE("errors propagate with their index") {
    auto errors = validate_command(parse(R"({"command": "compound", "commands": [{"command": "stop", "id": "ok"},
                                             {"command": "patch", "id": "test", "source": {"kind": "waveform", "waveform": "sine"}}]})"));
    CHECK(any_error(errors, {"sub-command 1", "frequency"}));
  }
}

// Shaped like what helpers.table_to_json produces for the mod's builders (scripts/launcher-audio.lua, scripts/sonifiers/).
TEST_CASE("mod command shapes") {
  SUBCASE("vehicle tone") {
    Command c = parse(R"({"command":"patch","id":"fa_vehicle_sound","source":{"kind":"waveform","waveform":"triangle","frequency":523.25,)"
                      R"("non_looping_duration":0.08,"fade_out":0.03},"pan":-0.35,"volume":0.2})");
    CHECK(validate_command(c).empty());
    CHECK(patch(c).pan.value(0) == Approx(-0.35));
  }
  SUBCASE("radar compound with stops and an lpf envelope") {
    Command c = parse(R"({"command":"compound","commands":[{"command":"stop","id":"group-12"},)"
                      R"({"command":"patch","id":"group-15","source":{"kind":"encoded_bytes","name":"sonifiers/combat/enemy.ogg"},"volume":0.6,"pan":0.2,)"
                      R"("playback_rate":1.1,"lpf":{"cutoff":800,"enabled":true},)"
                      R"("filter_gain":[{"time":0,"value":1,"interpolation_from_prev":"linear"},{"time":2,"value":0,"interpolation_from_prev":"linear"}]}]})");
    CHECK(validate_command(c).empty());
    const PatchCommand& p = patch(std::get<CompoundCommand>(c.v).commands[1]);
    CHECK(*p.source.name == "sonifiers/combat/enemy.ogg");
    CHECK(p.filter_gain->value(1.0) == Approx(0.5));
  }
}
