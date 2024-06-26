--Here: Quickbar related functions
local fa_localising = require("scripts.localising")

local mod = {}

---@param event EventData.CustomInputEvent
function mod.quickbar_get_handler(event)
   pindex = event.player_index
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
   pindex = event.player_index
   if not check_for_player(pindex) then return end
   if
      players[pindex].menu == "inventory"
      or players[pindex].menu == "none"
      or (players[pindex].menu == "building" or players[pindex].menu == "vehicle")
   then
      local num = tonumber(string.sub(event.input_name, -1))
      if num == 0 then num = 10 end
      mod.set_quick_bar_slot(num, pindex)
   end
end

--all 10 quickbar page setting event handlers
---@param event EventData.CustomInputEvent
function mod.quickbar_page_handler(event)
   pindex = event.player_index
   if not check_for_player(pindex) then return end

   local num = tonumber(string.sub(event.input_name, -1))
   if num == 0 then num = 10 end
   mod.read_switched_quick_bar(num, pindex)
end

function mod.read_quick_bar_slot(index, pindex)
   page = game.get_player(pindex).get_active_quick_bar_page(1) - 1
   local item = game.get_player(pindex).get_quick_bar_slot(index + 10 * page)
   if item ~= nil then
      local count = game.get_player(pindex).get_main_inventory().get_item_count(item.name)
      local stack = game.get_player(pindex).cursor_stack
      if stack and stack.valid_for_read then
         count = count + stack.count
         printout("unselected " .. fa_localising.get(item, pindex) .. " x " .. count, pindex)
      else
         printout("selected " .. fa_localising.get(item, pindex) .. " x " .. count, pindex)
      end
   else
      printout("Empty quickbar slot", pindex) --does this print, maybe not working because it is linked to the game control?
   end
end

function mod.set_quick_bar_slot(index, pindex)
   local p = game.get_player(pindex)
   local page = game.get_player(pindex).get_active_quick_bar_page(1) - 1
   local stack_cur = game.get_player(pindex).cursor_stack
   local stack_inv = players[pindex].inventory.lua_inventory[players[pindex].inventory.index]
   local ent = p.selected
   if stack_cur and stack_cur.valid_for_read and stack_cur.valid == true then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, stack_cur)
      printout("Quickbar assigned " .. index .. " " .. fa_localising.get(stack_cur, pindex), pindex)
   elseif
      players[pindex].menu == "inventory"
      and stack_inv
      and stack_inv.valid_for_read
      and stack_inv.valid == true
   then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, stack_inv)
      printout("Quickbar assigned " .. index .. " " .. fa_localising.get(stack_inv, pindex), pindex)
   elseif ent ~= nil and ent.valid and ent.force == p.force and game.item_prototypes[ent.name] ~= nil then
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, ent.name)
      printout("Quickbar assigned " .. index .. " " .. fa_localising.get(ent, pindex), pindex)
   else
      --Clear the slot
      local item = game.get_player(pindex).get_quick_bar_slot(index + 10 * page)
      local item_name = ""
      if item ~= nil then item_name = fa_localising.get(item, pindex) end
      ---@diagnostic disable-next-line: param-type-mismatch
      game.get_player(pindex).set_quick_bar_slot(index + 10 * page, nil)
      printout("Quickbar unassigned " .. index .. " " .. item_name, pindex)
   end
end

function mod.read_switched_quick_bar(index, pindex)
   page = game.get_player(pindex).get_active_quick_bar_page(index)
   local item = game.get_player(pindex).get_quick_bar_slot(1 + 10 * (index - 1))
   local item_name = "empty slot"
   if item ~= nil then item_name = fa_localising.get(item, pindex) end
   local result = "Quickbar " .. index .. " selected starting with " .. item_name
   printout(result, pindex)
end

return mod
