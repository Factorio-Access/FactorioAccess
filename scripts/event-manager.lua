--- mod: Manages multiple handlers for Factorio events
-- Since Factorio's script.on_event is last-one-wins, this allows multiple handlers per event

local mod = {}

-- Storage for all registered handlers
-- Structure: handlers[event_id] = { handler1, handler2, ... }
local handlers = {}

-- Storage for on_init handlers
local on_init_handlers = {}

-- Storage for on_load handlers
local on_load_handlers = {}

-- Storage for on_configuration_changed handlers
local on_configuration_changed_handlers = {}

-- Storage for on_nth_tick handlers
-- Structure: on_nth_tick_handlers[tick_interval] = { handler1, handler2, ... }
local on_nth_tick_handlers = {}

-- Flag to track if we're in test mode
local test_mode = false

-- Storage for mocked events when in test mode
local mocked_events = {}

--- Register a handler for an event
-- @param event_id The event ID from defines.events
-- @param handler The function to call when the event fires
function mod.on_event(event_id, handler)
   if type(event_id) == "table" then
      -- Handle multiple events with same handler
      for _, id in pairs(event_id) do
         mod.on_event(id, handler)
      end
      return
   end

   if not handlers[event_id] then
      handlers[event_id] = {}

      -- Register the master handler with Factorio
      script.on_event(event_id, function(event)
         mod._dispatch_event(event_id, event)
      end)
   end

   table.insert(handlers[event_id], handler)
end

--- Register a handler for on_init
-- @param handler The function to call on init
function mod.on_init(handler)
   table.insert(on_init_handlers, handler)
end

--- Register a handler for on_load
-- @param handler The function to call on load
function mod.on_load(handler)
   table.insert(on_load_handlers, handler)
end

--- Register a handler for on_configuration_changed
-- @param handler The function to call on configuration changed
function mod.on_configuration_changed(handler)
   table.insert(on_configuration_changed_handlers, handler)
end

--- Register a handler for on_nth_tick
-- @param tick_interval The tick interval
-- @param handler The function to call
function mod.on_nth_tick(tick_interval, handler)
   if not on_nth_tick_handlers[tick_interval] then
      on_nth_tick_handlers[tick_interval] = {}

      -- Register the master handler with Factorio
      script.on_nth_tick(tick_interval, function(event)
         mod._dispatch_nth_tick(tick_interval, event)
      end)
   end

   table.insert(on_nth_tick_handlers[tick_interval], handler)
end

--- Register a handler for a custom input
-- @param input_name The custom input name (e.g. "fa-w")
-- @param handler The function to call
function mod.on_custom_input(input_name, handler)
   -- Custom inputs are just regular events
   mod.on_event(input_name, handler)
end

--- Register a handler (alias for on_event)
-- @param event_id_or_input The event ID or custom input name
-- @param handler The function to call
function mod.register(event_id_or_input, handler)
   mod.on_event(event_id_or_input, handler)
end

--- Internal: Dispatch an event to all registered handlers
-- @param event_id The event ID
-- @param event The event data
function mod._dispatch_event(event_id, event)
   local event_handlers = handlers[event_id]
   if not event_handlers then return end

   -- Check if this event has a player_index and needs initialization
   if event.player_index then
      local pindex = event.player_index
      if storage.players and storage.players[pindex] == nil then
         -- Player needs initialization
         local player = game.get_player(pindex)
         if player then
            -- Import PlayerInit here to avoid circular dependencies
            local PlayerInit = require("scripts.player-init")
            PlayerInit.initialize(player)
         end
      end
   end

   for _, handler in ipairs(event_handlers) do
      handler(event)
   end
end

--- Internal: Dispatch nth tick events
-- @param tick_interval The tick interval
-- @param event The event data
function mod._dispatch_nth_tick(tick_interval, event)
   local tick_handlers = on_nth_tick_handlers[tick_interval]
   if not tick_handlers then return end

   for _, handler in ipairs(tick_handlers) do
      handler(event)
   end
end

-- Initialize on module load
-- Register on_init handler
script.on_init(function()
   for _, handler in ipairs(on_init_handlers) do
      handler()
   end
end)

-- Register on_load handler
script.on_load(function()
   for _, handler in ipairs(on_load_handlers) do
      handler()
   end
end)

-- Register on_configuration_changed handler
script.on_configuration_changed(function(data)
   for _, handler in ipairs(on_configuration_changed_handlers) do
      handler(data)
   end
end)

--- Enable test mode to allow event mocking
function mod.enable_test_mode()
   test_mode = true
end

--- Disable test mode
function mod.disable_test_mode()
   test_mode = false
   mocked_events = {}
end

--- Mock an event (only works in test mode)
-- @param event_id The event ID to mock
-- @param event_data The event data to dispatch
function mod.mock_event(event_id, event_data)
   if not test_mode then error("Cannot mock events outside of test mode") end

   -- Ensure event has required fields
   event_data.name = event_id
   event_data.tick = event_data.tick or game.tick

   -- Store the mocked event
   if not mocked_events[event_id] then mocked_events[event_id] = {} end
   table.insert(mocked_events[event_id], event_data)

   -- Dispatch immediately
   mod._dispatch_event(event_id, event_data)
end

--- Clear all handlers (useful for testing)
function mod.clear_all_handlers()
   handlers = {}
   on_init_handlers = {}
   on_load_handlers = {}
   on_configuration_changed_handlers = {}
   on_nth_tick_handlers = {}
end

--- Get the number of handlers for an event (useful for testing)
-- @param event_id The event ID
-- @return Number of handlers
function mod.get_handler_count(event_id)
   if not handlers[event_id] then return 0 end
   return #handlers[event_id]
end

--- Create a player event handler that automatically validates the player
-- This wrapper ensures the player is initialized and valid before calling the handler
-- @param handler function(event, pindex) The handler function
-- @return function The wrapped handler
function mod.create_player_handler(handler)
   return function(event)
      local pindex = event.player_index
      if not pindex then
         error("create_player_handler used on event without player_index")
      end
      
      -- Player initialization is now handled in _dispatch_event
      -- so we just need to verify the player exists
      if storage.players and storage.players[pindex] then
         handler(event, pindex)
      end
   end
end

--- Create a player event handler with common objects pre-fetched
-- This wrapper provides player, router, and other commonly needed objects
-- @param handler function(event, pindex, player, router) The handler function
-- @return function The wrapped handler
function mod.create_extended_player_handler(handler)
   return function(event)
      local pindex = event.player_index
      if not pindex then
         error("create_extended_player_handler used on event without player_index")
      end
      
      -- Player initialization is now handled in _dispatch_event
      if storage.players and storage.players[pindex] then
         local player = game.get_player(pindex)
         -- Lazy load UiRouter to avoid circular dependencies
         local UiRouter = require("scripts.ui.router")
         local router = UiRouter.get_router(pindex)
         handler(event, pindex, player, router)
      end
   end
end

return mod
