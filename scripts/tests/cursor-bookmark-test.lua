--- Test cursor bookmark system
-- Tests saving and restoring cursor position bookmarks

local EventManager = require("scripts.event-manager")
local graphics = require("scripts.graphics")
local viewpoint = require("scripts.viewpoint")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Cursor Bookmark Tests", function()
   it("should save and restore cursor bookmarks", function(ctx)
      ctx:init(function()
         local pindex = 1
         local player = game.get_player(pindex)

         -- Ensure player exists
         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end

         ctx.state.pindex = pindex
         ctx.state.player = player

         -- Initialize cursor at a known position
         local vp = viewpoint.get_viewpoint(pindex)
         local cursor_pos = vp:get_cursor_pos()
         ctx.state.initial_pos = { x = cursor_pos.x, y = cursor_pos.y }
      end)

      ctx:at_tick(1, function()
         -- Test saving bookmark using viewpoint
         local vp = viewpoint.get_viewpoint(ctx.state.pindex)
         local current_pos = vp:get_cursor_pos()

         -- The viewpoint module has a bookmark feature
         vp:set_cursor_bookmark({ x = current_pos.x, y = current_pos.y })

         -- Store the bookmarked position for verification
         ctx.state.bookmarked_pos = { x = current_pos.x, y = current_pos.y }
      end)

      ctx:at_tick(2, function()
         -- Move cursor to a different position
         local vp = viewpoint.get_viewpoint(ctx.state.pindex)
         vp:set_cursor_pos({ x = 10, y = 10 })

         -- Verify cursor moved
         local new_pos = vp:get_cursor_pos()
         ctx:assert_not_nil(new_pos, "Cursor position should exist")
         ctx:assert_equals(10, new_pos.x, "Cursor X should be 10")
         ctx:assert_equals(10, new_pos.y, "Cursor Y should be 10")
      end)

      ctx:at_tick(3, function()
         -- Test loading bookmark
         local vp = viewpoint.get_viewpoint(ctx.state.pindex)
         local bookmarked_pos = vp:get_cursor_bookmark()

         -- Verify bookmark was saved correctly
         ctx:assert_equals(ctx.state.bookmarked_pos.x, bookmarked_pos.x, "Bookmarked X should match")
         ctx:assert_equals(ctx.state.bookmarked_pos.y, bookmarked_pos.y, "Bookmarked Y should match")

         -- Restore cursor to bookmarked position
         vp:set_cursor_pos(bookmarked_pos)

         -- Verify cursor returned to saved position
         local restored_pos = vp:get_cursor_pos()
         ctx:assert_equals(ctx.state.initial_pos.x, restored_pos.x, "X coordinate should be restored")
         ctx:assert_equals(ctx.state.initial_pos.y, restored_pos.y, "Y coordinate should be restored")
      end)

      ctx:at_tick(4, function()
         -- Test completed
      end)
   end)

   it("should handle multiple bookmarks", function(ctx)
      ctx:init(function()
         local pindex = 1
         local player = game.get_player(pindex)

         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end

         ctx.state.pindex = pindex
         ctx.state.player = player
         ctx.state.positions = {}
      end)

      ctx:at_tick(1, function()
         -- Note: viewpoint module only supports one bookmark, not multiple
         -- Test that bookmark can be overwritten
         local vp = viewpoint.get_viewpoint(ctx.state.pindex)

         -- Save first position
         vp:set_cursor_pos({ x = 5, y = 5 })
         vp:set_cursor_bookmark({ x = 5, y = 5 })
         ctx.state.first_bookmark = vp:get_cursor_bookmark()

         -- Save second position (overwrites)
         vp:set_cursor_pos({ x = 10, y = 10 })
         vp:set_cursor_bookmark({ x = 10, y = 10 })
         ctx.state.second_bookmark = vp:get_cursor_bookmark()
      end)

      ctx:at_tick(2, function()
         -- Verify bookmark was overwritten
         local vp = viewpoint.get_viewpoint(ctx.state.pindex)
         local current_bookmark = vp:get_cursor_bookmark()

         -- Should have the second bookmark value
         ctx:assert_equals(10, current_bookmark.x, "Bookmark X should be overwritten to 10")
         ctx:assert_equals(10, current_bookmark.y, "Bookmark Y should be overwritten to 10")

         -- First bookmark should have been overwritten
         ctx:assert_not_equals(5, current_bookmark.x, "First bookmark X should be overwritten")
      end)

      ctx:at_tick(3, function()
         -- Test completed
      end)
   end)
end)
