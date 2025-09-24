# FactorioAccess Development Guide for LLMs

This guide helps LLMs (particularly Claude) work effectively on the FactorioAccess mod, which makes Factorio playable by blind and visually impaired players through audio cues and keyboard controls.

## Critical Rules (Read First!)

### Top 5 Most Common Mistakes

1. **API Access: Use dot notation for modules**
   ```lua
   -- WRONG: Viewpoint:get_viewpoint(pindex)
   -- RIGHT: Viewpoint.get_viewpoint(pindex)
   ```

2. **Table properties: MUST use local variable**
   ```lua
   -- WRONG: player.walking_state = {walking = false}  -- Engine ignores!
   -- RIGHT:
   local new_state = {walking = false}
   player.walking_state = new_state
   ```

3. **Always format and test before committing**
   ```bash
   python launch_factorio.py --format
   python launch_factorio.py --run-tests --timeout 60
   ```

4. **Debug output: Use print(), not game.print()**
   ```lua
   -- WRONG: game.print("debug")  -- Goes to GUI, blind users can't see
   -- RIGHT: print("debug")        -- Goes to logs
   -- RIGHT: Speech.speak(pindex, "user message")  -- Goes to screen reader
   ```

5. **LuaLS annotations: Use three dashes**
   ```lua
   ---@param pindex integer   -- CORRECT
   -- @param pindex integer   -- WRONG (linter will fail)
   ```

## Development Essentials

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
- Add test to `test_files` table in `control.lua`
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

- **Rails/Trains**: Completely broken, will be reimplemented
- **Circuit Networks**: Wire connections non-functional
- **Syntrax**: Rail description language integrated but not yet active

## Important Notes

- **Everything** goes through `launch_factorio.py`
- Prefer `rg`/`grep` over reading huge files
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

# Common LLM Antipatterns

## Comments Referring To What Changed

**WRONG**:

```
- Removed the old UI system. Now x does y.
```

**CORRECT**: consider whether a comment is required.


**WRONG**:

```
- Changed to use controllers. Now handles force_close
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

**WRONG**:

```
if thing_which_is_not_supposed_to_be_nil == nil then return end
```

**CORRECT**:


```
assert(thing_which_is_not_supposed_to_be_nil)
-- Code
```

Or just:

```
-- code, we'll crash if we index it.
```
