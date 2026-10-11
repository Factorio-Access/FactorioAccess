#pragma once
// Symbol lookup against the game's own debug symbols (on Windows: factorio.pdb, which ships next to the exe).
// Names are undecorated C++ names ("LuaHelper::initLuaState", "lua_pcallk", "global").
#include <cstddef>
#include <optional>
#include <string>
#include <vector>

namespace fa::sym {
bool init();
void shutdown();
// Address of a function or variable, or null when the name does not resolve (logged).
void* addr(const char* name);
template <typename T>
T fn(const char* name) { return reinterpret_cast<T>(addr(name)); }
// Byte offset of a data member ("agui::Widget", "children"), or nullopt (logged). Searches base classes too.
std::optional<std::size_t> offset(const char* type, const char* member);
// sizeof(type), or nullopt (logged).
std::optional<std::size_t> type_size(const char* type);
// Byte offset of a virtual method's slot in the vtable ("agui::Widget", "getText"), or nullopt (logged).
// Overloads share a name: this returns the first one declared, so use it only on unambiguous methods.
std::optional<std::size_t> vtable_offset(const char* type, const char* method);
// The call stack of another thread (`thread` is the platform's thread handle; it is paused for a moment), innermost first:
// "name+0xoffset" for the game's own code, "module+0xoffset" elsewhere.
std::vector<std::string> thread_stack(void* thread);
}  // namespace fa::sym
