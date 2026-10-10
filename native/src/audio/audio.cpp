#include "audio/audio.h"
#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <deque>
#include <exception>
#include <format>
#include <future>
#include <memory>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_map>
#include "audio/audio_testing.h"
#include "audio/commands.h"
#include "audio/panner_node.h"

namespace fa::audio {
namespace {

// Rate the sources are generated/decoded at. The launcher also used it to turn seconds into engine-clock frames for
// scheduled starts, fade-outs and stops, although the engine runs at the device rate (often 48000). The mod's timings
// were tuned against that, so it is kept; the conversions are all in to_engine_frames() if it is ever corrected.
constexpr ma_uint32 kSourceRate = 44100;
// Volume changes after the first update ramp over this many engine frames (50ms at 44100).
constexpr ma_uint64 kVolumeFadeFrames = 2205;
// The worker wakes at least this often to advance envelopes and reap finished sounds; commands wake it immediately.
constexpr auto kUpdateInterval = std::chrono::milliseconds(10);

ma_uint64 to_engine_frames(double seconds) { return static_cast<ma_uint64>(seconds * kSourceRate); }

std::mutex g_log_mu;
std::function<void(std::string_view)> g_log;

void log(std::string_view msg) {
  std::function<void(std::string_view)> fn;
  {
    std::lock_guard lk(g_log_mu);
    fn = g_log;
  }
  if (!fn) return;
  // A throwing log callback must not take the worker thread (and with it the process) down.
  try {
    fn(msg);
  } catch (...) {
  }
}

template <class... A>
void logf(std::format_string<A...> f, A&&... a) {
  log(std::format(f, std::forward<A>(a)...));
}

std::string ma_err(ma_result r) { return std::format("{} ({})", ma_result_description(r), static_cast<int>(r)); }

struct WaveformSource {
  ma_waveform wf{};
  bool inited = false;
  WaveformSource() = default;
  WaveformSource(const WaveformSource&) = delete;
  WaveformSource& operator=(const WaveformSource&) = delete;
  ~WaveformSource() {
    if (inited) ma_waveform_uninit(&wf);
  }
};

struct DecoderSource {
  std::shared_ptr<const std::vector<std::uint8_t>> bytes;  // the decoder reads from this memory, so it lives as long
  ma_decoder dec{};
  bool inited = false;
  DecoderSource() = default;
  DecoderSource(const DecoderSource&) = delete;
  DecoderSource& operator=(const DecoderSource&) = delete;
  ~DecoderSource() {
    if (inited) ma_decoder_uninit(&dec);
  }
};

// One playing sound and its private node graph. Every source is mono; the panner makes it stereo.
//   without lpf: sound -> panner -> endpoint
//   with lpf:    sound -> splitter -> panner -> endpoint
//                                  -> lpf -> panner_filtered -> endpoint
// filter_gain crossfades the two paths through the panners' output bus volumes.
class Sound {
 public:
  Sound() = default;
  Sound(const Sound&) = delete;
  Sound& operator=(const Sound&) = delete;
  ~Sound() { cleanup(); }

  std::unique_ptr<WaveformSource> wave;
  std::unique_ptr<DecoderSource> decoder;

  ma_result init(ma_engine* engine, ma_data_source* source, std::optional<double> lpf_cutoff, float initial_pan) {
    has_lpf_ = lpf_cutoff.has_value();
    initial_pan = std::clamp(initial_pan, -1.0f, 1.0f);

    ma_sound_config cfg = ma_sound_config_init_2(engine);
    cfg.pDataSource = source;
    cfg.flags = MA_SOUND_FLAG_NO_DEFAULT_ATTACHMENT | MA_SOUND_FLAG_NO_SPATIALIZATION;
    cfg.channelsOut = MA_SOUND_SOURCE_CHANNEL_COUNT;  // keep mono so the panner sees one channel
    ma_result r = ma_sound_init_ex(engine, &cfg, &sound_);
    if (r != MA_SUCCESS) return r;
    sound_inited_ = true;

    ma_node* endpoint = ma_engine_get_endpoint(engine);
    ma_node_graph* graph = ma_engine_get_node_graph(engine);
    if (has_lpf_) {
      ma_splitter_node_config sc = ma_splitter_node_config_init(1);
      if ((r = ma_splitter_node_init(graph, &sc, nullptr, &splitter_)) != MA_SUCCESS) return r;
      splitter_inited_ = true;
      ma_lpf_node_config lc = ma_lpf_node_config_init(1, ma_engine_get_sample_rate(engine), *lpf_cutoff, 2);
      if ((r = ma_lpf_node_init(graph, &lc, nullptr, &lpf_)) != MA_SUCCESS) return r;
      lpf_inited_ = true;
      if ((r = panner_node_init(graph, initial_pan, nullptr, &panner_)) != MA_SUCCESS) return r;
      panner_inited_ = true;
      if ((r = panner_node_init(graph, initial_pan, nullptr, &panner_filtered_)) != MA_SUCCESS) return r;
      panner_filtered_inited_ = true;
      if ((r = ma_node_attach_output_bus(&sound_, 0, &splitter_, 0)) != MA_SUCCESS) return r;
      if ((r = ma_node_attach_output_bus(&splitter_, 0, &panner_, 0)) != MA_SUCCESS) return r;
      if ((r = ma_node_attach_output_bus(&splitter_, 1, &lpf_, 0)) != MA_SUCCESS) return r;
      if ((r = ma_node_attach_output_bus(&lpf_, 0, &panner_filtered_, 0)) != MA_SUCCESS) return r;
      if ((r = ma_node_attach_output_bus(&panner_, 0, endpoint, 0)) != MA_SUCCESS) return r;
      if ((r = ma_node_attach_output_bus(&panner_filtered_, 0, endpoint, 0)) != MA_SUCCESS) return r;
    } else {
      if ((r = panner_node_init(graph, initial_pan, nullptr, &panner_)) != MA_SUCCESS) return r;
      panner_inited_ = true;
      if ((r = ma_node_attach_output_bus(&sound_, 0, &panner_, 0)) != MA_SUCCESS) return r;
      if ((r = ma_node_attach_output_bus(&panner_, 0, endpoint, 0)) != MA_SUCCESS) return r;
    }
    return MA_SUCCESS;
  }

  bool has_lpf() const { return has_lpf_; }

  // The first set goes to the sound node's output bus; later ones fade the sound's fader from wherever it is. The two
  // multiply, so a steady volume v plays at v*v after the first update. The launcher behaved this way and the mod's
  // levels were tuned by ear against it; changing it means retuning every sonifier.
  void set_volume(float v, bool fade) {
    if (fade) ma_sound_set_fade_in_pcm_frames(&sound_, -1.0f, v, kVolumeFadeFrames);
    else ma_node_set_output_bus_volume(&sound_, 0, v);
  }

  void set_pan(float pan) {
    pan = std::clamp(pan, -1.0f, 1.0f);
    panner_node_set_pan(&panner_, pan);
    if (has_lpf_ && panner_filtered_inited_) panner_node_set_pan(&panner_filtered_, pan);
  }

  void set_filter_gain(float g) {
    if (!has_lpf_) return;
    g = std::clamp(g, 0.0f, 1.0f);
    ma_node_set_output_bus_volume(&panner_, 0, 1.0f - g);
    ma_node_set_output_bus_volume(&panner_filtered_, 0, g);
  }

  void set_pitch(float p) { ma_sound_set_pitch(&sound_, p); }

  void set_looping(bool l) {
    looping_ = l;
    ma_sound_set_looping(&sound_, l ? MA_TRUE : MA_FALSE);
  }

  ma_result start() {
    if (started_) return MA_SUCCESS;
    ma_result r = ma_sound_start(&sound_);
    if (r == MA_SUCCESS) started_ = true;
    return r;
  }

  void stop() { ma_sound_stop(&sound_); }
  bool is_playing() const { return ma_sound_is_playing(&sound_) != MA_FALSE; }
  bool is_finished() const { return !looping_ && ma_sound_at_end(&sound_) != MA_FALSE; }

  void set_fade_at(float from, float to, ma_uint64 frames, ma_uint64 start_frame) {
    ma_sound_set_fade_start_in_pcm_frames(&sound_, from, to, frames, start_frame);
  }
  void schedule_start(ma_uint64 frame) { ma_sound_set_start_time_in_pcm_frames(&sound_, frame); }
  void schedule_stop(ma_uint64 frame) { ma_sound_set_stop_time_in_pcm_frames(&sound_, frame); }

  // Downstream nodes first, then the sound, then the source it reads from.
  void cleanup() {
    if (panner_filtered_inited_) panner_node_uninit(&panner_filtered_, nullptr);
    if (panner_inited_) panner_node_uninit(&panner_, nullptr);
    if (lpf_inited_) ma_lpf_node_uninit(&lpf_, nullptr);
    if (splitter_inited_) ma_splitter_node_uninit(&splitter_, nullptr);
    if (sound_inited_) ma_sound_uninit(&sound_);
    panner_filtered_inited_ = panner_inited_ = lpf_inited_ = splitter_inited_ = sound_inited_ = false;
    wave.reset();
    decoder.reset();
  }

 private:
  ma_sound sound_{};
  panner_node panner_{};
  panner_node panner_filtered_{};
  ma_splitter_node splitter_{};
  ma_lpf_node lpf_{};
  bool sound_inited_ = false, panner_inited_ = false, panner_filtered_inited_ = false, splitter_inited_ = false, lpf_inited_ = false;
  bool has_lpf_ = false;
  bool looping_ = false;
  bool started_ = false;
};

struct ManagedSound {
  std::unique_ptr<Sound> sound;
  Param volume, pan, playback_rate;
  std::optional<Param> filter_gain;
  double start_time = 0.0;  // engine seconds when the sound becomes audible; envelopes are relative to it
  std::optional<double> duration;  // stop after this many seconds, unless a scheduled stop already covers it
  bool scheduled = false;  // waiting for a delayed start
  std::optional<ma_uint64> scheduled_stop_frame;
  bool stopped_by_duration = false;
  bool first_update = true;

  void update(double now) {
    if (scheduled) {
      if (!sound->is_playing()) return;
      scheduled = false;
    }
    double elapsed = now - start_time;
    if (duration && !stopped_by_duration && elapsed >= *duration) {
      sound->stop();
      stopped_by_duration = true;
      return;
    }
    sound->set_volume(static_cast<float>(volume.value(elapsed)), !first_update);
    sound->set_pan(static_cast<float>(pan.value(elapsed)));
    sound->set_pitch(static_cast<float>(playback_rate.value(elapsed)));
    if (filter_gain && sound->has_lpf()) sound->set_filter_gain(static_cast<float>(filter_gain->value(elapsed)));
    first_update = false;
  }

  bool is_finished(ma_uint64 frame) const {
    if (stopped_by_duration) return true;
    if (scheduled_stop_frame && frame >= *scheduled_stop_frame) return true;
    return sound->is_finished();
  }
};

// Phase that starts each waveform on a zero crossing, so the start does not click. Square waves have none.
std::optional<double> zero_crossing_phase(ma_waveform_type t) {
  switch (t) {
    case ma_waveform_type_triangle: return 0.25;  // rising edge
    case ma_waveform_type_sawtooth: return 0.5;
    default: return std::nullopt;  // sine already starts at 0
  }
}

std::optional<ma_waveform_type> waveform_type(std::string_view name) {
  if (name == "sine") return ma_waveform_type_sine;
  if (name == "square") return ma_waveform_type_square;
  if (name == "triangle") return ma_waveform_type_triangle;
  if (name == "saw" || name == "sawtooth") return ma_waveform_type_sawtooth;
  return std::nullopt;
}

class Worker {
 public:
  Worker(AssetLoader loader, bool null_device) : loader_(std::move(loader)), null_device_(null_device) {}

  // Starts the thread and waits for it to bring the engine up. The engine is created and destroyed on the worker so
  // miniaudio's COM setup happens on a thread we own rather than on whatever thread called init().
  bool start() {
    std::promise<bool> ready;
    auto fut = ready.get_future();
    thread_ = std::thread([this, &ready] { run(ready); });
    if (fut.get()) return true;
    thread_.join();
    return false;
  }

  void stop() {
    {
      std::lock_guard lk(mu_);
      stopping_ = true;
    }
    cv_.notify_one();
    if (thread_.joinable()) thread_.join();
  }

  void submit(std::string_view text) {
    {
      std::lock_guard lk(mu_);
      queue_.emplace_back(text);
    }
    cv_.notify_one();
  }

 private:
  AssetLoader loader_;
  bool null_device_;
  std::thread thread_;
  std::mutex mu_;
  std::condition_variable cv_;
  std::deque<std::string> queue_;
  bool stopping_ = false;

 public:
  std::atomic<size_t> live{0};  // sounds tracked as of the last tick
  std::atomic<uint64_t> ticks{0};

 private:

  // Worker thread only from here down.
  ma_context context_{};
  ma_engine engine_{};
  std::unordered_map<std::string, std::unique_ptr<ManagedSound>> sounds_;
  std::unordered_map<std::string, std::shared_ptr<const std::vector<std::uint8_t>>> cache_;

  void run(std::promise<bool>& ready) {
    ma_engine_config cfg = ma_engine_config_init();
    ma_result r;
    if (null_device_) {
      ma_backend null_backend = ma_backend_null;
      if ((r = ma_context_init(&null_backend, 1, nullptr, &context_)) != MA_SUCCESS) {
        logf("audio: null context init failed: {}", ma_err(r));
        ready.set_value(false);
        return;
      }
      cfg.pContext = &context_;
    }
    if ((r = ma_engine_init(&cfg, &engine_)) != MA_SUCCESS) {
      logf("audio: engine init failed: {}", ma_err(r));
      if (null_device_) ma_context_uninit(&context_);
      ready.set_value(false);
      return;
    }
    logf("audio: engine running at {} Hz", ma_engine_get_sample_rate(&engine_));
    ready.set_value(true);

    while (true) {
      std::deque<std::string> batch;
      {
        std::unique_lock lk(mu_);
        cv_.wait_for(lk, kUpdateInterval, [this] { return stopping_ || !queue_.empty(); });
        if (stopping_) break;
        batch.swap(queue_);
      }
      for (auto& text : batch) process(text);
      tick();
    }

    sounds_.clear();
    ma_engine_uninit(&engine_);
    if (null_device_) ma_context_uninit(&context_);
  }

  void tick() {
    try {
      double now = time_seconds();
      for (auto& [id, m] : sounds_) m->update(now);
      ma_uint64 frame = ma_engine_get_time_in_pcm_frames(&engine_);
      std::erase_if(sounds_, [frame](const auto& kv) { return kv.second->is_finished(frame); });
      live = sounds_.size();
      ticks++;
    } catch (const std::exception& e) {
      logf("audio: update failed: {}", e.what());
    }
  }

  double time_seconds() const { return static_cast<double>(ma_engine_get_time_in_pcm_frames(&engine_)) / ma_engine_get_sample_rate(&engine_); }

  void process(const std::string& text) {
    try {
      std::string error;
      auto cmd = parse_command(text, error);
      if (!cmd) {
        logf("audio: bad command ({}): {}", error, text);
        return;
      }
      auto errors = validate_command(*cmd);
      if (!errors.empty()) {
        std::string joined;
        for (auto& e : errors) joined += (joined.empty() ? "" : "; ") + e;
        logf("audio: invalid command ({}): {}", joined, text);
        return;
      }
      execute(*cmd);
    } catch (const std::exception& e) {
      logf("audio: command failed ({}): {}", e.what(), text);
    } catch (...) {
      logf("audio: command failed: {}", text);
    }
  }

  void execute(const Command& cmd) {
    if (auto* s = std::get_if<StopCommand>(&cmd.v)) {
      if (auto it = sounds_.find(s->id); it != sounds_.end()) {
        it->second->sound->stop();
        sounds_.erase(it);
      }
    } else if (auto* p = std::get_if<PatchCommand>(&cmd.v)) {
      if (auto it = sounds_.find(p->id); it != sounds_.end()) update_existing(*it->second, *p);
      else create(*p);
    } else if (auto* c = std::get_if<CompoundCommand>(&cmd.v)) {
      for (auto& sub : c->commands) execute(sub);
    }
  }

  // A patch to a live sound only changes its parameters; the source, filter and start time are fixed at creation.
  // Envelopes stay relative to the original start.
  static void update_existing(ManagedSound& m, const PatchCommand& cmd) {
    if (!cmd.looping) m.sound->set_looping(false);  // looping only ever turns off: that lets a loop end gracefully
    m.volume = cmd.volume;
    m.pan = cmd.pan;
    m.playback_rate = cmd.playback_rate;
    if (cmd.filter_gain) m.filter_gain = cmd.filter_gain;
  }

  std::shared_ptr<const std::vector<std::uint8_t>> load(const std::string& name) {
    if (auto it = cache_.find(name); it != cache_.end()) return it->second;
    auto bytes = loader_(name);
    if (!bytes) return nullptr;
    auto shared = std::make_shared<const std::vector<std::uint8_t>>(std::move(*bytes));
    cache_.emplace(name, shared);
    return shared;
  }

  // Builds the sound's source. Validation has already guaranteed the fields each kind needs.
  bool make_source(const SourceConfig& src, Sound& sound, ma_data_source*& out, const std::string& id) {
    if (src.kind == SourceKind::Waveform) {
      auto type = waveform_type(*src.waveform);
      if (!type) {
        logf("audio: sound {}: unknown waveform {}", id, *src.waveform);
        return false;
      }
      auto w = std::make_unique<WaveformSource>();
      ma_waveform_config cfg = ma_waveform_config_init(ma_format_f32, 1, kSourceRate, *type, 1.0, *src.frequency);
      if (ma_result r = ma_waveform_init(&cfg, &w->wf); r != MA_SUCCESS) {
        logf("audio: sound {}: waveform init failed: {}", id, ma_err(r));
        return false;
      }
      w->inited = true;
      // A zero or negative frequency has no phase to seek to (and the launcher would have crashed on it).
      if (auto phase = zero_crossing_phase(*type); phase && *src.frequency > 0)
        ma_waveform_seek_to_pcm_frame(&w->wf, static_cast<ma_uint64>(*phase * kSourceRate / *src.frequency));
      out = &w->wf;
      sound.wave = std::move(w);
      return true;
    }
    auto bytes = load(*src.name);
    if (!bytes) {
      logf("audio: sound {}: asset not found: {}", id, *src.name);
      return false;
    }
    auto d = std::make_unique<DecoderSource>();
    d->bytes = std::move(bytes);
    ma_decoder_config cfg = ma_decoder_config_init(ma_format_f32, 1, kSourceRate);  // mono: panning is ours
    if (ma_result r = ma_decoder_init_memory(d->bytes->data(), d->bytes->size(), &cfg, &d->dec); r != MA_SUCCESS) {
      logf("audio: sound {}: cannot decode {}: {}", id, *src.name, ma_err(r));
      return false;
    }
    d->inited = true;
    out = &d->dec;
    sound.decoder = std::move(d);
    return true;
  }

  void create(const PatchCommand& cmd) {
    auto sound = std::make_unique<Sound>();
    ma_data_source* source = nullptr;
    if (!make_source(cmd.source, *sound, source, cmd.id)) return;

    std::optional<double> cutoff;
    if (cmd.lpf) cutoff = cmd.lpf->cutoff;
    if (ma_result r = sound->init(&engine_, source, cutoff, static_cast<float>(cmd.pan.value(0.0))); r != MA_SUCCESS) {
      logf("audio: sound {}: init failed: {}", cmd.id, ma_err(r));
      return;
    }
    sound->set_looping(cmd.looping);
    sound->set_volume(static_cast<float>(cmd.volume.value(0.0)), false);
    sound->set_pitch(static_cast<float>(cmd.playback_rate.value(0.0)));
    if (cmd.filter_gain && sound->has_lpf()) sound->set_filter_gain(static_cast<float>(cmd.filter_gain->value(0.0)));

    double now = time_seconds();
    ma_uint64 frame = ma_engine_get_time_in_pcm_frames(&engine_);

    const SourceConfig& src = cmd.source;
    std::optional<double> duration;
    if (!cmd.looping && src.kind == SourceKind::Waveform && src.non_looping_duration && *src.non_looping_duration != 0) duration = src.non_looping_duration;

    bool scheduled = cmd.start_time > 0;
    ma_uint64 start_frame = scheduled ? frame + to_engine_frames(cmd.start_time) : frame;
    if (scheduled) sound->schedule_start(start_frame);

    // A waveform with a duration and a fade-out gets a sample-accurate fade and stop on the engine clock. The fade
    // starts from -1 (the fader's current level) because the volume itself lives on the node bus, not the fader.
    std::optional<ma_uint64> stop_frame;
    if (src.kind == SourceKind::Waveform && src.fade_out && *src.fade_out != 0 && duration) {
      ma_uint64 fade_frames = to_engine_frames(*src.fade_out);
      stop_frame = start_frame + to_engine_frames(*duration);
      sound->set_fade_at(-1.0f, 0.0f, fade_frames, *stop_frame - fade_frames);
      sound->schedule_stop(*stop_frame);
    }

    if (ma_result r = sound->start(); r != MA_SUCCESS) {
      logf("audio: sound {}: start failed: {}", cmd.id, ma_err(r));
      return;
    }

    auto m = std::make_unique<ManagedSound>();
    m->sound = std::move(sound);
    m->volume = cmd.volume;
    m->pan = cmd.pan;
    m->playback_rate = cmd.playback_rate;
    m->filter_gain = cmd.filter_gain;
    m->start_time = scheduled ? now + cmd.start_time : now;
    m->duration = stop_frame ? std::nullopt : duration;  // the scheduled stop already ends it
    m->scheduled = scheduled;
    m->scheduled_stop_frame = stop_frame;
    sounds_[cmd.id] = std::move(m);
  }
};

std::mutex g_api_mu;
std::unique_ptr<Worker> g_worker;

bool start(AssetLoader loader, bool null_device) {
  std::lock_guard lk(g_api_mu);
  if (g_worker) {
    log("audio: init called while already running; keeping the running engine");
    return true;
  }
  try {
    auto w = std::make_unique<Worker>(std::move(loader), null_device);
    if (!w->start()) return false;
    g_worker = std::move(w);
    return true;
  } catch (const std::exception& e) {
    logf("audio: init failed: {}", e.what());
    return false;
  }
}

}  // namespace

bool init(AssetLoader loader) { return start(std::move(loader), false); }

namespace testing {
bool init_null_device(AssetLoader loader) { return start(std::move(loader), true); }

size_t live_sounds() {
  std::lock_guard lk(g_api_mu);
  return g_worker ? g_worker->live.load() : 0;
}

uint64_t ticks() {
  std::lock_guard lk(g_api_mu);
  return g_worker ? g_worker->ticks.load() : 0;
}
}  // namespace testing

void set_log(std::function<void(std::string_view)> fn) {
  std::lock_guard lk(g_log_mu);
  g_log = std::move(fn);
}

void submit(std::string_view json) {
  try {
    std::lock_guard lk(g_api_mu);
    if (g_worker) g_worker->submit(json);
  } catch (const std::exception& e) {
    logf("audio: submit failed: {}", e.what());
  }
}

void shutdown() {
  std::lock_guard lk(g_api_mu);
  if (!g_worker) return;
  g_worker->stop();
  g_worker.reset();
}

}  // namespace fa::audio
