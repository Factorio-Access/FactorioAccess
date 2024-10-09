--[[
We have to declare categorization and subcategorization functions for everything
by declaring our backends.  Simple already does everything else for us.
]]
local decl = require("scripts.scanner.backends.simple").declare_simple_backend
local functionize = require("scripts.functools").functionize
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
      return cat2(ent.type, rn)
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

-- There are so many logistics items that we will make one generic backend and
-- list them off in the LUT instead (inserters, transport belts, splitters, so
-- on).
mod.Logistics = decl_bound_category("fa.scanner.backends.Logistics", SC.CATEGORIES.LOGISTICS)
mod.Production = decl_bound_category("fa.scanner.backends.Production", SC.CATEGORIES.PRODUCTION)
mod.Military = decl_bound_category("fa.scanner.backends.Military", SC.CATEGORIES.MILITARY)
mod.Other = decl_bound_category("fa.scanner.backends.Other", SC.CATEGORIES.OTHER)
mod.Remnants = decl_bound_category("fa.scanner.backends.Remnants", SC.CATEGORIES.REMNANTS)
mod.Containers = decl_bound_category("fa.scanner.backends.Containers", SC.CATEGORIES.CONTAINERS)
mod.Corpses = decl_bound_category("fa.scanner.backends.Corpses", SC.CATEGORIES.CORPSES)
-- For rocks.
mod.Rock = decl_bound_category("fa.scanner.backends.ResourceSingle", SC.CATEGORIES.RESOURCES)

return mod
