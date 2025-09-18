local EventManager = require("scripts.event-manager")
local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("EventManager Player Initialization", function()
   it("should initialize new players and not swallow their first event", function(ctx)
      local event_count = 0
      local handler_called = false
      local test_pindex = 1

      -- Register a test handler that tracks calls
      EventManager.on_event("test-player-event", function(event, pindex)
         event_count = event_count + 1
         handler_called = true
         ctx:assert_equals(pindex, test_pindex) -- Test player index
         assert(storage.players[pindex] ~= nil, "Player should be initialized")
      end)

      ctx:at_tick(1, function()
         -- Clear any existing player data for our test player
         if storage.players then storage.players[test_pindex] = nil end

         -- Mock a player event for a new player
         EventManager.mock_event("test-player-event", {
            player_index = test_pindex,
            tick = game.tick,
         })
      end)

      ctx:at_tick(2, function()
         -- Verify the handler was called
         assert(handler_called, "Handler should have been called")
         ctx:assert_equals(event_count, 1, "Event should not have been swallowed")

         -- Verify player was initialized
         assert(storage.players[test_pindex] ~= nil, "Player should have been initialized")

         -- Send another event to verify it still works
         handler_called = false
         EventManager.mock_event("test-player-event", {
            player_index = test_pindex,
            tick = game.tick,
         })
      end)

      ctx:at_tick(3, function()
         assert(handler_called, "Handler should have been called again")
         ctx:assert_equals(event_count, 2, "Second event should also work")
      end)
   end)

   it("should handle events without player_index gracefully", function(ctx)
      local handler_called = false

      -- Register a non-player event handler
      EventManager.on_event("test-non-player-event", function(event)
         handler_called = true
      end)

      ctx:at_tick(1, function()
         -- Mock an event without player_index
         EventManager.mock_event("test-non-player-event", {
            tick = game.tick,
            some_data = "test",
         })
      end)

      ctx:at_tick(2, function()
         assert(handler_called, "Non-player event handler should be called")
      end)
   end)
end)
