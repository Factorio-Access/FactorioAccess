local mod = {}

--can be local since all events must be registered each startup / in on_init
local registered_handlers = {}
local custom_event_handlers = {}

global.last_event_tick_by_player = global.last_event_tick_by_player or {}
local last_event_tick = global.last_event_tick_by_player

global.last_event_by_player = global.last_event_by_player or {}
local last_event = global.last_event_by_player

---This handler is what actually gets registered with LuaScript
---it will call some registered handlers that match the event data as described in the description of register handler
---@param event_data EventData.CustomInputEvent
local function universal_handler(event_data)
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
         local pindex = event_data.player_index
         if last_event_tick[pindex] ~= event_data.tick then
            local context = handler.context(event_data)
            if context and not handler.handler(event_data, context) then
               last_event_tick[pindex] = event_data.tick
               last_event[pindex] = event_data
            end
         else
            --TODO add player.play_sound
            print("event " .. serpent.line(event_data) .. " was suppressed by " .. serpent.line(last_event[pindex]))
         end
      end
   end
end

---A default context evaluator function saying that the event should be handled in all contexts.
---It's unlikely that it's actually correct that an event should really be handled in all contexts.
---However, it may be used kinda like a todo while figuring out what contexts an event should fire in.
function mod.all_contexts(event_data)
   return true
end

---Used very similarly to scripts.on_event. With a few major differences.
---The purpose of using the handler is to prevent multiple events from happening do to one key press.
---For example we don't want to both flip a blue print and disconnect a train with the same keypress
---The primary way we want to prevent this is by defining contexts for when an event will actually happen.
---As long as the contexts are mutually exclusive each event will only fire in it's context.
---If the contexts have overlap then only the highest priority event will fire.
---Other events will be recorded to the log as suppressed.
---If you think your event should always happen, try out using all_contexts as the context_evaluator.
---If you're confident your event couldn't interfere with another handler and should always be executed even if something else is also executing
---then don't provide a context.
---If your context checking is kinda expensive and you'd need that value to actually execute the event,
---then you can return the data you'd need from the context evaluator and as long as it's truthy it'll be passed to your event handler.
---The priority of events is determined by the order key in the custom event prototype.
---@param event string|defines.events
---@param event_handler fun(p1:EventData,context_evaluator_return:any)
---@param context_evaluator fun(p1:EventData)|nil
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

--TODO add remove handler

return mod
