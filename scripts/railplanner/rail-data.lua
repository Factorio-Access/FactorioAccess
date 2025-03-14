local dirs16 = require("dirs")
--This is an attempt to generically describe the rail shapes and connectivity
--In theory this could be used to make a rail planner

--rail works in both directions but I think the entrance exit terminology helps
--if the ends of two rail entities are at the same position they might join
--if they are one entrance and one exit facing the same direction they join
--or if they are the same type facing opposite direction they also join.
--if their directions are the opposite of the above then they form a fork.
--if there angular difference is not 0 or 180 then they don't connect.

--The geometry definitions bellow describe all the different shapes
--each shape can be rotated and possibly mirrored
--they are however described in one orientation while the others can be expanded

---@class (exact) RailGeometry.ends.end
---The position of this end relative to the entity position
---@field pos MapPosition
---The direction a train would be traveling while passing through this end in the forward direction
---@field dir dirs16
---@field entering_signals MapPosition[]?
---@field exiting_signals MapPosition[]?

---@class (exact) RailGeometry.ends
---The entrance to this rail
---@field entrance RailGeometry.ends.end
---The exit to this rail
---@field exit RailGeometry.ends.end

---@class (exact) RailGeometry
---The name to refer to this RailGeometry
---@field name string
---The lua entity type that can have this geometry
---@field prototype string
---All rail geometry can be rotated by 90 degrees repeatedly, this is the direction an entity of said prototype will have for the described geometry
---@field dir dirs16
---Straight rail is identical facing south an north so it only faces north
---@field two_way_rotational_symmetry? true
---If mirroring the geometry across the y axis produces a distinct geometry then this direction will have that mirrored geometry.
---@field mirrored_dir? dirs16
---The actual geometry when the entity is facing dir
---@field ends RailGeometry.ends
---The allowed positions of the entity mod 2
---@field mod_pos MapPosition
---If ramp, the elevation gained or zero
---@field elevation_gain integer
---The distance a train travels between the entrance and exit
---@field distance double

---@type (RailGeometry)[]
local rail_shapes_common = {
   {
      name = "straight",
      dir = dirs16.north,
      two_way_rotational_symmetry = true,
      ends = {
         entrance = {
            pos = { 0, 1 },
            dir = dirs16.north,
            exiting_signals = { { -1.5, 0.5 } },
            entering_signals = { { 1.5, 0.5 } },
         },
         exit = {
            pos = { 0, -1 },
            dir = dirs16.north,
            exiting_signals = { { 1.5, -0.5 } },
            entering_signals = { { -1.5, -0.5 } },
         },
      },
      elevation_gain = 0,
      mod_pos = { 1, 1 },
      prototype = "straight-rail",
      distance = 2,
   },
}
---rail geometries that will stop being allowed to place in 2.0
---@type (RailGeometry)[]
local rail_shapes_1 = {
   {
      name = "diagonal",
      dir = dirs16.northeast,
      ends = {
         entrance = { pos = { 0, -1 }, dir = dirs16.southeast },
         exit = { pos = { 1, 0 }, dir = dirs16.southeast },
      },
      elevation_gain = 0,
      mod_pos = { 1, 1 },
      prototype = "straight-rail",
      distance = math.sqrt(2),
   },
   {
      name = "curve",
      dir = dirs16.north,
      mirrored_dir = dirs16.northeast,
      ends = {
         entrance = { pos = { 1, 4 }, dir = dirs16.north },
         exit = { pos = { -2, -3 }, dir = dirs16.northwest },
      },
      elevation_gain = 0,
      mod_pos = { 0, 0 },
      prototype = "curved-rail",
      distance = 7.842081225095013, --source: https://forums.factorio.com/viewtopic.php?t=109189
   },
}
--rail geometries that will unlock with 2.0
---@type (RailGeometry)[]
local rail_shapes_2 = {
   {
      name = "straight_curve_to_half_diag",
      dir = dirs16.north,
      mirrored_dir = dirs16.northeast,
      ends = {
         entrance = {
            pos = { 0, 2 },
            dir = dirs16.north,
            exiting_signals = { { -1.5, 1.5 } },
            entering_signals = { { 1.5, 1.5 } },
         },
         exit = {
            pos = { -1, -3 },
            dir = dirs16.northnorthwest,
            exiting_signals = { { 1.5, -2.5 } },
            entering_signals = { { -1.5, -1.5 } },
         },
      },
      elevation_gain = 0,
      mod_pos = { 1, 0 },
      prototype = "curved-rail-a",
      distance = 5.132284556, --source: https://forums.factorio.com/viewtopic.php?p=592880#p592880
   },
   {
      name = "half-diagonal",
      dir = dirs16.northeast,
      two_way_rotational_symmetry = true,
      mirrored_dir = dirs16.north,
      ends = {
         entrance = {
            pos = { -1, 2 },
            dir = dirs16.northnortheast,
            exiting_signals = { { -1.5, 0.5 } },
            entering_signals = { { 0.5, 1.5 } },
         },
         exit = {
            pos = { 1, -2 },
            dir = dirs16.northnortheast,
            exiting_signals = { { 1.5, -0.5 } },
            entering_signals = { { -0.5, -1.5 } },
         },
      },
      elevation_gain = 0,
      mod_pos = { 1, 1 },
      prototype = "half-diagonal-rail",
      distance = math.sqrt(16 + 4), --4^2 + 2^2
   },
   {
      name = "diag_curve_to_half_diag",
      dir = dirs16.southwest,
      mirrored_dir = dirs16.south,
      ends = {
         entrance = {
            pos = { -2, 2 },
            dir = dirs16.northeast,
            exiting_signals = { { -2.5, 0.5 } },
            entering_signals = { { -0.5, 2.5 } },
         },
         exit = {
            pos = { 1, -2 },
            dir = dirs16.northnortheast,
            exiting_signals = { { 1.5, -0.5 }, { 0.5, 0.5 } },
            entering_signals = { { -0.5, -1.5 } },
         },
      },
      elevation_gain = 0,
      mod_pos = { 1, 1 },
      prototype = "curved-rail-b",
      distance = 5.077891568, --source: https://forums.factorio.com/viewtopic.php?p=592880#p592880
   },
   {
      name = "diagonal",
      dir = dirs16.northeast,
      two_way_rotational_symmetry = true,
      ends = {
         entrance = {
            pos = { -1, 1 },
            dir = dirs16.northeast,
            exiting_signals = { { -1.5, -0.5 } },
            entering_signals = { { 0.5, 1.5 } },
         },
         exit = {
            pos = { 1, -1 },
            dir = dirs16.northeast,
            exiting_signals = { { 1.5, -0.5 } },
            entering_signals = { { -0.5, -1.5 } },
         },
      },
      elevation_gain = 0,
      mod_pos = { 0, 0 },
      prototype = "straight-rail",
      distance = math.sqrt(8),
   },
   {
      name = "ramp",
      prototype = "rail-ramp",
      dir = dirs16.north,
      ends = {
         entrance = { pos = { 0, 8 }, dir = dirs16.north },
         exit = { pos = { 0, -8 }, dir = dirs16.north },
      },
      elevation_gain = 3,
      mod_pos = { 1, 0 },
      distance = 16.762232162214,
   },
}

local ret = rail_shapes_1
if string.sub(script.active_mods.base, 1, 1) == "2" then ret = rail_shapes_2 end
for i, geo in pairs(rail_shapes_common) do
   table.insert(ret, 1, geo)
end
return ret
