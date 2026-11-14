#pragma once
// The game's own standard-library types as they sit in its memory. The Mac game links its own libc++ statically
// (Homebrew clang 16), so these are read by layout rather than through our libc++, which may be a different build.
#include <cstdint>
#include <cstring>
#include <string>

namespace fa::mac::abi {
// libc++ std::string, default layout on little-endian 64-bit: long mode when the top bit of byte 23 is set
// ({data, size, capacity|flag}); otherwise up to 22 chars inline with the size in byte 23.
struct String {
  unsigned char raw[24];
  bool is_long() const { return raw[23] & 0x80; }
  std::string str() const {
    if (is_long()) {
      const char* data;
      size_t size;
      std::memcpy(&data, raw, 8);
      std::memcpy(&size, raw + 8, 8);
      return std::string(data, size);
    }
    return std::string(reinterpret_cast<const char*>(raw), raw[23] & 0x7f);
  }
};
static_assert(sizeof(String) == 24);

// libc++ std::vector<T>: begin, end, end of storage.
template <typename T>
struct Vector {
  T* first;
  T* last;
  T* end;
  size_t size() const { return last - first; }
};
}  // namespace fa::mac::abi
