// The worker and engine end to end on miniaudio's null backend: real time passes, nothing is audible.
#include <doctest/doctest.h>
#include <chrono>
#include <cmath>
#include <cstring>
#include <map>
#include <mutex>
#include <string>
#include <thread>
#include "audio/audio.h"
#include "audio/audio_testing.h"

using namespace fa::audio;
using namespace std::chrono_literals;

namespace {

// A mono 16-bit 44.1kHz WAV of a quiet sine.
std::vector<std::uint8_t> make_wav(double seconds) {
  const uint32_t rate = 44100;
  const uint32_t frames = static_cast<uint32_t>(seconds * rate);
  std::vector<std::uint8_t> out;
  auto u32 = [&](uint32_t v) {
    for (int i = 0; i < 4; i++) out.push_back(static_cast<std::uint8_t>(v >> (8 * i)));
  };
  auto u16 = [&](uint16_t v) {
    out.push_back(static_cast<std::uint8_t>(v));
    out.push_back(static_cast<std::uint8_t>(v >> 8));
  };
  auto tag = [&](const char* t) { out.insert(out.end(), t, t + 4); };
  tag("RIFF");
  u32(36 + frames * 2);
  tag("WAVE");
  tag("fmt ");
  u32(16);
  u16(1);
  u16(1);
  u32(rate);
  u32(rate * 2);
  u16(2);
  u16(16);
  tag("data");
  u32(frames * 2);
  for (uint32_t i = 0; i < frames; i++) u16(static_cast<uint16_t>(static_cast<int16_t>(1000 * std::sin(i * 0.06))));
  return out;
}

struct Harness {
  std::mutex mu;
  std::vector<std::string> logs;
  std::map<std::string, int> loads;

  Harness() {
    set_log([this](std::string_view m) {
      std::lock_guard lk(mu);
      logs.emplace_back(m);
    });
    bool ok = testing::init_null_device([this](std::string_view name) -> std::optional<std::vector<std::uint8_t>> {
      {
        std::lock_guard lk(mu);
        loads[std::string(name)]++;
      }
      if (name == "short.wav") return make_wav(0.1);
      if (name == "junk.bin") return std::vector<std::uint8_t>(64, 0x5a);
      return std::nullopt;
    });
    REQUIRE(ok);
  }
  ~Harness() {
    shutdown();
    set_log(nullptr);
  }

  // Waits for the worker to finish everything submitted so far, plus one more tick so the effects are visible.
  static void settle() {
    uint64_t start = testing::ticks();
    auto deadline = std::chrono::steady_clock::now() + 2s;
    while (testing::ticks() < start + 2 && std::chrono::steady_clock::now() < deadline) std::this_thread::sleep_for(1ms);
  }

  template <class Pred>
  static bool wait_for(Pred pred, std::chrono::milliseconds limit = 2000ms) {
    auto deadline = std::chrono::steady_clock::now() + limit;
    while (!pred()) {
      if (std::chrono::steady_clock::now() > deadline) return false;
      std::this_thread::sleep_for(2ms);
    }
    return true;
  }

  bool logged(std::string_view needle) {
    std::lock_guard lk(mu);
    for (auto& l : logs)
      if (l.find(needle) != std::string::npos) return true;
    return false;
  }

  int load_count(const std::string& name) {
    std::lock_guard lk(mu);
    return loads[name];
  }
};

}  // namespace

TEST_CASE("the API is inert before init and shutdown is idempotent") {
  submit(R"({"command": "stop", "id": "x"})");
  submit("garbage");
  shutdown();
  shutdown();
  CHECK(testing::live_sounds() == 0);
}

TEST_CASE("engine on the null backend") {
  Harness h;

  SUBCASE("a waveform with a duration ends on its own") {
    submit(R"({"command":"patch","id":"tone","source":{"kind":"waveform","waveform":"sine","frequency":440,"non_looping_duration":0.1}})");
    h.settle();
    CHECK(testing::live_sounds() == 1);
    CHECK(Harness::wait_for([] { return testing::live_sounds() == 0; }));
  }

  SUBCASE("a waveform with a fade-out ends at its scheduled stop") {
    submit(R"({"command":"patch","id":"tone","source":{"kind":"waveform","waveform":"triangle","frequency":440,"non_looping_duration":0.1,"fade_out":0.05}})");
    h.settle();
    CHECK(testing::live_sounds() == 1);
    CHECK(Harness::wait_for([] { return testing::live_sounds() == 0; }));
  }

  SUBCASE("a scheduled start is tracked before it plays and ends after") {
    submit(R"({"command":"patch","id":"later","start_time":0.2,)"
           R"("source":{"kind":"waveform","waveform":"saw","frequency":440,"non_looping_duration":0.1,"fade_out":0.02}})");
    h.settle();
    CHECK(testing::live_sounds() == 1);
    CHECK(Harness::wait_for([] { return testing::live_sounds() == 0; }));
  }

  SUBCASE("a repeated id patches the live sound instead of starting another") {
    for (int i = 0; i < 5; i++) submit(R"({"command":"patch","id":"same","looping":true,"source":{"kind":"waveform","waveform":"square","frequency":220}})");
    h.settle();
    CHECK(testing::live_sounds() == 1);
    submit(R"({"command":"stop","id":"same"})");
    h.settle();
    CHECK(testing::live_sounds() == 0);
  }

  SUBCASE("turning looping off lets the loop finish") {
    const char* looped = R"({"command":"patch","id":"wav","looping":true,"source":{"kind":"encoded_bytes","name":"short.wav"}})";
    submit(looped);
    std::this_thread::sleep_for(300ms);
    h.settle();
    CHECK(testing::live_sounds() == 1);
    submit(R"({"command":"patch","id":"wav","looping":false,"source":{"kind":"encoded_bytes","name":"short.wav"}})");
    CHECK(Harness::wait_for([] { return testing::live_sounds() == 0; }));
  }

  SUBCASE("encoded assets are loaded once and cached") {
    submit(R"({"command":"compound","commands":[{"command":"patch","id":"a","source":{"kind":"encoded_bytes","name":"short.wav"}},)"
           R"({"command":"patch","id":"b","pan":-1,"volume":0.5,"source":{"kind":"encoded_bytes","name":"short.wav"},"lpf":{"cutoff":500},)"
           R"("filter_gain":[{"time":0,"value":1},{"time":0.1,"value":0}]}]})");
    h.settle();
    CHECK(testing::live_sounds() == 2);
    CHECK(Harness::wait_for([] { return testing::live_sounds() == 0; }));
    submit(R"({"command":"patch","id":"c","source":{"kind":"encoded_bytes","name":"short.wav"}})");
    h.settle();
    CHECK(h.load_count("short.wav") == 1);
  }

  SUBCASE("a missing asset is logged and retried next time") {
    submit(R"({"command":"patch","id":"m","source":{"kind":"encoded_bytes","name":"missing.ogg"}})");
    submit(R"({"command":"patch","id":"m","source":{"kind":"encoded_bytes","name":"missing.ogg"}})");
    h.settle();
    CHECK(testing::live_sounds() == 0);
    CHECK(h.logged("missing.ogg"));
    CHECK(h.load_count("missing.ogg") == 2);
  }

  SUBCASE("bytes that do not decode are logged") {
    submit(R"({"command":"patch","id":"x","source":{"kind":"encoded_bytes","name":"junk.bin"}})");
    h.settle();
    CHECK(testing::live_sounds() == 0);
    CHECK(h.logged("cannot decode junk.bin"));
  }

  SUBCASE("a zero frequency is harmless") {
    submit(R"({"command":"patch","id":"x","source":{"kind":"waveform","waveform":"saw","frequency":0,"non_looping_duration":0.05}})");
    h.settle();
    CHECK(Harness::wait_for([] { return testing::live_sounds() == 0; }));
  }

  SUBCASE("malformed and invalid commands are logged and the worker keeps going") {
    submit("{not json");
    submit(R"({"command":"patch","id":"bad","source":{"kind":"waveform","waveform":"sine"}})");
    submit(R"({"command":"compound","commands":[{"command":"stop","id":"a"},{"command":"explode"}]})");
    submit(std::string(5000, '['));
    submit(R"({"command":"patch","id":"ok","looping":true,"source":{"kind":"waveform","waveform":"sine","frequency":440}})");
    h.settle();
    CHECK(h.logged("invalid JSON"));
    CHECK(h.logged("frequency"));
    CHECK(h.logged("Unknown command type"));
    CHECK(testing::live_sounds() == 1);
  }
}
