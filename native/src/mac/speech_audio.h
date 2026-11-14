#pragma once
// The sample arithmetic of the system voice's gapless queue (mac/speech.mm), kept pure for tests: what of a rendered
// utterance is speech, and the short fades that stop a line clicking against the silence around it. Ported from
// NonVisualCalculus' SpeechAudio.
#include <algorithm>
#include <cmath>
#include <cstddef>
#include <vector>

namespace fa::mac::speech_audio {
constexpr float kSilenceThreshold = 0.004f;  // samples quieter than this are silence
constexpr double kKeepEdgeSeconds = 0.005;   // kept either side of the speech so a consonant is not clipped
constexpr double kFadeInSeconds = 0.002;
constexpr double kFadeOutSeconds = 0.004;

// The speech between the first and last samples above the threshold, plus kKeepEdgeSeconds either side; empty when
// nothing is above it.
inline std::vector<float> trim(const float* samples, size_t count, double rate) {
  size_t start = 0;
  while (start < count && std::fabs(samples[start]) < kSilenceThreshold) ++start;
  if (start == count) return {};
  size_t end = count - 1;
  while (end > start && std::fabs(samples[end]) < kSilenceThreshold) --end;
  size_t keep = (size_t)(kKeepEdgeSeconds * rate);
  start = start > keep ? start - keep : 0;
  end = std::min(count - 1, end + keep);
  return std::vector<float>(samples + start, samples + end + 1);
}

// 0 at x = 0 rising smoothly to 1 at x = 1.
inline float raised_cosine(float x) { return 0.5f - 0.5f * std::cos((float)M_PI * x); }

// Ramp the first kFadeInSeconds up from zero and the last kFadeOutSeconds down to zero, in place. A line shorter
// than both ramps gives each its share.
inline void fade_edges(std::vector<float>& s, double rate) {
  size_t n = s.size();
  if (!n) return;
  size_t in = std::max<size_t>(1, (size_t)std::lround(kFadeInSeconds * rate));
  size_t out = std::max<size_t>(1, (size_t)std::lround(kFadeOutSeconds * rate));
  if (in + out > n) {
    in = std::max<size_t>(1, n * in / (in + out));
    out = std::max<size_t>(1, n - in);
  }
  for (size_t i = 0; i < in && i < n; ++i) s[i] *= raised_cosine((float)i / in);
  for (size_t i = 0; i < out && i < n; ++i) s[n - 1 - i] *= raised_cosine((float)i / out);
}
}  // namespace fa::mac::speech_audio
