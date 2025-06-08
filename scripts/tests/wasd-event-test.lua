--- Test WASD keyboard events for cursor movement
-- Simulates keyboard input to test cursor movement

local EventManager = require("scripts.event-manager")
local TestRegistry = require("scripts.test-registry")
local Viewpoint = require("scripts.viewpoint")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("WASD Event Tests", function()
   it("should move cursor with simulated WASD events", function(ctx)
      -- Local variables for the test
      local pindex = 1
      local player
      local vp
      local initial_pos

      ctx:init(function()
         player = game.get_player(pindex)

         -- Ensure player exists
         if not player then
            ctx:error("No player found at index 1")
            return
         end

         -- Get viewpoint for cursor operations
         vp = Viewpoint.get_viewpoint(pindex)
      end)

      ctx:at_tick(1, function()
         -- First enable cursor mode by mocking 'I' key press
         local enable_cursor_event = {
            name = "fa-i",
            player_index = pindex,
            tick = game.tick,
         }
         EventManager.mock_event("fa-i", enable_cursor_event)
         
         -- Verify cursor is enabled
         ctx:assert(vp:get_cursor_enabled(), "Cursor should be enabled after pressing I")
         
         -- Record initial cursor position
         initial_pos = vp:get_cursor_pos()
      end)

      ctx:at_tick(2, function()
         -- Mock pressing 'D' (move east)
         local event = {
            name = "fa-d",
            player_index = pindex,
            tick = game.tick,
         }
         EventManager.mock_event("fa-d", event)
         
         -- Check cursor moved east
         local new_pos = vp:get_cursor_pos()
         ctx:assert(new_pos.x > initial_pos.x, "Cursor should have moved east")
         ctx:assert(new_pos.y == initial_pos.y, "Cursor Y should not have changed")
      end)

      ctx:at_tick(3, function()
         -- Mock pressing 'W' (move north) 
         local event = {
            name = "fa-w",
            player_index = pindex,
            tick = game.tick,
         }
         EventManager.mock_event("fa-w", event)
         
         -- Check cursor moved north (negative Y in Factorio)
         local new_pos = vp:get_cursor_pos()
         ctx:assert(new_pos.y < initial_pos.y, "Cursor should have moved north")
      end)

      ctx:at_tick(4, function()
         -- Mock pressing 'A' (move west)
         local event = {
            name = "fa-a", 
            player_index = pindex,
            tick = game.tick,
         }
         EventManager.mock_event("fa-a", event)
         
         -- Check cursor moved west (back to original X)
         local new_pos = vp:get_cursor_pos()
         ctx:assert(new_pos.x == initial_pos.x, "Cursor should be back at original X position")
      end)

      ctx:at_tick(5, function()
         -- Mock pressing 'S' (move south)
         local event = {
            name = "fa-s",
            player_index = pindex,
            tick = game.tick,
         }
         EventManager.mock_event("fa-s", event)
         
         -- Check cursor moved south (back to original position)
         local new_pos = vp:get_cursor_pos()
         ctx:assert(new_pos.x == initial_pos.x, "Cursor X should match initial")
         ctx:assert(new_pos.y == initial_pos.y, "Cursor Y should match initial")
      end)
   end)
end)
