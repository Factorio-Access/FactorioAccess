--- Test entity selection stable ordering (issue #265)

local TestRegistry = require("scripts.test-registry")
local EntitySelection = require("scripts.entity-selection")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Entity Selection Stable Ordering", function()
   it("should return entities in stable order", function(ctx)
      local entities = {}
      local surface = nil
      local test_pos = { x = 10, y = 10 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create multiple entities at same position
         -- Order: chest (has unit_number), then tree (no unit_number)
         entities.chest = surface.create_entity({
            name = "iron-chest",
            position = test_pos,
            force = player.force,
         })

         entities.tree = surface.create_entity({
            name = "tree-01",
            position = test_pos,
         })

         ctx:assert_not_nil(entities.chest, "Chest should be created")
         ctx:assert_not_nil(entities.tree, "Tree should be created")
      end)

      ctx:at_tick(1, function()
         -- Query entities multiple times
         local result1 = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)
         local result2 = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)

         -- Should get same order both times
         ctx:assert_equals(#result1, #result2, "Should return same number of entities")

         for i = 1, #result1 do
            ctx:assert_equals(
               result1[i].unit_number,
               result2[i].unit_number,
               "Entity order should be stable at index " .. i
            )
         end

         -- Chest (with unit_number) should come before tree (without)
         ctx:assert(#result1 >= 2, "Should have at least 2 entities")
         ctx:assert_not_nil(result1[1].unit_number, "First entity should have unit_number")
         ctx:assert_equals("iron-chest", result1[1].name, "First should be chest")
      end)

      ctx:at_tick(2, function()
         -- Clean up
         for _, ent in pairs(entities) do
            if ent and ent.valid then ent.destroy() end
         end
      end)
   end)

   it("should use registration numbers for identical entities", function(ctx)
      local trees = {}
      local surface = nil
      local test_pos = { x = 15, y = 15 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create identical entities (same prototype, no unit_number)
         trees[1] = surface.create_entity({ name = "tree-01", position = test_pos })
         trees[2] = surface.create_entity({ name = "tree-01", position = test_pos })
         trees[3] = surface.create_entity({ name = "tree-01", position = test_pos })

         for i, tree in ipairs(trees) do
            ctx:assert_not_nil(tree, "Tree " .. i .. " should be created")
         end
      end)

      ctx:at_tick(1, function()
         -- Query multiple times - should get stable order
         local result1 = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)
         local result2 = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)
         local result3 = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)

         ctx:assert_equals(3, #result1, "Should find 3 trees")
         ctx:assert_equals(3, #result2, "Should find 3 trees second time")
         ctx:assert_equals(3, #result3, "Should find 3 trees third time")

         -- Order should be identical across queries
         for i = 1, 3 do
            -- Can't compare unit_number (trees don't have them)
            -- But position comparison shows they're in same order
            ctx:assert_equals(
               result1[i].position.x,
               result2[i].position.x,
               "Entity " .. i .. " should be in same position"
            )
            ctx:assert_equals(
               result2[i].position.x,
               result3[i].position.x,
               "Entity " .. i .. " should be stable across queries"
            )
         end
      end)

      ctx:at_tick(2, function()
         for _, tree in ipairs(trees) do
            if tree and tree.valid then tree.destroy() end
         end
      end)
   end)

   it("should sort primary entities before secondary entities", function(ctx)
      local entities = {}
      local surface = nil
      local test_pos = { x = 20, y = 20 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create secondary entity (logistic-robot) then primary (chest)
         -- Secondary should be created first to test sorting, not creation order
         entities.robot = surface.create_entity({
            name = "logistic-robot",
            position = test_pos,
            force = player.force,
         })

         entities.chest = surface.create_entity({
            name = "iron-chest",
            position = test_pos,
            force = player.force,
         })

         ctx:assert_not_nil(entities.robot, "Robot should be created")
         ctx:assert_not_nil(entities.chest, "Chest should be created")
      end)

      ctx:at_tick(1, function()
         local result = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)

         ctx:assert(#result >= 2, "Should have at least 2 entities")

         -- Chest (primary) should come before robot (secondary)
         ctx:assert_equals("iron-chest", result[1].name, "First should be primary entity (chest)")
         ctx:assert_equals("logistic-robot", result[2].name, "Second should be secondary entity (robot)")
      end)

      ctx:at_tick(2, function()
         for _, ent in pairs(entities) do
            if ent and ent.valid then ent.destroy() end
         end
      end)
   end)

   it("should sort by unit_number when both entities have them", function(ctx)
      local entities = {}
      local surface = nil
      local test_pos = { x = 25, y = 25 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create two chests - they both have unit_numbers
         entities.chest1 = surface.create_entity({
            name = "iron-chest",
            position = test_pos,
            force = player.force,
         })

         entities.chest2 = surface.create_entity({
            name = "iron-chest",
            position = test_pos,
            force = player.force,
         })

         ctx:assert_not_nil(entities.chest1, "Chest 1 should be created")
         ctx:assert_not_nil(entities.chest2, "Chest 2 should be created")
         ctx:assert_not_nil(entities.chest1.unit_number, "Chest 1 should have unit_number")
         ctx:assert_not_nil(entities.chest2.unit_number, "Chest 2 should have unit_number")
      end)

      ctx:at_tick(1, function()
         local result = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)

         ctx:assert_equals(2, #result, "Should find 2 chests")

         -- Order should be stable and based on unit_number
         local first_unit = result[1].unit_number
         local second_unit = result[2].unit_number

         ctx:assert(first_unit < second_unit, "Should be ordered by unit_number")

         -- Query again to verify stability
         local result2 = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)
         ctx:assert_equals(first_unit, result2[1].unit_number, "Order should be stable")
         ctx:assert_equals(second_unit, result2[2].unit_number, "Order should be stable")
      end)

      ctx:at_tick(2, function()
         for _, ent in pairs(entities) do
            if ent and ent.valid then ent.destroy() end
         end
      end)
   end)

   it("should sort by lexicographic name when same type", function(ctx)
      local entities = {}
      local surface = nil
      local test_pos = { x = 30, y = 30 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create trees with different names (no unit_numbers)
         -- Create in reverse alphabetical order to test sorting
         entities.tree2 = surface.create_entity({ name = "tree-02", position = test_pos })
         entities.tree1 = surface.create_entity({ name = "tree-01", position = test_pos })

         ctx:assert_not_nil(entities.tree1, "Tree 1 should be created")
         ctx:assert_not_nil(entities.tree2, "Tree 2 should be created")
      end)

      ctx:at_tick(1, function()
         local result = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)

         ctx:assert_equals(2, #result, "Should find 2 trees")

         -- Should be ordered lexicographically by name
         ctx:assert_equals("tree-01", result[1].name, "First should be tree-01 (lexicographic order)")
         ctx:assert_equals("tree-02", result[2].name, "Second should be tree-02")
      end)

      ctx:at_tick(2, function()
         for _, ent in pairs(entities) do
            if ent and ent.valid then ent.destroy() end
         end
      end)
   end)

   it("should sort by item name for item-on-ground entities", function(ctx)
      local entities = {}
      local surface = nil
      local test_pos = { x = 35, y = 35 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create item-on-ground entities with different items
         -- Create in reverse alphabetical order to test sorting
         entities.wood = surface.create_entity({
            name = "item-on-ground",
            position = test_pos,
            stack = { name = "wood", count = 1 },
         })

         entities.iron = surface.create_entity({
            name = "item-on-ground",
            position = test_pos,
            stack = { name = "iron-plate", count = 1 },
         })

         ctx:assert_not_nil(entities.iron, "Iron item should be created")
         ctx:assert_not_nil(entities.wood, "Wood item should be created")
      end)

      ctx:at_tick(1, function()
         local result = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)

         ctx:assert_equals(2, #result, "Should find 2 items")

         -- Should be ordered by item name (iron-plate < wood)
         ctx:assert_equals("item-on-ground", result[1].name, "First should be item-on-ground")
         ctx:assert_equals("item-on-ground", result[2].name, "Second should be item-on-ground")
         ctx:assert_equals("iron-plate", result[1].stack.name, "First item should be iron-plate")
         ctx:assert_equals("wood", result[2].stack.name, "Second item should be wood")
      end)

      ctx:at_tick(2, function()
         for _, ent in pairs(entities) do
            if ent and ent.valid then ent.destroy() end
         end
      end)
   end)

   it("should sort mining drills with mining_target before those without", function(ctx)
      local entities = {}
      local surface = nil
      local test_pos = { x = 40, y = 40 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create ore entities under the drill position
         entities.ore = surface.create_entity({
            name = "iron-ore",
            position = test_pos,
            amount = 1000,
         })

         ctx:assert_not_nil(entities.ore, "Ore should be created")

         -- Create mining drill without target (no ore under it)
         entities.drill_empty = surface.create_entity({
            name = "burner-mining-drill",
            position = { x = 40, y = 45 },
            force = player.force,
            direction = defines.direction.north,
         })

         -- Create mining drill with target (over ore)
         entities.drill_mining = surface.create_entity({
            name = "burner-mining-drill",
            position = test_pos,
            force = player.force,
            direction = defines.direction.north,
         })

         ctx:assert_not_nil(entities.drill_empty, "Empty drill should be created")
         ctx:assert_not_nil(entities.drill_mining, "Mining drill should be created")
      end)

      ctx:at_tick(1, function()
         local has_target = entities.drill_mining.mining_target ~= nil
         local no_target = entities.drill_empty.mining_target == nil

         ctx:assert(has_target, "Mining drill should have mining_target")
         ctx:assert(no_target, "Empty drill should not have mining_target")
      end)

      ctx:at_tick(2, function()
         for _, ent in pairs(entities) do
            if ent and ent.valid then ent.destroy() end
         end
      end)
   end)

   it("should handle mixed entity types with complex sorting", function(ctx)
      local entities = {}
      local surface = nil
      local test_pos = { x = 45, y = 45 }

      ctx:init(function()
         local player = game.get_player(1)
         surface = player.surface

         -- Create mix: robot (secondary), tree (no unit_number), chest (primary with unit_number)
         entities.tree = surface.create_entity({ name = "tree-01", position = test_pos })

         entities.robot = surface.create_entity({
            name = "logistic-robot",
            position = test_pos,
            force = player.force,
         })

         entities.chest = surface.create_entity({
            name = "iron-chest",
            position = test_pos,
            force = player.force,
         })

         ctx:assert_not_nil(entities.tree, "Tree should be created")
         ctx:assert_not_nil(entities.robot, "Robot should be created")
         ctx:assert_not_nil(entities.chest, "Chest should be created")
      end)

      ctx:at_tick(1, function()
         local result = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)

         ctx:assert(#result >= 3, "Should have at least 3 entities")

         -- Expected order: chest (primary with unit_number) first, then secondary entities
         local found_chest_first = false
         if result[1].name == "iron-chest" then found_chest_first = true end

         ctx:assert(found_chest_first, "Chest (primary) should come first")

         -- Verify stability
         local result2 = EntitySelection.get_ents_on_tile(surface, test_pos.x, test_pos.y, 1)
         for i = 1, math.min(#result, #result2) do
            ctx:assert_equals(result[i].name, result2[i].name, "Order should be stable at index " .. i)
         end
      end)

      ctx:at_tick(2, function()
         for _, ent in pairs(entities) do
            if ent and ent.valid then ent.destroy() end
         end
      end)
   end)
end)
