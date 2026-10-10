#pragma once
namespace fa::audio_session {
// Mute or unmute everything this process plays (the game's sound and the native audio engine). Windows remembers
// a per-application mute across runs, so callers apply the wanted state both ways on every load.
bool set_muted(bool mute);
}  // namespace fa::audio_session
