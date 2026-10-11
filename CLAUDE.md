# FactorioAccess development guide for LLMs

FactorioAccess makes Factorio playable by blind and visually impaired players through speech, audio cues and
keyboard controls. Almost all of it is a normal Factorio mod in Lua. A small native part (`native/`, C++) is
injected into the game process for the few things the modding API cannot do.

Every feature is designed audio first: if it cannot be understood by ear and driven by keyboard, it is not done.

## Critical rules

1. **In a world, native code is the last resort.** Everything outside a world (the main menu and its dialogs:
   new game, load and save, mod sync, settings, the defeat screen) is the native code's job: that is why it
   exists, and no Lua can reach it, so fix accessibility there directly. Inside a world, extend the player-facing
   part of `native/` only when there is no way at all to do the job in Lua with the Factorio API, the launcher, or
   a change of design. It runs only in single player (it reads state local to one machine), so every in-world
   native feature needs a Lua path for multiplayer anyway; when in doubt, it does not go in `native/`. Development
   tooling (the dev server, `fadev.py`, anything that only drives or inspects the game for testing) is exempt: use
   native code freely there; it may break with any Factorio update and nobody minds. See "Native code" below.
2. **Module functions use dot notation**: `Viewpoint.get_viewpoint(pindex)`, never `Viewpoint:get_viewpoint(pindex)`.
3. **Before committing**: `python launch_factorio.py --format`, `python launch_factorio.py --run-tests --timeout 60`,
   `python lint_localisation.py lint`. Native changes also: build, and run `native/build/ninja/faui_tests.exe`.
4. **Debug output goes to the log**: `print("debug")`. Never `game.print` (the GUI is useless to the players).
   User-facing text goes through `Speech.speak(pindex, message)`.
5. **Type annotations use three dashes**: `---@param pindex integer`.
6. **This is Factorio 2.x, not 1.1.** Check every API against `llm-docs/api-reference` before using it (see
   "Factorio API reference").

## Commands

Run from this directory (`mods/FactorioAccess`, inside a portable Factorio install; the game is at `../..`).

```bash
python launch_factorio.py --format              # stylua; required before committing
python launch_factorio.py --format-check
python launch_factorio.py --run-tests --timeout 60
python launch_factorio.py --setup-tools         # once, and after a Factorio update: .tools/ (checker + API library)
python launch_factorio.py --lint                # emmylua_check with the generated Factorio library
python lint_localisation.py lint                # unused / missing locale keys
python build_message_lists.py                   # after editing locale/*/**/*.txt message lists (then --format)
python json_to_markdown.py --type runtime --input ../../doc-html/runtime-api.json --output llm-docs/api-reference
python json_to_markdown.py --type prototype --input ../../doc-html/prototype-api.json --output llm-docs/api-reference
```

Regenerating the API reference after a Factorio update: delete `llm-docs/api-reference/runtime` and
`.../prototypes` first (the generator never removes pages for classes the API dropped), run both commands, commit.

`--setup-tools` needs network once: it downloads pinned emmylua_check and stylua releases (stylua matches CI) and
runs fmtk (`npx factoriomod-debug luals-addon`) on this install's own `doc-html` JSON. `--format` and `--lint` use
only `.tools/`; nothing comes from an editor. The lint config is written to `.tools/emmyrc.json` by
`write_emmyrc` in `launch_factorio.py`; warnings fail the lint, hints are not shown. `need-check-nil` and `strict.arrayIndex` are
off: the project lets a missing value crash rather than checking for it.

Type-checker habits that keep the lint clean:

- Integers are `integer` (indices, counts, `pindex`); Factorio's `uint32` and friends are aliases of it.
- A local initialised with `0` and later given fractions needs `---@type number` above it.
- A local assigned inside a different closure needs its type declared (`---@type LuaEntity`), or it reads as nil.
- `---@class` binds to a `local X = {}` declaration only. Casts are `--[[@as T]]`, no spaces inside.
- `defines` values are opaque in the types: `FaUtils.localise_direction(dir)` for direction names.
- Positions the game returns are typed "struct or array" but are always the struct: cast where they enter,
  `entity.position --[[@as MapPosition.struct]]`. A `Vector` is the opposite, always the array (`fa.VectorArray`).
- An API value typed maybe-nil that cannot be nil here gets `assert(...)` where it enters, never an `if` that skips.
- `MessageBuilder:build()` returns `""` for an empty message; `build_or_nil()` when the caller needs to know.

Don't add a root `.luarc.json` or `.emmyrc.json`: editors pick them up, and they override the editor's own settings
(including its Factorio library).

## Architecture

### Loading stages

1. Settings (`settings.lua`): settings only, no game access.
2. Data (`data.lua`): prototypes only, no runtime access.
3. Runtime (`control.lua`): event-driven gameplay.

Never touch `game`, `script` or `storage` from the settings or data stage.

### Core patterns

```lua
local player = game.get_player(pindex)
local player_data = storage.players[pindex]

-- Per-player storage with lazy initialisation: my_storage[pindex] is storage.players[pindex].module_name
local my_storage = StorageManager.declare_storage_module("module_name", { --[[ defaults ]] })
```

- In remote view (always the case aboard a space platform) the player has no character as far as the game shows:
  character features (inventory, crafting, equipment, walking, teleporting, mining) refuse or are absent. The engine
  disagrees: `player.character` still returns the parked character, while `player.get_main_inventory()` is nil and
  `player.position` / `player.surface` are the view. Use `FaUtils.controlled_character(player)`, never a bare
  `player.character` check. `player.character` is truly nil only without a body (dead in multiplayer, god, editor).
- Requires only at file top level. No global state beyond the current file.
- Check `player and player.valid` at entry points; see "Defensive coding" for everywhere else.
- `prototypes.recipe["name"]`, not `game.recipe_prototypes`. There is no `game.create_player()`.
- Imports are CamelCase: `local FaUtils = require("scripts.fa-utils")`.

### Speech and MessageBuilder

```lua
local message = Speech.MessageBuilder.new()
message:fragment({ "entity-name.transport-belt" })
message:fragment({ "fa.direction", "north" })
Speech.speak(pindex, message:build())
```

`MessageBuilder` (in `scripts/speech.lua`) places the spaces itself: `fragment(" ")` crashes on purpose. Use
`list_item()` for commas. `scripts/localising.lua` has name fallbacks and other localisation helpers. Read both
before writing user-facing text.

`Speech.speak` goes through the native code when it is available (single player with the DLL) and otherwise
prints `out <pindex> <message>` to stdout for the external launcher. Callers do not care which.

Writing for a screen reader:

- The sooner the message varies, the sooner the player can move on: "anchored cursor" / "unanchored cursor",
  not "cursor anchored" / "cursor unanchored".
- No `:` `(` `)`: many screen reader setups read them aloud. Commas (`list_item`) and periods are fine.
- No em dashes, no Unicode symbols, no verbosity.
- Locale keys live in section `fa` and never contain `.`: `fa.foo-bar`, not `fa.foo.bar`.
- Prefer one parameterised locale key over `fragment({"fa.intro"}):fragment(p1)`, so translations can reorder.

### UI system

Graph-based and React-like: a UI is a description of how to say things, rebuilt on demand; there is no paint
step and no explicit re-render. Controls that change a value say the new value.

- `scripts/ui/router.lua`: the entry point from non-UI code (opening a UI). `Router.UI_NAMES`.
- `scripts/ui/menu.lua` (`Menu.MenuBuilder`), `scripts/ui/form-builder.lua`, `scripts/ui/controls.lua`: building UIs.
- `scripts/ui/grid.lua`: grids. `scripts/ui/tab-list.lua`: `TabList.declare_tablist({ ui_name = ..., tabs = ... })`.

### Scanner

A streaming database of entities and tiles, grouped by spatial clustering and answering fixed queries:
`scripts/scanner/entrypoint.lua`, `scripts/scanner/surface-scanner.lua`, `scripts/scanner/backends/`.

### Syntrax

The rail description language: compiler in `syntrax/` (lexer, parser, compiler, vm), CLI `syntrax-cli.lua`,
runtime wiring in `scripts/rails/` and `scripts/ui/menus/` (router UIs `SYNTRAX_INPUT`, `RAIL_BUILDER`,
`SYNTRAX_PROGRAM`).

### Other files

- `control.lua` is huge: grep it, read it in parts.
- `scripts/fa-utils.lua` utilities, `scripts/fa-info.lua` entity info, `scripts/storage-manager.lua` storage,
  `scripts/event-manager.lua` events (migration in progress).
- `scripts/item-stack-utils.lua`: read it before aggregating items by quality ("legendary solar panel x 5").
- `scripts/inventory-utils.lua`: inventory-like list presentation.

## Common tasks

### Keybinding

1. `data.lua`: a `custom-input`. Names are `fa-<key>` or `fa-<flags>-<key>` with flags from `c`, `a`, `s`
   (`fa-cas-s` is Ctrl+Alt+Shift+S).
2. `control.lua`: `EventManager.on_event("fa-k", function(event, pindex) ... end)`.
3. `locale/en/locale.cfg` under `[controls]`.

### Setting

1. Declare in `scripts/settings-decls.lua` (`name = "fa-my-setting"`, `type`, `setting_type = "runtime-per-user"`,
   `default_value`, `order`).
2. `locale/en/settings.cfg`: `[mod-setting-name]` and `[mod-setting-description]`.
3. Read: `settings.get_player_settings(pindex)["fa-my-setting"].value`.

The FA settings menu builds itself from `settings-decls.lua`.

### Message lists (help and documentation)

1. A `.txt` file anywhere under `locale/<language>/` (e.g. `locale/en/ui-help/my-feature.txt`); messages are
   separated by blank lines, `;` starts a comment. The list's name is the file's basename and must be unique.
2. `python build_message_lists.py`, then `python launch_factorio.py --format` (the generated
   `scripts/message-list-index.lua` comes out with CRLF line endings on Windows, which stylua rejects and git's
   autocrlf hides).
3. In a UI: `get_help_metadata = function(ctx) return { Help.message_list("my-feature") } end`
   (`local Help = require("scripts.ui.help")`). Players open help with Shift+/.

### Test

```lua
local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("Feature", function()
   it("does the thing", function(ctx)
      local value = 42 -- locals, not ctx.state
      ctx:at_tick(5, function()
         ctx:assert_equals(42, value)
      end)
   end)
end)
```

Add the file to `test_files` in `scripts/test-framework.lua`. Test the mod's behaviour, not Factorio's API.

## Native code

`native/` is C++ (CMake, MSVC) injected into `factorio.exe`. It exists for what Lua cannot reach: the main
menus before a world exists, speech without the external launcher, and the engine's own localisation. Anything
outside a world is its job; inside a world, read critical rule 1 again before adding anything players use. The dev
server and other test tooling are exempt.

### What it does

- **Menus**: `native/src/screens/dialogs.cpp` reads the game's widget tree (agui) and builds our own navigation
  graph over it (`native/src/ui/`, ported from grimdark, itself from this mod's key-graph design). Labels,
  state and activation all come from the game's widgets; we add almost no text. While a menu is open the native
  UI owns the keyboard (keys never reach the game); once a world is loaded it lets go entirely.
  Reading rules live in the walker: tables with columns become grids (row and column headers name the cells,
  up/down keep the column), a label beside or above a field/dropdown/slider names it, a label leading a row of
  controls is that row's context, a slider with a value field speaks the field's text. Keys: arrows, Tab, Home/End,
  Enter activates, Escape clicks the dialog's back button, Left/Right adjust a slider or dropdown alone in its row,
  Page Up/Down (Shift for more) adjust anywhere, Enter on a slider types a value (into the game's value field
  when it has one), Enter on a text field lends the keyboard to the game until Enter, Escape or Tab.
  Speech is immediate: state a screen changes itself goes through `app::announce_change` (speaks now and
  re-baselines the navigator's live watch); never defer an announcement.
- **Lua bridge**: the `_fa_native` global, installed only into this mod's Lua state (control stage).
  `scripts/native.lua` is the only Lua that touches it. Everything checks `Native.is_available()` (the DLL is
  loaded and the game is single player) and branches; calling anything else while it is false errors.
  `_fa_native.speak(localised_string, interrupt)` localises with the engine immediately and speaks through prism.
  `_fa_native.audio_cmd(json)` takes the same JSON the launcher's audio engine does (`scripts/launcher-audio.lua`
  builds it), so the launcher and the DLL are interchangeable by swapping who parses it.
- **Audio**: `native/src/audio/` is the launcher's `fa_launcher_audio` ported to C++ (miniaudio, the panner
  node, JSON commands), with tests in `native/tests_audio/` (`fa_audio_tests.exe`, runs on miniaudio's null
  backend). It deliberately keeps three quirks of the Python engine the mod's sounds were tuned against (squared
  steady volumes, scheduled fade-outs overridden by the next volume ramp, times converted at 44100 Hz); each is
  commented in `audio.cpp`. Fixing one means retuning the sonifiers by ear.
- **Assets**: `native/src/assets.cpp` reads files from the mod's own package (folder or installed zip, located
  by the engine; zips inflate through the game's own zlib).

### How it loads

- **Playing**: `python native/tools/fadev.py install` copies `version.dll`, `fa_native.dll` and `prism.dll` next to
  `factorio.exe` (`uninstall` removes them). Then just run the game. `version.dll` (`native/src/proxy/`) is a
  proxy: factorio.exe imports VERSION.dll, which is not a KnownDLL, so this copy loads instead of System32's. It
  forwards every export to the real one and starts `fa_native.dll` on a thread, in parallel with the game's own
  startup. The external launcher can still start the game (multiplayer needs it); in single player the mod then
  speaks through the native code and the launcher simply hears nothing.
- **Developing**: `fadev.py launch` starts the game suspended and injects the build directory's DLL before the
  game runs, with `FA_NO_PROXY=1` so an installed proxy stays idle. Re-run `install` after a change you want to
  play with.

### Layout

- `native/src/` platform-free code; `native/src/win/` the Windows platform layer (everything that knows MSVC
  layouts or Windows): hooks, symbol lookup, the agui reader, game state.
- `native/src/ui/`: the engine-free UI core with doctest tests in `native/tests/`.
- `native/third_party/`: vendored code and binaries, committed (see its README). The repository must build
  without network access.

### Build and dev loop

```bash
cmd //c "$(cygpath -w native/tools/build.cmd)"   # configure (first time) + build into native/build/ninja
native/build/ninja/faui_tests.exe
native/build/ninja/fa_audio_tests.exe
python native/tools/fadev.py launch              # build, start the game with the DLL, wait for the dev server
python native/tools/fadev.py reload              # eject, rebuild, re-inject into the running game
python native/tools/fadev.py kill                # close the game (WM_CLOSE first; only the tracked process)
python native/tools/fadev.py shot                # screenshot of the game window -> native/build/shot.png
python native/tools/fadev.py key down | keys text | speech --since N | log | tree | get ui/nav
python native/tools/fadev.py lua "game.get_player(1).position"   # run Lua in the mod's state (loaded game; over Lua UDP)
```

- The dev loop never steals focus: the game starts visible but inactive and the DLL blocks its attempts to
  activate itself (`FA_NOFOCUS`). It is silent unless `launch --speak`: speech is recorded but not voiced, and
  the process's audio session (the game's sound and our audio engine) is muted. `speech` shows what would have
  been said. `health` counts the audio commands the mod sent; `get "audio?json=..."` submits one by hand.
- `fadev.py` tracks the game by pid, creation time and image path, and re-checks all three before acting, so a
  pid Windows reused is never touched. `kill` closes the window first so the game exits cleanly (a terminated
  game re-shows the changelog on the next start).
- Routes take no leading slash on the command line (`get ui/nav`): Git Bash rewrites `/paths`.
- Take screenshots (`shot`, then read the PNG). They catch what dumps miss.
- `lua` runs a chunk in the mod's Lua state in the loaded game and prints its return values (`scripts/dev-udp.lua`;
  `launch` passes `--enable-lua-udp`). `loaded("scripts.fa-utils")` gets a module, since require only works at load
  time. It answers once a tick, so the game must be in a world and unpaused. Use it for experiments on the engine's
  behaviour instead of throwaway test files.
- Only one party drives the game at a time. Ask before launching or driving it unless the user handed it over.
- `fa_native.dll` cannot be rebuilt while loaded: `reload` ejects first. A plain build while the game runs
  fails to link (LNK1168); build test targets with `--target faui_tests` instead.

### Engine access

All addresses, struct offsets and vtable slots come from the shipped `factorio.pdb` at startup, by name, through
dbghelp (`native/src/sym.h`). Nothing is hardcoded except a few enum values and bit masks, each with a comment
saying where it was read from. A missing name disables the native code with one spoken line instead of crashing.

Investigating the engine: `llvm-pdbutil` (in the Visual Studio LLVM directory) dumps classes with
`pretty -classes -class-definitions=layout -include-types='^agui::Widget$'` and enums with `pretty -enums`;
`llvm-objdump -d --start-address=... --stop-address=...` plus `llvm-symbolizer --obj=factorio.exe <addr>` reads
code. Disassemble a function before guessing what it does.

### Traps

- Factorio's Lua is compiled as C++: a Lua error is a C++ exception and unwinds through native frames. Code
  called from Lua uses RAII only (see `ParsedLocalisedString` in `lua_native.cpp`), and every Lua C function
  leaves the stack balanced.
- Never free memory the game allocated (strings it returns by value, `Package::read` results): the DLL's CRT
  heap is not the game's. Read the game's data in place instead.
- Never hold a widget pointer across frames. Node closures keep a path and resolve it each time they run.
- `agui::Widget::dispatchClick` fires a button's listeners. The virtual `mouseClick` does not, for buttons
  (agui::Gui's mouse-down bookkeeping gates it), but it is the right call for toggle buttons (checkboxes).
- Synthetic keys must release a few frames after the press: a press and release in one poll is invisible.
- Script names in `LuaGameScript` are `mod-<name>`; the scenario's is `level`.
- `_fa_native` and the mod's package path are set up when the mod's Lua state is created. After a hot `reload`,
  load a save again (or `kill` and `launch`) before testing anything that goes through Lua or reads assets.

## Factorio API reference

`llm-docs/api-reference/` has one file per class, concept, event and prototype, generated from this install's
docs. Read `llm-docs/api-reference/CLAUDE.md` for how to browse it. It is in this repository, not the Factorio
install. There are thousands of files: search with grep or glob rather than listing everything.

2.x renamed, removed and added a lot relative to 1.1, and most training data is 1.1. Check every call.

## Common LLM antipatterns

### Comments about what changed

Wrong: `-- Changed to use controllers. Now handles force_close`. Right: `-- Can be closed with the controller`,
or no comment. Comments describe the code as it is.

### Overuse of `.valid`

Check validity once, where an object enters from the outside (an event, a stored reference). Not at every level
below that.

### Defensive coding

Excessive validation hides bugs. Let code crash so edge cases surface.

```lua
-- Wrong: every line hides a possible bug
function process_signals(entity)
   if not entity or not entity.valid then return {} end
   local cb = entity.get_control_behavior()
   if not cb then return {} end
   for _, section in ipairs(cb.sections or {}) do
      for i = 1, (section.filters_count or 0) do
         local slot = section.get_slot(i)
         if slot and slot.value then --[[ ... ]] end
      end
   end
end

-- Right: check only what is legitimately nil
function process_signals(entity)
   local cb = entity.get_control_behavior()
   for _, section in ipairs(cb.sections) do
      for i = 1, section.filters_count do
         local slot = section.get_slot(i)
         if slot.value then --[[ ... ]] end -- empty slots have no value
      end
   end
end
```

Validate at UI entry points and where nil is an expected value. Not in internal functions, not for properties
that always exist, and never by silently returning an empty default.

## Performance

Cache globals locally, avoid creating tables in hot loops, use sensible tick intervals (15, 60), and validate
entities where they enter (`if entity and entity.valid then`).
