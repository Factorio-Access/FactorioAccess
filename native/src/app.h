#pragma once
// The native UI's main-thread side: screens, navigation, and who owns the keyboard. Platform-free.
#include <string>
#include "ui/control_id.h"

namespace fa::app {
void init();
void tick();
// A single player autosave started: click now, and again once the game says it is done (as the launcher did).
void autosave_started();  // once per frame on the main thread, after the frame's input was collected
void shutdown();
// Move focus to a Tab stop of the current screen and announce it (a screen whose content swapped underneath).
void focus_stop(const fa::ui::Key& stop);
std::string dump();
// The current screen changed the focused control's state itself: speak it now (see GraphNavigator::announce_change).
void announce_change(std::string_view text);  // the navigator's current graph and focus, for the dev server
}  // namespace fa::app
