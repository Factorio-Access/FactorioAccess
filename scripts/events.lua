local mod = {}

--can be local since all events must be registered each startup / in on_init
local registered_handlers = {}
local custom_event_handlers = {}

global.last_event_tick_by_player = global.last_event_tick_by_player or {}

local last_event_tick = global.last_event_tick_by_player

function mod.all_contexts(event_data)
   return true
end

function mod.register_handler(event, event_handler, context_evaluator)
   local top_handlers
   if type(event) == "string" then
      top_handlers = custom_event_handlers
   else
      top_handlers = registered_handlers
   end
   top_handlers[event] = top_handlers[event] or {}
   local handlers = top_handlers[event]
   table.insert(handlers, {
      handler = event_handler,
      context = context_evaluator,
   })
   script.on_event(event, universal_handler)
end

---This handler is what actually gets registered with scripts
---it will call some registered handlers that match the event data as described in the description of register handler
---@param event_data EventData.CustomInputEvent
function universal_handler(event_data)
   local handlers = registered_handlers[event_data.name]
   if not handlers then
      handlers = event_data.input_name and custom_event_handlers[event_data.input_name]
      if not handlers then
         error("received an event we shouldn't have been registered for:" .. serpent.line(event_data))
      end
      registered_handlers[event_data.name] = handlers
   end
   for _, handler in pairs(handlers) do
      if not event_data.player_index or not handler.context or event_data.tick then
         handler.handler(event_data)
      else
         if last_event_tick[event_data.player_index] ~= event_data.tick then
            local context = handler.context(event_data)
            if context and not handler.handler(event_data, context) then
               last_event_tick[event_data.player_index] = event_data.tick
            end
         end
      end
   end
end

return mod
