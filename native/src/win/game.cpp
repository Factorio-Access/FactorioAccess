#include "game.h"
#include <cstddef>
#include "log.h"
#include "sym.h"

namespace fa::game {
static void* g_global_var;  // GlobalContext* global
static size_t g_app_manager;  // GlobalContext::appManager (UniquePointer<AppManager>, one pointer)
using IsInGame_t = bool (*)(const void*);
static IsInGame_t g_is_in_game;
static IsInGame_t g_is_saving;  // AppManager::isSavingMap, same shape; optional

bool init() {
  g_global_var = sym::addr("global");
  auto off = sym::offset("GlobalContext", "appManager");
  g_is_in_game = sym::fn<IsInGame_t>("AppManager::isInGame");
  if (!g_global_var || !off || !g_is_in_game) {
    log::write("game: could not resolve AppManager");
    return false;
  }
  g_app_manager = *off;
  g_is_saving = sym::fn<IsInGame_t>("AppManager::isSavingMap");
  return true;
}

static void* app_manager() {
  void* global = *reinterpret_cast<void**>(g_global_var);
  return global ? *reinterpret_cast<void**>(reinterpret_cast<char*>(global) + g_app_manager) : nullptr;
}

bool saving() {
  void* app = app_manager();
  return app && g_is_saving && g_is_saving(app);
}

bool in_game() {
  void* global = *reinterpret_cast<void**>(g_global_var);
  if (!global) return false;
  void* app = *reinterpret_cast<void**>(reinterpret_cast<char*>(global) + g_app_manager);
  return app && g_is_in_game(app);
}
}  // namespace fa::game
