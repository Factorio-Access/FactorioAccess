#pragma once
// Where the application is (menus, loading, in a world), from the game's own AppManager. Main thread.
namespace fa::game {
bool init();
bool in_game();  // a world is loaded and running (the player is playing, possibly with a game GUI open)
bool saving();   // a save is in progress (AppManager::isSavingMap); false when the game build lacks it
}  // namespace fa::game
