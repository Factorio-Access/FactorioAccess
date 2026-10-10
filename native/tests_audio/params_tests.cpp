// Port of launcher-audio tests/test_parameters.py.
#include <doctest/doctest.h>
#include "audio/commands.h"

using namespace fa::audio;
using doctest::Approx;

static Param env(std::vector<TimePoint> pts) { return *Param::envelope(std::move(pts)); }
static Param param_json(const char* text) {
  std::string err;
  auto v = json::parse(text, err);
  REQUIRE(v);
  auto p = parse_param(*v, err);
  REQUIRE_MESSAGE(p, err);
  return *p;
}

TEST_CASE("static param returns a constant value") {
  Param p = Param::constant(0.5);
  CHECK(p.value(0.0) == 0.5);
  CHECK(p.value(100.0) == 0.5);
  CHECK(p.value(-5.0) == 0.5);
  CHECK(p.is_constant());
}

TEST_CASE("time envelope") {
  using enum Interpolation;
  SUBCASE("single point is constant") {
    Param e = env({{0.0, 1.0}});
    CHECK(e.is_constant());
    CHECK(e.value(0.0) == 1.0);
    CHECK(e.value(100.0) == 1.0);
  }
  SUBCASE("before first point returns first value") {
    Param e = env({{1.0, 0.5}, {2.0, 1.0}});
    CHECK(e.value(0.0) == 0.5);
    CHECK(e.value(0.9) == 0.5);
  }
  SUBCASE("after last point returns last value") {
    Param e = env({{0.0, 0.0}, {1.0, 1.0}});
    CHECK(e.value(1.0) == 1.0);
    CHECK(e.value(100.0) == 1.0);
  }
  SUBCASE("linear interpolation") {
    Param e = env({{0.0, 0.0, Linear}, {1.0, 1.0, Linear}});
    CHECK(e.value(0.0) == Approx(0.0));
    CHECK(e.value(0.25) == Approx(0.25));
    CHECK(e.value(0.5) == Approx(0.5));
    CHECK(e.value(0.75) == Approx(0.75));
    CHECK(e.value(1.0) == Approx(1.0));
  }
  SUBCASE("jump holds the previous value until the point") {
    Param e = env({{0.0, 0.0, Linear}, {1.0, 1.0, Jump}});
    CHECK(e.value(0.0) == 0.0);
    CHECK(e.value(0.5) == 0.0);
    CHECK(e.value(0.99) == 0.0);
    CHECK(e.value(1.0) == 1.0);
  }
  SUBCASE("multiple segments") {
    Param e = env({{0.0, 0.0}, {1.0, 1.0}, {2.0, 0.5}});
    CHECK(e.value(0.5) == Approx(0.5));
    CHECK(e.value(1.0) == Approx(1.0));
    CHECK(e.value(1.5) == Approx(0.75));
    CHECK(e.value(2.0) == Approx(0.5));
  }
  SUBCASE("points are sorted") {
    Param e = env({{2.0, 1.0}, {0.0, 0.0}, {1.0, 0.5}});
    CHECK(e.value(0.0) == 0.0);
    CHECK(e.value(1.0) == 0.5);
    CHECK(e.value(2.0) == 1.0);
    CHECK(!e.is_constant());
  }
  SUBCASE("empty is an error") { CHECK(!Param::envelope({})); }
}

TEST_CASE("parse_param") {
  SUBCASE("static int") { CHECK(param_json("1").value(0) == 1.0); }
  SUBCASE("static float") {
    Param p = param_json("0.75");
    CHECK(p.is_constant());
    CHECK(p.value(0) == 0.75);
  }
  SUBCASE("envelope") {
    Param p = param_json(R"([{"time": 0.0, "value": 0.0}, {"time": 1.0, "value": 1.0, "interpolation_from_prev": "linear"}])");
    CHECK(!p.is_constant());
    CHECK(p.value(0.5) == Approx(0.5));
  }
  SUBCASE("envelope with jump") {
    Param p = param_json(R"([{"time": 0.0, "value": 0.0}, {"time": 1.0, "value": 1.0, "interpolation_from_prev": "jump"}])");
    CHECK(p.value(0.5) == 0.0);
  }
  SUBCASE("unknown interpolation is linear") {
    Param p = param_json(R"([{"time": 0, "value": 0}, {"time": 1, "value": 1, "interpolation_from_prev": "cubic"}])");
    CHECK(p.value(0.5) == Approx(0.5));
  }
  SUBCASE("invalid values are errors") {
    for (const char* bad : {"\"loud\"", "null", "{\"a\": 1}", "[]", "{}", "[{\"time\": 0}]", "[{\"value\": 0}]", "[1, 2]"}) {
      std::string err;
      auto v = json::parse(bad, err);
      REQUIRE(v);
      CHECK_MESSAGE(!parse_param(*v, err), bad);
      CHECK(!err.empty());
    }
  }
}
