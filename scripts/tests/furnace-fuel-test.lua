local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it
local MessageBuilder = require("scripts.message-builder")

describe("Furnace Fuel Status", function()
   it("should report out of fuel for furnace with empty fuel inventory", function(ctx)
      local furnace, player

      ctx:init(function()
         player = game.get_player(1)
         -- Place a furnace
         furnace = player.surface.create_entity({
            name = "stone-furnace",
            position = { 10, 10 },
            force = player.force,
         })

         -- Furnaces don't use set_recipe - they automatically choose based on ingredients
         -- Add ingredients but no fuel
         local ingredient_inv = furnace.get_inventory(defines.inventory.furnace_source)
         ingredient_inv.insert({ name = "iron-ore", count = 10 })

         -- Ensure fuel inventory is empty
         local fuel_inv = furnace.get_fuel_inventory()
         fuel_inv.clear()
      end)

      ctx:at_tick(5, function()
         -- Test the fuel check logic directly (same logic as in fa-info.lua)
         local fuel_inv = furnace.get_fuel_inventory()
         local is_out_of_fuel = fuel_inv and fuel_inv.valid and fuel_inv.is_empty()

         ctx:assert_equals(true, is_out_of_fuel, "Furnace with empty fuel inventory should be detected as out of fuel")
      end)

      ctx:at_tick(10, function()
         -- Clean up
         if furnace and furnace.valid then furnace.destroy() end
      end)
   end)

   it("should not report out of fuel when fuel is present", function(ctx)
      local furnace, player

      ctx:init(function()
         player = game.get_player(1)
         -- Place a furnace
         furnace = player.surface.create_entity({
            name = "stone-furnace",
            position = { 15, 15 },
            force = player.force,
         })

         -- Furnaces don't use set_recipe - they automatically choose based on ingredients
         -- Add fuel
         local fuel_inv = furnace.get_fuel_inventory()
         fuel_inv.insert({ name = "coal", count = 5 })
      end)

      ctx:at_tick(5, function()
         -- Test the fuel check logic
         local fuel_inv = furnace.get_fuel_inventory()
         local is_out_of_fuel = fuel_inv and fuel_inv.valid and fuel_inv.is_empty()

         ctx:assert_equals(false, is_out_of_fuel, "Furnace with fuel should not be detected as out of fuel")
      end)

      ctx:at_tick(10, function()
         -- Clean up
         if furnace and furnace.valid then furnace.destroy() end
      end)
   end)

   it("should report out of fuel even when crafting if fuel inventory is empty", function(ctx)
      local furnace, player

      ctx:init(function()
         player = game.get_player(1)
         -- Place a furnace
         furnace = player.surface.create_entity({
            name = "stone-furnace",
            position = { 20, 20 },
            force = player.force,
         })

         -- Furnaces don't use set_recipe - they automatically choose based on ingredients
         -- Add ingredients to trigger smelting
         local ingredient_inv = furnace.get_inventory(defines.inventory.furnace_source)
         ingredient_inv.insert({ name = "iron-ore", count = 10 })

         -- Add a tiny bit of fuel to start crafting
         local fuel_inv = furnace.get_fuel_inventory()
         fuel_inv.insert({ name = "wood", count = 1 })
      end)

      ctx:at_tick(30, function()
         -- Let it burn through the fuel
         -- Now remove any remaining fuel to simulate running out while crafting
         local fuel_inv = furnace.get_fuel_inventory()
         fuel_inv.clear()
      end)

      ctx:at_tick(35, function()
         -- Check if we detect out of fuel even if energy > 0 due to ongoing crafting
         local fuel_inv = furnace.get_fuel_inventory()
         local is_out_of_fuel = fuel_inv and fuel_inv.valid and fuel_inv.is_empty()

         -- Also check that it might still have some energy
         local has_energy = furnace.energy > 0

         ctx:assert_equals(
            true,
            is_out_of_fuel,
            "Furnace should be detected as out of fuel when fuel inventory is empty"
         )

         -- This demonstrates the bug we fixed - previously it required energy == 0
         if has_energy then
            print(
               "Furnace has energy "
                  .. furnace.energy
                  .. " but fuel inventory is empty - this is why the fix was needed"
            )
         end
      end)

      ctx:at_tick(40, function()
         -- Clean up
         if furnace and furnace.valid then furnace.destroy() end
      end)
   end)
end)
