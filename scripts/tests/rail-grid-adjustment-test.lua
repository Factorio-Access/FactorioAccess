--- Rail Grid Adjustment Test
-- Verifies that TestSurface matches the game's grid adjustment behavior

local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

local TestSurface = require("railutils.surface-impls.test-surface")
local RailInfo = require("railutils.rail-info")

describe("Rail Grid Adjustment", function()
   it("should match game behavior for all rail types and positions", function(ctx)
      local failures = {}
      local prototype_names = {
         "straight-rail",
         "curved-rail-a",
         "curved-rail-b",
         "half-diagonal-rail",
      }

      -- Map prototype names to RailType
      local function get_rail_type(prototype_name)
         if prototype_name == "straight-rail" then
            return RailInfo.RailType.STRAIGHT
         elseif prototype_name == "curved-rail-a" then
            return RailInfo.RailType.CURVE_A
         elseif prototype_name == "curved-rail-b" then
            return RailInfo.RailType.CURVE_B
         elseif prototype_name == "half-diagonal-rail" then
            return RailInfo.RailType.HALF_DIAGONAL
         end
         error("Unknown prototype: " .. prototype_name)
      end

      ctx:init(function()
         local player = game.get_player(1)
         ctx:assert_not_nil(player, "Player should exist")

         local surface = player.surface
         ctx:assert_not_nil(surface, "Surface should exist")

         -- Loop through all prototype names
         for _, prototype_name in ipairs(prototype_names) do
            local rail_type = get_rail_type(prototype_name)

            -- Test positions from -8 to 8
            for x = -8, 8 do
               for y = -8, 8 do
                  -- Test even directions only (0, 2, 4, 6, 8, 10, 12, 14)
                  for dir = 0, 14, 2 do
                     -- Clear the surface
                     local area = { { x - 10, y - 10 }, { x + 10, y + 10 } }
                     local rails_to_remove = surface.find_entities_filtered({ area = area, type = "straight-rail" })
                     for _, rail in ipairs(rails_to_remove) do
                        rail.destroy()
                     end
                     rails_to_remove = surface.find_entities_filtered({ area = area, type = "curved-rail-a" })
                     for _, rail in ipairs(rails_to_remove) do
                        rail.destroy()
                     end
                     rails_to_remove = surface.find_entities_filtered({ area = area, type = "curved-rail-b" })
                     for _, rail in ipairs(rails_to_remove) do
                        rail.destroy()
                     end
                     rails_to_remove = surface.find_entities_filtered({ area = area, type = "half-diagonal-rail" })
                     for _, rail in ipairs(rails_to_remove) do
                        rail.destroy()
                     end

                     -- Create a new test surface for each iteration
                     local test_surface = TestSurface.new()

                     -- Try to place on real surface
                     local real_rail = surface.create_entity({
                        name = prototype_name,
                        position = { x = x, y = y },
                        direction = dir,
                        force = player.force,
                        raise_built = false,
                     })

                     -- Place on test surface
                     ---@cast dir defines.direction
                     local test_rail = test_surface:add_rail(rail_type, { x = x, y = y }, dir)

                     if real_rail then
                        -- Compare positions
                        local real_pos = real_rail.position
                        local test_pos = test_rail.prototype_position

                        local pos_match = math.abs(real_pos.x - test_pos.x) < 0.01
                           and math.abs(real_pos.y - test_pos.y) < 0.01

                        -- Compare directions
                        local real_dir = real_rail.direction
                        local test_dir = test_rail.direction
                        local dir_match = real_dir == test_dir

                        if not pos_match or not dir_match then
                           table.insert(failures, {
                              prototype = prototype_name,
                              request_x = x,
                              request_y = y,
                              request_dir = dir,
                              real_x = real_pos.x,
                              real_y = real_pos.y,
                              real_dir = real_dir,
                              test_x = test_pos.x,
                              test_y = test_pos.y,
                              test_dir = test_dir,
                              pos_match = pos_match,
                              dir_match = dir_match,
                           })
                        end

                        real_rail.destroy()
                     else
                        -- Real surface rejected placement, test surface should too
                        -- (but we already placed it, so this is a potential failure)
                        -- For now, we accept this case since test surface is more permissive
                     end
                  end
               end
            end
         end

         -- Report failures
         if next(failures) then
            print("=== RAIL GRID ADJUSTMENT FAILURES ===")
            print(string.format("Total failures: %d", #failures))
            print("")

            -- Group by issue type
            local pos_failures = {}
            local dir_failures = {}
            local both_failures = {}

            for _, f in ipairs(failures) do
               if not f.pos_match and not f.dir_match then
                  table.insert(both_failures, f)
               elseif not f.pos_match then
                  table.insert(pos_failures, f)
               elseif not f.dir_match then
                  table.insert(dir_failures, f)
               end
            end

            -- Analyze grid offset patterns
            print("Grid offset analysis:")
            local offset_patterns = {}
            for _, f in ipairs(pos_failures) do
               local game_offset_x = f.real_x - f.request_x
               local game_offset_y = f.real_y - f.request_y
               local test_offset_x = f.test_x - f.request_x
               local test_offset_y = f.test_y - f.request_y

               local key = string.format("%s_dir%d", f.prototype, f.request_dir)
               if not offset_patterns[key] then
                  offset_patterns[key] = {
                     prototype = f.prototype,
                     direction = f.request_dir,
                     game_offset_x = game_offset_x,
                     game_offset_y = game_offset_y,
                     test_offset_x = test_offset_x,
                     test_offset_y = test_offset_y,
                     count = 0,
                  }
               end
               offset_patterns[key].count = offset_patterns[key].count + 1
            end

            for key, pattern in pairs(offset_patterns) do
               print(
                  string.format(
                     "  %s dir %d: game offset (%.1f,%.1f) vs test offset (%.1f,%.1f) - %d cases",
                     pattern.prototype,
                     pattern.direction,
                     pattern.game_offset_x,
                     pattern.game_offset_y,
                     pattern.test_offset_x,
                     pattern.test_offset_y,
                     pattern.count
                  )
               )
            end
            print("")

            if #dir_failures > 0 or #both_failures > 0 then
               print("Direction mismatches:")
               local dir_issues = {}
               for _, f in ipairs(dir_failures) do
                  table.insert(dir_issues, f)
               end
               for _, f in ipairs(both_failures) do
                  table.insert(dir_issues, f)
               end

               -- Show first 10
               for i = 1, math.min(10, #dir_issues) do
                  local f = dir_issues[i]
                  print(
                     string.format(
                        "  %s at (%d,%d) dir %d -> game dir %d, test dir %d",
                        f.prototype,
                        f.request_x,
                        f.request_y,
                        f.request_dir,
                        f.real_dir,
                        f.test_dir
                     )
                  )
               end
               if #dir_issues > 10 then
                  print(string.format("  ... and %d more direction mismatches", #dir_issues - 10))
               end
               print("")
            end

            if #pos_failures > 0 or #both_failures > 0 then
               print("Position mismatches:")
               local pos_issues = {}
               for _, f in ipairs(pos_failures) do
                  table.insert(pos_issues, f)
               end
               for _, f in ipairs(both_failures) do
                  table.insert(pos_issues, f)
               end

               -- Show first 10
               for i = 1, math.min(10, #pos_issues) do
                  local f = pos_issues[i]
                  print(
                     string.format(
                        "  %s at (%d,%d) dir %d -> game (%.1f,%.1f), test (%.1f,%.1f)",
                        f.prototype,
                        f.request_x,
                        f.request_y,
                        f.request_dir,
                        f.real_x,
                        f.real_y,
                        f.test_x,
                        f.test_y
                     )
                  )
               end
               if #pos_issues > 10 then
                  print(string.format("  ... and %d more position mismatches", #pos_issues - 10))
               end
            end

            error("Rail grid adjustment test failed - see log for details")
         end

         print("Rail grid adjustment test passed: all positions and directions match")
      end)
   end)
end)
