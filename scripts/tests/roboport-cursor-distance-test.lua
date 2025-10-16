local FaUtils = require("scripts.fa-utils")
local TestRegistry = require("scripts.test-registry")
local Viewpoint = require("scripts.viewpoint")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Roboport Distance Cursor Mode", function()
   it("should correctly handle cursor position for distance calculations", function(ctx)
      local player
      local vp

      ctx:init(function()
         player = game.get_player(1)
         vp = Viewpoint.get_viewpoint(1)

         -- Place player at a known position
         player.teleport({ x = 10, y = 20 })
      end)

      ctx:at_tick(1, function()
         -- Test cursor position setting
         vp:set_cursor_pos({ x = 10, y = 20 })

         local position = vp:get_cursor_pos()
         ctx:assert_not_nil(position, "Should return cursor position")
         ctx:assert_equals(10, position.x, "Cursor X should be 10")
         ctx:assert_equals(20, position.y, "Cursor Y should be 20")
      end)

      ctx:in_ticks(5, function()
         -- Test cursor position update
         vp:set_cursor_pos({ x = 100, y = 150 })

         local position = vp:get_cursor_pos()
         ctx:assert_equals(100, position.x, "Cursor X should be 100")
         ctx:assert_equals(150, position.y, "Cursor Y should be 150")
      end)

      ctx:in_ticks(5, function()
         -- Test cursor position works without character (god mode)
         local old_char = player.character
         player.character = nil

         local position = vp:get_cursor_pos()
         ctx:assert_not_nil(position, "Should return cursor position even without character")

         -- Restore character
         player.character = old_char
      end)
   end)

   it("should calculate distances correctly using cursor position", function(ctx)
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
         -- Test distance from cursor at origin
         vp:set_cursor_pos({ x = 0, y = 0 })

         local pos = vp:get_cursor_pos()
         local dist = FaUtils.distance(pos, target_pos)

         -- Distance from (0,0) to (50,0) should be 50
         ctx:assert_equals(50, dist, "Distance should be 50 from cursor at origin")
      end)

      ctx:in_ticks(5, function()
         -- Test distance with cursor at different position
         vp:set_cursor_pos({ x = 48, y = 0 })

         local pos = vp:get_cursor_pos()
         local dist = FaUtils.distance(pos, target_pos)

         -- Distance from (48,0) to (50,0) should be 2
         ctx:assert_equals(2, dist, "Distance should be 2 from cursor position")
      end)

      ctx:in_ticks(5, function()
         -- Test distance after moving cursor
         vp:set_cursor_pos({ x = 40, y = 30 })

         local pos = vp:get_cursor_pos()
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
