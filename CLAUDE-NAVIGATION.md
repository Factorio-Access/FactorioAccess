# CLAUDE-NAVIGATION.md - Quick Code Location Guide for FactorioAccess

This guide helps LLMs quickly find specific code locations in the FactorioAccess codebase. Use Ctrl+F to search for your task.

## 1. Common Development Tasks

### Add a New Keybinding
- **Define keybinding**: `data.lua` - Look for `data:extend` with `type = "custom-input"`
- **Handle keybinding**: `control.lua` - Search for `script.on_event("YOUR_KEYBIND_NAME"`
- **Locale string**: `locale/en/locale.cfg` - Add under `[controls]` section
- **Common mistake**: Forgetting to add locale string causes missing text in settings

### Create a New UI
- **Modern UI (recommended)**: 
  - Start with: `scripts/ui/menu-builder.lua` or `scripts/ui/grid-builder.lua`
  - Router integration: `scripts/ui/router.lua` - See `Router.open()`
  - Examples: `scripts/ui/tabs/crafting-tab.lua`, `scripts/production-overview.lua`
- **Legacy UI**: `scripts/gui.lua` (avoid for new code)
- **Common mistake**: Not closing UI properly - always use `Router.close()`

### Add a Scanner Backend
- **Create backend**: `scripts/scanner/backends/YOUR_BACKEND.lua`
- **Backend template**: Copy `scripts/scanner/backends/simple.lua`
- **Register backend**: Add to backend list in scanner initialization
- **Required methods**: `get_category()`, `get_surface_scan_results()`
- **Common mistake**: Not handling nil/invalid entities in scan results

### Add a New Test
- **Create test file**: `scripts/tests/YOUR_TEST.lua`
- **Test structure**: Use `describe()` and `it()` from `scripts/test-registry.lua`
- **Run tests**: `python3 launch_factorio.py --run-tests`
- **Common mistake**: Testing Factorio API instead of mod behavior

### Add Storage for New Feature
- **Declare storage**: `scripts/storage-manager.lua` - Use `storage_manager.declare_storage_module()`
- **Access storage**: `local my_data = my_storage[pindex]`
- **Initialize storage**: Add to your module's `on_init()` function
- **Common mistake**: Accessing storage before it's initialized

## 2. Core System Locations

### Movement System
- **Main movement**: `scripts/movement.lua`
- **Telestep mode**: Look for `storage.players[pindex].move_state`
- **Walking mode**: `scripts/character-walking.lua`
- **Direction handling**: `fa-utils.lua` - `directions` table
- **Position helpers**: `fa-utils.lua` - `offset_position()`, `util.distance()`

### Building Placement
- **Core logic**: `scripts/building-tools.lua`
- **Preview system**: Look for `play_building_preview_sound()`
- **Collision detection**: `can_place_entity()` function
- **Cursor memory**: `storage.players[pindex].cursor_memory`
- **Area tools**: `scripts/mining-tools.lua`, `scripts/blueprint-tools.lua`

### Inventory Management
- **Main inventory**: `scripts/inventory-tools.lua`
- **Navigation**: WASD handling in `control.lua` (search "inventory-up")
- **Slot info**: `read_inventory_slot()` function
- **Transfer logic**: Look for `fast_transfer`, `smart_transfer`
- **Common mistake**: Not checking `slot.valid_for_read` before accessing

### Crafting System
- **Menu navigation**: `scripts/crafting-menu.lua`
- **Recipe access**: Use `prototypes.recipe["name"]` (NOT `game.recipe_prototypes`)
- **Queue management**: Look for `crafting_queue` operations
- **UI**: `scripts/ui/tabs/crafting-tab.lua` (modern approach)

### Scanner System
- **Entry point**: `scripts/scanner/entrypoint.lua`
- **Core engine**: `scripts/scanner/surface-scanner.lua`
- **Aggregate results**: `scripts/scanner/aggregate-scanner.lua`
- **Backends**: `scripts/scanner/backends/` directory
- **Common mistake**: Not handling empty scan results

## 3. API and Helper Locations

### Player Information
- **Get player**: `game.get_player(pindex)` - NEVER use `game.create_player()`
- **Player position**: `player.position` (centered coordinates)
- **Player state**: `storage.players[pindex]` - Custom mod data
- **Common mistake**: Not checking `player and player.valid`

### Entity Information
- **Read entity**: `scripts/fa-info.lua` - Comprehensive entity reading
- **Entity types**: Check `entity.type` against Factorio API types
- **Localised names**: Use `{"entity-name." .. entity.name}`
- **Direction**: `entity.direction` (use `directions` lookup table)
- **Common mistake**: Not checking `entity.valid` before access

### Sound System
- **Play sound**: `fa-utils.lua` - `play_sound()`
- **Sound files**: `Audio/` directory
- **Volume control**: Check `storage.players[pindex].audio_volume`
- **Boundary sounds**: `inventory_edge.ogg`, `inventory_corner.ogg`

### Localization/Translation
- **Modern approach**: `scripts/message-builder.lua` - Use `MessageBuilder`
- **Legacy approach**: Concatenation tables `{"", fragment1, fragment2}`
- **Locale files**: `locale/en/` directory
- **Entity names**: `{"entity-name.X"}`, `{"item-name.X"}`, `{"recipe-name.X"}`
- **Common mistake**: Hardcoding strings instead of using locale keys

### Output to Screen Reader
- **Send message**: `Speech.speak(pindex, message)`
- **Format**: Sends `"out <pindex> <message>"` to stdout
- **Debug print**: `game.print()` - Goes to console, not screen reader
- **Common mistake**: Using `game.print()` for user messages

## 4. Configuration and Settings

### Mod Settings
- **Define settings**: `settings.lua`
- **Access runtime**: `settings.get_player_settings(player)["setting-name"]`
- **Access startup**: `settings.startup["setting-name"]`
- **Common mistake**: Trying to access runtime settings from data stage

### Keybind Configuration
- **Default bindings**: `data.lua` - Look for `key_sequence`
- **Check if pressed**: `script.on_event("keybind-name", handler)`
- **Alternative keys**: Can define multiple `key_sequence` values

### Feature Toggles
- **Accessibility options**: Various settings in `settings.lua`
- **Check in code**: `storage.players[pindex].setting_name`
- **Common locations**: Cursor mode, movement mode, verbosity levels

## 5. Localization Strings

### String Categories (in locale files)
- **[controls]**: Keybinding names and descriptions
- **[mod-setting-name]**: Setting names
- **[mod-setting-description]**: Setting tooltips
- **[fa]**: General mod strings
- **[direction]**: Direction names (north, south, etc.)

### Common String Patterns
- **Entity info**: `fa.ent-info-*` - Entity descriptions
- **Prompts**: `fa.prompt-*` - User prompts
- **Menus**: `fa.menu-*` - Menu titles and options
- **Warnings**: `fa.warning-*` - Warning messages

### String Building
- **Simple**: `{"fa.key", param1, param2}`
- **Complex**: Use `MessageBuilder` for multi-part messages
- **Entity names**: Always use `{"entity-name.X"}` format
- **Common mistake**: String concatenation with `..` instead of locale tables

## 6. Special Considerations

### Event Handling
- **New code**: Use `EventManager.on_event()` in `scripts/event-manager.lua`
- **Legacy code**: Direct `script.on_event()` calls (being migrated)
- **Custom events**: `script.raise_event()` for mod-specific events
- **Common mistake**: Registering events outside module initialization

### Performance Patterns
- **Tick intervals**: Use `event.tick % N == 0` for periodic checks
- **Caching**: Cache frequently accessed values locally
- **Validity checks**: Always check `.valid` on game objects
- **Common mistake**: Running expensive operations every tick

### Testing Helpers
- **Mock events**: `EventManager.mock_event()` in tests
- **Test context**: `scripts/test-framework.lua` - TestContext class
- **Assertions**: `ctx:assert_equals()`, `ctx:assert_true()`, etc.
- **Common mistake**: Using `ctx.state` instead of local variables

### File Size Warnings
- **control.lua**: ~10,000 lines - Use tree-sitter or grep, not full reads
- **Large modules**: Check file size before reading entire file
- **Common mistake**: Repeatedly reading control.lua exhausts context

## Quick Reference Patterns

### Check Valid Entity
```lua
if entity and entity.valid then
    -- Safe to use entity
end
```

### Access Player Storage
```lua
local pindex = player.index
local player_data = storage.players[pindex]
```

### Proper Module Pattern
```lua
local mod = {}
-- Implementation
return mod
```

### Message Building
```lua
local message = MessageBuilder.new()
message:fragment({"entity-name.transport-belt"})
message:fragment({"fa.ent-info-count", count})
Speech.speak(pindex, message:build())
```

### Event Registration (New Pattern)
```lua
local EventManager = require("scripts.event-manager")
EventManager.on_event(defines.events.on_built_entity, function(event)
    -- Handler
end)
```

## Navigation Tips
- Use tree-sitter for large files (control.lua)
- Search for keybind names to find handlers
- Look for `require` statements to trace dependencies
- Check `scripts/` subdirectories for feature modules
- Read test files for usage examples