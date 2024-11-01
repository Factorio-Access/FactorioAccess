local Consts = require("scripts.consts")
local DataToRuntimeMap = require("scripts.data-to-runtime-map")
local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local Functools = require("scripts.functools")
local Clusterer = require("scripts.ds.clusterer")
local ScannerConsts = require("scripts.scanner.scanner-consts")
local TableHelpers = require("scripts.table-helpers")

local mod = {}

---@type function(): table<string, number>
local PROTOTYPE_SEARCH_RADIUSES = Functools.cached(function()
   local loaded = DataToRuntimeMap.load(Consts.RESOURCE_SEARCH_RADIUSES_MAP_NAME)
   local res = {}
   for k, v in pairs(loaded) do
      res[k] = tonumber(v)
   end
   return res
end)

---@class fa.scanner.ResourcePatch
---@field highest_point { x: number, y: number, entity: LuaEntity, amount: number }
---@field initial_total_amount number
---@field prototype string

---@class fa.scanner.ResourcePatchEntData: fa.scanner.ResourcePatch
---@field zoom_override LuaEntity?

---@class fa.scanner.ResourcePatchesBackend: fa.scanner.ScannerBackend
---@field clusterers table<string, fa.ds.Clusterer>
---@field known_patches table<string, table<any, true>>
local ResourcePatchesBackend = {}
local ResourcePatchesBackend_meta = { __index = ResourcePatchesBackend }
script.register_metatable("fa.scanner.ResourcePatches", ResourcePatchesBackend_meta)
mod.ResourcePatchesBackend = ResourcePatchesBackend

---@param a fa.scanner.ResourcePatch
---@param b fa.scanner.ResourcePatch
---@return fa.scanner.ResourcePatch
function fold_patches(a, b)
   local highest

   if a.highest_point.amount > b.highest_point.amount then
      highest = a.highest_point
   else
      highest = b.highest_point
   end

   return {
      highest_point = highest,
      initial_total_amount = a.initial_total_amount + b.initial_total_amount,

      prototype = a.prototype,
   }
end

local clusterer_fact = Clusterer.declare_clusterer("fa.scanner.ResourceClusterer", {
   fold = fold_patches,
})

---@param ent LuaEntity
---@return number
local function amount_for(ent)
   return ent.amount
end

-- Adjectives for forest by density, as an amount of wood.
local FOREST_DENSITIES = {
   { -math.huge, "fa.scanner-forest-empty" },
   { 10, "fa.scanner-forest-sparse" },
   { 50, "fa.scanner-forest-normal" },
   { 80, "fa.scanner-forest-dense" },
}

---@returns fa.scanner.ResourcePatchesBackend
function ResourcePatchesBackend.new()
   local ret = {
      known_patches = {},
      clusterers = {},
   }
   setmetatable(ret, ResourcePatchesBackend_meta)
   return ret
end

---@param proto string
---@return fa.ds.Clusterer
function ResourcePatchesBackend:get_clusterer_for(proto)
   local c = self.clusterers[proto]
   if c then return c end

   local proto_def = prototypes.entity[proto]

   -- The radius of the resource is only available on the raw prototype.  While
   -- it is the case that the resource search distance is optional, we're a mod
   -- trying to do this reasonably so we just pull a default out of the air.
   local search_radius = PROTOTYPE_SEARCH_RADIUSES()[proto]
   -- We are careful to default this when declaring the map, so not finding one
   -- is a bug; trees have long since been moved to their own clusterer.
   assert(search_radius)

   local nc = clusterer_fact(search_radius)

   self.clusterers[proto] = nc
   return nc
end

---@param new_entity LuaEntity
function ResourcePatchesBackend:on_new_entity(new_entity)
   local amount = amount_for(new_entity)

   self:get_clusterer_for(new_entity.name):insert(new_entity.position.x, new_entity.position.y, {
      highest_point = {
         x = new_entity.position.x,
         y = new_entity.position.y,
         amount = amount,
         entity = new_entity,
      },
      initial_total_amount = amount,

      prototype = new_entity.name,
   })
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

function ResourcePatchesBackend:update_entry(ent)
   -- Nothing to do.  Re-update happens on announcement.  Revalidation scans
   -- happen in validation.
end

---@param player LuaPlayer
---@param ent fa.scanner.ScanEntry
function ResourcePatchesBackend:readout_entry(player, ent)
   ---@type fa.scanner.ResourcePatchEntData
   local bd = ent.backend_data
   local pname = bd.prototype

   if bd.zoom_override then return FaInfo.ent_info(pindex, bd.zoom_override, true) end

   local ents

   ents = player.surface.find_entities_filtered({
      area = ent.backend_data.aabb,
      name = pname,
   })

   local total = 0
   for _, e in pairs(ents) do
      total = total + amount_for(e)
   end

   local total_str

   if prototypes.entity[pname].type == "resource" and prototypes.entity[pname].infinite_resource then
      local t = math.floor(total / prototypes.entity[pname].normal_resource_amount * 100)
      total_str = string.format("%i percent", t)
   else
      total_str = FaUtils.format_number(total)
   end

   local percent = math.floor(total / bd.initial_total_amount * 100)

   local pname = prototypes.entity[pname].localised_name

   local res = {
      "fa.scanner-resource-patch",
      pname,
      total_str,
      percent,
   }
   return res
end

---@param player LuaPlayer
---@param callback fun(fa.scanner.ScanEntry)
function ResourcePatchesBackend:dump_entries_to_callback(player, callback)
   local seen_clusterers = {}

   local px, py = player.position.x, player.position.y

   for n, c in pairs(self.clusterers) do
      if seen_clusterers[c] then goto continue end
      seen_clusterers[c] = true

      local is_infinite = prototypes.entity[n].infinite_resource

      local zoom_dist = nil

      if is_infinite then zoom_dist = ScannerConsts.INFINITE_RESOURCE_ZOOM_DISTANCE end

      c:get_clusters(function(cluster)
         ---@type fa.scanner.ResourcePatch
         local d = cluster.data

         ---@type fa.scanner.ScanEntry
         local ent_agg = {
            backend = self,
            category = ScannerConsts.CATEGORIES.RESOURCES,
            position = { x = d.highest_point.x, y = d.highest_point.y },
            subcategory = n,
            -- Required because this may get modified later as clusters fold
            -- into each other.
            backend_data = {
               aabb = cluster.aabb,
               highest_point = table.deepcopy(d.highest_point),
               -- Without the prototype, we can't do a query on the patch without
               -- having an original entity, which may no longer exist.
               prototype = n,
               initial_total_amount = d.initial_total_amount,

               -- When set this is a zoomed entry; announce with FaInfo instead.
               zoom_override = nil,
            },
         }

         if not zoom_dist then
            callback(ent_agg)
            return
         end

         -- Important shortcut.  If the cluster's aabb is further away than the
         -- player is, then we want  to avoid doing anything: surface scans
         --  hurt.
         local closest_x = util.clamp(px, cluster.aabb.left_top.x, cluster.aabb.right_bottom.x)
         local closest_y = util.clamp(py, cluster.aabb.left_top.y, cluster.aabb.right_bottom.y)

         local closest_dist = math.sqrt((px - closest_x) ^ 2 + (py - closest_y) ^ 2)
         if closest_dist > zoom_dist then
            callback(ent_agg)
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
               local ent = {
                  backend = self,
                  category = ScannerConsts.CATEGORIES.RESOURCES,
                  position = { x = e.position.x, y = e.position.y },
                  subcategory = e.name,
                  -- Required because this may get modified later as clusters fold
                  -- into each other.
                  backend_data = {
                     aabb = table.deepcopy(e.bounding_box),
                     highest_point = table.deepcopy(d.highest_point),
                     -- Without the prototype, we can't do a query on the patch without
                     -- having an original entity, which may no longer exist.
                     prototype = n,
                     initial_total_amount = d.initial_total_amount,
                     -- When set this is a zoomed entry; announce with FaInfo instead.
                     zoom_override = e,
                  },
               }

               callback(ent)
            end
         end

         -- To determine whether or not we are going to want to also include
         -- the aggregate, count the number of entities in the aggregate and
         -- compare.
         filter.area = cluster.aabb
         filter.radius = nil
         filter.position = nil

         local remaining_count = player.surface.count_entities_filtered(filter)

         if consumed_count < remaining_count then callback(ent_agg) end
      end)

      ::continue::
   end
end

function ResourcePatchesBackend:on_new_tiles(tiles) end

function ResourcePatchesBackend:is_huge(e)
   return false
end

function ResourcePatchesBackend:get_aabb(e)
   local aabb = e.backend_data.aabb
   local lt = aabb.left_top
   local rb = aabb.right_bottom
   return lt.x, lt.y, rb.x, rb.y
end

return mod
