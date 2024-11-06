--[[
We have to declare categorization and subcategorization functions for everything
by declaring our backends.  Simple already does everything else for us.
]]
local BuildingTools = require("scripts.building-tools")
local decl = require("scripts.scanner.backends.simple").declare_simple_backend
local functionize = require("scripts.functools").functionize
local Info = require("scripts.fa-info")
local ResourceMining = require("scripts.resource-mining")
local SC = require("scripts.scanner.scanner-consts")

local mod = {}

-- For things such as crafting machines, trains, etc. the category is
-- 'prototype/recipe', 'prototype/train-name', etc.
function cat2(c1, c2)
   return string.format("%s/%s", c1, c2)
end

-- Quickly declare backends where it's just fixing the category to something not
-- default.
local function decl_bound_category(metaname, category)
   return decl(metaname, {
      category_callback = functionize(category),
   })
end

mod.CraftingMachine = decl("fa.scanner.backends.CraftingMachine", {
   category_callback = functionize(SC.CATEGORIES.PRODUCTION),
   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      local r = ent.get_recipe()
      local rn = r and r.name or "<UNCONFIGURED>"
      return cat2(ent.name, rn)
   end,
})

mod.MiningDrill = decl("fa.scanner.backends.MiningDrill", {
   category_callback = functionize(SC.CATEGORIES.PRODUCTION),
   subcategory_callback = function(ent)
      local under_drill = ResourceMining.compute_resources_under_drill(ent)
      local keys = {}
      for k in pairs(under_drill) do
         table.insert(keys, k)
      end
      table.sort(keys)
      local key_part = table.concat(keys, "/")
      return cat2(ent.name, key_part)
   end,
})

mod.Furnace = decl("fa.scanner.backends.Furnace", {
   category_callback = functionize(SC.CATEGORIES.PRODUCTION),
   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      local recipe = ent.get_recipe()
      local rname = recipe and recipe.name or nil

      local oi = ent.get_output_inventory()
      if not rname and #oi > 0 and oi[1].valid_for_read then rname = oi[1].name end
      return cat2(ent.name, rname or "<UNCONFIGURED>")
   end,
})

mod.Vehicle = decl_bound_category("fa.scanner.backends.Vehicle", SC.CATEGORIES.VEHICLES)

-- rail, curved-rail, signals are all "boring". Stops and cars are more
-- complicated.
mod.TrainsSimple = decl_bound_category("fa.scanner.backends.TrainsSimple", SC.CATEGORIES.TRAINS)

-- For trains, we group by the train id only, so that the scanner isn't super
-- cluttered with random train cars.  In the future, we probably want a custom
-- backend.
mod.TrainsNamed = decl("fa.scanner.backends.TrainsNamed", {
   category_callback = functionize(SC.CATEGORIES.TRAINS),
   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      return cat2("train", tostring(ent.train.id))
   end,
})

mod.Ghosts = decl("fa.scanner.backends.Ghosts", {
   category_callback = functionize(SC.CATEGORIES.GHOSTS),
   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      return ent.ghost_type
   end,
})

mod.Character = decl_bound_category("fa.scanner.backends.Character", SC.CATEGORIES.PLAYERS)

-- Unit are enemies in vanilla.
mod.Unit = decl_bound_category("fa.scanner.backends.Unit", SC.CATEGORIES.ENEMIES)

-- Spawners need to be grouped by pollution. Buckets copied from old scanner.
local SPAWNER_POLLUTION_BUCKETS = {
   { 0, { "fa.scanner-spawner-polluted-none" } },
   { 1, { "fa.scanner-spawner-polluted-lightly" } },
   { 99, { "fa.scanner-spawner-polluted-heavily" } },
}

mod.Spawner = decl("fa.scanner.backends.Spawner", {
   category_callback = functionize(SC.CATEGORIES.ENEMIES),

   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      local level = 0
      local p = ent.absorbed_pollution
      for i = 1, #SPAWNER_POLLUTION_BUCKETS do
         if SPAWNER_POLLUTION_BUCKETS[i][1] <= p then
            level = i
         else
            break
         end
      end

      return cat2(ent.name, tostring(level))
   end,

   ---@param ent LuaEntity
   readout_callback = function(player, ent)
      local result = SPAWNER_POLLUTION_BUCKETS[1][2]
      local p = ent.absorbed_pollution
      for i = 1, #SPAWNER_POLLUTION_BUCKETS do
         if SPAWNER_POLLUTION_BUCKETS[i][1] <= p then
            result = SPAWNER_POLLUTION_BUCKETS[i][2]
         else
            break
         end
      end

      local info_string = Info.ent_info(player.index, ent, true)
      return { "fa.scanner-spawner-announce", info_string, result }
   end,
})

-- There are so many logistics items that we will make one generic backend and
-- list them off in the LUT instead (inserters, transport belts, splitters, so
-- on).
mod.LogisticsAndPower = decl_bound_category("fa.scanner.backends.LogisticsAndPower", SC.CATEGORIES.LOGISTICSAndPower)
mod.Production = decl_bound_category("fa.scanner.backends.Production", SC.CATEGORIES.PRODUCTION)
mod.Military = decl_bound_category("fa.scanner.backends.Military", SC.CATEGORIES.MILITARY)
mod.Other = decl_bound_category("fa.scanner.backends.Other", SC.CATEGORIES.OTHER)
mod.Remnants = decl_bound_category("fa.scanner.backends.Remnants", SC.CATEGORIES.REMNANTS)

mod.Containers = decl("fa.scanner.backends.Containers", {
   category_callback = functionize(SC.CATEGORIES.CONTAINERS),
   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      local itemset = ent.get_inventory(defines.inventory.chest).get_contents()
      local subcat
      -- This is a set not an array, and we care if it has 0, 1, or multiple
      -- items. To do that, pull out the first two keys.
      local key1 = next(itemset)
      local key2 = next(itemset, key1)
      local subcat
      if key1 and not key2 then
         subcat = key1
      elseif not key1 then
         subcat = "<EMPTY>"
      else
         subcat = "<MIXED>"
      end
      return cat2(ent.name, subcat)
   end,
})

mod.Corpses = decl_bound_category("fa.scanner.backends.Corpses", SC.CATEGORIES.CORPSES)

-- For rocks.
mod.Rock = decl_bound_category("fa.scanner.backends.ResourceSingle", SC.CATEGORIES.RESOURCES)

-- When used on something with a fluidbox, group by the contained fluid.  In the
-- rare case of multiple fluids, will group by one arbitrarily, not necessarily
-- the same one each time.
mod.LogisticsWithFluid = decl("fa.scanner.backends.LogisticsWithFluid", {
   category_callback = functionize(SC.CATEGORIES.LOGISTICSAndPower),

   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      local fluids = ent.get_fluid_contents()
      local fluid_name = next(fluids) or "<NONE>"
      return cat2(ent.name, fluid_name)
   end,
})

-- Roboports are categorized by network name.
mod.Roboport = decl("fa.scanner.backends.Roboport", {
   category_callback = functionize(SC.CATEGORIES.LOGISTICSAndPower),

   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      return cat2(ent.name, ent.backer_name)
   end,
})

mod.Pipe = decl("fa.scanner.backends.Pipe", {
   category_callback = functionize(SC.CATEGORIES.LOGISTICSAndPower),

   ---@param ent LuaEntity
   subcategory_callback = function(ent)
      local fluids = ent.get_fluid_contents()
      local fluid = next(fluids) or "<NONE>"
      local end_part = BuildingTools.is_a_pipe_end(ent) and "<END>" or "<NONE>"
      return string.format("%s/%s/%s", ent.name, fluid, end_part)
   end,
})
return mod
