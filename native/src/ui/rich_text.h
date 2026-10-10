#pragma once
// Factorio rich text ("[font=default-bold]Continue[/font] [img=restart_required]") to plain speech text.
#include <string>
#include <string_view>

namespace fa::ui {
// Drops every [tag], [tag=value] and [/tag] whose tag name is a known rich-text tag, collapses the whitespace
// left behind, and trims. Brackets that are not rich-text tags ("[3]") are kept.
std::string strip_rich_text(std::string_view s);
}  // namespace fa::ui
