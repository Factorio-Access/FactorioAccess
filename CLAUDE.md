IMPORTANT: if you find that docs are not matching reality it may be the docs that are incorrect.  If you cannot
determine which, ask!  If the docs are wrong, fix them!

# CLAUDE.md - FactorioAccess Development Guide for LLMs

This document is designed to help LLMs (particularly Claude) understand and effectively work on the FactorioAccess mod
codebase. FactorioAccess makes the complex visual game Factorio fully playable by blind and visually impaired players
through audio cues and keyboard controls.

## Critical Mistakes to Avoid (Read First!)

### Top 7 Most Common LLM Errors:

1. **Viewpoint API: Use dot notation, not colon**
   ```lua
   -- WRONG: Viewpoint:get_viewpoint(pindex)
   -- RIGHT: Viewpoint.get_viewpoint(pindex)
   ```

2. **Test files must be registered in control.lua**
   - Add to `test_files` table or tests won't run!

3. **Event handlers: Different modifiers = different events**
   ```lua
   -- WRONG: Thinking fa-q and fa-s-q are the same event
   -- RIGHT: fa-q, fa-s-q, fa-c-q are completely separate events
   ```

4. **Always format before committing**
   ```bash
   python3 launch_factorio.py --format
   ```

5. **Function names: Check actual API, don't guess**
   ```lua
   -- Example: It's get_player_relative_origin, NOT get_player_cursor_position
   ```

6. **Table properties: MUST use local variable**
   ```lua
   -- WRONG: player.walking_state = {walking = false}  -- Engine ignores this!
   -- RIGHT: 
   local new_state = {walking = false}
   player.walking_state = new_state
   ```

7. **Speech fragments: NEVER use fragment(" ")**
   ```lua
   -- WRONG: message:fragment(" ") -- Spaces are added automatically!
   -- WRONG: message:fragment(quality_string):fragment(" "):fragment(item_name)
   -- RIGHT: message:fragment(quality_string):fragment(item_name)
   ```
   The Speech system automatically adds spaces between fragments. Adding explicit space fragments is an error and will crash at runtime.

## From the Human

After a lot of working with you I have seen your antipatterns, so I am going to lay them out here.

- Everything, everything goes through the launcher script launch_factorio.py. Tests, formatting,  you name it.
- Always run tests. Always format your changes.
- Remember that there is Factorio the game, and Factorio Access the mod, and these are separate.  We do not control the
  game. We should not test the game APIs, only the mod.
- Many files here are huge.  If you read entire files you will exhaust your context window extremely rapidly.  Prefer
  rg/grep or partial reads
- game.print is wrong. You cannot see game.print because it only goes to the GUI. You want print or the logging framework.
- One-time init of local state that does not depend on the Factorio API and which does not need to persist across a
  save/load cycle may be done at the top level of files.
- There are conflicting patterns and varying code quality.  This is particularly true of localisation.  fa-info.lua and
  message-builder.lua contain the proper patterns for localisations.  For others, either ask the human or use the one
  that leads to the best code quality.
- You currently have no real control over the GUI, only via tests.  Use tests and code hacks to explore.
- Do not use globals beyond the current file. `_G.whatever = whatever` is cheating.  Do not do this.
- Requires only execute at the top-level file.  Any other level and the require will crash at runtime.
- Always add LuaLS annotations using the correct format: `---@` (three dashes), not `-- @` (two dashes with space).
- The linter will automatically check for incorrect annotation formats and fail if any are found.

control.lua is the main runtime entry point. Use rg/grep or partial reads to explore it efficiently rather than reading the entire file.

## Quick Start

1. **Environment**: You're in WSL running a Windows Factorio binary
2. **Launcher**: Use `python3 launch_factorio.py` for testing (see below)
3. **Main entry**: `control.lua` is the runtime entry point
4. **Key directories**: 
   - `scripts/` - All gameplay features
   - `Audio/` - Sound effects
   - `locale/` - Translations
   - `llm-docs/` - Factorio API reference

## Architecture Overview

### Loading Stages (Critical to Understand!)

Factorio mods execute in three distinct stages:

1. **Settings Stage** (`settings.lua`)
   - Runs when Factorio starts
   - Defines mod settings
   - NO access to game state

2. **Data Stage** (`data.lua`, `data-updates.lua`)
   - Runs after settings
   - Defines prototypes (items, entities, recipes)
   - NO access to runtime game state
   - Can read startup settings

3. **Runtime Stage** (`control.lua`)
   - Runs when a save loads
   - All gameplay logic lives here
   - Event-driven programming
   - Access to `game`, `script`, `storage` objects

**CRITICAL**: Never try to access runtime objects (game, script, storage) from data stage or vice versa!

### Core Concepts

#### Player Index (pindex)
Almost everything is tracked per-player using their index:
```lua
local pindex = player.index
local player_data = storage.players[pindex]
```

#### Storage System
The mod uses a sophisticated storage manager (`scripts/storage-manager.lua`):
```lua
-- Declare module storage
local my_state = storage_manager.declare_storage_module('my_module', default_value)

-- Access in functions
function my_function(pindex)
    local state = my_state[pindex]  -- Automatically refers to storage.players[pindex].my_module
end
```

#### Event System
All runtime behavior is event-driven:
```lua
script.on_event(defines.events.on_built_entity, function(event)
    -- React to entity being built
end)
```

#### Communication with Screen Reader
The mod communicates with an external launcher via stdout:
```lua
Speech.speak(pindex, "Building placed at coordinates 10, 20")
-- Sends: "out <pindex> Building placed at coordinates 10, 20"
```

**Note**: The old `printout(message, pindex)` API has been deprecated in favor of `Speech.speak(pindex, message)`. Always use Speech.speak for new code.

## Key Systems

### 1. Scanner System
Helps players find entities in the world through a hierarchical menu.

**Architecture**:
- `scanner-core.lua` - Main scanning engine
- `scanner-entrypoint.lua` - Player interaction
- Multiple backends for different entity types
- Uses spatial clustering for performance

**Usage**: PAGE UP/DOWN to navigate, END to refresh

### 2. Movement System
Three movement modes:
1. **Telestep** (default) - Turn, then move
2. **Smooth Walking** - Continuous movement like vanilla

Character coordinates are announced for spatial awareness.

### 3. Building System
- Audio preview before placement
- Collision detection and reporting
- Area operations (mining, deconstructing)
- Smart cursor that remembers last interaction

### 4. Inventory/UI Navigation
- 2D grids mapped to keyboard navigation (WASD)
- Coordinate announcements ("slot 5, row 2")
- Different sounds for boundaries vs normal movement
- Hierarchical crafting menu

### 5. Transport Systems
- **Belts**: Complex analysis of belt networks
- **Vehicles**: Driving assistance
- **Trains/Rails**: Removed due to Factorio 2.0 API changes (will be reimplemented)

### 6. UI System
Modern graph-based UI architecture in `scripts/ui/`:
- **Router**: Central UI manager tracking open UIs
- **TabList**: Multi-tab UI support with shared state
- **KeyGraph**: Low-level directed graph for navigation
- **Builders**: High-level Menu and Grid builders
- Dynamic rendering with entity validation
- Integrated MessageBuilder for localization

## Development Patterns

### Module Structure

**CRITICAL**: Always use `local mod = {}` pattern, never `ModuleName = {}` global pattern:

```lua
-- CORRECT: Local module pattern
local mod = {}

-- Module initialization
function mod.on_init()
    -- Setup code
end

-- Public functions
function mod.do_something(pindex)
    -- Implementation
end

-- Event handlers (should be in EventManager, see below)
script.on_event(defines.events.on_tick, function(event)
    -- Handle event
end)

return mod
```

**Event Registration Pattern**: The codebase is transitioning to centralized event management. New code should register
events through EventManager:

```lua
-- In EventManager (scripts/event-manager.lua)
EventManager.on_event(defines.events.on_built_entity, function(event)
    -- Handle event
end)

-- Multiple events with same handler
EventManager.on_event({
    defines.events.on_player_joined_game,
    defines.events.on_player_left_game,
}, function(event)
    -- Handle either event
end)
```

### Common Function Patterns
```lua
-- Most functions take pindex as first parameter
function read_entity_info(pindex, entity, extra_flag)
    local player = game.get_player(pindex)
    if not (player and player.valid) then return end
    
    -- Implementation
end

-- Position/direction helpers from fa-utils
local dirs = directions  -- Quick access to direction constants
local function offset_position(pos, direction, distance)
    -- Implementation
end
```

### Localization Pattern (Modern Approach)

The mod is transitioning to MessageBuilder for proper localization:

```lua
-- Modern pattern using MessageBuilder (see scripts/message-builder.lua)
local message = MessageBuilder.new()
message:fragment({"entity-name.transport-belt"})
message:fragment({"fa.ent-info-facing", direction_lookup(entity.direction)})
Speech.speak(pindex, message:build())

-- Legacy pattern (still used in most code)
local result = {"", 
    {"entity-name.transport-belt"}, 
    " facing ", 
    direction_lookup(entity.direction)
}
Speech.speak(pindex, result)
```

See `scripts/fa-info.lua` for comprehensive examples of proper localization patterns.

## control.lua Navigation Guide

It's best to use targeted searches rather than reading the entire file:

### File Structure Overview

control.lua is organized into these major sections:

1. **Lines 1-52**: Module requires and initialization
   - All `require` statements for scripts
   - Module loading (fa_utils, fa_info, scanner, etc.)

2. **Lines 53-94**: Global constants
   - Entity type definitions (ENT_TYPES_YOU_CAN_WALK_OVER, etc.)
   - Walking modes
   - Direction constants

3. **Lines 95-744**: Core utility functions
   - `call_to_*` scheduled functions (95-116)
   - Entity handling functions (117-260)
   - Inventory management (261-521)
   - Player and tile utilities (522-744)

4. **Lines 745-1111**: Player initialization
   - `initialize()` function and related setup
   - Default player state configuration

5. **Lines 1112-1811**: Menu navigation
   - `menu_cursor_up/down/left/right` functions
   - Menu state management

6. **Lines 1812-2067**: Core systems
   - `schedule()` function (1812)
   - `on_tick()` main handler (1912)
   - Player joining/sync functions

7. **Lines 2068-3776**: Factorio event handlers
   - Game events (on_built_entity, on_player_died, etc.)
   - GUI events (on_gui_opened, on_gui_closed, etc.)
   - Research, combat, and other game events

8. **Lines 3777-8738**: Keybinding handlers
   - All "fa-*" custom keybindings
   - Movement keys (3777-4615): WASD, arrow keys with modifiers
   - Interaction keys (4853-5520): K, J, B, T, I keys
   - Menu/UI keys (5521-6866): N, Tab, E, X, Delete
   - Building/rail keys (6866-7454): Brackets [], rail operations
   - Special function keys (7455-8738): Various Alt/Ctrl combinations

### Search Strategies to Avoid Reading Entire File

1. **Find specific functionality**:
   ```bash
   # Instead of reading the file, search for specific functions
   rg "function.*inventory" control.lua -n
   rg "on_built_entity" control.lua -n -A 5
   ```

2. **Look in dedicated modules first**:
   - Inventory → `scripts/crafting.lua`
   - Building → `scripts/building-tools.lua`
   - Scanner → `scripts/scanner/`
   - Combat → `scripts/combat.lua`
   - UI → `scripts/ui/`

3. **Find keybinding handlers**:
   ```bash
   # Find what happens when pressing a key
   rg 'script\.on_event\("fa-k"' control.lua -n -A 10
   ```

4. **Locate event handlers**:
   ```bash
   # Find specific event handlers
   rg "on_player_cursor_stack_changed" control.lua -n -C 5
   ```

### Alternative Files for Common Tasks

Instead of searching control.lua, check these files first:

- **Building placement**: `scripts/building-tools.lua`
- **Inventory management**: `scripts/crafting.lua`
- **Scanner system**: `scripts/scanner/entrypoint.lua`
- **UI/menus**: `scripts/ui/router.lua`
- **Movement**: `scripts/travel-tools.lua`
- **Combat**: `scripts/combat.lua`
- **Localization**: `scripts/localising.lua`, `scripts/message-builder.lua`
- **Event handling**: `scripts/event-manager.lua` (new pattern)

### Common Patterns in control.lua

When you must look at control.lua:

1. **Player state access**: Search for `storage.players[pindex]`
2. **Menu handling**: Search for `players[pindex].menu`
3. **Cursor operations**: Search for `cursor_stack`
4. **Scheduled tasks**: Search for `schedule(`
5. **Initialization**: Search for `initialize(`

### Test Framework Pitfalls

1. **Test Registration**
   ```lua
   -- Tests MUST be added to test_files table in control.lua
   local test_files = {
       "scripts/tests/my-new-test.lua",  -- Add your test here!
   }
   ```

2. **Test File Structure**
   ```lua
   -- CORRECT test file structure
   local TestRegistry = require("scripts.test-registry")
   local describe, it = TestRegistry.describe, TestRegistry.it
   
   describe("Feature", function()
       it("should work", function(ctx)
           -- Test code here
       end)
   end)
   ```

3. **Assertion API**
   ```lua
   -- WRONG: These functions don't exist
   ctx:assert_true(condition)
   ctx:assert_false(condition)
   
   -- CORRECT: Use assert() with comparison
   assert(condition == true)
   assert(condition == false)
   ctx:assert_equals(expected, actual)  -- This one exists!
   ```

4. **Test Complexity**
   ```lua
   -- WRONG: Testing Factorio API behavior
   it("should create entity", function(ctx)
       local entity = surface.create_entity{...}
       assert(entity.valid)  -- Don't test API!
   end)
   
   -- CORRECT: Test mod functionality
   it("should announce entity creation", function(ctx)
       -- Mock/capture printout and verify mod behavior
   end)
   ```

### Event Handling Patterns

1. **Key Event Handlers**
   ```lua
   -- CORRECT: Different modifiers = different events = separate handlers
   script.on_event("fa-q", function(event)
       -- Plain Q logic
   end)
   
   script.on_event("fa-s-q", function(event)
       -- Shift+Q logic (separate event)
   end)
   
   script.on_event("fa-c-q", function(event)
       -- Ctrl+Q logic (separate event)
   end)
   
   -- Naming scheme: fa-[modifiers]-keyname
   -- Modifiers are "bitflags": c (ctrl), a (alt), s (shift)
   -- Examples:
   -- fa-cas-w = Ctrl+Alt+Shift+W
   -- fa-cs-w = Ctrl+Shift+W  
   -- fa-a-w = Alt+W
   -- fa-w = plain W
   ```

2. **Input Naming Convention**
   ```lua
   -- Pattern: fa-[modifiers]-keyname
   -- Examples:
   "fa-q"              -- Plain Q
   "fa-shift-q"        -- Shift+Q
   "fa-control-q"      -- Ctrl+Q
   "fa-alt-q"          -- Alt+Q
   "fa-shift-control-q" -- Shift+Ctrl+Q
   ```

### Metatable Registration

```lua
-- For custom data structures that need to persist across save/load
-- Register in on_init:
script.on_init(function()
    script.register_metatable("MyCustomClass", MyCustomClass.metatable)
end)

-- The class needs __index in its metatable:
MyCustomClass.metatable = {
    __index = MyCustomClass
}
```

## Testing with launch_factorio.py

The launcher provides LLM-friendly testing capabilities:

```bash
# Quick version check
python3 launch_factorio.py --timeout 10 -- --version

# Load a save for testing
python3 launch_factorio.py --timeout 300 --load-game mysave.zip

# Run automated tests (output is suppressed unless tests fail)
python3 launch_factorio.py --run-tests --timeout 30

# Run tests with full output (verbose mode)
python3 launch_factorio.py --run-tests --timeout 30 --verbose

# Run linter (includes LuaLS annotation format checking)
python3 launch_factorio.py --lint

# Apply formatting (runs stylua)
python3 launch_factorio.py --format

# Check formatting
python3 launch_factorio.py --format-check

# GUI testing with screenshots
python3 launch_factorio.py --gui-test --suppress-window --timeout 60
```

### Writing Tests

The mod has a custom test framework in `scripts/test-framework.lua` and `scripts/test-registry.lua`:

```lua
-- Example test file in scripts/tests/
describe("Feature Tests", function()
   it("should do something", function(ctx)
      -- Use local variables, not ctx.state!
      local test_value = 42
      local player
      
      ctx:init(function()
         -- Runs once at test start
         player = game.get_player(1)
         -- Do NOT use game.create_player() - it doesn't exist!
      end)
      
      ctx:at_tick(5, function()
         -- Runs at tick 5
         test_value = test_value + 1
         ctx:assert_equals(43, test_value)
      end)
      
      ctx:in_ticks(10, function()
         -- Runs 10 ticks after previous action
         -- Local variables persist across tick handlers!
      end)
   end)
end)
```

**Key Testing Insights**:
- Use local variables instead of `ctx.state` - Lua closures handle state persistence
- Never test Factorio API behavior - test your mod's functionality
- Mock events with `EventManager.mock_event()`
- Remove empty `ctx:at_tick` handlers - they're unnecessary
- The test framework handles EventManager test mode automatically
- Test output is suppressed by default to save context (use `--verbose` to see full output)
- On test failure, full output is automatically shown for debugging

## Performance Considerations

### Lua Optimization Patterns
- Cache globals locally for frequently called functions
- Avoid creating tables in hot loops
- Use appropriate tick intervals for different features

### Tick Distribution
Different features check at different intervals:
```lua
if event.tick % 15 == 0 then
    -- Medium frequency checks
end

if event.tick % 60 == 0 then
    -- Low frequency checks
end
```

## Common Pitfalls

1. **Don't access game/script from data stage** - This crashes immediately
2. **Check entity validity** - Entities can become invalid between ticks
3. **Handle multiplayer** - Always use pindex, never assume single player
4. **Coordinate systems** - Factorio uses centered coordinates, not tile corners
5. **Direction constants** - Use `directions.north` etc, not magic numbers
6. **Localization** - Never hardcode strings, always use locale system
7. **game.create_player() doesn't exist** - Players are created by the game, not mods. Use `game.get_player(index)`
   instead
8. **Module pattern mistakes** - Use `local mod = {}`, never global `ModuleName = {}`
9. **Testing antipatterns** - Don't test Factorio's API, test your mod's behavior
10. **Recipe API** - Use `prototypes.recipe["name"]` not `game.recipe_prototypes` (2.0 change)

### API Usage Mistakes (Common LLM Errors)

1. **Viewpoint API Confusion**
   ```lua
   -- WRONG: Using colon syntax
   local origin = Viewpoint:get_viewpoint(pindex)
   
   -- CORRECT: Use dot syntax for module functions
   local origin = Viewpoint.get_viewpoint(pindex)
   ```

2. **Function Naming Errors**
   ```lua
   -- WRONG: Incorrect function name
   local pos = get_player_cursor_position(pindex)
   
   -- CORRECT: Use the actual function name
   local pos = get_player_relative_origin(pindex)
   ```

3. **Storage Access Patterns**
   ```lua
   -- WRONG: Direct storage access
   storage.players[pindex].my_data = value
   
   -- CORRECT: Use StorageManager for new modules
   local my_storage = storage_manager.declare_storage_module('my_module', {})
   -- Then access as: my_storage[pindex].field = value
   ```

4. **Table Property Assignment (Critical)**
   ```lua
   -- WRONG: This will NOT work - Factorio engine won't detect the change
   player.walking_state = {walking = false}
   
   -- CORRECT: Must assign to a local variable first
   local new_state = {walking = false}
   player.walking_state = new_state
   
   -- This is a Factorio engine requirement: when setting properties that 
   -- return tables (like walking_state, color, etc.), you MUST assign a
   -- table to a local variable first, then assign that variable to the
   -- property. Direct table construction in the assignment will be ignored.
   ```

5. **Debug Output (Critical for FactorioAccess)**
   ```lua
   -- WRONG: game.print() outputs to in-game console which blind users can't see
   game.print("Debug info: " .. value)
   
   -- CORRECT: Use print() for debug output to logs
   print("Debug info: " .. value)
   
   -- CORRECT: Use logging framework for structured logging
   log("Debug info: " .. serpent.line(complex_data))
   
   -- CORRECT: Use Speech.speak() for user-facing messages
   Speech.speak(pindex, "Operation completed successfully")
   ```

## Adding New Features

1. **Create module** in `scripts/`
2. **Declare storage** if needed
3. **Register events** in the module
4. **Add to control.lua** requires
5. **Create keybindings** in `data.lua` if needed
6. **Add locale strings** in `locale/en/`
7. **Test thoroughly** - Manual testing required

## Known Issues (Factorio 2.0 Migration)

**IMPORTANT**: The mod is halfway through migration from Factorio 1.1 to 2.0. Many features may crash due to API
changes.

- **Trains/Rails**: Completely removed due to API incompatibility - will be reimplemented from scratch
- **Circuit Networks**: Broken - wire connection features not functional
- **Various 1.1 code**: May crash when called due to API differences

## Syntrax - Text-Based Rail Placement Language

Syntrax is a domain-specific language for describing rail layouts using text commands, designed to make train network planning accessible to blind players. It has been integrated into the codebase but is not yet actively used.

### Current Status
- **Integration**: Code is present in `syntrax/` directory and loaded in `control.lua`
- **Functionality**: Not yet connected to any rail-building features
- **Purpose**: Will eventually replace the broken rail-building system

### Basic Syntax
```lua
-- Simple commands
"l r s"              -- left, right, straight rails
"[l r] rep 4"        -- repeat pattern 4 times
"[l l s] rep 8"      -- creates a circle

-- Junction example using rail stack
"s s rpush l s s reset r s s"  -- T-junction
```

### Using Syntrax in Code
```lua
local Syntrax = require("syntrax")
local rails, error = Syntrax.execute("l r s")
if error then
    Speech.speak(pindex, "Syntrax error: " .. error.message)
else
    -- Process rail placements
    for i, rail in ipairs(rails) do
        -- rail.kind: "left", "right", or "straight"
        -- rail.outgoing_direction: 0-15 (Factorio directions)
    end
end
```

### Architecture
- **Lexer** → **Parser** → **Compiler** → **VM** → **Rail Instructions**
- Compiles to bytecode for efficient execution
- Includes comprehensive test suite (`syntrax-tests.lua`)
- Command-line tool for testing: `lua syntrax-cli.lua -c "[l r] rep 4"`

### Development Notes
- See `syntrax-overview.md` for detailed documentation
- See `syntrax-spec.md` for language specification
- See `syntrax-architecture.md` for implementation details
- Test files in `syntrax/tests/` use LuaUnit framework

### EventManager Migration (In Progress)

The codebase is transitioning from direct `script.on_event` calls scattered throughout modules to centralized event
management in `EventManager`. This migration is about 10% complete:

**Current State**:
- EventManager exists and works for new code
- ~159 event registrations still in control.lua need migration
- Most modules still use direct script.on_event

**Migration Pattern**:
```lua
-- OLD: Direct registration in module
script.on_event(defines.events.on_built_entity, function(event)
    -- handler code
end)

-- NEW: Register through EventManager
local EventManager = require("scripts.event-manager")
EventManager.on_event(defines.events.on_built_entity, function(event)
    -- handler code
end)
```

**Benefits**:
- Centralized error handling
- Event mocking for tests
- Better debugging capabilities
- Cleaner module separation

## Debugging Tips

1. **Use print() or logging framework** for debugging - game.print() outputs to the in-game console which blind users cannot access
2. **Use Speech.speak()** for user-facing messages - goes to screen reader
3. **Check logs** at `%APPDATA%/Factorio/factorio-current.log`
4. **Cursor rendering** - Enable to visualize what the mod is doing

## Key Files Reference

- `control.lua` - Main runtime entry, loads all modules
- `scripts/fa-utils.lua` - Core utilities used everywhere  
- `scripts/storage-manager.lua` - Storage system
- `scripts/event-manager.lua` - Centralized event handling (transition in progress)
- `scripts/localising.lua` - Translation/localization
- `scripts/message-builder.lua` - Complex message construction
- `scripts/building-tools.lua` - Building placement/interaction
- `scripts/scanner/` - Entity finding system (see scanner-related files)
- `scripts/test-framework.lua` - Test runner and TestContext
- `scripts/test-registry.lua` - Test registration (describe/it functions)
- `scripts/tests/` - Test files (run with --run-tests)
- `launch_factorio.py` - Development launcher with linting

## Working with the Scanner

The scanner is the flagship feature. To extend it:

1. Create a new backend in `scripts/scanner/backends/`
2. Look at existing backends for patterns (e.g., `simple.lua`, `trees.lua`)
3. Implement required methods
4. Register in the scanner system

For implementation details, refer to:
- `scripts/scanner/entrypoint.lua` - Player interaction
- `scripts/scanner/surface-scanner.lua` - Main scanning engine
- `scripts/scanner/backends/` - Example backend implementations

## Contributing Patterns

When making changes:

1. **Respect existing patterns** - Consistency is crucial
2. **Consider performance** - This runs 60 times per second
3. **Add sounds** - Audio feedback is essential
4. **Update locale** - All strings must be translatable
5. **Document complex logic** - Future maintainers will thank you
6. **Test manually** - Play with the feature using a screen reader
7. **Write automated tests** - Add tests in `scripts/tests/` when possible

### Development Workflow Best Practices

1. **Always Format and Lint**
   ```bash
   # Format your code (REQUIRED before committing)
   python3 launch_factorio.py --format
   
   # Check formatting
   python3 launch_factorio.py --format-check
   
   # Run linter
   python3 launch_factorio.py --lint
   ```

2. **Test Before Committing**
   ```bash
   # Run all tests
   python3 launch_factorio.py --run-tests --timeout 60
   
   # Run specific test scenarios
   python3 launch_factorio.py --timeout 300 --load-game mysave.zip
   ```

3. **Git Best Practices**
   ```bash
   # Use interactive rebase to clean up commits
   git rebase -i HEAD~3
   
   # Squash work-in-progress commits into logical changes
   # Each commit should be a complete, working change
   ```

4. **PR Workflow**
   - Work on feature branches (not main/master)
   - Keep commits clean and logical
   - Run formatter and tests before pushing
   - Use descriptive commit messages

## External Communication

The mod communicates with a launcher process via stdout. Format:
```
out <player_index> <message>
```

The launcher handles text-to-speech conversion. This is why `Speech.speak()` is used for user messages. Never use `game.print()` - it outputs to the in-game console which is inaccessible to blind users.

## Resources

- `llm-docs/` - Complete Factorio API reference
- `devdocs/` - Deep dives into specific systems
- `helper-scripts/` - Utilities for documentation
- GitHub issues - Bug reports and feature requests
- Discord community - User feedback and testing

Remember: This mod makes a complex visual game accessible to blind players. Every feature must be designed with
audio-first interaction in mind. When in doubt, play-test with a screen reader!
## Note on llm-docs Consolidation

The llm-docs directory has been consolidated from ~1,500 individual files to ~20 larger files to improve git performance. The information is preserved and organized by category:

- `llm-docs/classes.md` - All LuaClass definitions
- `llm-docs/concepts.md` - All concept definitions
- `llm-docs/prototypes.md` - All prototype definitions
- `llm-docs/types.md` - All type definitions
- `llm-docs/game-content.md` - Game content reference
- Other standalone files remain unchanged

Use your text editor's search within these files to find specific items.
