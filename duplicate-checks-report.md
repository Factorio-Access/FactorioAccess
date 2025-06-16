# FactorioAccess Duplicate Validation Checks Report

## Executive Summary

This report identifies cases where validation checks are duplicated between function callers and callees. These redundant checks reduce performance and clarity without adding safety, since the same conditions are verified multiple times in a single execution path.

## Key Findings Categories

### 1. Entity Validity Checks

These functions receive entities that have already been validated by their callers:

1. **apply: build_item_in_hand** (scripts/building-tools.lua:21)
   - Validates: `stack.valid` and `stack.valid_for_read` at lines 33-45
   - Callers that already validate:
     - control.lua:1026-1027 validates before calling at line 1033
     - control.lua:1045-1047 validates before calling at line 1053
     - control.lua:3839 validates before calling at line 3843
     - control.lua:3936-3938 validates before calling at line 3944
   - Recommendation: Remove validation from function or document that it expects pre-validated input

2. **apply: equip_it** (scripts/equipment.lua:11)
   - Validates: `stack.valid_for_read` and `stack.valid` at line 22
   - Caller that validates:
     - control.lua:7293-7294 kb_equip_item validates stack before calling at line 7301
   - Recommendation: Remove validation from equip_it since caller ensures validity

3. **apply: circuit_network_menu_run** (scripts/circuit-networks.lua:816)
   - Validates: `ent == nil or ent.valid == false` at lines 820-823
   - Callers that validate:
     - control.lua:5460-5462 validates entity before calling at lines 5466, 5469, 5489
     - control.lua:5492 validates entity before calling at lines 5500, 5503
   - Recommendation: Remove validation from function

4. **keep: can_make_logistic_requests** (scripts/worker-robots.lua)
   - Validates: `if ent == nil or ent.valid == false then return false`
   - Issue: This is a predicate function, so validation might be its purpose
   - Recommendation: Keep as-is, this is the function's job

5. **keep: can_set_logistic_filter** (scripts/worker-robots.lua)
   - Validates: `if ent == nil or ent.valid == false then return false`
   - Issue: This is a predicate function, so validation might be its purpose
   - Recommendation: Keep as-is, this is the function's job

### 2. Stack Validity Checks

1. **apply: send_selected_stack_to_logistic_trash** (scripts/worker-robots.lua)
   - Validates: `stack == nil or stack.valid_for_read == false` 
   - Note: Gets stack from cursor, so validation is needed
   - Recommendation: Keep as-is
   - Review note: player.cursor_stack is factorio API, should always come back valid or nil

2. **get_grenade_or_capsule_range** (scripts/combat.lua)
   - Validates: `stack == nil or stack.valid_for_read == false`
   - Note: Defensive function that calculates ranges
   - Recommendation: Keep as-is for safety

### 3. Entity Type Checks

1. **Underground Belt Functions** (scripts/fa-info.lua)
   - ent_info_underground_belt_type (line 528): Checks `if ent.type == "underground-belt"`
   - ent_info_underground_belt_connection (line 686): Checks `if ent.type == "underground-belt"`
   - Issue: These are called for all entities but only work on underground belts
   - Recommendation: Either pre-filter in caller or rename to clarify they handle all entities
   - Review note: This is intentional.  Having the callees check lets us easily reorder how information is announced.  Leave it alone.

2. **Inserter Filter Setting**
   - Caller (control.lua:7402, 7420): Checks `if ent.type == "inserter"` before calling
   - Callee (control.lua:3118): set_inserter_filter_by_hand doesn't recheck type
   - Recommendation: Good pattern - caller validates type, callee trusts it

3. **Train/Locomotive Checks**
   - Multiple callers check `ent.name == "locomotive"` before calling train functions
   - Functions assume they receive locomotives
   - Recommendation: Good pattern - maintain this separation

### 4. Mixed Validation Patterns

1. **repair_pack_used** (scripts/combat.lua:15)
   - Function validates: `ent and ent.valid` at lines 20-21
   - Some callers validate, others don't
   - Recommendation: Keep validation in function due to mixed caller behavior

2. **ent_info** (scripts/fa-info.lua:1011)
   - Function doesn't validate entity
   - Mixed caller behavior - some validate, some don't
   - Recommendation: Add validation to function or ensure all callers validate

## Proposed Changes

### High Priority (Clear Redundancy)

1. **APPLY: Remove validation from build_item_in_hand**
   - File: scripts/building-tools.lua
   - Lines: 33-45
   - Rationale: All callers validate stack before calling

2. **APPLY: Remove validation from equip_it**
   - File: scripts/equipment.lua
   - Line: 22
   - Rationale: Caller validates before calling

3. **APPLY: Remove validation from circuit_network_menu_run**
   - File: scripts/circuit-networks.lua
   - Lines: 820-823
   - Rationale: All callers validate entity before calling

### Medium Priority (Consider Context)

1. **CONSIDER: Add validation to ent_info**
   - File: scripts/fa-info.lua
   - Line: After 1011
   - Rationale: Mixed caller behavior suggests defensive validation needed

2. **CONSIDER: Rename underground belt functions**
   - Files: scripts/fa-info.lua
   - Functions: ent_info_underground_belt_type, ent_info_underground_belt_connection
   - Rationale: Clarify they handle all entities but only process underground belts

### Low Priority (Working as Intended)

1. **SKIP: Predicate functions (can_make_logistic_requests, can_set_logistic_filter)**
   - Rationale: Their purpose is to validate

2. **SKIP: Functions with mixed caller patterns**
   - Rationale: Need validation for safety

## Implementation Guidelines

When removing duplicate checks:
1. Verify ALL callers validate before removing checks
2. Add comments documenting validation expectations
3. Consider adding assert() for debug builds
4. Update function documentation to clarify preconditions

Example refactoring:
```lua
-- Before
function build_item_in_hand(pindex)
   local stack = game.get_player(pindex).cursor_stack
   if stack == nil or not stack.valid or not stack.valid_for_read then
      return false
   end
   -- ... rest of function
end

-- After
---@param pindex number Player index
---@return boolean success
-- Precondition: Caller must ensure cursor_stack is valid_for_read
function build_item_in_hand(pindex)
   local stack = game.get_player(pindex).cursor_stack
   assert(stack and stack.valid_for_read) -- Debug only
   -- ... rest of function
end
```

## Conclusion

The codebase shows a pattern of defensive programming with validation checks at multiple levels. While this provides safety, many checks are redundant when callers already validate. Removing these duplicate checks would improve performance and clarify the contract between functions. The proposed changes focus on clear cases of redundancy while preserving necessary defensive checks.