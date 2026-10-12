#pragma once
// The system clipboard, for the mod's copy commands (blueprint strings, prototype names) in single player; the
// launcher does it in multiplayer.
#include <string_view>

namespace fa::clipboard {
void start();  // the worker thread and its window (from init)
// Put UTF-8 text on the clipboard as Unicode text, "\n" becoming "\r\n". From any thread, never blocks: a worker
// owns the clipboard, because taking it sends WM_DESTROYCLIPBOARD to the previous owner, which may be the game's
// window, whose thread waits for the update thread that scripts run on.
void set_text(std::string_view utf8);
void shutdown();  // stops the worker (fa_unload, never DllMain)
}  // namespace fa::clipboard
