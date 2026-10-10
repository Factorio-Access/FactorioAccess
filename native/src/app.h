#pragma once
// The native UI's main-thread side: screens, navigation, and who owns the keyboard. Platform-free.
#include <string>
#include "ui/control_id.h"

namespace fa::app {
void init();
void tick();  // once per frame on the main thread, after the frame's input was collected
void shutdown();
// Move focus to a Tab stop of the current screen and announce it (a screen whose content swapped underneath).
void focus_stop(const fa::ui::Key& stop);
std::string dump();  // the navigator's current graph and focus, for the dev server
}  // namespace fa::app
