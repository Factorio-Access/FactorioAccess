--[[
Entity connection bounding boxes.

Combinators (arithmetic, decider, selector) have separate input and output connection points.
Power switches have left and right copper connection points.
The drag_wire API uses position to determine which side to connect to. This module provides
access to the AABBs for these connection points, which are only available in the data stage.
]]

local Functools = require("scripts.functools")
local DataToRuntimeMap = require("scripts.data-to-runtime-map")

local mod = {}

---@alias fa.ConnectionSide "input"|"output"|"left"|"right"

---@class fa.CombinatorConnectionData
---@field input_aabb fa.AABB
---@field output_aabb fa.AABB

---@class fa.PowerSwitchConnectionData
---@field left_pos Vector
---@field right_pos Vector

---Convert AABB to named format if needed
---@param aabb table Either array format {{x1, y1}, {x2, y2}} or named format {left_top = {x, y}, right_bottom = {x, y}}
---@return fa.AABB Named format: {left_top = {x, y}, right_bottom = {x, y}}
local function convert_aabb(aabb)
   if not aabb then return nil end

   -- Check if already in named format
   if aabb.left_top then return aabb end

   -- Convert from array format
   return {
      left_top = { x = aabb[1][1], y = aabb[1][2] },
      right_bottom = { x = aabb[2][1], y = aabb[2][2] },
   }
end

---Convert position vector to named format if needed
---@param pos table Either array format {x, y} or named format {x = ..., y = ...}
---@return Vector Named format: {x = ..., y = ...}
local function convert_vec(pos)
   if not pos then return nil end

   -- Check if already in named format
   if pos.x then return pos end

   -- Convert from array format
   return { x = pos[1], y = pos[2] }
end

---@type fun(): table<string, fa.CombinatorConnectionData|fa.PowerSwitchConnectionData>
local load_map_cached = Functools.cached(function()
   local raw_data = DataToRuntimeMap.load("combinator-bounding-boxes")
   local converted = {}

   for name, data in pairs(raw_data) do
      if data.input_aabb then
         -- It's a combinator
         converted[name] = {
            input_aabb = convert_aabb(data.input_aabb),
            output_aabb = convert_aabb(data.output_aabb),
         }
      else
         -- It's a power switch
         converted[name] = {
            left_pos = convert_vec(data.left_pos),
            right_pos = convert_vec(data.right_pos),
         }
      end
   end

   return converted
end)

---Get connection metadata for a given prototype name
---@param name string The prototype name (e.g. "arithmetic-combinator", "power-switch")
---@return fa.CombinatorConnectionData|fa.PowerSwitchConnectionData|nil
function mod.get_metadata(name)
   local map = mod.load_map()
   return map[name]
end

---Build the connection bounding box map in data stage
function mod.build_map()
   local connection_data = {}

   -- Collect all combinator types
   local combinator_types = {
      "arithmetic-combinator",
      "decider-combinator",
      "selector-combinator",
   }

   for _, combinator_type in ipairs(combinator_types) do
      for name, proto in pairs(data.raw[combinator_type] or {}) do
         connection_data[name] = {
            input_aabb = proto.input_connection_bounding_box,
            output_aabb = proto.output_connection_bounding_box,
         }
      end
   end

   -- Collect power switches
   for name, proto in pairs(data.raw["power-switch"] or {}) do
      connection_data[name] = {
         left_pos = proto.left_wire_connection_point.wire.copper,
         right_pos = proto.right_wire_connection_point.wire.copper,
      }
   end

   DataToRuntimeMap.build("combinator-bounding-boxes", connection_data)
end

---Load the connection bounding box map at runtime (memoized)
---@return table<string, fa.CombinatorConnectionData|fa.PowerSwitchConnectionData>
function mod.load_map()
   return load_map_cached()
end

return mod
