#pragma once
#include <memory>
#include "ui/screen.h"

namespace fa::screens {
// The menus (everything before a world is loaded), read generically from the game's widget tree: every visible
// dialog is a Tab stop, its flows become rows, and its controls become our own nodes whose labels, state and
// activation come from the game's widgets. Specific screens can replace this where the generic reading falls
// short.
std::unique_ptr<fa::ui::Screen> make_dialogs();
// The main menu itself (no other dialog over it) is the top dialog, as of the dialogs screen's last update. Only
// meaningful while that screen is current.
bool on_main_menu();
}  // namespace fa::screens
