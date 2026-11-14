// fa::speech on macOS, the design of NonVisualCalculus' MacSpeechBackend. At startup, in this order:
//   1. VoiceOver through Prism, when FA_SPEECH=voiceover and the VoiceOver process runs. Opt-in: its announcement
//      API cannot queue, and the mod's speech leans on a queue.
//   2. A running screen reader that ships a Prism plugin (~/Library/Application Support/<reader>/prism/*.dylib):
//      the Mac counterpart of NVDA on Windows, with the player's own voice, rate and speech history.
//   3. The system voice, spoken by this file itself: each line is rendered through AVSpeech
//      (writeUtterance:toBufferCallback:), trimmed, faded at its edges and played back to back on an audio engine of
//      its own, because AVSpeech's own queue leaves 120-250 ms of silence between lines. Voice and rate are the
//      player's Spoken Content settings (System Settings, Accessibility, Spoken Content).
// Never Prism's "best" backend: its VoiceOver backend speaks through AppleScript, which launches VoiceOver when it is
// not running. FA_SPEECH=system skips the screen reader search.
#include "speech.h"
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>
#include <prism.h>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <deque>
#include <filesystem>
#include <format>
#include <future>
#include <algorithm>
#include <memory>
#include <mutex>
#include <set>
#include <string>
#include <thread>
#include <vector>
#include "log.h"
#include "mac/speech_audio.h"

namespace fa::speech {
namespace {
using clock = std::chrono::steady_clock;
constexpr double kGapSeconds = 0.05;   // silence after each line, as a screen reader would pause
constexpr double kStallSeconds = 5.0;  // a render that delivers nothing for this long is abandoned

std::mutex g_mu;
bool g_muted = false;
LineRing g_history(500);
std::string g_backend_name = "(none)";

// ---------------- Prism: a screen reader's plugin, or VoiceOver by name ----------------
PrismContext* g_ctx;
PrismBackend* g_backend;
uint64_t g_features;

bool prism_present() { return &prism_init != nullptr; }  // weakly linked: absent when libprism.dylib is missing

void prism_log(void*, PrismLogLevel level, const char* source, const char* message) {
  if (level >= PRISM_LOG_LEVEL_INFO) log::writef("[prism:{}] {}", source ? source : "", message ? message : "");
}

std::vector<std::string> plugin_paths() {
  std::vector<std::string> out;
  const char* home = std::getenv("HOME");
  if (!home) return out;
  std::error_code ec;
  std::filesystem::path support = std::filesystem::path(home) / "Library/Application Support";
  for (auto& app : std::filesystem::directory_iterator(support, ec)) {
    std::filesystem::path dir = app.path() / "prism";
    std::error_code ec2;
    if (!std::filesystem::is_directory(dir, ec2)) continue;
    for (auto& f : std::filesystem::directory_iterator(dir, ec2))
      if (f.path().extension() == ".dylib") out.push_back(f.path().string());
  }
  std::sort(out.begin(), out.end());
  return out;
}

std::set<std::string> builtin_names() {
  std::set<std::string> names;
  PrismConfig cfg = prism_config_init();
  PrismContext* ctx = prism_init(&cfg);
  if (!ctx) return names;
  for (size_t i = 0, n = prism_registry_count(ctx); i < n; ++i) {
    const char* name = prism_registry_name(ctx, prism_registry_id_at(ctx, i));
    names.insert(name ? name : "");
  }
  prism_shutdown(ctx);
  return names;
}

void prism_stop_all() {
  if (g_backend) {
    prism_backend_free(g_backend);
    g_backend = nullptr;
  }
  if (g_ctx) {
    prism_shutdown(g_ctx);
    g_ctx = nullptr;
  }
}

bool voiceover_running() {
  @autoreleasepool {
    return [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.VoiceOver"].count > 0;
  }
}

bool try_prism(bool voiceover) {
  if (!prism_present()) {
    log::write("speech: libprism.dylib not loaded; no screen reader plugins");
    return false;
  }
  prism_set_log_handler(PrismLogHandler{prism_log, nullptr});
  prism_set_log_level(PRISM_LOG_LEVEL_INFO);
  PrismRegistry* registry = nullptr;
  if (!voiceover) {
    PrismRegistryBuilder* builder = prism_registry_builder_new();
    if (!builder) return false;
    int loaded = 0;
    for (auto& path : plugin_paths()) {
      size_t added = 0;
      PrismError e = prism_registry_builder_add_library(builder, path.c_str(), -1, &added);
      if (e == PRISM_OK) {
        ++loaded;
        log::writef("speech: screen reader plugin loaded ({} backends): {}", added, path);
      } else {
        log::writef("speech: screen reader plugin not loaded ({}): {}", prism_error_string(e), path);
      }
    }
    registry = loaded ? prism_registry_freeze(builder) : nullptr;
    prism_registry_builder_free(builder);
    if (!registry) {
      log::write("speech: no screen reader plugin found");
      return false;
    }
  }
  PrismConfig cfg = prism_config_init();
  cfg.registry = registry;
  g_ctx = prism_init(&cfg);
  if (registry) prism_registry_release(registry);
  if (!g_ctx) {
    log::write("speech: prism_init failed");
    return false;
  }
  struct Candidate {
    PrismBackendId id;
    std::string name;
    int priority;
  };
  std::vector<Candidate> all;
  for (size_t i = 0, n = prism_registry_count(g_ctx); i < n; ++i) {
    PrismBackendId id = prism_registry_id_at(g_ctx, i);
    const char* name = prism_registry_name(g_ctx, id);
    all.push_back({id, name ? name : "", prism_registry_priority(g_ctx, id)});
  }
  std::vector<Candidate> pick;
  if (voiceover) {
    for (auto& c : all)
      if (c.name.starts_with("VoiceOver")) pick.push_back(c);
  } else {
    auto builtin = builtin_names();
    for (auto& c : all)
      if (!builtin.count(c.name)) pick.push_back(c);
    std::sort(pick.begin(), pick.end(), [](auto& a, auto& b) { return a.priority > b.priority; });
  }
  for (auto& c : pick) {
    PrismBackend* b = prism_registry_create(g_ctx, c.id);
    if (!b) continue;
    PrismError e = prism_backend_initialize(b);
    if (e != PRISM_OK && e != PRISM_ERROR_ALREADY_INITIALIZED) {
      // A screen reader's plugin answers "not available" while its reader is not running.
      log::writef("speech: backend '{}' did not initialize: {}", c.name, prism_error_string(e));
      prism_backend_free(b);
      continue;
    }
    g_backend = b;
    g_features = prism_backend_get_features(b);
    g_backend_name = "Prism " + c.name;
    return true;
  }
  prism_stop_all();
  return false;
}

void prism_speak(const std::string& text, bool interrupt) {
  // A screen reader's interrupting output cuts the line in flight but may resume its queue after; the mod's
  // interrupt means everything pending goes, as on NVDA.
  if (interrupt && (g_features & PRISM_BACKEND_SUPPORTS_STOP)) (void)prism_backend_stop(g_backend);
  PrismError e = (g_features & PRISM_BACKEND_SUPPORTS_OUTPUT) ? prism_backend_output(g_backend, text.c_str(), interrupt)
                                                              : prism_backend_speak(g_backend, text.c_str(), interrupt);
  if (e != PRISM_OK) log::writef("speech: output failed ({}): {}", prism_error_string(e), text);
}

// ---------------- the system voice ----------------
// The voice and rate of System Settings, Accessibility, Spoken Content. The voice is public API
// (NSSpeechSynthesizer.defaultVoice); the rate lives undocumented in the com.apple.Accessibility domain, as an array
// alternating a language code with a dictionary of voiceId and rate.
NSString* spoken_content_voice() {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  NSString* v = [NSSpeechSynthesizer defaultVoice];
#pragma clang diagnostic pop
  return v.length ? v : nil;
}

float spoken_content_rate(NSString* voice) {
  NSUserDefaults* d = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.Accessibility"];
  id selections = [d objectForKey:@"SpokenContentDefaultVoiceSelectionsByLanguage"];
  if (![selections isKindOfClass:[NSArray class]]) return -1;
  for (id entry in (NSArray*)selections) {
    if (![entry isKindOfClass:[NSDictionary class]]) continue;
    id vid = entry[@"voiceId"];
    if (![vid isKindOfClass:[NSString class]] || ![vid isEqualToString:voice]) continue;
    id rate = entry[@"rate"];
    float r = [rate respondsToSelector:@selector(floatValue)] ? [rate floatValue] : -1;
    return r >= 0 && r <= 1 ? r : -1;
  }
  return -1;
}

// One utterance being rendered. AVSpeech's thread appends; the voice thread reads once `done`.
struct Render {
  std::mutex mu;
  std::vector<float> samples;
  double rate = 0;
  std::atomic<bool> done{false};   // the audio is complete: a zero-frame buffer or the nil marker arrived
  std::atomic<bool> ended{false};  // the nil marker arrived: no more callbacks for this render
  std::atomic<int64_t> last_progress{clock::now().time_since_epoch().count()};
  std::string problem;
  double quiet_seconds() const {
    return std::chrono::duration<double>(clock::now().time_since_epoch() - clock::duration(last_progress.load())).count();
  }
  void append(AVAudioBuffer* buffer) {
    last_progress = clock::now().time_since_epoch().count();
    if (!buffer) {
      done = ended = true;
      return;
    }
    if (done) return;  // closed by a zero-frame buffer: the voice thread may be reading
    if (![buffer isKindOfClass:[AVAudioPCMBuffer class]]) {
      std::lock_guard lk(mu);
      if (problem.empty()) problem = "AVSpeech delivered a buffer that is not PCM";
      return;
    }
    auto* pcm = (AVAudioPCMBuffer*)buffer;
    AVAudioFrameCount frames = pcm.frameLength;
    if (!frames) {
      done = true;
      return;
    }
    if (!pcm.floatChannelData) {
      std::lock_guard lk(mu);
      if (problem.empty()) problem = "AVSpeech delivered a buffer without float samples";
      return;
    }
    std::lock_guard lk(mu);
    double r = pcm.format.sampleRate;
    if (rate <= 0) rate = r;
    else if (r != rate) {
      problem = "the sample rate changed within one line";
      return;
    }
    const float* ch = pcm.floatChannelData[0];  // speech voices are mono
    samples.insert(samples.end(), ch, ch + frames);
  }
};

class SystemVoice {
 public:
  bool start() {
    @autoreleasepool {
      NSString* vid = spoken_content_voice();
      if (vid) voice_ = [AVSpeechSynthesisVoice voiceWithIdentifier:vid];
      float r = vid ? spoken_content_rate(vid) : -1;
      rate_ = r >= 0 ? r : AVSpeechUtteranceDefaultSpeechRate;
      engine_ = [[AVAudioEngine alloc] init];
      player_ = [[AVAudioPlayerNode alloc] init];
      [engine_ attachNode:player_];
      connect(22050);
      NSError* err = nil;
      if (![engine_ startAndReturnError:&err]) {
        log::writef("speech: the audio engine did not start: {}", err ? err.localizedDescription.UTF8String : "?");
        return false;
      }
      synth_ = [[AVSpeechSynthesizer alloc] init];
      description_ = std::format("system voice {}, rate {:.2f}", vid ? vid.UTF8String : "(AVSpeech default)", rate_);
      return true;
    }
  }
  const std::string& description() const { return description_; }

  void enqueue(const std::string& text) {
    if (text.find_first_not_of(" \t\r\n") == std::string::npos) return;
    pending_.push_back(text);
    start_next();
  }

  void clear() {
    pending_.clear();
    if (in_flight_) retire();
    [player_ stop];
  }

  // Reap retired renders, collect a finished one, start the next.
  void update() {
    @autoreleasepool {
      std::erase_if(retired_, [](const Retired& r) { return r.render->ended || r.render->quiet_seconds() > kStallSeconds; });
      if (in_flight_) {
        if (in_flight_->done) finish();
        else if (in_flight_->quiet_seconds() > kStallSeconds) {
          log::write("speech: a render stalled; abandoning it");
          retire();
        }
      }
      start_next();
    }
  }

 private:
  struct Retired {
    AVSpeechSynthesizer* synth;
    std::shared_ptr<Render> render;
  };

  void connect(double rate) {
    if (format_) [engine_ disconnectNodeOutput:player_];
    format_ = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:rate channels:1];
    format_rate_ = rate;
    [engine_ connect:player_ to:engine_.mainMixerNode format:format_];
  }

  void start_next() {
    if (in_flight_ || pending_.empty()) return;
    if (!synth_) synth_ = [[AVSpeechSynthesizer alloc] init];
    std::string text = std::move(pending_.front());
    pending_.pop_front();
    AVSpeechUtterance* u = [AVSpeechUtterance speechUtteranceWithString:[NSString stringWithUTF8String:text.c_str()] ?: @""];
    if (voice_) u.voice = voice_;
    u.rate = rate_;
    auto render = std::make_shared<Render>();
    in_flight_ = render;
    // Each render's block holds its own Render, so a callback that trails an abandoned render lands on that render.
    [synth_ writeUtterance:u
          toBufferCallback:^(AVAudioBuffer* buffer) {
            render->append(buffer);
          }];
  }

  void retire() {
    retired_.push_back({synth_, in_flight_});
    synth_ = nil;  // a write cannot be aborted: the next line gets a fresh synthesizer
    in_flight_.reset();
  }

  void finish() {
    std::shared_ptr<Render> r = in_flight_;
    in_flight_.reset();
    // A render closed by a zero-frame buffer may still get its nil marker: keep its synthesizer out of reuse.
    if (!r->ended) {
      retired_.push_back({synth_, r});
      synth_ = nil;
    }
    std::lock_guard lk(r->mu);
    if (!r->problem.empty()) {
      log::writef("speech: rendered speech unusable: {}", r->problem);
      return;
    }
    schedule(mac::speech_audio::trim(r->samples.data(), r->samples.size(), r->rate), r->rate);
  }

  void schedule(std::vector<float> s, double rate) {
    if (s.empty()) return;
    // The engine stops by itself when the output device changes; bring it back first.
    if (!engine_.running) {
      NSError* err = nil;
      if (![engine_ startAndReturnError:&err]) {
        log::write("speech: the audio engine did not restart; line dropped");
        return;
      }
    }
    if (rate != format_rate_) {
      [player_ stop];
      connect(rate);
    }
    mac::speech_audio::fade_edges(s, rate);
    AVAudioFrameCount frames = (AVAudioFrameCount)(s.size() + (size_t)(kGapSeconds * rate));
    AVAudioPCMBuffer* buf = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format_ frameCapacity:frames];
    if (!buf || !buf.floatChannelData) return;
    float* ch = buf.floatChannelData[0];
    std::copy(s.begin(), s.end(), ch);
    std::fill(ch + s.size(), ch + frames, 0.0f);
    buf.frameLength = frames;
    [player_ scheduleBuffer:buf completionHandler:nil];
    [player_ play];  // idempotent while playing; needed after a stop or a restart
    if (!logged_first_) {
      logged_first_ = true;
      log::writef("speech: first line played, {:.0f} ms at {:.0f} Hz", 1000.0 * s.size() / rate, rate);
    }
  }

  AVAudioEngine* engine_ = nil;
  AVAudioPlayerNode* player_ = nil;
  AVAudioFormat* format_ = nil;
  double format_rate_ = 0;
  AVSpeechSynthesizer* synth_ = nil;
  AVSpeechSynthesisVoice* voice_ = nil;
  float rate_ = 0.5f;
  std::shared_ptr<Render> in_flight_;
  std::vector<Retired> retired_;
  std::deque<std::string> pending_;
  std::string description_;
  bool logged_first_ = false;
};

// The system voice lives on a thread of its own with a run loop: lines come from the game's update thread, and the
// voice needs a steady tick no matter what the game is doing.
struct VoiceThread {
  std::mutex mu;
  std::condition_variable cv;
  std::deque<std::pair<std::string, bool>> lines;  // text, interrupt
  bool stop_requested = false, clear_requested = false, quit = false;
  std::thread thread;
  SystemVoice voice;
};
VoiceThread* g_voice;

void voice_main(VoiceThread* vt, std::promise<bool>* started) {
  pthread_setname_np("fa speech");
  bool ok = vt->voice.start();
  started->set_value(ok);
  if (!ok) return;
  for (;;) {
    @autoreleasepool {
      CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true);
      std::deque<std::pair<std::string, bool>> lines;
      bool clear;
      {
        std::unique_lock lk(vt->mu);
        if (vt->quit) break;
        lines.swap(vt->lines);
        clear = vt->clear_requested;
        vt->clear_requested = false;
      }
      if (clear) vt->voice.clear();
      for (auto& [text, interrupt] : lines) {
        if (interrupt) vt->voice.clear();
        vt->voice.enqueue(text);
      }
      vt->voice.update();
    }
  }
  vt->voice.clear();
}

bool try_system_voice() {
  auto* vt = new VoiceThread();
  std::promise<bool> started;
  auto fut = started.get_future();
  vt->thread = std::thread(voice_main, vt, &started);
  if (!fut.get()) {
    vt->thread.join();
    delete vt;
    return false;
  }
  g_voice = vt;
  g_backend_name = vt->voice.description();
  return true;
}
}  // namespace

bool init() {
  const char* pref = std::getenv("FA_SPEECH");
  std::string want = pref ? pref : "";
  bool ok = false;
  if (want == "voiceover") {
    if (voiceover_running()) ok = try_prism(true);
    else log::write("speech: VoiceOver is not running, so it is not used (the mod never starts it)");
  }
  if (!ok && want != "system") ok = try_prism(false);
  if (!ok) ok = try_system_voice();
  if (!ok) {
    log::write("speech: nothing can speak");
    return false;
  }
  log::writef("speech: using {}{}", g_backend_name, g_muted ? " (muted)" : "");
  return true;
}

const char* backend_name() { return g_backend_name.c_str(); }

void speak(std::string_view utf8, bool interrupt) {
  log::writef("[speak{}] {}", interrupt ? "!" : "", utf8);
  g_history.push(std::string(utf8));
  if (g_muted) return;
  std::lock_guard lk(g_mu);
  if (g_backend) {
    prism_speak(std::string(utf8), interrupt);
  } else if (g_voice) {
    std::lock_guard l2(g_voice->mu);
    g_voice->lines.emplace_back(std::string(utf8), interrupt);
  }
}

void stop() {
  if (g_muted) return;
  std::lock_guard lk(g_mu);
  if (g_backend) {
    if (g_features & PRISM_BACKEND_SUPPORTS_STOP) (void)prism_backend_stop(g_backend);
  } else if (g_voice) {
    std::lock_guard l2(g_voice->mu);
    g_voice->lines.clear();
    g_voice->clear_requested = true;
  }
}

void set_muted(bool m) { g_muted = m; }
bool muted() { return g_muted; }
LineRing& history() { return g_history; }

void shutdown() {
  std::lock_guard lk(g_mu);
  if (g_voice) {
    {
      std::lock_guard l2(g_voice->mu);
      g_voice->quit = true;
    }
    g_voice->thread.join();
    delete g_voice;
    g_voice = nullptr;
  }
  prism_stop_all();
}
}  // namespace fa::speech
