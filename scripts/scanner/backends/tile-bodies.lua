--[[
Bodies of tiles: water, lava, oceans, Gleba's marshes and soils, Aquilo's land. Each kind in
ScannerConsts.tile_body_kinds() gets its own clusterer, and each cluster is one entry read as "name w by h".
]]
local TileClusterer = require("ds.tile-clusterer")
local SC = require("scripts.scanner.scanner-consts")

local mod = {}

-- Terrain kinds break up into many specks (Gleba's marsh comes in 1 by 1 patches) that only bury the bodies worth
-- reading. Liquids keep every body: a lava pool of a few tiles still decides where things can go. Only edge tiles
-- are counted: a 3 by 3 body has 8, a 3 by 4 one has 10.
local MIN_TERRAIN_EDGE_TILES = 10

---@class fa.scanner.backends.TileBodiesBackendData
---@field aabb fa.AABB
---@field kind string Key into ScannerConsts.tile_body_kinds().by_key

---@class fa.scanner.TileBodiesBackend: fa.scanner.ScannerBackend
---@field surface LuaSurface
---@field clusterers table<string, fa.ds.TileClusterer?> By kind key, made when a kind's first tile is seen
local TileBodiesBackend = {}
mod.TileBodiesBackend = TileBodiesBackend
local TileBodiesBackend_meta = { __index = TileBodiesBackend }
script.register_metatable("fa.scanner.TileBodiesBackend", TileBodiesBackend_meta)

-- The water and iceberg backends this replaced. Saves made with them still hold tables linked to these names until
-- the scanner's storage is rebuilt, and loading needs the names registered.
script.register_metatable("fa.scanner.WaterBackend", {})
script.register_metatable("fa.scanner.IcebergBackend", {})

---@param surface LuaSurface
function TileBodiesBackend.new(surface)
   return setmetatable({ surface = surface, clusterers = {} }, TileBodiesBackend_meta)
end

---@param e LuaEntity
function TileBodiesBackend:on_new_entity(e) end

---@param event EventData.on_object_destroyed
function TileBodiesBackend:on_entity_destroyed(event) end

---@param player LuaPlayer
---@param e fa.scanner.ScanEntry
function TileBodiesBackend:validate_entry(player, e)
   if player.surface.index ~= self.surface.index then return false end

   -- Could be landfilled. Check that to get our answer.
   return player.surface.count_tiles_filtered({
      area = e.backend_data.aabb,
      name = SC.tile_body_kinds().by_key[e.backend_data.kind].tiles,
      limit = 1,
   }) > 0
end

function TileBodiesBackend:update_entry(player, e) end

function TileBodiesBackend:readout_entry(player, e)
   local bb = e.backend_data.aabb
   local w = bb.right_bottom.x - bb.left_top.x
   local h = bb.right_bottom.y - bb.left_top.y
   return { "fa.scanner-tile-body", SC.tile_body_kinds().by_key[e.backend_data.kind].name, w, h }
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function TileBodiesBackend:dump_entries_to_callback(player, callback)
   local px, py = player.position.x, player.position.y

   for _, kind in ipairs(SC.tile_body_kinds().kinds) do
      local clusterer = self.clusterers[kind.key]
      if clusterer then
         ---@param group fa.ds.TileClusterer.Group
         clusterer:get_groups(function(group)
            local tlx = math.huge
            local tly = math.huge
            local brx = -math.huge
            local bry = -math.huge

            local closest_dist = math.huge
            local e_x, e_y
            local edge_count = 0

            for x, children in pairs(group.edge_tiles) do
               tlx = tlx < x and tlx or x
               brx = brx > x and brx or x

               for y in pairs(children) do
                  tly = tly < y and tly or y
                  bry = bry > y and bry or y
                  edge_count = edge_count + 1

                  local dist = (px - x) ^ 2 + (py - y) ^ 2
                  if dist < closest_dist then
                     closest_dist = dist
                     e_x = x
                     e_y = y
                  end
               end
            end

            if kind.category == SC.CATEGORIES.TERRAIN and edge_count < MIN_TERRAIN_EDGE_TILES then return end

            -- This is the top-left corner of the bottom-right tile. We want the
            -- bottom right.
            brx = brx + 1
            bry = bry + 1

            callback({
               -- This is fun.  If we use the corner of the tile, confused geometry in
               -- the cursor handling code will currently corrupt the cursor to
               -- temporarily be off by one tile to the northwest in some and only
               -- some contexts.  Since this won't break in future, we offset to the
               -- center of the tile to fix that.
               position = { x = e_x + 0.5, y = e_y + 0.5 },
               backend_data = {
                  aabb = {
                     left_top = { x = tlx, y = tly },
                     right_bottom = { x = brx, y = bry },
                  },
                  kind = kind.key,
               },
               backend = self,
               category = kind.category,
               subcategory = kind.key,
            })
         end)
      end
   end
end

---@param chunk ChunkPositionAndArea
function TileBodiesBackend:on_new_chunk(chunk)
   local kinds = SC.tile_body_kinds()
   local tiles = self.surface.find_tiles_filtered({
      area = chunk.area,
      name = kinds.all_tiles,
   })

   ---@type table<string, fa.Point[]>
   local by_kind = {}
   for i = 1, #tiles do
      local key = kinds.by_tile[tiles[i].name].key
      local points = by_kind[key]
      if not points then
         points = {}
         by_kind[key] = points
      end
      table.insert(points, tiles[i].position)
   end

   for key, points in pairs(by_kind) do
      local clusterer = self.clusterers[key]
      if not clusterer then
         clusterer = TileClusterer.TileClusterer.new({ track_interior = kinds.by_key[key].track_interior })
         self.clusterers[key] = clusterer
      end
      clusterer:submit_points(points)
   end
end

function TileBodiesBackend:get_aabb(e)
   local aabb = e.backend_data.aabb
   local lt = aabb.left_top
   local rb = aabb.right_bottom
   return lt.x, lt.y, rb.x, rb.y
end

function TileBodiesBackend:is_huge(e)
   return true
end

return mod
