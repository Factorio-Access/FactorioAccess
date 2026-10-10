#include "ui/rich_text.h"
#include <array>

namespace fa::ui {
namespace {
// The tag names of Factorio's rich-text format (wiki "Rich text").
constexpr std::array<std::string_view, 25> kTags = {
    "font", "color", "img", "item", "entity", "technology", "recipe", "item-group", "fluid", "tile", "virtual-signal", "achievement",
    "gps", "special-item", "armor", "train", "train-stop", "tooltip", "space-platform", "planet", "space-location", "quality",
    "shortcut", "tip", "space-age"};

bool is_tag_name(std::string_view n) {
  for (auto t : kTags)
    if (n == t) return true;
  return false;
}
}  // namespace

std::string strip_rich_text(std::string_view s) {
  std::string out;
  out.reserve(s.size());
  for (size_t i = 0; i < s.size();) {
    if (s[i] == '[') {
      size_t close = s.find(']', i);
      if (close != std::string_view::npos) {
        std::string_view inner = s.substr(i + 1, close - i - 1);
        if (!inner.empty() && inner[0] == '/') inner.remove_prefix(1);
        std::string_view name = inner.substr(0, inner.find('='));
        if (is_tag_name(name)) {
          out += ' ';
          i = close + 1;
          continue;
        }
      }
    }
    out += s[i++];
  }
  // Collapse runs of whitespace and trim.
  std::string clean;
  for (char c : out) {
    bool space = c == ' ' || c == '\t' || c == '\n' || c == '\r';
    if (space) {
      if (!clean.empty() && clean.back() != ' ') clean += ' ';
    } else {
      clean += c;
    }
  }
  if (!clean.empty() && clean.back() == ' ') clean.pop_back();
  return clean;
}
}  // namespace fa::ui
