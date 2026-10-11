#include "update/check.h"
#include <array>
#include <cctype>
#include "ui/message_builder.h"
#include "ui/strings.h"

namespace fa::update {
namespace {
constexpr std::string_view kRepoPath = "/repos/Factorio-Access/FactorioAccess/releases";

bool is_hex(std::string_view s) {
  if (s.empty()) return false;
  for (char c : s)
    if (!std::isxdigit((unsigned char)c)) return false;
  return true;
}
// "v1.2.3" (a trailing "-suffix" ignored) -> {1, 2, 3}; false when it is not one.
bool parse_semver(std::string_view t, std::array<unsigned long, 3>& out) {
  if (t.empty() || (t[0] != 'v' && t[0] != 'V')) return false;
  t.remove_prefix(1);
  for (int i = 0; i < 3; ++i) {
    if (t.empty() || !std::isdigit((unsigned char)t[0])) return false;
    unsigned long n = 0;
    while (!t.empty() && std::isdigit((unsigned char)t[0])) {
      n = n * 10 + (unsigned long)(t[0] - '0');
      t.remove_prefix(1);
    }
    out[(size_t)i] = n;
    if (i < 2) {
      if (t.empty() || t[0] != '.') return false;
      t.remove_prefix(1);
    }
  }
  return t.empty() || t[0] == '-' || t[0] == '+';
}
}  // namespace

Channel channel_of(std::string_view installed) {
  std::array<unsigned long, 3> v{};
  if (parse_semver(installed, v)) return Channel::Release;
  if (installed.size() > 3 && installed.substr(0, 3) == "ci-" && is_hex(installed.substr(3))) return Channel::Ci;
  return Channel::None;
}

std::string request_path(Channel c) {
  switch (c) {
    case Channel::Release: return std::string(kRepoPath) + "/latest";
    case Channel::Ci: return std::string(kRepoPath) + "/tags/ci-latest";
    default: return {};
  }
}

std::string json_string(std::string_view json, std::string_view key) {
  std::string needle = "\"" + std::string(key) + "\"";
  size_t at = json.find(needle);
  if (at == std::string_view::npos) return {};
  size_t i = at + needle.size();
  auto skip_ws = [&] {
    while (i < json.size() && std::isspace((unsigned char)json[i])) ++i;
  };
  skip_ws();
  if (i >= json.size() || json[i] != ':') return {};
  ++i;
  skip_ws();
  if (i >= json.size() || json[i] != '"') return {};
  ++i;
  std::string out;
  for (; i < json.size(); ++i) {
    char c = json[i];
    if (c == '"') return out;
    if (c == '\\' && i + 1 < json.size()) {  // an escaped quote or backslash; \u escapes never appear in a tag or sha
      out += json[++i];
      continue;
    }
    out += c;
  }
  return {};  // unterminated
}

Verdict decide(std::string_view installed, std::string_view json) {
  Verdict v;
  switch (channel_of(installed)) {
    case Channel::Release: {
      std::string tag = json_string(json, "tag_name");
      std::array<unsigned long, 3> have{}, latest{};
      if (parse_semver(installed, have) && parse_semver(tag, latest) && latest > have) {
        v.newer = true;
        v.latest = tag;
      }
      break;
    }
    case Channel::Ci: {
      std::string sha = json_string(json, "target_commitish");
      std::string_view mine = installed.substr(3);
      if (sha.size() >= mine.size() && is_hex(sha) && sha.compare(0, mine.size(), mine) != 0) {
        v.newer = true;
        v.latest = sha.substr(0, 7);
      }
      break;
    }
    default: break;
  }
  return v;
}

std::string announcement(std::string_view installed, const Verdict& v) {
  ui::MessageBuilder m;
  m.list_item().fragment(channel_of(installed) == Channel::Ci ? strings::kCiUpdateAvailable : strings::kUpdateAvailable);
  m.list_item().fragment(v.latest);
  m.list_item().fragment(strings::kYouHave).fragment(installed);
  m.list_item().fragment(strings::kRunInstallerToUpdate);
  return m.build();
}

bool Settle::ready(bool on_main_menu, double now) {
  if (on_main_menu != was_on_) {
    was_on_ = on_main_menu;
    since_ = now;
  }
  return on_main_menu && now - since_ >= kSettleSeconds;
}

}  // namespace fa::update
