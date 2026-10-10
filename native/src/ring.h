#pragma once
#include <deque>
#include <mutex>
#include <string>
#include <vector>

// A bounded ring of lines with stable monotonic indices, so a client can ask "everything since N".
class LineRing {
 public:
  explicit LineRing(size_t cap = 1000) : cap_(cap) {}
  void push(std::string line) {
    std::lock_guard lk(mu_);
    lines_.push_back(std::move(line));
    ++next_;
    while (lines_.size() > cap_) { lines_.pop_front(); ++first_; }
  }
  // Returns lines with index >= since and the cursor to pass next time.
  std::pair<std::vector<std::pair<uint64_t, std::string>>, uint64_t> since(uint64_t s) {
    std::lock_guard lk(mu_);
    std::vector<std::pair<uint64_t, std::string>> out;
    uint64_t start = s < first_ ? first_ : s;
    for (uint64_t i = start; i < next_; ++i) out.emplace_back(i, lines_[i - first_]);
    return {out, next_};
  }
  uint64_t cursor() { std::lock_guard lk(mu_); return next_; }
 private:
  std::mutex mu_;
  std::deque<std::string> lines_;
  uint64_t first_ = 0, next_ = 0;
  size_t cap_;
};
