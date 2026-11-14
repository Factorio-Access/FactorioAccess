// fa::update on macOS: the same check as win/update_check.cpp, fetched with NSURLSession. The decisions are shared
// (update/check.h).
#import <Foundation/Foundation.h>
#include <atomic>
#include <cstdlib>
#include <mutex>
#include <string>
#include "fa_version.h"
#include "log.h"
#include "speech.h"
#include "update/check.h"
#include "update_check.h"

namespace fa::update {
namespace {
constexpr NSUInteger kMaxBody = 1 << 20;
std::mutex g_mu;
std::string g_pending;  // the line to speak, set by the completion handler, taken by tick() (under g_mu)
Settle g_settle;
NSURLSessionDataTask* g_task;  // under g_mu
bool g_started = false;
}  // namespace

void tick(bool on_main_menu, double now) {
  if (!g_settle.ready(on_main_menu, now)) return;
  std::string line;
  {
    std::lock_guard l(g_mu);
    line.swap(g_pending);
  }
  if (line.empty()) return;
  log::write("update: announced on the main menu");
  speech::speak(line, false);
}

void start() {
  log::writef("fa_native: version {}", kVersion);
  if (channel_of(kVersion) == Channel::None || g_started) return;
  g_started = true;
  @autoreleasepool {
    // FA_UPDATE_HOST (dev) replaces the host, e.g. "nonexistent.invalid" to exercise the offline path.
    const char* host_env = std::getenv("FA_UPDATE_HOST");
    std::string host = host_env && *host_env ? host_env : "api.github.com";
    std::string url = "https://" + host + request_path(channel_of(kVersion));
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@(url.c_str())]];
    req.timeoutInterval = 10;
    [req setValue:@"application/vnd.github+json" forHTTPHeaderField:@"Accept"];
    [req setValue:@"2022-11-28" forHTTPHeaderField:@"X-GitHub-Api-Version"];
    [req setValue:@(("FactorioAccess/" + std::string(kVersion)).c_str()) forHTTPHeaderField:@"User-Agent"];
    NSURLSessionConfiguration* cfg = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:cfg];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:req
                                            completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                                              if (error) {
                                                log::writef("update: request failed: {}", error.localizedDescription.UTF8String);
                                                return;
                                              }
                                              long status = [response isKindOfClass:[NSHTTPURLResponse class]]
                                                                ? ((NSHTTPURLResponse*)response).statusCode
                                                                : 0;
                                              if (status != 200 || !data || data.length > kMaxBody) {
                                                log::writef("update: GitHub answered {}", status);
                                                return;
                                              }
                                              std::string body((const char*)data.bytes, data.length);
                                              std::string_view mine = kVersion;
                                              Verdict v = decide(mine, body);
                                              log::writef("update: installed {}, newer={} latest='{}'", mine, v.newer, v.latest);
                                              if (!v.newer) return;
                                              std::lock_guard l(g_mu);
                                              g_pending = announcement(mine, v);
                                            }];
    {
      std::lock_guard l(g_mu);
      g_task = task;
    }
    [task resume];
    [session finishTasksAndInvalidate];
  }
}

void shutdown() {
  std::lock_guard l(g_mu);
  [g_task cancel];
  g_task = nil;
}
}  // namespace fa::update
