#include "devserver.h"
#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <atomic>
#include <format>
#include <map>
#include <memory>
#include <string>
#include <thread>
#include "agui.h"
#include "app.h"
#include "audio/audio.h"
#include "hooks.h"
#include "input.h"
#include "log.h"
#include "lua_native.h"
#include "speech.h"

namespace fa::dev {
using Query = std::map<std::string, std::string>;

static std::atomic<bool> g_run{false};
static SOCKET g_listen = INVALID_SOCKET;
static std::thread g_thread;

static std::string url_decode(std::string_view s) {
  std::string o;
  for (size_t i = 0; i < s.size(); ++i) {
    if (s[i] == '+') o += ' ';
    else if (s[i] == '%' && i + 2 < s.size()) {
      o += (char)strtol(std::string(s.substr(i + 1, 2)).c_str(), nullptr, 16);
      i += 2;
    } else o += s[i];
  }
  return o;
}

static Query parse_query(std::string_view q) {
  Query m;
  size_t p = 0;
  while (p <= q.size()) {
    size_t e = q.find('&', p);
    if (e == std::string_view::npos) e = q.size();
    std::string_view kv = q.substr(p, e - p);
    size_t eq = kv.find('=');
    if (!kv.empty()) m[url_decode(kv.substr(0, eq))] = eq == std::string_view::npos ? "1" : url_decode(kv.substr(eq + 1));
    p = e + 1;
  }
  return m;
}

static bool truthy(const std::string& s) { return s == "1" || s == "true" || s == "on" || s == "yes"; }
static std::string arg(const Query& q, const char* k, std::string def = {}) {
  auto it = q.find(k);
  return it == q.end() ? def : it->second;
}

static std::string ring_since(LineRing& ring, const Query& q) {
  auto [lines, next] = ring.since(strtoull(arg(q, "since", "0").c_str(), nullptr, 10));
  std::string out = std::format("cursor: {}\n", next);
  for (auto& [i, l] : lines) out += std::format("{}: {}\n", i, l);
  return out;
}

// One line per widget, indented by depth: class, flags, rect, text. Hidden subtrees are skipped unless all=1;
// private children (a widget's implementation parts) are marked with '~'.
static void dump_tree(agui::Widget* w, int depth, bool all, std::string& out) {
  bool vis = agui::visible(w);
  if (!vis && !all) return;
  auto r = agui::rect(w);
  std::string t = agui::text(w);
  std::string st = agui::style_name(w);
  out += std::format("{}{} {:#x}{}{}{}{}{} [{},{} {}x{}]{}{}\n", std::string(depth * 2, ' '), agui::class_name(w), (uintptr_t)w, vis ? "" : " hidden",
                     agui::enabled(w) ? "" : " disabled", w == agui::focused() ? " FOCUSED" : "", st.empty() ? "" : " style=", st, r.x, r.y, r.w, r.h, t.empty() ? "" : " ",
                     t);
  for (auto* c : agui::children(w)) dump_tree(c, depth + 1, all, out);
  for (auto* c : agui::private_children(w)) {
    out += std::string(depth * 2 + 2, ' ') + "~\n";
    dump_tree(c, depth + 1, all, out);
  }
}

// Key names -> SDL scancodes. Letters and digits by themselves ("a", "7").
static int scancode(const std::string& name) {
  static const std::map<std::string, int> k = {
      {"enter", 40}, {"return", 40}, {"escape", 41}, {"esc", 41}, {"backspace", 42}, {"tab", 43}, {"space", 44}, {"minus", 45},
      {"equals", 46}, {"lbracket", 47}, {"rbracket", 48}, {"backslash", 49}, {"semicolon", 51}, {"apostrophe", 52}, {"grave", 53},
      {"comma", 54}, {"period", 55}, {"slash", 56}, {"f1", 58}, {"f2", 59}, {"f3", 60}, {"f4", 61}, {"f5", 62}, {"f6", 63},
      {"f7", 64}, {"f8", 65}, {"f9", 66}, {"f10", 67}, {"f11", 68}, {"f12", 69}, {"insert", 73}, {"home", 74}, {"pageup", 75},
      {"delete", 76}, {"end", 77}, {"pagedown", 78}, {"right", 79}, {"left", 80}, {"down", 81}, {"up", 82},
  };
  if (name.size() == 1 && name[0] >= 'a' && name[0] <= 'z') return 4 + (name[0] - 'a');
  if (name.size() == 1 && name[0] >= '1' && name[0] <= '9') return 30 + (name[0] - '1');
  if (name == "0") return 39;
  auto it = k.find(name);
  return it == k.end() ? -1 : it->second;
}

static std::string handle(const std::string& path, const Query& q, int& status) {
  status = 200;
  if (path == "/health")
    return std::format("ok pid={} frame={} backend={} muted={} audio_commands={}\n", GetCurrentProcessId(), hooks::frame(), speech::backend_name(),
                       speech::muted(), lua::audio_commands());
  if (path == "/log") return ring_since(log::ring(), q);
  if (path == "/speech") return ring_since(speech::history(), q);
  if (path == "/say") {
    speech::speak(arg(q, "text"), true);
    return "ok\n";
  }
  if (path == "/mute") {
    speech::set_muted(truthy(arg(q, "on", "1")));
    return std::format("muted={}\n", speech::muted());
  }
  if (path == "/key") {  // press and release, as two real SDL events
    int sc = scancode(arg(q, "name"));
    if (sc < 0) {
      status = 400;
      return "unknown key name\n";
    }
    bool shift = truthy(arg(q, "shift")), ctrl = truthy(arg(q, "ctrl")), alt = truthy(arg(q, "alt"));
    // The release comes a few frames later: a press and release inside one poll is invisible to code that
    // samples key state per frame.
    if (!hooks::push_key(sc, true, shift, ctrl, alt)) return "not ready (no SDL window yet)\n";
    std::thread([=] {
      Sleep(60);
      hooks::push_key(sc, false, shift, ctrl, alt);
    }).detach();
    return "ok\n";
  }
  if (path == "/keys") return hooks::push_text(arg(q, "text")) ? "ok\n" : "not ready\n";
  if (path == "/own") {  // dev override of who owns the keyboard; the UI tick decides again on its next change
    if (q.count("on")) input::set_owned(truthy(arg(q, "on")));
    return std::format("keyboard={}\n", input::owned() ? "native" : "game");
  }
  if (path == "/ui/click") {  // ?addr=0x... from /ui/tree
    auto* w = reinterpret_cast<agui::Widget*>(strtoull(arg(q, "addr").c_str(), nullptr, 16));
    if (!agui::in_tree(w)) {
      status = 400;
      return "not a widget in the current tree\n";
    }
    agui::click(w);
    return "clicked\n";
  }
  if (path == "/audio") {  // ?json=<one command, as the mod sends it>
    audio::submit(arg(q, "json"));
    return "submitted\n";
  }
  if (path == "/ui/nav") return app::dump();
  if (path == "/ui/tree") {
    agui::Widget* root = agui::root();
    if (!root) return "no gui\n";
    std::string out;
    dump_tree(root, 0, truthy(arg(q, "all", "0")), out);
    return out;
  }
  status = 404;
  return "unknown route\n";
}

// SEH guard: routes read game memory through layouts we derived; a fault must not take the game down.
// No C++ objects with destructors may live in the __try function itself.
struct JobCtx {
  const std::string* path;
  const Query* q;
  int* status;
  std::string* out;
};
static void run_job(JobCtx* c) { *c->out = handle(*c->path, *c->q, *c->status); }
static int seh_filter(EXCEPTION_POINTERS* ep, void** addr, DWORD* code) {
  *addr = ep->ExceptionRecord->ExceptionAddress;
  *code = ep->ExceptionRecord->ExceptionCode;
  return EXCEPTION_EXECUTE_HANDLER;
}
static DWORD run_job_seh(JobCtx* c, void** addr) {
  DWORD code = 0;
  __try {
    run_job(c);
  } __except (seh_filter(GetExceptionInformation(), addr, &code)) {
  }
  return code;
}
static std::string module_offset(void* addr) {
  HMODULE m = nullptr;
  GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCWSTR)addr, &m);
  if (!m) return std::format("{}", addr);
  char path[MAX_PATH];
  GetModuleFileNameA(m, path, MAX_PATH);
  const char* base = strrchr(path, '\\');
  base = base ? base + 1 : path;
  return std::format("{}+{:#x}", base, (uintptr_t)addr - (uintptr_t)m);
}

static void serve(SOCKET c) {
  std::string req;
  char buf[4096];
  while (req.find("\r\n\r\n") == std::string::npos) {
    int n = recv(c, buf, sizeof buf, 0);
    if (n <= 0) return;
    req.append(buf, n);
    if (req.size() > 1 << 20) return;
  }
  std::string head = req.substr(0, req.find("\r\n\r\n"));
  size_t sp1 = head.find(' '), sp2 = head.find(' ', sp1 + 1);
  std::string target = head.substr(sp1 + 1, sp2 - sp1 - 1);
  size_t qm = target.find('?');
  // The job owns its state: a route that outlives the timeout still runs later on the main thread.
  struct Owned {
    std::string path;
    Query query;
    int status = 500;
    std::string out;
  };
  auto owned = std::make_shared<Owned>();
  owned->path = target.substr(0, qm);
  owned->query = parse_query(qm == std::string::npos ? "" : target.substr(qm + 1));
  bool ran = hooks::run_on_main_thread(
      [owned] {
        JobCtx ctx{&owned->path, &owned->query, &owned->status, &owned->out};
        void* addr = nullptr;
        if (DWORD code = run_job_seh(&ctx, &addr)) {
          owned->status = 500;
          owned->out = std::format("route faulted: exception {:#x} at {}\n", code, module_offset(addr));
          log::write(owned->out);
        }
      },
      8000);
  int status = 504;
  std::string out = "the main thread did not run the job within 8 s\n";
  if (ran) {
    status = owned->status;
    out = owned->out;
  }
  std::string resp = std::format("HTTP/1.1 {} {}\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: {}\r\nConnection: close\r\n\r\n", status,
                                 status == 200 ? "OK" : "ERR", out.size()) +
                     out;
  send(c, resp.data(), (int)resp.size(), 0);
}

static void loop(int port) {
  WSADATA w;
  WSAStartup(MAKEWORD(2, 2), &w);
  g_listen = socket(AF_INET, SOCK_STREAM, 0);
  sockaddr_in a{};
  a.sin_family = AF_INET;
  a.sin_port = htons((u_short)port);
  a.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  if (bind(g_listen, (sockaddr*)&a, sizeof a) != 0 || listen(g_listen, 8) != 0) {
    log::writef("devserver: bind/listen on {} failed: {}", port, WSAGetLastError());
    return;
  }
  log::writef("devserver: listening on 127.0.0.1:{}", port);
  while (g_run) {
    SOCKET c = accept(g_listen, nullptr, nullptr);
    if (c == INVALID_SOCKET) break;
    DWORD to = 10000;
    setsockopt(c, SOL_SOCKET, SO_RCVTIMEO, (const char*)&to, sizeof to);
    serve(c);
    closesocket(c);
  }
}

void start(int port) {
  if (g_run) return;
  g_run = true;
  g_thread = std::thread(loop, port);
}

void stop() {
  g_run = false;
  if (g_listen != INVALID_SOCKET) {
    closesocket(g_listen);
    g_listen = INVALID_SOCKET;
  }
  if (g_thread.joinable()) g_thread.join();
}
}  // namespace fa::dev
