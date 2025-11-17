---Rail information types and enums
---
---This module defines the core data types for representing rail pieces in a way that works
---both with real Factorio entities and with dry-run/test implementations.

require("polyfill")

local mod = {}

---Rail piece types
---String values use dashes for localization compatibility
---@enum railutils.RailType
mod.RailType = {
   STRAIGHT = "straight-rail",
   CURVE_A = "curved-rail-a",
   CURVE_B = "curved-rail-b",
   HALF_DIAGONAL = "half-diagonal-rail",
}

---Rail kind/description types (for announcements)
---String values match locale keys in locale/en/rail-announcer.cfg
---@enum railutils.RailKind
mod.RailKind = {
   -- Simple straight rails
   VERTICAL = "vertical",
   HORIZONTAL = "horizontal",

   -- Half-diagonal and diagonal rails (12 directions)
   NORTHNORTHEAST = "northnortheast",
   NORTHEAST = "northeast",
   EASTNORTHEAST = "eastnortheast",
   EASTSOUTHEAST = "eastsoutheast",
   SOUTHEAST = "southeast",
   SOUTHSOUTHEAST = "southsoutheast",
   SOUTHSOUTHWEST = "southsouthwest",
   SOUTHWEST = "southwest",
   WESTSOUTHWEST = "westsouthwest",
   WESTNORTHWEST = "westnorthwest",
   NORTHWEST = "northwest",
   NORTHNORTHWEST = "northnorthwest",

   -- 90-degree turn positions (4 turns × 4 positions)
   TOP_OF_EAST_TO_NORTH_TURN = "top-of-east-to-north-turn",
   UPPER_HALF_OF_EAST_TO_NORTH_TURN = "upper-half-of-east-to-north-turn",
   LOWER_HALF_OF_EAST_TO_NORTH_TURN = "lower-half-of-east-to-north-turn",
   BOTTOM_OF_EAST_TO_NORTH_TURN = "bottom-of-east-to-north-turn",

   TOP_OF_EAST_TO_SOUTH_TURN = "top-of-east-to-south-turn",
   UPPER_HALF_OF_EAST_TO_SOUTH_TURN = "upper-half-of-east-to-south-turn",
   LOWER_HALF_OF_EAST_TO_SOUTH_TURN = "lower-half-of-east-to-south-turn",
   BOTTOM_OF_EAST_TO_SOUTH_TURN = "bottom-of-east-to-south-turn",

   TOP_OF_WEST_TO_NORTH_TURN = "top-of-west-to-north-turn",
   UPPER_HALF_OF_WEST_TO_NORTH_TURN = "upper-half-of-west-to-north-turn",
   LOWER_HALF_OF_WEST_TO_NORTH_TURN = "lower-half-of-west-to-north-turn",
   BOTTOM_OF_WEST_TO_NORTH_TURN = "bottom-of-west-to-north-turn",

   TOP_OF_WEST_TO_SOUTH_TURN = "top-of-west-to-south-turn",
   UPPER_HALF_OF_WEST_TO_SOUTH_TURN = "upper-half-of-west-to-south-turn",
   LOWER_HALF_OF_WEST_TO_SOUTH_TURN = "lower-half-of-west-to-south-turn",
   BOTTOM_OF_WEST_TO_SOUTH_TURN = "bottom-of-west-to-south-turn",

   -- Curved rail fallbacks (left/right of cardinal/diagonal)
   LEFT_OF_NORTH = "left-of-north",
   RIGHT_OF_NORTH = "right-of-north",
   LEFT_OF_EAST = "left-of-east",
   RIGHT_OF_EAST = "right-of-east",
   LEFT_OF_SOUTH = "left-of-south",
   RIGHT_OF_SOUTH = "right-of-south",
   LEFT_OF_WEST = "left-of-west",
   RIGHT_OF_WEST = "right-of-west",

   LEFT_OF_NORTHEAST = "left-of-northeast",
   RIGHT_OF_NORTHEAST = "right-of-northeast",
   LEFT_OF_SOUTHEAST = "left-of-southeast",
   RIGHT_OF_SOUTHEAST = "right-of-southeast",
   LEFT_OF_SOUTHWEST = "left-of-southwest",
   RIGHT_OF_SOUTHWEST = "right-of-southwest",
   LEFT_OF_NORTHWEST = "left-of-northwest",
   RIGHT_OF_NORTHWEST = "right-of-northwest",
}

---Junction types (for fork/split detection)
---String values use dashes for localization compatibility
---@enum railutils.JunctionKind
mod.JunctionKind = {
   SPLIT = "split", -- Left and right turns exist, no straight
   FORK_LEFT = "fork-left", -- Straight and left turn exist, no right
   FORK_RIGHT = "fork-right", -- Straight and right turn exist, no left
   FORK_BOTH = "fork-both", -- All three: straight, left, and right
}

---Information about a rail piece
---@class railutils.RailInfo
---@field prototype_position fa.Point Position where the rail is placed (center, on the 1x1 grid)
---@field rail_type railutils.RailType Type of rail piece
---@field direction defines.direction Placement direction of the rail
---@field unit_number number Unique identifier for this rail (always present for rails)

return mod
