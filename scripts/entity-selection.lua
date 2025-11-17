--- Entity selection utilities for handling entities at tiles
local mod = {}

local Consts = require("scripts.consts")
local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")

---@class fa.EntitySelection.StorageState
---@field ent_index number Current index for cycling

---@type table<number, fa.EntitySelection.StorageState>
local ent_selection_storage = StorageManager.declare_storage_module("entity_selection", {
   ent_index = 1,
}, {
   ephemeral_state_version = 1,
})

--- Sort priorities by entity type. Higher priority entities appear first.
--- Default priority is 0 if not listed.
local SORT_PRIORITIES = {
   -- Secondary entities (priority -2)
   ["logistic-robot"] = -2,
   ["construction-robot"] = -2,
   ["combat-robot"] = -2,
   ["capture-robot"] = -2,
   ["corpse"] = -2,
   ["character-corpse"] = -2,
   ["rocket-silo-rocket-shadow"] = -2,
   ["resource"] = -2,

   -- Rail shapes (priority -1)
   ["straight-rail"] = -1,
   ["curved-rail-a"] = -1,
   ["curved-rail-b"] = -1,
   ["elevated-straight-rail"] = -1,
   ["elevated-curved-rail-a"] = -1,
   ["elevated-curved-rail-b"] = -1,
   ["half-diagonal-rail"] = -1,
   ["elevated-half-diagonal-rail"] = -1,
   ["legacy-straight-rail"] = -1,
   ["legacy-curved-rail"] = -1,
   ["rail-ramp"] = -1,
   ["rail-support"] = -1,

   -- Vehicles and rolling stock (priority 1)
   ["car"] = 1,
   ["spider-vehicle"] = 1,
   ["locomotive"] = 1,
   ["cargo-wagon"] = 1,
   ["fluid-wagon"] = 1,
   ["artillery-wagon"] = 1,
   ["infinity-cargo-wagon"] = 1,
   ["cargo-pod"] = 1,

   -- Characters and enemies (priority 2)
   ["character"] = 2,
   ["unit"] = 2,
   ["unit-spawner"] = 2,
   ["segmented-unit"] = 2,
   ["spider-unit"] = 2,
}

---Get the sort priority for an entity type
---@param entity_type string The entity type
---@return number The sort priority (default 0)
local function get_sort_priority(entity_type)
   return SORT_PRIORITIES[entity_type] or 0
end

---Check if an entity should be included in tile queries
---@param ent LuaEntity
---@return boolean
local function should_include_entity(ent)
   if not ent or not ent.valid then return false end
   for _, excluded in ipairs(Consts.EXCLUDED_ENT_NAMES) do
      if ent.name == excluded then return false end
   end
   return true
end

---Implements stable total ordering over entities per issue #265
---@param a LuaEntity
---@param b LuaEntity
---@param pindex number For player index
---@return boolean True if a < b
local function compare_entities(a, b, pindex)
   -- Ghosts before non-ghosts
   local a_is_ghost = a.type == "entity-ghost" or a.type == "tile-ghost"
   local b_is_ghost = b.type == "entity-ghost" or b.type == "tile-ghost"
   if a_is_ghost and not b_is_ghost then return true end
   if b_is_ghost and not a_is_ghost then return false end

   -- Compare by priority (higher priority first)
   local a_priority = get_sort_priority(a.type)
   local b_priority = get_sort_priority(b.type)
   if a_priority ~= b_priority then return a_priority > b_priority end

   -- Has unit_number before doesn't
   local a_has_unit = a.unit_number ~= nil
   local b_has_unit = b.unit_number ~= nil
   if a_has_unit and not b_has_unit then return true end
   if b_has_unit and not a_has_unit then return false end

   -- Compare unit_numbers if both have
   if a_has_unit and b_has_unit then return a.unit_number < b.unit_number end

   -- Has mining_target before doesn't (only check on mining drills)
   if a.type == "mining-drill" and b.type == "mining-drill" then
      local a_has_mining = a.mining_target ~= nil
      local b_has_mining = b.mining_target ~= nil
      if a_has_mining and not b_has_mining then return true end
      if b_has_mining and not a_has_mining then return false end
   end

   -- Compare prototype names lexicographically
   if a.name ~= b.name then return a.name < b.name end

   -- For item-on-ground, compare item names
   if a.type == "item-entity" and b.type == "item-entity" then
      local a_stack = a.stack
      local b_stack = b.stack
      if a_stack and b_stack and a_stack.name ~= b_stack.name then return a_stack.name < b_stack.name end
   end

   -- Last resort: register for destruction and compare registration numbers
   local reg_num_a = script.register_on_object_destroyed(a)
   local reg_num_b = script.register_on_object_destroyed(b)

   return reg_num_a < reg_num_b
end

---Get entities on a tile in stable sorted order
---@param surface LuaSurface
---@param x number Tile x coordinate (will be floored)
---@param y number Tile y coordinate (will be floored)
---@param pindex number Player index (for primary entity detection)
---@return LuaEntity[] Sorted entities in stable order
function mod.get_ents_on_tile(surface, x, y, pindex)
   local floor_x = math.floor(x)
   local floor_y = math.floor(y)

   local search_area = {
      { x = floor_x + 0.001, y = floor_y + 0.001 },
      { x = floor_x + 0.999, y = floor_y + 0.999 },
   }

   -- Get all entities in area
   local all_ents = surface.find_entities_filtered({ area = search_area })

   -- Filter to included entities
   local ents = {}
   for _, ent in ipairs(all_ents) do
      if should_include_entity(ent) then table.insert(ents, ent) end
   end

   -- Add corpses separately
   local corpses = surface.find_entities_filtered({
      area = search_area,
      type = "corpse",
   })
   for _, corpse in ipairs(corpses) do
      if should_include_entity(corpse) then table.insert(ents, corpse) end
   end

   -- Sort with stable ordering
   table.sort(ents, function(a, b)
      return compare_entities(a, b, pindex)
   end)

   return ents
end

--- Get the first entity at a tile
-- The entity list is sorted to have primary entities first, so a primary entity is expected.
---@param pindex number The player index
---@return LuaEntity|nil The first entity at the tile, or nil if none found
function mod.get_first_ent_at_tile(pindex)
   local player = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local c_pos = vp:get_cursor_pos()

   local ents = mod.get_ents_on_tile(player.surface, c_pos.x, c_pos.y, pindex)
   if #ents == 0 then return nil end

   ent_selection_storage[pindex].ent_index = 1
   return ents[1]
end

--- Get the next entity at this tile and note its index.
-- The tile entity list is already sorted such that primary ents are listed first.
-- Cycles through with modulus wrapping.
---@param pindex number The player index
---@return LuaEntity|nil The next entity at the tile, or nil if none found
function mod.get_next_ent_at_tile(pindex)
   local state = ent_selection_storage[pindex]
   local player = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local c_pos = vp:get_cursor_pos()

   local ents = mod.get_ents_on_tile(player.surface, c_pos.x, c_pos.y, pindex)
   if #ents == 0 then return nil end

   -- Increment and wrap with modulus
   state.ent_index = (state.ent_index % #ents) + 1
   return ents[state.ent_index]
end

--- Produce an iterator over all entities for a player's selected tile,
-- while filtering out the player themselves.
---@param pindex number The player index
---@return function, nil, nil
function mod.iterate_selected_ents(pindex)
   local player = game.get_player(pindex)
   local vp = Viewpoint.get_viewpoint(pindex)
   local c_pos = vp:get_cursor_pos()

   local ents = mod.get_ents_on_tile(player.surface, c_pos.x, c_pos.y, pindex)
   local i = 0

   return function()
      while i < #ents do
         i = i + 1
         local ent = ents[i]
         if ent.type ~= "character" or ent.player ~= pindex then return ent end
      end
      return nil
   end,
      nil,
      nil
end

--- Get the tile info for the player's current cursor tile
---@param pindex number The player index
---@return string?, LuaTile? Tile name and tile object, or nil if error
function mod.get_player_tile(pindex)
   local player = game.get_player(pindex)
   local surf = player.surface
   local vp = Viewpoint.get_viewpoint(pindex)
   local c_pos = vp:get_cursor_pos()

   -- Reset cycling state
   ent_selection_storage[pindex].ent_index = 1

   -- Get tile info
   local tile_name, tile_object
   if
      not pcall(function()
         local tile = surf.get_tile(c_pos.x, c_pos.y)
         tile_name = tile.name
         tile_object = tile
      end)
   then
      return nil, nil
   end

   return tile_name, tile_object
end

--- Reset entity cycling index (for when cursor moves)
---@param pindex number The player index
function mod.reset_entity_index(pindex)
   ent_selection_storage[pindex].ent_index = 1
end

return mod
