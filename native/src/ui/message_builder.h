#pragma once
#include <string>
#include <string_view>
#include <vector>

namespace fa::ui {

// Fluent message accumulator, ported from soundz <- Tanglebeep <- Factorio Access's MessageBuilder.
// The value it carries is the separation discipline: consecutive fragments are joined with a space,
// list-item boundaries with a comma. A chain of collaborating functions can each append its piece
// without coordinating spacing. Single use: build() may be called once.
//
// Rules (see CLAUDE.md): anything spoken with more than one part goes through this; never hand-build
// ", " in a speech path; composed shapes become push_* helpers in strings.h, not call-site concatenation.
class MessageBuilder {
 public:
  MessageBuilder() = default;
  MessageBuilder(const MessageBuilder&) = delete;
  MessageBuilder& operator=(const MessageBuilder&) = delete;
  MessageBuilder(MessageBuilder&&) = default;
  MessageBuilder& operator=(MessageBuilder&&) = default;

  // Append a text fragment. Separated from preceding content by a space; the first fragment of a
  // fresh list item is preceded by a comma. Empty fragments are ignored so optional pieces can be
  // appended blindly. A lone " " is rejected: spacing is the builder's job.
  MessageBuilder& fragment(std::string_view text);
  // Start a new list item: the next fragment opens it (comma-separated from the previous item).
  MessageBuilder& list_item();
  // Append every fragment of another builder's content as one fragment (used by push_* helpers).
  MessageBuilder& fragment(const MessageBuilder& other) = delete;  // build the other first, then fragment(str)

  bool empty() const { return text_.empty(); }
  // Finish. Throws std::logic_error if called twice.
  std::string build();

 private:
  enum class State { Initial, ListItem, Fragment, FragmentInList, Built };
  void check_not_built() const;
  std::string text_;
  State state_ = State::Initial;
  bool first_list_item_ = true;
};

}  // namespace fa::ui
