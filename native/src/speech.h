#pragma once
#include <string_view>
#include "ring.h"

namespace fa::speech {
bool init();  // loads prism.dll from next to fa_native.dll and picks the best backend
void shutdown();
void speak(std::string_view utf8, bool interrupt = true);  // callable from any thread
void stop();
const char* backend_name();
void set_muted(bool m);  // muted: nothing reaches the backend, history still records (the dev loop runs muted)
bool muted();
LineRing& history();  // every line passed to speak(), for the dev server
}  // namespace fa::speech
