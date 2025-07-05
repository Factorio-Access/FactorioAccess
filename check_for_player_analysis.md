# check_for_player Usage Analysis

## Pattern Categories

### 1. Simple check_for_player only
These handlers only check if the player exists and return if not.
```lua
if not check_for_player(pindex) then return end
```
**Migration**: Use `create_player_handler`

Examples:
- fa-k (line 3963)
- fa-s-k (line 4007)
- fa-s-j (line 4164)
- fa-c-j (line 4171)
- fa-s-b (line 4188)
- fa-b (line 4209)
- fa-ca-b (line 4227)
- fa-cas-b (line 4242)
- fa-a-t (line 4250)
- fa-s-t (line 4257)
- fa-cs-t (line 4264)
- fa-cs-p (line 4291)

### 2. Router fetched BEFORE check_for_player (PROBLEMATIC)
These handlers fetch the router before checking if the player exists:
```lua
local router = UiRouter.get_router(pindex)
if not check_for_player(pindex) then return end
```
**Migration**: Need to refactor to check player first, then get router

Examples:
- on_player_changed_position (line 563)
- on_player_left_game (line 1545)
- on_player_cursor_stack_changed (line 1876)
- on_player_died (line 2024)
- on_player_main_inventory_changed (line 2060)
- on_player_selected_area (line 2399)

### 3. check_for_player with router UI checks
Combined checks for player and UI state:
```lua
if not check_for_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end
```
**Migration**: Use `create_extended_player_handler` with ui_check

Examples:
- fa-a-up (line 3613)
- fa-a-left (line 3622)
- fa-a-down (line 3631)
- fa-a-right (line 3640)
- fa-c-up (line 3662)
- fa-c-left (line 3670)
- fa-c-down (line 3678)
- fa-c-right (line 3686)

### 4. Multi-line conditions with check_for_player
Complex conditions checking vanilla_mode, cursor state, etc:
```lua
if
   not check_for_player(pindex)
   or storage.players[pindex].vanilla_mode
   or Viewpoint.get_viewpoint(pindex):get_cursor_enabled() == false
then
   return
end
```
**Migration**: Use `create_extended_player_handler` with custom skip_handler

Examples:
- fa-ca-up (line 3501)
- fa-ca-left (line 3515)
- fa-ca-down (line 3529)
- fa-ca-right (line 3543)
- fa-cs-up (line 3557)
- fa-cs-left (line 3571)
- fa-cs-down (line 3585)
- fa-cs-right (line 3599)

### 5. Special Cases

#### 5a. check_for_player with no early return
Some handlers call check_for_player but don't return immediately:
```lua
check_for_player(pindex)
schedule(3, "call_to_fix_zoom", pindex)
```
Examples:
- on_cutscene_cancelled (line 1998)
- on_cutscene_finished (line 2005)
- on_cutscene_started (line 2013)

#### 5b. Duplicate check_for_player calls
- fa-space (lines 7322 and 7324) - has duplicate checks!

#### 5c. Combined with other checks
```lua
if not check_for_player(pindex) or UiRouter.get_router(pindex):is_ui_open() then return end
```
Examples:
- fa-s-i (line 4405)
- fa-c-i (line 4413)
- fa-a-i (line 4422)

### 6. Functions called from handlers
Some functions are called from event handlers and do their own check_for_player:
- `fix_walk(pindex)` (line 2049)
- `read_coords(pindex)` - likely does internal checks

## Handlers Missing check_for_player

These handlers have player_index but don't call check_for_player:
- on_player_mined_item (line 1917) - plays sounds without checking
- on_player_created (line 2017) - calls PlayerInit.initialize directly
- on_player_died (line 2659) - complex handler, has some checks but not check_for_player
- on_player_joined_game (line 1387) - might be initialization-related

## Migration Strategy

### Phase 0: Fix Missing Checks
1. Add check_for_player to handlers that are missing it
2. Ensure proper initialization order

### Phase 1: Fix Problematic Patterns
1. Refactor handlers that get router before check_for_player
2. Fix duplicate check_for_player calls
3. Fix handlers that get game.get_player before check_for_player

### Phase 2: Migrate Simple Patterns
1. Convert simple check_for_player patterns to create_player_handler
2. Convert UI check patterns to create_extended_player_handler with ui_check

### Phase 3: Migrate Complex Patterns
1. Create skip_handler functions for complex conditions
2. Convert multi-condition patterns to create_extended_player_handler

### Phase 4: Special Cases
1. Handle non-returning check_for_player calls
2. Audit functions called from handlers for redundant checks

## Automated Migration Notes

For automated migration, we need to:
1. Parse the handler body to identify the pattern
2. Extract any router usage
3. Extract any additional conditions
4. Generate appropriate create_player_handler or create_extended_player_handler call
5. Handle special cases manually

The migration script should:
- Identify pattern type
- Extract handler body after checks
- Generate new handler with appropriate wrapper
- Preserve comments and formatting where possible

## Summary Statistics

- Total EventManager handlers: ~169
- Handlers with check_for_player: ~125
- Handlers missing check_for_player: ~4-10
- Handlers with router before check: ~10
- Handlers with complex conditions: ~20
- Handlers with UI checks: ~15