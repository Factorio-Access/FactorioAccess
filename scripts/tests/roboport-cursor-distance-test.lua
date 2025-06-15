local FaUtils = require("scripts.fa-utils")
local Viewpoint = require("scripts.viewpoint")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Roboport Distance Cursor Mode", function()
   it("should correctly handle get_player_relative_origin helper", function(ctx)
      local player
      local vp

      ctx:init(function()
         player = game.get_player(1)
         vp = Viewpoint.get_viewpoint(1)

         -- Place player at a known position
         player.teleport({ x = 10, y = 20 })
      end)

      ctx:at_tick(1, function()
         -- Test with cursor disabled - should return player position
         vp:set_cursor_enabled(false)

         local position = FaUtils.get_player_relative_origin(1)
         ctx:assert_not_nil(position, "Should return position")
         ctx:assert_equals(10, position.x, "Should return player X when cursor disabled")
         ctx:assert_equals(20, position.y, "Should return player Y when cursor disabled")
      end)

      ctx:in_ticks(5, function()
         -- Test with cursor enabled - should return cursor position
         vp:set_cursor_enabled(true)
         vp:set_cursor_pos({ x = 100, y = 150 })

         local position = FaUtils.get_player_relative_origin(1)
         ctx:assert_equals(100, position.x, "Should return cursor X when cursor enabled")
         ctx:assert_equals(150, position.y, "Should return cursor Y when cursor enabled")
      end)

      ctx:in_ticks(5, function()
         -- Test without character (god mode) - should still work
         local old_char = player.character
         player.character = nil

         local position = FaUtils.get_player_relative_origin(1)
         ctx:assert_not_nil(position, "Should return position even without character")

         -- Restore character
         player.character = old_char
      end)
   end)

   it("should calculate distances correctly using relative origin", function(ctx)
      local player
      local vp
      local target_pos = { x = 50, y = 0 }

      ctx:init(function()
         player = game.get_player(1)
         vp = Viewpoint.get_viewpoint(1)

         -- Place player at origin
         player.teleport({ x = 0, y = 0 })
      end)

      ctx:at_tick(1, function()
         -- Test distance with cursor disabled
         vp:set_cursor_enabled(false)

         local pos = FaUtils.get_player_relative_origin(1)
         local dist = FaUtils.distance(pos, target_pos)

         -- Distance from (0,0) to (50,0) should be 50
         ctx:assert_equals(50, dist, "Distance should be 50 when using player position")
      end)

      ctx:in_ticks(5, function()
         -- Test distance with cursor enabled
         vp:set_cursor_enabled(true)
         vp:set_cursor_pos({ x = 48, y = 0 })

         local pos = FaUtils.get_player_relative_origin(1)
         local dist = FaUtils.distance(pos, target_pos)

         -- Distance from (48,0) to (50,0) should be 2
         ctx:assert_equals(2, dist, "Distance should be 2 when using cursor position")
      end)

      ctx:in_ticks(5, function()
         -- Test distance after moving cursor
         vp:set_cursor_pos({ x = 40, y = 30 })

         local pos = FaUtils.get_player_relative_origin(1)
         local dist = FaUtils.distance(pos, target_pos)

         -- Distance from (40,30) to (50,0) should be sqrt(100 + 900) = sqrt(1000) ≈ 31.62
         local expected = math.sqrt(10 * 10 + 30 * 30)
         ctx:assert(
            math.abs(dist - expected) < 0.01,
            "Distance should be approximately " .. expected .. " but was " .. dist
         )
      end)
   end)
end)
