---Rail Announcer
---
---Builds user-facing messages from rail descriptions.
---Works with railutils/rail-describer.lua and locale/en/rail-announcer.cfg
---
---This module takes RailDescription objects from the railutils describer and converts
---them into localized messages using MessageBuilder.

local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---Build announcement message for a rail
---@param description railutils.RailDescription Rail description from describer
---@param prefix_rail boolean? If true, prefix with "rail" (default true for backwards compatibility)
---@return LocalisedString Message ready for speech
function mod.announce_rail(description, prefix_rail)
   if prefix_rail == nil then prefix_rail = true end

   local message = MessageBuilder.new()

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

   return message:build()
end

return mod
