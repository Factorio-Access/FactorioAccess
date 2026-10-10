#pragma once
// Keyboard state for the native UI. Keys are SDL scancodes (the game's own key identity on every platform).
// The platform layer feeds events in; the main-thread tick reads them through key_source().
#include <cstdint>
#include <string>
#include "ui/input.h"

namespace fa::input {
namespace sc {  // SDL scancodes used by the native UI
constexpr int A = 4, Z = 29, Num1 = 30, Num0 = 39, Enter = 40, Escape = 41, Backspace = 42, Tab = 43, Space = 44;
constexpr int Slash = 56, F1 = 58, Home = 74, PageUp = 75, End = 77, PageDown = 78, Right = 79, Left = 80, Down = 81, Up = 82;
constexpr int LCtrl = 224, LShift = 225, LAlt = 226, RCtrl = 228, RShift = 229, RAlt = 230;
}  // namespace sc

struct KeyEvent {
  int scancode = 0;
  bool down = true;  // false = release
  bool repeat = false;
  bool shift = false, ctrl = false, alt = false;
};

// Whether the native UI takes the keyboard. Set by the main-thread tick; read by the platform layer when it
// decides to swallow a key event (the game then never sees it).
void set_owned(bool owned);
bool owned();

// Platform layer -> here (any thread).
void record_key(const KeyEvent& e);
void record_text(std::u32string_view text);

// Main thread, once per frame: move the recorded events into the frame state the UI reads, then clear it after.
void begin_frame();
void end_frame();
const fa::ui::KeySource& key_source();
std::u16string_view typed_chars();  // printable characters typed this frame
}  // namespace fa::input
