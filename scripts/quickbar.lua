--Here: Quickbar related functions
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UiRouter = require("scripts.ui.router")

local mod = {}

---Describe what a quick bar slot holds. A slot can hold a plain item or item
---filter, a blueprint-library record, or a spidertron remote.
---@param slot QuickBarSlot?
---@return LocalisedString? description Localised name of the content, nil if empty
---@return string? item_name Plain item name for an inventory count, nil if not a counted item
local function describe_quick_bar_slot(slot)
   if not slot then return nil end
   if slot.type == "item" and slot.item then
      local name = slot.item.name
      return Localising.get_localised_name_with_fallback(prototypes.item[name]), name
   elseif slot.type == "filter" and slot.filter then
      -- Filters read from the game name their item by string.
      local name = (type(slot.filter) == "string" and slot.filter or slot.filter.name) --[[@as string]]
      return Localising.get_localised_name_with_fallback(prototypes.item[name]), name
   elseif slot.type == "record" and slot.record then
      local record = slot.record
      if record.label and record.label ~= "" then return record.label end
      return Localising.get_localised_name_with_fallback(prototypes.item[record.type])
   elseif slot.type == "remote" then
      return Localising.get_localised_name_with_fallback(prototypes.item["spidertron-remote"])
   end
   return nil
end

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
   local p = game.get_player(pindex)
   local page = p.get_active_quick_bar_page(1)
   local name, item_name = describe_quick_bar_slot(p.get_quick_bar_slot(page, index))
   if name == nil then
      Speech.speak(pindex, { "fa.quickbar-empty-slot" })
      return
   end

   local stack = p.cursor_stack
   local msg = MessageBuilder.new()
   msg:fragment(stack and stack.valid_for_read and { "fa.quickbar-unselected" } or { "fa.quickbar-selected" })
   msg:fragment(name)
   -- Only plain items have an inventory count to report.
   if item_name then
      local count = p.get_main_inventory().get_item_count(item_name)
      if stack and stack.valid_for_read then count = count + stack.count end
      msg:fragment({ "fa.quickbar-count", count })
   end
   Speech.speak(pindex, msg:build())
end

function mod.set_quick_bar_slot(index, pindex)
   local p = game.get_player(pindex)
   local router = UiRouter.get_router(pindex)
   local page = game.get_player(pindex).get_active_quick_bar_page(1)
   local stack_cur = game.get_player(pindex).cursor_stack
   local ent = p.selected
   if stack_cur and stack_cur.valid_for_read and stack_cur.valid == true then
      game.get_player(pindex).set_quick_bar_slot(page, index, stack_cur)
      local msg = MessageBuilder.new()
      msg:fragment({ "fa.quickbar-assigned", index })
      msg:fragment(Localising.get_localised_name_with_fallback(stack_cur))
      Speech.speak(pindex, msg:build())
   else
      --Clear the slot
      local item_desc = describe_quick_bar_slot(game.get_player(pindex).get_quick_bar_slot(page, index))
      game.get_player(pindex).set_quick_bar_slot(page, index, nil)
      local msg = MessageBuilder.new()
      msg:fragment({ "fa.quickbar-unassigned", index })
      if item_desc then msg:fragment(item_desc) end
      Speech.speak(pindex, msg:build())
   end
end

function mod.read_switched_quick_bar(index, pindex)
   local name = describe_quick_bar_slot(game.get_player(pindex).get_quick_bar_slot(index, 1))
   local msg = MessageBuilder.new()
   msg:fragment({ "fa.quickbar-page-selected", index })
   msg:fragment(name or { "fa.quickbar-empty-slot" })
   Speech.speak(pindex, msg:build())
end

return mod
