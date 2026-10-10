#include <doctest/doctest.h>
#include "audio/json.h"

using namespace fa::audio;

TEST_CASE("json parses the shapes commands use") {
  std::string err;
  auto v = json::parse(R"( {"a": [1, -2.5e1, true, false, null], "b": {"c": "x\"\u00e9\ud83d\ude00"}} )", err);
  REQUIRE(v);
  const json::Value* a = v->find("a");
  REQUIRE(a);
  REQUIRE(a->is_array());
  REQUIRE(a->array.size() == 5);
  CHECK(a->array[0].number == 1.0);
  CHECK(a->array[1].number == -25.0);
  CHECK(a->array[2].boolean);
  CHECK(a->array[3].is_bool());
  CHECK(a->array[4].is_null());
  CHECK(v->find("b")->find("c")->string == "x\"\xC3\xA9\xF0\x9F\x98\x80");
  CHECK(v->find("missing") == nullptr);
}

TEST_CASE("json rejects malformed input without throwing") {
  for (const char* bad : {"", "{", "{\"a\":}", "[1,]", "{\"a\" 1}", "nul", "\"open", "1 2", "{\"a\":1,}", "-", "01x", R"("\q")"}) {
    std::string err;
    CHECK_MESSAGE(!json::parse(bad, err), bad);
    CHECK(!err.empty());
  }
}

TEST_CASE("json limits nesting depth") {
  std::string deep(1000, '[');
  std::string err;
  CHECK(!json::parse(deep, err));
}

TEST_CASE("json duplicate keys keep the last value") {
  std::string err;
  auto v = json::parse(R"({"k": 1, "k": 2})", err);
  REQUIRE(v);
  CHECK(v->find("k")->number == 2.0);
}
