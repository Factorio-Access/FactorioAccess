local BuildLock = require("scripts.build-lock")
local TestRegistry = require("scripts.test-registry")
local Viewpoint = require("scripts.viewpoint")
local describe, it = TestRegistry.describe, TestRegistry.it

---Whether a's connection of this type reaches b.
---@param a LuaEntity?
---@param b LuaEntity?
---@param how string? The connection type, underground by default
---@return boolean
local function joined(a, b, how)
   assert(a and b)
   for _, c in ipairs(assert(a.get_fluid_box_pipe_connections(1))) do
      if c.connection_type == (how or "underground") and c.target == b then return true end
   end
   return false
end

---Grass and nothing else on the rows y-2..y+2, from x0-1 to x1+1.
---@param surface LuaSurface
---@param x0 integer
---@param x1 integer
---@param y integer
---@return BoundingBox area
local function clear_strip(surface, x0, x1, y)
   local area = { { x0 - 1, y - 2 }, { x1 + 2, y + 3 } }
   for _, e in ipairs(surface.find_entities_filtered({ area = area })) do
      if e.type ~= "character" then e.destroy() end
   end
   local tiles = {}
   for tx = x0 - 1, x1 + 1 do
      for ty = y - 2, y + 2 do
         table.insert(tiles, { name = "grass-1", position = { tx, ty } })
      end
   end
   surface.set_tiles(tiles)
   return area
end

describe("Build lock with pipe to ground", function()
   it("lays chained pairs, steps back from obstacles, and stops at a turn", function(ctx)
      ctx:init(function()
         local player, surface = ctx:setup_test_area(1)
         assert(player and surface)
         local reach = assert(prototypes.entity["pipe-to-ground"].max_underground_distance)
         local pos = player.position --[[@as MapPosition.struct]]
         local x0, y = math.floor(pos.x) + 2, math.floor(pos.y) + 3
         local x1 = x0 + reach + 1 -- where the second pair starts
         local last = x1 + reach + 1
         local area = clear_strip(surface, x0, last, y)

         -- Where the second pair's exit would go: it steps back two tiles, so the next entrance fits before it
         local chest = assert(surface.create_entity({
            name = "wooden-chest",
            position = { x1 + reach + 0.5, y + 0.5 },
            force = player.force,
         }))

         local old_bonus = player.character_build_distance_bonus
         player.character_build_distance_bonus = 100
         assert(player.cursor_stack).set_stack({ name = "pipe-to-ground", count = 50 })

         local vp = Viewpoint.get_viewpoint(1)
         vp:set_cursor_pos({ x = x0, y = y })
         BuildLock.set_enabled(1, true, true)
         ctx:assert(BuildLock.is_enabled(1), "build lock is on")
         for tx = x0 + 1, last do
            vp:set_cursor_pos_continuous({ x = tx, y = y }, defines.direction.east)
         end

         ---@param tx integer
         ---@return LuaEntity?
         local function pipe_at(tx)
            return surface.find_entity("pipe-to-ground", { tx + 0.5, y + 0.5 })
         end

         local placed = surface.find_entities_filtered({ area = area, name = "pipe-to-ground" })
         ctx:assert_equals(5, #placed, "two pairs and an open entrance")
         ctx:assert(joined(pipe_at(x0), pipe_at(x0 + reach)), "the first pair spans the whole reach")
         ctx:assert_not_nil(pipe_at(x1), "the next entrance follows the exit")
         ctx:assert(joined(pipe_at(x1), pipe_at(x1 + reach - 2)), "the second pair stops short of the chest")
         ctx:assert_not_nil(pipe_at(x1 + reach - 1), "with the next entrance before the chest")
         ctx:assert(joined(pipe_at(x0 + reach), pipe_at(x1), "normal"), "the exit joins the next entrance above ground")

         vp:set_cursor_pos_continuous({ x = last, y = y + 1 }, defines.direction.south)
         ctx:assert(not BuildLock.is_enabled(1), "a turn turns build lock off")

         for _, p in ipairs(placed) do
            p.destroy()
         end
         chest.destroy()
         player.character_build_distance_bonus = old_bonus
         player.clear_cursor()
      end)
   end)

   it("lays pairs behind a walking character", function(ctx)
      ---@type LuaPlayer, LuaSurface
      local player, surface
      ---@type integer, integer, integer
      local reach, x0, y
      ---@type BoundingBox
      local area
      ---@type MapPosition.struct
      local start

      ctx:init(function()
         local p, s = ctx:setup_test_area(1)
         player, surface = assert(p), assert(s)
         reach = assert(prototypes.entity["pipe-to-ground"].max_underground_distance)
         start = player.position --[[@as MapPosition.struct]]
         x0, y = math.floor(start.x), math.floor(start.y)
         area = clear_strip(surface, x0, x0 + 2 * reach + 6, y)
         assert(player.cursor_stack).set_stack({ name = "pipe-to-ground", count = 50 })
         BuildLock.set_enabled(1, true, true)
      end)

      -- Walk east until two pairs are behind, about 0.15 tiles a tick. A walking state set by script lasts until
      -- changed.
      for tick = 2, 300 do
         ctx:at_tick(tick, function()
            local walking = player.position.x < x0 + 2 * reach + 4
            player.walking_state = { walking = walking, direction = defines.direction.east }
         end)
      end

      ctx:at_tick(305, function()
         ---@param tx integer
         ---@return LuaEntity?
         local function pipe_at(tx)
            return surface.find_entity("pipe-to-ground", { tx + 0.5, y + 0.5 })
         end
         ctx:assert(player.position.x >= x0 + 2 * reach + 4, "walked far enough")
         ctx:assert(BuildLock.is_enabled(1), "still on")
         local placed = surface.find_entities_filtered({ area = area, name = "pipe-to-ground" })
         ctx:assert_equals(5, #placed, "two pairs and an open entrance")
         ctx:assert(joined(pipe_at(x0), pipe_at(x0 + reach)), "the first pair starts where the character stood")
         ctx:assert(joined(pipe_at(x0 + reach + 1), pipe_at(x0 + 2 * reach + 1)), "the second pair follows")
         ctx:assert_not_nil(pipe_at(x0 + 2 * reach + 2), "and the next entrance")

         BuildLock.set_enabled(1, false, true)
         for _, p in ipairs(placed) do
            p.destroy()
         end
         player.clear_cursor()
         -- Later tests expect the character where it was
         player.teleport(start)
      end)
   end)
end)
