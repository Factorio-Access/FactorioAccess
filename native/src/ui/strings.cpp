#include "ui/strings.h"
#include <format>

namespace fa::strings {
using fa::ui::MessageBuilder;

MessageBuilder& push_position(MessageBuilder& m, int index1, int count) {
  m.list_item().fragment(std::format("{} of {}", index1, count));
  return m;
}

MessageBuilder& push_control(MessageBuilder& m, std::string_view label, std::string_view role, bool selected, bool disabled) {
  m.list_item().fragment(label);
  if (!role.empty()) m.list_item().fragment(role);
  if (selected) m.list_item().fragment(kSelected);
  if (disabled) m.list_item().fragment(kDisabled);
  return m;
}
}  // namespace fa::strings
