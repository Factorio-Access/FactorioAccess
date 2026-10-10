local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it
local Speech = require("scripts.speech")

describe("Speech Logger", function()
   it("should log speech messages to file", function(ctx)
      local player

      ctx:init(function()
         player = game.get_player(1)
      end)

      ctx:at_tick(1, function()
         -- Test simple string message
         Speech.speak(1, "Test simple string")
      end)

      ctx:at_tick(5, function()
         -- Test concatenated localised string
         Speech.speak(1, { "", "Test ", "concatenated ", "string" })
      end)

      ctx:at_tick(10, function()
         -- Test actual locale key that exists
         Speech.speak(1, { "fa.empty" })
      end)

      ctx:at_tick(15, function()
         -- Test locale key with parameters
         Speech.speak(1, { "fa.zoom-at-max", 200 })
      end)

      ctx:at_tick(20, function()
         -- Test mixed content
         Speech.speak(1, { "", "Position: ", { "fa.distance-tiles-direction", 10, { "fa.direction", 0 } } })
      end)

      ctx:at_tick(25, function()
         -- Test nil and edge cases
         Speech.speak(1, "") -- Empty string
         Speech.speak(1, { "" }) -- Empty localised string
      end)

      ctx:at_tick(30, function()
         -- Test passes if we get here without errors
      end)
   end)
end)
