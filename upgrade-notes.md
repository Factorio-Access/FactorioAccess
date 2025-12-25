# Upgrade Planner Implementation Plan

## API References

- `llm-docs/api-reference/runtime/classes/LuaItemCommon.md` - get_mapper, set_mapper, mapper_count, clear_upgrade_item, is_upgrade_item, label
- `llm-docs/api-reference/runtime/concepts/UpgradeMapperSource.md` - type, name
- `llm-docs/api-reference/runtime/concepts/UpgradeMapperDestination.md` - type, name
- `llm-docs/api-reference/runtime/classes/LuaEntityPrototype.md` - fast_replaceable_group
- `llm-docs/api-reference/runtime/classes/LuaItemPrototype.md` - category, tier (for modules)
- `llm-docs/api-reference/runtime/classes/LuaItemStack.md` - cursor_stack_temporary, import_stack, export_stack

## Existing Code

- `scripts/ui/selectors/upgrade-selector.lua` - Box selector for area upgrade
- `scripts/ui/tabs/item-chooser.lua` - Has filter parameter support
- `scripts/ui/tabs/entity-chooser.lua` - Has filter_type parameter
- `scripts/fa-info.lua` - Needs upgrade planner support
- `scripts/ui/menus/blueprint-book-menu.lua` - Pattern for book handling
- `scripts/ui/inventory-grid.lua` - Ctrl+click handling

## API Summary

```lua
-- Reading rules (1-indexed)
local from = planner.get_mapper(index, "from")  -- Returns {type="item"} if undefined
local to = planner.get_mapper(index, "to")      -- Returns nil if undefined

-- Writing rules (auto-expands list)
planner.set_mapper(index, "from", { type = "entity", name = "transport-belt" })
planner.set_mapper(index, "to", { type = "entity", name = "fast-transport-belt" })

-- Clearing
planner.set_mapper(index, "from", nil)
planner.set_mapper(index, "to", nil)
planner.clear_upgrade_item()  -- Reset all

-- Rule types
-- Entity: { type = "entity", name = "entity-prototype-name" }
-- Module: { type = "item", name = "module-prototype-name" }
```

## Entry Point

`fa-rightbracket` in control.lua opens the upgrade planner menu when planner is in hand.

## Task 1: Create scripts/upgrade-planner.lua

```lua
local mod = {}

-- Read single rule into MessageBuilder
-- Format: "Transport belt to Fast transport belt"
function mod.read_planner_rule(mb, planner, index)

-- Describe planner: name, rule count, first few rules
function mod.describe_planner(mb, planner)

return mod
```

## Task 2: Update scripts/fa-info.lua

Call upgrade-planner.describe_planner for upgrade planners.

## Task 3: Create scripts/ui/menus/upgrade-planner-menu.lua

**Menu structure:** 24 slots always shown.

Each slot displays:
- Empty: "No rule, slot 1"
- Configured: "Transport belt to Fast transport belt, slot 1"

**Controls:**
- Click (Enter): Opens entity rule flow. If slot has rule, replaces it.
- on_action1 (fa-m): Opens module rule flow instead.
- on_clear (Backspace): Removes rule.
- Actions at bottom: "Clear all", "Set name", "Export", "Import"

**Binds:** Hand contents.

**On any modification:** Set `cursor_stack.cursor_stack_temporary = false` to make permanent.

## Task 4: Entity Rule Flow (Chained Helper UIs)

Three UIs chain together:

**upgrade-entity-step1** (helper):
- Opens immediately with entity chooser as child (filter: entities with fast_replaceable_group)
- on_child_result: closes with result, passes source entity name to step2

**upgrade-entity-step2** (helper):
- Receives source entity name in parameters
- Opens immediately with entity chooser as child (filter: same fast_replaceable_group as source)
- on_child_result: closes with full rule `{ from = {...}, to = {...} }`

**Main menu on_child_result:**
- Receives complete rule
- Writes to planner at the clicked slot index

## Task 5: Module Rule Flow (Chained Helper UIs)

Same pattern:

**upgrade-module-step1** (helper):
- Opens with item chooser filtered to modules (prototype.type == "module")
- on_child_result: passes source module name to step2

**upgrade-module-step2** (helper):
- Opens with item chooser filtered to modules
- on_child_result: closes with full rule

## Task 6: Add Entity Chooser Filters

In `scripts/ui/tabs/entity-chooser.lua`, add to FILTERS:

```lua
[mod.FILTER_TYPES.UPGRADEABLE] = function(proto)
   return proto.fast_replaceable_group ~= nil
end,
[mod.FILTER_TYPES.SAME_FAST_GROUP] = function(proto)
   -- Uses global_parameters.fast_replaceable_group
   return proto.fast_replaceable_group == params.fast_replaceable_group
end,
```

## Task 7: Add Module Filter to Item Chooser

In `scripts/ui/tabs/item-chooser.lua`, add filter support:

```lua
-- In build_item_tree, check global_parameters.item_type_filter
if params.item_type_filter == "module" then
   -- Only include items where proto.type == "module"
end
```

## Task 8: Blueprint Book Integration

**blueprint-book-menu.lua:** Add upgrade planners to book contents tab alongside blueprints and deconstruction planners.

**inventory-grid.lua:** Ctrl+click on book with upgrade planner in hand inserts it.

**Cycling:** Wherever book cycling happens, include upgrade planners.

## Task 9: Register UIs

router.lua:
```lua
UPGRADE_PLANNER = "upgrade_planner",
UPGRADE_ENTITY_STEP1 = "upgrade_entity_step1",
UPGRADE_ENTITY_STEP2 = "upgrade_entity_step2",
UPGRADE_MODULE_STEP1 = "upgrade_module_step1",
UPGRADE_MODULE_STEP2 = "upgrade_module_step2",
```

control.lua: Require the new menu, fa-rightbracket handler opens it.

## Task 10: Locale Keys

```ini
[fa]
upgrade-no-rule=No rule, slot __1__
upgrade-slot=__1__, slot __2__
upgrade-planner-title=Upgrade planner
upgrade-rule-added=Rule added
upgrade-rule-removed=Rule removed
upgrade-rules-cleared=All rules cleared
upgrade-planner-exported=Exported
upgrade-planner-imported=Imported
upgrade-planner-import-failed=Import failed
```

## Notes

- Downgrading works - just a normal rule with higher tier as source
- Quality, module_limit, module_filter: deferred
- Import/export: use LuaItemStack.import_stack / export_stack
