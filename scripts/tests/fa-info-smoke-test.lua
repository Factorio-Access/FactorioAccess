--- Smoke test for fa-info system
-- Tests the core entity information extraction functionality

local FaInfo = require("scripts.fa-info")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("FA-Info Smoke Tests", function()
   it("should describe basic entities without crashing", function(ctx)
      local pindex = 1
      local Speech = require("scripts.speech")

      ctx:init(function()
         -- Enable speech capture for testing
         Speech.start_capture()
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
         Speech.clear_captured_messages()
         FaInfo.describe_entity(chest, pindex, false, false)

         -- Should have gotten some output
         ctx:assert(Speech.has_captured_messages(), "Should have received description for chest")

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

         Speech.clear_captured_messages()
         FaInfo.describe_entity(belt, pindex, false, false)

         ctx:assert(Speech.has_captured_messages(), "Should have received description for belt")

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

         Speech.clear_captured_messages()
         FaInfo.describe_entity(assembler, pindex, false, false)

         ctx:assert(Speech.has_captured_messages(), "Should have received description for assembler")

         assembler.destroy()
      end)

      ctx:at_tick(4, function()
         -- Stop capture
         Speech.stop_capture()
      end)
   end)

   it("should handle nil entity gracefully", function(ctx)
      local pindex = 1
      local Speech = require("scripts.speech")

      ctx:init(function()
         -- Enable speech capture for testing
         Speech.start_capture()
      end)

      ctx:at_tick(1, function()
         -- This should not crash
         local success = pcall(function()
            FaInfo.describe_entity(nil, pindex, false, false)
         end)

         ctx:assert(success, "fa-info should handle nil entity without crashing")

         -- Stop capture
         Speech.stop_capture()
      end)
   end)
end)
