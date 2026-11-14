#pragma once
// The game's main executable as loaded: where it is, and its own symbol table (the Mac build ships it unstripped,
// but without type information, so field offsets come from mac/layout.cpp instead).
#include <cstdint>
#include <string>
#include <string_view>
#include <vector>

namespace fa::mac::image {
bool init();  // finds the executable and indexes its symbols; false (logged) when it cannot
uintptr_t slide();
bool in_text(uintptr_t addr);  // inside the executable's __TEXT segment (its code and constants)
// Every symbol whose name starts with `prefix`. Names lose the `_` Mach-O adds: "lua_gettop", "_ZN4agui6Widget...".
std::vector<std::pair<std::string_view, uintptr_t>> with_prefix(std::string_view prefix);
// The exact symbol, or 0.
uintptr_t exact(std::string_view mangled);
// The nearest symbol at or below addr, for stack traces: its mangled name and the offset into it.
std::pair<std::string_view, uintptr_t> nearest(uintptr_t addr);
std::string demangle(std::string_view mangled);
// The Itanium mangling of a qualified C++ name ("agui::Widget" -> "N4agui6WidgetE", "MainLoop" -> "8MainLoop").
std::string mangle_type(std::string_view qualified);
}  // namespace fa::mac::image
