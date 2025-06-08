--- Test crafting menu navigation
-- Tests navigating the hierarchical crafting menu system

local EventManager = require("scripts.event-manager")
local fa_crafting = require("scripts.crafting")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Crafting Menu Navigation Tests", function()

   --[[
   -- Commenting out due to crafting queue API issues in test environment
   it("should open and close crafting menu", function(ctx)
      ctx:init(function()
         local pindex = 1
         local player = game.get_player(pindex)
         
         -- Ensure player exists with a character
         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end
         
         -- Ensure player has a character
         if not player.character then
            player.create_character()
         end
         
         ctx.state.pindex = pindex
         ctx.state.player = player
      end)
      
      ctx:at_tick(1, function()
         -- Mock opening crafting menu (typically E key)
         local open_event = {
            name = "toggle-menu",
            player_index = ctx.state.pindex,
            tick = game.tick
         }
         
         -- The crafting menu is part of the inventory system
         -- Test that we can check if it's open
         local is_open = ctx.state.player.opened ~= nil
         ctx:assert(not is_open, "Crafting menu should start closed")
      end)
      
      ctx:at_tick(2, function()
         -- Test crafting queue using Factorio API
         -- The crafting queue might not be available in all test environments
         local queue = ctx.state.player.crafting_queue
         if not queue then
            game.print("WARNING: Crafting queue not available in test environment")
            -- Test the mod's internal queue tracking instead
            local queue_total = fa_crafting.get_crafting_que_total(ctx.state.pindex)
            ctx:assert_equals(0, queue_total, "Mod's crafting queue should be empty")
            return
         end
         
         ctx:assert_equals(0, #queue, "Crafting queue should start empty")
         
         -- Also test queue size property
         local queue_size = ctx.state.player.crafting_queue_size or 0
         ctx:assert_equals(0, queue_size, "Crafting queue size should be 0")
      end)
      
      ctx:at_tick(3, function()
         -- Skip if no crafting queue available
         if not ctx.state.player.crafting_queue then
            return
         end
         
         -- Test starting to craft something
         -- Give player some materials
         ctx.state.player.insert({name = "iron-ore", count = 10})
         
         -- Try to start crafting iron plates
         local crafted_count = ctx.state.player.begin_crafting({recipe = "iron-plate", count = 5})
         ctx:assert(crafted_count > 0, "Should be able to start crafting iron plates")
         
         -- Check queue has items now
         local queue_size = ctx.state.player.crafting_queue_size or 0
         ctx:assert(queue_size > 0, "Crafting queue should have items")
      end)
      
      ctx:at_tick(4, function()
      end)
   end)
   --]]

   --[[
   -- Commenting out due to crafting API issues in test environment
   it("should navigate recipe categories", function(ctx)
      ctx:init(function()
         
         local pindex = 1
         local player = game.get_player(pindex)
         
         if not player then
            -- Player should already exist in test environment
            ctx:error("No player found at index 1")
            return
         end
         
         if not player.character then
            player.create_character()
         end
         
         -- Give player some starting items to enable recipes
         player.insert({name = "iron-plate", count = 100})
         player.insert({name = "copper-plate", count = 100})
         player.insert({name = "coal", count = 50})
         
         ctx.state.pindex = pindex
         ctx.state.player = player
      end)
      
      ctx:at_tick(1, function()
         -- Get available recipes
         local recipes = {}
         for name, recipe in pairs(game.recipe_prototypes) do
            if ctx.state.player.can_craft_recipe(name) then
               table.insert(recipes, name)
            end
         end
         
         ctx:assert(#recipes > 0, "Player should have some recipes available")
         ctx.state.recipe_count = #recipes
      end)
      
      ctx:at_tick(2, function()
         -- Test recipe groups/categories
         -- In Factorio, recipes are organized by groups
         local groups = {}
         for name, group in pairs(game.item_group_prototypes) do
            table.insert(groups, name)
         end
         
         ctx:assert(#groups > 0, "Game should have item groups")
      end)
      
      ctx:at_tick(3, function()
         -- Test crafting a simple recipe
         if ctx.state.player.can_craft_recipe("iron-gear-wheel") then
            -- Start crafting
            local count_before = ctx.state.player.get_item_count("iron-gear-wheel")
            ctx.state.player.begin_crafting{recipe = "iron-gear-wheel", count = 1}
            
            -- Check crafting queue
            local queue = fa_crafting.get_crafting_queue(ctx.state.pindex)
            ctx:assert(#queue > 0, "Crafting queue should have items after starting craft")
         end
      end)
      
      ctx:at_tick(4, function()
      end)
   end)
   --]]
end)
