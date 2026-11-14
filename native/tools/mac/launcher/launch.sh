#!/bin/sh
# Starts Factorio with Factorio Access's native code on an Apple Silicon Mac. The installer puts this script, the
# libraries and FactorioAccess.app in ~/Library/Application Support/FactorioAccess, and sets the game's Steam
# launch option (Properties, General, Launch Options) to:
#
#   "/Users/<you>/Library/Application Support/FactorioAccess/FactorioAccess.app" %command%
#
# Why a bundle and `open` (the lessons of NonVisualCalculus' run-modded.sh):
#
# - Steam on macOS does not run launch options through a shell, so DYLD_INSERT_LIBRARIES can only be set by a program
#   it starts. %command% expands to the game's .app bundle.
# - Steam spawns a script launch option as x86_64 (Rosetta), but opens an app bundle through LaunchServices natively,
#   so the launch option names FactorioAccess.app, which only runs this script with --open.
# - That bundle must not exec the game: a process LaunchServices started as one bundle that then becomes another never
#   gets keyboard focus. open(1) starts the game's own bundle as Steam would, with the library and every Steam*
#   variable (so the Steam API finds its app id and does not restart the game without the library), and waits for it
#   to quit so Steam shows the game as running.
# - Steam's overlay comes in through DYLD_INSERT_LIBRARIES too (STEAM_DYLD_INSERT_LIBRARIES when it hands the launch
#   to a program); it stays, after ours.
#
# Whatever goes wrong, the game starts: without Factorio Access when the library is missing or the Mac is not Apple
# Silicon. Without --open (from a terminal) the game runs in this process, which is fine for testing.
set -eu

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; here=$(cd "$a" || exit 1; pwd -P)

launch=exec
if [ "${1:-}" = "--open" ]; then
    launch=open
    shift
fi
target="${1:-$HOME/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app}"
[ $# -gt 0 ] && shift
case "$target" in
    *.app)
        app="$target"
        executable="$app/Contents/MacOS/$(defaults read "$app/Contents/Info" CFBundleExecutable)"
        ;;
    *)
        executable="$target"
        app="$(cd "$(dirname "$executable")/../.." && pwd -P)"
        ;;
esac
if [ ! -x "$executable" ]; then
    echo "Factorio not found: $executable" >&2
    exit 1
fi

start_unmodded() {
    echo "$1; starting Factorio without Factorio Access" >&2
    shift
    if [ "$launch" = open ]; then
        exec open -W "$app"
    fi
    exec "$executable" "$@"
}

if [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" != 1 ]; then
    start_unmodded "Factorio Access needs an Apple Silicon Mac" "$@"
fi
lib="$here/libfa_native.dylib"
if [ ! -f "$lib" ]; then
    start_unmodded "$lib is missing" "$@"
fi

inherited="${DYLD_INSERT_LIBRARIES:-${STEAM_DYLD_INSERT_LIBRARIES:-}}"
insert="$lib${inherited:+:$inherited}"

if [ "$launch" = open ]; then
    set -- --arch arm64 --env "DYLD_INSERT_LIBRARIES=$insert"
    for name in $(env | sed -n 's/^\(Steam[A-Za-z0-9_]*\)=.*/\1/p; s/^\(FA_[A-Za-z0-9_]*\)=.*/\1/p'); do
        set -- "$@" --env "$name=$(printenv "$name")"
    done
    exec open -W "$@" "$app"
fi

export DYLD_INSERT_LIBRARIES="$insert"
exec arch -arm64 -e DYLD_INSERT_LIBRARIES="$insert" "$executable" "$@"
