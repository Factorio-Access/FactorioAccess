-- Test to verify TAB doesn't crash with no UI open or with legacy UI
local TestRegistry = require("scripts.test-registry")
local EventManager = require("scripts.event-manager")
local UiRouter = require("scripts.ui.router")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("TAB Key Safety Test", function()
   it("should not crash when pressing TAB with no UI open", function(ctx)
      ctx:at_tick(10, function()
         -- First, close any open UI
         local player = game.get_player(1)
         if player and player.opened then player.opened = nil end

         -- Ensure router shows no UI open
         local router = UiRouter.get_router(1)
         router:close_ui()

         -- Simulate pressing TAB with no UI open
         EventManager.mock_event("fa-tab", {
            tick = game.tick,
            player_index = 1,
            input_name = "fa-tab",
            cursor_position = { x = 0, y = 0 },
            cursor_display_location = { x = 0, y = 0 },
            selected_prototype = nil,
         })

         -- If we get here without crashing, the test passes
         print("TAB key handled safely with no UI open")
      end)

      ctx:at_tick(20, function()
         -- Now test with a legacy UI name set (simulating pressing E)
         local router = UiRouter.get_router(1)
         router:open_ui("inventory") -- Legacy UI name with no registered TabList

         -- Simulate pressing TAB with legacy UI
         EventManager.mock_event("fa-tab", {
            tick = game.tick,
            player_index = 1,
            input_name = "fa-tab",
            cursor_position = { x = 0, y = 0 },
            cursor_display_location = { x = 0, y = 0 },
            selected_prototype = nil,
         })

         -- If we get here without crashing, the test passes
         print("TAB key handled safely with legacy UI open")
      end)
   end)
end)
