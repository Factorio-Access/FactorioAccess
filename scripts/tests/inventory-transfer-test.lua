-- Test for inventory transfer functionality
local TestRegistry = require("scripts.test-registry")
local InventoryTransfers = require("scripts.inventory-transfers")

local describe, it = TestRegistry.describe, TestRegistry.it

describe("Inventory Transfer Tests", function()
   it("should transfer multiple items from building to player", function(ctx)
      local player, surface, chest

      ctx:init(function()
         player = game.get_player(1)
         surface = player.surface

         -- Clear player inventory first
         player.get_main_inventory().clear()

         -- Create a chest with various items
         chest = surface.create_entity({
            name = "iron-chest",
            position = { x = 5, y = 5 },
            force = player.force,
         })

         local chest_inv = chest.get_inventory(defines.inventory.chest)

         -- Add items with different counts to test sorting by count
         chest_inv.insert({ name = "iron-plate", count = 50 })
         chest_inv.insert({ name = "copper-plate", count = 30 })
         chest_inv.insert({ name = "steel-plate", count = 10 })
         chest_inv.insert({ name = "electronic-circuit", count = 20 })
         chest_inv.insert({ name = "advanced-circuit", count = 5 })
      end)

      ctx:at_tick(5, function()
         -- Mock building UI state
         storage.players[1].building = {
            sectors = {
               [1] = {
                  name = "Output",
                  inventory = chest.get_inventory(defines.inventory.chest),
               },
            },
            sector = 1,
            sector_name = "output",
            index = nil, -- Transfer all items
         }

         -- Capture printout to verify it was called without error
         local printout_called = false
         local old_printout = _G.printout
         _G.printout = function(message, pindex)
            printout_called = true
            -- We can't easily check the message content since it's a LocalisedString
            -- but we can verify it was called without error
         end

         -- Do multi-stack transfer (50% ratio to test partial transfers)
         InventoryTransfers.do_multi_stack_transfer(0.5, 1)

         -- Restore printout
         _G.printout = old_printout

         -- Verify printout was called
         assert(printout_called, "Expected printout to be called")

         -- Verify items were transferred (50% of each)
         local player_inv = player.get_main_inventory()
         ctx:assert_equals(15, player_inv.get_item_count("copper-plate"))
         ctx:assert_equals(10, player_inv.get_item_count("electronic-circuit"))
         ctx:assert_equals(25, player_inv.get_item_count("iron-plate"))
         ctx:assert_equals(5, player_inv.get_item_count("steel-plate"))
         ctx:assert_equals(3, player_inv.get_item_count("advanced-circuit"))

         -- Verify remaining items in chest
         local chest_inv = chest.get_inventory(defines.inventory.chest)
         ctx:assert_equals(15, chest_inv.get_item_count("copper-plate"))
         ctx:assert_equals(10, chest_inv.get_item_count("electronic-circuit"))
         ctx:assert_equals(25, chest_inv.get_item_count("iron-plate"))
         ctx:assert_equals(5, chest_inv.get_item_count("steel-plate"))
         ctx:assert_equals(2, chest_inv.get_item_count("advanced-circuit"))
      end)
   end)

   it("should handle empty hand single item transfer", function(ctx)
      local player, surface, chest

      ctx:init(function()
         player = game.get_player(1)
         surface = player.surface

         -- Clear player inventory and hand
         player.get_main_inventory().clear()
         player.cursor_stack.clear()

         -- Create a chest with one item type
         chest = surface.create_entity({
            name = "iron-chest",
            position = { x = 5, y = 5 },
            force = player.force,
         })

         local chest_inv = chest.get_inventory(defines.inventory.chest)
         chest_inv.insert({ name = "iron-plate", count = 100 })
      end)

      ctx:at_tick(5, function()
         -- Mock building UI state with cursor on first slot
         storage.players[1].building = {
            sectors = {
               [1] = {
                  name = "Output",
                  inventory = chest.get_inventory(defines.inventory.chest),
               },
            },
            sector = 1,
            sector_name = "output",
            index = 1, -- Cursor on first slot
         }

         -- Verify hand is empty
         assert(not player.cursor_stack.valid_for_read, "Expected empty hand")

         -- Do transfer
         InventoryTransfers.do_multi_stack_transfer(1.0, 1)

         -- Verify all iron plates were transferred
         local player_inv = player.get_main_inventory()
         ctx:assert_equals(100, player_inv.get_item_count("iron-plate"))

         -- Verify chest is empty
         local chest_inv = chest.get_inventory(defines.inventory.chest)
         ctx:assert_equals(0, chest_inv.get_item_count("iron-plate"))
      end)
   end)
end)
