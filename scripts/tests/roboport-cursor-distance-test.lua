local WorkerRobots = require("scripts.worker-robots")
local FaUtils = require("scripts.fa-utils")
local Viewpoint = require("scripts.viewpoint")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Roboport Distance Cursor Mode", function()
   it("should use cursor position for distance checks when in cursor mode", function(ctx)
      local player
      local roboport
      local surface
      local vp
      local captured_output = ""

      ctx:init(function()
         player = game.get_player(1)
         surface = player.surface
         vp = Viewpoint.get_viewpoint(1)

         -- Create a roboport at a specific position
         roboport = surface.create_entity({
            name = "roboport",
            position = { x = 50, y = 0 },
            force = player.force,
         })

         -- Give it a name for identification
         roboport.backer_name = "TestRoboport"

         -- Teleport player away from roboport
         player.teleport({ x = 0, y = 0 })
      end)

      ctx:at_tick(1, function()
         -- Test 1: Player far from roboport, cursor mode disabled
         vp:set_cursor_enabled(false)

         -- Capture output
         local old_printout = _G.printout
         _G.printout = function(msg, pindex)
            captured_output = type(msg) == "table" and serpent.line(msg) or tostring(msg)
         end

         WorkerRobots.player_logistic_requests_summary_info(1)

         _G.printout = old_printout

         -- Should report not in network since player is at (0,0) far from roboport
         ctx:assert(
            captured_output:find("Not in a network") ~= nil,
            "Should report not in network when player is far away"
         )
      end)

      ctx:in_ticks(5, function()
         -- Test 2: Enable cursor mode and place cursor near roboport
         vp:set_cursor_enabled(true)
         vp:set_cursor_pos({ x = 48, y = 0 }) -- Within construction range of roboport at (50,0)

         -- Capture output
         local old_printout = _G.printout
         captured_output = ""
         _G.printout = function(msg, pindex)
            captured_output = type(msg) == "table" and serpent.line(msg) or tostring(msg)
         end

         WorkerRobots.player_logistic_requests_summary_info(1)

         _G.printout = old_printout

         -- Should report in construction range since cursor is near roboport
         ctx:assert(
            captured_output:find("TestRoboport") ~= nil,
            "Should report being in network when cursor is near roboport"
         )
      end)

      ctx:in_ticks(5, function()
         -- Test 3: Move cursor far away
         vp:set_cursor_pos({ x = 200, y = 200 }) -- Far from roboport

         -- Capture output
         local old_printout = _G.printout
         captured_output = ""
         _G.printout = function(msg, pindex)
            captured_output = type(msg) == "table" and serpent.line(msg) or tostring(msg)
         end

         WorkerRobots.player_logistic_requests_summary_info(1)

         _G.printout = old_printout

         -- Should report not in network since cursor is far away
         ctx:assert(
            captured_output:find("Not in a network") ~= nil,
            "Should report not in network when cursor is far away"
         )
      end)

      ctx:in_ticks(5, function()
         -- Cleanup
         if roboport and roboport.valid then roboport.destroy() end
      end)
   end)

   it("should correctly handle get_player_relative_origin helper", function(ctx)
      local player
      local vp
      local position

      ctx:init(function()
         player = game.get_player(1)
         vp = Viewpoint.get_viewpoint(1)

         -- Start at a known position
         player.teleport({ x = 10, y = 20 })
      end)

      ctx:at_tick(1, function()
         -- Test with cursor disabled - should return player position
         vp:set_cursor_enabled(false)
         position = FaUtils.get_player_relative_origin(1)

         ctx:assert_equals(10, position.x, "Should return player X when cursor disabled")
         ctx:assert_equals(20, position.y, "Should return player Y when cursor disabled")
      end)

      ctx:in_ticks(5, function()
         -- Test with cursor enabled - should return cursor position
         vp:set_cursor_enabled(true)
         vp:set_cursor_pos({ x = 100, y = 150 })

         position = FaUtils.get_player_relative_origin(1)

         ctx:assert_equals(100, position.x, "Should return cursor X when cursor enabled")
         ctx:assert_equals(150, position.y, "Should return cursor Y when cursor enabled")
      end)

      ctx:in_ticks(5, function()
         -- Test with no character (simulate god mode)
         local old_character = player.character
         player.character = nil
         vp:set_cursor_enabled(false)

         position = FaUtils.get_player_relative_origin(1)

         -- Should still return a position (player position in god mode)
         ctx:assert_not_nil(position, "Should return position even without character")

         -- Restore character
         player.character = old_character
      end)
   end)

   it("should work correctly in player_logistic_request_read", function(ctx)
      local player
      local roboport
      local surface
      local vp
      local captured_output = ""

      ctx:init(function()
         player = game.get_player(1)
         surface = player.surface
         vp = Viewpoint.get_viewpoint(1)

         -- Create roboport
         roboport = surface.create_entity({
            name = "roboport",
            position = { x = 30, y = 0 },
            force = player.force,
         })

         -- Place player outside network
         player.teleport({ x = 0, y = 0 })

         -- Give player an item to check logistics for
         player.insert({ name = "iron-plate", count = 10 })
      end)

      ctx:at_tick(1, function()
         -- Test with cursor in network range
         vp:set_cursor_enabled(true)
         vp:set_cursor_pos({ x = 28, y = 0 }) -- Near roboport

         -- Capture output
         local old_printout = _G.printout
         _G.printout = function(msg, pindex)
            captured_output = type(msg) == "table" and serpent.line(msg) or tostring(msg)
         end

         -- Call the function with additional_checks = true
         WorkerRobots.player_logistic_request_read("iron-plate", 1, true)

         _G.printout = old_printout

         -- Should NOT say "Not in a network" since cursor is near roboport
         ctx:assert(not 
            captured_output:find("Not in a network") ~= nil,
            "Should not report 'not in network' when cursor is near roboport"
         )
      end)

      ctx:in_ticks(5, function()
         -- Cleanup
         if roboport and roboport.valid then roboport.destroy() end
      end)
   end)
end)
