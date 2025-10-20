--Here: functions about the warnings menu
local Viewpoint = require("scripts.viewpoint")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

--Warnings menu: scans for problems in the production network it defines and creates the warnings list.
function mod.scan_for_warnings(L, H, pindex)
   local surf = game.get_player(pindex).surface
   local pos = Viewpoint.get_viewpoint(pindex):get_cursor_pos()
   local area = { { pos.x - L, pos.y - H }, { pos.x + L, pos.y + H } }
   local ents = surf.find_entities_filtered({ area = area, type = entity_types })
   local warnings = {}
   warnings["noFuel"] = {}
   warnings["noRecipe"] = {}
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
   local result = {}
   local summary_message = MessageBuilder.new()
   local has_warnings = false

   for i, warning in pairs(warnings) do
      if #warning > 0 then
         has_warnings = true
         summary_message:list_item({ "fa.warning-type-" .. i })
         summary_message:fragment(tostring(#warning))
         table.insert(result, { name = i, ents = warning })
      end
   end

   local summary = summary_message:build()
   if not has_warnings then summary = { "fa.warnings-no-warnings-displayed" } end

   return { summary = summary, warnings = result }
end

return mod
