local TestRegistry = require("scripts.test-registry")
local TravelTools = require("scripts.travel-tools")
local convert = require("scripts.migration-steps.fast-travel-surfaces-and-categories")
local describe, it = TestRegistry.describe, TestRegistry.it

---@param pindex integer
---@param surface_index integer
---@param filter fa.travel.Filter
---@return string
local function labels(pindex, surface_index, filter)
   local out = {}
   for _, p in ipairs(TravelTools.points(pindex, surface_index, filter)) do
      table.insert(out, p.label)
   end
   return table.concat(out, ",")
end

---@param pindex integer
local function clear(pindex)
   for _, surface in ipairs(TravelTools.surfaces(pindex)) do
      for _, p in ipairs(TravelTools.points(pindex, surface.index, "all")) do
         TravelTools.delete_point(pindex, p.id)
      end
   end
end

describe("Fast travel", function()
   it("converts the old storage format", function(ctx)
      ctx:init(function()
         local old = {
            points = {
               { id = 7, label = "B", position = { x = 1.5, y = 2.5 }, description = "d" },
               { id = 3, label = "a", position = { x = 0.5, y = 0.5 } },
            },
         }
         local new = convert(old, 1)
         ctx:assert_equals(7, new.order[1][1], "keeps the order")
         ctx:assert_equals(3, new.order[1][2], "keeps the order")
         ctx:assert_equals(1, new.points[7].surface_index, "on Nauvis")
         ctx:assert_equals("", new.points[3].description, "a missing description is empty")
         ctx:assert_equals(nil, next(new.categories), "no categories")
         ctx:assert_equals(nil, next(convert({ points = {} }, 1).order), "nothing to order")
         ctx:assert_equals(nil, next(convert(old, nil).points), "without Nauvis, dropped")
         ctx:assert(not pcall(convert, new --[[@as any]], 1), "refuses data already converted")
      end)
   end)

   it("orders, drags and categorizes points", function(ctx)
      ctx:init(function()
         local pindex = 1
         local s = assert(game.get_player(pindex)).surface.index
         clear(pindex)
         game.get_player(pindex).mod_settings["fa-fast-travel-sort-by-name"] = { value = false }

         local c = TravelTools.create_point(pindex, "c", s, { x = 0, y = 0 })
         local a = TravelTools.create_point(pindex, "a", s, { x = 0, y = 0 })
         TravelTools.create_point(pindex, "b", s, { x = 0, y = 0 })
         ctx:assert_equals("a,b,c", labels(pindex, s, "all"), "new points go in by name")

         ctx:assert(TravelTools.drag_point(pindex, c, -1, TravelTools.points(pindex, s, "all")), "dragged")
         ctx:assert_equals("a,c,b", labels(pindex, s, "all"), "c moved up past b")
         ctx:assert(not TravelTools.drag_point(pindex, a, -1, TravelTools.points(pindex, s, "all")), "a is first")

         -- Out of order now: a new point goes where it fits between its neighbours' names
         TravelTools.create_point(pindex, "bb", s, { x = 0, y = 0 })
         ctx:assert_equals("a,bb,c,b", labels(pindex, s, "all"), "the first place that fits, between a and c")

         TravelTools.set_category(pindex, a, "Ore")
         TravelTools.set_category(pindex, c, "Ore")
         ctx:assert_equals("a,c", labels(pindex, s, assert(TravelTools.get_point(pindex, a).category)), "the Ore tab")
         ctx:assert_equals("bb,b", labels(pindex, s, "uncategorized"), "the rest")

         -- Dragging in a category tab moves among that category, and the change holds in all
         ctx:assert(
            TravelTools.drag_point(pindex, c, -1, TravelTools.points(pindex, s, "uncategorized")) == false,
            "c is not in that list"
         )
         local ore_points = TravelTools.points(pindex, s, assert(TravelTools.get_point(pindex, a).category))
         ctx:assert(TravelTools.drag_point(pindex, c, -1, ore_points), "dragged within Ore")
         ctx:assert_equals("c,a,bb,b", labels(pindex, s, "all"), "seen in all")

         -- Stepping: Ore, then uncategorized; past the end, nothing
         ctx:assert_equals(false, TravelTools.step_category(pindex, a, 1), "to uncategorized")
         ctx:assert_equals(nil, TravelTools.step_category(pindex, a, 1), "uncategorized is last")
         ctx:assert_equals("Ore", TravelTools.step_category(pindex, a, -1), "back to Ore")

         TravelTools.set_category(pindex, a, nil)
         TravelTools.set_category(pindex, c, nil)
         ctx:assert_equals(0, #TravelTools.all_category_names(pindex), "an empty category is forgotten")

         game.get_player(pindex).mod_settings["fa-fast-travel-sort-by-name"] = { value = true }
         ctx:assert_equals("a,b,bb,c", labels(pindex, s, "all"), "the legacy setting sorts by name")
         game.get_player(pindex).mod_settings["fa-fast-travel-sort-by-name"] = { value = false }
         ctx:assert_equals("c,a,bb,b", labels(pindex, s, "all"), "and the arranged order is kept")
         clear(pindex)
      end)
   end)

   it("forgets a deleted surface's points", function(ctx)
      ---@type integer
      local index
      ctx:init(function()
         local surface = game.create_surface("fast-travel-test")
         index = surface.index
         TravelTools.create_point(1, "gone", index, { x = 0, y = 0 }, "Doomed")
         ctx:assert_equals("gone", labels(1, index, "all"), "made")
         game.delete_surface(surface)
      end)
      ctx:at_tick(3, function()
         ctx:assert_equals(nil, game.get_surface(index), "deleted")
         ctx:assert_equals(0, #TravelTools._order(1, index), "its order is gone")
         ctx:assert_equals(0, #TravelTools.all_category_names(1), "and its category")
      end)
   end)
end)
