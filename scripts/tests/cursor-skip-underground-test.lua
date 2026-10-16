local EventManager = require("scripts.event-manager")
local TestRegistry = require("scripts.test-registry")
local Viewpoint = require("scripts.viewpoint")
local describe, it = TestRegistry.describe, TestRegistry.it

---Shift and a direction key, as the player presses it.
---@param key "fa-s-a"|"fa-s-d"
local function skip(key)
   EventManager.mock_event(key, { name = key, player_index = 1, tick = game.tick })
end

describe("Cursor skipping over undergrounds", function()
   it("jumps to the other end of a pair, both ways", function(ctx)
      local X, Y = 90, -60
      local GAP = 4 -- within the reach of both the basic underground belt and pipe to ground

      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         local area = { { X - 2, Y - 1 }, { X + GAP + 3, Y + 4 } }
         for _, e in ipairs(surface.find_entities_filtered({ area = area })) do
            if e.type ~= "character" then e.destroy() end
         end
         local tiles = {}
         for x = X - 2, X + GAP + 2 do
            for y = Y - 1, Y + 3 do
               table.insert(tiles, { name = "grass-1", position = { x, y } })
            end
         end
         surface.set_tiles(tiles)
         local force = player.force
         -- A pipe to ground's direction is its above-ground side: west then east makes a pair going east
         surface.create_entity({
            name = "pipe-to-ground",
            position = { X + 0.5, Y + 0.5 },
            direction = defines.direction.west,
            force = force,
         })
         surface.create_entity({
            name = "pipe-to-ground",
            position = { X + GAP + 0.5, Y + 0.5 },
            direction = defines.direction.east,
            force = force,
         })
         surface.create_entity({
            name = "underground-belt",
            type = "input",
            position = { X + 0.5, Y + 2.5 },
            direction = defines.direction.east,
            force = force,
         })
         surface.create_entity({
            name = "underground-belt",
            type = "output",
            position = { X + GAP + 0.5, Y + 2.5 },
            direction = defines.direction.east,
            force = force,
         })
      end)

      ctx:at_tick(2, function()
         local surface = assert(game.get_player(1)).surface
         local belt = assert(surface.find_entity("underground-belt", { X + 0.5, Y + 2.5 }))
         ctx:assert_not_nil(belt.underground_belt_neighbour, "the belts are a pair")
         local vp = Viewpoint.get_viewpoint(1)
         for _, row in ipairs({ { y = Y, what = "pipe to ground" }, { y = Y + 2, what = "underground belt" } }) do
            vp:set_cursor_pos({ x = X + 0.5, y = row.y + 0.5 })
            skip("fa-s-d")
            ctx:assert_equals(X + GAP, math.floor(vp:get_cursor_pos().x), row.what .. ": entrance to exit")
            skip("fa-s-a")
            ctx:assert_equals(X, math.floor(vp:get_cursor_pos().x), row.what .. ": exit back to entrance")
         end
      end)

      ctx:at_tick(3, function()
         local surface = assert(game.get_player(1)).surface
         for _, e in ipairs(surface.find_entities_filtered({ area = { { X - 2, Y - 1 }, { X + GAP + 3, Y + 4 } } })) do
            if e.type ~= "character" then e.destroy() end
         end
      end)
   end)
end)
