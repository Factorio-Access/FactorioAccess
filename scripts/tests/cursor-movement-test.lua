--- Test cursor movement functionality
-- Tests the mod's custom cursor system (not part of vanilla Factorio)

local EventManager = require("scripts.event-manager")
local graphics = require("scripts.graphics")
local TestRegistry = require("scripts.test-registry")
local viewpoint = require("scripts.viewpoint")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Cursor Movement Tests", function()
   it("should initialize cursor system properly", function(ctx)
      -- Local variables for the test
      local pindex = 1
      local player
      local initial_pos

      ctx:init(function()
         player = game.get_player(pindex)

         -- Ensure player exists
         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end

         -- The cursor system should lazy-initialize when accessed
         -- We can test this by getting the viewpoint
         local vp = viewpoint.get_viewpoint(pindex)
         initial_pos = vp:get_cursor_pos()
      end)

      ctx:at_tick(1, function()
         -- Verify cursor was initialized
         local vp = viewpoint.get_viewpoint(pindex)
         local cursor_pos = vp:get_cursor_pos()
         ctx:assert_not_nil(cursor_pos, "Cursor position should be initialized")
         ctx:assert_not_nil(cursor_pos.x, "Cursor should have x coordinate")
         ctx:assert_not_nil(cursor_pos.y, "Cursor should have y coordinate")
      end)

      ctx:at_tick(2, function()
         -- Test cursor size getter
         local vp = viewpoint.get_viewpoint(pindex)
         local cursor_size = vp:get_cursor_size()
         ctx:assert_not_nil(cursor_size, "Cursor size should be initialized")
         ctx:assert(cursor_size >= 0, "Cursor size should be non-negative")
      end)
   end)

   it("should handle cursor size changes", function(ctx)
      -- Local variables for the test
      local pindex = 1
      local player
      local initial_size

      ctx:init(function()
         player = game.get_player(pindex)

         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end
      end)

      ctx:at_tick(1, function()
         -- Get initial cursor size
         local vp = viewpoint.get_viewpoint(pindex)
         initial_size = vp:get_cursor_size()
      end)

      ctx:at_tick(2, function()
         -- Mock cursor size increase event (typically SHIFT+J)
         local event = {
            name = "increase-cursor-size",
            player_index = pindex,
            tick = game.tick,
         }

         -- Note: We need the actual event name from the keybindings
         -- For now, test that cursor size can be retrieved and modified
         local vp = viewpoint.get_viewpoint(pindex)
         local current_size = vp:get_cursor_size()
         ctx:assert_equals(initial_size, current_size, "Cursor size should remain unchanged without event")

         -- Test setting cursor size
         vp:set_cursor_size(current_size + 2)
         local new_size = vp:get_cursor_size()
         ctx:assert_equals(current_size + 2, new_size, "Cursor size should be updated")
      end)
   end)
end)
