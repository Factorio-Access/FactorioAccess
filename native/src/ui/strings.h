#pragma once
// Words the native UI speaks that do not come from the game. Keep this short: a label the game already has
// (a widget's caption, a locale key the engine can resolve) always wins over a word added here.
#include <string_view>
#include "ui/message_builder.h"

namespace fa::strings {
inline constexpr std::string_view kButton = "button";
inline constexpr std::string_view kCheckbox = "checkbox";
inline constexpr std::string_view kDropdown = "dropdown";
inline constexpr std::string_view kTab = "tab";
inline constexpr std::string_view kTextField = "text field";
inline constexpr std::string_view kSlider = "slider";
inline constexpr std::string_view kChecked = "checked";
inline constexpr std::string_view kUnchecked = "unchecked";
inline constexpr std::string_view kSelected = "selected";
inline constexpr std::string_view kDisabled = "disabled";
inline constexpr std::string_view kNoTooltip = "no tooltip";
inline constexpr std::string_view kNothingToCompare = "nothing to compare";
inline constexpr std::string_view kNoDetails = "no details";
inline constexpr std::string_view kNoMatch = "no match for";
inline constexpr std::string_view kSearchCleared = "search cleared";
inline constexpr std::string_view kEditing = "editing, enter or escape to finish";
inline constexpr std::string_view kTypeValue = "type a value, enter to set";
inline constexpr std::string_view kCancelled = "cancelled";
inline constexpr std::string_view kBlank = "blank";

// "<i> of <n>" as a list item
fa::ui::MessageBuilder& push_position(fa::ui::MessageBuilder& m, int index1, int count);
// "<label>, <role>[, selected][, disabled]" as list items
fa::ui::MessageBuilder& push_control(fa::ui::MessageBuilder& m, std::string_view label, std::string_view role, bool selected, bool disabled);
}  // namespace fa::strings
