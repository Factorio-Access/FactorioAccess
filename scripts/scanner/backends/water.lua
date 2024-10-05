local Clusterer = require("scripts.ds.clusterer")
local SC = require("scripts.scanner.scanner-consts")
local TH = require("scripts.table-helpers")
local Memosort = require("scripts.memosort")
local TileClusterer = require("scripts.ds.tile-clusterer")

local mod = {}

local WATER_PROTOS_SET = {}
TH.array_to_set(WATER_PROTOS_SET, SC.WATER_PROTOS)

---@class fa.scanner.WaterBackend: fa.scanner.ScannerBackend
---@field surface LuaSurface
---@field clusterer fa.ds.TileClusterer
local WaterBackend = {}
mod.WaterBackend = WaterBackend
local WaterBackend_meta = { __index = WaterBackend }
if script then script.register_metatable("fa.scanner.WaterBackend", WaterBackend_meta) end

---@param surface LuaSurface
function WaterBackend.new(surface)
   return setmetatable(
      { surface = surface, clusterer = TileClusterer.TileClusterer.new({ track_interior = false }), entry_cache = {} },
      WaterBackend_meta
   )
end

---@param e fa.scanner.ScanEntry
function WaterBackend:on_new_entity(e) end

---@param player LuaPlayer
---@param e fa.scanner.ScanEntry
function WaterBackend:validate_entry(player, e)
   if player.surface.index ~= self.surface.index then return false end

   -- Could be landfilled. Check that to get our answer.
   return player.surface.count_tiles_filtered({
      area = e.bounding_box,
      name = SC.WATER_PROTOS,
      limit = 1,
   }) > 0
end

function WaterBackend:update_entry(player, e) end

function WaterBackend:readout_entry(player, e)
   local bb = e.bounding_box
   local w = bb.right_bottom.x - bb.left_top.x
   local h = bb.right_bottom.y - bb.left_top.y
   local area = math.floor(w * h)
   return { "fa.scanner-water", w, h }
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function WaterBackend:dump_entries_to_callback(player, callback)
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
         position = { x = e_x, y = e_y },
         bounding_box = {
            left_top = { x = tlx, y = tly },
            right_bottom = { x = brx, y = bry },
         },
         backend = self,
         category = SC.CATEGORIES.RESOURCES,
         subcategory = "water",
      })
   end)
end

---@param chunk ChunkPositionAndArea
function WaterBackend:on_new_chunk(chunk)
   local tiles = self.surface.find_tiles_filtered({
      area = chunk.area,
      name = SC.WATER_PROTOS,
   })

   -- Convert to xy.
   local xy = {}
   for i = 1, #tiles do
      table.insert(xy, tiles[i].position)
   end

   self.clusterer:submit_points(xy)
end

return mod