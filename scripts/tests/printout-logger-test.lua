local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("Printout Logger", function()
   it("should log printout messages to file", function(ctx)
      local player

      ctx:init(function()
         player = game.get_player(1)
      end)

      ctx:at_tick(1, function()
         -- Test simple string message
         printout("Test simple string", 1)
      end)

      ctx:at_tick(5, function()
         -- Test concatenated localised string
         printout({ "", "Test ", "concatenated ", "string" }, 1)
      end)

      ctx:at_tick(10, function()
         -- Test actual locale key that exists
         printout({ "fa.prefix-w" }, 1)
      end)

      ctx:at_tick(15, function()
         -- Test locale key with parameters
         printout({ "fa.ent-recipe-line", "iron-plate", 5 }, 1)
      end)

      ctx:at_tick(20, function()
         -- Test mixed content
         printout({ "", "Position: ", { "fa.position", 10, 20 }, " facing ", { "fa.direction.north" } }, 1)
      end)

      ctx:at_tick(25, function()
         -- Test nil and edge cases
         printout("", 1) -- Empty string
         printout({ "" }, 1) -- Empty localised string
      end)

      ctx:at_tick(30, function()
         -- Test passes if we get here without errors
      end)
   end)
end)
