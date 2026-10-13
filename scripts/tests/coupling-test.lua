local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

local Coupling = require("scripts.rails.coupling")

describe("Train coupling", function()
   it("uncouples and couples the selected car", function(ctx)
      ---@type LuaEntity
      local loco
      ---@type LuaEntity
      local wagon
      ---@type LuaEntity[]
      local rails = {}

      ctx:init(function()
         local player = assert(game.get_player(1))
         local surface = player.surface
         for i = 0, 12 do
            table.insert(
               rails,
               assert(surface.create_entity({
                  name = "straight-rail",
                  position = { x = 61, y = 41 + 2 * i },
                  direction = defines.direction.north,
                  force = player.force,
               }))
            )
         end
         loco = assert(surface.create_entity({
            name = "locomotive",
            position = { x = 61, y = 47 },
            direction = defines.direction.north,
            force = player.force,
         }))
         wagon = assert(surface.create_entity({
            name = "cargo-wagon",
            position = { x = 61, y = 54 },
            direction = defines.direction.north,
            force = player.force,
         }))
      end)

      ctx:at_tick(2, function()
         ctx:assert_equals(2, #loco.train.carriages, "placed coupled")
         game.get_player(1).selected = wagon
         Coupling.uncouple(1)
         ctx:assert_equals(1, #loco.train.carriages, "uncoupled")
         Coupling.couple(1)
         ctx:assert_equals(2, #loco.train.carriages, "coupled again")
      end)

      ctx:at_tick(3, function()
         wagon.destroy()
         loco.destroy()
         for _, r in ipairs(rails) do
            r.destroy()
         end
      end)
   end)
end)
