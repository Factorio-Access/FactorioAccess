#pragma once
// The update check's decisions (engine-free; the WinHTTP fetch is src/win/update_check.cpp). The native code's version
// is embedded at build time (fa_version.h): a tag "v0.16.57" (a release) or "ci-<short sha>" (a CI build); anything
// else ("dev") is never checked. A release asks GitHub for the newest full release (releases/latest skips the ci-latest
// pre-release); a CI build asks for the rolling ci-latest pre-release, whose target_commitish is the commit it was
// built from (the workflow never moves it backwards), so "a different commit" means "newer".
#include <string>
#include <string_view>

namespace fa::update {

enum class Channel { None, Release, Ci };
Channel channel_of(std::string_view installed);
// The GitHub API path for the channel ("" for None).
std::string request_path(Channel c);
// The first "key": "value" string in a JSON text, unescaped; "" when absent. Enough for the two top-level fields read
// here (tag_name, target_commitish), which no nested object of a release repeats.
std::string json_string(std::string_view json, std::string_view key);

struct Verdict {
  bool newer = false;
  std::string latest;  // the tag, or the CI build's short sha
};
Verdict decide(std::string_view installed, std::string_view json);

// What the player hears: "Factorio Access update available, v0.17.0, you have v0.16.57, run the Factorio Access
// installer to update" (the CI variant names the build's short sha).
std::string announcement(std::string_view installed, const Verdict& v);

// When to speak: the main menu has been the current screen for kSettleSeconds (the game's startup and the menu's own
// first announcement would otherwise talk over the line). Fed once per frame; true while settled.
class Settle {
 public:
  static constexpr double kSettleSeconds = 3.0;
  bool ready(bool on_main_menu, double now);

 private:
  bool was_on_ = false;
  double since_ = 0;
};

}  // namespace fa::update
