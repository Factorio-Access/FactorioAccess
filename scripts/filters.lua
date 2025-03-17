--[[
Item and inventory filters.

Right now this file just contains a shim to get filters off stuff as a string so
that we can shove in calls for the 1.1-ish parts of the API to get things off
the ground, and some other utilities to hack things into working.  This is worth
a module because it will later need to deal with quality, and also localisation
of filters.
]]
local TH = require("scripts.table-helpers")

local mod = {}

---@alias fa.Filters.Filterlike LuaEntity | LuaInventory

---@param filterable fa.Filters.Filterlike
---@param index number
---@return string?
function mod.get_filter_prototype(filterable, index)
   print(serpent.line(filterable))
   local filter = filterable.get_filter(index)
   if filter then
      return filter.name --[[@as string]]
   end
   return nil
end

-- cannot be used on inventories, because in inventories the filter indices are
-- inventory slot indices, not a list of filters.
---@param ent LuaEntity
---@return  LuaItemPrototype[]
function mod.get_all_filters(ent)
   local ret = {}

   for i = 1, ent.filter_slot_count do
      TH.insert_if_notnill(ret, mod.get_filter_prototype(ent, i))
   end

   return ret
end

---@param filterable fa.Filters.Filterlike
---@param index number
---@param filter ItemFilter?
function mod.set_filter(filterable, index, filter)
   filterable.set_filter(index, filter)
   if filterable.object_name ~= "LuaEntity" then return end

   -- For entities we have to work out when to set use_filters.

   -- Easy case: it is using a filter because this just set one.
   if filter then
      filterable.use_filters = true
      return
   end

   -- Otherwise check all of them; if we find one turn it on; if we don't turn
   -- it off.
   for i = 1, filterable.filter_slot_count do
      if filterable.get_filter(i) then
         filterable.use_filters = true
         return
      end
   end

   filterable.use_filters = false
end

return mod
