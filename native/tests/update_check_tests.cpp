#include <doctest/doctest.h>
#include "update/check.h"

using namespace fa::update;

TEST_CASE("update: channel of the embedded version") {
  CHECK(channel_of("v0.16.57") == Channel::Release);
  CHECK(channel_of("v1.10.2-rc1") == Channel::Release);
  CHECK(channel_of("ci-03c9462") == Channel::Ci);
  CHECK(channel_of("dev") == Channel::None);
  CHECK(channel_of("ci-") == Channel::None);
  CHECK(channel_of("ci-xyz") == Channel::None);
  CHECK(channel_of("0.16.57") == Channel::None);
  CHECK(request_path(Channel::Release) == "/repos/Factorio-Access/FactorioAccess/releases/latest");
  CHECK(request_path(Channel::Ci) == "/repos/Factorio-Access/FactorioAccess/releases/tags/ci-latest");
  CHECK(request_path(Channel::None).empty());
}

TEST_CASE("update: json string fields") {
  const char* release = "{\"url\":\"x\",\"tag_name\": \"v0.5.0\",\"name\":\"a \\\"q\\\"\"}";
  const char* escaped = "{\"name\":\"a \\\"q\\\" \\\\ b\"}";
  CHECK(json_string(release, "tag_name") == "v0.5.0");
  CHECK(json_string(escaped, "name") == "a \"q\" \\ b");
  CHECK(json_string(R"({"tag_name":5})", "tag_name").empty());
  CHECK(json_string(R"({"other":"v"})", "tag_name").empty());
  CHECK(json_string(R"({"tag_name":"unterminated)", "tag_name").empty());
}

TEST_CASE("update: releases compare by semver") {
  CHECK(decide("v0.16.57", R"({"tag_name":"v0.17.0"})").newer);
  CHECK(decide("v0.16.57", R"({"tag_name":"v0.17.0"})").latest == "v0.17.0");
  CHECK(decide("v0.16.9", R"({"tag_name":"v0.16.10"})").newer);  // numeric, not text
  CHECK_FALSE(decide("v0.16.57", R"({"tag_name":"v0.16.57"})").newer);
  CHECK_FALSE(decide("v0.16.57", R"({"tag_name":"v0.15.3"})").newer);
  CHECK_FALSE(decide("v0.16.57", R"({"message":"Not Found"})").newer);
}

TEST_CASE("update: CI builds compare by commit") {
  const char* json = R"({"tag_name":"ci-latest","target_commitish":"26ab37012345678901234567890123456789abcd"})";
  CHECK_FALSE(decide("ci-26ab370", json).newer);
  Verdict v = decide("ci-4d25d72", json);
  CHECK(v.newer);
  CHECK(v.latest == "26ab370");
  CHECK_FALSE(decide("ci-4d25d72", R"({"target_commitish":"f2.1"})").newer);  // not a sha
  CHECK_FALSE(decide("dev", json).newer);
}

TEST_CASE("update: announcement") {
  CHECK(announcement("v0.16.57", decide("v0.16.57", R"({"tag_name":"v0.17.0"})")) ==
        "Factorio Access update available, v0.17.0, you have v0.16.57, run the Factorio Access installer to update");
  CHECK(announcement("ci-4d25d72", Verdict{true, "26ab370"}) ==
        "newer Factorio Access CI build available, 26ab370, you have ci-4d25d72, run the Factorio Access installer to update");
}

TEST_CASE("update: waits for the main menu to settle") {
  Settle s;
  CHECK_FALSE(s.ready(false, 0));
  CHECK_FALSE(s.ready(true, 1));
  CHECK_FALSE(s.ready(true, 3.9));
  CHECK(s.ready(true, 4.0));
  CHECK_FALSE(s.ready(false, 5));  // a dialog over the menu resets the wait
  CHECK_FALSE(s.ready(true, 6));
  CHECK(s.ready(true, 9.5));
}
