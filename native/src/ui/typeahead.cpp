#include "ui/typeahead.h"

#include <cstdint>
#include <utility>

namespace fa::ui {
namespace {

// ---- minimal UTF-8 codec (the core may not depend on ICU or the Windows NLS APIs) ----

// Decodes the code point starting at `i`, advancing `i`. Invalid bytes decode as themselves so text is
// never corrupted, only left unfolded.
std::uint32_t next_codepoint(std::string_view s, std::size_t& i) {
  const auto b0 = static_cast<unsigned char>(s[i]);
  auto cont = [&s](std::size_t k) {
    return k < s.size() && (static_cast<unsigned char>(s[k]) & 0xC0) == 0x80;
  };
  if (b0 < 0x80) {
    i += 1;
    return b0;
  }
  if ((b0 & 0xE0) == 0xC0 && cont(i + 1)) {
    const std::uint32_t cp = ((b0 & 0x1Fu) << 6) | (static_cast<unsigned char>(s[i + 1]) & 0x3Fu);
    i += 2;
    return cp;
  }
  if ((b0 & 0xF0) == 0xE0 && cont(i + 1) && cont(i + 2)) {
    const std::uint32_t cp = ((b0 & 0x0Fu) << 12) | ((static_cast<unsigned char>(s[i + 1]) & 0x3Fu) << 6) |
                             (static_cast<unsigned char>(s[i + 2]) & 0x3Fu);
    i += 3;
    return cp;
  }
  if ((b0 & 0xF8) == 0xF0 && cont(i + 1) && cont(i + 2) && cont(i + 3)) {
    const std::uint32_t cp = ((b0 & 0x07u) << 18) | ((static_cast<unsigned char>(s[i + 1]) & 0x3Fu) << 12) |
                             ((static_cast<unsigned char>(s[i + 2]) & 0x3Fu) << 6) |
                             (static_cast<unsigned char>(s[i + 3]) & 0x3Fu);
    i += 4;
    return cp;
  }
  i += 1;
  return b0;
}

void append_codepoint(std::string& out, std::uint32_t cp) {
  if (cp < 0x80) {
    out.push_back(static_cast<char>(cp));
  } else if (cp < 0x800) {
    out.push_back(static_cast<char>(0xC0 | (cp >> 6)));
    out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
  } else if (cp < 0x10000) {
    out.push_back(static_cast<char>(0xE0 | (cp >> 12)));
    out.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
    out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
  } else {
    out.push_back(static_cast<char>(0xF0 | (cp >> 18)));
    out.push_back(static_cast<char>(0x80 | ((cp >> 12) & 0x3F)));
    out.push_back(static_cast<char>(0x80 | ((cp >> 6) & 0x3F)));
    out.push_back(static_cast<char>(0x80 | (cp & 0x3F)));
  }
}

// The ASCII folding of one code point, or null to pass it through unchanged. Entries are exactly the
// characters NFD decomposes into base + NonSpacingMark (which the C# then dropped), plus the two
// ligatures it special-cased. Characters NFD leaves alone (D-stroke, thorn, eszett, l-stroke, ...) pass
// through here too, as they did there.
const char* ascii_fold(std::uint32_t cp) {
  switch (cp) {
    // Latin-1 Supplement.
    case 0xC0: case 0xC1: case 0xC2: case 0xC3: case 0xC4: case 0xC5: return "A";
    case 0xC6: return "ae";  // the C# folded both cases of the ligature to lowercase
    case 0xC7: return "C";
    case 0xC8: case 0xC9: case 0xCA: case 0xCB: return "E";
    case 0xCC: case 0xCD: case 0xCE: case 0xCF: return "I";
    case 0xD1: return "N";
    case 0xD2: case 0xD3: case 0xD4: case 0xD5: case 0xD6: return "O";
    case 0xD9: case 0xDA: case 0xDB: case 0xDC: return "U";
    case 0xDD: return "Y";
    case 0xE0: case 0xE1: case 0xE2: case 0xE3: case 0xE4: case 0xE5: return "a";
    case 0xE6: return "ae";
    case 0xE7: return "c";
    case 0xE8: case 0xE9: case 0xEA: case 0xEB: return "e";
    case 0xEC: case 0xED: case 0xEE: case 0xEF: return "i";
    case 0xF1: return "n";
    case 0xF2: case 0xF3: case 0xF4: case 0xF5: case 0xF6: return "o";
    case 0xF9: case 0xFA: case 0xFB: case 0xFC: return "u";
    case 0xFD: case 0xFF: return "y";
    // Latin Extended-A.
    case 0x100: case 0x102: case 0x104: return "A";
    case 0x101: case 0x103: case 0x105: return "a";
    case 0x106: case 0x108: case 0x10A: case 0x10C: return "C";
    case 0x107: case 0x109: case 0x10B: case 0x10D: return "c";
    case 0x10E: return "D";
    case 0x10F: return "d";
    case 0x112: case 0x114: case 0x116: case 0x118: case 0x11A: return "E";
    case 0x113: case 0x115: case 0x117: case 0x119: case 0x11B: return "e";
    case 0x11C: case 0x11E: case 0x120: case 0x122: return "G";
    case 0x11D: case 0x11F: case 0x121: case 0x123: return "g";
    case 0x124: return "H";
    case 0x125: return "h";
    case 0x128: case 0x12A: case 0x12C: case 0x12E: case 0x130: return "I";
    case 0x129: case 0x12B: case 0x12D: case 0x12F: return "i";
    case 0x134: return "J";
    case 0x135: return "j";
    case 0x136: return "K";
    case 0x137: return "k";
    case 0x139: case 0x13B: case 0x13D: return "L";
    case 0x13A: case 0x13C: case 0x13E: return "l";
    case 0x143: case 0x145: case 0x147: return "N";
    case 0x144: case 0x146: case 0x148: return "n";
    case 0x14C: case 0x14E: case 0x150: return "O";
    case 0x14D: case 0x14F: case 0x151: return "o";
    case 0x152: case 0x153: return "oe";
    case 0x154: case 0x156: case 0x158: return "R";
    case 0x155: case 0x157: case 0x159: return "r";
    case 0x15A: case 0x15C: case 0x15E: case 0x160: return "S";
    case 0x15B: case 0x15D: case 0x15F: case 0x161: return "s";
    case 0x162: case 0x164: return "T";
    case 0x163: case 0x165: return "t";
    case 0x168: case 0x16A: case 0x16C: case 0x16E: case 0x170: case 0x172: return "U";
    case 0x169: case 0x16B: case 0x16D: case 0x16F: case 0x171: case 0x173: return "u";
    case 0x174: return "W";
    case 0x175: return "w";
    case 0x176: case 0x178: return "Y";
    case 0x177: return "y";
    case 0x179: case 0x17B: case 0x17D: return "Z";
    case 0x17A: case 0x17C: case 0x17E: return "z";
    default: return nullptr;
  }
}

std::uint32_t lower_codepoint(std::uint32_t cp) {
  if (cp >= 'A' && cp <= 'Z') return cp + 0x20;
  if (cp >= 0xC0 && cp <= 0xDE && cp != 0xD7) return cp + 0x20;
  if (cp >= 0x100 && cp <= 0x137) return (cp % 2 == 0) ? cp + 1 : cp;
  if (cp >= 0x139 && cp <= 0x148) return (cp % 2 == 1) ? cp + 1 : cp;
  if (cp >= 0x14A && cp <= 0x177) return (cp % 2 == 0) ? cp + 1 : cp;
  if (cp == 0x178) return 0xFF;
  if (cp >= 0x179 && cp <= 0x17E) return (cp % 2 == 1) ? cp + 1 : cp;
  return cp;
}

}  // namespace

namespace text_util {

std::string remove_diacritics(std::string_view text) {
  std::string out;
  out.reserve(text.size());
  std::size_t i = 0;
  while (i < text.size()) {
    const std::uint32_t cp = next_codepoint(text, i);
    if (cp >= 0x300 && cp <= 0x36F) continue;  // a loose combining mark: dropped, as NFD's would be
    if (const char* folded = ascii_fold(cp)) out.append(folded);
    else append_codepoint(out, cp);
  }
  return out;
}

std::string to_lower_invariant(std::string_view text) {
  std::string out;
  out.reserve(text.size());
  std::size_t i = 0;
  while (i < text.size()) append_codepoint(out, lower_codepoint(next_codepoint(text, i)));
  return out;
}

}  // namespace text_util

TypeAheadSearch::TypeAheadSearch() { buffer_.reserve(32); }

void TypeAheadSearch::add_codepoint(std::uint32_t cp) { append_codepoint(buffer_, cp); }

bool TypeAheadSearch::remove_char() {
  if (buffer_.empty()) return false;
  // Drop continuation bytes (10xxxxxx), then the lead byte: one whole code point.
  while (buffer_.size() > 1 && (static_cast<unsigned char>(buffer_.back()) & 0xC0) == 0x80) buffer_.pop_back();
  buffer_.pop_back();
  return true;
}

void TypeAheadSearch::clear() {
  buffer_.clear();
  is_search_active_ = false;
  result_indices_.clear();
  result_names_.clear();
  result_cursor_ = 0;
  announce_result_ = nullptr;
}

namespace {

// More than one code point, all the same one ("lll", "éé"); `first_len` receives the byte length of the first.
bool is_repeated_codepoint(const std::string& s, std::size_t& first_len) {
  std::size_t i = 0;
  const std::uint32_t first = next_codepoint(s, i);
  first_len = i;
  int count = 1;
  while (i < s.size()) {
    if (next_codepoint(s, i) != first) return false;
    ++count;
  }
  return count > 1;
}

std::string trim_end(const std::string& s) {
  std::size_t end = s.size();
  while (end > 0 && static_cast<unsigned char>(s[end - 1]) <= ' ') end--;
  return s.substr(0, end);
}

}  // namespace

void TypeAheadSearch::search(int item_count, const std::function<std::string(int)>& name_by_index,
                             std::function<void(int)> announce_result) {
  // Repeat single-letter: typing the same letter again cycles ALL its matches in list order
  // (l -> Load Game, l -> License, l -> DLC), wrapping.
  const std::string buffer_str = buffer_;
  std::size_t first_len = 0;
  if (is_search_active_ && !result_indices_.empty() && !buffer_.empty() && is_repeated_codepoint(buffer_str, first_len)) {
    buffer_.resize(first_len);
    if (announce_result) announce_result_ = std::move(announce_result);
    navigate_results(1);
    return;
  }

  if (announce_result) announce_result_ = std::move(announce_result);

  const std::string trimmed = trim_end(buffer_str);
  if (!has_buffer() || item_count == 0 || trimmed.empty()) {
    result_indices_.clear();
    result_names_.clear();
    result_cursor_ = 0;
    is_search_active_ = true;
    if (on_no_match) on_no_match(buffer_str);
    return;
  }

  for (int t = 0; t < kTierCount; t++) {
    tier_indices_[t].clear();
    tier_names_[t].clear();
    tier_positions_[t].clear();
    tier_sort_lengths_[t].clear();
    tier_in_segment_[t].clear();
  }
  const std::string lower_buffer = text_util::to_lower_invariant(trimmed);

  for (int i = 0; i < item_count; i++) {
    const std::string name = name_by_index(i);
    if (name.empty()) continue;
    int pos = -1;
    const int tier = match_tier(text_util::to_lower_invariant(name), lower_buffer, pos);
    if (tier >= 0) {
      tier_indices_[tier].push_back(i);
      tier_names_[tier].push_back(name);
      tier_positions_[tier].push_back(pos);
      // Matches inside the name (before the first comma) rank ahead of matches inside the appended
      // metadata; sort length is likewise name-only.
      const std::size_t comma = name.find(',');
      const int name_len = comma == std::string::npos ? static_cast<int>(name.size())
                                                      : static_cast<int>(comma);
      tier_sort_lengths_[tier].push_back(name_len);
      tier_in_segment_[tier].push_back(pos < name_len ? 0 : 1);
    }
  }

  // Within a tier, entries stay in ITEM order (collected 0..n above) -- no length re-ranking. Merge:
  // name (pre-comma) matches across all tiers before metadata (post-comma) matches.
  work_indices_.clear();
  work_names_.clear();
  for (int in_seg = 0; in_seg <= 1; in_seg++)
    for (int t = 0; t < kTierCount; t++)
      for (std::size_t i = 0; i < tier_indices_[t].size(); i++)
        if (tier_in_segment_[t][i] == in_seg) {
          work_indices_.push_back(tier_indices_[t][i]);
          work_names_.push_back(tier_names_[t][i]);
        }

  if (work_indices_.empty()) {
    result_indices_.clear();
    result_names_.clear();
    result_cursor_ = 0;
    is_search_active_ = true;
    if (on_no_match) on_no_match(buffer_str);
  } else {
    result_indices_.swap(work_indices_);
    result_names_.swap(work_names_);
    result_cursor_ = 0;
    is_search_active_ = true;
    announce_current_result();
  }
}

void TypeAheadSearch::navigate_results(int direction) {
  if (result_indices_.empty()) return;
  const int count = static_cast<int>(result_indices_.size());
  const int cursor = ((static_cast<int>(result_cursor_) + direction) % count + count) % count;
  result_cursor_ = static_cast<std::size_t>(cursor);
  announce_current_result();
}

void TypeAheadSearch::jump_to_first_result() {
  if (result_indices_.empty()) return;
  result_cursor_ = 0;
  announce_current_result();
}

void TypeAheadSearch::jump_to_last_result() {
  if (result_indices_.empty()) return;
  result_cursor_ = result_indices_.size() - 1;
  announce_current_result();
}

void TypeAheadSearch::announce_current_result() {
  if (result_indices_.empty()) return;
  if (announce_result_) announce_result_(result_indices_[result_cursor_]);
}

namespace {

// Position of the first matched word if every space-delimited token in the prefix is a prefix of a
// distinct word in the name, consumed in order, all within one comma-delimited segment.
int match_word_prefix_tokens(std::string_view lower_name, std::string_view lower_prefix) {
  std::vector<std::string_view> tokens;
  std::size_t start = 0;
  while (start <= lower_prefix.size()) {
    const std::size_t sep = lower_prefix.find(' ', start);
    const std::size_t end = sep == std::string_view::npos ? lower_prefix.size() : sep;
    if (end > start) tokens.push_back(lower_prefix.substr(start, end - start));
    if (sep == std::string_view::npos) break;
    start = sep + 1;
  }
  if (tokens.empty()) return -1;

  std::size_t token_idx = 0;
  int first_pos = -1;
  std::size_t i = 0;
  while (i < lower_name.size()) {
    const char c = lower_name[i];
    if (c == ',') {
      token_idx = 0;
      first_pos = -1;
      i++;
      continue;
    }
    if (c == ' ') {
      i++;
      continue;
    }

    if (token_idx < tokens.size()) {
      const std::string_view token = tokens[token_idx];
      const bool fits = i + token.size() <= lower_name.size() &&
                        lower_name.compare(i, token.size(), token) == 0;
      if (fits) {
        if (token_idx == 0) first_pos = static_cast<int>(i);
        token_idx++;
        if (token_idx == tokens.size()) return first_pos;
        i += token.size();
      }
    }
    while (i < lower_name.size() && lower_name[i] != ' ' && lower_name[i] != ',') i++;
  }

  return -1;
}

}  // namespace

int TypeAheadSearch::match_tier(std::string_view lower_name_in, std::string_view lower_prefix_in,
                                int& position) {
  position = -1;
  const std::string lower_name = text_util::remove_diacritics(lower_name_in);
  const std::string lower_prefix = text_util::remove_diacritics(lower_prefix_in);
  const std::size_t prefix_len = lower_prefix.size();
  if (prefix_len > lower_name.size()) return -1;

  if (lower_name.compare(0, prefix_len, lower_prefix) == 0) {
    position = 0;
    const bool whole_word =
        lower_name.size() == prefix_len || lower_name[prefix_len] == ' ' || lower_name[prefix_len] == ',';
    return whole_word ? 0 : 1;
  }

  for (std::size_t i = 1; i < lower_name.size(); i++) {
    const char prev = lower_name[i - 1];
    if (prev != ' ' && prev != ',') continue;
    if (lower_name[i] == ' ') continue;
    if (lower_name.size() - i < prefix_len) break;
    if (lower_name.compare(i, prefix_len, lower_prefix) == 0) {
      const std::size_t after_match = i + prefix_len;
      const bool whole_word = after_match >= lower_name.size() || lower_name[after_match] == ' ' ||
                              lower_name[after_match] == ',';
      position = static_cast<int>(i);
      return whole_word ? 2 : 3;
    }
  }

  const std::size_t idx = lower_name.find(lower_prefix);
  if (idx != std::string::npos) {
    position = static_cast<int>(idx);
    return 4;
  }

  if (lower_prefix.find(' ') != std::string::npos) {
    const int abbrev_pos = match_word_prefix_tokens(lower_name, lower_prefix);
    if (abbrev_pos >= 0) {
      position = abbrev_pos;
      return 5;
    }
  }

  return -1;
}

}  // namespace fa::ui
