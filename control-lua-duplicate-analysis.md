# Control.lua Duplicate Code Analysis Report

## Executive Summary

After analyzing control.lua (8,738 lines), I've identified significant code duplication across menu handling, event handlers, and utility functions. The most prevalent issues are:

1. **Inventory boundary checking** - 8 nearly identical implementations
2. **Player/entity validation** - 200+ instances of the same pattern
3. **Position calculations** - Repeated scan area and coordinate calculations
4. **Event handler boilerplate** - Similar structure across dozens of handlers

## Major Duplication Categories

### 1. Menu Navigation & UI Handling

#### Inventory Wrap-Around Logic (8 occurrences)
The most significant duplication occurs in inventory navigation. Each direction (up/down/left/right) has identical logic for both regular inventory and trash inventory:

**Pattern:**
```lua
if storage.players[pindex].preferences.inventory_wraps_around == true then
    --Wrap around setting
    storage.players[pindex].inventory.index = [calculation]
    sounds.play_menu_wrap(pindex)
    read_inventory_slot(pindex[, optional params])
else
    --Border setting: Undo change and play "wall" sound
    storage.players[pindex].inventory.index = [undo calculation]
    sounds.play_ui_edge(pindex)
end
```

**Locations:**
- Lines 691-701 (menu_cursor_up - INVENTORY)
- Lines 711-721 (menu_cursor_up - PLAYER_TRASH)
- Lines 884-895 (menu_cursor_down - INVENTORY)
- Lines 904-915 (menu_cursor_down - PLAYER_TRASH)
- Lines 1072-1081 (menu_cursor_left - INVENTORY)
- Lines 1090-1099 (menu_cursor_left - PLAYER_TRASH)
- Lines 1215-1224 (menu_cursor_right - INVENTORY)
- Lines 1234-1243 (menu_cursor_right - PLAYER_TRASH)

#### Sound Playback Pattern
Consistent pattern throughout menu navigation:
- `sounds.play_menu_move(pindex)` - 59 occurrences
- `sounds.play_menu_wrap(pindex)` - for wrap-around
- `sounds.play_ui_edge(pindex)` - 10 occurrences for boundaries

### 2. Event Handler Patterns

#### Player Validation (209 occurrences)
Almost every event handler starts with:
```lua
local pindex = event.player_index
if not check_for_player(pindex) then return end
```

#### Movement Key Handlers (Lines 3093-3126)
Four identical handlers for WASD movement:
```lua
EventManager.on_event("fa-[key]", function(event)
   local pindex = event.player_index
   local router = UiRouter.get_router(pindex)
   if not check_for_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end
   
   move_key(defines.direction.[direction], event)
end)
```

#### Entity Validation Pattern (20+ occurrences)
```lua
if ent and ent.valid then
   -- do something with entity
end
```

### 3. Calculation & Utility Patterns

#### Pump Distance Calculation (Exact Duplicate)
Lines 817-821 and 1026-1030 contain identical code:
```lua
local pump_position = storage.players[pindex].pump.positions[storage.players[pindex].pump.index]
local player_pos = game.get_player(pindex).position
local distance = math.floor(FaUtils.distance(player_pos, pump_position.position))
local relative_dir = FaUtils.direction(player_pos, pump_position.position)
local facing_dir = pump_position.direction
```

#### Scan Area Calculation (4 occurrences)
Similar patterns at lines 3006-3013, 3489-3496, 4100-4107, 4392-4399:
```lua
local scan_left_top = {
   x = math.floor(cursor_pos.x) - cursor_size,
   y = math.floor(cursor_pos.y) - cursor_size,
}
local scan_right_bottom = {
   x = math.floor(cursor_pos.x) + cursor_size + 1,
   y = math.floor(cursor_pos.y) + cursor_size + 1,
}
```

#### Index to Grid Coordinates
Pattern repeated with variations:
```lua
local x = index % width
local y = math.floor(index / width) + 1
if x == 0 then
   x = x + width
   y = y - 1
end
```

### 4. Common Getter Patterns

#### Player and Router (30+ occurrences each)
```lua
local p = game.get_player(pindex)
local router = UiRouter.get_router(pindex)
```

#### Entity at Tile (15+ occurrences)
```lua
local ent = EntitySelection.get_first_ent_at_tile(pindex)
```

## Recommendations

### High Priority (Biggest Impact)

1. **Extract Inventory Navigation Helper**
   ```lua
   function handle_inventory_navigation(pindex, new_index, undo_index, is_trash)
      if storage.players[pindex].preferences.inventory_wraps_around then
         storage.players[pindex].inventory.index = new_index
         sounds.play_menu_wrap(pindex)
         read_inventory_slot(pindex, is_trash)
      else
         storage.players[pindex].inventory.index = undo_index
         sounds.play_ui_edge(pindex)
      end
   end
   ```

2. **Create Event Handler Wrapper**
   ```lua
   function create_player_event_handler(handler)
      return function(event)
         local pindex = event.player_index
         if not check_for_player(pindex) then return end
         local p = game.get_player(pindex)
         local router = UiRouter.get_router(pindex)
         handler(event, pindex, p, router)
      end
   end
   ```

3. **Extract Scan Area Calculation**
   ```lua
   function calculate_scan_area(center_pos, size)
      return {
         left_top = {
            x = math.floor(center_pos.x) - size,
            y = math.floor(center_pos.y) - size,
         },
         right_bottom = {
            x = math.floor(center_pos.x) + size + 1,
            y = math.floor(center_pos.y) + size + 1,
         }
      }
   end
   ```

### Medium Priority

4. **Consolidate Pump Distance Calculations**
5. **Create Grid Coordinate Conversion Utility**
6. **Standardize Entity Validation**
7. **Extract Position Formatting Utilities**

### Low Priority

8. **Consolidate Similar Menu Functions** - The `general_mod_menu_up/down` functions exist but aren't used
9. **Table-Driven Approach for Similar Handlers** - e.g., splitter priority handlers

## Impact Analysis

- **Lines of code that could be reduced**: ~500-800 lines
- **Maintenance improvement**: Changes to menu behavior would require updates in 1 place instead of 8
- **Bug reduction**: Consistent behavior across all menus
- **Readability**: Clearer intent with named helper functions

## Next Steps

1. Start with the inventory navigation helper (biggest win)
2. Create the event handler wrapper
3. Extract calculation utilities
4. Gradually refactor existing code to use new helpers
5. Add tests for the extracted helpers

This refactoring would significantly improve maintainability while preserving all existing functionality.