local lu = require("luaunit")

local Directions = require("syntrax.directions")

local mod = {}

function mod.TestDirectionConstants()
   -- Test that constants match Factorio's direction system
   lu.assertEquals(Directions.NORTH, 0)
   lu.assertEquals(Directions.NORTH_NORTHEAST, 1)
   lu.assertEquals(Directions.NORTHEAST, 2)
   lu.assertEquals(Directions.EAST_NORTHEAST, 3)
   lu.assertEquals(Directions.EAST, 4)
   lu.assertEquals(Directions.EAST_SOUTHEAST, 5)
   lu.assertEquals(Directions.SOUTHEAST, 6)
   lu.assertEquals(Directions.SOUTH_SOUTHEAST, 7)
   lu.assertEquals(Directions.SOUTH, 8)
   lu.assertEquals(Directions.SOUTH_SOUTHWEST, 9)
   lu.assertEquals(Directions.SOUTHWEST, 10)
   lu.assertEquals(Directions.WEST_SOUTHWEST, 11)
   lu.assertEquals(Directions.WEST, 12)
   lu.assertEquals(Directions.WEST_NORTHWEST, 13)
   lu.assertEquals(Directions.NORTHWEST, 14)
   lu.assertEquals(Directions.NORTH_NORTHWEST, 15)
end

function mod.TestToName()
   -- Test direction to name conversion
   lu.assertEquals(Directions.to_name(Directions.NORTH), "N")
   lu.assertEquals(Directions.to_name(Directions.EAST), "E")
   lu.assertEquals(Directions.to_name(Directions.SOUTH), "S")
   lu.assertEquals(Directions.to_name(Directions.WEST), "W")
   lu.assertEquals(Directions.to_name(Directions.NORTHEAST), "NE")
   lu.assertEquals(Directions.to_name(Directions.SOUTHEAST), "SE")
   lu.assertEquals(Directions.to_name(Directions.SOUTHWEST), "SW")
   lu.assertEquals(Directions.to_name(Directions.NORTHWEST), "NW")

   -- Test invalid directions
   lu.assertEquals(Directions.to_name(16), "16")
   lu.assertEquals(Directions.to_name(-1), "-1")
   lu.assertEquals(Directions.to_name(100), "100")
end

function mod.TestRotate()
   -- Test clockwise rotation
   lu.assertEquals(Directions.rotate(Directions.NORTH, 1), Directions.NORTH_NORTHEAST)
   lu.assertEquals(Directions.rotate(Directions.NORTH, 4), Directions.EAST)
   lu.assertEquals(Directions.rotate(Directions.NORTH, 8), Directions.SOUTH)
   lu.assertEquals(Directions.rotate(Directions.NORTH, 12), Directions.WEST)
   lu.assertEquals(Directions.rotate(Directions.NORTH, 16), Directions.NORTH) -- Full circle

   -- Test counterclockwise rotation
   lu.assertEquals(Directions.rotate(Directions.NORTH, -1), Directions.NORTH_NORTHWEST)
   lu.assertEquals(Directions.rotate(Directions.NORTH, -4), Directions.WEST)
   lu.assertEquals(Directions.rotate(Directions.NORTH, -8), Directions.SOUTH)
   lu.assertEquals(Directions.rotate(Directions.NORTH, -12), Directions.EAST)
   lu.assertEquals(Directions.rotate(Directions.NORTH, -16), Directions.NORTH) -- Full circle

   -- Test wrapping
   lu.assertEquals(Directions.rotate(Directions.NORTH_NORTHWEST, 1), Directions.NORTH)
   lu.assertEquals(Directions.rotate(Directions.NORTH, -1), Directions.NORTH_NORTHWEST)

   -- Test large rotations
   lu.assertEquals(Directions.rotate(Directions.NORTH, 17), Directions.NORTH_NORTHEAST)
   lu.assertEquals(Directions.rotate(Directions.NORTH, 32), Directions.NORTH) -- Two full circles
end

function mod.TestOpposite()
   -- Test opposite directions
   lu.assertEquals(Directions.opposite(Directions.NORTH), Directions.SOUTH)
   lu.assertEquals(Directions.opposite(Directions.EAST), Directions.WEST)
   lu.assertEquals(Directions.opposite(Directions.SOUTH), Directions.NORTH)
   lu.assertEquals(Directions.opposite(Directions.WEST), Directions.EAST)

   lu.assertEquals(Directions.opposite(Directions.NORTHEAST), Directions.SOUTHWEST)
   lu.assertEquals(Directions.opposite(Directions.SOUTHEAST), Directions.NORTHWEST)
   lu.assertEquals(Directions.opposite(Directions.SOUTHWEST), Directions.NORTHEAST)
   lu.assertEquals(Directions.opposite(Directions.NORTHWEST), Directions.SOUTHEAST)

   -- Test that opposite of opposite is the original
   for i = 0, 15 do
      lu.assertEquals(Directions.opposite(Directions.opposite(i)), i)
   end
end

return mod
