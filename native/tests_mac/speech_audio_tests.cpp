#include <doctest/doctest.h>
#include "mac/speech_audio.h"

using namespace fa::mac::speech_audio;

TEST_CASE("trim: silence around the speech goes, a few milliseconds either side stay") {
  std::vector<float> s(1000, 0.0f);
  for (int i = 400; i < 600; ++i) s[i] = 0.5f;
  auto t = trim(s.data(), s.size(), 1000);  // 1 kHz: 5 ms is 5 samples
  CHECK(t.size() == 210);
  CHECK(t.front() == 0.0f);
  CHECK(t[5] == 0.5f);
}

TEST_CASE("trim: all silence is empty") {
  std::vector<float> s(100, 0.001f);
  CHECK(trim(s.data(), s.size(), 22050).empty());
}

TEST_CASE("fade_edges: the ends go to zero, the middle is untouched") {
  std::vector<float> s(1000, 1.0f);
  fade_edges(s, 1000);  // 2 samples in, 4 out
  CHECK(s.front() == doctest::Approx(0.0f));
  CHECK(s.back() == doctest::Approx(0.0f));
  CHECK(s[500] == 1.0f);
}

TEST_CASE("fade_edges: a line shorter than both ramps still fades both ways") {
  std::vector<float> s(3, 1.0f);
  fade_edges(s, 1000);
  CHECK(s.front() == doctest::Approx(0.0f));
  CHECK(s.back() == doctest::Approx(0.0f));
}
