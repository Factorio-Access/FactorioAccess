--Here: Quickbar related functions
local Localising = require("scripts.localising")
local MessageBuilder = require("scripts.message-builder")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@param event EventData.CustomInputEvent
function mod.quickbar_get_handler(event)
   local pindex = event.player_index
   if not check_for_player(pindex) then return end
   if
      players[pindex].menu == "inventory"
      or players[pindex].menu == "none"
      or (players[pindex].menu == "building" or players[pindex].menu == "vehicle")
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
   local router = UiRouter.get_router(pindex)
   if
      router:is_ui_open(UiRouter.UI_NAMES.INVENTORY)
      or not router:is_ui_open()
      or router:is_ui_open(UiRouter.UI_NAMES.BUILDING)
      or router:is_ui_open(UiRouter.UI_NAMES.VEHICLE)
   then
      local num = tonumber(string.sub(event.input_name, -1))
      if num == 0 then num = 10 end
      mod.set_quick_bar_slot(num, pindex)
   end
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
         local msg = MessageBuilder.new()
         msg:fragment({ "fa.quickbar-unselected" })
         msg:fragment(Localising.get_localised_name_with_fallback(proto))
         msg:fragment({ "fa.quickbar-count", count })
         printout(msg:build(), pindex)
      else
         local msg = MessageBuilder.new()
         msg:fragment({ "fa.quickbar-selected" })
         msg:fragment(Localising.get_localised_name_with_fallback(proto))
         msg:fragment({ "fa.quickbar-count", count })
         printout(msg:build(), pindex)
      end
   else
      printout({ "fa.quickbar-empty-slot" }, pindex) --does this print, maybe not working because it is linked to the game control?
   end
end

function mod.set_quick_bar_slot(index, pindex)
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)
   local page = game.get_player(pindex).get_active_quick_bar_page(1) - 1
   local stack_cur = game.get_player(pindex).cursor_stack
   local stack_inv = players[pindex].inventory.lua_inventory[players[pindex].inventory.index]
   local ent = p.selected
   if stack_cur and stack_cur.valid_for_read and stack_cur.valid == true then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, stack_cur)
      local msg = MessageBuilder.new()
      msg:fragment({ "fa.quickbar-assigned", index })
      msg:fragment(Localising.get_localised_name_with_fallback(stack_cur))
      printout(msg:build(), pindex)
   elseif
      router:is_ui_open(UiRouter.UI_NAMES.INVENTORY)
      and stack_inv
      and stack_inv.valid_for_read
      and stack_inv.valid == true
   then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, stack_inv)
      local msg = MessageBuilder.new()
      msg:fragment({ "fa.quickbar-assigned", index })
      msg:fragment(Localising.get_localised_name_with_fallback(stack_inv))
      printout(msg:build(), pindex)
   elseif ent ~= nil and ent.valid and ent.force == p.force and prototypes.item[ent.name] ~= nil then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, ent.name)
      local msg = MessageBuilder.new()
      msg:fragment({ "fa.quickbar-assigned", index })
      msg:fragment(Localising.get_localised_name_with_fallback(ent))
      printout(msg:build(), pindex)
   else
      --Clear the slot
      local item = game.get_player(pindex).get_quick_bar_slot(index + 10 * page)
      local item_desc = nil
      if item ~= nil then item_desc = Localising.get_localised_name_with_fallback(item) end
      ---@diagnostic disable-next-line: param-type-mismatch
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, nil)
      local msg = MessageBuilder.new()
      msg:fragment({ "fa.quickbar-unassigned", index })
      if item_desc then msg:fragment(item_desc) end
      printout(msg:build(), pindex)
   end
end

function mod.read_switched_quick_bar(index, pindex)
   local page = game.get_player(pindex).get_active_quick_bar_page(index)
   local item = game.get_player(pindex).get_quick_bar_slot(1 + 10 * (index - 1))
   local msg = MessageBuilder.new()
   msg:fragment({ "fa.quickbar-page-selected", index })
   if item ~= nil then
      msg:fragment(Localising.get_localised_name_with_fallback(prototypes.item[item.name]))
   else
      msg:fragment({ "fa.quickbar-empty-slot" })
   end
   printout(msg:build(), pindex)
end

return mod
