#include "assets.h"
#include <cstring>
#include <filesystem>
#include <fstream>
#include <map>
#include <mutex>
#include "log.h"
#include "sym.h"

namespace fa::assets {
namespace {
std::mutex g_mu;
std::filesystem::path g_package;  // empty until the game told us
bool g_is_zip = false;

struct ZipEntry {
  uint32_t local_offset;
  uint32_t compressed;
  uint32_t size;
  uint16_t method;  // 0 stored, 8 deflate
};
std::map<std::string, ZipEntry> g_zip;  // keyed by the path below the zip's top folder, '/' separated

// ---- zlib, as linked into the game (no inflateEnd there: the stream allocates through our zalloc/zfree) ----
struct ZStream {  // z_stream_s, 64-bit Windows layout (checked against the PDB at init)
  const unsigned char* next_in;
  unsigned avail_in;
  unsigned long total_in;
  unsigned char* next_out;
  unsigned avail_out;
  unsigned long total_out;
  char* msg;
  void* state;
  void* (*zalloc)(void*, unsigned, unsigned);
  void (*zfree)(void*, void*);
  void* opaque;
  int data_type;
  unsigned long adler;
  unsigned long reserved;
};
using InflateInit2_t = int (*)(ZStream*, int, const char*, int);
using Inflate_t = int (*)(ZStream*, int);
InflateInit2_t g_inflate_init;
Inflate_t g_inflate;
constexpr int kZFinish = 4, kZStreamEnd = 1;

struct Arena {
  std::vector<void*> blocks;
  ~Arena() {
    for (void* b : blocks) free(b);
  }
};
void* arena_alloc(void* opaque, unsigned n, unsigned size) {
  void* p = calloc(n, size);
  static_cast<Arena*>(opaque)->blocks.push_back(p);
  return p;
}
void arena_free(void*, void*) {}  // released with the arena

bool inflate_raw(const uint8_t* in, size_t in_size, uint8_t* out, size_t out_size) {
  Arena arena;
  ZStream z{};
  z.next_in = in;
  z.avail_in = (unsigned)in_size;
  z.next_out = out;
  z.avail_out = (unsigned)out_size;
  z.zalloc = arena_alloc;
  z.zfree = arena_free;
  z.opaque = &arena;
  // -15: a raw deflate stream (zip entries carry no zlib header). zlib checks only the version's first digit.
  if (g_inflate_init(&z, -15, "1.3.1", (int)sizeof(ZStream)) != 0) return false;
  return g_inflate(&z, kZFinish) == kZStreamEnd && z.total_out == out_size;
}

template <typename T>
T le(const uint8_t* p) {
  T v;
  memcpy(&v, p, sizeof v);
  return v;
}

// Index the zip's central directory. Factorio mod zips hold one top folder ("FactorioAccess_0.16.57/");
// entries are keyed below it.
bool index_zip(const std::filesystem::path& zip) {
  std::ifstream f(zip, std::ios::binary);
  if (!f) return false;
  f.seekg(0, std::ios::end);
  size_t size = (size_t)f.tellg();
  size_t tail = size < 65557 ? size : 65557;  // end-of-central-directory record + maximum comment
  std::vector<uint8_t> buf(tail);
  f.seekg(size - tail);
  f.read((char*)buf.data(), tail);
  size_t eocd = std::string::npos;
  for (size_t i = tail - 22 + 1; i-- > 0;)
    if (le<uint32_t>(&buf[i]) == 0x06054b50) {
      eocd = i;
      break;
    }
  if (eocd == std::string::npos) return false;
  uint16_t count = le<uint16_t>(&buf[eocd + 10]);
  uint32_t cd_size = le<uint32_t>(&buf[eocd + 12]), cd_offset = le<uint32_t>(&buf[eocd + 16]);
  std::vector<uint8_t> cd(cd_size);
  f.seekg(cd_offset);
  f.read((char*)cd.data(), cd_size);
  size_t p = 0;
  for (uint16_t i = 0; i < count && p + 46 <= cd.size(); ++i) {
    if (le<uint32_t>(&cd[p]) != 0x02014b50) return false;
    ZipEntry e{le<uint32_t>(&cd[p + 42]), le<uint32_t>(&cd[p + 20]), le<uint32_t>(&cd[p + 24]), le<uint16_t>(&cd[p + 10])};
    uint16_t name_len = le<uint16_t>(&cd[p + 28]), extra = le<uint16_t>(&cd[p + 30]), comment = le<uint16_t>(&cd[p + 32]);
    std::string name((const char*)&cd[p + 46], name_len);
    size_t slash = name.find('/');
    if (slash != std::string::npos && !name.ends_with('/')) g_zip[name.substr(slash + 1)] = e;
    p += 46 + name_len + extra + comment;
  }
  return true;
}

std::optional<std::vector<uint8_t>> read_zip(const std::string& key) {
  auto it = g_zip.find(key);
  if (it == g_zip.end()) return std::nullopt;
  const ZipEntry& e = it->second;
  std::ifstream f(g_package, std::ios::binary);
  uint8_t local[30];
  f.seekg(e.local_offset);
  f.read((char*)local, sizeof local);
  if (!f || le<uint32_t>(local) != 0x04034b50) return std::nullopt;
  f.seekg(e.local_offset + 30 + le<uint16_t>(&local[26]) + le<uint16_t>(&local[28]));
  std::vector<uint8_t> packed(e.compressed);
  f.read((char*)packed.data(), packed.size());
  if (!f) return std::nullopt;
  if (e.method == 0) return packed;
  if (e.method != 8) return std::nullopt;
  std::vector<uint8_t> out(e.size);
  if (!inflate_raw(packed.data(), packed.size(), out.data(), out.size())) return std::nullopt;
  return out;
}

std::string normalise(std::string_view name) {
  std::string s(name);
  for (char& c : s)
    if (c == '\\') c = '/';
  return s;
}
}  // namespace

bool init() {
  g_inflate_init = sym::fn<InflateInit2_t>("inflateInit2_");
  g_inflate = sym::fn<Inflate_t>("inflate");
  auto zsize = sym::type_size("z_stream_s");
  bool ok = g_inflate_init && g_inflate && zsize && *zsize == sizeof(ZStream);
  if (!ok) log::write("assets: the game's zlib does not match; zip packages cannot be read");
  return ok;
}

void set_package(const std::wstring& path) {
  std::lock_guard lk(g_mu);
  std::filesystem::path p(path);
  if (p == g_package) return;
  g_package = p;
  g_zip.clear();
  g_is_zip = p.extension() == L".zip";
  bool ok = !g_is_zip || index_zip(p);
  log::writef("assets: package {} ({}, {})", p.string(), g_is_zip ? "zip" : "directory", ok ? "ok" : "UNREADABLE");
}

std::optional<std::vector<uint8_t>> read(std::string_view name) {
  std::lock_guard lk(g_mu);
  if (g_package.empty()) return std::nullopt;
  std::string key = normalise(name);
  if (g_is_zip) return read_zip(key);
  std::ifstream f(g_package / std::filesystem::path(key), std::ios::binary);
  if (!f) return std::nullopt;
  return std::vector<uint8_t>(std::istreambuf_iterator<char>(f), {});
}
}  // namespace fa::assets
