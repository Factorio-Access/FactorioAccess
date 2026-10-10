#pragma once
// Sound playback driven by JSON command strings from the mod (scripts/launcher-audio.lua): a port of the launcher's
// fa_launcher_audio package. Commands are queued and run on a worker thread that owns the miniaudio engine.
#include <cstdint>
#include <functional>
#include <optional>
#include <string_view>
#include <vector>

namespace fa::audio {
// Loads the bytes of a named asset ("sounds/foo.ogg"), or nullopt when it does not exist. Called on the worker thread,
// once per distinct name that loads successfully (the bytes are cached for the session; misses are retried).
using AssetLoader = std::function<std::optional<std::vector<std::uint8_t>>(std::string_view name)>;
bool init(AssetLoader loader);  // starts the engine and the worker thread; false (logged via a log callback) on failure
void submit(std::string_view json);  // one command string exactly as the mod sends it; thread-safe; malformed input is logged and ignored
void shutdown();  // stops the worker, uninitialises the engine; safe to call twice
void set_log(std::function<void(std::string_view)> log);
}  // namespace fa::audio
