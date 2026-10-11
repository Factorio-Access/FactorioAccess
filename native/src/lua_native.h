#pragma once
// The `_fa_native` global: the native code's surface to the FactorioAccess mod's own Lua state (control stage).
// No other mod's state gets it. Functions run on whatever thread runs that mod's Lua (the game's update thread).
//
//   _fa_native.api_version            integer, bumped when a function's contract changes
//   _fa_native.speak(ls [, interrupt]) speak a LocalisedString, localised by the engine on the spot
//                                      (interrupt defaults to true)
//   _fa_native.audio_cmd(json)         one audio command, the launcher's JSON format (scripts/launcher-audio.lua)
#include <cstdint>
#include <string_view>

namespace fa::lua {
bool init();  // resolves the Lua C API and the engine's localisation functions
// A Lua state was just set up for `mod` (the platform layer calls this from the engine's own state setup,
// before the mod's control.lua runs).
void on_state_created(void* lua_state, std::string_view mod);
uint64_t audio_commands();
// From any thread: have the mod's Lua log a traceback of where it is the next time it runs a few instructions (a Lua
// count hook, which lua_sethook allows to be set asynchronously). For the watchdog.
void request_traceback();
// The thread the mod's Lua last called into the native code from (the game's update thread), or 0.
unsigned long script_thread_id();  // audio commands the mod has sent this session (dev server)
}  // namespace fa::lua
