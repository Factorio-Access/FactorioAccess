--- Spidertron remote control functionality
local mod = {}

local EntitySelection = require("scripts.entity-selection")
local FaInfo = require("scripts.fa-info")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local Viewpoint = require("scripts.viewpoint")

---Check if a spidertron is in the list
---@param list LuaEntity[]
---@param unit_number integer
---@return boolean
local function is_spidertron_in_list(list, unit_number)
   for _, spider in ipairs(list) do
      if spider.unit_number == unit_number then return true end
   end
   return false
end

---Check if a spidertron is in the player's remote (public API)
---@param player LuaPlayer
---@param unit_number integer
---@return boolean
function mod.is_spidertron_in_remote(player, unit_number)
   local current_list = player.spidertron_remote_selection or {}
   return is_spidertron_in_list(current_list, unit_number)
end

---Toggle a spidertron on the remote (add if not present, remove if present)
---@param player LuaPlayer
---@param spidertron LuaEntity
function mod.toggle_spidertron(player, spidertron)
   local current_list = player.spidertron_remote_selection or {}

   if is_spidertron_in_list(current_list, spidertron.unit_number) then
      mod.remove_spider(player, spidertron.unit_number)
   else
      mod.add_to_remote(player, spidertron)
   end
end

---Add a spidertron to the remote
---@param player LuaPlayer
---@param spidertron LuaEntity
function mod.add_to_remote(player, spidertron)
   local current_list = player.spidertron_remote_selection or {}

   -- Check surface compatibility
   if #current_list > 0 and current_list[1].surface_index ~= spidertron.surface_index then
      Speech.speak(player.index, { "fa.spidertron-remote-different-surface" })
      return
   end

   -- Check if already added
   if is_spidertron_in_list(current_list, spidertron.unit_number) then
      Speech.speak(player.index, { "fa.spidertron-already-linked" })
      return
   end

   -- Add to list
   table.insert(current_list, spidertron)
   player.spidertron_remote_selection = current_list

   local mb = MessageBuilder.new()
   mb:fragment({ "fa.spidertron-remote-added" })
   mb:fragment(FaInfo.ent_info(player.index, spidertron, true))
   Speech.speak(player.index, mb:build())
end

---Clear all spidertrons from the remote
---@param player LuaPlayer
function mod.clear_remote(player)
   local current_list = player.spidertron_remote_selection or {}
   if #current_list == 0 then
      Speech.speak(player.index, { "fa.spidertron-remote-already-empty" })
      return
   end

   player.spidertron_remote_selection = {}
   Speech.speak(player.index, { "fa.spidertron-remote-cleared" })
end

---Remove a specific spidertron from the remote
---@param player LuaPlayer
---@param unit_number integer
function mod.remove_spider(player, unit_number)
   local current_list = player.spidertron_remote_selection or {}

   if not is_spidertron_in_list(current_list, unit_number) then
      Speech.speak(player.index, { "fa.spidertron-remote-not-in-list" })
      return
   end

   -- Remove the spidertron
   for i = #current_list, 1, -1 do
      if current_list[i].unit_number == unit_number then
         table.remove(current_list, i)
         break
      end
   end

   player.spidertron_remote_selection = current_list
   Speech.speak(player.index, { "fa.spidertron-remote-removed" })
end

---Add a position to the autopilot queue for all spidertrons on the remote
---@param player LuaPlayer
---@param position MapPosition
---@param clear_first boolean
function mod.add_to_autopilot(player, position, clear_first)
   local current_list = player.spidertron_remote_selection or {}
   if #current_list == 0 then
      Speech.speak(player.index, { "fa.spidertron-remote-empty" })
      return
   end

   for _, spider in ipairs(current_list) do
      if clear_first then spider.autopilot_destination = nil end
      spider.add_autopilot_destination(position)
   end

   if #current_list == 1 then
      local key = clear_first and "fa.spidertron-remote-autopilot-replaced-singular"
         or "fa.spidertron-remote-autopilot-set-singular"
      Speech.speak(player.index, { key })
   else
      local key = clear_first and "fa.spidertron-remote-autopilot-replaced-plural"
         or "fa.spidertron-remote-autopilot-set-plural"
      Speech.speak(player.index, { key, #current_list })
   end
end

---Clear autopilot for all spidertrons on the remote
---@param player LuaPlayer
function mod.clear_autopilot(player)
   local current_list = player.spidertron_remote_selection or {}
   if #current_list == 0 then
      Speech.speak(player.index, { "fa.spidertron-remote-empty" })
      return
   end

   for _, spider in ipairs(current_list) do
      spider.autopilot_destination = nil
   end

   Speech.speak(player.index, { "fa.spidertron-remote-autopilot-cleared" })
end

---Cycle through spidertrons on the remote
---@param player LuaPlayer
---@param direction integer 1 for forward, -1 for backward
function mod.cycle_spidertrons(player, direction)
   local pindex = player.index
   local current_list = player.spidertron_remote_selection or {}
   if #current_list == 0 then
      Speech.speak(pindex, { "fa.spidertron-remote-empty" })
      return
   end

   local vp = Viewpoint.get_viewpoint(pindex)
   local cursor_pos = vp:get_cursor_pos()

   -- Find current spidertron at cursor position
   local current_spider = EntitySelection.get_first_ent_at_tile(pindex)
   local current_index = nil

   if current_spider and current_spider.type == "spider-vehicle" then
      local current_unit = current_spider.unit_number
      for i, spider in ipairs(current_list) do
         if spider.unit_number == current_unit then
            current_index = i
            break
         end
      end
   end

   -- Calculate next index
   local next_index
   if current_index then
      next_index = current_index + direction
      if next_index > #current_list then
         next_index = 1
      elseif next_index < 1 then
         next_index = #current_list
      end
   else
      next_index = 1
   end

   local next_spider = current_list[next_index]
   local next_pos = next_spider.position
   ---@cast next_pos fa.Point

   -- Update cursor position (caller should read tile)
   vp:set_cursor_pos(next_pos)
end

return mod
