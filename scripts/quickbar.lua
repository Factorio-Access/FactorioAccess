--Here: Quickbar related functions
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@param event EventData.CustomInputEvent
function mod.quickbar_get_handler(event)
   local pindex = event.player_index
   if not check_for_player(pindex) then return end
   if
      storage.players[pindex].menu == "inventory"
      or storage.players[pindex].menu == "none"
      or (storage.players[pindex].menu == "building" or storage.players[pindex].menu == "vehicle")
   then
      local num = tonumber(string.sub(event.input_name, -1))
      if num == 0 then num = 10 end
      mod.read_quick_bar_slot(num, pindex)
   end
end

--all 10 quickbar slot setting event handlers
---@param event EventData.CustomInputEvent
function mod.quickbar_set_handler(event)
   local pindex = event.player_index
   if not check_for_player(pindex) then return end
   -- [UI CHECKS REMOVED] Quickbar setting now available anytime
   local num = tonumber(string.sub(event.input_name, -1))
   if num == 0 then num = 10 end
   mod.set_quick_bar_slot(num, pindex)
end

--all 10 quickbar page setting event handlers
---@param event EventData.CustomInputEvent
function mod.quickbar_page_handler(event)
   local pindex = event.player_index
   if not check_for_player(pindex) then return end

   local num = tonumber(string.sub(event.input_name, -1))
   if num == 0 then num = 10 end
   mod.read_switched_quick_bar(num, pindex)
end

function mod.read_quick_bar_slot(index, pindex)
   local page = game.get_player(pindex).get_active_quick_bar_page(1) - 1
   local item = game.get_player(pindex).get_quick_bar_slot(index + 10 * page)
   if item ~= nil then
      local proto = prototypes.item[item.name]
      local count = game.get_player(pindex).get_main_inventory().get_item_count(item.name)
      local stack = game.get_player(pindex).cursor_stack
      if stack and stack.valid_for_read then
         count = count + stack.count
         local msg = Speech.new()
         msg:fragment({ "fa.quickbar-unselected" })
         msg:fragment(Localising.get_localised_name_with_fallback(proto))
         msg:fragment({ "fa.quickbar-count", count })
         Speech.speak(pindex, msg:build())
      else
         local msg = Speech.new()
         msg:fragment({ "fa.quickbar-selected" })
         msg:fragment(Localising.get_localised_name_with_fallback(proto))
         msg:fragment({ "fa.quickbar-count", count })
         Speech.speak(pindex, msg:build())
      end
   else
      Speech.speak(pindex, { "fa.quickbar-empty-slot" }) --does this print, maybe not working because it is linked to the game control?
   end
end

function mod.set_quick_bar_slot(index, pindex)
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)
   local page = game.get_player(pindex).get_active_quick_bar_page(1) - 1
   local stack_cur = game.get_player(pindex).cursor_stack
   local stack_inv = storage.players[pindex].inventory.lua_inventory[storage.players[pindex].inventory.index]
   local ent = p.selected
   if stack_cur and stack_cur.valid_for_read and stack_cur.valid == true then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, stack_cur)
      local msg = Speech.new()
      msg:fragment({ "fa.quickbar-assigned", index })
      msg:fragment(Localising.get_localised_name_with_fallback(stack_cur))
      Speech.speak(pindex, msg:build())
   elseif stack_inv and stack_inv.valid_for_read and stack_inv.valid == true then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, stack_inv)
      local msg = Speech.new()
      msg:fragment({ "fa.quickbar-assigned", index })
      msg:fragment(Localising.get_localised_name_with_fallback(stack_inv))
      Speech.speak(pindex, msg:build())
   elseif ent ~= nil and ent.valid and ent.force == p.force and prototypes.item[ent.name] ~= nil then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, ent.name)
      local msg = Speech.new()
      msg:fragment({ "fa.quickbar-assigned", index })
      msg:fragment(Localising.get_localised_name_with_fallback(ent))
      Speech.speak(pindex, msg:build())
   else
      --Clear the slot
      local item = game.get_player(pindex).get_quick_bar_slot(index + 10 * page)
      local item_desc = nil
      if item ~= nil then item_desc = Localising.get_localised_name_with_fallback(item) end
      ---@diagnostic disable-next-line: param-type-mismatch
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, nil)
      local msg = Speech.new()
      msg:fragment({ "fa.quickbar-unassigned", index })
      if item_desc then msg:fragment(item_desc) end
      Speech.speak(pindex, msg:build())
   end
end

function mod.read_switched_quick_bar(index, pindex)
   local page = game.get_player(pindex).get_active_quick_bar_page(index)
   local item = game.get_player(pindex).get_quick_bar_slot(1 + 10 * (index - 1))
   local msg = Speech.new()
   msg:fragment({ "fa.quickbar-page-selected", index })
   if item ~= nil then
      msg:fragment(Localising.get_localised_name_with_fallback(prototypes.item[item.name]))
   else
      msg:fragment({ "fa.quickbar-empty-slot" })
   end
   Speech.speak(pindex, msg:build())
end

return mod
