local TestRegistry = require("scripts.test-registry")
local FaUtils = require("scripts.fa-utils")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("Liquid tiles for the cursor skip", function()
   it("treats water and the other liquids alike", function(ctx)
      ctx:init(function()
         local player, surface = ctx:setup_test_area(1)
         assert(player and surface)
         local pos = player.position --[[@as MapPosition.struct]]
         local x, y = math.floor(pos.x) - 6, math.floor(pos.y) + 6
         local cases = { { "grass-1", false }, { "water", true }, { "deepwater", true } }
         if script.feature_flags.space_travel then
            table.insert(cases, { "lava", true })
            table.insert(cases, { "oil-ocean-shallow", true })
            table.insert(cases, { "ammoniacal-ocean", true })
         end
         for i, c in ipairs(cases) do
            surface.set_tiles({ { name = c[1], position = { x + i, y } } })
            ctx:assert_equals(c[2], FaUtils.tile_is_water(surface, { x = x + i + 0.5, y = y + 0.5 }), c[1])
         end
         local restore = {}
         for i = 1, #cases do
            table.insert(restore, { name = "grass-1", position = { x + i, y } })
         end
         surface.set_tiles(restore)
      end)
   end)
end)
