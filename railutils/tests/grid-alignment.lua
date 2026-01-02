---Test that rail extensions are grid-aligned
---Tests that Traverser correctly produces positions that match where Factorio places rails

local lu = require("luaunit")
require("polyfill")

local Traverser = require("railutils.traverser")
local RailInfo = require("railutils.rail-info")

local mod = {}

function mod.TestGridAlignment_ExtendNorth()
   -- Place a vertical rail at (1, 1)
   local trav =
      Traverser.new(RailInfo.RailType.STRAIGHT, { x = 1, y = 1 }, defines.direction.north, defines.direction.north)

   -- Extend once north
   trav:move_forward()

   local new_pos = trav:get_position()

   -- The new position should be grid-aligned
   -- For a vertical rail extending north from (1,1), we expect it at (1, -1)
   lu.assertEquals(new_pos.x, 1, "X position should be 1")
   lu.assertEquals(new_pos.y, -1, "Y position should be -1")
end

function mod.TestGridAlignment_ExtendSouth()
   -- Place a vertical rail at (1, 1)
   local trav =
      Traverser.new(RailInfo.RailType.STRAIGHT, { x = 1, y = 1 }, defines.direction.north, defines.direction.north)

   -- Flip to face south
   trav:flip_ends()

   -- Extend once south
   trav:move_forward()

   local new_pos = trav:get_position()

   -- For a vertical rail extending south from (1,1), we expect it at (1, 3)
   lu.assertEquals(new_pos.x, 1, "X position should be 1")
   lu.assertEquals(new_pos.y, 3, "Y position should be 3")
end

function mod.TestGridAlignment_ExtendEast()
   -- Place a horizontal rail at (1, 1)
   local trav =
      Traverser.new(RailInfo.RailType.STRAIGHT, { x = 1, y = 1 }, defines.direction.east, defines.direction.east)

   -- Extend once east
   trav:move_forward()

   local new_pos = trav:get_position()

   -- For a horizontal rail extending east from (1,1), we expect it at (3, 1)
   lu.assertEquals(new_pos.x, 3, "X position should be 3")
   lu.assertEquals(new_pos.y, 1, "Y position should be 1")
end

return mod
