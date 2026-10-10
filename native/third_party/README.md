# Third-party code

Vendored so the repository builds without network access. Only what the build uses is committed.

- `Detours/`: Microsoft Detours, MIT. Source only (`src/`, licence files), copied from grimdark's vendored copy (upstream github.com/microsoft/Detours commit d644ce94e8c7f7f5a31591577c78134ea3ac1fae). Built as a static library by CMake.
- `prism/`: the prism speech SDK v0.18.1 prebuilt release, MPL-2.0 (see `NOTICE` and `LICENSES/`). Committed: `include/`, `windows/x64/lib/prism.lib`, `windows/x64/bin/prism.dll`. The release also has Linux and macOS builds; bring those in when those platform layers exist. `prism.dll` is delay-loaded from next to `fa_native.dll`.
