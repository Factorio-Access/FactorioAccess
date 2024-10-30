--Here: functions about belts, splitters, underground belts

local localising = require("scripts.localising")
local util = require("util")
local fa_utils = require("scripts.fa-utils")

local mod = {}

--Takes some stats about a belt unit and explains what type of junction the belt is.
function mod.transport_belt_junction_info(
   sideload_count,
   backload_count,
   outload_count,
   this_dir,
   outload_dir,
   say_middle,
   outload_is_corner
)
   local say_middle = say_middle or false
   local outload_is_corner = outload_is_corner or false
   local result = ""
   if sideload_count == 0 and backload_count == 0 and outload_count == 0 then
      result = " unit "
   elseif sideload_count == 0 and backload_count == 1 and outload_count == 0 then
      result = " stopping end "
   elseif sideload_count == 1 and backload_count == 0 and outload_count == 0 then
      result = " stopping end corner "
   elseif sideload_count == 1 and backload_count == 1 and outload_count == 0 then
      result = " sideloading stopping end "
   elseif sideload_count == 2 and backload_count == 1 and outload_count == 0 then
      result = " double sideloading stopping end "
   elseif sideload_count == 2 and backload_count == 0 and outload_count == 0 then
      result = " safe merging stopping end "
   elseif sideload_count == 0 and backload_count == 0 and outload_count == 1 and this_dir == outload_dir then
      result = " start "
   elseif sideload_count == 0 and backload_count == 1 and outload_count == 1 and this_dir == outload_dir then
      if say_middle then
         result = " middle "
      else
         result = " "
      end
   elseif sideload_count == 1 and backload_count == 0 and outload_count == 1 and this_dir == outload_dir then
      result = " corner "
   elseif sideload_count == 1 and backload_count == 1 and outload_count == 1 and this_dir == outload_dir then
      result = " sideloading junction "
   elseif sideload_count == 2 and backload_count == 1 and outload_count == 1 and this_dir == outload_dir then
      result = " double sideloading junction "
   elseif sideload_count == 2 and backload_count == 0 and outload_count == 1 and this_dir == outload_dir then
      result = " safe merging junction "
   elseif sideload_count == 0 and backload_count == 0 and outload_count == 1 and this_dir ~= outload_dir then
      if outload_is_corner == false then
         result = " unit pouring end "
      else
         result = " start "
      end
   elseif sideload_count == 0 and backload_count == 1 and outload_count == 1 and this_dir ~= outload_dir then
      if outload_is_corner == false then
         result = " pouring end "
      else
         if say_middle then
            result = " middle "
         else
            result = " "
         end
      end
   elseif sideload_count == 1 and backload_count == 0 and outload_count == 1 and this_dir ~= outload_dir then
      if outload_is_corner == false then
         result = " corner pouring end "
      else
         result = " corner "
      end
   elseif sideload_count == 1 and backload_count == 1 and outload_count == 1 and this_dir ~= outload_dir then
      if outload_is_corner == false then
         result = " sideloading pouring end "
      else
         result = " sideloading junction "
      end
   elseif sideload_count == 2 and backload_count == 1 and outload_count == 1 and this_dir ~= outload_dir then
      if outload_is_corner == false then
         result = " double sideloading pouring end "
      else
         result = " double sideloading junction "
      end
   elseif sideload_count == 2 and backload_count == 0 and outload_count == 1 and this_dir ~= outload_dir then
      if outload_is_corner == false then
         result = " safe merging pouring end "
      else
         result = " safe merging junction "
      end
   elseif
      sideload_count + backload_count > 1 and (outload_count == 0 or (outload_count == 1 and this_dir == outload_dir))
   then
      result = " unidentified junction " --this should not be reachable any more
   elseif sideload_count + backload_count > 1 and outload_count == 1 and this_dir ~= outload_dir then
      result = " unidentified pouring end "
   elseif outload_count > 1 then
      result = " multiple outputs " --unexpected case
   else
      result = " unknown state " --unexpected case
   end
   return result
   --Note: A pouring end either pours into a sideloading junction, or into a corner and this can now be identified. Lanes are preserved if the target is a corner.
end

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
