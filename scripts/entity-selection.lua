--- Entity selection utilities for handling entities at tiles
local mod = {}

local Consts = require("scripts.consts")
local StorageManager = require("scripts.storage-manager")
local Viewpoint = require("scripts.viewpoint")

---@class fa.EntitySelection.StorageState
---@field ents LuaEntity[]
---@field ent_index number
---@field last_returned_index number
---@field tile string
---@field tile_object LuaTile

---@type table<number, fa.EntitySelection.StorageState>
local ent_selection_storage = StorageManager.declare_storage_module("entity_selection", {
   ents = {},
   ent_index = 0,
   last_returned_index = 0,
   tile = nil,
   tile_object = nil,
})

--- Define primary ents, which are ents that show up first when reading tiles.
-- Notably, the definition is done by listing which types count as secondary.
---@param ent LuaEntity The entity to check
---@param pindex number The player index
---@return boolean True if the entity is primary
function mod.ent_is_primary(ent, pindex)
   return ent.type ~= "logistic-robot"
      and ent.type ~= "construction-robot"
      and ent.type ~= "combat-robot"
      and ent.type ~= "corpse"
      and ent.type ~= "rocket-silo-rocket-shadow"
      and ent.type ~= "resource"
      and (ent.type ~= "character" or ent.player ~= pindex)
end

--- Sorts a list of entities by bringing primary entities to the start
---@param pindex number The player index
---@param ents table Array of entities to sort
function mod.sort_ents_by_primary_first(pindex, ents, check_end_rail_fn)
   table.sort(ents, function(a, b)
      -- Return false if either are invalid
      if a == nil or a.valid == false then return false end
      if b == nil or b.valid == false then return false end

      -- Check if primary
      local a_is_primary = mod.ent_is_primary(a, pindex)
      local b_is_primary = mod.ent_is_primary(b, pindex)

      -- Both or none are primary
      if a_is_primary == b_is_primary then return false end

      -- a is primary while b is not
      if a_is_primary then return true end

      -- b is primary while a is not
      return false
   end)
end

--- Get the first entity at a tile
-- The entity list is sorted to have primary entities first, so a primary entity is expected.
---@param pindex number The player index
---@return LuaEntity|nil The first valid entity at the tile, or nil if none found
function mod.get_first_ent_at_tile(pindex)
   local ents = ent_selection_storage[pindex].ents

   --Return nil for an empty ents list
   if ents == nil or #ents == 0 then return nil end

   --Attempt to find the next ent (init to end)
   for i = 1, #ents, 1 do
      local current = ents[i]
      if current and current.valid then
         ent_selection_storage[pindex].ent_index = i
         ent_selection_storage[pindex].last_returned_index = i
         return current
      end
   end

   --By this point there are no valid ents
   return nil
end

--- Get the next entity at this tile and note its index.
-- The tile entity list is already sorted such that primary ents are listed first.
---@param pindex number The player index
---@return LuaEntity|nil The next valid entity at the tile, or nil if none found
function mod.get_next_ent_at_tile(pindex)
   local ents = ent_selection_storage[pindex].ents
   local init_index = ent_selection_storage[pindex].ent_index
   local last_returned_index = ent_selection_storage[pindex].last_returned_index
   local current = ents[init_index]

   --Return nil for an empty ents list
   if ents == nil or #ents == 0 then return nil end

   --Attempt to find the next ent (init to end)
   for i = init_index, #ents, 1 do
      current = ents[i]
      if current and current.valid then
         --If this is not a repeat then return it
         if last_returned_index == 0 or last_returned_index ~= i then
            ent_selection_storage[pindex].ent_index = i
            ent_selection_storage[pindex].last_returned_index = i
            return current
         end
      end
   end

   --Return nil to get the tile info instead
   if last_returned_index ~= 0 then
      ent_selection_storage[pindex].ent_index = 0
      ent_selection_storage[pindex].last_returned_index = 0
      return nil
   end

   --Attempt to find the next ent (start to init)
   for i = 1, init_index - 1, 1 do
      current = ents[i]
      if current and current.valid then
         --If this is not a repeat then return it
         if last_returned_index == 0 or last_returned_index ~= i then
            ent_selection_storage[pindex].ent_index = i
            ent_selection_storage[pindex].last_returned_index = i
            return current
         end
      end
   end

   --By this point there are no valid ents
   ent_selection_storage[pindex].ent_index = 0
   ent_selection_storage[pindex].last_returned_index = 0
   return nil
end

--- Produce an iterator over all valid entities for a player's selected tile,
-- while filtering out the player themselves.
---@param pindex number The player index
---@return function Iterator function that returns entities
---@return nil
---@return nil
function mod.iterate_selected_ents(pindex)
   local tile = ent_selection_storage[pindex]
   local ents = tile.ents
   local i = 1

   local next_fn
   next_fn = function()
      -- Ignore all entities that are a character belonging to this player. It
      -- should only be one, but we don't mutate so we don't know.
      while i <= #ents do
         local ent = ents[i]
         i = i + 1

         if ent and ent.valid then
            if ent.type ~= "character" or ent.player ~= pindex then return ent end
         end
      end

      return nil
   end

   return next_fn, nil, nil
end

--- Refresh the entity list for the player's current cursor tile
---@param pindex number The player index
---@return boolean True if refresh succeeded, false if an error occurred
function mod.refresh_player_tile(pindex)
   local surf = game.get_player(pindex).surface
   local vp = Viewpoint.get_viewpoint(pindex)
   local c_pos = vp:get_cursor_pos()
   local x = c_pos.x + 0.5
   local y = c_pos.y + 0.5
   local search_area = {
      { x = math.floor(x) + 0.001, y = math.floor(y) + 0.001 },
      { x = math.ceil(x) - 0.01, y = math.ceil(y) - 0.01 },
   }
   ent_selection_storage[pindex].ents =
      surf.find_entities_filtered({ area = search_area, name = Consts.EXCLUDED_ENT_NAMES, invert = true })

   -- Sort entities without rail-specific sorting
   mod.sort_ents_by_primary_first(pindex, ent_selection_storage[pindex].ents, nil)
   --Draw the tile
   --rendering.draw_rectangle{left_top = search_area[1], right_bottom = search_area[2], color = {1,0,1}, surface = surf, time_to_live = 100}--
   local remnants = surf.find_entities_filtered({ area = search_area, type = "corpse" })
   for i, remnant in ipairs(remnants) do
      table.insert(ent_selection_storage[pindex].ents, remnant)
   end
   ent_selection_storage[pindex].ent_index = 1
   if #ent_selection_storage[pindex].ents == 0 then ent_selection_storage[pindex].ent_index = 0 end
   ent_selection_storage[pindex].last_returned_index = 0
   if
      not (
         pcall(function()
            local vp = Viewpoint.get_viewpoint(pindex)
            local cursor_pos = vp:get_cursor_pos()
            local tile = surf.get_tile(cursor_pos.x, cursor_pos.y)
            ent_selection_storage[pindex].tile = tile.name
            ent_selection_storage[pindex].tile_object = tile
         end)
      )
   then
      return false
   end
   return true
end

--- Get the cached tile data for a player
---@param pindex number The player index
---@return table The tile cache containing ents, tile name, and tile object
function mod.get_tile_cache(pindex)
   return ent_selection_storage[pindex]
end

return mod
