#pragma once
// Hooks for fa_audio_tests: the whole pipeline on miniaudio's null backend, which keeps real time but makes no sound.
#include <cstddef>
#include <cstdint>
#include "audio/audio.h"

namespace fa::audio::testing {
bool init_null_device(AssetLoader loader);  // init() on the null backend; shutdown() as usual
std::size_t live_sounds();  // sounds the worker tracked after its last tick
std::uint64_t ticks();  // worker ticks so far; a tick runs after every batch of commands
}  // namespace fa::audio::testing
