---Syntrax runner - executes syntrax code and places rails in game
---
---Uses build-helpers to place rails as ghosts, then revives them.
---In normal mode, checks cost before placing. In force/superforce, just places ghosts.

local BuildHelpers = require("scripts.rails.build-helpers")
local InventoryUtils = require("scripts.inventory-utils")
local Syntrax = require("syntrax")

local mod = {}

---Destroy a list of ghosts (only if valid)
---@param ghosts LuaEntity[]
local function destroy_ghosts(ghosts)
   for _, g in ipairs(ghosts) do
      if g.valid then g.destroy() end
   end
end

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

---Convert a syntrax placement to game placement format
---@param placement syntrax.vm.Placement
---@param planner_description railutils.RailPlannerDescription
---@return {name: string, position: MapPosition, direction: defines.direction}
local function convert_placement(placement, planner_description)
   if placement.type == "rail" then
      return {
         name = map_rail_type(placement.rail_type, planner_description),
         position = placement.position,
         direction = placement.placement_direction,
      }
   elseif placement.type == "signal" then
      return {
         name = placement.signal_type,
         position = placement.position,
         direction = placement.direction,
      }
   else
      error("Unknown placement type: " .. tostring(placement.type))
   end
end

---Format an error message for a failed placement
---@param group_idx integer
---@param placement syntrax.vm.Placement
---@return string
local function format_placement_error(group_idx, placement)
   local entity_type = placement.type == "rail" and placement.rail_type or placement.signal_type
   return string.format(
      "Failed to place group %d, %s at (%d, %d)",
      group_idx,
      entity_type,
      placement.position.x,
      placement.position.y
   )
end

---Try to place an alternative (array of placements) as ghosts
---@param pindex integer
---@param surface LuaSurface
---@param alternative syntrax.vm.Placement[]
---@param planner_description railutils.RailPlannerDescription
---@param build_mode defines.build_mode
---@return LuaEntity[]|nil ghosts All ghosts (created + existing) if successful, nil if failed
---@return LuaEntity[]|nil created_ghosts Ghosts we created (for cleanup tracking)
---@return syntrax.vm.Placement|nil failed_placement The placement that failed, if any
local function try_alternative(pindex, surface, alternative, planner_description, build_mode)
   local all_ghosts = {}
   local created_ghosts = {}

   for _, syntrax_placement in ipairs(alternative) do
      local placement = convert_placement(syntrax_placement, planner_description)

      -- Check if real entity already exists - counts as success, no ghost needed
      local existing =
         BuildHelpers.find_expected_entity(surface, placement.position, placement.name, placement.direction)
      if existing then goto continue end

      -- Check if ghost already exists - counts as success, but we didn't create it
      local ghost = BuildHelpers.find_expected_ghost(surface, placement.position, placement.name, placement.direction)
      if ghost then
         table.insert(all_ghosts, ghost)
         goto continue
      end

      -- Try to place new ghost
      local new_ghosts = BuildHelpers.place_ghosts(pindex, { placement }, build_mode)
      if not new_ghosts or #new_ghosts == 0 then
         -- Failed to place - clean up only ghosts WE created
         destroy_ghosts(created_ghosts)
         return nil, nil, syntrax_placement
      end

      local new_ghost = new_ghosts[1]
      table.insert(all_ghosts, new_ghost)
      table.insert(created_ghosts, new_ghost)

      ::continue::
   end

   return all_ghosts, created_ghosts
end

---Execute syntrax code and place rails
---@param opts syntrax_runner.ExecuteOptions
---@return LuaEntity[]|nil entities The placed rails/ghosts, or nil on failure
---@return string|nil error Error message if failed
function mod.execute(opts)
   local player = game.get_player(opts.pindex)
   if not player then return nil, "Invalid player" end

   -- Parse and execute syntrax
   local placement_groups, err = Syntrax.execute(opts.source, opts.position, opts.direction)
   if err then return nil, err.message end

   -- Handle empty result
   if not placement_groups or #placement_groups == 0 then return {}, nil end

   -- Process each placement group, trying alternatives until one works
   local all_ghosts = {}
   local all_created = {} -- Track only ghosts we created, for cleanup

   for group_idx, group in ipairs(placement_groups) do
      local group_ghosts, group_created = nil, nil
      local last_failed_placement = nil

      -- Try each alternative in order
      for _, alternative in ipairs(group) do
         local failed
         group_ghosts, group_created, failed =
            try_alternative(opts.pindex, player.surface, alternative, opts.planner_description, opts.build_mode)
         if group_ghosts then break end
         if failed then last_failed_placement = failed end
      end

      if not group_ghosts then
         -- No alternative worked - clean up only what we created
         destroy_ghosts(all_created)
         if last_failed_placement then return nil, format_placement_error(group_idx, last_failed_placement) end
         return nil, string.format("Failed to place group %d", group_idx)
      end

      for _, g in ipairs(group_ghosts) do
         table.insert(all_ghosts, g)
      end
      for _, g in ipairs(group_created) do
         table.insert(all_created, g)
      end
   end

   -- All groups placed successfully as ghosts
   -- Now handle costs and revival

   if opts.build_mode == defines.build_mode.normal then
      -- Check cost for all placed ghosts
      local proto_names = {}
      for _, ghost in ipairs(all_ghosts) do
         if ghost.valid then table.insert(proto_names, ghost.ghost_name) end
      end

      local deductor = InventoryUtils.deductor_for_placements(opts.pindex, proto_names, false)
      if not deductor then
         destroy_ghosts(all_created)
         return nil, "Insufficient items"
      end

      deductor:commit()
      return BuildHelpers.revive_ghosts(all_ghosts), nil
   end

   -- Force/superforce mode - just return ghosts
   return all_ghosts, nil
end

return mod
