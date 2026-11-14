// The Mac entry point. The library is loaded into the game with DYLD_INSERT_LIBRARIES (tools/mac/launch.sh sets it), and
// its initializer runs before the game's main(), on the main thread, so every hook is in place before the game's
// first frame. So far: the main menus (app.cpp, screens/dialogs.cpp), keyboard input, speech, the Lua bridge (`_fa_native`: speech, sounds, clipboard, pointer), the update check, the
// watchdog, the dev server (FA_PORT) and the startup report of what was resolved.
#include <chrono>
#include <cstdlib>
#include <format>
#include <string>
#include <vector>
#include "agui.h"
#include "app.h"
#include "assets.h"
#include "devserver.h"
#include "game.h"
#include "audio/audio.h"
#include "clipboard.h"
#include "hooks.h"
#include "lua_native.h"
#include "speech.h"
#include "update_check.h"
#include "watchdog.h"
#include "log.h"
#include "sym.h"

namespace {
// Everything the Windows layer resolves by name, so the log shows at once what this build of the game lacks.
void report() {
  const char* functions[] = {
      "global", "luaD_throw", "MainLoop::mainLoopStep", "SDLWindow::pollEvent", "LuaGameScript::LuaGameScript", "LuaHelper::initLuaState",
      "SDL_GetModState", "SDL_PushEvent", "SDL_GetWindowID", "SDL_GetKeyFromScancode", "AppManager::isInGame", "AppManager::isSavingMap",
      "agui::Widget::dispatchClick", "agui::Widget::getAbsoluteRectangle", "agui::DropDown::getItemCount", "agui::DropDown::getSelectedIndex",
      "agui::DropDown::editSelectedIndex", "agui::DropDown::isDropDownShowing", "agui::DropDown::hideDropDown", "agui::ListBox::getSelectedIndex",
      "agui::Tab::isSelectedTab", "agui::Slider::setValue", "agui::ListBox::getIndexOfWidget", "agui::TableWithSelection::editSelectedIndex",
      "agui::Gui::getFocusedWidget", "lua_createtable", "lua_pushcclosure", "lua_pushinteger", "lua_setfield", "lua_setglobal", "lua_gettop",
      "lua_toboolean", "luaL_checklstring", "luaL_checkinteger", "lua_sethook", "luaL_traceback", "lua_tolstring", "lua_settop",
      "lua_pushlstring", "LuaHelper::parseLocalisedString", "LocalisedString::str", "LocalisedString::~LocalisedString",
      "GlobalContext::getActiveLocaleProvider", "inflateInit2_", "inflate"};
  int missing = 0;
  for (const char* f : functions)
    if (void* a = fa::sym::addr(f)) fa::log::writef("  fn {} = {}", f, a);
    else ++missing;
  struct Field {
    const char *type, *member;
    std::size_t expect;  // read by hand off the 2.1.24 build; a mismatch means a recipe misread this build
  };
  const Field fields[] = {
      {"GlobalContext", "gui", 0x60},
      {"GlobalContext", "appManager", 0x168},
      {"agui::Gui", "baseWidget", 0x70},
      {"agui::Widget", "parentWidget", 0x50},
      {"agui::Widget", "children", 0x58},
      {"agui::Widget", "privateChildren", 0x70},
      {"agui::Widget", "usageBitMask", 0x88},
      {"agui::Widget", "toolTipCreator", 0x30},
      {"agui::Button", "toggled", 0xdd},
      {"agui::ToggleButton", "checkedState", 0x124},
      {"agui::Style", "tooltip", 0x60},
      {"agui::Style", "parent", 0x8},
      {"agui::Style", "styleInfo", 0x18},
      {"agui::StyleInfo", "name", 0x0},
      {"agui::PlainToolTipCreator", "title", 0x8},
      {"agui::PlainToolTipCreator", "text", 0x20},
      {"agui::Table", "columnCount", 0x284},
      {"agui::Table", "hasHeaders", 0x281},
      {"agui::TableWithSelection", "selectedIndex", 0x288},
      {"agui::Slider", "value", 0x398},
      {"agui::Slider", "valueStep", 0x3b0},
      {"agui::Slider", "min", 0x3a0},
      {"agui::Slider", "max", 0x3a8},
      {"agui::Slider", "notchTooltips", 0x180},
      {"agui::MouseEvent", "position", 0x0},
      {"agui::MouseEvent", "button", 0xc},
      {"agui::MouseEvent", "eventType", 0x10},
      {"agui::MouseEvent", "source", 0x28},
      {"agui::MouseEvent", "previous", 0x30},
      {"Mod", "package", 0x0},
      {"Package", "packagePath_", 0x40},
  };
  int mismatched = 0;
  for (auto& f : fields) {
    auto o = fa::sym::offset(f.type, f.member);
    if (!o) {
      ++missing;
      continue;
    }
    bool same = *o == f.expect;
    mismatched += !same;
    fa::log::writef("  field {}::{} = {:#x}{}", f.type, f.member, *o, same ? "" : std::format(" (MISMATCH: expected {:#x})", f.expect));
  }
  for (const char* t : {"LocalisedString", "z_stream_s"})
    if (auto sz = fa::sym::type_size(t)) fa::log::writef("  sizeof {} = {:#x}", t, *sz);
    else ++missing;
  const Field virtuals[] = {{"agui::Widget", "mouseClick", 0}, {"agui::Widget", "getText", 0}, {"agui::Widget", "focus", 0}, {"agui::Widget", "getStyle", 0}};
  for (auto& v : virtuals)
    if (auto o = fa::sym::vtable_offset(v.type, v.member)) fa::log::writef("  virtual {}::{} = slot {:#x}", v.type, v.member, *o);
    else ++missing;
  fa::log::writef("fa_native: {} names unresolved, {} fields differ from 2.1.24", missing, mismatched);
}
bool env_flag(const char* name) {
  const char* v = std::getenv(name);
  return v && v[0] == '1';
}
}  // namespace

__attribute__((constructor)) static void fa_init() {
  fa::log::init();
  fa::log::write("fa_native: loaded (macOS)");
  fa::speech::set_muted(env_flag("FA_MUTE"));
  bool sp = fa::speech::init();
  if (!fa::sym::init()) {
    fa::speech::speak("Factorio Access native code could not read the game's symbols and is disabled", true);
    return;
  }
  report();
  if (!fa::agui::init() || !fa::game::init() || !fa::lua::init() || !fa::assets::init()) {
    fa::speech::speak("Factorio Access native code does not support this game version and is disabled", true);
    return;
  }
  if (!fa::hooks::install()) {
    fa::log::write("fa_native: hook install failed; removing what attached");
    fa::hooks::remove();
    fa::speech::speak("Factorio Access native code does not support this game version and is disabled", true);
    return;
  }
  fa::audio::set_log([](std::string_view line) { fa::log::writef("audio: {}", line); });
  // Sound names are relative to the mod's audio/ folder, as the launcher resolved them.
  if (!fa::audio::init([](std::string_view name) { return fa::assets::read("audio/" + std::string(name)); }))
    fa::log::write("fa_native: audio unavailable");
  fa::clipboard::start();
  fa::app::init();
  fa::hooks::set_frame_callback(fa::app::tick);
  if (const char* port = std::getenv("FA_PORT")) fa::dev::start(std::atoi(port));
  fa::watchdog::start();
  fa::update::start();  // asks GitHub for a newer build; spoken on the main menu when there is one
  fa::log::writef("fa_native: ready, speech {}", sp ? fa::speech::backend_name() : "unavailable");
}
