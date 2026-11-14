// Small macOS services behind platform-free headers: the clipboard (clipboard.h) and the mouse pointer (mouse.h).
// Both are asked for from the game's update thread and done on the main thread, which pumps the main queue as the
// game drains its events.
#include <dispatch/dispatch.h>
#import <AppKit/AppKit.h>
#include <string>
#include "clipboard.h"
#include "log.h"
#include "mouse.h"
#include "sym.h"

namespace fa::clipboard {
void start() {}
void shutdown() {}

void set_text(std::string_view utf8) {
  std::string text(utf8);
  dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool {
      NSString* s = [NSString stringWithUTF8String:text.c_str()];
      if (!s) {
        log::write("clipboard: text is not UTF-8");
        return;
      }
      NSPasteboard* pb = [NSPasteboard generalPasteboard];
      [pb clearContents];
      if (![pb setString:s forType:NSPasteboardTypeString]) log::write("clipboard: the pasteboard refused the text");
    }
  });
}
}  // namespace fa::clipboard

namespace fa::mouse {
namespace {
// The game's own SDL3 (statically linked). Warping through SDL, not CoreGraphics, also tells the game the pointer
// moved: CGWarpMouseCursorPosition alone posts no event.
using GetKeyboardFocus_t = void* (*)();
using Warp_t = void (*)(void* window, float x, float y);
using PixelDensity_t = float (*)(void* window);
GetKeyboardFocus_t g_focus;
Warp_t g_warp;
PixelDensity_t g_density;
bool g_resolved = false;
}  // namespace

// x, y are pixels of the game's drawable; SDL wants window coordinates, which are points on a Retina display.
void move_to_client(int x, int y) {
  if (std::getenv("FA_NOFOCUS")) return;  // the dev loop: never move the developer's mouse
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!g_resolved) {
      g_resolved = true;
      g_focus = sym::fn<GetKeyboardFocus_t>("SDL_GetKeyboardFocus");
      g_warp = sym::fn<Warp_t>("SDL_WarpMouseInWindow");
      g_density = sym::fn<PixelDensity_t>("SDL_GetWindowPixelDensity");
    }
    if (!g_focus || !g_warp || !g_density) return;
    // Only while the game has the keyboard: otherwise the player's mouse belongs to whatever they are using.
    void* w = g_focus();
    if (!w || !NSApp.active) return;
    float d = g_density(w);
    if (d <= 0) d = 1;
    g_warp(w, x / d, y / d);
  });
}
}  // namespace fa::mouse
