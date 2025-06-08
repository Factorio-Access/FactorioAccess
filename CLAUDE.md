IMPORTANT: if you find that docs are not matching reality it may be the docs that are incorrect.  If you cannot determine which, ask!  If the docs are wrong, fix them!
# CLAUDE.md - FactorioAccess Development Guide for LLMs

This document is designed to help LLMs (particularly Claude) understand and effectively work on the FactorioAccess mod codebase. FactorioAccess makes the complex visual game Factorio fully playable by blind and visually impaired players through audio cues and keyboard controls.

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
printout("Building placed at coordinates 10, 20", pindex)
-- Sends: "out <pindex> Building placed at coordinates 10, 20"
```

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
- **Rails**: Custom rail builder with templates (currently broken in 2.0)
- **Trains**: Schedule management, state reporting
- **Belts**: Complex analysis of belt networks
- **Vehicles**: Driving assistance

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
```lua
local mod = {}

-- Module initialization
function mod.on_init()
    -- Setup code
end

-- Public functions
function mod.do_something(pindex)
    -- Implementation
end

-- Event handlers
script.on_event(defines.events.on_tick, function(event)
    -- Handle event
end)

return mod
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
printout(message:build(), pindex)

-- Legacy pattern (still used in most code)
local result = {"", 
    {"entity-name.transport-belt"}, 
    " facing ", 
    direction_lookup(entity.direction)
}
printout(result, pindex)
```

See `scripts/fa-info.lua` for comprehensive examples of proper localization patterns.

## Testing with launch_factorio.py

The launcher provides LLM-friendly testing capabilities:

```bash
# Quick version check
python3 launch_factorio.py --timeout 10 -- --version

# Load a save for testing
python3 launch_factorio.py --timeout 300 --load-game mysave.zip

# Run linter
python3 launch_factorio.py --lint

# Check formatting
python3 launch_factorio.py --format-check

# GUI testing with screenshots
python3 launch_factorio.py --gui-test --suppress-window --timeout 60
```

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

## Adding New Features

1. **Create module** in `scripts/`
2. **Declare storage** if needed
3. **Register events** in the module
4. **Add to control.lua** requires
5. **Create keybindings** in `data.lua` if needed
6. **Add locale strings** in `locale/en/`
7. **Test thoroughly** - Manual testing required

## Known Issues (Factorio 2.0 Migration)

**IMPORTANT**: The mod is halfway through migration from Factorio 1.1 to 2.0. Many features may crash due to API changes.

- **Rails**: Currently broken - avoid working on rail-related features
- **Circuit Networks**: Broken - wire connection features not functional
- **Various 1.1 code**: May crash when called due to API differences

## Debugging Tips

1. **Use game.print()** for debugging - prints to console instead of screen reader
2. **Use printout()** for user-facing messages - goes to screen reader
3. **Check logs** at `%APPDATA%/Factorio/factorio-current.log`
4. **Cursor rendering** - Enable to visualize what the mod is doing

## Key Files Reference

- `control.lua` - Main runtime entry, loads all modules
- `scripts/fa-utils.lua` - Core utilities used everywhere  
- `scripts/storage-manager.lua` - Storage system
- `scripts/localising.lua` - Translation/localization
- `scripts/message-builder.lua` - Complex message construction
- `scripts/building-tools.lua` - Building placement/interaction
- `scripts/scanner/` - Entity finding system (see scanner-related files)
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

## External Communication

The mod communicates with a launcher process via stdout. Format:
```
out <player_index> <message>
```

The launcher handles text-to-speech conversion. This is why `printout()` is used instead of `game.print()`.

## Resources

- `llm-docs/` - Complete Factorio API reference
- `devdocs/` - Deep dives into specific systems
- `helper-scripts/` - Utilities for documentation
- GitHub issues - Bug reports and feature requests
- Discord community - User feedback and testing

Remember: This mod makes a complex visual game accessible to blind players. Every feature must be designed with audio-first interaction in mind. When in doubt, play-test with a screen reader!