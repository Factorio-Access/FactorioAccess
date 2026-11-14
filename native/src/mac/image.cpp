#include "mac/image.h"
#include <cxxabi.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <algorithm>
#include <cstdlib>
#include <cstring>
#include "log.h"

namespace fa::mac::image {
namespace {
struct Sym {
  std::string_view name;  // mangled, leading '_' removed
  uintptr_t addr;
};
std::vector<Sym> g_by_name, g_by_addr;
uintptr_t g_slide = 0, g_text_lo = 0, g_text_hi = 0;
}  // namespace

uintptr_t slide() { return g_slide; }
bool in_text(uintptr_t a) { return a >= g_text_lo && a < g_text_hi; }

bool init() {
  const mach_header_64* hdr = nullptr;
  for (uint32_t i = 0; i < _dyld_image_count(); ++i) {
    auto* h = reinterpret_cast<const mach_header_64*>(_dyld_get_image_header(i));
    if (h && h->magic == MH_MAGIC_64 && h->filetype == MH_EXECUTE) {
      hdr = h;
      g_slide = (uintptr_t)_dyld_get_image_vmaddr_slide(i);
      log::writef("image: {} (slide {:#x})", _dyld_get_image_name(i), g_slide);
      break;
    }
  }
  if (!hdr) {
    log::write("image: no main executable");
    return false;
  }
  const segment_command_64* linkedit = nullptr;
  const symtab_command* symtab = nullptr;
  auto* lc = reinterpret_cast<const load_command*>(hdr + 1);
  for (uint32_t i = 0; i < hdr->ncmds; ++i, lc = reinterpret_cast<const load_command*>(reinterpret_cast<const char*>(lc) + lc->cmdsize)) {
    if (lc->cmd == LC_SEGMENT_64) {
      auto* seg = reinterpret_cast<const segment_command_64*>(lc);
      if (!std::strncmp(seg->segname, SEG_TEXT, 16)) {
        g_text_lo = seg->vmaddr + g_slide;
        g_text_hi = g_text_lo + seg->vmsize;
      } else if (!std::strncmp(seg->segname, SEG_LINKEDIT, 16)) {
        linkedit = seg;
      }
    } else if (lc->cmd == LC_SYMTAB) {
      symtab = reinterpret_cast<const symtab_command*>(lc);
    }
  }
  if (!linkedit || !symtab) {
    log::write("image: no symbol table");
    return false;
  }
  const char* base = reinterpret_cast<const char*>(linkedit->vmaddr + g_slide - linkedit->fileoff);
  auto* syms = reinterpret_cast<const nlist_64*>(base + symtab->symoff);
  const char* strings = base + symtab->stroff;
  g_by_name.reserve(symtab->nsyms);
  for (uint32_t i = 0; i < symtab->nsyms; ++i) {
    const nlist_64& s = syms[i];
    if ((s.n_type & N_STAB) || (s.n_type & N_TYPE) != N_SECT || !s.n_value) continue;
    const char* n = strings + s.n_un.n_strx;
    if (*n == '_') ++n;
    g_by_name.push_back({n, (uintptr_t)(s.n_value + g_slide)});
  }
  g_by_addr = g_by_name;
  std::sort(g_by_name.begin(), g_by_name.end(), [](const Sym& a, const Sym& b) { return a.name < b.name; });
  std::sort(g_by_addr.begin(), g_by_addr.end(), [](const Sym& a, const Sym& b) { return a.addr < b.addr; });
  log::writef("image: {} symbols", g_by_name.size());
  return !g_by_name.empty();
}

std::vector<std::pair<std::string_view, uintptr_t>> with_prefix(std::string_view prefix) {
  std::vector<std::pair<std::string_view, uintptr_t>> out;
  auto it = std::lower_bound(g_by_name.begin(), g_by_name.end(), prefix, [](const Sym& s, std::string_view p) { return s.name < p; });
  for (; it != g_by_name.end() && it->name.starts_with(prefix); ++it) out.emplace_back(it->name, it->addr);
  return out;
}

uintptr_t exact(std::string_view mangled) {
  auto it = std::lower_bound(g_by_name.begin(), g_by_name.end(), mangled, [](const Sym& s, std::string_view p) { return s.name < p; });
  return it != g_by_name.end() && it->name == mangled ? it->addr : 0;
}

std::pair<std::string_view, uintptr_t> nearest(uintptr_t addr) {
  auto it = std::upper_bound(g_by_addr.begin(), g_by_addr.end(), addr, [](uintptr_t a, const Sym& s) { return a < s.addr; });
  if (it == g_by_addr.begin()) return {{}, 0};
  --it;
  return {it->name, addr - it->addr};
}

std::string demangle(std::string_view mangled) {
  std::string m(mangled);
  int status = 0;
  char* d = abi::__cxa_demangle(m.c_str(), nullptr, nullptr, &status);
  if (!d) return std::string(mangled);
  std::string out(d);
  std::free(d);
  return out;
}

std::string mangle_type(std::string_view q) {
  std::vector<std::string_view> parts;
  for (size_t p; (p = q.find("::")) != std::string_view::npos; q.remove_prefix(p + 2)) parts.push_back(q.substr(0, p));
  parts.push_back(q);
  std::string out = parts.size() > 1 ? "N" : "";
  for (auto part : parts) out += std::to_string(part.size()) + std::string(part);
  if (parts.size() > 1) out += "E";
  return out;
}
}  // namespace fa::mac::image
