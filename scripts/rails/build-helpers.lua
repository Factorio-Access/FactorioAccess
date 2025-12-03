---Build helpers for ghost-based entity placement
---Used by virtual-train-driving and syntrax-runner

local StorageManager = require("scripts.storage-manager")
local BlueprintSynthesizer = require("scripts.blueprint-synthesizer")
local HandMonitor = require("scripts.hand-monitor")

local mod = {}

---@class build_helpers.Inventories
---@field tmp_inv LuaInventory? Temporary inventory for hand swapping

---Initialize inventories for a player
---@return build_helpers.Inventories
local function init_inventories()
   return {}
end

-- IMPORTANT: changing the name of this or bumping the ephemeral version will leak inventories. That is fine as long as
-- it is only ever done occasionally, but if we need to do so more often then that is bad.  If this is moved to another
-- file, it must keep the name.
---@type table<number, build_helpers.Inventories>
local build_inventories = StorageManager.declare_storage_module("train_building_invs", init_inventories)

---Get or create a temporary inventory for storing the player's hand during builds
---@param pindex integer
---@return LuaInventory
function mod.get_or_create_tmp_inventory(pindex)
   local invs = build_inventories[pindex]

   -- Check if we have a valid inventory
   if invs.tmp_inv and invs.tmp_inv.valid then return invs.tmp_inv end

   -- Create a new inventory with 1 slot
   invs.tmp_inv = game.create_inventory(1)
   return invs.tmp_inv
end

---Find a ghost entity at a position matching the expected name and direction
---@param surface LuaSurface
---@param position MapPosition
---@param entity_name string
---@param direction defines.direction
---@return LuaEntity|nil
function mod.find_expected_ghost(surface, position, entity_name, direction)
   local ghosts = surface.find_entities_filtered({
      position = position,
      radius = 1,
      name = "entity-ghost",
      ghost_name = entity_name,
   })

   for _, ghost in ipairs(ghosts) do
      if ghost.direction == direction then return ghost end
   end

   return nil
end

---Find a real entity at a position matching the expected name and direction
---@param surface LuaSurface
---@param position MapPosition
---@param entity_name string
---@param direction defines.direction
---@return LuaEntity|nil
function mod.find_expected_entity(surface, position, entity_name, direction)
   local entities = surface.find_entities_filtered({
      position = position,
      radius = 1,
      name = entity_name,
   })

   for _, entity in ipairs(entities) do
      if entity.direction == direction then return entity end
   end

   return nil
end

---Place a single entity as a ghost using build_from_cursor
---Does NOT check costs, does NOT revive, does NOT play sounds
---@param pindex integer
---@param entity_name string
---@param position MapPosition
---@param direction defines.direction
---@param build_mode defines.build_mode
---@return LuaEntity|nil ghost The placed ghost, or nil if failed
function mod.place_ghost(pindex, entity_name, position, direction, build_mode)
   local player = game.get_player(pindex)
   if not player then return nil end

   local surface = player.surface

   -- Check if entity already exists at this position
   local existing = mod.find_expected_entity(surface, position, entity_name, direction)
   if existing then
      -- Already exists - return nil but this is not a failure
      -- Caller should check for existing entities separately if needed
      return nil
   end

   -- Check if ghost already exists
   local existing_ghost = mod.find_expected_ghost(surface, position, entity_name, direction)
   if existing_ghost then return existing_ghost end

   -- Suppress hand change events for this tick
   HandMonitor.suppress_this_tick(pindex)

   -- Get temporary inventory and swap hand into it
   local tmp_inv = mod.get_or_create_tmp_inventory(pindex)
   local cursor = player.cursor_stack

   -- Swap player's hand to temp inventory
   local swap_success = cursor.swap_stack(tmp_inv[1])
   if not swap_success then return nil end

   -- Create blueprint in cursor
   cursor.set_stack({ name = "blueprint" })
   local bp_string = BlueprintSynthesizer.synthesize_simple_blueprint(entity_name, direction)
   local import_result = cursor.import_stack(bp_string)
   if import_result ~= 0 then
      -- Import failed, restore hand
      cursor.swap_stack(tmp_inv[1])
      return nil
   end

   -- Try to build from cursor with specified build mode
   local can_build = player.can_build_from_cursor({
      position = position,
      build_mode = build_mode,
   })

   if can_build then player.build_from_cursor({
      position = position,
      build_mode = build_mode,
   }) end

   -- Clear blueprint and restore hand
   cursor.clear()
   cursor.swap_stack(tmp_inv[1])

   -- Check if ghost was placed
   local ghost = mod.find_expected_ghost(surface, position, entity_name, direction)
   return ghost
end

---Place multiple entities as ghosts
---If any placement fails, destroys all previously placed ghosts and returns nil
---@param pindex integer
---@param placements {name: string, position: MapPosition, direction: defines.direction}[]
---@param build_mode defines.build_mode
---@return LuaEntity[]|nil ghosts All placed ghosts, or nil if any failed
function mod.place_ghosts(pindex, placements, build_mode)
   local player = game.get_player(pindex)
   if not player then return nil end

   local surface = player.surface
   local ghosts = {}

   for _, placement in ipairs(placements) do
      -- Check if real entity already exists (skip, don't fail)
      local existing = mod.find_expected_entity(surface, placement.position, placement.name, placement.direction)
      if existing then
         -- Already built, skip this one
         goto continue
      end

      -- Check if ghost already exists
      local existing_ghost = mod.find_expected_ghost(surface, placement.position, placement.name, placement.direction)
      if existing_ghost then
         table.insert(ghosts, existing_ghost)
         goto continue
      end

      -- Place ghost
      local ghost = mod.place_ghost(pindex, placement.name, placement.position, placement.direction, build_mode)
      if not ghost then
         -- Failed - destroy all placed ghosts
         for _, g in ipairs(ghosts) do
            if g.valid then g.destroy() end
         end
         return nil
      end
      table.insert(ghosts, ghost)

      ::continue::
   end

   return ghosts
end

---Revive all ghosts, returning the created entities
---@param ghosts LuaEntity[]
---@return LuaEntity[] entities The revived entities
function mod.revive_ghosts(ghosts)
   local entities = {}
   for _, ghost in ipairs(ghosts) do
      if ghost.valid then
         local _, entity = ghost.silent_revive()
         if entity then table.insert(entities, entity) end
      end
   end
   return entities
end

return mod
