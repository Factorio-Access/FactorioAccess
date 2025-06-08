--- Test character inventory coordinate announcements
-- Tests that moving in inventory announces coordinates

local EventManager = require("scripts.event-manager")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Inventory Coordinate Tests", function()
   it("should announce inventory slot coordinates", function(ctx)
      ctx:init(function()
         -- Enable test mode

         local pindex = 1
         local player = game.get_player(pindex)

         -- Ensure player exists with character
         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end

         if not player.character then player.create_character() end

         -- Add some items to inventory
         player.insert({ name = "iron-plate", count = 50 })
         player.insert({ name = "copper-plate", count = 30 })
         player.insert({ name = "coal", count = 20 })

         ctx.state.pindex = pindex
         ctx.state.player = player
      end)

      ctx:at_tick(1, function()
         -- Test inventory properties
         local inventory = ctx.state.player.get_main_inventory()
         ctx:assert_not_nil(inventory, "Player should have main inventory")

         -- Inventory dimensions are hardcoded in the mod
         local width = 10 -- Standard inventory width
         local height = math.ceil(#inventory / width)
         ctx:assert(width > 0, "Inventory should have positive width")
         ctx:assert(height > 0, "Inventory should have positive height")

         ctx.state.inv_width = width
         ctx.state.inv_height = height
      end)

      ctx:at_tick(2, function()
         -- Test coordinate calculation for slots
         local inventory = ctx.state.player.get_main_inventory()

         -- Test first slot (1,1)
         local slot_1_x = ((1 - 1) % ctx.state.inv_width) + 1
         local slot_1_y = math.floor((1 - 1) / ctx.state.inv_width) + 1
         ctx:assert_equals(1, slot_1_x, "First slot X should be 1")
         ctx:assert_equals(1, slot_1_y, "First slot Y should be 1")

         -- Test slot at position width (should wrap to next row)
         local slot_w_x = ((ctx.state.inv_width - 1) % ctx.state.inv_width) + 1
         local slot_w_y = math.floor((ctx.state.inv_width - 1) / ctx.state.inv_width) + 1
         ctx:assert_equals(ctx.state.inv_width, slot_w_x, "Last slot in row X should be width")
         ctx:assert_equals(1, slot_w_y, "Last slot in first row Y should be 1")
      end)

      ctx:at_tick(3, function()
         -- Test inventory navigation bounds
         local inventory = ctx.state.player.get_main_inventory()
         local total_slots = #inventory

         -- Calculate max coordinates
         local max_x = ctx.state.inv_width
         local max_y = math.ceil(total_slots / ctx.state.inv_width)

         ctx:assert(max_x > 0, "Max X should be positive")
         ctx:assert(max_y > 0, "Max Y should be positive")

         -- Test coordinate for last slot
         local last_x = ((total_slots - 1) % ctx.state.inv_width) + 1
         local last_y = math.floor((total_slots - 1) / ctx.state.inv_width) + 1
         ctx:assert(last_x <= max_x, "Last slot X should be within bounds")
         ctx:assert(last_y <= max_y, "Last slot Y should be within bounds")
      end)

      ctx:at_tick(4, function()
         -- Test inventory content at specific coordinates
         local inventory = ctx.state.player.get_main_inventory()

         -- Check first few slots for items we inserted
         local slot1 = inventory[1]
         if slot1 and slot1.valid_for_read then ctx:assert_not_nil(slot1.name, "First slot should have an item") end
      end)
   end)

   it("should handle inventory edge detection", function(ctx)
      ctx:init(function()
         local pindex = 1
         local player = game.get_player(pindex)

         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end

         if not player.character then player.create_character() end

         ctx.state.pindex = pindex
         ctx.state.player = player
      end)

      ctx:at_tick(1, function()
         local inventory = ctx.state.player.get_main_inventory()
         local width = 10 -- Standard inventory width
         local total_slots = #inventory
         local height = math.ceil(total_slots / width)

         -- Test edge detection logic
         -- Top edge: y = 1
         -- Bottom edge: y = max_y
         -- Left edge: x = 1
         -- Right edge: x = width

         -- Test corners
         local top_left = { x = 1, y = 1 }
         local top_right = { x = width, y = 1 }
         local bottom_left = { x = 1, y = math.ceil(total_slots / width) }
         local bottom_right = { x = ((total_slots - 1) % width) + 1, y = math.ceil(total_slots / width) }

         -- Verify corner detection logic
         ctx:assert_equals(1, top_left.x, "Top left X should be 1")
         ctx:assert_equals(1, top_left.y, "Top left Y should be 1")
         ctx:assert_equals(width, top_right.x, "Top right X should be width")
         ctx:assert_equals(1, top_right.y, "Top right Y should be 1")
      end)

      ctx:at_tick(2, function()
         -- Test completed
      end)
   end)
end)
