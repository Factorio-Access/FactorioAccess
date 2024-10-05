--[[
Trees have the same problem as water: there's a billion of them spread widely.

Blind players can't really tell how "perfectt" this is.  So, two basic things:

- The foreests are announced as forests if they're far away.
- The forests are announced as trees if they're close.

And then to make this work we divide them into tiles like how the game does
chunks, and use the much faster tile clusterer.  Any chunk in a forest close
enough to the player gets converted to trees.

It's good enough as long as two things hold: the cursor ends up on a tree and
the player can see trees close to them.

the one thing that does come up here is that it's important for us to be able to
cluster in batches. We thus do the clustering when dumping, but the work which
is done at that time is saved.

We shove the tree count in as backend_data.
]]
local SC = require("scripts.scanner.scanner-consts")
local TileClusterer = require("scripts.ds.tile-clusterer")
local TH = require("scripts.table-helpers")

local mod = {}

---@class fa.scanner.backends.TreeBackend: fa.scanner.ScannerBackend
---@field point_queue { x: number, y: number }[]
---@field clusterer fa.ds.TileClusterer
---@field chunk_size number Saved version of ScannerConsts's value.
---@field surface LuaSurface
local TreeBackend = {}
local TreeBackend_meta = { __index = TreeBackend }
if script then script.register_metatable("fa.scanner.backends.TreeBackenmd", TreeBackend_meta) end
mod.TreeBackend = TreeBackend

---@return fa.scanner.backends.TreeBackend
function TreeBackend.new(surface)
   ---@type fa.scanner.backends.TreeBackend
   local r = {
      clusterer = TileClusterer.TileClusterer.new({ track_interior = true }),
      chunk_size = SC.FOREST_CHUNK_SIZE,
      point_queue = {},
      surface = surface,
   }

   return setmetatable(r, TreeBackend_meta)
end

function TreeBackend:on_new_entity(entity)
   local cx, cy = math.floor(entity.position.x / self.chunk_size), math.floor(entity.position.y / self.chunk_size)

   table.insert(self.point_queue, { x = cx, y = cy })
end

---@param event EventData.on_entity_destroyed
function TreeBackend:on_entity_destroyed(event) end

function TreeBackend:update_entry(player, e)
   local aabb = e.backend_data.aabb
   local trees = self.surface.find_entities_filtered({ area = aabb, tpe = "tree" })
   local closest = self.surface.get_closest(player.position, trees)
   -- It's still in the AABB, just a different point.
   e.position = closest.position
end

function TreeBackend:validate_entry(player, e)
   return self.surface.valid
      and self.surface.count_entities_filtered({ area = e.backend_data.aabb, type = "tree", limit = 1 }) > 0
end

function TreeBackend:readout_entry(player, e)
   return { "fa.scanner-forest", e.backend_data.tree_count }
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function TreeBackend:dump_entries_to_callback(player, callback)
   -- Step 1: feed all of OUR NEW POINTS To THE CLUSTERER.
   if next(self.point_queue) then
      self.clusterer:submit_points(self.point_queue)
      self.point_queue = {}
   end
   local px, py = player.position.x, player.position.y
   local CAT_RESOURCES = SC.CATEGORIES.RESOURCES
   local find_entities_filtered = self.surface.find_entities_filtered

   ---@param g fa.ds.TileClusterer.Group
   self.clusterer:get_groups(function(g)
      -- We work out the count, bounding box, and then find a tree closest to
      -- the player.
      local tlx = math.huge
      local tly = math.huge
      local brx = -math.huge
      local bry = -math.huge

      for x, children in pairs(g.edge_tiles) do
         tlx = tlx < x and tlx or x
         brx = brx > x and brx or x

         for y in pairs(children) do
            tly = tly < y and tly or y
            bry = bry > y and bry or y
         end
      end

      -- These are the top left of a tile; make them the bottom right.
      brx = brx + 1
      bry = bry + 1

      tlx = tlx * self.chunk_size
      brx = brx * self.chunk_size
      tly = tly * self.chunk_size
      bry = bry * self.chunk_size

      local aabb = {
         left_top = { x = tlx, y = tly },
         right_bottom = { x = brx, y = bry },
      }

      local trees = find_entities_filtered({ area = aabb, type = "tree" })
      -- If still not, skip this one.
      if not next(trees) then return end

      local closest = self.surface.get_closest(player.position, trees)

      callback({
         backend = self,
         backend_data = { tree_count = #trees, aabb = aabb },
         position = closest.position,
         category = CAT_RESOURCES,
         subcategory = "tree",
      })
   end)

   -- Todo: zoom. But let's see it work at all first.
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
