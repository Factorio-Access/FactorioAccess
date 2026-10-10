#pragma once
// Files from the FactorioAccess mod's own package (its folder, or the zip players install), located by the
// engine itself: the package path comes from the mod's LuaGameScript setup.
#include <cstdint>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace fa::assets {
bool init();  // resolves the engine's inflate (zip packages)
// The platform layer reports where the mod's package is (a directory or a .zip), once per game load.
void set_package(const std::wstring& path);
// Bytes of `name` relative to the mod root ("audio/menu-open.ogg"; '/' or '\\'), or nullopt.
std::optional<std::vector<std::uint8_t>> read(std::string_view name);
}  // namespace fa::assets
