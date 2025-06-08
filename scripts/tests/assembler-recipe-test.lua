--- Test assembling machine recipe management
-- Tests mod's recipe listing and handling functions

local EventManager = require("scripts.event-manager")
local fa_crafting = require("scripts.crafting")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Assembler Recipe Mod Tests", function()
   it("should list available recipes for assembler", function(ctx)
      -- Local variables for the test
      local pindex = 1
      local player
      local surface
      local assembler

      ctx:init(function()
         -- Use the common test setup helper
         player, surface = ctx:setup_test_area(pindex)
         if not player then return end

         -- Unlock some recipes
         player.force.recipes["iron-gear-wheel"].enabled = true
         player.force.recipes["electronic-circuit"].enabled = true
         player.force.recipes["copper-cable"].enabled = true
      end)

      ctx:at_tick(1, function()
         -- Create an assembler
         assembler = surface.create_entity({
            name = "assembling-machine-1",
            position = { x = 0, y = -3 },
            force = player.force,
         })
      end)

      ctx:at_tick(2, function()
         -- Test the mod's get_recipes function
         local recipes = fa_crafting.get_recipes(pindex, assembler, false)

         -- Should return a table of recipe groups
         ctx:assert_not_nil(recipes, "Should return recipes")
         ctx:assert(type(recipes) == "table", "Recipes should be a table")
         ctx:assert(#recipes > 0, "Should have at least one recipe group")

         -- Check structure - should be groups of recipes
         local first_group = recipes[1]
         ctx:assert(type(first_group) == "table", "First group should be a table")
         ctx:assert(#first_group > 0, "First group should have recipes")

         -- Count total recipes
         local total_recipes = 0
         for _, group in ipairs(recipes) do
            total_recipes = total_recipes + #group
         end
         ctx:assert(total_recipes >= 3, "Should have at least the 3 unlocked recipes")
      end)

      ctx:at_tick(3, function()
         -- Test loading all categories
         local all_recipes = fa_crafting.get_recipes(pindex, assembler, true)

         -- When loading all categories, we should get more recipes
         ctx:assert(#all_recipes > 0, "Should have recipes when loading all categories")

         -- Count recipes in all mode
         local all_total = 0
         for _, group in ipairs(all_recipes) do
            all_total = all_total + #group
         end

         -- Compare with limited mode
         local limited_recipes = fa_crafting.get_recipes(pindex, assembler, false)
         local limited_total = 0
         for _, group in ipairs(limited_recipes) do
            limited_total = limited_total + #group
         end

         -- All categories mode should have at least as many (usually more)
         ctx:assert(all_total >= limited_total, "All categories should have at least as many recipes")
      end)
   end)
end)
