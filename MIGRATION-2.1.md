# FactorioAccess 2.0.73 to 2.1.8 Migration Plan

Status: EXECUTED. Target game version 2.1.8 (base API version 6, unchanged).
info.json is now marked 2.1. The mod loads and all 82 in-game tests plus all
Lua tests pass on 2.1.8.

## Execution status

Done (see commits on the f2.1 branch):
- Item 1 fluids, item 2 defines.inventory, item 3 control-behavior descriptors
  (load-blocking), item 4 neighbours, item 5 active write, item 6 recipe
  categories, item 7 product probability, item 8 quickbar -- all complete.
- The two verify-only items resolved as no-change: the `minable` read is still
  valid; `mouse-button-3` is still a valid key (the data stage loads cleanly).

Found during execution (not in the original plan), now fixed:
- data-updates.lua iterated `data.raw.tool`, which is nil in 2.1 because science
  packs became plain items -- switched to `data.raw.item`. (Was a hard load crash.)
- Two `PipeConnection.target.owner.type` reads in fa-info.lua (573, 1048): target
  is now a LuaEntity, so `.owner` was dropped. (Caught by the stricter lint.)
- Kruise_Kontrol_Remote (a forked 2.0 mod we own) is disabled in the install's
  mod-list so the suite can run; it needs its own 2.1 pass, likely a separate
  session. Our wrapper code was still migrated (the `.active` write).

Deliberately deferred (per scope decision):
- Item 3b additive dialog gaps: radar `mode` (surface/universe) and descriptors
  for the new circuit-connectable types (boiler/heat_pipe/lab/land_mine). New-type
  scope is out for now.

Flagged for playtesting (best-effort 1:1, worth a closer look in-game):
- Fluid "locked fluid" now comes from `get_fluid_filter`; an empty recipe-locked
  crafting-machine fluidbox may not report its locked fluid as it did before
  (non-empty boxes still resolve via the fluid segment).
- Quickbar slots now describe all four 2.1 slot kinds: plain item and item filter
  (with inventory count, as before), blueprint-library records (by label, falling
  back to the record type), and spidertron remotes. Item count is only spoken for
  the item/filter kinds. Worth confirming the record/remote wording in-game.

The rest of this document is the original plan, retained for reference.

## Scope

This is a compatibility migration, NOT a feature pass.

- In scope: runtime/data APIs the mod ALREADY calls that 2.1 removed, renamed, or
  changed the signature of. Goal is to restore existing behavior 1:1.
- Out of scope: new 2.1 features and capabilities (circuit network on pipes/labs,
  new prototype properties, etc.), and Space Age support. We adopt a new API only
  to replace one the mod used that is now gone, never to add functionality.
- The simple-gap exception (e.g. a dialog missing an obvious option) is allowed AND
  in several places required: where 2.1 added or restructured an enum/mode that one
  of our fixed-choice dialogs presents, the dialog must be updated so it can represent
  and set the entity's real 2.1 state. A blind user on a 2.1 save who cannot perceive
  or set a mode our dialog omits is a correctness bug, not a missing feature. See the
  "Additive dialog gaps" section. The line we hold: adopt new APIs/values to keep an
  existing dialog correct, not to build dialogs for capabilities we never had.

## How this was found

Three independent inputs, cross-referenced:

1. The 2.1 changelog Removed/Renamed/Changed entries (Scripting, Modding, defines).
2. Six targeted code-search passes over control.lua, scripts/**, syntrax/**, data*.lua.
3. The stricter lint run (undefined-field now visible) against 2.1 type definitions,
   used to catch anything the changelog-driven search missed. This is how the
   `product.probability` item below was found.

Data stage is essentially clean: no selection tools, no recipe categories defined,
no removed prototype properties used. The migration is almost entirely runtime.

---

## Confirmed breaking changes (must fix)

### 1. Fluid API: LuaFluidBox and LuaEntity::fluidbox were removed entirely

Highest-effort item. In 2.1 all fluid interaction moved onto LuaEntity directly,
each call taking a fluid box index. The `LuaFluidBox` class and `entity.fluidbox`
no longer exist.

Old operation to new method mapping (all new methods are on LuaEntity):

- `#entity.fluidbox` (count of fluid boxes) -> `entity.fluids_count`
- `entity.fluidbox[i]` (fluid in box i, table or nil) -> `entity.get_fluid(i)`
- `entity.fluidbox.get_pipe_connections(i)` -> `entity.get_fluid_box_pipe_connections(i)`
- `entity.fluidbox.get_filter(i)` -> `entity.get_fluid_filter(i)`
- `entity.fluidbox.get_prototype(i)` -> `entity.get_fluid_box_prototype(i)`
- `entity.fluidbox.get_locked_fluid(i)` -> VERIFY: most likely `entity.get_fluid_filter(i)`;
  confirm against llm-docs/api-reference/runtime/classes/LuaEntity.md
- `entity.fluidbox.get_fluid_segment_contents(i)` -> VERIFY: `has_fluid_segment(i)` plus
  `get_fluid_segment_fluid(i)`, or `get_fluid_contents`; confirm semantics in the docs
- `entity.remove_fluid({name, amount})` (old) -> `entity.extract_fluid(...)`
  (note: 2.1 also added a NEW `remove_fluid` with different semantics; the old
  remove-and-return behavior is now `extract_fluid`)

Two `---@param fluidbox LuaFluidBox` annotations must be removed/retyped since the
class no longer exists.

Locations:
- control.lua:1273 `start.fluidbox.get_pipe_connections(1)`
- scripts/building-tools.lua:971 `building.fluidbox ~= nil`
- scripts/building-tools.lua:981 `for i = 1, #building.fluidbox`
- scripts/building-tools.lua:982 `building.fluidbox.get_pipe_connections(i)`
- scripts/building-tools.lua:1006 `relevant_box = building.fluidbox[i]`
- scripts/building-tools.lua:1007 `building.fluidbox[i] ~= nil`
- scripts/building-tools.lua:1008 `building.fluidbox[i].name`
- scripts/building-tools.lua:1009 `building.fluidbox.get_locked_fluid(i)`
- scripts/building-tools.lua:1010 `building.fluidbox.get_locked_fluid(i)`
- scripts/building-tools.lua:1142 `local boxes = ent.fluidbox`
- scripts/building-tools.lua:1145 `boxes.get_pipe_connections(i)`
- scripts/fa-info.lua:428 `#ctx.ent.fluidbox`
- scripts/fa-info.lua:570 `ctx.ent.fluidbox.get_pipe_connections(1)`
- scripts/fluids.lua:70 `---@param fluidbox LuaFluidBox`
- scripts/fluids.lua:74 `fluidbox.get_locked_fluid(index)`
- scripts/fluids.lua:76 `fluidbox.get_filter(index)`
- scripts/fluids.lua:80 `fluidbox.get_fluid_segment_contents(index)`
- scripts/fluids.lua:90 `---@param fluidbox LuaFluidBox`
- scripts/fluids.lua:98 `fluidbox.get_pipe_connections(index)`
- scripts/fluids.lua:111 `local fb = ent.fluidbox`
- scripts/fluids.lua:118 `fb.get_pipe_connections(i)`
- scripts/fluids.lua:152 `fb.get_locked_fluid(i)`
- scripts/fluids.lua:196 `local fb = ent.fluidbox`
- scripts/fluids.lua:200 `fb.get_pipe_connections(1)`
- scripts/fluids.lua:233 `local fluidbox = entity.fluidbox`
- scripts/fluids.lua:236 `#fluidbox > 0`
- scripts/fluids.lua:237 `for i = 1, #fluidbox`
- scripts/fluids.lua:238 `fluidbox.get_prototype(i)`
- scripts/fluids.lua:239 `fluidbox.get_locked_fluid(i)`
- scripts/fluids.lua:240 `local fluid_data = fluidbox[i]`
- scripts/ui/tabs/fluids.lua:80 `ent.remove_fluid({...})` -> `extract_fluid`

Risk: the old indexing returned a fluid table with name/amount/temperature; confirm
`get_fluid(i)` returns the same shape and nil handling. The locked-fluid and
fluid-segment-contents mappings are the two that need doc confirmation before coding.

### 2. defines.inventory crafter consolidation

2.1 removed the per-machine inventory defines and replaced them with shared
`crafter_*` defines:
- `assembling_machine_input`, `furnace_source`, `rocket_silo_input` -> `crafter_input`
- `assembling_machine_output`, `furnace_result`, `rocket_silo_output` -> `crafter_output`
- `assembling_machine_modules`, `furnace_modules`, `rocket_silo_modules` -> `crafter_modules`
- `assembling_machine_trash`, `furnace_trash` -> `crafter_trash`

Runtime `defines.inventory.X` reads now evaluate to nil and break `get_inventory`.

Real runtime breaks:
- scripts/ui/inventory-grid.lua:57 `inventory_index == defines.inventory.assembling_machine_input`
- scripts/ui/inventory-grid.lua:58 `defines.inventory.furnace_source`
- scripts/ui/inventory-grid.lua:69 `defines.inventory.assembling_machine_output`
- scripts/ui/inventory-grid.lua:70 `defines.inventory.furnace_result`
- scripts/tests/furnace-fuel-test.lua:20 and :88 `defines.inventory.furnace_source`

Also clean up the dead string keys in scripts/consts.lua:228-239 (a priority-number
lookup keyed by inventory-name strings, with "maps to crafter_input" comments). These
do not crash on their own but reference removed names and should collapse to the
`crafter_*` keys. Plus the doc-comment alias lists in scripts/inventory-utils.lua
(lines around 194-247 and 315/318).

Fix: replace each removed `defines.inventory.X` with the `crafter_*` equivalent. Note
the same physical inventory now has one define across all three machine types, so any
code that distinguished assembler vs furnace vs silo by inventory define must use a
different discriminator (likely entity type), not the inventory index.

### 3. Control behavior descriptors (scripts/control-behavior-descriptors.lua) -- LOAD-BLOCKING

CRITICAL: this descriptor table is a module-level literal built at `require` time with
direct references to removed defines. Those evaluate to nil and crash on load, so the
MOD WILL NOT LOAD on 2.1 until these three are fixed. Do these first.

- `[defines.control_behavior.type.storage_tank]` is now `[nil]` (the type was renamed
  to `single_fluid_box`), which is a table-constructor error.
  Location: control-behavior-descriptors.lua:672. Fix: rename the key to
  `defines.control_behavior.type.single_fluid_box`.
- `defines.control_behavior.cargo_landing_pad.exclusive_mode.{none,send_contents,set_requests}`
  no longer exist (the whole `cargo_landing_pad` control_behavior subkey was removed).
  Locations: control-behavior-descriptors.lua:182, 186, 190 (choice values), 178 (the
  `circuit_exclusive_mode_of_operation` CHOICE field).
- `defines.control_behavior.logistic_container.exclusive_mode.{none,send_contents,set_requests}`
  likewise removed.
  Locations: control-behavior-descriptors.lua:373, 377, 381 (choice values), 369 (field).

Fix for the two exclusive_mode dialogs (CORRECTED from an earlier draft that said
"delete the field"): 2.1 did not just remove the setting, it split the 3-way exclusive
choice (none / send_contents / set_requests) into two INDEPENDENT booleans. The
control behaviors now expose `read_contents` and `set_requests` (LuaCargoLandingPad-
ControlBehavior and LuaLogisticContainerControlBehavior both gained these). So replace
each `circuit_exclusive_mode_of_operation` CHOICE field with two BOOLEAN fields named
`read_contents` and `set_requests`. This preserves the user's ability to set both,
which deleting the field would have silently removed.

- `include_fuel` renamed to `read_fuel` on assembling machine and furnace control behavior.
  Locations: control-behavior-descriptors.lua:121 (assembling machine), 224 (furnace).
  The reactor descriptor at :530 already uses `read_fuel` (reference pattern). Straight rename.

### 3b. Additive dialog gaps: enums/types 2.1 added that our dialogs must represent

These are not crashes, but per the scope note they are required for correctness: on a
2.1 save, an entity can be in a state our fixed-choice dialog cannot show or set.

Checked all nine enum-backed CHOICE selectors in the descriptor file against the 2.1
defines. Six are unchanged and need nothing: inserter.hand_read_mode, lamp.color_mode,
mining_drill.resource_read_mode, roboport.read_items_mode, rocket_silo.read_mode,
transport_belt.content_read_mode.

Gaps found:

- Radar gained `defines.control_behavior.radar.mode` with values `surface` and
  `universe` (cross-surface signal transfer). Our radar descriptor is `fields = {}`
  (control-behavior-descriptors.lua:438-441), so it exposes nothing. DECISION NEEDED:
  adding a mode choice here is arguably restoring representable state vs adding a
  capability we never had (we exposed no radar circuit settings before). Recommend
  adding the mode choice if radar circuit settings are reachable through our UI on
  2.1; confirm with you.
- Four new circuit-connectable entity types exist in 2.1 that our descriptor table has
  no entry for: `boiler`, `heat_pipe`, `lab`, `land_mine`
  (defines.control_behavior.type.*). On a 2.1 save a blind user could select one of
  these circuit-connected and open our circuit dialog. REQUIRED at minimum: confirm the
  descriptor consumer degrades gracefully (empty/“no settings” dialog) rather than
  erroring on an unknown type. Full per-type descriptors for these is new functionality
  and a separate decision; the no-crash guarantee is the migration-required part.

Note: this audit covered the control-behavior descriptor system, which is the mod's
main enum-backed dialog generator. Any other hand-rolled fixed-choice selector tied to
a game enum should get the same "did 2.1 add a value" check before sign-off.

### 4. LuaEntity::neighbours read removed

Replaced by type-specific reads (belt_neighbours, heat_neighbours, fluidbox_neighbours,
wall_neighbours, cliff_neighbours, underground_belt_neighbour,
neighbour_connectable_connections). Each call site must pick the right replacement
based on the entity type it is inspecting.

Locations (all reads on LuaEntity):
- control.lua:1288 `local neighbour = start.neighbours`
- scripts/fa-info.lua:880 `if ent.neighbours ~= nil then`
- scripts/fa-info.lua:883 `ent.neighbours.position`
- scripts/fa-info.lua:884 `ent.neighbours.position`
- scripts/transport-belts.lua:143 `behind = connectable.neighbours`
- scripts/transport-belts.lua:159 `and connectable.neighbours`
- scripts/transport-belts.lua:161 `table.insert(neighbours, connectable.neighbours)`
- scripts/transport-belts.lua:747 `not candidate.neighbours`

Not affected (different class, leave alone): scripts/worker-robots.lua:358 and :364 use
`cell.neighbours` on LuaLogisticCell.

Note: the transport-belts.lua sites are about belts, so they map to `belt_neighbours`.
The fa-info.lua and control.lua sites need their entity context checked to pick the
correct replacement (pipes -> fluidbox_neighbours, etc).

### 5. LuaEntity::active write removed

The write was removed; use `disabled_by_script` instead. Reads of `.active` are still
valid.

Location:
- scripts/kruise-kontrol-wrapper.lua:59 `p.vehicle.active = true` -> set
  `p.vehicle.disabled_by_script = false`

Reads at kruise-kontrol-wrapper.lua:58 and :100 stay as-is. Verify the inverted
boolean sense when switching to disabled_by_script.

### 6. LuaRecipe::category / additional_categories removed

Replaced by the `categories` array.

Locations:
- scripts/crafting.lua:82 `crafting_categories[recipe.category]` (a single-category
  membership check; must become "does any recipe.categories entry match")
- scripts/recipe-helpers.lua:66 `local categories = { recipe.category }`
- scripts/recipe-helpers.lua:67-68 the `recipe.additional_categories` loop

Fix: `get_recipe_categories` in recipe-helpers.lua collapses to returning
`recipe.categories` directly. crafting.lua:82 iterates that array.

### 7. Product probability renamed (found via lint, not changelog search)

Runtime ItemProduct / FluidProduct dropped `probability`; it is now
`independent_probability` (same [0,1] meaning). Confirmed in
llm-docs/api-reference/runtime/concepts/ItemProduct.md.

Location:
- scripts/recipe-helpers.lua:56 `if product.probability and product.probability < 1`
- scripts/recipe-helpers.lua:57 `product.probability * 100`

Fix: `product.probability` -> `product.independent_probability` (2 reads on one logical
check). 1:1 restoration of the "show probability if under 100%" behavior. There is also
a `shared_probability` field for a different mechanic; we intentionally do not adopt it.

### 8. Quickbar slot methods changed signature

`LuaPlayer::get_quick_bar_slot` / `set_quick_bar_slot` now take a quick bar slot
location as (page index, slot index) instead of a single flat index, and `set` takes
the item as the third argument.

Locations (all in scripts/quickbar.lua):
- :47 `get_quick_bar_slot(index + 10 * page)`
- :78 `set_quick_bar_slot(index + 10 * page, stack_cur)`
- :85 `get_quick_bar_slot(index + 10 * page)`
- :89 `set_quick_bar_slot(index + 10 * page, nil)`
- :99 `get_quick_bar_slot(1 + 10 * (index - 1))`

Current code computes a flat index from a 0-based `page` (from
`get_active_quick_bar_page(1) - 1`) and a 1..10 slot. The conversion:
- get: `get_quick_bar_slot(page_index, slot_index)`
- set: `set_quick_bar_slot(page_index, slot_index, item)`
- read_switched_quick_bar:99 reads slot 1 of page `index`, so `(index, 1)`.

VERIFY against llm-docs/api-reference/runtime/classes/LuaControl.md whether page and
slot indexes are both 1-based; if so use the 1-based page directly (drop the `- 1`).
This also matches the lint missing-parameter and the LuaItemStack-to-integer warnings
on these exact lines.

---

## Verify only (not confirmed breaks)

- scripts/ui/selectors/copy-paste-selector.lua:81 reads `entity.minable`. Only the
  minable WRITE was removed in 2.1 (use minable_flag); the read should still work.
  Confirm, no change expected.
- data/input.lua:902 `key_sequence = "mouse-button-3"`. 2.1 removed deprecated/
  undocumented key names from custom-input key sequences. Confirm mouse-button-3 is
  still a valid key name; it is the only mouse binding in the mod.

## Out of scope / not breaks

- The transport_line param-type-mismatch lint warnings (control.lua:3374-3377,
  transport-belts.lua several) are PREEXISTING (present before 2.1) and are a typing
  annotation issue, not a runtime break.
- Lint undefined-field on control.lua:3093 (`cb.circuit_enable_disable`,
  `cb.connect_to_logistic_network`) and scripts/combat/combat-data.lua:86, 187, 369,
  399, 400 (`type`, `final_attack_result`, `min_range`, `range`) are preexisting
  false positives from imprecise union typing (the fields exist on specialized
  subtypes/prototypes). The 2.1 changelog does not touch them. Not migration items.
- All "Added ..." entries in the changelog (new reads, new prototype properties, new
  events, circuit-network expansion, Space Age changes) are deliberately skipped.

---

## Suggested execution order

1. Control-behavior descriptors (item 3) FIRST: these are load-blocking, so the mod
   cannot load or be tested until they are done. Includes the storage_tank ->
   single_fluid_box key rename, the two exclusive_mode -> read_contents/set_requests
   toggle conversions, and include_fuel -> read_fuel.
2. Additive dialog gaps (item 3b): the boiler/heat_pipe/lab/land_mine no-crash check is
   migration-required; the radar mode choice is a decision for you.
3. Fluids (item 1): largest and self-contained; confirm the locked-fluid and
   fluid-segment-contents mappings in the docs first.
4. defines.inventory crafter consolidation (item 2) plus consts.lua/inventory-utils
   cleanup.
5. neighbours (item 4): per-site entity-type check.
6. Small mechanical items: active write (5), recipe categories (6), product
   probability (7), quickbar signature (8).
7. Resolve the two verify-only items.

## How to validate

- The stricter lint (already committed) is the primary gate while the game cannot be
  launched. Each fixed item should remove its corresponding undefined-field /
  undefined-doc-name / missing-parameter warnings. Watch the LuaFluidBox
  undefined-doc-name and the quickbar missing-parameter counts drop to zero.
- The mod's own dynamic-typing false positives (syntrax vm, UI tablist internals) will
  remain in the lint and are not part of this migration; do not chase them.
- Game-launch testing (tests, manual play) is blocked until info.json is marked 2.1
  compatible. Marking compatibility and a real test pass is the final step, separate
  from this code migration.
