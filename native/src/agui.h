#pragma once
// Read access to the game's widget tree (agui, Factorio's retained-mode GUI library). Widget pointers are
// valid only within the main-thread frame they were read in: never hold one across frames.
#include <optional>
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
std::string class_name(Widget* w);                 // dynamic type, e.g. "agui::TextButton"
bool is_a(Widget* w, std::string_view qualified);  // the dynamic type is or derives from `qualified` ("agui::Button")
std::string text(Widget* w);  // the widget's own text (captions are already localised, rich-text markup included), UTF-8
bool visible(Widget* w);
bool enabled(Widget* w);
bool toggled(Widget* w);  // agui::Button state: a toggle button's pressed. Only for agui::Button.
bool checked(Widget* w);  // agui::ToggleButton state (checkboxes, radio buttons). Only for toggle buttons.
// Flip a checkbox / pick a radio button as a click would (agui::ToggleButton::mouseClick: the state changes and
// the game's check listeners run). Only for toggle buttons.
void toggle(Widget* w);
// The style the widget was built with ("back_button", "confirm_button"), from its style chain; empty if none.
std::string style_name(Widget* w);
// The widget's tooltip text (localised, may carry rich-text markup); empty if none.
std::string tooltip(Widget* w);
Rect rect(Widget* w);  // absolute, in window pixels
// A left click on the widget's click listeners (agui::Widget::dispatchClick): the game's handlers run as for a
// mouse click, without moving the mouse or needing the widget on screen. Widget-internal click behaviour
// (a checkbox flipping its own state) is not part of this.
void click(Widget* w);
// Give the widget agui keyboard focus (a text field then receives the game's key events).
void focus(Widget* w);
// agui::DropDown: item count, selected index, and a selection change as if the user picked it (the game's
// item-select listeners run). Only for dropdowns.
int dropdown_count(Widget* w);
int dropdown_selected(Widget* w);
void dropdown_select(Widget* w, int index);
// For a row of an agui::ListBox: whether it is the list's selected row. nullopt when `w` is not a list row.
std::optional<bool> list_row_selected(Widget* w);
// Close any open dropdown list (the popup the game adds over everything); false when none was open.
bool close_dropdown_popup();
// Whether `w` is currently in the tree under root() (guards dev routes taking raw addresses).
bool in_tree(Widget* w);
}  // namespace fa::agui
