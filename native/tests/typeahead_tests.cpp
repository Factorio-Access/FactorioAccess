// TypeAheadSearch had no tests in wotr-access; these are new, and exist because the C++ port had to
// hand-write the case folding and diacritic folding that C# got from Unicode normalization (see
// core/typeahead.h). They pin the six match tiers, the list-order/name-before-metadata ranking, and the
// repeat-letter cycle described in the class comment.
#include <doctest/doctest.h>

#include <string>
#include <vector>

#include "ui/typeahead.h"

using fa::ui::TypeAheadSearch;

namespace {

int tier_of(const std::string& name, const std::string& prefix) {
  int pos = -1;
  return TypeAheadSearch::match_tier(fa::ui::text_util::to_lower_invariant(name),
                                     fa::ui::text_util::to_lower_invariant(prefix), pos);
}

// Types `text` and runs a search, appending every announced item index to `hits`. The callback must
// outlive the search object, which keeps it for later result navigation.
void type_and_search(TypeAheadSearch& search, const std::string& text,
                     const std::vector<std::string>& items, std::vector<int>& hits) {
  for (char c : text) search.add_char(c);
  search.search(
      static_cast<int>(items.size()), [&items](int i) { return items[static_cast<std::size_t>(i)]; },
      [&hits](int index) { hits.push_back(index); });
}

}  // namespace

TEST_CASE("match tiers rank start-of-string over mid-string over substring") {
  CHECK(tier_of("Load Game", "load") == 0);   // start of string, whole word
  CHECK(tier_of("License", "lic") == 1);      // start of string, prefix
  CHECK(tier_of("New Game", "game") == 2);    // mid-string whole word
  CHECK(tier_of("New Game", "gam") == 3);     // mid-string word prefix
  CHECK(tier_of("DLC", "l") == 4);            // substring anywhere
  CHECK(tier_of("gas pipe", "ga pi") == 5);   // space-delimited abbreviation
  CHECK(tier_of("Continue", "zz") == -1);
}

TEST_CASE("a comma also delimits a whole word") {
  CHECK(tier_of("Continue, button", "continue") == 0);
  CHECK(tier_of("Continue, button", "button") == 2);
}

TEST_CASE("diacritics and case are folded away") {
  CHECK(tier_of("Caf\xC3\xA9 Menu", "cafe") == 0);  // "Café Menu"
  CHECK(tier_of("Elden R\xC3\xAFng", "ring") == 2);  // "Elden Rïng"
  CHECK(tier_of("\xC3\x86THER", "aether") == 0);     // "ÆTHER"
}

TEST_CASE("within a tier results keep list order, and repeating the letter cycles them") {
  TypeAheadSearch search;
  const std::vector<std::string> items{"Continue", "Load Game", "New Game", "License", "DLC"};
  std::vector<int> hits;

  type_and_search(search, "l", items, hits);
  REQUIRE(hits.size() == 1);
  CHECK(hits[0] == 1);  // Load Game: tier 1 and earliest in list order
  CHECK(search.result_count() == 3);

  // Repeating the letter cycles every match of it, weaker tiers last, wrapping.
  type_and_search(search, "l", items, hits);
  REQUIRE(hits.size() == 2);
  CHECK(hits[1] == 3);  // License
  type_and_search(search, "l", items, hits);
  REQUIRE(hits.size() == 3);
  CHECK(hits[2] == 4);  // DLC, on the substring tier
  type_and_search(search, "l", items, hits);
  REQUIRE(hits.size() == 4);
  CHECK(hits[3] == 1);  // wrapped back to Load Game
}

TEST_CASE("matches in the name outrank matches in the appended metadata") {
  TypeAheadSearch search;
  const std::vector<std::string> items{"Sword, legendary blade", "Blade of dawn"};
  std::vector<int> hits;

  type_and_search(search, "blade", items, hits);
  REQUIRE(hits.size() == 1);
  CHECK(hits[0] == 1);  // the pre-comma match wins even though it is later in the list
  CHECK(search.result_count() == 2);
}

TEST_CASE("an unmatched buffer reports no match and clears the results") {
  TypeAheadSearch search;
  std::string reported;
  std::vector<int> hits;
  search.on_no_match = [&reported](const std::string& buffer) { reported = buffer; };

  type_and_search(search, "zq", {"Continue", "Load Game"}, hits);
  CHECK(hits.empty());
  CHECK(reported == "zq");
  CHECK(search.result_count() == 0);
  CHECK(search.is_search_active());

  search.clear();
  CHECK_FALSE(search.has_buffer());
  CHECK_FALSE(search.is_search_active());
}

TEST_CASE("result navigation wraps in both directions") {
  TypeAheadSearch search;
  const std::vector<std::string> items{"Alpha", "Beta", "Alto"};
  std::vector<int> hits;

  type_and_search(search, "a", items, hits);
  REQUIRE(hits.size() == 1);
  CHECK(hits[0] == 0);                // Alpha
  CHECK(search.result_count() == 3);  // Alpha, Alto (tier 1), then Beta (substring)

  search.navigate_results(-1);  // wrap backwards to the last result
  CHECK(hits.back() == 1);      // Beta
  search.jump_to_first_result();
  CHECK(hits.back() == 0);
  search.jump_to_last_result();
  CHECK(hits.back() == 1);
  search.navigate_results(+1);  // wrap forwards
  CHECK(hits.back() == 0);
}

// A non-English player's report (2026-09-22): typed non-ASCII letters reached the search as '?' and matched
// nothing. The navigator now appends whole code points; the buffer stays valid UTF-8 through backspace and the
// repeat-letter cycle.
TEST_CASE("a typed accented letter is searched as itself, and backspace removes it whole") {
  const std::vector<std::string> items = {"Autel", "\xC3\x89glise", "\xC3\xA9" "cole", "Ecurie"};   // Eglise, ecole (accented)
  TypeAheadSearch search;
  std::vector<int> hits;
  search.add_codepoint(0xE9);   // é
  search.search(static_cast<int>(items.size()), [&items](int i) { return items[static_cast<std::size_t>(i)]; },
                [&hits](int index) { hits.push_back(index); });
  REQUIRE(!hits.empty());
  CHECK(hits.back() == 1);              // "Église": accents and case fold, list order wins
  CHECK(search.buffer() == "\xC3\xA9");
  CHECK(search.remove_char());
  CHECK(search.buffer().empty());       // both bytes of é gone, not a dangling lead byte
}

TEST_CASE("repeating an accented letter cycles its matches like an ASCII one") {
  const std::vector<std::string> items = {"\xC3\x89glise", "Autel", "\xC3\xA9" "cole"};   // Eglise, ecole (accented)
  TypeAheadSearch search;
  std::vector<int> hits;
  auto run = [&] {
    search.search(static_cast<int>(items.size()), [&items](int i) { return items[static_cast<std::size_t>(i)]; },
                  [&hits](int index) { hits.push_back(index); });
  };
  search.add_codepoint(0xE9); run();
  search.add_codepoint(0xE9); run();
  REQUIRE(hits.size() >= 2);
  CHECK(hits[0] == 0);
  CHECK(hits.back() == 2);                 // the second é moved to the next match
  CHECK(search.buffer() == "\xC3\xA9");   // cut back to one whole code point
}

TEST_CASE("a Cyrillic letter is searched as itself") {
  const std::vector<std::string> items = {"Alpha", "\xD0\x91\xD0\xB5\xD1\x82\xD0\xB0"};   // "Beta" in Cyrillic
  TypeAheadSearch search;
  std::vector<int> hits;
  search.add_codepoint(0x0411);   // Б
  search.search(static_cast<int>(items.size()), [&items](int i) { return items[static_cast<std::size_t>(i)]; },
                [&hits](int index) { hits.push_back(index); });
  REQUIRE(!hits.empty());
  CHECK(hits.back() == 1);
}
