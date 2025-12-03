---Syntrax runner - executes syntrax code and places rails in game
---
---Uses build-helpers to place rails as ghosts, then revives them.
---In normal mode, checks cost before placing. In force/superforce, just places ghosts.

local BuildHelpers = require("scripts.rails.build-helpers")
local InventoryUtils = require("scripts.inventory-utils")
local Syntrax = require("syntrax")

local mod = {}

---@class syntrax_runner.ExecuteOptions
---@field pindex integer Player index
---@field source string Syntrax source code
---@field position MapPosition Starting position
---@field direction defines.direction Starting direction (0-15)
---@field planner_description railutils.RailPlannerDescription Rail planner for prototype names
---@field build_mode defines.build_mode Build mode for placement

---Map generic rail type to actual prototype name using rail planner
---@param generic_type string Generic rail type like "straight-rail"
---@param planner_description railutils.RailPlannerDescription
---@return string The actual prototype name from the player's rail planner
local function map_rail_type(generic_type, planner_description)
   if generic_type == "straight-rail" then
      return planner_description.straight_rail_name
   elseif generic_type == "curved-rail-a" then
      return planner_description.curved_rail_a_name
   elseif generic_type == "curved-rail-b" then
      return planner_description.curved_rail_b_name
   elseif generic_type == "half-diagonal-rail" then
      return planner_description.half_diagonal_rail_name
   else
      error("Unknown rail type: " .. tostring(generic_type))
   end
end

---Categorize placements into what needs to be built vs what already exists
---@param surface LuaSurface
---@param placements {name: string, position: MapPosition, direction: defines.direction}[]
---@return {name: string, position: MapPosition, direction: defines.direction}[] to_place New placements that need ghosts
---@return LuaEntity[] existing_ghosts Ghosts that already exist and just need revival
local function categorize_placements(surface, placements)
   local to_place = {}
   local existing_ghosts = {}

   for _, placement in ipairs(placements) do
      -- Check if real entity already exists - skip entirely
      local existing =
         BuildHelpers.find_expected_entity(surface, placement.position, placement.name, placement.direction)
      if existing then goto continue end

      -- Check if ghost already exists - just needs revival, no cost
      local ghost = BuildHelpers.find_expected_ghost(surface, placement.position, placement.name, placement.direction)
      if ghost then
         table.insert(existing_ghosts, ghost)
         goto continue
      end

      -- Need to place new ghost
      table.insert(to_place, placement)

      ::continue::
   end

   return to_place, existing_ghosts
end

---Execute syntrax code and place rails
---@param opts syntrax_runner.ExecuteOptions
---@return LuaEntity[]|nil entities The placed rails/ghosts, or nil on failure
---@return string|nil error Error message if failed
function mod.execute(opts)
   local player = game.get_player(opts.pindex)
   if not player then return nil, "Invalid player" end

   -- Parse and execute syntrax
   local rails, err = Syntrax.execute(opts.source, opts.position, opts.direction)
   if err then return nil, err.message end

   -- Handle empty result
   if not rails or #rails == 0 then return {}, nil end

   -- Convert syntrax output to placement format using rail planner prototypes
   local placements = {}
   for _, rail in ipairs(rails) do
      table.insert(placements, {
         name = map_rail_type(rail.rail_type, opts.planner_description),
         position = rail.position,
         direction = rail.placement_direction,
      })
   end

   -- Categorize: what needs placing vs what already exists
   local to_place, existing_ghosts = categorize_placements(player.surface, placements)

   -- In normal mode, check cost for all entities (new placements + existing ghosts to revive)
   local deductor
   if opts.build_mode == defines.build_mode.normal then
      local proto_names = {}
      for _, placement in ipairs(to_place) do
         table.insert(proto_names, placement.name)
      end
      for _, ghost in ipairs(existing_ghosts) do
         table.insert(proto_names, ghost.ghost_name)
      end

      deductor = InventoryUtils.deductor_for_placements(opts.pindex, proto_names, false)
      if not deductor then return nil, "Insufficient items" end
   end

   -- Place new ghosts
   local new_ghosts = {}
   if #to_place > 0 then
      new_ghosts = BuildHelpers.place_ghosts(opts.pindex, to_place, opts.build_mode)
      if not new_ghosts then return nil, "Failed to place rails" end
   end

   -- Commit cost after successful placement
   if deductor then deductor:commit() end

   -- Combine all ghosts
   local all_ghosts = {}
   for _, g in ipairs(existing_ghosts) do
      table.insert(all_ghosts, g)
   end
   for _, g in ipairs(new_ghosts) do
      table.insert(all_ghosts, g)
   end

   -- In normal mode, revive ghosts
   if opts.build_mode == defines.build_mode.normal then return BuildHelpers.revive_ghosts(all_ghosts), nil end

   return all_ghosts, nil
end

return mod
