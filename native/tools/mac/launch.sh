#!/bin/sh
# Start the Steam copy of Factorio with the native library loaded.
#
#   tools/mac/launch.sh [path/to/libfa_native.dylib]
#
# The default library is this checkout's build (native/build/mac). Steam must be running. SteamAppId stops the game
# from restarting itself through Steam, which would drop the library. DYLD_INSERT_LIBRARIES is set here, right
# before the game starts, because macOS strips DYLD_* variables when a protected binary such as /bin/sh is started.
here=$(cd "$(dirname "$0")" && pwd)
lib=${1:-$here/../../build/mac/libfa_native.dylib}
game="$HOME/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents/MacOS/factorio"
[ -f "$lib" ] || { echo "no library at $lib (build it first)" >&2; exit 1; }
[ -x "$game" ] || { echo "no game at $game" >&2; exit 1; }
export SteamAppId=427520 SteamGameId=427520
export DYLD_INSERT_LIBRARIES="$lib"
exec "$game"
