--- Smoke test for fa-info system
-- Tests the core entity information extraction functionality

local fa_info = require("scripts.fa-info")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("FA-Info Smoke Tests", function()
   it("should describe basic entities without crashing", function(ctx)
      local pindex = 1
      local messages = {}
      local original_printout = _G.printout

      ctx:init(function()
         -- Mock printout to capture fa-info output
         _G.printout = function(message, player_index)
            if player_index == pindex then table.insert(messages, message) end
         end
      end)

      ctx:at_tick(1, function()
         local surface = game.surfaces["nauvis"]

         -- Test 1: Describe a chest
         local chest = surface.create_entity({
            name = "wooden-chest",
            position = { 5, 5 },
            force = "player",
         })
         ctx:assert(chest and chest.valid, "Chest should be created")

         -- Clear messages and describe the chest
         messages = {}
         fa_info.describe_entity(chest, pindex, false, false)

         -- Should have gotten some output
         ctx:assert(#messages > 0, "Should have received description for chest")

         -- Clean up
         chest.destroy()
      end)

      ctx:at_tick(2, function()
         local surface = game.surfaces["nauvis"]

         -- Test 2: Describe a belt
         local belt = surface.create_entity({
            name = "transport-belt",
            position = { 10, 10 },
            direction = defines.direction.east,
            force = "player",
         })
         ctx:assert(belt and belt.valid, "Belt should be created")

         messages = {}
         fa_info.describe_entity(belt, pindex, false, false)

         ctx:assert(#messages > 0, "Should have received description for belt")

         belt.destroy()
      end)

      ctx:at_tick(3, function()
         local surface = game.surfaces["nauvis"]

         -- Test 3: Describe an assembler
         local assembler = surface.create_entity({
            name = "assembling-machine-1",
            position = { 15, 15 },
            force = "player",
         })
         ctx:assert(assembler and assembler.valid, "Assembler should be created")

         messages = {}
         fa_info.describe_entity(assembler, pindex, false, false)

         ctx:assert(#messages > 0, "Should have received description for assembler")

         assembler.destroy()
      end)

      ctx:at_tick(4, function()
         -- Restore original printout
         _G.printout = original_printout
      end)
   end)

   it("should handle nil entity gracefully", function(ctx)
      local pindex = 1
      local original_printout = _G.printout
      local error_occurred = false

      ctx:init(function()
         -- Mock printout to detect errors
         _G.printout = function(message, player_index)
            -- fa-info might output an error message for nil entity
         end
      end)

      ctx:at_tick(1, function()
         -- This should not crash
         local success = pcall(function()
            fa_info.describe_entity(nil, pindex, false, false)
         end)

         ctx:assert(success, "fa-info should handle nil entity without crashing")

         -- Restore
         _G.printout = original_printout
      end)
   end)
end)
