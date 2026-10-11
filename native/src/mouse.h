#pragma once
// The real mouse pointer, which the mod keeps on its cursor so the game's own clicks land where the player is.
namespace fa::mouse {
// Move the pointer to a pixel of the game window's client area. Does nothing while the game window is not the
// foreground window (the player's mouse belongs to whatever they are using) or in the dev loop (FA_NOFOCUS).
void move_to_client(int x, int y);
}  // namespace fa::mouse
