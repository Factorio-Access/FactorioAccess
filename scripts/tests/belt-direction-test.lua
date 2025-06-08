--- Test transport belt mod functionality
-- Tests mod's ability to handle belt information

local EventManager = require("scripts.event-manager")
local fa_transport_belts = require("scripts.transport-belts")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Transport Belt Mod Tests", function()
   it("should read splitter priority settings", function(ctx)
      -- Local variables for the test
      local pindex = 1
      local player
      local surface
      local splitter

      ctx:init(function()
         -- Use the common test setup helper
         player, surface = ctx:setup_test_area(pindex)
         if not player then return end
      end)

      ctx:at_tick(1, function()
         -- Create a splitter
         splitter = surface.create_entity({
            name = "splitter",
            position = { x = 0, y = 0 },
            direction = defines.direction.north,
            force = player.force,
         })
      end)

      ctx:at_tick(2, function()
         -- Test the mod's splitter priority info function
         local info = fa_transport_belts.splitter_priority_info(splitter)

         -- The function should return info about the splitter's priority settings
         ctx:assert_not_nil(info, "Splitter priority info should be returned")
         -- Info might be a localized string table
         ctx:assert(type(info) == "string" or type(info) == "table", "Info should be a string or localized table")
      end)

      ctx:at_tick(3, function()
         -- Test setting splitter priority using mod function
         -- Set input priority to left
         fa_transport_belts.set_splitter_priority(splitter, true, true, nil, false)

         -- Get updated info
         local info = fa_transport_belts.splitter_priority_info(splitter)
         -- Convert to string if it's a localized table
         local info_str = type(info) == "table" and serpent.line(info) or tostring(info)
         ctx:assert(info_str:find("left") ~= nil, "Info should mention left priority")
      end)
   end)
end)
