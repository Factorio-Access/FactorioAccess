---Rail Announcer
---
---Builds user-facing messages from rail descriptions.
---Works with railutils/rail-describer.lua and locale/en/rail-announcer.cfg
---
---This module takes RailDescription objects from the railutils describer and converts
---them into localized messages using MessageBuilder.

local SignalStationClassifier = require("scripts.rails.signal-station-classifier")
local StopPreview = require("scripts.rails.stop-preview")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---Build announcement for signal/station info
---@param info fa.rails.SignalStationInfo Signal and station info
---@return LocalisedString? Message fragment or nil if nothing to announce
local function build_signal_station_announcement(info)
   if not info then return nil end

   local message = MessageBuilder.new()
   local dir = { "fa.direction", info.direction }

   -- Determine signal configuration
   local left = info.left
   local right = info.right

   if left and right then
      -- Pair case
      if left == right then
         -- Same type on both sides
         if left == "signal" then
            message:fragment({ "fa.rail-signal-pair", dir })
         else
            message:fragment({ "fa.rail-chain-pair", dir })
         end
      else
         -- Mixed pair - say which side is chained
         if left == "chain" then
            message:fragment({ "fa.rail-pair-chained-left", dir })
         else
            message:fragment({ "fa.rail-pair-chained-right", dir })
         end
      end
   elseif right then
      -- Only right side (out signal)
      if right == "signal" then
         message:fragment({ "fa.rail-signal-out", dir })
      else
         message:fragment({ "fa.rail-chain-out", dir })
      end
   elseif left then
      -- Only left side (in signal)
      if left == "signal" then
         message:fragment({ "fa.rail-signal-in", dir })
      else
         message:fragment({ "fa.rail-chain-in", dir })
      end
   end

   -- Add station
   if info.station then message:list_item({ "fa.rail-at-station" }) end

   return message:build()
end

---Build announcement message for a rail
---@param description railutils.RailDescription Rail description from describer
---@param opts { prefix_rail: boolean?, is_ghost: boolean?, rail_entity: LuaEntity?, cursor_pos: MapPosition? }? Options
---@return LocalisedString Message ready for speech
function mod.announce_rail(description, opts)
   opts = opts or {}
   local prefix_rail = opts.prefix_rail
   local is_ghost = opts.is_ghost or false
   local rail_entity = opts.rail_entity
   if prefix_rail == nil then prefix_rail = true end

   local message = MessageBuilder.new()

   -- Add "ghost" prefix if this is a ghost rail
   if is_ghost then message:fragment({ "fa.rail-ghost-prefix" }) end

   -- Add "rail" prefix if requested
   if prefix_rail then message:fragment("rail") end

   -- Main rail kind
   message:fragment({ "fa.rails-descriptions-" .. description.kind })

   -- Add lonely modifier or disconnected end (not both - lonely means all ends disconnected)
   if description.lonely then
      message:fragment({ "fa.rail-lonely" })
   elseif description.end_direction then
      -- Only announce disconnected end if not lonely
      message:fragment({ "fa.rail-end-direction", { "fa.direction", description.end_direction } })
   end

   -- Add junctions (splits and forks)
   if #description.junctions > 0 then
      for _, junction in ipairs(description.junctions) do
         -- Junction kind is one of: split, fork-left, fork-right, fork-both
         local junction_desc = { "fa.rail-junction-" .. junction.kind, { "fa.direction", junction.direction } }

         message:list_item(junction_desc)
      end
   end

   -- Add signal/station info if rail entity provided (not for ghosts)
   if rail_entity and not is_ghost then
      local signal_info = SignalStationClassifier.get_signal_station_info(rail_entity)
      local signal_announcement = build_signal_station_announcement(signal_info)
      if signal_announcement then message:list_item(signal_announcement) end

      -- Add stop preview (shows where train cars would be)
      if opts.cursor_pos then
         local stop_preview = StopPreview.get_stop_preview(rail_entity, opts.cursor_pos)
         if stop_preview then message:list_item(stop_preview) end
      end
   end

   return message:build()
end

return mod
