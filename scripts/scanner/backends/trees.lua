--[[
Trees have the same problem as water: there's a billion of them spread widely.

Blind players can't really tell how "perfect" this is.  So, two basic things:

- The forests are announced as forests if they're far away.
- The forests are announced as trees if they're close.

To make this work the map is cut into squares of FOREST_CHUNK_SIZE tiles, and a square with a tree in it is one
cell of a block clusterer, so trees about two squares apart join into one forest. Any forest tree close enough to
the player is announced on its own.

It's good enough as long as two things hold: the cursor ends up on a tree and the player can see trees close to
them.

Squares are filled a map chunk at a time: a new tree marks its chunk dirty, and the chunk is reread on its next
scan or the next dump. Felled trees raise nothing that says where they were, so every scan of a chunk compares its
tree count with the last read.
]]
local BlockClusterer = require("ds.block-clusterer")
local Info = require("scripts.fa-info")
local SC = require("scripts.scanner.scanner-consts")
local TH = require("scripts.table-helpers")

local band, bnot, bor, lshift = bit32.band, bit32.bnot, bit32.bor, bit32.lshift

local mod = {}

local MAP_CHUNK_SIZE = 32
local BLOCK_SIZE = BlockClusterer.BLOCK_SIZE

-- Gleba's yumako trees and jellystems are plants, a kind of tree.
local TREE_TYPES = { "tree", "plant" }

-- How far outside a forest's box one of its trees can stand: the search finds trees by their collision boxes.
local ZOOM_BOX_MARGIN = 2

---@class fa.scanner.backends.TreeBackend: fa.scanner.ScannerBackend
---@field clusterer fa.ds.BlockClusterer A cell is a chunk_size square with a tree in it
---@field chunk_size integer Saved version of ScannerConsts's value; divides a map chunk.
---@field chunk_counts table<integer, table<integer, integer?>?> Trees in each map chunk at its last read
---@field dirty_chunks table<integer, table<integer, true?>?> Map chunks to reread before the next dump
---@field surface LuaSurface
local TreeBackend = {}
local TreeBackend_meta = { __index = TreeBackend }
script.register_metatable("fa.scanner.backends.TreeBackenmd", TreeBackend_meta)
mod.TreeBackend = TreeBackend

---@return fa.scanner.backends.TreeBackend
function TreeBackend.new(surface)
   return setmetatable({
      clusterer = BlockClusterer.BlockClusterer.new(),
      chunk_size = SC.FOREST_CHUNK_SIZE,
      chunk_counts = {},
      dirty_chunks = {},
      surface = surface,
   }, TreeBackend_meta)
end

---@param cx integer
---@param cy integer
function TreeBackend:mark_dirty(cx, cy)
   local col = self.dirty_chunks[cx]
   if not col then
      col = {}
      self.dirty_chunks[cx] = col
   end
   col[cy] = true
end

function TreeBackend:on_new_entity(entity)
   local p = entity.position
   self:mark_dirty(math.floor(p.x / MAP_CHUNK_SIZE), math.floor(p.y / MAP_CHUNK_SIZE))
end

---@param event EventData.on_object_destroyed
function TreeBackend:on_entity_destroyed(event) end

---@param cx integer
---@param cy integer
---@return BoundingBox.struct
local function chunk_area(cx, cy)
   return {
      left_top = { x = cx * MAP_CHUNK_SIZE, y = cy * MAP_CHUNK_SIZE },
      right_bottom = { x = (cx + 1) * MAP_CHUNK_SIZE, y = (cy + 1) * MAP_CHUNK_SIZE },
   }
end

-- Reread a map chunk's trees into its square of cells, replacing what was there.
---@param cx integer
---@param cy integer
function TreeBackend:read_chunk(cx, cy)
   local size = self.chunk_size
   local per_chunk = math.floor(MAP_CHUNK_SIZE / size)
   local trees = self.surface.find_entities_filtered({ area = chunk_area(cx, cy), type = TREE_TYPES })

   -- The chunk's cells, in the block that holds them.
   local cell_x0, cell_y0 = cx * per_chunk, cy * per_chunk
   local bx, by = math.floor(cell_x0 / BLOCK_SIZE), math.floor(cell_y0 / BLOCK_SIZE)
   local lx0, ly0 = cell_x0 - bx * BLOCK_SIZE, cell_y0 - by * BLOCK_SIZE

   local rows = {}
   for i, r in ipairs(self.clusterer:get_rows(bx, by) or BlockClusterer.empty_rows()) do
      rows[i] = r
   end
   local window = lshift(lshift(1, per_chunk) - 1, lx0)
   for i = ly0 + 1, ly0 + per_chunk do
      rows[i] = band(rows[i], bnot(window))
   end

   for i = 1, #trees do
      local p = trees[i].position
      -- Trees overlapping from a neighbouring chunk belong to that chunk's read.
      local x, y = math.floor(p.x / size) - cell_x0, math.floor(p.y / size) - cell_y0
      if x >= 0 and x < per_chunk and y >= 0 and y < per_chunk then
         local ri = ly0 + y + 1
         rows[ri] = bor(rows[ri], lshift(1, lx0 + x))
      end
   end
   self.clusterer:set_block(bx, by, rows)

   local col = self.chunk_counts[cx]
   if not col then
      col = {}
      self.chunk_counts[cx] = col
   end
   col[cy] = #trees
end

-- Every scan of a map chunk. Felled trees raise nothing we can place, so a changed count rereads the chunk.
---@param chunk ChunkPositionAndArea
function TreeBackend:on_chunk_scanned(chunk)
   local cx, cy = chunk.x, chunk.y
   local dirty = self.dirty_chunks[cx]
   if dirty and dirty[cy] then
      dirty[cy] = nil
      return self:read_chunk(cx, cy)
   end
   local col = self.chunk_counts[cx]
   local known = col and col[cy] or 0
   if self.surface.count_entities_filtered({ area = chunk_area(cx, cy), type = TREE_TYPES }) ~= known then
      self:read_chunk(cx, cy)
   end
end

function TreeBackend:update_entry(player, e)
   local aabb = e.backend_data.aabb
   local trees = self.surface.find_entities_filtered({ area = aabb, type = TREE_TYPES })
   local closest = self.surface.get_closest(player.position, trees)
   -- It's still in the AABB, just a different point.
   e.position = closest.position --[[@as MapPosition.struct]]
end

function TreeBackend:validate_entry(player, e)
   return self.surface.valid
      and self.surface.count_entities_filtered({ area = e.backend_data.aabb, type = TREE_TYPES, limit = 1 }) > 0
end

---@param player LuaPlayer
function TreeBackend:readout_entry(player, e)
   if e.backend_data.zoom_ent then
      return Info.ent_info(player.index, e.backend_data.zoom_ent, true)
   else
      return { "fa.scanner-forest", e.backend_data.tree_count }
   end
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function TreeBackend:dump_entries_to_callback(player, callback)
   for cx, col in pairs(self.dirty_chunks) do
      for cy in pairs(col) do
         self:read_chunk(cx, cy)
      end
   end
   self.dirty_chunks = {}

   local player_pos = player.position --[[@as MapPosition.struct]]
   local px, py = player_pos.x, player_pos.y
   local zoom_squared = SC.FOREST_ZOOM_DISTANCE ^ 2
   local CAT_RESOURCES = SC.CATEGORIES.RESOURCES
   local find_entities_filtered = self.surface.find_entities_filtered

   for _, g in ipairs(self.clusterer:get_groups()) do
      local tlx = g.x0 * self.chunk_size
      local tly = g.y0 * self.chunk_size
      local brx = (g.x1 + 1) * self.chunk_size
      local bry = (g.y1 + 1) * self.chunk_size

      local aabb = {
         left_top = { x = tlx, y = tly },
         right_bottom = { x = brx, y = bry },
      }

      local trees = find_entities_filtered({ area = aabb, type = TREE_TYPES })
      -- Felled since the chunk was last read.
      if not next(trees) then goto continue end

      local zoomed_trees = {}

      -- Filter out any trees close enough for zoom. A forest whose box is farther away has none: most forests, and
      -- the per-tree test is most of a refresh's time.
      local cx = math.min(math.max(px, tlx - ZOOM_BOX_MARGIN), brx + ZOOM_BOX_MARGIN)
      local cy = math.min(math.max(py, tly - ZOOM_BOX_MARGIN), bry + ZOOM_BOX_MARGIN)
      if (px - cx) ^ 2 + (py - cy) ^ 2 < zoom_squared then
         TH.retain_unordered(trees, function(t)
            local p = t.position
            local zoomed = (px - p.x) ^ 2 + (py - p.y) ^ 2 < zoom_squared
            if zoomed then table.insert(zoomed_trees, t) end
            return not zoomed
         end)
      end

      -- Figure out the big non-zoomed one.
      if next(trees) then
         local closest = self.surface.get_closest(player_pos, trees)

         -- If there is only one tree, don't announce as trees x1. instead
         -- "zoom" into it.
         local zoom_ent = #trees == 1 and trees[1] or nil
         if zoom_ent then aabb = trees[1].bounding_box end
         callback({
            backend = self,
            backend_data = { tree_count = #trees, aabb = aabb, zoom_ent = zoom_ent },
            position = closest.position,
            category = CAT_RESOURCES,
            subcategory = "tree",
         })
      end

      for _, t in pairs(zoomed_trees) do
         callback({
            position = t.position,
            category = CAT_RESOURCES,
            subcategory = "tree",
            backend = self,
            backend_data = { tree_count = 1, zoom_ent = t, aabb = t.bounding_box },
         })
      end

      ::continue::
   end
end

function TreeBackend:get_aabb(e)
   local aabb = e.backend_data.aabb
   local lt = aabb.left_top
   local rb = aabb.right_bottom
   return lt.x, lt.y, rb.x, rb.y
end

function TreeBackend:is_huge(e)
   return e.backend_data.tree_count > 100
end

return mod
