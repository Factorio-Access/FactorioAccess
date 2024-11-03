--Here: functions about belts, splitters, underground belts

local localising = require("scripts.localising")
local util = require("util")
local fa_utils = require("scripts.fa-utils")

local mod = {}

--Transport belt analyzer: Read a results list slot
function mod.read_belt_slot(pindex, start_phrase)
   return "unimplemented for 2.0"
end

--Set the input priority or the output priority or filter for a splitter
function mod.set_splitter_priority(splitter, is_input, is_left, filter_item_stack, clear)
   local clear = clear or false
   local result = "no message"
   local filter = splitter.splitter_filter

   if clear then
      splitter.splitter_filter = nil
      filter = splitter.splitter_filter
      result = "Cleared splitter filter"
      splitter.splitter_output_priority = "none"
   elseif filter_item_stack ~= nil and filter_item_stack.valid_for_read then
      splitter.splitter_filter = filter_item_stack.prototype
      filter = splitter.splitter_filter
      result = "filter set to " .. filter_item_stack.name
      if splitter.splitter_output_priority == "none" then
         splitter.splitter_output_priority = "left"
         result = result .. ", from the left"
      end
   elseif is_input and is_left then
      if splitter.splitter_input_priority == "left" then
         splitter.splitter_input_priority = "none"
         result = "equal input priority"
      else
         splitter.splitter_input_priority = "left"
         result = "left input priority"
      end
   elseif is_input and not is_left then
      if splitter.splitter_input_priority == "right" then
         splitter.splitter_input_priority = "none"
         result = "equal input priority"
      else
         splitter.splitter_input_priority = "right"
         result = "right input priority"
      end
   elseif not is_input and is_left then
      if splitter.splitter_output_priority == "left" then
         if filter == nil then
            splitter.splitter_output_priority = "none"
            result = "equal output priority"
         else
            result = "left filter output"
         end
      else
         if filter == nil then
            splitter.splitter_output_priority = "left"
            result = "left output priority"
         else
            splitter.splitter_output_priority = "left"
            result = "left filter output"
         end
      end
   elseif not is_input and not is_left then
      if splitter.splitter_output_priority == "right" then
         if filter == nil then
            splitter.splitter_output_priority = "none"
            result = "equal output priority"
         else
            result = "right filter output"
         end
      else
         if filter == nil then
            splitter.splitter_output_priority = "right"
            result = "right output priority"
         else
            splitter.splitter_output_priority = "right"
            result = "right filter output"
         end
      end
   else
      result = "Splitter config error"
   end

   return result
end

--Returns an info string about a splitter's input and output settings.
function mod.splitter_priority_info(ent)
   local result = ","
   local input = ent.splitter_input_priority
   local output = ent.splitter_output_priority
   local filter = ent.splitter_filter
   if input == "none" then
      result = result .. " input balanced, "
   elseif input == "right" then
      result = result
         .. " input priority "
         .. "right"
         .. " which is "
         .. fa_utils.direction_lookup(fa_utils.rotate_90(ent.direction))
         .. ", "
   elseif input == "left" then
      result = result
         .. " input priority "
         .. "left"
         .. " which is "
         .. fa_utils.direction_lookup(fa_utils.rotate_270(ent.direction))
         .. ", "
   end
   if filter == nil then
      if output == "none" then
         result = result .. " output balanced, "
      elseif output == "right" then
         result = result
            .. " output priority "
            .. "right"
            .. " which is "
            .. fa_utils.direction_lookup(fa_utils.rotate_90(ent.direction))
            .. ", "
      elseif output == "left" then
         result = result
            .. " output priority "
            .. "left"
            .. " which is "
            .. fa_utils.direction_lookup(fa_utils.rotate_270(ent.direction))
            .. ", "
      end
   else
      local item_name = localising.get(filter, pindex)
      if item_name == nil or item_name == "" then item_name = "unknown item" end
      if output == "right" then
         result = result
            .. " output filtering "
            .. item_name
            .. " towards the "
            .. "right"
            .. " which is "
            .. fa_utils.direction_lookup(fa_utils.rotate_90(ent.direction))
            .. ", "
      elseif output == "left" then
         result = result
            .. " output filtering "
            .. item_name
            .. " towards the "
            .. "left"
            .. " which is "
            .. fa_utils.direction_lookup(fa_utils.rotate_270(ent.direction))
            .. ", "
      end
   end
   return result
end

return mod
