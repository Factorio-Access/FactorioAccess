#pragma once
#include <format>
#include <string>
#include <string_view>
#include "ring.h"

namespace fa::log {
void init();  // %LOCALAPPDATA%\FactorioAccess\native.log, truncated per load
void write(std::string_view line);
template <typename... A>
void writef(std::format_string<A...> fmt, A&&... a) { write(std::format(fmt, std::forward<A>(a)...)); }
std::wstring path();
LineRing& ring();  // recent lines, for the dev server
}  // namespace fa::log
