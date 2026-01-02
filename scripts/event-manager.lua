---Manages multiple handlers for Factorio events
---Since Factorio's script.on_event is last-one-wins, this allows multiple handlers per event.
---Don't use that though, it's to support our tests.
local PlayerInit = require("scripts.player-init")
local VanillaMode = require("scripts.vanilla-mode")

local mod = {}

-- Events that run even when vanilla mode is enabled.
local VANILLA_MODE_WHITELIST = {
   -- Vanilla mode toggle itself
   ["fa-cas-v"] = true,
   ["fa-ca-v"] = true, -- legacy, will be removed

   -- Essential game events
   [defines.events.on_tick] = true,
   [defines.events.on_player_joined_game] = true,
   [defines.events.on_player_created] = true,
   [defines.events.on_player_respawned] = true,

   -- Scanner and state tracking (silent)
   [defines.events.on_object_destroyed] = true,
   [defines.events.on_built_entity] = true,
   [defines.events.on_robot_built_entity] = true,
   [defines.events.script_raised_built] = true,
   [defines.events.on_entity_cloned] = true,
   [defines.events.on_surface_created] = true,
   [defines.events.on_surface_deleted] = true,
   [defines.events.on_research_finished] = true,
   [defines.events.on_string_translated] = true,
   [defines.events.on_player_display_resolution_changed] = true,
   [defines.events.on_player_display_scale_changed] = true,
   [defines.events.on_player_cursor_stack_changed] = true,
   [defines.events.on_player_main_inventory_changed] = true,

   -- GUI and game state
   [defines.events.on_gui_opened] = true,
   [defines.events.on_gui_closed] = true,
   [defines.events.on_cutscene_started] = true,
   [defines.events.on_cutscene_finished] = true,
   [defines.events.on_player_changed_surface] = true,
   [defines.events.on_player_driving_changed_state] = true,
   [defines.events.on_entity_damaged] = true,
   [defines.events.on_entity_died] = true,
   [defines.events.on_player_died] = true,
}

-- Event priority constants
mod.EVENT_KIND = {
   TEST = "test",
   UI = "ui",
   WORLD = "world",
}

-- Special constant to indicate no further handlers should run
mod.FINISHED = {}

---@alias EventHandlerResult nil|table Return nil to continue processing, or EventManager.FINISHED to stop

-- Storage for all registered handlers
-- Structure: handlers[event_id] = { test = handler, ui = handler, world = handler }
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

---Register a handler for an event
---@param event_id defines.events|string|(defines.events|string)[] The event ID from defines.events, custom input name, or array of event IDs
---@param handler fun(event: any, pindex?: integer): EventHandlerResult The function to call when the event fires
---@param priority? "test"|"ui"|"world" Optional priority (defaults to WORLD)
function mod.on_event(event_id, handler, priority)
   priority = priority or mod.EVENT_KIND.WORLD

   if type(event_id) == "table" then
      -- Handle multiple events with same handler
      for _, id in pairs(event_id) do
         mod.on_event(id, handler, priority)
      end
      return
   end

   if not handlers[event_id] then
      handlers[event_id] = {}

      -- Register the master handler with Factorio
      script.on_event(event_id, function(event)
         -- For debugging: prints events to the launcher console.
         -- CLAUDE: don't remove this, it's not by you.
         if false and event.name and event.name ~= 0 then
            print("Evt:", serpent.line(event, { nocode = true }))
            for n, v in pairs(defines.events) do
               if event.name == v then print("Is", n) end
            end
         end
         mod._dispatch_event(event_id, event)
      end)
   end

   -- Only one handler per priority level allowed
   handlers[event_id][priority] = handler
end

---Register a handler for on_init
---@param handler fun() The function to call on init
function mod.on_init(handler)
   table.insert(on_init_handlers, handler)
end

---Register a handler for on_load
---@param handler fun() The function to call on load
function mod.on_load(handler)
   table.insert(on_load_handlers, handler)
end

---Register a handler for on_configuration_changed
---@param handler fun(data: ConfigurationChangedData) The function to call on configuration changed
function mod.on_configuration_changed(handler)
   table.insert(on_configuration_changed_handlers, handler)
end

---Register a handler for on_nth_tick
---@param tick_interval integer The tick interval
---@param handler fun(event: NthTickEventData) The function to call
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

---Register a handler for a custom input
---@param input_name string The custom input name (e.g. "fa-w")
---@param handler fun(event: EventData, pindex?: integer): EventHandlerResult The function to call
---@param priority? "test"|"ui"|"world" Optional priority (defaults to WORLD)
function mod.on_custom_input(input_name, handler, priority)
   -- Custom inputs are just regular events
   mod.on_event(input_name, handler, priority)
end

---Register a handler (alias for on_event)
---@param event_id_or_input defines.events|string The event ID or custom input name
---@param handler fun(event: EventData, pindex?: integer): EventHandlerResult The function to call
---@param priority? "test"|"ui"|"world" Optional priority (defaults to WORLD)
function mod.register(event_id_or_input, handler, priority)
   mod.on_event(event_id_or_input, handler, priority)
end

---Internal: Dispatch an event to all registered handlers
---@param event_id defines.events|string The event ID
---@param event EventData The event data
function mod._dispatch_event(event_id, event)
   local event_handlers = handlers[event_id]
   if not event_handlers then return end

   local pindex = event.player_index

   -- Check if this event has a player_index and needs initialization
   if pindex then
      if storage.players and storage.players[pindex] == nil then
         -- Player needs initialization
         local player = game.get_player(pindex)
         if player then PlayerInit.initialize(player) end
      end

      -- Skip non-whitelisted events when vanilla mode is enabled.
      -- pcall permitted: player_index can be stale/invalid in some edge cases.
      local ok, is_vanilla = pcall(VanillaMode.is_enabled, pindex)
      if ok and is_vanilla and not VANILLA_MODE_WHITELIST[event_id] then return end
   end

   -- Run handlers in priority order: test → ui → world
   local priority_order = { mod.EVENT_KIND.TEST, mod.EVENT_KIND.UI, mod.EVENT_KIND.WORLD }

   for _, priority in ipairs(priority_order) do
      local handler = event_handlers[priority]
      if handler then
         local result = handler(event, pindex)
         if result == mod.FINISHED then
            -- Stop processing further handlers
            return
         end
      end
   end
end

---Internal: Dispatch nth tick events
---@param tick_interval integer The tick interval
---@param event NthTickEventData The event data
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

---Enable test mode to allow event mocking
function mod.enable_test_mode()
   test_mode = true
end

---Disable test mode
function mod.disable_test_mode()
   test_mode = false
   mocked_events = {}
end

---Mock an event (only works in test mode)
---@param event_id defines.events|string The event ID to mock
---@param event_data any The event data to dispatch
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

---Clear all handlers (useful for testing)
function mod.clear_all_handlers()
   handlers = {}
   on_init_handlers = {}
   on_load_handlers = {}
   on_configuration_changed_handlers = {}
   on_nth_tick_handlers = {}
end

---Get the number of handlers for an event (useful for testing)
---@param event_id defines.events|string The event ID
---@return integer count Number of handlers
function mod.get_handler_count(event_id)
   if not handlers[event_id] then return 0 end
   local count = 0
   for _, handler in pairs(handlers[event_id]) do
      if handler then count = count + 1 end
   end
   return count
end

return mod
