#include "ui/message_builder.h"
#include <stdexcept>

namespace fa::ui {

void MessageBuilder::check_not_built() const {
  if (state_ == State::Built) throw std::logic_error("MessageBuilder used after build()");
}

MessageBuilder& MessageBuilder::fragment(std::string_view text) {
  check_not_built();
  if (text == " ") throw std::invalid_argument("fragment(\" \") is unnecessary: spaces are added between fragments automatically");
  if (text.empty()) return *this;
  if (state_ == State::ListItem) {
    if (!first_list_item_) text_ += ',';
    first_list_item_ = false;
  }
  state_ = (state_ == State::ListItem || state_ == State::FragmentInList) ? State::FragmentInList : State::Fragment;
  if (!text_.empty()) text_ += ' ';
  text_.append(text);
  return *this;
}

MessageBuilder& MessageBuilder::list_item() {
  check_not_built();
  state_ = State::ListItem;
  return *this;
}

std::string MessageBuilder::build() {
  check_not_built();
  state_ = State::Built;
  return std::move(text_);
}

}  // namespace fa::ui
