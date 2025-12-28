--[[
Constants for our mod.  Must load in the data stage as well as runtime.
]]

local TableHelpers = require("scripts.table-helpers")

local mod = {}

-- Numeric limits for Factorio's 32-bit integer fields
mod.INT32_MAX = 2147483647
mod.INT32_MIN = -2147483648

mod.RESOURCE_SEARCH_RADIUSES_MAP_NAME = "resource-search-radiuses"

mod.ENT_NAMES_CLEARED_AS_OBSTACLES = {
   "tree-01-stump",
   "tree-02-stump",
   "tree-03-stump",
   "tree-04-stump",
   "tree-05-stump",
   "tree-06-stump",
   "tree-07-stump",
   "tree-08-stump",
   "tree-09-stump",
   "small-scorchmark",
   "small-scorchmark-tintable",
   "medium-scorchmark",
   "medium-scorchmark-tintable",
   "big-scorchmark",
   "big-scorchmark-tintable",
   "huge-scorchmark",
   "huge-scorchmark-tintable",
   "big-rock",
   "huge-rock",
   "big-sand-rock",
}

-- Holds a mapping of names. See data-updates.lua.
mod.RESEARCH_CRAFT_ITEMS_MAP_OUTER = "craft-item-map-names"
mod.RESEARCH_CRAFT_ITEM_TRIGGER_MAPNAME_SUFFIX = "craft-item-counts"

-- The unit vectors of the directions in order north going clockwise.  If indexed by defines.direction, this gives back
-- the unit vector pointing in that direction.  Note that this is a 0-indexed table, 0 is north, directions go
-- clockwise, 15 is northnorthwest.
---@type table<defines.direction, fa.Point>
mod.DIRECTION_VECTORS = {
   [defines.direction.north] = { x = 0.0, y = -1.0 },
   [defines.direction.northnortheast] = { x = 0.3826834323650898, y = -0.9238795325112867 },
   [defines.direction.northeast] = { x = 0.7071067811865476, y = -0.7071067811865476 },
   [defines.direction.eastnortheast] = { x = 0.9238795325112867, y = -0.38268343236508984 },
   [defines.direction.east] = { x = 1.0, y = 0.0 },
   [defines.direction.eastsoutheast] = { x = 0.9238795325112867, y = 0.3826834323650897 },
   [defines.direction.southeast] = { x = 0.7071067811865476, y = 0.7071067811865475 },
   [defines.direction.southsoutheast] = { x = 0.3826834323650899, y = 0.9238795325112867 },
   [defines.direction.south] = { x = 0.0, y = 1.0 },
   [defines.direction.southsouthwest] = { x = -0.38268343236508967, y = 0.9238795325112868 },
   [defines.direction.southwest] = { x = -0.7071067811865475, y = 0.7071067811865477 },
   [defines.direction.westsouthwest] = { x = -0.9238795325112865, y = 0.38268343236509034 },
   [defines.direction.west] = { x = -1.0, y = 0.0 },
   [defines.direction.westnorthwest] = { x = -0.9238795325112866, y = -0.38268343236509 },
   [defines.direction.northwest] = { x = -0.7071067811865477, y = -0.7071067811865474 },
   [defines.direction.northnorthwest] = { x = -0.3826834323650904, y = -0.9238795325112865 },
}

---@type table<string, true>
mod.CRAFTING_MACHINES = {
   ["assembling-machine"] = true,
   ["furnace"] = true,
   ["rocket-silo"] = true,
}

---@type string[]
mod.WATER_TILE_NAMES = {
   "water",
   "deepwater",
   "water-green",
   "deepwater-green",
   "water-shallow",
   "water-mud",
   "water-wube",
}

---@type table<string, true>
mod.WATER_TILE_NAMES_SET = {
   ["water"] = true,
   ["deepwater"] = true,
   ["water-green"] = true,
   ["deepwater-green"] = true,
   ["water-shallow"] = true,
   ["water-mud"] = true,
   ["water-wube"] = true,
}

---@type string[]
mod.RAIL_TYPES = {
   "straight-rail",
   "curved-rail-a",
   "curved-rail-b",
   "half-diagonal-rail",
}

---@type table<string, true>
mod.RAIL_TYPES_SET = TableHelpers.array_to_set({}, mod.RAIL_TYPES)

-- Vehicle entity types (can have drivers/passengers)
---@type table<string, true>
mod.VEHICLE_TYPES = {
   ["car"] = true,
   ["spider-vehicle"] = true,
   ["locomotive"] = true,
   ["cargo-wagon"] = true,
   ["fluid-wagon"] = true,
   ["artillery-wagon"] = true,
}

-- Entity types that players can walk over without collision
mod.ENT_TYPES_YOU_CAN_WALK_OVER = {
   "resource",
   "transport-belt",
   "underground-belt",
   "splitter",
   "item-entity",
   "entity-ghost",
   "heat-pipe",
   "pipe",
   "pipe-to-ground",
   "character",
   "rail-signal",
   "highlight-box",
   "combat-robot",
   "logistic-robot",
   "construction-robot",
   "rocket-silo-rocket-shadow",
}

-- Entity types that can be built over (replaced)
mod.ENT_TYPES_YOU_CAN_BUILD_OVER = {
   "resource",
   "entity-ghost",
   "highlight-box",
   "combat-robot",
   "logistic-robot",
   "construction-robot",
   "rocket-silo-rocket-shadow",
}

-- Entity names to exclude from various operations
mod.EXCLUDED_ENT_NAMES = { "highlight-box" }

-- Main inventories that represent primary storage for entities
-- These are the inventories used for fast transfer operations
---@type string[]
mod.MAIN_INVENTORIES = {
   "character_main",
   "chest",
   "car_trunk",
   "spider_trunk",
   "cargo_wagon",
   "hub_main",
   "cargo_landing_pad_main",
   "linked_container_main",
   "item_main",
   "cargo_unit",
   "god_main",
   "editor_main",
   "proxy_main",
   "crafter_input",
   "lab_input",
}

-- Inventory priorities for sorting in entity UI
-- Lower numbers appear first
---@type table<string, number>
mod.INVENTORY_PRIORITIES = {
   -- Primary/main inventories (priority 1)
   character_main = 1,
   chest = 1,
   car_trunk = 1,
   spider_trunk = 1,
   cargo_wagon = 1,
   hub_main = 1,
   cargo_landing_pad_main = 1,
   linked_container_main = 1,
   item_main = 1,

   -- Input inventories (priority 2)
   crafter_input = 2,
   lab_input = 2,
   agricultural_tower_input = 2,

   -- Output inventories (priority 3)
   crafter_output = 3,
   agricultural_tower_output = 3,
   asteroid_collector_output = 3,
   burnt_result = 3,

   -- Module inventories (priority 4)
   crafter_modules = 4,
   beacon_modules = 4,
   mining_drill_modules = 4,
   lab_modules = 4,

   -- Special/trash inventories (priority 5)
   crafter_trash = 5,
   car_trash = 5,
   character_trash = 5,
   spider_trash = 5,
   hub_trash = 5,
   lab_trash = 5,
   cargo_landing_pad_trash = 5,
   rocket_silo_trash = 5,
   logistic_container_trash = 5,

   -- Fuel and ammo inventories (priority 6)
   fuel = 6,
   artillery_wagon_ammo = 6,

   -- Robot/material inventories (priority 7)
   roboport_robot = 7,
   roboport_material = 7,
   robot_cargo = 7,
   robot_repair = 7,

   -- Rocket silo special (priority 8)
   rocket_silo_rocket = 8,

   -- Deprecated inventories (map to their replacements for compatibility)
   assembling_machine_input = 2, -- maps to crafter_input
   assembling_machine_output = 3, -- maps to crafter_output
   assembling_machine_modules = 4, -- maps to crafter_modules
   assembling_machine_trash = 5, -- maps to crafter_trash
   assembling_machine_dump = 5,
   furnace_source = 2, -- maps to crafter_input
   furnace_result = 3, -- maps to crafter_output
   furnace_modules = 4, -- maps to crafter_modules
   furnace_trash = 5, -- maps to crafter_trash
   rocket_silo_input = 2, -- maps to crafter_input
   rocket_silo_output = 3, -- maps to crafter_output
   rocket_silo_modules = 4, -- maps to crafter_modules
}

-- Logic signal names (virtual signals with special combinator behavior)
-- These are: signal-everything, signal-anything, signal-each
---@type table<string, true>
mod.LOGIC_SIGNAL_NAMES = {
   ["signal-everything"] = true,
   ["signal-anything"] = true,
   ["signal-each"] = true,
}

-- Entity statuses that should be announced in the brief cursor form, not just right bracket.
-- These are error states or rarely-seen conditions that warrant immediate attention.
---@type table<defines.entity_status, true>
mod.VERBOSE_STATUSES = {
   -- Error states
   [defines.entity_status.broken] = true,
   [defines.entity_status.cant_divide_segments] = true,
   [defines.entity_status.disabled] = true,
   [defines.entity_status.disabled_by_control_behavior] = true,
   [defines.entity_status.disabled_by_script] = true,
   [defines.entity_status.frozen] = true,

   -- Output problems
   [defines.entity_status.full_burnt_result_output] = true,
   [defines.entity_status.full_output] = true,

   -- Power problems
   [defines.entity_status.low_power] = true,
   [defines.entity_status.no_power] = true,
   [defines.entity_status.not_plugged_in_electric_network] = true,

   -- Resource/fuel/ingredient problems
   [defines.entity_status.no_fuel] = true,
   [defines.entity_status.no_ammo] = true,
   [defines.entity_status.no_minable_resources] = true,
   [defines.entity_status.missing_required_fluid] = true,
   [defines.entity_status.no_ingredients] = true,
   [defines.entity_status.no_input_fluid] = true,
   [defines.entity_status.item_ingredient_shortage] = true,
   [defines.entity_status.fluid_ingredient_shortage] = true,

   -- Rail signal problems
   [defines.entity_status.not_connected_to_rail] = true,

   -- Path problems
   [defines.entity_status.no_path] = true,

   -- Pipe problems
   [defines.entity_status.pipeline_overextended] = true,

   -- Logistics problems
   [defines.entity_status.out_of_logistic_network] = true,

   -- Space/cargo problems
   [defines.entity_status.not_connected_to_hub_or_pad] = true,
   [defines.entity_status.not_enough_thrust] = true,

   -- Misc problems
   [defines.entity_status.marked_for_deconstruction] = true,
   [defines.entity_status.recharging_after_power_outage] = true,
   [defines.entity_status.recipe_not_researched] = true,
   [defines.entity_status.no_filter] = true,
}

return mod
