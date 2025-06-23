local Clusterer = require("scripts.ds.clusterer")
local SC = require("scripts.scanner.scanner-consts")
local TH = require("scripts.table-helpers")
local Memosort = require("scripts.memosort")
local TileClusterer = require("scripts.ds.tile-clusterer")

local mod = {}

local ICEBERG_PROTOS_SET = {}
TH.array_to_set(ICEBERG_PROTOS_SET, SC.ICEBERG_PROTOS)

---@class fa.scanner.backends.IcebergBackendData
---@field aabb fa.AABB

---@class fa.scanner.IcebergBackend: fa.scanner.ScannerBackend
---@field surface LuaSurface
---@field clusterer fa.ds.TileClusterer
local IcebergBackend = {}
local IcebergBackend_meta = { __index = IcebergBackend }
mod.IcebergBackend = IcebergBackend
if script then script.register_metatable("fa.scanner.IcebergBackend", IcebergBackend_meta) end

---@param surface LuaSurface
function IcebergBackend.new(surface)
   return setmetatable(
      { surface = surface, clusterer = TileClusterer.TileClusterer.new({ track_interior = true }), entry_cache = {} },
      IcebergBackend_meta
   )
end

---@param e LuaEntity
function IcebergBackend:on_new_entity(e) end

---@param player LuaPlayer
---@param e fa.scanner.ScanEntry
function IcebergBackend:validate_entry(player, e)
   if player.surface.index ~= self.surface.index then return false end

   -- Could be landfilled. Check that to get our answer.
   return player.surface.count_tiles_filtered({
      area = e.backend_data.aabb,
      name = SC.ICEBERG_PROTOS,
      limit = 1,
   }) > 0
end

function IcebergBackend:update_entry(player, e) end

function IcebergBackend:readout_entry(player, e)
   local bb = e.backend_data.aabb
   local w = bb.right_bottom.x - bb.left_top.x
   local h = bb.right_bottom.y - bb.left_top.y
   return { "fa.scanner-iceberg", w, h }
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function IcebergBackend:dump_entries_to_callback(player, callback)
   ---@param group fa.ds.TileClusterer.Group
   self.clusterer:get_groups(function(group)
      local tlx = math.huge
      local tly = math.huge
      local brx = -math.huge
      local bry = -math.huge

      local closest_dist = math.huge
      local e_x, e_y
      local px, py = player.position.x, player.position.y

      for x, children in pairs(group.edge_tiles) do
         tlx = tlx < x and tlx or x
         brx = brx > x and brx or x

         for y in pairs(children) do
            tly = tly < y and tly or y
            bry = bry > y and bry or y

            local dist = (px - x) ^ 2 + (py - y) ^ 2
            if dist < closest_dist then
               closest_dist = dist
               e_x = x
               e_y = y
            end
         end
      end

      -- This is the top-left corner of the bottom-right tile. We want the
      -- bottom right.
      brx = brx + 1
      bry = bry + 1

      callback({
         -- This is fun.  If we use the corner of the tile, confused geometry in the cursor handling code will currently
         -- corrupt the cursor to temporarily be off by one tile to the northwest in some and only some contexts.  Since
         -- this won't break in future, we offset to the center of the tile to fix that.
         position = { x = e_x + 0.5, y = e_y + 0.5 },
         backend_data = {
            aabb = {
               left_top = { x = tlx, y = tly },
               right_bottom = { x = brx, y = bry },
            },
         },
         backend = self,
         category = SC.CATEGORIES.TERRAIN,
         subcategory = "iceberg",
      })
   end)
end

---@param chunk ChunkPositionAndArea
function IcebergBackend:on_new_chunk(chunk)
   if not script.feature_flags.space_travel then return end

   local tiles = self.surface.find_tiles_filtered({
      area = chunk.area,
      name = SC.ICEBERG_PROTOS,
   })

   -- Convert to xy.
   local xy = {}
   for i = 1, #tiles do
      table.insert(xy, tiles[i].position)
   end

   self.clusterer:submit_points(xy)
end

function IcebergBackend:get_aabb(e)
   local aabb = e.backend_data.aabb
   local lt = aabb.left_top
   local rb = aabb.right_bottom
   return lt.x, lt.y, rb.x, rb.y
end

function IcebergBackend:is_huge(e)
   return true
end

return mod
