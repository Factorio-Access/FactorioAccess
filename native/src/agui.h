#pragma once
// Read access to the game's widget tree (agui, Factorio's retained-mode GUI library). Widget pointers are
// valid only within the main-thread frame they were read in: never hold one across frames.
#include <string>
#include <vector>

namespace fa::agui {
struct Widget;  // opaque game object

struct Rect {
  int x = 0, y = 0, w = 0, h = 0;
};

bool init();  // resolves layouts; false (logged) when the game build does not match what we read

Widget* root();     // the GUI's top container, or null before the GUI exists
Widget* focused();  // the widget holding agui keyboard focus, or null
std::vector<Widget*> children(Widget* w);          // public children, in order
std::vector<Widget*> private_children(Widget* w);  // implementation parts (a scroll pane's flow, a dropdown's list)
Widget* parent(Widget* w);
std::string class_name(Widget* w);  // dynamic type, e.g. "agui::TextButton"
std::string text(Widget* w);        // the widget's own text (captions are already localised), UTF-8
bool visible(Widget* w);
bool enabled(Widget* w);
Rect rect(Widget* w);  // absolute, in window pixels
}  // namespace fa::agui
