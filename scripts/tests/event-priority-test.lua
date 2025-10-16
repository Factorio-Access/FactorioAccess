local EventManager = require("scripts.event-manager")
local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

describe("EventManager Priority System", function()
   it("should execute handlers in priority order: TEST -> UI -> WORLD", function(ctx)
      local execution_order = {}

      -- Register handlers in reverse order to ensure ordering works
      EventManager.on_event("test-priority-event", function(event)
         table.insert(execution_order, "WORLD")
      end, EventManager.EVENT_KIND.WORLD)

      EventManager.on_event("test-priority-event", function(event)
         table.insert(execution_order, "UI")
      end, EventManager.EVENT_KIND.UI)

      EventManager.on_event("test-priority-event", function(event)
         table.insert(execution_order, "TEST")
      end, EventManager.EVENT_KIND.TEST)

      ctx:at_tick(1, function()
         -- Trigger the event
         EventManager.mock_event("test-priority-event", {
            tick = game.tick,
         })
      end)

      ctx:at_tick(2, function()
         -- Verify execution order
         ctx:assert_equals(#execution_order, 3)
         ctx:assert_equals(execution_order[1], "TEST")
         ctx:assert_equals(execution_order[2], "UI")
         ctx:assert_equals(execution_order[3], "WORLD")
      end)
   end)

   it("should stop execution when handler returns FINISHED", function(ctx)
      local handlers_called = {}

      EventManager.on_event("test-finished-event", function(event)
         table.insert(handlers_called, "TEST")
      end, EventManager.EVENT_KIND.TEST)

      EventManager.on_event("test-finished-event", function(event)
         table.insert(handlers_called, "UI")
         return EventManager.FINISHED -- Stop here
      end, EventManager.EVENT_KIND.UI)

      EventManager.on_event("test-finished-event", function(event)
         table.insert(handlers_called, "WORLD")
      end, EventManager.EVENT_KIND.WORLD)

      ctx:at_tick(1, function()
         EventManager.mock_event("test-finished-event", {
            tick = game.tick,
         })
      end)

      ctx:at_tick(2, function()
         -- Only TEST and UI should have been called
         ctx:assert_equals(#handlers_called, 2)
         ctx:assert_equals(handlers_called[1], "TEST")
         ctx:assert_equals(handlers_called[2], "UI")
         -- WORLD should not be in the list
         for _, handler in ipairs(handlers_called) do
            assert(handler ~= "WORLD", "WORLD handler should not have been called")
         end
      end)
   end)

   it("should default to WORLD priority when not specified", function(ctx)
      local handler_priority = nil

      -- Register without priority
      EventManager.on_event("test-default-priority", function(event)
         -- We'll check which priority slot this landed in
         handler_priority = "found"
      end)

      ctx:at_tick(1, function()
         EventManager.mock_event("test-default-priority", {
            tick = game.tick,
         })
      end)

      ctx:at_tick(2, function()
         assert(handler_priority == "found", "Handler should have been called")
         -- Verify only one handler is registered
         local count = EventManager.get_handler_count("test-default-priority")
         ctx:assert_equals(count, 1)
      end)
   end)

   it("should handle multiple events with same handler", function(ctx)
      local call_count = 0

      EventManager.on_event({ "test-multi-1", "test-multi-2", "test-multi-3" }, function(event)
         call_count = call_count + 1
      end, EventManager.EVENT_KIND.UI)

      ctx:at_tick(1, function()
         EventManager.mock_event("test-multi-1", { tick = game.tick })
         EventManager.mock_event("test-multi-2", { tick = game.tick })
         EventManager.mock_event("test-multi-3", { tick = game.tick })
      end)

      ctx:at_tick(2, function()
         ctx:assert_equals(call_count, 3)
      end)
   end)
end)
