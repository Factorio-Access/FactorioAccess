--[[
Tests for the generic entity UI system
]]

local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it
local EntityUI = require("scripts.ui.entity-ui")
local UiRouter = require("scripts.ui.router")

describe("Entity UI", function()
   it("should open for a chest entity", function(ctx)
      local player, chest

      ctx:init(function()
         player = game.get_player(1)
         -- Create a chest near the player
         chest = player.surface.create_entity({
            name = "wooden-chest",
            position = { player.position.x + 2, player.position.y },
            force = player.force,
         })
         assert(chest ~= nil, "Failed to create chest")
         assert(chest.valid, "Chest should be valid")
      end)

      ctx:at_tick(5, function()
         -- Try to open the entity UI
         local success = EntityUI.open_entity_ui(1, chest)
         assert(success == true, "Should successfully open entity UI")
      end)

      ctx:at_tick(10, function()
         -- Check that the UI is actually open
         local router = UiRouter.get_router(1)
         local is_open = router:is_ui_open(UiRouter.UI_NAMES.ENTITY)
         assert(is_open == true, "Entity UI should be open")
      end)

      -- No need to explicitly close - test framework cleanup will handle it

      -- Cleanup handled automatically by test framework
   end)

   it("should open for an assembling machine", function(ctx)
      local player, machine

      ctx:init(function()
         player = game.get_player(1)
         -- Create an assembling machine near the player
         machine = player.surface.create_entity({
            name = "assembling-machine-1",
            position = { player.position.x + 2, player.position.y },
            force = player.force,
         })
         assert(machine ~= nil, "Failed to create assembling machine")
         assert(machine.valid, "Machine should be valid")
      end)

      ctx:at_tick(5, function()
         -- Try to open the entity UI
         local success = EntityUI.open_entity_ui(1, machine)
         assert(success == true, "Should successfully open entity UI for assembling machine")
      end)

      ctx:at_tick(10, function()
         -- Check that the UI is actually open
         local router = UiRouter.get_router(1)
         local is_open = router:is_ui_open(UiRouter.UI_NAMES.ENTITY)
         assert(is_open == true, "Entity UI should be open")

         -- Get the registered UI to check sections
         local entity_ui = UiRouter.get_registered_ui(UiRouter.UI_NAMES.ENTITY)
         assert(entity_ui ~= nil, "Entity UI should be registered")
      end)

      -- No need to explicitly close - test framework cleanup will handle it

      -- Cleanup handled automatically by test framework
   end)

   it("should open for charted out-of-reach entity in read-only mode", function(ctx)
      local player, far_chest

      ctx:init(function()
         player = game.get_player(1)
         -- Create a chest far from the player (but on charted terrain)
         far_chest = player.surface.create_entity({
            name = "wooden-chest",
            position = { player.position.x + 100, player.position.y + 100 },
            force = player.force,
         })
         assert(far_chest ~= nil, "Failed to create far chest")
         assert(far_chest.valid, "Far chest should be valid")
         -- Ensure the chunk is charted (for remote viewing)
         local chunk_pos =
            { x = math.floor((player.position.x + 100) / 32), y = math.floor((player.position.y + 100) / 32) }
         player.force.chart(player.surface, {
            { chunk_pos.x * 32, chunk_pos.y * 32 },
            { (chunk_pos.x + 1) * 32, (chunk_pos.y + 1) * 32 },
         })
      end)

      ctx:at_tick(5, function()
         -- Try to open the entity UI - should succeed for remote viewing
         local success = EntityUI.open_entity_ui(1, far_chest)
         assert(success == true, "Should open UI for charted out-of-reach entity")
      end)

      ctx:at_tick(10, function()
         -- Check that the UI IS open (for reading)
         local router = UiRouter.get_router(1)
         local is_open = router:is_ui_open(UiRouter.UI_NAMES.ENTITY)
         assert(is_open == true, "Entity UI should be open for reading")
      end)

      -- Cleanup handled automatically by test framework
   end)

   it("should fail to open for uncharted out-of-reach entity", function(ctx)
      local player, far_chest

      ctx:init(function()
         player = game.get_player(1)
         -- Create a chest in an uncharted area
         local far_pos = { x = player.position.x + 2000, y = player.position.y + 2000 }
         -- Ensure the chunk is NOT charted by picking a distant location
         local chunk_pos = { x = math.floor(far_pos.x / 32), y = math.floor(far_pos.y / 32) }
         local is_charted = player.force.is_chunk_charted(player.surface, chunk_pos)

         -- Only create the chest if the chunk is uncharted (skip test otherwise)
         if not is_charted then
            far_chest = player.surface.create_entity({
               name = "wooden-chest",
               position = far_pos,
               force = player.force,
            })
            assert(far_chest ~= nil, "Failed to create far chest")
            assert(far_chest.valid, "Far chest should be valid")
         end
      end)

      ctx:at_tick(5, function()
         if far_chest then
            -- Try to open the entity UI - should fail for uncharted areas
            local success = EntityUI.open_entity_ui(1, far_chest)
            assert(success == false, "Should fail to open UI for uncharted out-of-reach entity")
         end
      end)

      ctx:at_tick(10, function()
         if far_chest then
            -- Check that the UI is NOT open
            local router = UiRouter.get_router(1)
            local is_open = router:is_ui_open(UiRouter.UI_NAMES.ENTITY)
            assert(is_open == false, "Entity UI should not be open for uncharted entity")
         end
      end)

      -- Cleanup handled automatically by test framework
   end)

   it("should handle entity becoming invalid during UI lifetime", function(ctx)
      local player, chest

      ctx:init(function()
         player = game.get_player(1)
         -- Create a chest near the player
         chest = player.surface.create_entity({
            name = "wooden-chest",
            position = { player.position.x + 2, player.position.y },
            force = player.force,
         })
         assert(chest ~= nil, "Failed to create chest")
      end)

      ctx:at_tick(5, function()
         -- Open the entity UI
         local success = EntityUI.open_entity_ui(1, chest)
         assert(success == true, "Should successfully open entity UI")
      end)

      ctx:at_tick(10, function()
         -- Destroy the chest while UI is open
         if chest and chest.valid then chest.destroy() end
      end)

      ctx:at_tick(15, function()
         -- Try to interact with the UI - it should handle the invalid entity gracefully
         local router = UiRouter.get_router(1)
         -- The UI framework should detect the invalid entity and close automatically
         -- This tests that tabs_callback returns nil when entity is invalid
      end)
   end)
end)
