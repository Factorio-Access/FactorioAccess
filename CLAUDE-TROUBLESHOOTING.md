# CLAUDE-TROUBLESHOOTING.md - Troubleshooting Guide for FactorioAccess Development

## Common Error Messages and Solutions

### "attempt to index global 'game' (a nil value)"
**Cause**: Trying to access runtime objects from data stage
```lua
-- WRONG - in data.lua:
local player_count = #game.players  -- game doesn't exist here!

-- CORRECT - in control.lua:
local player_count = #game.players  -- game exists at runtime
```

### "Error while running event on_tick (ID 0)"
**Common Causes**:
1. Invalid entity reference
2. Nil player index
3. Division by zero in tick calculations

**Debug Steps**:
```lua
-- Add safety checks
script.on_event(defines.events.on_tick, function(event)
    -- Wrap in pcall for debugging
    local success, err = pcall(function()
        -- Your code here
    end)
    if not success then
        log("on_tick error: " .. err)
    end
end)
```

### "Desync detected"
**Cause**: Non-deterministic operations in multiplayer

**Common Issues**:
- Using `math.random()` without consistent seed
- Storing data outside `storage` table  
- Using `os.time()` or other system calls
- Different code paths for different players

**Fix**: Ensure all game state modifications are deterministic

### Entity Validation Errors
**Symptom**: "LuaEntity API call when LuaEntity was invalid"

**Fix Pattern**:
```lua
-- Always validate before use
if entity and entity.valid then
    -- Safe to use entity
    local name = entity.name
else
    -- Entity was destroyed
    return
end
```

## Performance Issues

### High UPS/FPS Impact

**Diagnosis**:
```lua
-- Add timing to suspect functions
local start = game.tick
expensive_function()
local elapsed = game.tick - start
if elapsed > 1 then
    log("Function took " .. elapsed .. " ticks!")
end
```

**Common Culprits**:
1. Scanning too many entities per tick
2. Creating many temporary tables
3. String concatenation in loops
4. Unnecessary global lookups

### Memory Issues

**Symptoms**: Save file grows continuously, game slows over time

**Common Causes**:
```lua
-- Storing references to invalid entities
storage.entities[id] = entity  -- Entity might become invalid!

-- Growing arrays without cleanup
table.insert(storage.history, data)  -- Never removed!
```

**Solutions**:
```lua
-- Validate and clean
for id, entity in pairs(storage.entities) do
    if not entity.valid then
        storage.entities[id] = nil
    end
end

-- Limit array size if needed
if #storage.history > 1000 then
    table.remove(storage.history, 1)
end
```

## Input/Control Issues

### Keybinding Not Working

**Checklist**:
1. Defined in `data.lua`?
2. Handler in `control.lua`?
3. Locale key exists?
4. No conflicts with other bindings?

**Debug**:
```lua
-- Add logging to input handler
script.on_event("my-custom-input", function(event)
    game.print("Input received!")  -- Verify it's firing
end)
```

### Screen Reader Not Speaking

**Common Issues**:
1. Using `game.print()` instead of `Speech.speak()`
2. Missing pindex parameter
3. Launcher not running

**Test**:
```lua
-- Direct test
Speech.speak(pindex, "Test message")  -- Should always work
```

## Scanner Issues

### Entities Not Appearing

**Checklist**:
- Is the chunk scanned? Check `storage.scanner.surfaces[surface.index].scanned_chunks`
- Is the entity type handled? Check backend implementation
- Is the area charted? Uncharted areas aren't scanned
- Is the entity within range? Default 2500 tiles

**Debug**:
```lua
-- Force rescan
storage.scanner.surfaces[surface.index].scanned_chunks = {}
storage.scanner.surfaces[surface.index].force_full_rescan = true
```

### Scanner Performance Issues

**Symptoms**: Game freezes when using scanner

**Solutions**:
1. Reduce chunks per tick in `surface-scanner.lua`
2. Increase range filtering
3. Add entity type filtering
4. Optimize backend implementations

## Building/Placement Issues

### "Can't build here" But Visually Clear

**Common Causes**:
1. Collision mask mismatch
2. Hidden entities (like smoke)
3. Tile restrictions
4. Force permissions

**Debug Helper**:
```lua
-- Check what's blocking
local blocking = surface.find_entities_filtered{
    area = entity_box,
    collision_mask = prototype.collision_mask
}
for _, blocker in pairs(blocking) do
    game.print("Blocked by: " .. blocker.name .. " at " .. serpent.line(blocker.position))
end
```

## Save/Load Issues

### Data Lost After Save/Load

**Cause**: Not storing in `storage` table

**Audit Code**:
```lua
-- Search for module-level variables
local important_data = {}  -- BAD! Will be lost

-- Should be:
storage.important_data = {}  -- Persisted
```

### Migration Failures

**Fix Pattern**:
```lua
-- In control.lua
script.on_configuration_changed(function(data)
    -- Migrate old structure
    if storage.old_field then
        storage.new_field = storage.old_field
        storage.old_field = nil
    end
    
    -- Ensure all structures exist
    storage.players = storage.players or {}
end)
```

## Localization Issues

### Missing Translations

**Symptoms**: Seeing locale keys like "item-name.iron-plate"

**Debug**:
```lua
-- Check if locale exists
local player = game.get_player(pindex)
player.request_translation{"item-name.iron-plate"}

-- In on_string_translated event:
if not event.translated then
    log("Missing translation: " .. event.localised_string[1])
end
```

## Development Workflow Issues

### WSL/Windows Interop Problems

**Symptom**: "Error 0xc0000142" when launching

**Solutions**:
1. Use `--shell` flag: `python3 launch_factorio.py --shell`
2. Check WSL version: `wsl --version`
3. Restart WSL: `wsl --shutdown` then restart

### Linter Not Finding Types

The launcher should automatically configure .luarc.json. If types are still missing:
1. Install the factoriomod-debug VSCode extension
2. Run `python3 launch_factorio.py --update-luarc`
3. Check that Factorio path is correct in .luarc.json

### Factorio 2.0 Migration Issues

**Many features are broken due to ongoing migration from 1.1 to 2.0**:
- Rails system
- Circuit networks  
- Various API calls that changed

When encountering crashes, check if the feature uses 1.1 API calls that no longer exist in 2.0.

## Debugging Tools

### Useful Console Commands
```lua
-- Check storage size
/c game.print("Storage: " .. #serpent.dump(storage) .. " bytes")

-- List all entities in area
/c local area = {{-50,-50},{50,50}}
local ents = game.player.surface.find_entities(area)
for _, e in pairs(ents) do game.print(e.name) end

-- Force scanner refresh
/c storage.scanner.surfaces[1].force_full_rescan = true

-- Clear invalid entities
/c for _, player_data in pairs(storage.players) do
    if player_data.ents then
        for i = #player_data.ents, 1, -1 do
            if not player_data.ents[i].valid then
                table.remove(player_data.ents, i)
            end
        end
    end
end
```

### Debug Mode Toggle
```lua
-- Add to control.lua for development
commands.add_command("fa-debug", nil, function(command)
    storage.debug_mode = not storage.debug_mode
    game.print("Debug mode: " .. tostring(storage.debug_mode))
end)

-- Use in code
if storage.debug_mode then
    game.print("Debug: " .. serpent.line(data))
end
```

## Getting Help

1. **Check logs**: `%APPDATA%/Factorio/factorio-current.log`
2. **Use debugger**: VSCode with Factorio Mod Debug extension
3. **Ask community**: GitHub issues or Discord
4. **Test minimal case**: Isolate problem in simple test mod

Remember: When stuck, the issue is often stage confusion (data vs runtime), invalid entity references, or multiplayer desync. Start debugging there!