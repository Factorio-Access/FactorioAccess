local EventManager = require("scripts.event-manager")
local FaInfo = require("scripts.fa-info")
local EntitySelection = require("scripts.entity-selection")
local TestRegistry = require("scripts.test-registry")
local Viewpoint = require("scripts.viewpoint")
local describe, it = TestRegistry.describe, TestRegistry.it

---@param s any A LocalisedString or one of its parts
---@param key string
---@return boolean
local function has_key(s, key)
   if type(s) ~= "table" then return false end
   if s[1] == key then return true end
   for i = 2, #s do
      if has_key(s[i], key) then return true end
   end
   return false
end

describe("Ghosts on water", function()
   it("reads a belt ghost on its landfill ghost and skips along the line", function(ctx)
      local X, Y = 70, -40
      local LINE = 5 -- ghosts from X + 3

      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         local tiles = {}
         for x = X, X + 14 do
            for y = Y - 1, Y + 1 do
               table.insert(tiles, { name = "water", position = { x, y } })
            end
         end
         surface.set_tiles(tiles)
         for x = X + 3, X + 2 + LINE do
            -- The tile ghost first, as a blueprint places it: it gets the lower unit number
            surface.create_entity({
               name = "tile-ghost",
               inner_name = "landfill",
               position = { x, Y },
               force = player.force,
            })
            surface.create_entity({
               name = "entity-ghost",
               inner_name = "transport-belt",
               position = { x + 0.5, Y + 0.5 },
               direction = defines.direction.east,
               force = player.force,
            })
         end
      end)

      ctx:at_tick(2, function()
         local surface = assert(game.get_player(1)).surface
         local first = EntitySelection.get_ents_on_tile(surface, X + 3.5, Y + 0.5, 1)[1]
         ctx:assert_equals("entity-ghost", first.type, "the belt ghost comes first")
         ctx:assert(has_key(FaInfo.ent_info(1, first), "fa.ent-info-ghost-on-tile"), "it says the landfill under it")

         -- Shift+D from the empty water before the line stops on its first ghost, then skips the line
         local vp = Viewpoint.get_viewpoint(1)
         vp:set_cursor_pos({ x = X + 0.5, y = Y + 0.5 })
         EventManager.mock_event("fa-s-d", { name = "fa-s-d", player_index = 1, tick = game.tick })
         ctx:assert_equals(X + 3, math.floor(vp:get_cursor_pos().x), "stopped on the first ghost")
         EventManager.mock_event("fa-s-d", { name = "fa-s-d", player_index = 1, tick = game.tick })
         ctx:assert_equals(X + 3 + LINE, math.floor(vp:get_cursor_pos().x), "skipped past the line")
      end)

      ctx:at_tick(3, function()
         local surface = assert(game.get_player(1)).surface
         for _, e in
            ipairs(surface.find_entities_filtered({
               area = { { X, Y - 1 }, { X + 15, Y + 2 } },
               type = { "entity-ghost", "tile-ghost" },
            }))
         do
            e.destroy()
         end
         local tiles = {}
         for x = X, X + 14 do
            for y = Y - 1, Y + 1 do
               table.insert(tiles, { name = "grass-1", position = { x, y } })
            end
         end
         surface.set_tiles(tiles)
      end)
   end)
end)
