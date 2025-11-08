# FactorioAccess Development Guide for LLMs

This guide helps LLMs (particularly Claude) work effectively on the FactorioAccess mod, which makes Factorio playable by blind and visually impaired players through audio cues and keyboard controls.

## Critical Rules (Read First!)

### Most Common Mistakes

1. **API Access: Use dot notation for modules**
   ```lua
   -- WRONG: Viewpoint:get_viewpoint(pindex)
   -- RIGHT: Viewpoint.get_viewpoint(pindex)
   ```

2. **Always format, test, and lint localisation before committing**
   ```bash
   python launch_factorio.py --format
   python launch_factorio.py --run-tests --timeout 60
   python lint_localisation.py lint
   ```

3. **Debug output: Use print(), not game.print()**
   ```lua
   -- WRONG: game.print("debug")  -- Goes to GUI, blind users can't see
   -- RIGHT: print("debug")        -- Goes to logs
   -- RIGHT: Speech.speak(pindex, "user message")  -- Goes to screen reader
   ```

4. **LuaLS annotations: Use three dashes**
   ```lua
   ---@param pindex integer   -- CORRECT
   -- @param pindex integer   -- WRONG (linter will fail)
   ```

## Development Essentials

### Your Environment

You are running in the mods/FactorioAccess directory of a Factorio install. `launch_factorio.py` is in your current working directory.

The full factorio install is available at `../..`. You almost never need to consult it.

Commands should always be relative to the current working directory.

### Key Commands
```bash
# Run Factorio with save
python launch_factorio.py --timeout 300 --load-game mysave.zip

# Format code (REQUIRED before committing)
python launch_factorio.py --format

# Run tests
python launch_factorio.py --run-tests --timeout 60

# Run linter
python launch_factorio.py --lint

# Run localisation linter (checks for unused/missing locale keys)
python lint_localisation.py lint
```

### Architecture Overview

**Loading Stages (Critical!)**
1. **Settings Stage** (`settings.lua`) - Defines settings, NO game access
2. **Data Stage** (`data.lua`) - Defines prototypes, NO runtime access
3. **Runtime Stage** (`control.lua`) - Event-driven gameplay logic

**Never access runtime objects (game, script, storage) from data stage!**

### Core Patterns

#### Player Data Access
```lua
local pindex = player.index
local player = game.get_player(pindex)
local player_data = storage.players[pindex]
```

#### Storage Declaration (StorageManager)
```lua
local my_storage = storage_manager.declare_storage_module('module_name', {
    -- default values
})

-- Access: automatically refers to storage.players[pindex].module_name
-- Also handles lazy initialization
local data = my_storage[pindex]
```

#### Modern UI Pattern
```lua
local Router = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")
local Menu = require("scripts.ui.menu-builder")

local my_menu = TabList.declare_tablist({
    ui_name = Router.UI_NAMES.MY_MENU,
    tabs = {
        -- Tab definitions using KeyGraph
    }
})
```

#### Localization (MessageBuilder)
```lua
local message = MessageBuilder.new()
message:fragment({"entity-name.transport-belt"})
message:fragment({"fa.direction", "north"})
Speech.speak(pindex, message:build())
```

**WARNING**: `MessageBuilder` handles spaces. `MessageBuilder:fragment(" ")` crashes in order to loudly catch this bug!

Correct:

```
mb:fragment("foo"):fragment("bar")
-- produces foo bar
```

Crashes!:

```
mb:fragment("foo":fragment(" "):fragment("bar")
-- crashes: spaces were already added!
```


Style rules:

- Don't use `:` `()`.
- Don't be verbose
- Avoid emdash
- Avoid unicode
- Prefer MessageBuilder list_item() for managing placement of commas
- Always familiarize with the contents of scripts/localising.lua and use those functions
- Localisation keys should always be in section `fa` and must never contain `.`.  Example: `fa.foo-bar` is good, `fa.foo.bar` is bad.

We are writing for a screen reader.  This means two core principles:

- The sooner a message conveiying information varies, the faster the user can keep going.
  - Ex: "cursor anchored" "cursor unanchored" makes the user listen to "cursor".
  - ex: "anchored cursor" "unanchored cursor" lets the user move on as soon as the first syllable.
- Less punctuation is better, unless it's comma or period.  Many setups read colon left paren etc.

## Key Systems

### Scanner System
The flagship feature for finding entities:
- **Entry**: `scripts/scanner/entrypoint.lua`
- **Engine**: `scripts/scanner/surface-scanner.lua`
- **Backends**: `scripts/scanner/backends/`
- Uses spatial clustering and incremental processing

### UI System
Modern graph-based architecture:
- **Router**: `scripts/ui/router.lua` - Central UI manager
- **TabList**: Multi-tab support with shared state
- **Builders**: Menu and Grid builders for common patterns
- Dynamic rendering with React-like rebuilding

### Movement System
- Files: `scripts/movement.lua`, `scripts/character-walking.lua`

### Building System
- Audio preview before placement
- Collision detection
- Area operations
- File: `scripts/building-tools.lua`

## Testing

### Test Framework
```lua
-- In scripts/tests/my-test.lua
local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("Feature", function()
    it("should work", function(ctx)
        local test_value = 42  -- Use locals, not ctx.state

        ctx:at_tick(5, function()
            ctx:assert_equals(42, test_value)
        end)
    end)
end)
```

**Remember**:
- Add test to `test_files` table in `scripts/test-framework.lua` (around line 29)
- Test mod behavior, not Factorio API
- Use local variables for state

## Quick Reference

### File Locations
- **Main entry**: `control.lua` (use grep/partial reads - it's huge!)
- **Utilities**: `scripts/fa-utils.lua`
- **Entity info**: `scripts/fa-info.lua`
- **Storage**: `scripts/storage-manager.lua`
- **Events**: `scripts/event-manager.lua` (migration in progress)
- **Tests**: `scripts/tests/`

### Common Tasks

#### Add Keybinding
1. Define in `data.lua`: `type = "custom-input"`
2. Handle in `control.lua`: `script.on_event("fa-keyname")`
3. Add locale in `locale/en/locale.cfg` under `[controls]`

#### Add Scanner Backend
1. Create `scripts/scanner/backends/your-backend.lua`
2. Copy structure from `simple.lua`
3. Implement required methods: `get_category()`, `get_surface_scan_results()`

#### Add Storage Module
```lua
local my_storage = storage_manager.declare_storage_module('my_module', {
    -- defaults
})
```

## Performance Tips

- Cache globals locally
- Avoid table creation in hot loops
- Use appropriate tick intervals (15, 60, etc.)
- Validate entities: `if entity and entity.valid then`

## Known Issues (Factorio 2.0 Migration)

- **Rails/Trains**: Removed from the mod and to be reimplemented. Available in the 1.1 version only.
- **Syntrax**: Rail description language integrated but not yet active

## Important Notes

- **Everything** goes through `launch_factorio.py`
- Requires only work at file top-level
- No global state beyond current file
- Check `player and player.valid` always
- Never use `game.create_player()` (doesn't exist)
- Use `prototypes.recipe["name"]` not `game.recipe_prototypes`

## External Communication

The mod communicates with a launcher via stdout:
```
out <player_index> <message>
```
This is why `Speech.speak()` is used for user messages.

Remember: This mod makes a visual game accessible through audio. Every feature must be designed with audio-first interaction in mind!

# Message List System for Help and Documentation

The mod includes a message list system for providing help and documentation that integrates with Factorio's localization system.

## Creating Message Lists

1. Create a `.txt` file anywhere under `locale/<language>/` (e.g., `locale/en/ui-help/my-feature.txt` or `locale/en/docs/controls.txt`)
2. Write messages separated by blank lines:
   ```
   ; Comments start with semicolon
   This is the first message.

   This is the second message.
   It can span multiple lines.
   ```
3. Run `python build_message_lists.py` to generate locale files
4. The message list name is the basename of the file (without `.txt`)
5. Message list names must be globally unique across all directories

## Using Message Lists in UIs

```lua
local Help = require("scripts.ui.help")

-- In your KeyGraph declaration or TabList callbacks:
get_help_metadata = function(ctx)
   return {
      Help.message_list("my-feature"),  -- From my-feature.txt
      Help.message({"fa.some-other-message"}),  -- Direct localised string
   }
end
```

## How Users Access Help

- Press `Shift+/` (question mark) while in a UI to open help
- Use W/S to navigate between help messages
- Press `Shift+/` again or `E` to close help

# Common LLM Antipatterns

## Comments Referring To What Changed

**WRONG**:

```
- Removed the old UI system. Now x does y.
```

**CORRECT**: consider whether a comment is required.

**WRONG**:

```
-- Changed to use controllers. Now handles force_close
```

**CORRECT**:

```
-- Can be closed with the controller
```

## Overuse of valid

`x.valid` is how the mod checks whether or not an entity from Factorio can be used without error.  But, it is **WRONG TO
DO THIS AT EVERY LEVEL**.  Before implementing a block of code, **ALWAYS** consider whether or not entity/object
validity has already been checked elsewhere.

## Defensive Coding

**CRITICAL**: Excessive validation hides bugs. Let code crash to find edge cases.

**WRONG**:

```lua
function process_signals(entity)
   if not entity or not entity.valid then return {} end

   local cb = entity.get_control_behavior()
   if not cb then return {} end

   for _, section in ipairs(cb.sections or {}) do
      local count = section.filters_count or 0
      for i = 1, count do
         local slot = section.get_slot(i)
         if slot and slot.value then
            -- process slot
         end
      end
   end
end
```

This hides bugs:
- Returns empty table when entity is invalid (should crash)
- `cb.sections or {}` returns empty on nil (should crash to find why cb.sections is nil)
- `section.filters_count or 0` hides missing filters_count (should crash)
- `if slot and slot.value` silently skips invalid slots (should crash if unexpected)

**CORRECT**:

```lua
function process_signals(entity)
   local cb = entity.get_control_behavior()

   for _, section in ipairs(cb.sections) do
      for i = 1, section.filters_count do
         local slot = section.get_slot(i)
         if slot.value then  -- Only check what's expected to be nil
            -- process slot
         end
      end
   end
end
```

**When to validate:**
- At UI entry points (user can trigger with bad state)
- When nil is a valid expected value (e.g., `slot.value` can legitimately be nil for empty slots)

**When NOT to validate:**
- Internal functions (caller should ensure valid state)
- Properties that should always exist (let it crash to find the bug)
- Returning empty/default silently (masks the real problem)

# Factorio 2.0 API

This is a Factorio 2.0 project.  Your knowledge cutoff and training data did not contain Factorio 2.0 API changes.

A complete reference (one file per class, concept, define, etc) is at llm-docs/api-reference. List this directory recursively for a "table of contents".

You **MUST** double check that you understand APIs before using them.

# Quick notes on common patterns

- Before performing aggregations of items by quality to produce lists such as "legendary solar panel x 5", read scripts/item-stack-utils.lua to learn about aggregation functions that already exist.
- imports are CamelCase, not snake_case or camelCase.
