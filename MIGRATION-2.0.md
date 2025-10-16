NOTE: For LLMs, not humans.

# Factorio 2.0 Migration Guide

This document consolidates all information about the ongoing migration from Factorio 1.1 to 2.0 for the FactorioAccess mod.

## Migration Overview

### Current Status
- **Overall Progress**: Approximately 50-60% complete
- **Base Compatibility**: The mod runs on Factorio 2.0 (as per info.json)
- **API Migration**: In progress, many 1.1 API calls still present
- **EventManager Migration**: ~5% complete (8 of 168 event registrations migrated)

### Major API Changes from 1.1 to 2.0
The Factorio 2.0 update brought significant API changes that require careful migration:

1. **Prototype Access Changes**
   - `game.recipe_prototypes` → `prototypes.recipe`
   - `game.entity_prototypes` → `prototypes.entity`
   - All prototype access moved from `game.*_prototypes` to `prototypes.*`

2. **Wire Connection API**
   - `connect_neighbour()` and `disconnect_neighbour()` methods changed
   - Circuit network connection handling requires updates

3. **Rail System Changes**
   - Rail building and placement API significantly modified
   - Rail templates and patterns need rework

4. **Storage/Global State**
   - `global` renamed to `storage` (though backward compatibility exists)
   - Migration patterns need updating

### Timeline and Priorities
Based on CHANGES.md, the team is actively working on 2.0 compatibility while maintaining a working beta for 1.1 users. Current priority appears to be:
1. Core functionality (movement, building, inventory)
2. Scanner improvements
3. Rail and circuit network fixes (lower priority)

## What's Working

### Fully Migrated Systems
- **Core Movement**: Telestep and smooth walking modes
- **Basic Building**: Placement, rotation, mining
- **Scanner System**: Recently improved with new grouping features
- **Inventory Navigation**: WASD grid navigation
- **Crafting Menus**: Basic crafting functionality
- **Audio System**: Sound cues and directional audio

### Tested and Verified Features
- Basic gameplay loop (gather, craft, build)
- Multiplayer compatibility (with launcher)
- Save/load functionality
- Most keybindings and controls

## What's Broken

### Rails System
**Status**: Currently broken - avoid working on rail-related features
- Rail builder templates not functioning
- Rail placement logic needs complete rewrite for 2.0 API
- Train pathfinding integration issues

### Circuit Networks  
**Status**: Broken - wire connection features not functional
- `connect_neighbour()` API changed
- Wire placement and removal broken
- Circuit condition reading partially working

### Other Known Broken Features
1. **Various 1.1 Code**: May crash when called due to API differences
2. **Some Prototype Access**: Scattered instances of old API usage
3. **Mod Compatibility**: Some companion mods may not work

### Specific Error Messages You Might See
- "attempt to index field 'recipe_prototypes' (a nil value)" - Use `prototypes.recipe` instead
- "attempt to call method 'connect_neighbour'" - Wire connection API changed
- Rail-related crashes when attempting to use rail builder

## API Changes

### Recipe and Prototype Access
```lua
-- OLD (1.1)
local recipe = game.recipe_prototypes["iron-plate"]
local entity = game.entity_prototypes["assembling-machine-1"]

-- NEW (2.0)
local recipe = prototypes.recipe["iron-plate"]
local entity = prototypes.entity["assembling-machine-1"]
```

### Wire Connections
```lua
-- OLD (1.1)
entity.connect_neighbour({
    wire = defines.wire_type.red,
    target_entity = other_entity
})

-- NEW (2.0)
-- API changed significantly - needs investigation
```

### Other Breaking Changes
- Player creation: `game.create_player()` never existed not even in 1.1, use `game.get_player(index)`
- Force recipe access: Check if `force.recipes` API changed
- GUI API: Some elements may have new properties/methods

## EventManager Migration

### Current Progress
- **Total Event Registrations**: 168
- **Migrated to EventManager**: 8
- **Percentage Complete**: ~5%

### Migration Pattern
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

### Benefits of Migration
- Centralized error handling
- Event mocking for tests
- Better debugging capabilities
- Cleaner module separation

### Files Still Needing Migration
Most files still use direct `script.on_event`, including:
- `control.lua` (159+ registrations)
- Most files in `scripts/` directory
- Only `scripts/zoom.lua` partially migrated

## How to Help

### Priority Areas for Contribution
1. **EventManager Migration**: Low-hanging fruit, mechanical changes
2. **Prototype Access Updates**: Search and replace with testing
3. **API Documentation**: Update docs when you find discrepancies
4. **Test Coverage**: Add tests for migrated features

### Testing Procedures
```bash
# Always use the launcher for testing
python launch_factorio.py --run-tests --timeout 30

# Format your changes
python launch_factorio.py --format

# Run linter
python launch_factorio.py --lint

# Manual testing with a save
python launch_factorio.py --timeout 300 --load-game mysave.zip
```

### Migration Checklist
When migrating a file:

- [ ] Replace all `game.*_prototypes` with `prototypes.*`
- [ ] Update `script.on_event` to `EventManager.on_event`
- [ ] Check for removed/changed API methods
- [ ] Add/update tests for the migrated code
- [ ] Run formatter and linter
- [ ] Test manually with screen reader
- [ ] Update any related documentation

### Known Gotchas
1. **Don't use `global`**: Use `storage` or the storage manager pattern
2. **Check entity validity**: More important in 2.0
3. **Recipe forces**: API may have changed
4. **Wire types**: Circuit network enums may differ

### Where to Find Information
- **API Reference**: `llm-docs/` directory
- **Migration Examples**: Look at recently changed files in git history
- **Factorio Forums**: Official 2.0 modding migration guide
- **Discord**: Ask in the FactorioAccess community

## Contributing Guidelines

1. **Check Issues First**: Look for existing migration tasks
2. **Small PRs**: Migrate one system at a time
3. **Test Thoroughly**: Both automated and manual testing
4. **Document Changes**: Update this file if you discover new issues
5. **Preserve Compatibility**: Don't break working features

Remember: The mod must remain playable throughout the migration. When in doubt, ask the community or create an issue for discussion.