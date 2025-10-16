--- Simple smoke test

local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Basic Smoke Tests", function()
   it("should pass a trivial test", function(ctx)
      ctx:init(function()
         -- Just verify we can run a test at all
         ctx:assert(true, "True should be true")

         -- Verify game object exists
         ctx:assert_not_nil(game, "game should exist")
         ctx:assert_not_nil(game.tick, "game.tick should exist")

         -- Verify player 1 exists in benchmark mode
         local player = game.get_player(1)
         ctx:assert_not_nil(player, "Player 1 should exist")
      end)
   end)

   it("should handle basic state tracking", function(ctx)
      -- Local variable accessible to all closures
      local test_value

      ctx:init(function()
         test_value = 42
         game.print("Init: Set test_value to " .. tostring(test_value))
      end)

      ctx:at_tick(1, function()
         -- Verify state persists
         game.print("Tick 1: test_value is " .. tostring(test_value))
         ctx:assert_equals(42, test_value, "State should persist")

         -- Modify state
         test_value = 100
      end)

      ctx:at_tick(2, function()
         -- Verify state changes persist
         ctx:assert_equals(100, test_value, "State changes should persist")
      end)
   end)
end)
