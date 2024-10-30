--Here: functions about the warnings menu
local fa_belts = require("scripts.transport-belts")

local mod = {}

--Reads out a selected warning from the menu.
function mod.read_warnings_slot(pindex)
   local warnings = {}
   if players[pindex].warnings.sector == 1 then
      warnings = players[pindex].warnings.short.warnings
   elseif players[pindex].warnings.sector == 2 then
      warnings = players[pindex].warnings.medium.warnings
   elseif players[pindex].warnings.sector == 3 then
      warnings = players[pindex].warnings.long.warnings
   end
   if
      players[pindex].warnings.category <= #warnings
      and players[pindex].warnings.index <= #warnings[players[pindex].warnings.category].ents
   then
      local ent = warnings[players[pindex].warnings.category].ents[players[pindex].warnings.index]
      if ent ~= nil and ent.valid then
         printout(
            ent.name
               .. " has "
               .. warnings[players[pindex].warnings.category].name
               .. " at "
               .. math.floor(ent.position.x)
               .. ", "
               .. math.floor(ent.position.y),
            pindex
         )
      else
         printout("Blank", pindex)
      end
   else
      printout("No warnings for this range.  Press tab to pick a larger range, or press E to close this menu.", pindex)
   end
end

--Warnings menu: scans for problems in the production network it defines and creates the warnings list.
function mod.scan_for_warnings(L, H, pindex)
   local surf = game.get_player(pindex).surface
   local pos = players[pindex].cursor_pos
   local area = { { pos.x - L, pos.y - H }, { pos.x + L, pos.y + H } }
   local ents = surf.find_entities_filtered({ area = area, type = entity_types })
   local warnings = {}
   warnings["noFuel"] = {}
   warnings["noRecipe"] = {}
   warnings["noInserters"] = {}
   warnings["noPower"] = {}
   warnings["notConnected"] = {}
   for i, ent in pairs(ents) do
      if ent.prototype.burner_prototype ~= nil then
         local fuel_inv = ent.get_fuel_inventory()
         if ent.energy == 0 and (fuel_inv == nil or (fuel_inv and fuel_inv.valid and fuel_inv.is_empty())) then
            table.insert(warnings["noFuel"], ent)
         end
      end

      if ent.prototype.electric_energy_source_prototype ~= nil and ent.is_connected_to_electric_network() == false then
         table.insert(warnings["notConnected"], ent)
      elseif ent.prototype.electric_energy_source_prototype ~= nil and ent.energy == 0 then
         table.insert(warnings["noPower"], ent)
      end
      local recipe = nil
      if pcall(function()
         recipe = ent.get_recipe()
      end) then
         if recipe == nil and ent.type ~= "furnace" then table.insert(warnings["noRecipe"], ent) end
      end
   end
   local str = ""
   local result = {}
   for i, warning in pairs(warnings) do
      if #warning > 0 then
         str = str .. i .. " " .. #warning .. ", "
         table.insert(result, { name = i, ents = warning })
      end
   end
   if str == "" then str = "No warnings displayed    " end
   str = string.sub(str, 1, -3)
   return { summary = str, warnings = result }
end

return mod
