# Control.lua Refactoring Plan

## Current State (After Telestep Removal)
- **File size**: 8,592 lines (reduced from 8,767)
- **Already extracted**: Entity selection system to `scripts/entity-selection.lua`
- **Recently removed**: Telestep walking mode and movement queue system

## High Priority Extraction Opportunities

### 1. **Bump Detection System** (lines 3167-3407)
- **Purpose**: Audio feedback for walking collisions
- **Impact**: High - core accessibility feature
- **Safety**: High - stateless collision detection
- **LLM-friendliness**: High - self-contained logic
- **Recommendation**: Extract to `scripts/bump-detection.lua`

### 2. **Cursor Management Module** (lines 4795-5128, 5908-5058)
- **Purpose**: All cursor operations (position, size, bookmarks, distance)
- **Impact**: High - frequently used
- **Safety**: High - mostly stateless
- **LLM-friendliness**: High - clear boundaries
- **Recommendation**: Extract to `scripts/cursor-management.lua`

### 3. **Alert Sound System** (lines 1696-1765 in on_tick)
- **Purpose**: Various alert sounds (bump, enemy, train, mining)
- **Impact**: Medium-High - accessibility feature
- **Safety**: High - read-only checks
- **LLM-friendliness**: High - could be registry-based
- **Recommendation**: Extract to `scripts/alert-manager.lua`

### 4. **Item Description System** (lines 7531-7714)
- **Purpose**: Read descriptions for entities/items
- **Impact**: High - frequently used
- **Safety**: High - read-only
- **LLM-friendliness**: High - focused purpose
- **Recommendation**: Extract to `scripts/item-descriptions.lua`

## Medium Priority Extractions

### 5. **Schedule System** (lines 1610-1621 + on_tick usage)
- **Purpose**: Delayed function execution
- **Current issue**: Uses string-based function lookup
- **Recommendation**: Refactor to use function references, extract to `scripts/scheduler.lua`

### 6. **Inventory Transfer System** (lines 2168-2301)
- **Purpose**: Multi-stack inventory transfers
- **Safety**: Medium - modifies state
- **Recommendation**: Extract to `scripts/inventory-transfers.lua`

### 7. **Area Operations** (lines 5909-5999)
- **Purpose**: Area mining and clearing
- **Safety**: High - well-contained
- **Recommendation**: Extend existing `PlayerMiningTools` module

## Low Priority / Complex Extractions

### 8. **Movement System** (lines 3558-3672)
- **Issue**: Heavily coupled with many systems
- **Recommendation**: Keep in control.lua until further refactoring

### 9. **Click Handlers** (lines 6117-6725)
- **Issue**: Tightly coupled with UI state
- **Recommendation**: Wait for new UI system before extracting

## Dead Code to Remove

### Definitely dead functions:
- `call_to_check_ghost_rails` (line 88)
- `general_mod_menu_up` (line 3467)
- `swap_weapon_forward` (line 1971)
- `report_pause_menu` (line 3508)

### Rail-related code (to be removed when rails are replaced):
- Various rail-specific handlers throughout the file

### Deprecated functions:
- `target_mouse_pointer_deprecated` (lines 367-378)
- `toggle_remote_view` (lines 431-452) - has TODO about being broken

## Recommended Implementation Phases

### Phase 1 - Quick Wins (High safety, high impact):
- Extract bump detection system
- Extract cursor management
- Remove dead code
- Extract alert sound system

### Phase 2 - Medium Complexity:
- Extract item description system
- Refactor and extract schedule system
- Extract inventory transfer system

### Phase 3 - After UI/Rail Replacement:
- Re-evaluate movement system
- Extract click handlers with new UI
- Remove old rail code

## Key Observations

1. **Global namespace pollution**: control.lua injects many functions into global scope, making dependencies harder to track

2. **Event handler organization**: Currently scattered throughout file, could benefit from grouping by feature

3. **Menu navigation**: Very repetitive code (lines 917-1500) that could be data-driven

4. **Good modularization examples**: Equipment, WorkerRobots, and Scanner modules show good patterns to follow

5. **Testing implications**: Extracted modules should include tests where possible

## Implementation Notes

When extracting modules:
1. Use the local module pattern: `local mod = {}`
2. Declare storage using storage-manager when needed
3. Register events through EventManager where possible
4. Add appropriate LuaLS annotations
5. Include the module in control.lua's requires section
6. Write tests for the extracted functionality