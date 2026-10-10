#pragma once
// Loopback HTTP server for driving and observing the game during development (the dev loop; the client is
// native/tools/fadev.py). Plain-text responses; every route runs on the main thread under an SEH guard.
// Started only when FA_PORT is set: the routes are unauthenticated.
//   /health                 pid, frame, speech backend, mute state
//   /log?since=N            native log lines since cursor N ("cursor: M" first, then "i: text")
//   /speech?since=N         spoken lines since cursor N
//   /say?text=...           speak through the native speech path
//   /mute?on=1|0            mute or unmute speech (history still records)
//   /key?name=enter&shift=1&ctrl=1&alt=1   press+release as real SDL events (names: devserver.cpp scancode())
//   /keys?text=abc          text input as a real SDL event
//   /own?on=1|0             dev override: the native UI owns the keyboard (keys stop reaching the game)
//   /ui/click?addr=0x...    fire a widget's click handlers (address from /ui/tree)
//   /ui/tree?all=1          the agui widget tree: class, address, flags, absolute rect, text (all=1: hidden too)
namespace fa::dev {
void start(int port);  // no-op while running
void stop();
}  // namespace fa::dev
