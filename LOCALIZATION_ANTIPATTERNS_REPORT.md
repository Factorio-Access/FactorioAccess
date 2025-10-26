# Localization Antipatterns Report

This report identifies two types of localization issues in the FactorioAccess codebase:
1. **Unlocalised strings**: Hard-coded English text that should use locale keys
2. **Lack of flexibility**: Multiple sequential `fragment()` calls building a single semantic message that should be one parameterized locale string

---

## control.lua

### Unlocalised Strings

**Line 1325:**
```lua
Speech.speak(pindex, "Teleport Failed")
```
**Change to:** `Speech.speak(pindex, { "fa.teleport-failed" })`

**Line 1341:**
```lua
Speech.speak(pindex, "Tile Occupied")
```
**Change to:** `Speech.speak(pindex, { "fa.tile-occupied" })`

**Line 1922:**
```lua
Speech.speak(pindex, "Failed to nudge self")
```
**Change to:** `Speech.speak(pindex, { "fa.nudge-failed" })`

**Line 2122:**
```lua
local cursor_location_description = "At"
```
**Change to:** `local cursor_location_description = { "fa.at" }`

**Line 2348:**
```lua
Speech.speak(pindex, "Cleared rulers")
```
**Change to:** `Speech.speak(pindex, { "fa.rulers-cleared" })`

**Line 2391:**
```lua
Speech.speak(pindex, "No target")
```
**Change to:** `Speech.speak(pindex, { "fa.no-target" })`

**Line 2421:**
```lua
Speech.speak(pindex, "Cannot anchor cursor while there is no character")
```
**Change to:** `Speech.speak(pindex, { "fa.cannot-anchor-no-character" })`

**Line 2430:**
```lua
Speech.speak(pindex, "Cursor anchored")
```
**Change to:** `Speech.speak(pindex, { "fa.cursor-anchored" })`
**Note:** Consider "anchored cursor" instead for better screen reader experience (adjective first)

**Lines 2931, 2937:**
```lua
Speech.speak(pindex, "No fluids to flush")
```
**Change to:** `Speech.speak(pindex, { "fa.no-fluids-to-flush" })`

**Line 2974:**
```lua
Speech.speak(pindex, "Collecting items ")
```
**Change to:** `Speech.speak(pindex, { "fa.collecting-items" })`
**Note:** Remove trailing space

**Line 3584:**
```lua
Speech.speak(pindex, "Flipped horizontal")
```
**Change to:** `Speech.speak(pindex, { "fa.flipped-horizontal" })`

**Line 3622:**
```lua
Speech.speak(pindex, "Flipped vertical")
```
**Change to:** `Speech.speak(pindex, { "fa.flipped-vertical" })`

**Line 3727:**
```lua
Speech.speak(pindex, "Saving Game, please wait 3 seconds.")
```
**Change to:** `Speech.speak(pindex, { "fa.saving-game-wait" })`

**Line 3757:**
```lua
Speech.speak(pindex, "Vanilla mode enabled")
```
**Change to:** `Speech.speak(pindex, { "fa.vanilla-mode-enabled" })`

**Line 3763:**
```lua
Speech.speak(pindex, "Vanilla mode disabled")
```
**Change to:** `Speech.speak(pindex, { "fa.vanilla-mode-disabled" })`

**Line 4136:**
```lua
Speech.speak(pindex, "Not implemented in Factorio 2.0 yet due to API limitations")
```
**Change to:** `Speech.speak(pindex, { "fa.not-implemented-factorio-2" })`

### Lack of Flexibility

**Lines 2084-2090:**
```lua
message:fragment({ "fa.build-preview-intro" })
message:fragment({ "fa.build-preview-wide", tostring(p_width) })
message:fragment({ "fa.build-preview-east" })
message:fragment({ "fa.build-preview-and" })
message:fragment({ "fa.build-preview-high", tostring(p_height) })
message:fragment({ "fa.build-preview-south" })
```
**Change to:** Single locale string with parameters:
```lua
message:fragment({ "fa.build-preview-dimensions", tostring(p_width), tostring(p_height) })
```
**New locale key:** `build-preview-dimensions=, preview is __1__ tiles wide to the East and __2__ tiles high to the South`
**Note:** The directions appear hardcoded; consider making them dynamic based on `p_dir`

---

## scripts/building-tools.lua

### Unlocalised Strings

**Line 357:**
```lua
Speech.speak(pindex, "Ghost tiles not yet supported")
```
**Change to:** `Speech.speak(pindex, { "fa.building-ghost-tiles-not-supported" })`

**Line 373:**
```lua
Speech.speak(pindex, { "", "Placed ghost ", { "entity-name." .. decision.entity_name } })
```
**Change to:** `Speech.speak(pindex, { "fa.building-placed-ghost", { "entity-name." .. decision.entity_name } })`

**Line 654:**
```lua
return " cannot place this here "
```
**Change to:** `return { "fa.building-cannot-place-here" }`

**Lines 1315-1320:**
```lua
Speech.speak(
   pindex,
   "Placed steam engine near boiler at "
      .. math.floor(boiler.position.x)
      .. ","
      .. math.floor(boiler.position.y)
)
```
**Change to:** `Speech.speak(pindex, { "fa.building-placed-steam-engine", math.floor(boiler.position.x), math.floor(boiler.position.y) })`

### Lack of Flexibility

**Lines 1393-1406:**
```lua
if obstacle_ent ~= nil then
   table.insert(result, ", ")
   table.insert(result, localising.get_localised_name_with_fallback(obstacle_ent))
   table.insert(result, " in the way, at ")
   table.insert(result, tostring(math.floor(obstacle_ent.position.x)))
   table.insert(result, ", ")
   table.insert(result, tostring(math.floor(obstacle_ent.position.y)))
elseif #water_tiles_in_area > 0 then
   local water = water_tiles_in_area[1]
   table.insert(result, ", water ")
   table.insert(result, " in the way, at ")
   table.insert(result, tostring(math.floor(water.position.x)))
   table.insert(result, ", ")
   table.insert(result, tostring(math.floor(water.position.y)))
end
```
**Change to:** Use MessageBuilder with parameterized locale strings:
```lua
if obstacle_ent ~= nil then
   message:fragment({ "fa.building-obstacle-in-way",
      localising.get_localised_name_with_fallback(obstacle_ent),
      math.floor(obstacle_ent.position.x),
      math.floor(obstacle_ent.position.y)
   })
elseif #water_tiles_in_area > 0 then
   local water = water_tiles_in_area[1]
   message:fragment({ "fa.building-water-in-way",
      math.floor(water.position.x),
      math.floor(water.position.y)
   })
end
```

---

## scripts/blueprints.lua

### Unlocalised Strings

**Line 179:**
```lua
if not stack.is_blueprint_setup() then return "Blueprint empty" end
```
**Change to:** `if not stack.is_blueprint_setup() then return { "fa.blueprints-empty" } end`

**Lines 284-286:**
```lua
table.insert(result, "Blueprint book ")
table.insert(result, label)
if in_hand then table.insert(result, " in hand") end
```
**Change to:** Use parameterized locale string:
```lua
table.insert(result, { "fa.blueprints-book-label", label, in_hand and 1 or 0 })
```

---

## scripts/equipment.lua

### Unlocalised Strings

**Line 86:**
```lua
message:fragment("Error: no equipment grid available on " .. entity.name)
```
**Change to:** `message:fragment({ "fa.equipment-error-no-grid", entity.name })`

**Line 198:**
```lua
return "Error: No relevant ammo found for reloading"
```
**Change to:** `return { "fa.equipment-no-ammo-found" }`

**Lines 210-214:**
```lua
result = "Fully reloaded all three weapons"
result = "Reloaded weapons with any available ammunition, "
```
**Change to:** Use locale keys `{ "fa.equipment-fully-reloaded" }`, etc.

**Lines 246, 339, 495, 503:**
```lua
return "Error: Not enough empty inventory slots, at least 6 needed"
table.insert(result, "No character")
return "Error: No character or entity"
return "No armor."
```
**Change to:** Use locale keys for all error messages

**Lines 613-636 and 956-980:**
```lua
function mod.get_equipment_category(equipment)
   local type_name = equipment.type
   if type_name == "battery-equipment" then
      return "a battery"
   elseif type_name == "energy-shield-equipment" then
      return "a shield"
   -- ... etc
```
**Change to:** Use locale keys like `{ "fa.equipment-category-battery" }`, etc.

---

## scripts/worker-robots.lua

### Unlocalised Strings

**Lines 81-110, 125, 127, 175-176, 199:**
Multiple instances of hard-coded error messages and descriptions.
**Change to:** Use locale keys throughout

### Lack of Flexibility

**Lines 203-222:**
```lua
if min_only then
   if min_val > 0 then
      msg_builder:fragment("x")
      msg_builder:fragment(tostring(min_val))
   end
else
   if min_val > 0 and max_val then
      msg_builder:fragment("min")
      msg_builder:fragment(tostring(min_val))
      msg_builder:fragment("max")
      msg_builder:fragment(tostring(max_val))
   -- ... etc
```
**Change to:** Use parameterized locale strings for each case

**Lines 353-385, 384-390, 397-411, 444-455:**
String concatenation for roboport network descriptions.
**Change to:** Use parameterized locale strings

---

## scripts/tutorial-system.lua

### Unlocalised Strings

**Lines 318-321, 332-340:**
```lua
local str2 = ", tutorial step " .. j .. " of " .. tutorial.chapter_lengths[i] .. " in chapter " .. i
game.get_player(pindex).print(
   "Tutorial message, chapter "
      .. storage.players[pindex].tutorial.chapter_index
      .. " , step "
      .. storage.players[pindex].tutorial.step_index
      .. ": ",
```
**Change to:** Use parameterized locale strings

---

## scripts/transport-belts.lua

### Unlocalised Strings

**Lines 749-822 (entire function `mod.set_splitter_priority`):**
```lua
result = "no message"
result = "Cleared splitter filter"
result = "filter set to " .. filter_item_stack.name
result = result .. ", from the left"
result = "equal input priority"
result = "left input priority"
-- ... many more
```
**Change to:** Convert all return values to use locale keys

### Lack of Flexibility

**Lines 833-876:**
```lua
if input == "none" then
   msg:fragment("input balanced,")
elseif input == "right" then
   msg:fragment("input priority right")
   msg:fragment("which is")
   msg:fragment(FaUtils.direction_lookup(FaUtils.rotate_90(ent.direction)))
   msg:fragment(",")
-- ... etc
```
**Change to:** Use parameterized locale strings for each configuration

---

## scripts/recipe-helpers.lua

### Unlocalised Strings

**Line 45:**
```lua
message:fragment(" x " .. product.amount_min .. "-" .. product.amount_max)
```
**Change to:** `message:fragment({ "fa.recipe-range", product.amount_min, product.amount_max })`

---

## scripts/driving.lua

### Lack of Flexibility

**Lines 21-22:**
```lua
result:fragment({ "fa.driving-car", { "entity-name." .. vehicle.name } })
result:fragment(", ")
result:fragment(mod.fuel_inventory_info(vehicle))
```
**Change to:** Combine into single locale string with fuel info as parameter

**Lines 41-52:**
```lua
result:fragment({ "fa.driving-contains-fuel" })
result:fragment({ "fa.driving-fuel-item", { "item-name." .. itemtable[1].name }, tostring(itemtable[1].count) })
result:fragment(" ")
if #itemtable > 1 then
   result:fragment({ "fa.and" })
   result:fragment({ "fa.driving-fuel-item", { "item-name." .. itemtable[2].name }, tostring(itemtable[2].count) })
```
**Change to:** Use parameterized locale string or `FaUtils.build_list()` for proper list formatting

---

## scripts/fa-info.lua

### Unlocalised Strings

**Lines 1169, 1171:**
```lua
if ctx.ent.type == "inserter" and ctx.ent.inserter_filter_mode == "blacklist" then
   ctx.message:fragment("Denies")
else
   ctx.message:fragment("Filters for")
end
```
**Change to:** `ctx.message:fragment({ "fa.filter-denies" })` and `ctx.message:fragment({ "fa.filter-allows" })`

**Line 1223:**
```lua
ctx.message:fragment("producing")
```
**Change to:** `ctx.message:fragment({ "fa.ent-info-producing" })`

**Lines 1430-1445:**
```lua
if pol <= 0.1 then
   result = "No" .. result
elseif pol < 10 then
   result = "Minimal" .. result
elseif pol < 30 then
   result = "Low" .. result
-- ... etc
```
**Change to:** Replace with complete locale keys like `{ "fa.pollution-level-none" }`, `{ "fa.pollution-level-minimal" }`, etc.

**Lines 1458, 1470, 1485:**
```lua
Speech.speak(pindex, "No damaged structures within 1000 tiles.")
```
**Change to:** `Speech.speak(pindex, { "fa.no-damaged-structures-in-range", 1000 })`

**Lines 1540, 1590:**
```lua
if not prototype then return string.format("Error: Unknown item or fluid '%s'", prototype_name) end
if not prototype then return "Error: No selected item or fluid" end
```
**Change to:** Use locale keys `{ "fa.error-unknown-item", prototype_name }` and `{ "fa.error-no-selected-item" }`

**Line 1683:**
```lua
status_lookup[23] = "Full burnt result output"
```
**Change to:** Use locale key

### Lack of Flexibility

**Lines 1497-1503:**
```lua
local result = Localising.get(closest, pindex)
   .. "  damaged at "
   .. min_dist
   .. " "
   .. aligned_note
   .. FaUtils.direction_lookup(dir)
   .. ", cursor moved. "
```
**Change to:** Use MessageBuilder with parameterized locale string `{ "fa.damaged-entity-found", entity_name, distance, aligned_note, direction }`

**Lines 1630-1647:**
Production statistics with hard-coded "Produced", "Consumed", etc.
**Change to:** Use parameterized locale strings

---

## scripts/circuit-network.lua

### Unlocalised Strings

**Lines 506, 546, 621:**
```lua
if #all_signals == 0 then return { "", "No outputs" } end
if not next(neighbors) then return { "", "No copper wire connections" } end
if not next(neighbors) then return { "", "No circuit network connections" } end
```
**Change to:** Use locale keys `{ "fa.circuit-no-outputs" }`, `{ "fa.circuit-no-copper-connections" }`, `{ "fa.circuit-no-circuit-connections" }`

---

## scripts/combat.lua

### Unlocalised Strings

**Lines 454, 463, 466, 470, 481:**
```lua
abort_message = "Aiming alert, scroll mouse wheel to zoom out."
abort_message = "Aiming alert, move cursor to sync mouse."
abort_message = "Range alert, target too close, hold to fire anyway."
```
**Change to:** Use locale keys

### Lack of Flexibility

**Lines 37-38:**
```lua
msg:fragment({ "fa.combat-fully-repaired" })
msg:fragment(Localising.get_localised_name_with_fallback(ent))
```
**Change to:** `msg:fragment({ "fa.combat-fully-repaired-entity", Localising.get_localised_name_with_fallback(ent) })`

---

## scripts/ui/menus/blueprints-menu.lua

### Unlocalised Strings

**Lines 65, 67:**
```lua
elseif bp_stack.is_blueprint_book then
   c.message:fragment(bp_stack.label or "unnamed book")
else
   c.message:fragment("unknown item")
```
**Change to:** `{ "fa.unnamed-book" }` and `{ "fa.unknown-item" }`

**Line 49:**
```lua
builder:add_label("blueprint-info", { "fa.ui-blueprints-menu-basic", bp.label or "no name" })
```
**Change to:** `bp.label or { "fa.unnamed" }`

---

## scripts/ui/menus/crafting-queue.lua

### Lack of Flexibility

**Line 47:**
```lua
label_ctx.message:fragment(name):fragment(" x " .. queue_item.count)
```
**Change to:** `label_ctx.message:fragment({ "fa.crafting-queue-item", name, queue_item.count })`

---

## scripts/ui/menus/debug-menu.lua

### Unlocalised Strings

**Lines 56, 96-97:**
```lua
result_ctx.controller.message:fragment("Form builder test closed with result: " .. tostring(result))
msg:fragment("Box selection result: ")
msg:fragment(serpent.line(result, { nocode = true }))
```
**Change to:** Use locale keys for debug messages

---

## scripts/ui/menus/debug-formbuilder.lua

### Unlocalised Strings

**Lines 70, 76, 143-144:**
Debug messages that should use locale keys

---

## scripts/ui/menus/crafting.lua

### Unlocalised Strings

**Lines 155, 158:**
```lua
item_ctx.message:fragment("Error: Recipe has no valid product name")
item_ctx.message:fragment("Error: Recipe has no products")
```
**Change to:** Use locale keys

---

## scripts/ui/menus/fast-travel-menu.lua

### Unlocalised Strings

**Line 125:**
```lua
ctx.message:fragment("of")
```
**Change to:** Combine with surrounding fragments into single locale string

### Lack of Flexibility

**Lines 35-42:**
Building travel point label across multiple fragments with hardcoded comma.
**Change to:** Single parameterized locale string

---

## scripts/ui/tabs/spidertron-config.lua

### Lack of Flexibility

**Lines 54-60:**
```lua
ctx.message:fragment({ "fa.spidertron-autopilot-destination" })
ctx.message:fragment(tostring(math.floor(first.x)))
ctx.message:fragment(tostring(math.floor(first.y)))
if #destinations > 1 then
   ctx.message:fragment({ "fa.spidertron-autopilot-plus-more", tostring(#destinations - 1) })
end
ctx.message:fragment({ "fa.spidertron-autopilot-click-to-change" })
```
**Change to:** `{ "fa.spidertron-autopilot-destination-full", x, y, has_more, count }`

**Lines 79-81:**
```lua
ctx.message:fragment({ "fa.spidertron-follow-target" })
ctx.message:fragment(Localising.get_localised_name_with_fallback(target))
ctx.message:fragment({ "fa.spidertron-follow-click-to-change" })
```
**Change to:** `{ "fa.spidertron-follow-target-full", target_name }`

---

## scripts/ui/tabs/logistics-section-editor.lua

### Unlocalised Strings

**Line 78:**
```lua
ctx.message:fragment("to")
```
**Change to:** Part of parameterized locale string

### Lack of Flexibility

**Lines 76-83:**
```lua
ctx.message:fragment(CircuitNetwork.localise_signal(sid))
ctx.message:fragment(tostring(min_val))
ctx.message:fragment("to")
if max_val then
   ctx.message:fragment(tostring(max_val))
else
   ctx.message:fragment({ "fa.infinity" })
end
```
**Change to:** `{ "fa.logistics-signal-range", signal, min_val, max_val or { "fa.infinity" } }`

---

## scripts/ui/tabs/inserter-config.lua

### Unlocalised Strings

**Lines 141, 156:**
```lua
value_text = signal_type .. " " .. signal.name
ctx.controller.message:fragment(signal_type .. " " .. result.name)
```
**Change to:** Use `CircuitNetwork.localise_signal()` or similar

### Lack of Flexibility

**Lines 53-63:**
```lua
message:fragment({ "fa.inserter-hand-size" })
local override = entity.inserter_stack_size_override
if override == 0 then
   message:fragment({ "fa.inserter-hand-size-unset" })
else
   message:fragment(tostring(override))
end
message:fragment({ "fa.inserter-hand-size-help" })
```
**Change to:** `{ "fa.inserter-hand-size-full", override == 0 and { "fa.unset" } or tostring(override) }`

---

## scripts/ui/tabs/logistics-unified.lua

### Unlocalised Strings

**Lines 128, 130, 136, 138:**
```lua
ctx.message:fragment("active")
ctx.message:fragment("inactive")
```
**Change to:** `{ "fa.logistics-active" }` and `{ "fa.logistics-inactive" }`

**Lines 157, 159, 179, 181:**
```lua
ctx.controller.message:fragment("on")
ctx.controller.message:fragment("off")
```
**Change to:** `{ "fa.on" }` and `{ "fa.off" }`

---

## scripts/ui/tabs/circuit-network-signals.lua

### Unlocalised Strings

**Lines 71, 73, 93:**
```lua
ctx.message:fragment(" x ")
ctx.message:fragment(", ")
```
**Change to:** Part of parameterized locale strings

### Lack of Flexibility

**Lines 70-74:**
```lua
ctx.message:fragment(signal_name)
ctx.message:fragment(" x ")
ctx.message:fragment(tostring(sig_info.total_count))
ctx.message:fragment(", ")
ctx.message:fragment({ "fa.circuit-network-quality-hint" })
```
**Change to:** `{ "fa.circuit-network-signal-summary", signal_name, sig_info.total_count }`

**Lines 92-94:**
```lua
ctx.message:fragment(Localising.get_localised_name_with_fallback(quality_proto))
ctx.message:fragment(" x ")
ctx.message:fragment(tostring(count))
```
**Change to:** `{ "fa.circuit-network-quality-count", quality_name, count }`

---

## scripts/ui/constant-combinator.lua

### Unlocalised Strings

**Lines 62-63:**
```lua
ctx.message:fragment("x")
ctx.message:fragment(tostring(signal_info.count))
```
**Change to:** `{ "fa.signal-count", signal_name, count }`

---

## scripts/ui/form-builder.lua

### Unlocalised Strings

**Lines 330, 434, 484, and many others:**
String concatenation patterns like `signal_type .. " " .. signal.name`, hard-coded "0", "<", etc.
**Change to:** Use parameterized locale strings or localization functions

### Lack of Flexibility

**Lines 76-77, 107-108, 169-170, 246-247, 312-313, 623-626:**
Sequential fragments building single semantic messages.
**Change to:** Use single parameterized locale strings for each pattern

---

## scripts/ui/circuit-navigator.lua

### Lack of Flexibility

**Lines 129-138:**
```lua
ctx.message:fragment(pname)
ctx.message:list_item()
ctx.message:fragment({
   "fa.dir-dist",
   FaUtils.direction_lookup(...),
   FaUtils.distance_speech_friendly(...)
})
if hops > 0 then
   ctx.message:list_item()
   ctx.message:fragment({ "fa.circuit-navigator-hops", tostring(hops) })
end
```
**Change to:** `{ "fa.circuit-navigator-entity-full", name, direction, distance, hops }`

---

## scripts/ui/selectors/spidertron-autopilot-selector.lua

### Lack of Flexibility

**Lines 36-40:**
```lua
local message = MessageBuilder.new()
message:fragment({ "fa.spidertron-autopilot-added" })
message:fragment(tostring(math.floor(args.position.x)))
message:fragment(tostring(math.floor(args.position.y)))
message:fragment({ "fa.spidertron-autopilot-queue-count", tostring(args.state.waypoint_count) })
```
**Change to:** `{ "fa.spidertron-autopilot-added-at", x, y, waypoint_count }`

---

## scripts/ui/selectors/spidertron-follow-selector.lua

### Lack of Flexibility

**Lines 43-46:**
```lua
local message = MessageBuilder.new()
message:fragment({ "fa.spidertron-follow-set" })
message:fragment(Localising.get_localised_name_with_fallback(args.entity))
```
**Change to:** `{ "fa.spidertron-follow-set-entity", entity_name }`

---

## Summary Statistics

### Type 1: Unlocalised Strings (Hard-coded English)
Found in **19 files** with hundreds of instances, including:
- Error messages
- Status messages
- UI labels
- Debug output
- String concatenation patterns

### Type 2: Lack of Flexibility (Sequential fragments)
Found in **16 files** where multiple `fragment()` calls build single semantic messages that prevent localisers from:
- Reordering components for different language structures
- Adjusting punctuation and conjunctions
- Handling gender/number agreement

### Files with Most Issues

1. **control.lua** - 17 hard-coded strings, 1 major flexibility issue
2. **scripts/transport-belts.lua** - Entire functions return hard-coded English
3. **scripts/equipment.lua** - Extensive hard-coded categories and errors
4. **scripts/worker-robots.lua** - Hard-coded roboport network descriptions
5. **scripts/fa-info.lua** - Many hard-coded entity information strings
6. **scripts/ui/form-builder.lua** - String concatenation patterns throughout

### Impact

These antipatterns prevent:
- Translation to other languages
- Proper localization by community translators
- Cultural adaptation of messages
- Accessibility for non-English speaking blind players

### Recommendations

1. Create locale keys for all hard-coded English strings
2. Combine sequential fragments into single parameterized locale strings where they represent single semantic units
3. Use MessageBuilder and parameterized locale strings consistently
4. Avoid string concatenation for user-facing messages
5. Review debug messages - even these should be localizable

---

## Return Type Safety Analysis

This section documents the analysis of functions that would change from returning plain strings to returning LocalisedString tables, and whether those changes are safe (won't cause crashes due to string concatenation in callers).

### Analysis Methodology

**Direct Analysis**: Identified functions in the report that return plain strings and would be changed to return LocalisedString tables. For each function, analyzed all callers to check for:
- BAD: String concatenation (.. operator), string.format, or other string operations
- GOOD: Passing to Speech.speak(), MessageBuilder:fragment(), or other LocalisedString-compatible APIs
- GOOD: Function already returns mix of strings and LocalisedString (callers must handle both)
- GOOD: Callers treat return value as LocalisedString even though it's currently a string

**Transitive Analysis**: Found functions that call the functions identified in direct analysis and propagate their return values. Checked if THOSE functions' callers would have issues with the type change.

### Direct Analysis Results (9 Functions)

All 9 functions identified are **SAFE** to convert:

1. **build_preview_checks_info** (scripts/building-tools.lua:637-780)
   - Status: SAFE
   - Reason: Already returns mixed types. Caller passes to Speech system that handles LocalisedString
   - Callers: control.lua:269

2. **get_blueprint_info** (scripts/blueprints.lua:175-214)
   - Status: SAFE
   - Reason: Already returns mixed types. All callers pass to Speech.speak() or message:fragment()
   - Callers: control.lua:148, 4211, 4237; blueprint-book-menu.lua:63

3. **reload_weapons** (scripts/equipment.lua:181-217)
   - Status: SAFE
   - Reason: Caller passes result to MessageBuilder:fragment()
   - Callers: inventory-grid.lua:510

4. **remove_weapons_and_ammo** (scripts/equipment.lua:224-272)
   - Status: SAFE
   - Reason: Already returns mixed types. Caller passes to MessageBuilder:fragment()
   - Callers: inventory-grid.lua:514

5. **remove_equipment_and_armor** (scripts/equipment.lua:488-540)
   - Status: SAFE
   - Reason: Caller passes result to MessageBuilder:fragment()
   - Callers: inventory-grid.lua:518

6. **get_equipment_category** (scripts/equipment.lua:613-638)
   - Status: SAFE
   - Reason: Caller passes to MessageBuilder:list_item()
   - Callers: equipment.lua:700

7. **get_equipment_category_from_type** (scripts/equipment.lua:956-980)
   - Status: SAFE
   - Reason: Both callers pass to MessageBuilder:list_item()
   - Callers: equipment.lua:893, 940

8. **set_splitter_priority** (scripts/transport-belts.lua:749-822)
   - Status: SAFE
   - Reason: All callers pass to Speech.speak(), one test discards return value
   - Callers: control.lua:3240, 3243, 3966; belt-direction-test.lua:47

9. **selected_item_production_stats_info** (scripts/fa-info.lua:1525-1650)
   - Status: SAFE
   - Reason: Already returns mixed types. All 9 callers pass to Speech.speak() or MessageBuilder:fragment()
   - Callers: control.lua:3678; logistics-section-editor.lua:109; circuit-network-signals.lua:78; inventory-grid.lua:416; gun-menu.lua:197, 226, 327, 358; crafting.lua:152

### Transitive Analysis Results (3 Functions)

All 3 functions that propagate return values from the above functions are **SAFE**:

1. **read_tile_inner** (control.lua:236-277)
   - Status: SAFE
   - Propagates from: build_preview_checks_info
   - Reason: Returns table containing build_preview_checks_info result, but caller passes to FaUtils.localise_cat_table() which handles LocalisedString
   - Callers: control.lua:231 (via read_tile())

2. **get_equipment_label** (scripts/equipment.lua:677-718)
   - Status: SAFE
   - Propagates from: get_equipment_category
   - Reason: Already returns LocalisedString (annotated). Uses MessageBuilder which handles LocalisedString
   - Callers: equipment-grid.lua:159; equipment.lua:728

3. **get_equipment_info** (scripts/equipment.lua:724-755)
   - Status: SAFE
   - Propagates from: get_equipment_category (via get_equipment_label)
   - Reason: Already returns LocalisedString (annotated). Uses MessageBuilder which handles LocalisedString
   - Callers: equipment-grid.lua:162

### Summary

**Total Functions Analyzed**: 12 (9 direct + 3 transitive)

**Safe Functions**: 12 (100%)
- All changes can be safely implemented
- No string concatenation or unsafe operations found
- All callers use LocalisedString-compatible APIs

**Unsafe Functions**: 0
- No functions identified that would cause crashes
- No changes need to be removed from the report

### Key Findings

1. **MessageBuilder pattern protects against crashes**: Functions that use MessageBuilder:fragment(), MessageBuilder:list_item(), and Speech.speak() all handle LocalisedString correctly
2. **Mixed return types already handled**: Several functions already return both plain strings and LocalisedString tables, proving callers are equipped to handle both
3. **No string concatenation**: None of the callers use the .. operator, string.format(), or other string operations that would break with LocalisedString
4. **Transitive propagation is safe**: Functions that propagate the changing return values also use LocalisedString-compatible patterns

### Conclusion

**All recommended changes in this report are safe to implement.** No modifications to the report are required based on return type safety concerns.
