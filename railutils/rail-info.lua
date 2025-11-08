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

---Information about a rail piece
---@class railutils.RailInfo
---@field prototype_position fa.Point Position where the rail is placed (center, on the 1x1 grid)
---@field rail_type railutils.RailType Type of rail piece
---@field direction defines.direction Placement direction of the rail
---@field unit_number number Unique identifier for this rail (always present for rails)

return mod
