--[[
Ore patches. Each kind of ore has a block clusterer whose cell is a square of twice the ore's search radius
(resource_patch_search_radius) with that ore in it; cells touching at a side or a corner are one patch. Vanilla
patches are round and far apart, so this finds the same patches as joining tiles within the search radius.

Each map chunk keeps, per ore, what it held when its ore was found: the richest tile, the total, and the bounds of
the ore. A patch is the chunks whose richest tile is in it: their bounds make its box and their totals its initial
amount, for "percent remaining". Nothing is forgotten as ore is mined out; announcing re-reads the patch.
]]
local BlockClusterer = require("ds.block-clusterer")
local Consts = require("scripts.consts")
local DataToRuntimeMap = require("scripts.data-to-runtime-map")
local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local ScannerConsts = require("scripts.scanner.scanner-consts")
local Speech = require("scripts.speech")

local band, bor, lshift = bit32.band, bit32.bor, bit32.lshift

local mod = {}

local CHUNK_SIZE = 32
local BLOCK_SIZE = BlockClusterer.BLOCK_SIZE

---@type fun(): table<string, number?>
local PROTOTYPE_SEARCH_RADIUSES = Functools.cached(function()
   -- With ModData, numbers are stored directly, no need to convert from strings
   return DataToRuntimeMap.load(Consts.RESOURCE_SEARCH_RADIUSES_MAP_NAME)
end)

---@class fa.scanner.ResourcePatch
---@field highest_point { x: number, y: number, amount: number }
---@field initial_total_amount number
---@field prototype string

---@class fa.scanner.ResourcePatchEntData: fa.scanner.ResourcePatch
---@field aabb BoundingBox.struct
---@field zoom_override LuaEntity?

-- One ore in one map chunk, as found: the richest tile, the total, and the bounds of its tiles.
---@class fa.scanner.ResourceChunk
---@field x number
---@field y number
---@field amount number
---@field total number
---@field x0 number
---@field y0 number
---@field x1 number
---@field y1 number

---@class fa.scanner.ResourcePatchesBackend: fa.scanner.ScannerBackend
---@field clusterers table<string, fa.ds.BlockClusterer?> By ore: a cell is a square of cell_sizes[ore] tiles with it
---@field cell_sizes table<string, integer>
---@field chunks table<string, table<number, fa.scanner.ResourceChunk>> By ore, then chunk_key
local ResourcePatchesBackend = {}
local ResourcePatchesBackend_meta = { __index = ResourcePatchesBackend }
script.register_metatable("fa.scanner.ResourcePatches", ResourcePatchesBackend_meta)
mod.ResourcePatchesBackend = ResourcePatchesBackend

---@param ent LuaEntity
---@return integer
local function amount_for(ent)
   return ent.amount
end

-- Chunk coordinates are within plus or minus 2^15 on any map.
---@param cx integer
---@param cy integer
---@return number
local function chunk_key(cx, cy)
   return (cx + 32768) * 65536 + (cy + 32768)
end

---@return fa.scanner.ResourcePatchesBackend
function ResourcePatchesBackend.new()
   local ret = {
      clusterers = {},
      cell_sizes = {},
      chunks = {},
   }
   return setmetatable(ret, ResourcePatchesBackend_meta)
end

---@param proto string
---@return fa.ds.BlockClusterer
function ResourcePatchesBackend:get_clusterer_for(proto)
   local c = self.clusterers[proto]
   if c then return c end

   -- The radius of the resource is only available on the raw prototype.  While
   -- it is the case that the resource search distance is optional, we're a mod
   -- trying to do this reasonably so we just pull a default out of the air.
   local search_radius = PROTOTYPE_SEARCH_RADIUSES()[proto]
   -- We are careful to default this when declaring the map, so not finding one
   -- is a bug; trees have long since been moved to their own clusterer.
   assert(search_radius)

   local nc = BlockClusterer.BlockClusterer.new({ diagonal = true })
   self.clusterers[proto] = nc
   self.cell_sizes[proto] = math.max(1, math.floor(2 * search_radius))
   self.chunks[proto] = {}
   return nc
end

---@param new_entity LuaEntity
function ResourcePatchesBackend:on_new_entity(new_entity)
   local name = new_entity.name
   local amount = amount_for(new_entity)
   local pos = new_entity.position --[[@as MapPosition.struct]]
   local x, y = pos.x, pos.y

   local clusterer = self:get_clusterer_for(name)
   local size = self.cell_sizes[name]
   local cx, cy = math.floor(x / size), math.floor(y / size)
   local bx, by = math.floor(cx / BLOCK_SIZE), math.floor(cy / BLOCK_SIZE)
   local ri = cy - by * BLOCK_SIZE + 1
   local bit = lshift(1, cx - bx * BLOCK_SIZE)
   local rows = clusterer:get_rows(bx, by)
   if not rows or band(rows[ri], bit) == 0 then
      -- The clusterer keeps the rows it is given, so a change is a new copy.
      local new_rows = {}
      for i = 1, BLOCK_SIZE do
         new_rows[i] = rows and rows[i] or 0
      end
      new_rows[ri] = bor(new_rows[ri], bit)
      clusterer:set_block(bx, by, new_rows)
   end

   local chunks = self.chunks[name]
   local key = chunk_key(math.floor(x / CHUNK_SIZE), math.floor(y / CHUNK_SIZE))
   local c = chunks[key]
   if not c then
      chunks[key] = { x = x, y = y, amount = amount, total = amount, x0 = x, y0 = y, x1 = x, y1 = y }
      return
   end
   c.total = c.total + amount
   if amount > c.amount then
      c.x, c.y, c.amount = x, y, amount
   end
   if x < c.x0 then c.x0 = x end
   if y < c.y0 then c.y0 = y end
   if x > c.x1 then c.x1 = x end
   if y > c.y1 then c.y1 = y end
end

-- The ore's patches now, each with its box in tiles and its chunks' data folded together.
---@param proto string
---@return { aabb: BoundingBox.struct, data: fa.scanner.ResourcePatch }[]
function ResourcePatchesBackend:patches(proto)
   local clusterer = assert(self.clusterers[proto])
   local size = self.cell_sizes[proto]

   -- Which group each component is in, to find a chunk's patch from its richest tile.
   ---@type table<fa.ds.BlockClusterer.Component, integer>
   local group_of = {}
   for gi, g in ipairs(clusterer:get_groups()) do
      for _, comp in ipairs(g.comps) do
         group_of[comp] = gi
      end
   end

   ---@type table<integer, { aabb: BoundingBox.struct, data: fa.scanner.ResourcePatch }>
   local by_group = {}
   for _, c in pairs(self.chunks[proto]) do
      local cx, cy = math.floor(c.x / size), math.floor(c.y / size)
      local bx, by = math.floor(cx / BLOCK_SIZE), math.floor(cy / BLOCK_SIZE)
      local lx, ly = cx - bx * BLOCK_SIZE, cy - by * BLOCK_SIZE
      local block = assert(clusterer:get_block(bx, by), "a found tile's cell is set")
      ---@type integer?
      local gi
      for _, comp in ipairs(block.comps) do
         local row = comp.rows[ly - comp.y0 + 1]
         if row and band(row, lshift(1, lx)) ~= 0 then
            gi = group_of[comp]
            break
         end
      end
      gi = assert(gi, "a set cell is in a component")

      -- A tile at x spans x to x + 1, wherever the entity's position is in it.
      local x0, y0, x1, y1 = math.floor(c.x0), math.floor(c.y0), math.floor(c.x1) + 1, math.floor(c.y1) + 1
      local p = by_group[gi]
      if not p then
         by_group[gi] = {
            aabb = { left_top = { x = x0, y = y0 }, right_bottom = { x = x1, y = y1 } },
            data = {
               highest_point = { x = c.x, y = c.y, amount = c.amount },
               initial_total_amount = c.total,
               prototype = proto,
            },
         }
      else
         local lt, rb, d = p.aabb.left_top, p.aabb.right_bottom, p.data
         if x0 < lt.x then lt.x = x0 end
         if y0 < lt.y then lt.y = y0 end
         if x1 > rb.x then rb.x = x1 end
         if y1 > rb.y then rb.y = y1 end
         d.initial_total_amount = d.initial_total_amount + c.total
         if c.amount > d.highest_point.amount then d.highest_point = { x = c.x, y = c.y, amount = c.amount } end
      end
   end

   local out = {}
   for _, p in pairs(by_group) do
      out[#out + 1] = p
   end
   return out
end

function ResourcePatchesBackend:on_entity_destroyed()
   -- We aren't working with entities in this way.  Instead we have to figure
   -- out which patches are still live with a rescan.
end

---@param player LuaPlayer
---@param ent fa.scanner.ScanEntry
function ResourcePatchesBackend:validate_entry(player, ent)
   local bd = ent.backend_data
   if bd.zoom_override then return bd.zoom_override.valid and bd.zoom_override.surface_index == player.surface_index end

   local count = player.surface.count_entities_filtered({
      area = ent.backend_data.aabb,
      name = bd.prototype,
   })

   return count > 0
end

function ResourcePatchesBackend:update_entry(player, ent)
   -- Nothing to do.  Re-update happens on announcement.  Revalidation scans
   -- happen in validation.
end

---@param player LuaPlayer
---@param ent fa.scanner.ScanEntry
function ResourcePatchesBackend:readout_entry(player, ent)
   ---@type fa.scanner.ResourcePatchEntData
   local bd = ent.backend_data
   local pname = bd.prototype

   if bd.zoom_override then return FaInfo.ent_info(player.index, bd.zoom_override, true) end

   local ents

   ents = player.surface.find_entities_filtered({
      area = ent.backend_data.aabb,
      name = pname,
   })

   local total = 0
   for _, e in pairs(ents) do
      total = total + amount_for(e)
   end

   local proto = prototypes.entity[pname]

   if proto.infinite_resource then
      return Speech.MessageBuilder
         .new()
         :fragment(proto.localised_name)
         :list_item_forced_comma({
            "fa.ent-info-resource-infinite",
            math.floor(total / proto.normal_resource_amount * 100),
         })
         :build()
   end

   return {
      "fa.scanner-resource-patch",
      proto.localised_name,
      FaUtils.format_number(total),
      math.floor(total / bd.initial_total_amount * 100),
   }
end

---@param player LuaPlayer
---@param callback fa.scanner.EntryCallback
function ResourcePatchesBackend:dump_entries_to_callback(player, callback)
   local RESOURCES = ScannerConsts.CATEGORIES.RESOURCES
   local player_pos = player.position --[[@as MapPosition.struct]]
   local px, py = player_pos.x, player_pos.y

   for n in pairs(self.clusterers) do
      local is_infinite = prototypes.entity[n].infinite_resource

      local zoom_dist = nil

      if is_infinite then zoom_dist = ScannerConsts.INFINITE_RESOURCE_ZOOM_DISTANCE end

      local function emit(cluster)
         ---@type fa.scanner.ResourcePatch
         local d = cluster.data

         ---@type fa.scanner.ResourcePatchEntData
         local agg_data = {
            aabb = cluster.aabb,
            highest_point = d.highest_point,
            -- Without the prototype, we can't do a query on the patch without
            -- having an original entity, which may no longer exist.
            prototype = n,
            initial_total_amount = d.initial_total_amount,

            -- When set this is a zoomed entry; announce with FaInfo instead.
            zoom_override = nil,
         }
         local function emit_aggregate()
            callback(self, d.highest_point.x, d.highest_point.y, RESOURCES, n, agg_data)
         end

         if not zoom_dist then
            emit_aggregate()
            return
         end

         -- Important shortcut.  If the cluster's aabb is further away than the
         -- player is, then we want  to avoid doing anything: surface scans
         --  hurt.
         local left_top = cluster.aabb.left_top --[[@as fa.Point]]
         local right_bottom = cluster.aabb.right_bottom --[[@as fa.Point]]
         local closest_x = util.clamp(px, left_top.x, right_bottom.x)
         local closest_y = util.clamp(py, left_top.y, right_bottom.y)

         local closest_dist = math.sqrt((px - closest_x) ^ 2 + (py - closest_y) ^ 2)
         if closest_dist > zoom_dist then
            emit_aggregate()
            return
         end

         -- We will get everything that is near the player, then check what is
         -- in the bounding box of the aggregated entity.
         local filter = {
            position = { x = px, y = py },
            radius = zoom_dist,
            name = d.prototype,
         }

         local ents = player.surface.find_entities_filtered(filter)

         local consumed_count = 0

         for _, e in pairs(ents) do
            if
               e.position.x >= cluster.aabb.left_top.x
               and e.position.x <= cluster.aabb.right_bottom.x
               and e.position.y >= cluster.aabb.left_top.y
               and e.position.y <= cluster.aabb.right_bottom.y
            then
               consumed_count = consumed_count + 1
               local ep = e.position --[[@as MapPosition.struct]]
               callback(self, ep.x, ep.y, RESOURCES, e.name, {
                  aabb = e.bounding_box,
                  highest_point = d.highest_point,
                  prototype = n,
                  initial_total_amount = d.initial_total_amount,
                  zoom_override = e,
               })
            end
         end

         -- To determine whether or not we are going to want to also include
         -- the aggregate, count the number of entities in the aggregate and
         -- compare.
         filter.area = cluster.aabb
         filter.radius = nil
         filter.position = nil

         local remaining_count = player.surface.count_entities_filtered(filter)

         if consumed_count < remaining_count then emit_aggregate() end
      end

      for _, cluster in ipairs(self:patches(n)) do
         emit(cluster)
      end
   end
end

function ResourcePatchesBackend:is_huge(data)
   return false
end

function ResourcePatchesBackend:get_aabb(data)
   local aabb = data.aabb
   local lt = aabb.left_top
   local rb = aabb.right_bottom
   return lt.x, lt.y, rb.x, rb.y
end

return mod
