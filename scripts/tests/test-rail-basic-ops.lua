local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

-- Load the module at the top level
local RailOps = require("scripts.rails.basic-ops")

describe("Rail Basic Operations", function()
   it("should test get_rail_end_directions function", function(ctx)
      local surface

      ctx:init(function()
         surface = game.surfaces[1]
      end)

      ctx:at_tick(2, function()
         -- Test with straight rail
         local straight_rail = surface.create_entity({
            name = "straight-rail",
            position = { 0, 0 },
            direction = defines.direction.north,
            force = "player",
         })

         local directions = RailOps.get_rail_end_directions(straight_rail, "rail")
         ctx:assert_table_equals(directions, { defines.direction.north, defines.direction.south })
         straight_rail.destroy()
      end)

      ctx:at_tick(5, function()
         -- Test with curved rail
         local curved_rail = surface.create_entity({
            name = "curved-rail-a",
            position = { 5, 0 },
            direction = defines.direction.north,
            force = "player",
         })

         local directions = RailOps.get_rail_end_directions(curved_rail, "rail")
         ctx:assert_equals(2, #directions, "Curved rail should return exactly 2 directions")
         table.sort(directions)
         ctx:assert_table_equals({ defines.direction.south, defines.direction.northnorthwest }, directions)

         curved_rail.destroy()
      end)
   end)

   it("should test get_empty_directions function", function(ctx)
      local surface

      ctx:init(function()
         surface = game.surfaces[1]
      end)

      ctx:at_tick(2, function()
         -- Test with isolated rail (should have empty directions)
         local isolated_rail = surface.create_entity({
            name = "straight-rail",
            position = { 0, 0 },
            direction = defines.direction.north,
            force = "player",
         })

         local empty_dirs = RailOps.get_empty_directions(isolated_rail, "rail")
         assert(#empty_dirs >= 0, "Should return valid array")
         table.sort(empty_dirs)
         ctx:assert_table_equals({ defines.direction.north, defines.direction.south }, empty_dirs)
         isolated_rail.destroy()
      end)

      ctx:at_tick(5, function()
         -- Test with connected rails
         local rail1 = surface.create_entity({
            name = "straight-rail",
            position = { 0, 0 },
            direction = defines.direction.north,
            force = "player",
         })

         local rail2 = surface.create_entity({
            name = "straight-rail",
            position = { 0, -2 },
            direction = defines.direction.north,
            force = "player",
         })

         local empty_dirs = RailOps.get_empty_directions(rail1, "rail")
         ctx:assert_table_equals({ defines.direction.south }, empty_dirs)

         rail1.destroy()
         rail2.destroy()
      end)
   end)
end)
