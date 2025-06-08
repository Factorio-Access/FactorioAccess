--- Sound system tests
-- @module sound_tests

local sounds = require("scripts.ui.sounds")
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Sound System Tests", function()
   it("should track sounds in test mode", function(test_ctx)
      test_ctx:init(function(ctx)
         -- Clear sound history for this test
         sounds.clear_sound_history()
         -- Sounds should already be in test mode (enabled by framework)
         local history = sounds.get_sound_history()
         ctx:assert_equals(0, #history, "Sound history should start empty")

         -- Play some sounds
         sounds.play_menu_move(1)
         sounds.play_menu_click(1)
         sounds.play_menu_wrap(2)

         history = sounds.get_sound_history()
         ctx:assert_equals(3, #history, "Should have recorded 3 sounds")
      end)

      test_ctx:at_tick(10, function(ctx)
         local history = sounds.get_sound_history()

         -- Check first sound
         ctx:assert_equals(1, history[1].pindex)
         ctx:assert_equals("Inventory-Move", history[1].sound.path)

         -- Check second sound
         ctx:assert_equals(1, history[2].pindex)
         ctx:assert_equals("utility/inventory_click", history[2].sound.path)

         -- Check third sound
         ctx:assert_equals(2, history[3].pindex)
         ctx:assert_equals("inventory-wrap-around", history[3].sound.path)
      end)
   end)

   it("should handle complex sound sequences", function(test_ctx)
      test_ctx:init(function(ctx)
         -- Clear sound history for this test
         sounds.clear_sound_history()
         -- Play movement sounds
         sounds.play_player_walk(1)
         sounds.play_player_turn(1)
         sounds.play_player_teleport(1)
      end)

      test_ctx:at_tick(5, function(ctx)
         -- Play combat sounds
         sounds.play_player_damaged_character(1)
         sounds.play_aim_locked(1)

         local history = sounds.get_sound_history()
         ctx:assert_equals(5, #history, "Should have 5 sounds total")
      end)

      test_ctx:in_ticks(10, function(ctx)
         -- Play alert sounds
         sounds.play_enemy_presence_low(2)
         sounds.play_structure_damaged(2)

         local history = sounds.get_sound_history()
         ctx:assert_equals(7, #history, "Should have 7 sounds total")

         -- Verify all sounds are for correct players
         local player1_sounds = 0
         local player2_sounds = 0

         for _, sound_data in ipairs(history) do
            if sound_data.pindex == 1 then
               player1_sounds = player1_sounds + 1
            elseif sound_data.pindex == 2 then
               player2_sounds = player2_sounds + 1
            end
         end

         ctx:assert_equals(5, player1_sounds, "Player 1 should have 5 sounds")
         ctx:assert_equals(2, player2_sounds, "Player 2 should have 2 sounds")
      end)
   end)

   it("should handle custom sound specs", function(test_ctx)
      test_ctx:init(function(ctx)
         -- Clear sound history for this test
         sounds.clear_sound_history()
         -- Play custom sound with volume modifier
         sounds.play_sound(1, {
            path = "custom-sound-path",
            volume_modifier = 0.5,
            position = { x = 10, y = 20 },
         })

         local history = sounds.get_sound_history()
         ctx:assert_equals(1, #history)

         local sound_data = history[1]
         ctx:assert_equals("custom-sound-path", sound_data.sound.path)
         ctx:assert_equals(0.5, sound_data.sound.volume_modifier)
         ctx:assert_table_equals({ x = 10, y = 20 }, sound_data.sound.position)
      end)
   end)
end)
