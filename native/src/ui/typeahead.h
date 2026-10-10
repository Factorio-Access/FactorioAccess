#pragma once
#include <cstdint>
#include <functional>
#include <string>
#include <string_view>
#include <vector>

namespace fa::ui {

/// The two text helpers the search needs, ported from wotr-access src/TextUtil.cs.
///
/// DEVIATION, deliberate: the C# ran full Unicode NFD normalization and dropped every NonSpacingMark,
/// which needs an ICU-sized table. The engine-free core must stay dependency-free, so this handles the
/// range that actually occurs in game text -- ASCII, Latin-1 Supplement, Latin Extended-A, and loose
/// combining marks U+0300..U+036F -- and passes anything else through unchanged. Same for case folding:
/// ASCII plus those Latin ranges, not the full Unicode simple-case table.
namespace text_util {
/// Fold accents to their base letters (and the two ligatures the C# special-cased: oe, ae). UTF-8 in,
/// UTF-8 out.
std::string remove_diacritics(std::string_view text);
/// Lowercase (C#: ToLowerInvariant) over the ranges described above. UTF-8 in, UTF-8 out.
std::string to_lower_invariant(std::string_view text);
}  // namespace text_util

/// Type-ahead search engine -- ported, with permission, from OniAccess (VisionNotIncluded,
/// Handlers/TypeAheadSearch.cs) via wotr-access; adapted so that speech and key routing live in the
/// navigator, which feeds typed characters and arrows in; this class is pure matching/result state.
///
/// Builds a filtered results list over a flat item list with TIERED matching: start-of-string whole
/// word, start-of-string prefix, mid-string whole word, mid-string word prefix, substring anywhere,
/// then space-delimited word-prefix abbreviation ("ga pi" matches "gas pipe"). Within a tier, items keep
/// their LIST ORDER (the screen's element order -- a change from OniAccess's shortest-name ranking: "l"
/// must land on Load Game by menu position, not License by length), and matches in the item's NAME
/// (before the first comma) rank ahead of matches in its appended metadata. Diacritics are ignored.
/// Typing the same letter repeatedly cycles ALL of that letter's matches in list order (starts-with
/// first, then the weaker tiers -- so "l" reaches Load Game, License, then DLC).
class TypeAheadSearch {
 public:
  TypeAheadSearch();

  std::string buffer() const { return buffer_; }
  bool has_buffer() const { return !buffer_.empty(); }
  bool is_search_active() const { return is_search_active_; }
  int result_count() const { return static_cast<int>(result_indices_.size()); }

  /// Spoken when the buffer matches nothing (gets the buffer text).
  std::function<void(const std::string&)> on_no_match;

  void add_char(char c) { buffer_.push_back(c); }
  /// Append one Unicode code point (UTF-8 encoded into the buffer): what the navigator types, so a non-ASCII
  /// letter ("é") searches as itself, not as '?'.
  void add_codepoint(std::uint32_t cp);
  /// Remove the last CODE POINT (a whole UTF-8 sequence, never half of one).
  bool remove_char();
  void clear();

  /// Run the tiered search over the items and move/announce the best result. `name_by_index` supplies
  /// each item's searchable text; `announce_result` is called with the ORIGINAL item index.
  void search(int item_count, const std::function<std::string(int)>& name_by_index,
              std::function<void(int)> announce_result);

  /// Step within the filtered results (wrapping). +1 next, -1 previous.
  void navigate_results(int direction);
  void jump_to_first_result();
  void jump_to_last_result();

  /// Match tier for a prefix against a name (both lowercase), or -1. 0 = start whole word, 1 = start
  /// prefix, 2 = mid whole word, 3 = mid word prefix, 4 = substring anywhere, 5 = space-delimited
  /// word-prefix abbreviation ("ga pi" in "gas pipe"). `position` receives the match offset within the
  /// diacritics-folded name, or -1.
  static int match_tier(std::string_view lower_name, std::string_view lower_prefix, int& position);

 private:
  void announce_current_result();

  static constexpr int kTierCount = 6;

  std::string buffer_;
  bool is_search_active_ = false;
  std::vector<int> result_indices_;
  std::vector<std::string> result_names_;
  std::size_t result_cursor_ = 0;

  // Working lists for search, one set per match tier (the C# kept these to avoid allocation; the
  // reserve/clear discipline is preserved).
  std::vector<int> tier_indices_[kTierCount];
  std::vector<std::string> tier_names_[kTierCount];
  std::vector<int> tier_positions_[kTierCount];
  std::vector<int> tier_sort_lengths_[kTierCount];
  std::vector<int> tier_in_segment_[kTierCount];
  std::vector<int> work_indices_;
  std::vector<std::string> work_names_;

  // Announce-and-move callback (called with the ORIGINAL item index).
  std::function<void(int)> announce_result_;
};

}  // namespace fa::ui
