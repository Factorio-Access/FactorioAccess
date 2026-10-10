#pragma once
// The platform layer: everything that patches the game process lives behind this interface.
#include <cstdint>
#include <functional>
#include <string_view>

namespace fa::hooks {
bool install();
void remove();
// Frames seen by the main-loop hook (main thread, menus and game alike).
uint64_t frame();
// Run fn on the main thread at the start of the next frame. Blocks until it ran; false on timeout (the job
// still runs later, so it must own everything it touches).
bool run_on_main_thread(std::function<void()> fn, unsigned timeout_ms = 5000);
// Synthetic input for the dev loop, delivered as real SDL events: the game converts them itself and they take
// exactly the path of physical keys (including being swallowed while the native UI owns the keyboard).
bool push_key(int scancode, bool down, bool shift = false, bool ctrl = false, bool alt = false);
bool push_text(std::string_view utf8);
}  // namespace fa::hooks
