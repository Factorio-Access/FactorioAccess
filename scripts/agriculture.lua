--[[
Agricultural towers.

A tower sits in the middle of a square grid of sectors (agricultural_tower_radius sectors each way, each
growth_grid_tile_size tiles across) and plants one seed in the middle of each sector it can. A sector takes a seed
when every tile in it is one of the tiles the seed's plant lists in its autoplace tile_restriction (the game draws
the tower's sector colours from the same list), the plant's surface conditions hold, and nothing but plants stands
in it: any other entity or ghost blocks it. Plants do not block, since the tower harvests them.
]]
local SurfaceConditions = require("scripts.surface-conditions")

local mod = {}

---@class fa.Agriculture.Plant
---@field prototype LuaEntityPrototype
---@field tiles string[]

---Per tower prototype name, the plants its seeds grow into.
---@type { [string]: fa.Agriculture.Plant[]? }
local plants_by_tower = {}

---@param tower_prototype LuaEntityPrototype
---@return fa.Agriculture.Plant[]
local function tower_plants(tower_prototype)
   local cached = plants_by_tower[tower_prototype.name]
   if cached then return cached end

   ---@type LuaItemPrototype[]
   local seeds = {}
   if tower_prototype.accepted_seeds then
      for _, name in ipairs(tower_prototype.accepted_seeds) do
         table.insert(seeds, prototypes.item[name])
      end
   else
      for _, item in pairs(prototypes.item) do
         table.insert(seeds, item)
      end
   end

   ---@type fa.Agriculture.Plant[]
   local plants = {}
   for _, seed in ipairs(seeds) do
      local plant = seed.plant_result
      if plant then
         local tiles = {}
         local autoplace = plant.autoplace_specification
         for _, restriction in ipairs(autoplace and autoplace.tile_restriction or {}) do
            if restriction.first and not restriction.second then table.insert(tiles, restriction.first) end
         end
         table.insert(plants, { prototype = plant, tiles = tiles })
      end
   end
   plants_by_tower[tower_prototype.name] = plants
   return plants
end

---How many of the tower's sectors could take a seed right now, and how many sectors it has.
---@param tower_prototype LuaEntityPrototype
---@param surface LuaSurface
---@param center MapPosition.struct The tower's centre
---@return integer plantable
---@return integer total
function mod.count_plantable_sectors(tower_prototype, surface, center)
   ---@type fa.Agriculture.Plant[]
   local plants = {}
   for _, plant in ipairs(tower_plants(tower_prototype)) do
      if not SurfaceConditions.failed_condition(plant.prototype, surface) then table.insert(plants, plant) end
   end

   local radius = assert(tower_prototype.agricultural_tower_radius)
   local size = assert(tower_prototype.growth_grid_tile_size)
   local half = size / 2
   local plantable, total = 0, 0
   for i = -radius, radius do
      for j = -radius, radius do
         if i ~= 0 or j ~= 0 then
            total = total + 1
            local x, y = center.x + i * size, center.y + j * size
            local area = { { x - half, y - half }, { x + half, y + half } }
            local fits = false
            for _, plant in ipairs(plants) do
               -- A plant without a tile restriction grows on any tile.
               local name = next(plant.tiles) and plant.tiles or nil
               if surface.count_tiles_filtered({ area = area, name = name }) == size * size then
                  fits = true
                  break
               end
            end
            if
               fits
               and surface.count_entities_filtered({ area = area, type = { "plant", "character" }, invert = true })
                  == 0
            then
               plantable = plantable + 1
            end
         end
      end
   end
   return plantable, total
end

---Plants the tower owns and how many of them are fully grown.
---@param tower LuaEntity
---@return integer plants
---@return integer grown
function mod.plant_counts(tower)
   local plants = tower.owned_plants
   local grown = 0
   for _, plant in ipairs(plants) do
      if plant.tick_grown <= game.tick then grown = grown + 1 end
   end
   return #plants, grown
end

return mod
