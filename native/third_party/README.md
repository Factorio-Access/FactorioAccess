# Third-party code

Vendored so the repository builds without network access. Only what the build uses is committed.

- `Detours/`: Microsoft Detours, MIT. Source only (`src/`, licence files), copied from grimdark's vendored copy (upstream github.com/microsoft/Detours commit d644ce94e8c7f7f5a31591577c78134ea3ac1fae). Built as a static library by CMake.
- `prism/`: the prism speech SDK v0.18.1 prebuilt release, MPL-2.0 (see `NOTICE` and `LICENSES/`). Committed: `include/`, `windows/x64/lib/prism.lib`, `windows/x64/bin/prism.dll`. The release also has Linux and macOS builds; bring those in when those platform layers exist. `prism.dll` is delay-loaded from next to `fa_native.dll`.
- `miniaudio/`: single-file audio libraries used by `src/audio/`, copied from the launcher's launcher-audio package (`fa_launcher_audio/`): miniaudio v0.11.23 (public domain or MIT-0), dr_wav v0.14.1, dr_flac v0.13.2 and dr_mp3 v0.7.2 (public domain or MIT-0), stb_vorbis v1.22 (public domain or MIT). Licence text is at the end of each file. Their implementations are compiled once, in `src/audio/miniaudio_impl.c`. `src/audio/panner_node.c`/`.h` also come from launcher-audio (zlib, Factorio Access contributors).
