# FactorioAccess Code Quality Report: Validity Check Antipatterns

## Executive Summary

This report analyzes the FactorioAccess codebase for antipatterns related to validity checks and redundant conditions. The analysis reveals several systematic issues that, while not causing bugs, reduce code clarity and performance. These antipatterns stem from defensive programming practices and misunderstandings about Factorio API guarantees.

## Key Findings

### 1. Unnecessary Validity Checks on API-Fresh Objects

**Pattern**: Checking `.valid` on objects just obtained from the Factorio API within the same tick.

**Issue**: The Factorio API returns either valid objects or nil. Objects cannot become invalid within the same tick they're obtained.

**Impact**: Unnecessary complexity and confusion about API guarantees.

### 2. Verbose Nil and Valid Checks

**Pattern**: `if entity == nil or entity.valid == false then`

**Note**: This pattern is correct - Lua short-circuits, so checking nil first prevents errors when accessing `.valid`. However, the more idiomatic Lua pattern would be `if not entity or not entity.valid then`.

**Impact**: More verbose than necessary, but functionally correct.

### 3. Duplicate Condition Checks Between Callers and Callees

**Pattern**: Caller validates an object, then passes it to a function that re-validates it.

**Issue**: Functions don't trust their callers, leading to redundant checks.

**Impact**: Performance overhead and unclear API contracts.

### 4. Repeated API Calls

**Pattern**: Calling `game.get_player(pindex)` multiple times in the same function.

**Issue**: Each call has overhead; the result should be cached.

**Impact**: Performance degradation, especially in frequently-called functions.

### 5. Incorrect Prototype Validity Checks

**Pattern**: Checking `.valid` on prototypes (e.g., `prototype.valid`).

**Issue**: Prototypes don't have a `.valid` property. If they exist, they're valid.

**Impact**: Dead code that suggests misunderstanding of the API.

### 6. Style Issues with Boolean Comparisons

**Pattern**: Using `== false`, `~= true`, or `== nil` instead of `not`.

**Issue**: Verbose and non-idiomatic Lua.

**Impact**: Reduced readability.

## Detailed Analysis and Atomic Change Proposals

### Category 1: Remove Unnecessary Validity Checks on Fresh API Objects

1. **apply: control.lua:2702**
   - Current: `if game.get_player(pindex).character == nil or game.get_player(pindex).character.valid == false then return end`
   - Proposed: `local player = game.get_player(pindex)` followed by `if not player.character then return end`
   - Rationale: Avoid calling game.get_player twice and character from API is valid or nil

2. **apply: scripts/ui/sounds.lua:30-31**
   - Current: `local player = game.get_player(pindex)` followed by `if player and player.valid then`
   - Proposed: `local player = game.get_player(pindex)` followed by `if player then`
   - Rationale: game.get_player returns valid player or nil, never invalid player
   - NOTE from review: probably fine to avoid this nil check; use assert(player) to make LuaLS happy and crasah early on invalid pindex.

3. **apply: scripts/worker-robots.lua:36**
   - Current: `if game.get_player(pindex) == nil then return end`
   - Proposed: `if not game.get_player(pindex) then return end`
   - Rationale: More idiomatic Lua style

### Category 2: Simplify Verbose Nil/Valid Checks (Style Improvement Only)

1. **apply: scripts/fa-utils.lua:501**
   - Current: `if preferred_ent == nil or preferred_ent.valid == false then`
   - Proposed: `if not preferred_ent or not preferred_ent.valid then`
   - Rationale: More idiomatic Lua, functionally identical

2. **apply: scripts/fa-utils.lua:502**
   - Current: `if preferred_ent == nil or preferred_ent.valid == false then`
   - Proposed: `if not preferred_ent or not preferred_ent.valid then`
   - Rationale: More idiomatic Lua, functionally identical

3. **apply: scripts/fa-utils.lua:945-946**
   - Current: `if k1 == nil or k1.valid == false then return true end` and `if k2 == nil or k2.valid == false then return false end`
   - Proposed: `if not k1 or not k1.valid then return true end` and `if not k2 or not k2.valid then return false end`
   - Rationale: More idiomatic Lua, functionally identical

4. **apply: scripts/equipment.lua:571**
   - Current: `if selected_stack == nil or selected_stack.valid_for_read == false then`
   - Proposed: `if not selected_stack or not selected_stack.valid_for_read then`
   - Rationale: More idiomatic Lua, functionally identical

5. **apply: scripts/combat.lua:455**
   - Current: `if selected_ammo == nil or selected_ammo.valid_for_read == false then return end`
   - Proposed: `if not selected_ammo or not selected_ammo.valid_for_read then return end`
   - Rationale: More idiomatic Lua, functionally identical

### Category 3: Remove Duplicate Caller/Callee Checks

1. **apply: scripts/building-tools.lua - build_preview_checks_info function**
   - Issue: Function re-checks stack validity that callers already verify
   - Proposed: Remove lines 612-613 (the validity checks at function start)
   - Rationale: All callers already validate the stack before calling

2. **scripts/fa-utils.lua - get_entity_part_at_cursor function**
   - Issue: Lines 501-502 check the same condition twice in a row
   - Proposed: Remove line 502 (the duplicate check)
   - Rationale: Checking the same condition immediately twice is redundant
   -- NOTE from review: incorrect, the first condition assigns to the variable the second checks.

### Category 4: Cache Repeated API Calls

1. **scripts/rail-builder.lua:286**
   - Current: `game.get_player(pindex).cursor_stack.count = game.get_player(pindex).cursor_stack.count - 1`
   - Proposed: Add `local player = game.get_player(pindex)` then `player.cursor_stack.count = player.cursor_stack.count - 1`
   - Rationale: Avoid calling game.get_player twice

2. **scripts/worker-robots.lua:942**
   - Current: `if game.get_player(pindex).opened ~= nil and game.get_player(pindex).opened.name == "roboport" then`
   - Proposed: Add `local opened = game.get_player(pindex).opened` then `if opened and opened.name == "roboport" then`
   - Rationale: Avoid calling game.get_player twice

3. **scripts/trains.lua:424**
   - Current: `if game.get_player(pindex).vehicle ~= nil and game.get_player(pindex).vehicle.name == "locomotive" then`
   - Proposed: Add `local vehicle = game.get_player(pindex).vehicle` then `if vehicle and vehicle.name == "locomotive" then`
   - Rationale: Avoid calling game.get_player twice

4. **control.lua:1980**
   - Current: `if game.get_player(pindex) ~= nil and game.get_player(pindex).mining_state.mining == true then`
   - Proposed: Add `local player = game.get_player(pindex)` then `if player and player.mining_state.mining then`
   - Rationale: Avoid calling game.get_player twice and remove redundant == true

### Category 5: Remove Invalid Prototype Validity Checks

1. **scripts/building-tools.lua:621**
   - Current: `if ent_p == nil or not ent_p.valid then return "invalid entity" end`
   - Proposed: `if not ent_p then return "invalid entity" end`
   - Rationale: Prototypes don't have a .valid property

2. **scripts/crafting.lua:194**
   - Current: `if sub_recipe ~= nil and sub_recipe.valid then`
   - Proposed: `if sub_recipe then`
   - Rationale: Prototypes don't have a .valid property

3. **scripts/circuit-networks.lua:1537**
   - Current: `if prototype == nil or prototype.valid == false then`
   - Proposed: `if not prototype then`
   - Rationale: Prototypes don't have a .valid property

4. **scripts/menu-search.lua:167**
   - Current: `if prototype ~= nil and prototype.valid then`
   - Proposed: `if prototype then`
   - Rationale: Prototypes don't have a .valid property

### Category 6: Replace Verbose Boolean Comparisons

1. **scripts/tutorial-system.lua:308**
   - Current: `if players[pindex].tutorial.starting_fuel_provided ~= true then`
   - Proposed: `if not players[pindex].tutorial.starting_fuel_provided then`
   - Rationale: More idiomatic Lua

2. **scripts/graphics.lua:272**
   - Current: `and players[pindex].blueprint_reselecting ~= true`
   - Proposed: `and not players[pindex].blueprint_reselecting`
   - Rationale: More idiomatic Lua

3. **scripts/circuit-networks.lua:782**
   - Current: `if mute ~= true then`
   - Proposed: `if not mute then`
   - Rationale: More idiomatic Lua

4. **scripts/blueprints.lua:638+ (multiple occurrences)**
   - Current: Multiple instances of `if left_clicked ~= true then`
   - Proposed: `if not left_clicked then`
   - Rationale: More idiomatic Lua

5. **scripts/warnings.lua:70**
   - Current: `if recipe == nil and ent.type ~= "furnace" then`
   - Proposed: `if not recipe and ent.type ~= "furnace" then`
   - Rationale: More idiomatic Lua

## Additional Antipatterns Discovered

### 7. Inconsistent Error Handling Patterns

Some functions return nil, others return error strings, and others just return early. This inconsistency makes it hard to handle errors uniformly.

### 8. Magic Numbers in Validity Timeouts

Several places check tick counts or timeouts using magic numbers without constants or explanations.

## Recommendations

### Immediate Actions
1. Establish coding standards for validity checks
2. Create utility functions for common patterns
3. Document API guarantees in a developer guide

### Code Review Guidelines
1. **Trust the API**: Objects from `game.get_player()`, `player.selected`, etc. are valid or nil
2. **Cache API calls**: Store results in local variables
3. **Use idiomatic Lua**: Prefer `not x` over `x == nil` or `x == false`
4. **Document assumptions**: If a function expects valid inputs, document it

### Proposed Utility Functions
```lua
-- Helper for safe entity access
local function safe_entity(entity)
    return entity and entity.valid and entity or nil
end

-- Helper for stack validity
local function valid_stack(stack)
    return stack and stack.valid_for_read
end
```

## Implementation Priority

1. **High Priority**: Fix repeated API calls (performance impact)
2. **Medium Priority**: Remove redundant validity checks (clarity)
3. **Low Priority**: Style improvements (boolean comparisons)

## Conclusion

These antipatterns don't cause functional issues but significantly impact code quality, performance, and maintainability. The changes are small and atomic, making them suitable for gradual improvement. Each proposed change can be evaluated and applied independently based on team priorities.

The most impactful improvements would be:
1. Caching repeated `game.get_player()` calls
2. Establishing clear patterns for validity checking
3. Removing prototype validity checks that can never succeed

By addressing these issues systematically, the codebase will become more maintainable, performant, and easier for new contributors to understand.