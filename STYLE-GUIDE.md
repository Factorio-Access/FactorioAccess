NOTE: for LLMs, not humans.

# FactorioAccess Style Guide

This document outlines the coding conventions and style guidelines for the FactorioAccess mod codebase. Following these guidelines ensures consistency and maintainability across the project.

## 1. Naming Conventions

### Functions
- Use **snake_case** for all function names
- Functions that read/announce information should start with `read_` or `report_`
- Functions that check conditions should start with `is_` or `has_`
- Event handlers should be prefixed with `kb_` for keybindings or use descriptive names

```lua
-- Good
function mod.read_entity_info(pindex, entity)
function mod.is_pipe_connected(entity)  
function kb_pause_menu(event)

-- Bad
function readEntityInfo(pindex, entity)
function checkPipeConnection(entity)
```

### Variables
- Use **snake_case** for all variables
- Local variables should be declared with `local`
- Player index should always be named `pindex`
- Player object should be named `p` or `player`
- Avoid single letter variables except for common patterns (i, j for loops)

```lua
-- Good
local pindex = event.player_index
local player = game.get_player(pindex)
local entity_count = 0

-- Bad
playerIndex = event.player_index
local plr = game.get_player(pindex)
local e = 0
```

### Constants
- Constants can use UPPER_CASE but this is not consistently enforced
- Prefer descriptive names over abbreviations

```lua
-- Acceptable patterns
local TICK_RATE = 60
local dirs = defines.direction  -- Common alias
```

### Module Patterns
- **ALWAYS** use the local module pattern, never global modules
- Module variable should be named `mod`
- Return the module at the end of the file

```lua
-- CORRECT: Local module pattern
local mod = {}

function mod.some_function()
    -- implementation
end

return mod

-- WRONG: Global module pattern (DO NOT USE)
MyModule = {}  -- This pollutes global namespace!
```

## 2. Code Organization

### File Structure
- Start with requires at the top
- Define local shortcuts (like `dirs = defines.direction`)
- Create module table
- Define module functions
- Register event handlers (preferably through EventManager)
- Return module at end

```lua
-- Standard file structure
local util = require("util")
local fa_utils = require("scripts.fa-utils")
local dirs = defines.direction

local mod = {}

-- Module functions
function mod.do_something(pindex)
    -- implementation
end

-- Event handlers (new pattern - use EventManager)
local EventManager = require("scripts.event-manager")
EventManager.on_event(defines.events.on_built_entity, function(event)
    -- handler
end)

return mod
```

### Function Organization
- Group related functions together
- Add section comments for major functionality groups
- Keep functions focused on a single responsibility

## 3. Lua Patterns

### Table Construction
- Use table literals when possible
- For complex tables, build incrementally
- Use `table.insert` for dynamic arrays

```lua
-- Simple table literal
local data = {
    name = "test",
    value = 42,
    items = {"a", "b", "c"}
}

-- Building complex tables
local result = {}
for i, item in pairs(items) do
    table.insert(result, process_item(item))
end
```

### Error Handling
- Always validate player and entity objects
- Check `valid` property before using entities
- Return early on invalid conditions

```lua
function mod.process_entity(pindex, entity)
    local player = game.get_player(pindex)
    if not (player and player.valid) then return end
    
    if not (entity and entity.valid) then
        return "Invalid entity"
    end
    
    -- Process entity
end
```

### Nil Checks
- Use explicit nil checks
- Combine validity checks with logical operators
- Provide fallback values where appropriate

```lua
-- Good nil checking patterns
if entity ~= nil and entity.valid then
    -- use entity
end

local count = stack.count or 0
local name = entity.name or "unknown"
```

### Loop Patterns
- Use `pairs` for tables, `ipairs` for arrays
- Cache table lookups outside loops when possible
- Avoid creating tables inside hot loops

```lua
-- Good loop patterns
local players_data = storage.players
for pindex, player_data in pairs(players_data) do
    -- process player data
end

-- Avoid table creation in loops
-- Bad:
for i = 1, 100 do
    local pos = {x = i, y = i}  -- Creates new table each iteration
end

-- Good:
local pos = {}
for i = 1, 100 do
    pos.x = i
    pos.y = i
    -- use pos
end
```

## 4. FactorioAccess Specific Patterns

### Player Index (pindex) Usage
- Always pass `pindex` as the first parameter to functions
- Never assume single player - always use pindex
- Access player data through storage.players[pindex]

```lua
function mod.read_info(pindex, extra_param)
    local player = game.get_player(pindex)
    local player_data = storage.players[pindex]
    -- implementation
end
```

### Message Building
- Use MessageBuilder for complex localized messages
- For simple messages, use locale string arrays
- Never hardcode user-facing strings

```lua
-- Modern pattern with MessageBuilder
local message = MessageBuilder.new()
message:fragment({"entity-name.transport-belt"})
message:fragment({"fa.ent-info-facing", direction_lookup(entity.direction)})
printout(message:build(), pindex)

-- Simple pattern for basic messages
local result = {"", 
    {"entity-name.transport-belt"}, 
    " facing ", 
    direction_lookup(entity.direction)
}
printout(result, pindex)
```

### Sound Playing
- Use descriptive sound paths
- Always play sounds through the player object
- Common sounds: "Inventory-Move", "inventory-edge", "utility/cannot_build"
- When possible go through or add functions to scripts/ui/sounds.lua

```lua
-- Standard sound playing
player.play_sound({ path = "Inventory-Move" })
player.play_sound({ path = "utility/cannot_build" })
```

### Localization
- All user-facing strings must use the locale system
- Use locale keys like "fa.message-key" for mod-specific strings
- Use {"entity-name.entity"} for game entity names

```lua
-- Good localization
printout({"fa.building-info", entity.name}, pindex)

-- Bad - hardcoded string
printout("Building: " .. entity.name, pindex)  -- DO NOT DO THIS
```

## 5. Documentation

### LuaLS Annotations
- **Always** add LuaLS type annotations for function parameters
- Document return types
- Use proper type names from Factorio API

```lua
---@param pindex number Player index
---@param entity LuaEntity Entity to process
---@param check_connection boolean? Optional connection check
---@return string Result message
function mod.process_entity(pindex, entity, check_connection)
    -- implementation
end
```

### Function Documentation
- Add descriptive comments before complex functions
- Explain the purpose, not just what the code does
- Document any side effects

```lua
--[[
Scans for entities in a circular pattern around the player.
Updates the scanner cache and announces the closest entity found.
Note: This modifies storage.players[pindex].scanner_data
]]
function mod.scan_around_player(pindex, radius)
    -- implementation
end
```

### TODO/FIXME Format
- Use consistent markers: `--TODO:`, `--FIXME:`, `--laterdo`
- Include description of what needs to be done
- Reference issue numbers when available

```lua
--TODO: Implement proper error handling for multiplayer
--FIXME: This crashes when entity becomes invalid between ticks
--laterdo: Add localization for this message
```

## 6. What NOT to Do

### Global Pollution
- **NEVER** use global variables except through storage
- **NEVER** use `_G.variable = value` - this is cheating
- Always use local variables and module pattern

```lua
-- WRONG - Global pollution
MyGlobalVar = 42  -- DO NOT DO THIS
_G.some_function = function() end  -- DO NOT DO THIS

-- CORRECT
local my_var = 42
local mod = {}
function mod.some_function() end
```

### Magic Numbers
- Avoid hardcoded numbers without explanation
- Use named constants or add comments
- Exception: Common tick intervals (60 = 1 second)

```lua
-- Bad
if event.tick % 15 == 0 then  -- What is 15?

-- Good  
local SCANNER_UPDATE_INTERVAL = 15  -- Update every 0.25 seconds
if event.tick % SCANNER_UPDATE_INTERVAL == 0 then

-- Acceptable with comment
if event.tick % 60 == 0 then  -- Every second
```

### Hardcoded Strings
- Never hardcode user-facing messages
- Always use the localization system
- Exception: Internal debug messages with game.print()

```lua
-- WRONG
printout("Building placed at " .. pos.x .. ", " .. pos.y, pindex)

-- CORRECT
printout({"fa.building-placed", pos.x, pos.y}, pindex)
```

### Testing Factorio API
- Don't test Factorio's behavior - test your mod's functionality
- Don't verify API contracts in tests
- Focus on your mod's logic and state management

```lua
-- Bad test - tests Factorio API
it("should create valid entity", function(ctx)
    local entity = surface.create_entity{...}
    ctx:assert(entity.valid)  -- Testing Factorio, not your mod
end)

-- Good test - tests mod behavior  
it("should add entity to tracking list", function(ctx)
    local entity = surface.create_entity{...}
    mod.track_entity(1, entity)
    ctx:assert_equals(1, #storage.players[1].tracked_entities)
end)
```

### Incorrect Requires
- Requires only work at file top-level
- Never use require inside functions - it will crash

```lua
-- WRONG - Will crash at runtime
function mod.load_module()
    local other = require("scripts.other")  -- CRASH!
end

-- CORRECT - At top level only
local other = require("scripts.other")
function mod.use_module()
    other.do_something()
end
```

## 7. Performance Considerations

### Tick Distribution
- Spread expensive operations across multiple ticks
- Use modulo operators for periodic checks
- Document tick intervals

```lua
-- Common patterns
if event.tick % 15 == 0 then  -- 4 times per second
    -- medium frequency updates
end

if event.tick % 60 == 0 then  -- Once per second  
    -- low frequency updates
end
```

### Caching
- Cache frequently accessed values
- Cache global lookups in local variables
- Invalidate caches when data changes

```lua
-- Cache globals locally
local floor = math.floor
local insert = table.insert

-- Cache repeated lookups
function mod.process_entities(entities)
    local player_data = storage.players[pindex]
    for _, entity in pairs(entities) do
        -- use player_data instead of repeated storage access
    end
end
```

## 8. Event Handling (Migration in Progress)

The codebase is transitioning to centralized event management. New code should use EventManager:

```lua
-- NEW PATTERN - Use this for new code
local EventManager = require("scripts.event-manager")
EventManager.on_event(defines.events.on_built_entity, function(event)
    -- handler code
end)

-- OLD PATTERN - Being phased out
script.on_event(defines.events.on_built_entity, function(event)
    -- handler code  
end)
```

## Summary

Following these guidelines helps maintain a consistent, readable, and performant codebase. When in doubt:
- Look at well-written modules like fa-utils.lua, message-builder.lua, and storage-manager.lua
- Keep accessibility in mind - this mod serves blind players
- Test with actual screen readers when possible
- Ask for clarification rather than assuming