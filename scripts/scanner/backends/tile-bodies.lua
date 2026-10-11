--[[
Bodies of tiles: water, lava, oceans, Gleba's marshes and soils, Aquilo's land. Each kind in
ScannerConsts.tile_body_kinds() gets its own clusterer, and each cluster is one entry read as "name w by h".
]]
local BlockClusterer = require("ds.block-clusterer")
local SC = require("scripts.scanner.scanner-consts")

local bor, lshift = bit32.bor, bit32.lshift

local mod = {}

-- A chunk is one clusterer block, a tile one cell.
local BLOCK_SIZE = BlockClusterer.BLOCK_SIZE --[[@as integer]]

-- Terrain kinds break up into many specks (Gleba's marsh comes in 1 by 1 patches) that only bury the bodies worth
-- reading. Liquids keep every body: a lava pool of a few tiles still decides where things can go. Counted in edge
-- tiles: a 3 by 3 body has 8, a 3 by 4 one has 10.
local MIN_TERRAIN_EDGE_TILES = 10

---@class fa.scanner.backends.TileBodiesBackendData
---@field aabb fa.AABB
---@field kind string Key into ScannerConsts.tile_body_kinds().by_key

---@class fa.scanner.TileBodiesBackend: fa.scanner.ScannerBackend
---@field surface LuaSurface
---@field clusterers table<string, fa.ds.BlockClusterer?> By kind key, made when a kind's first tile is seen
---@field chunk_counts table<integer, table<integer, integer>> Body tiles in each chunk at its last read
---@field dirty_chunks table<integer, table<integer, true>> Chunks to reread before the next dump
local TileBodiesBackend = {}
mod.TileBodiesBackend = TileBodiesBackend
local TileBodiesBackend_meta = { __index = TileBodiesBackend }
script.register_metatable("fa.scanner.TileBodiesBackend", TileBodiesBackend_meta)

-- The water and iceberg backends this replaced, and the tile clusterer before ds.block-clusterer. Saves made with them still hold tables linked to these names until
-- the scanner's storage is rebuilt, and loading needs the names registered.
script.register_metatable("fa.scanner.WaterBackend", {})
script.register_metatable("fa.scanner.IcebergBackend", {})
script.register_metatable("fa.ds.TileClusterer", {})

---@param surface LuaSurface
function TileBodiesBackend.new(surface)
   return setmetatable(
      { surface = surface, clusterers = {}, chunk_counts = {}, dirty_chunks = {} },
      TileBodiesBackend_meta
   )
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

-- Read a chunk's tiles into the clusterers, replacing what they had for it.
---@param cx integer
---@param cy integer
function TileBodiesBackend:read_chunk(cx, cy)
   local kinds = SC.tile_body_kinds()
   local ox, oy = cx * BLOCK_SIZE, cy * BLOCK_SIZE
   local tiles = self.surface.find_tiles_filtered({
      area = { left_top = { x = ox, y = oy }, right_bottom = { x = ox + BLOCK_SIZE, y = oy + BLOCK_SIZE } },
      name = kinds.all_tiles,
   })

   ---@type table<string, integer[]>
   local by_kind = {}
   for i = 1, #tiles do
      local tile = tiles[i]
      local key = kinds.by_tile[tile.name].key
      local rows = by_kind[key]
      if not rows then
         rows = BlockClusterer.empty_rows()
         by_kind[key] = rows
      end
      local pos = tile.position
      local x, y =
         pos.x, --[[@as integer]]
         pos.y --[[@as integer]]
      local ri = y - oy + 1
      rows[ri] = bor(rows[ri], lshift(1, (x - ox) --[[@as integer]]))
   end

   for key, rows in pairs(by_kind) do
      if not self.clusterers[key] then self.clusterers[key] = BlockClusterer.BlockClusterer.new() end
   end
   for key, clusterer in pairs(self.clusterers) do
      clusterer:set_block(cx, cy, by_kind[key])
   end

   local col = self.chunk_counts[cx]
   if not col then
      col = {}
      self.chunk_counts[cx] = col
   end
   col[cy] = #tiles
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function TileBodiesBackend:dump_entries_to_callback(player, callback)
   for cx, col in pairs(self.dirty_chunks) do
      for cy in pairs(col) do
         self:read_chunk(cx, cy)
      end
   end
   self.dirty_chunks = {}

   local pos = player.position --[[@as MapPosition.struct]]
   local px, py = pos.x, pos.y

   for _, kind in ipairs(SC.tile_body_kinds().kinds) do
      local clusterer = self.clusterers[kind.key]
      if clusterer then
         for _, group in ipairs(clusterer:get_groups()) do
            if kind.category ~= SC.CATEGORIES.TERRAIN or group.edges >= MIN_TERRAIN_EDGE_TILES then
               local e_x, e_y = clusterer:closest_edge(group, px, py)
               callback({
                  -- The tile's centre: the cursor code reads a tile corner as the tile to the northwest in some
                  -- contexts.
                  position = { x = e_x + 0.5, y = e_y + 0.5 },
                  backend_data = {
                     aabb = {
                        left_top = { x = group.x0, y = group.y0 },
                        right_bottom = { x = group.x1 + 1, y = group.y1 + 1 },
                     },
                     kind = kind.key,
                  },
                  backend = self,
                  category = kind.category,
                  subcategory = kind.key,
               })
            end
         end
      end
   end
end

-- The first scan of a chunk.
---@param chunk ChunkPositionAndArea
function TileBodiesBackend:on_new_chunk(chunk)
   self:read_chunk(chunk.x, chunk.y)
end

-- A later scan of a chunk: catches tiles changed without an event (a script's set_tiles) when the count moved.
---@param chunk ChunkPositionAndArea
function TileBodiesBackend:on_chunk_rescanned(chunk)
   local col = self.chunk_counts[chunk.x]
   local known = col and col[chunk.y]
   if not known then return self:read_chunk(chunk.x, chunk.y) end
   local count = self.surface.count_tiles_filtered({ area = chunk.area, name = SC.tile_body_kinds().all_tiles })
   if count ~= known then self:read_chunk(chunk.x, chunk.y) end
end

-- Tiles changed (built, mined, set by a script): reread their chunks before the next dump.
---@param positions MapPosition[]
function TileBodiesBackend:on_tiles_changed(positions)
   local dirty = self.dirty_chunks
   for i = 1, #positions do
      local p = positions[i]
      local cx, cy = math.floor(p.x / BLOCK_SIZE), math.floor(p.y / BLOCK_SIZE)
      local col = dirty[cx]
      if not col then
         col = {}
         dirty[cx] = col
      end
      col[cy] = true
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
