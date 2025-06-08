# CLAUDE-QUICKREF.md - Quick Reference for Common Tasks

## Essential Commands

### Testing & Development
```bash
# Run Factorio with mod
python3 launch_factorio.py --timeout 300 --load-game mysave.zip

# Quick version check
python3 launch_factorio.py --timeout 10 -- --version

# Lint the code
python3 launch_factorio.py --lint

# Check formatting
python3 launch_factorio.py --format-check

# Apply formatting
python3 launch_factorio.py --format
```

### Common Code Patterns

#### Send Message to Player
```lua
printout("Your message here", pindex)
```

#### Get Player's Selected Entity
```lua
local ent = get_selected_ent(pindex)
if ent and ent.valid then
    -- Use entity
end
```

#### Access Player Data
```lua
local player = game.get_player(pindex)
local player_data = storage.players[pindex]
```

#### Create Storage Module
```lua
local mod = {}
local module_state = storage_manager.declare_storage_module('module_name', {
    -- default values
})

function mod.get_data(pindex)
    return module_state[pindex]  -- Auto-refers to storage.players[pindex].module_name
end
```

#### Create a UI Menu
```lua
local my_menu = TabList.declare_tablist({
    ui_name = UiRouter.UI_NAMES.MY_MENU,
    tabs = {
        UiKeyGraph.declare_graph({
            name = "main",
            title = {"my-menu.title"},
            render_callback = function(ctx)
                local menu = Menu.MenuBuilder.new()
                menu:add_clickable("item1", {"my-menu.item1"}, {
                    on_click = function(ctx) 
                        -- Handle click
                    end
                })
                return menu:build()
            end
        })
    }
})
```

#### Modern Localization
```lua
-- Use MessageBuilder for complex messages
local message = MessageBuilder.new()
message:fragment({"entity-name.transport-belt"})
message:fragment({"fa.ent-info-facing", "north"})
message:list_item({"fa.item", "iron-plate", 50})
printout(message:build(), pindex)
```

#### Register Event Handler
```lua
script.on_event(defines.events.on_built_entity, function(event)
    local entity = event.entity
    local pindex = event.player_index
    -- Handle event
end)
```

#### Schedule Future Event
```lua
schedule(10, function()
    printout("This happens 10 ticks later", pindex)
end)
```

## File Locations Quick Reference

| What | Where |
|------|-------|
| Main runtime code | `control.lua` |
| Feature modules | `scripts/*.lua` |
| Scanner backends | `scripts/scanner/backends/` |
| UI system | `scripts/ui/` |
| Modern localization | `scripts/message-builder.lua`, `scripts/fa-info.lua` |
| Sound effects | `Audio/` |
| Translations | `locale/en/` |
| Prototypes | `data.lua`, `data-updates.lua` |
| Settings | `settings.lua` |

## Key Global Functions

| Function | Purpose |
|----------|---------|
| `printout(msg, pindex)` | Send text to screen reader |
| `get_selected_ent(pindex)` | Get entity under cursor |
| `players[pindex]` | Access player state |
| `schedule(ticks, callback)` | Schedule future event |
| `direction_lookup(dir)` | Convert direction to string |
| `fa_localising.get(entity, pindex)` | Get localized name |

## Direction Constants

```lua
local dirs = directions
-- dirs.north, dirs.northeast, dirs.east, dirs.southeast,
-- dirs.south, dirs.southwest, dirs.west, dirs.northwest
```

## Common Entity Checks

```lua
-- Check if entity is valid
if entity and entity.valid then

-- Check if position is in range
local dist = fa_utils.distance(pos1, pos2)
if dist < 50 then

-- Check if entity can be mined
if entity.minable and entity.prototype.mineable_properties then

-- Check if entity has inventory
if entity.get_inventory(defines.inventory.chest) then

-- Check collision
local can_place = surface.can_place_entity{
    name = "transport-belt",
    position = pos,
    direction = dirs.north,
    force = force
}
```

## Audio Feedback

```lua
-- Play sound effect
player.play_sound{
    path = "utility/wire_connect_pole",
    volume_modifier = 0.8
}

-- Common sound paths
"utility/wire_connect_pole"      -- Connection made
"utility/cannot_build"           -- Build failed  
"utility/inventory_move"         -- Item moved
"utility/wire_disconnect"        -- Disconnection
```

## Debugging

```lua
-- Debug output to console
game.print("DEBUG: " .. serpent.line(data))

-- Check storage size
game.print("Storage size: " .. serpent.line(#serpent.dump(storage)))

-- Log to file
log("Important event: " .. serpent.block(event_data))
```

## Common Pitfalls to Avoid

❌ **Don't**:
```lua
-- Access game in data stage
data.raw["item"]["iron-plate"].stack_size = game.forces  -- CRASH!

-- Store state outside storage
local my_important_data = {}  -- LOST on save/load!

-- Hardcode strings
printout("Building placed", pindex)  -- Not translatable!

-- Assume single player
local player = game.players[1]  -- Breaks multiplayer!
```

✅ **Do**:
```lua
-- Use proper stages
-- In data.lua:
data.raw["item"]["iron-plate"].stack_size = 100

-- Store in storage
storage.players[pindex].my_data = {}

-- Use locale
printout({"building.placed"}, pindex)

-- Always use pindex
local player = game.get_player(pindex)
```

## Adding a New Feature Checklist

- [ ] Create module in `scripts/`
- [ ] Add storage declaration if needed
- [ ] Register any event handlers
- [ ] Add require to `control.lua`
- [ ] Create custom inputs in `data.lua` if needed
- [ ] Add locale strings in `locale/en/`
- [ ] Add audio files if needed
- [ ] Test with screen reader
- [ ] Test in multiplayer
- [ ] Run linter and formatter

## Performance Checklist

- [ ] Cache global lookups locally
- [ ] Avoid creating tables in loops
- [ ] Use appropriate tick intervals (15, 30, 60)
- [ ] Validate entities before use
- [ ] Clean up invalid references
- [ ] Use work queues for heavy processing
- [ ] Profile with large factories

## Testing Checklist

- [ ] Works with screen reader
- [ ] All strings are audible
- [ ] Keybindings don't conflict  
- [ ] Saves/loads correctly
- [ ] No crashes on entity removal
- [ ] Performance acceptable
- [ ] Edge cases handled
- [ ] Test with Factorio 2.0 API changes in mind