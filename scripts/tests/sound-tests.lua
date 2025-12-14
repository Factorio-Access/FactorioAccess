--- Sound system tests

local TestRegistry = require("scripts.test-registry")
local sounds = require("scripts.ui.sounds")
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
         -- Verify sounds from earlier tick are still in history
         local history = sounds.get_sound_history()
         ctx:assert_equals(5, #history, "Should have 5 sounds total")

         -- Verify all sounds are for player 1
         for _, sound_data in ipairs(history) do
            ctx:assert_equals(1, sound_data.pindex, "All sounds should be for player 1")
         end
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
