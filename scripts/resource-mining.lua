--[[
Mining drills and resource patches.

Sadly probably also recyclers which are "like a mining drill" in that they output stuff in the same way.
]]
local Consts = require("scripts.consts")
local FaUtils = require("scripts.fa-utils")

local mod = {}

---@alias fa.ResourceMining.OutputPoint { position: fa.Point, direction: defines.direction }

-- If this entity outputs without an inserter, get the coordinates on the entity
-- closest to where it would output, and the direction of that output.
---@param ent LuaEntity
---@return fa.ResourceMining.OutputPoint?
function mod.get_solid_output_coords(ent)
   if ent.type ~= "mining-drill" then return nil end

   local v2pr = ent.drop_position
   if not v2pr then return end

   -- This is how the game handles pumpjacks and other drills that don't output
   -- stuff.
   if v2pr.x == ent.position.x and v2pr.y == ent.position.y then return nil end
   v2pr = FaUtils.center_of_tile(v2pr)

   -- Get the closest point on the box. Then work out the direction of the point
   -- from that.  Then use the direction to move the point inside the entity, so
   -- that rounding will hit on a tile.
   local in_ent = FaUtils.center_of_tile(FaUtils.closest_point_in_box(v2pr, ent.bounding_box))

   local dir = FaUtils.direction_of_vector({ x = v2pr.x - in_ent.x, y = v2pr.y - in_ent.y })
   local flipped = FaUtils.rotate_180(dir)
   local uv = Consts.DIRECTION_VECTORS[flipped + 1]
   assert(uv)

   local effective = { x = v2pr.x + uv.x, y = v2pr.y + uv.y }
   effective = FaUtils.center_of_tile(effective)

   return { position = effective, direction = dir }
end

---@param ent LuaEntity
---@return table<string, number> The counts by resource prototype name
function mod.compute_resources_under_drill(ent)
   local pos = ent.position
   local radius = ent.prototype.mining_drill_radius
   local area = { { pos.x - radius, pos.y - radius }, { pos.x + radius, pos.y + radius } }
   local resources = ent.surface.find_entities_filtered({ area = area, type = "resource" })
   local dict = {}
   for i, resource in pairs(resources) do
      dict[resource.name] = (dict[resource.name] or 0) + resource.amount
   end

   return dict
end

return mod
