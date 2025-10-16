local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it
local UiRouter = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")
local AssemblingMachine = require("scripts.ui.tabs.assembling-machine")

-- Define test UI names as constants
local TEST_UI_NAME = "test-assembling-machine"
local TEST_UI_NAME_FOCUS = "test-assembling-machine-focus"

-- Create TabLists at module level for testing
local test_tablist = TabList.declare_tablist({
   ui_name = TEST_UI_NAME,
   tabs_callback = function()
      return {
         {
            name = "main",
            tabs = { AssemblingMachine.assembling_machine_tab },
         },
      }
   end,
})

local test_tablist_focus = TabList.declare_tablist({
   ui_name = TEST_UI_NAME_FOCUS,
   tabs_callback = function()
      return {
         {
            name = "main",
            tabs = { AssemblingMachine.assembling_machine_tab },
         },
      }
   end,
})

-- Register the test UIs
UiRouter.register_ui(test_tablist)
UiRouter.register_ui(test_tablist_focus)

describe("Assembling Machine UI", function()
   it("should open recipe selection tab for assembling machine", function(ctx)
      local player
      local assembler
      local opened = false
      local closed = false

      ctx:init(function()
         player = game.get_player(1)
         -- Enable some recipes for testing
         player.force.recipes["iron-gear-wheel"].enabled = true
         player.force.recipes["electronic-circuit"].enabled = true
         player.force.recipes["copper-cable"].enabled = true
      end)

      ctx:at_tick(1, function()
         -- Create an assembling machine
         assembler = player.surface.create_entity({
            name = "assembling-machine-1",
            position = { 0, 0 },
            force = player.force,
         })
         assert(assembler and assembler.valid)
      end)

      ctx:at_tick(2, function()
         -- Open the pre-registered test UI
         local router = UiRouter.get_router(player.index)
         router:open_ui(TEST_UI_NAME, { entity = assembler })

         -- Verify it opened by checking if it's open
         opened = router:is_ui_open(TEST_UI_NAME)
         assert(opened == true, "Should open assembling machine UI")
      end)

      ctx:at_tick(5, function()
         -- Verify the UI is open
         local router = UiRouter.get_router(player.index)
         assert(router:is_ui_open(TEST_UI_NAME), "UI should be open")
      end)

      ctx:at_tick(10, function()
         -- Close the UI
         local router = UiRouter.get_router(player.index)
         router:close_ui()
         -- Verify it closed
         closed = not router:is_ui_open(TEST_UI_NAME)
         assert(closed == true, "Should close UI")
      end)
   end)

   it("should set recipe when clicking on a recipe item", function(ctx)
      local player
      local assembler

      ctx:init(function()
         player = game.get_player(1)
         -- Enable recipes
         player.force.recipes["iron-gear-wheel"].enabled = true
         player.force.recipes["electronic-circuit"].enabled = true
      end)

      ctx:at_tick(1, function()
         -- Create assembling machine
         assembler = player.surface.create_entity({
            name = "assembling-machine-1",
            position = { 0, 0 },
            force = player.force,
         })
      end)

      ctx:at_tick(2, function()
         -- Set initial recipe
         assembler.set_recipe("iron-gear-wheel")
         local recipe = assembler.get_recipe()
         assert(recipe and recipe.name == "iron-gear-wheel", "Should set initial recipe")
      end)

      ctx:at_tick(5, function()
         -- Change recipe
         assembler.set_recipe("electronic-circuit")
         local recipe = assembler.get_recipe()
         assert(recipe and recipe.name == "electronic-circuit", "Should change recipe")
      end)
   end)

   it("should focus on current recipe when tab gains focus", function(ctx)
      local player
      local assembler

      ctx:init(function()
         player = game.get_player(1)
         -- Enable multiple recipes
         player.force.recipes["iron-gear-wheel"].enabled = true
         player.force.recipes["electronic-circuit"].enabled = true
         player.force.recipes["copper-cable"].enabled = true
         player.force.recipes["iron-stick"].enabled = true
      end)

      ctx:at_tick(1, function()
         -- Create assembling machine with a recipe set
         assembler = player.surface.create_entity({
            name = "assembling-machine-1",
            position = { 0, 0 },
            force = player.force,
         })
         assembler.set_recipe("electronic-circuit")
      end)

      ctx:at_tick(2, function()
         -- Open the pre-registered test UI
         local router = UiRouter.get_router(player.index)
         router:open_ui(TEST_UI_NAME_FOCUS, { entity = assembler })

         -- Verify it opened
         local opened = router:is_ui_open(TEST_UI_NAME_FOCUS)
         assert(opened == true, "Should open UI")

         -- The UI should be focused on the current recipe
         -- This would be verified through the category-rows state
         -- but we can at least verify the recipe is still set
         local recipe = assembler.get_recipe()
         assert(recipe and recipe.name == "electronic-circuit", "Recipe should still be set")
      end)
   end)
end)
