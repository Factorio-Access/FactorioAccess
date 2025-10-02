--[[
The low-level entrypoint to the UI infrastructure for external code.

One does: `Router.get_router(pindex):method()` or alternatively caches that in a variable.  This module is the UI
entrypoint: you can request UIs to open and close, and ask what is open, etc.

Routers cannot be stored in storage.  It is cheap to get a router because the instances are cached; each
get_router(pindex) call returns the same object  for a given pindex for the run of this process.  Those objects are thin
wrappers over storage manipulation, and so this is still deterministic.

This is WIP in the sense that not all UIs are ported to the new system.  So, for now, it just holds and changes the UI's
name, and the routing is handled in control.lua. If you are familiar with the old way:

```
players[pindex].menu = bla
players[pindex].in_menu = true
```

Then, now, it's:

```
Router.get_router(pindex):open_ui(UiRouter.UI_NAMES.WHATEVER)
local is_open = Router.get_router(pindex):is_ui_open()
```

Internally, routers will pass themselves down to child UIs so that said UIs may manipulate the top-level UI state. While
getting off the ground however, everything imports this module and uses it as a raw replacement for
storage[].menu[_name].  Once we are further along, that will be inverted and this router will get a chance to intercept
UI-destined events.
]]
local StorageManager = require("scripts.storage-manager")
local EventManager = require("scripts.event-manager")
local GameGui = require("scripts.ui.game-gui")
local UiSounds = require("scripts.ui.sounds")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local LocalisedStringCache = require("scripts.localised-string-cache")

local mod = {}

---Storage for registered UI instances
---@type table<string, fa.ui.UiPanelBase>
local registered_uis = {}

---Register a UI with the event routing system
---@param ui fa.ui.UiPanelBase
function mod.register_ui(ui)
   assert(type(ui.ui_name) == "string")
   registered_uis[ui.ui_name] = ui
end

---Get a registered UI by name
---@param ui_name string
---@return fa.ui.UiPanelBase?
function mod.get_registered_ui(ui_name)
   return registered_uis[ui_name]
end

---Get all registered UIs
---@return table<string, fa.ui.UiPanelBase>
function mod.get_registered_uis()
   return registered_uis
end

---@class fa.ui.UiPanelBase
---@field ui_name fa.ui.UiName
---@field open fun(self, pindex: number, parameters: table, controller: fa.ui.RouterController)
---@field close? fun(self, pindex: number)
---@field on_click? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_right_click? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_up? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_down? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_left? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_right? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_top? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_bottom? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_leftmost? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_rightmost? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_read_coords? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_read_info? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_next_tab? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_previous_tab? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_next_section? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_previous_section? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)
---@field on_child_result? fun(self, pindex: number, result: any, context: any, controller: fa.ui.RouterController)
---@field on_accelerator? fun(self, pindex: number, accelerator_name: fa.ui.Accelerator, modifiers: table?, controller: fa.ui.RouterController)
---@field on_clear? fun(self, pindex: number, modifiers: table?, controller: fa.ui.RouterController)

---@enum fa.ui.UiName
mod.UI_NAMES = {
   -- New unified UI that subsumes inventory, guns, crafting, crafting_queue, technology
   MAIN = "main",
   -- New inventory, but we need the old name for a little bit while we roll over.
   GENERIC_INVENTORY = "inventory2",
   -- BUILDING and VEHICLE removed - migrating to capability-based UI
   -- Generic entity UI that adapts to entity capabilities
   ENTITY = "entity",
   TRAVEL = "travel",
   GUNS = "guns", -- Keep for backward compatibility with gun_menu registration
   BELT = "belt",
   WARNINGS = "warnings",
   PUMP = "pump",
   ROBOPORT = "roboport",
   BLUEPRINT = "blueprint",
   BLUEPRINT_BOOK = "blueprint_book",
   SIGNAL_SELECTOR = "signal_selector",
   SPIDERTRON = "spidertron",
   DEBUG = "debug",
   DEBUG_FORMBUILDER = "debug_formbuilder",
   ITEM_CHOOSER = "item_chooser",
   SIGNAL_CHOOSER = "signal_chooser",
   LOGISTICS_CONFIG = "logistics_config",
   BOX_SELECTOR = "box_selector",
   BLUEPRINT_AREA_SELECTOR = "blueprint_area_selector",
   DECON_AREA_SELECTOR = "decon_area_selector",
   UPGRADE_AREA_SELECTOR = "upgrade_area_selector",
   COPY_PASTE_AREA_SELECTOR = "copy_paste_area_selector",
   SIMPLE_TEXTBOX = "simple_textbox",
   SEARCH_SETTER = "search_setter",
}

---@enum fa.ui.Accelerator
mod.ACCELERATORS = {
   ENTER_CONSTANT = "enter_constant",
   SELECT_SIGNAL = "select_signal",
}

---@enum fa.ui.SearchResult
mod.SEARCH_RESULT = {
   NO_SUPPORT = 1, -- UI doesn't support search
   DIDNT_MOVE = 2, -- Supports search but no match or already on it
   MOVED = 3, -- Moved to a match
   WRAPPED = 4, -- Wrapped around to find a match
}

---@class fa.ui.RouterState
---@field ui_stack {name: fa.ui.UiName, context?: any}[] Stack of open UIs with contexts (top is last)
---@field search_pattern string? Current search pattern (literal substring)

---@type table<number, fa.ui.RouterState>
local router_state = StorageManager.declare_storage_module("ui_router", {
   ui_stack = {},
   search_pattern = nil,
}, {
   ephemeral_state_version = 3,
})

---@class fa.ui.Router
---@field pindex number
---@field controller fa.ui.RouterController
local Router = {}
local Router_meta = { __index = Router }

---@class fa.ui.RouterController
---@field router fa.ui.Router
---@field pindex number
---@field message fa.MessageBuilder? Temporary message accumulator during event processing
local RouterController = {}
local RouterController_meta = { __index = RouterController }

function RouterController:close()
   self.router:close_ui()
end

---Close the current UI and return a result to the parent
---@param result any The result to pass to the parent UI
function RouterController:close_with_result(result)
   self.router:close_with_result(result)
end

---Open a child UI on top of the current one
---@param name fa.ui.UiName
---@param params? table Optional parameters to pass to the child UI
---@param context? any Optional context to help identify which node/item opened the child UI
function RouterController:open_child_ui(name, params, context)
   self.router:open_child_ui(name, params, context)
end

---Open a textbox for user input
---@param initial_text string
---@param context any Any value to help identify which node/item opened the textbox
---@param intro_message LocalisedString? Optional intro message to speak when opening
function RouterController:open_textbox(initial_text, context, intro_message)
   -- Store the context - result will go to top of stack when textbox closes
   GameGui.open_textbox(self.pindex, initial_text, context, intro_message)
end

---Set the search pattern for the current player
---@param pattern string?
function RouterController:set_search_pattern(pattern)
   router_state[self.pindex].search_pattern = pattern
end

---Get the current search pattern for the current player
---@return string?
function RouterController:get_search_pattern()
   return router_state[self.pindex].search_pattern
end

---Clear the search pattern for the current player
function RouterController:clear_search_pattern()
   router_state[self.pindex].search_pattern = nil
end

---@param name fa.ui.UiName
---@param params? table Optional parameters to pass to the UI
function Router:open_ui(name, params)
   -- Clear stack then push new UI
   self:_clear_ui_stack()
   self:_push_ui(name, params)
end

function Router:close_ui()
   self:_pop_ui()
end

-- Core stack operations

---Push a UI onto the stack (open it)
---@private
---@param name fa.ui.UiName
---@param params? table
---@param context? any Context to store with this UI entry
function Router:_push_ui(name, params, context)
   local stack = router_state[self.pindex].ui_stack

   -- Add to stack with context
   table.insert(stack, { name = name, context = context })

   -- Update GUI to show new top
   GameGui.set_active_ui(self.pindex, name)

   -- Play open sound
   UiSounds.play_open_inventory(self.pindex)

   -- Call the UI's open method
   if registered_uis[name] then registered_uis[name]:open(self.pindex, params or {}, self.controller) end
end

---Pop the top UI from the stack (close it)
---@private
---@return fa.ui.UiName? The name of the UI that was closed
function Router:_pop_ui()
   local stack = router_state[self.pindex].ui_stack
   if #stack == 0 then return nil end

   local top_entry = stack[#stack]
   local ui_name = top_entry.name

   -- Call the UI's close method
   if registered_uis[ui_name] then
      local ui = registered_uis[ui_name]
      if ui.close then ui:close(self.pindex) end
   end

   -- Remove from stack
   table.remove(stack)

   -- Play close sound
   UiSounds.play_close_inventory(self.pindex)

   -- Update GUI to show new top (or clear if empty)
   if #stack > 0 then
      GameGui.set_active_ui(self.pindex, stack[#stack].name)
   else
      GameGui.clear_active_ui(self.pindex)
   end

   return ui_name
end

---Clear all UIs from the stack
---@private
function Router:_clear_ui_stack()
   local stack = router_state[self.pindex].ui_stack
   if #stack == 0 then return end

   -- Close all UIs in reverse order (top to bottom)
   for i = #stack, 1, -1 do
      local entry = stack[i]
      local ui_name = entry.name
      if registered_uis[ui_name] then
         local ui = registered_uis[ui_name]
         if ui.close then ui:close(self.pindex) end
      end
   end

   -- Clear the stack
   router_state[self.pindex].ui_stack = {}

   -- Play single close sound
   UiSounds.play_close_inventory(self.pindex)

   -- Clear the GUI
   GameGui.clear_active_ui(self.pindex)
end

--[[
Ask if a UI is open.

This function primarily exists for the test framework.  It may be tempting to use it in other code, but you should
instead go through the UI event management at the bottom of this file, by overriding events in the ways others are
currently.
]]
---@param name fa.ui.UiName? If null, return true if any UI is open.
---@return boolean
function Router:is_ui_open(name)
   local stack = router_state[self.pindex].ui_stack
   if not name then return #stack > 0 end
   -- Check if name exists anywhere in the stack
   for _, entry in ipairs(stack) do
      if entry.name == name then return true end
   end
   return false
end

---@return fa.ui.UiName?
function Router:get_open_ui_name()
   local stack = router_state[self.pindex].ui_stack
   if #stack == 0 then return nil end
   return stack[#stack].name -- Return name from top of stack
end

---Open a child UI on top of the current one without closing it
---@param name fa.ui.UiName
---@param params? table Optional parameters to pass to the child UI
---@param context? any Optional context to store with this UI
function Router:open_child_ui(name, params, context)
   -- Just push without clearing
   self:_push_ui(name, params, context)
end

---Close the current UI and return a result to the parent
---@param result any The result to pass to the parent UI
function Router:close_with_result(result)
   local stack = router_state[self.pindex].ui_stack
   if #stack == 0 then return end

   -- Get the context of the UI being closed
   local closing_ui = stack[#stack]
   local context = closing_ui.context

   -- Get parent before popping
   local parent_ui = #stack > 1 and stack[#stack - 1] or nil

   -- Pop the current UI
   self:_pop_ui()

   -- Send result to parent if there is one
   if parent_ui and registered_uis[parent_ui.name] then
      registered_uis[parent_ui.name]:on_child_result(self.pindex, result, context, self.controller)
   end
end

-- Routers are stateless save for the pindex; we cache them to avoid the overhead of making new ones.
local router_cache = {}

---@param pindex number
---@return fa.ui.Router
function mod.get_router(pindex)
   assert(pindex ~= nil)
   if router_cache[pindex] then return router_cache[pindex] end
   local new_router = setmetatable({ pindex = pindex }, Router_meta)
   -- Create and cache the controller for this router
   new_router.controller = setmetatable({
      router = new_router,
      pindex = pindex,
   }, RouterController_meta)
   router_cache[pindex] = new_router
   return new_router
end

---Register a UI event that only fires when a UI is open
---@param event_name string|defines.events The event name or ID to register
---@param handler fun(event: EventData, pindex: integer): any? The handler function
local function register_ui_event(event_name, handler)
   EventManager.on_event(event_name, function(event, pindex)
      local router = mod.get_router(pindex)
      -- Only process if a UI is open
      if router:is_ui_open() then return handler(event, pindex) end
      -- No UI open, let it fall through
      return nil
   end, EventManager.EVENT_KIND.UI)
end

---Create a handler that routes to the appropriate TabList method
---@param method_name string The method name to call on the TabList
---@param modifiers? {control?: boolean, shift?: boolean, alt?: boolean} Optional modifier keys state
---@return fun(event: EventData, pindex: integer): any
local function create_ui_handler(method_name, modifiers)
   -- Default to no modifiers if not provided
   modifiers = modifiers or { control = false, shift = false, alt = false }

   return function(event, pindex)
      local router = mod.get_router(pindex)
      local stack = router_state[pindex].ui_stack

      -- Only check the top UI (the active one)
      if #stack > 0 then
         local top_entry = stack[#stack]
         local ui_name = top_entry.name
         if registered_uis[ui_name] then
            local ui = registered_uis[ui_name]
            -- Check if this UI has the method we're looking for
            if ui[method_name] then
               -- Create message builder for this event
               router.controller.message = MessageBuilder.new()

               -- Call the method on the UI, passing modifiers and controller
               ui[method_name](ui, pindex, modifiers, router.controller)

               -- Speak accumulated message if any
               local msg = router.controller.message:build()
               if msg then Speech.speak(pindex, msg) end

               -- Clear message
               router.controller.message = nil

               -- Return FINISHED to prevent world handlers from running
               return EventManager.FINISHED
            end
         end
      end

      -- No UI handled it or no UI open, let event pass through to world handlers
      return nil
   end
end

-- Register UI event handlers with UI priority at module load time
-- Movement keys (WASD)
register_ui_event("fa-w", create_ui_handler("on_up"))
register_ui_event("fa-s", create_ui_handler("on_down"))
register_ui_event("fa-a", create_ui_handler("on_left"))
register_ui_event("fa-d", create_ui_handler("on_right"))

-- Arrow keys (removed - using cursor anchoring instead)

-- Edge navigation (Ctrl+WASD)
register_ui_event("fa-c-w", create_ui_handler("on_top"))
register_ui_event("fa-c-s", create_ui_handler("on_bottom"))
register_ui_event("fa-c-a", create_ui_handler("on_leftmost"))
register_ui_event("fa-c-d", create_ui_handler("on_rightmost"))

-- Click/select (leftbracket is left click, rightbracket is right click)
register_ui_event("fa-leftbracket", create_ui_handler("on_click"))
register_ui_event("fa-rightbracket", create_ui_handler("on_right_click"))

-- Modified click handlers with modifiers
-- Alt+click (only leftbracket exists)
register_ui_event("fa-a-leftbracket", create_ui_handler("on_click", { alt = true }))

-- Control+click
register_ui_event("fa-c-leftbracket", create_ui_handler("on_click", { control = true }))
register_ui_event("fa-c-rightbracket", create_ui_handler("on_right_click", { control = true }))

-- Shift+click
register_ui_event("fa-s-leftbracket", create_ui_handler("on_click", { shift = true }))
register_ui_event("fa-s-rightbracket", create_ui_handler("on_right_click", { shift = true }))

-- Control+Shift+click
register_ui_event("fa-cs-leftbracket", create_ui_handler("on_click", { control = true, shift = true }))

-- Tab navigation (TAB and Shift+TAB)
register_ui_event("fa-tab", create_ui_handler("on_next_tab"))
register_ui_event("fa-s-tab", create_ui_handler("on_previous_tab"))

-- Section navigation (Ctrl+TAB and Ctrl+Shift+TAB)
register_ui_event("fa-c-tab", create_ui_handler("on_next_section"))
register_ui_event("fa-cs-tab", create_ui_handler("on_previous_section"))

-- K key reads coordinates
register_ui_event("fa-k", create_ui_handler("on_read_coords"))

-- Y key reads custom info
register_ui_event("fa-y", create_ui_handler("on_read_info"))

-- Accelerator keys - map to constants for UI flexibility
register_ui_event("fa-ca-c", function(event, pindex)
   local router = mod.get_router(pindex)
   local stack = router_state[pindex].ui_stack

   if #stack > 0 then
      local top_entry = stack[#stack]
      local ui_name = top_entry.name
      if registered_uis[ui_name] then
         local ui = registered_uis[ui_name]
         if ui.on_accelerator then
            -- Create message builder for this event
            router.controller.message = MessageBuilder.new()

            ui:on_accelerator(pindex, mod.ACCELERATORS.ENTER_CONSTANT, nil, router.controller)

            -- Speak accumulated message if any
            local msg = router.controller.message:build()
            if msg then Speech.speak(pindex, msg) end

            -- Clear message
            router.controller.message = nil

            return EventManager.FINISHED
         end
      end
   end
   return nil
end)

register_ui_event("fa-ca-s", function(event, pindex)
   local router = mod.get_router(pindex)
   local stack = router_state[pindex].ui_stack

   if #stack > 0 then
      local top_entry = stack[#stack]
      local ui_name = top_entry.name
      if registered_uis[ui_name] then
         local ui = registered_uis[ui_name]
         if ui.on_accelerator then
            -- Create message builder for this event
            router.controller.message = MessageBuilder.new()

            ui:on_accelerator(pindex, mod.ACCELERATORS.SELECT_SIGNAL, nil, router.controller)

            -- Speak accumulated message if any
            local msg = router.controller.message:build()
            if msg then Speech.speak(pindex, msg) end

            -- Clear message
            router.controller.message = nil

            return EventManager.FINISHED
         end
      end
   end
   return nil
end)

-- Backspace key for clearing
register_ui_event("fa-backspace", create_ui_handler("on_clear"))

-- E key closes the UI (inventory/menu close)
register_ui_event("fa-e", function(event, pindex)
   local router = mod.get_router(pindex)
   router:close_ui()
   return EventManager.FINISHED
end)

-- Handle textbox confirmation - this one needs special handling since it checks textbox validity
---@param event EventData.on_gui_confirmed
EventManager.on_event(defines.events.on_gui_confirmed, function(event)
   local pindex = event.player_index
   -- Check if this is our textbox
   if event.element and event.element.valid and event.element.name == "fa-text-input" then
      local router = mod.get_router(pindex)
      local top_ui_name = router:get_open_ui_name()

      if top_ui_name then
         local context = GameGui.get_textbox_context(pindex)
         -- Send result to the top UI on the stack
         local ui = registered_uis[top_ui_name]
         if ui and ui.on_child_result then
            -- Create message builder for this event
            router.controller.message = MessageBuilder.new()

            -- Pass result first, then context to the handler
            ui:on_child_result(pindex, event.element.text, context, router.controller)

            -- Speak accumulated message if any
            local msg = router.controller.message:build()
            if msg then Speech.speak(pindex, msg) end

            -- Clear message
            router.controller.message = nil
         end
         -- Close the textbox
         GameGui.close_textbox(pindex)
         return EventManager.FINISHED
      end
   end
   -- Not our textbox or no UI open
   return nil
end, EventManager.EVENT_KIND.UI)

-- Search navigation handlers
-- fa-s-enter: Next search result
register_ui_event("fa-s-enter", function(event, pindex)
   local router = mod.get_router(pindex)
   local stack = router_state[pindex].ui_stack

   if #stack > 0 then
      local top_entry = stack[#stack]
      local ui_name = top_entry.name
      if registered_uis[ui_name] then
         local ui = registered_uis[ui_name]
         if ui.supports_search and ui:supports_search(pindex, router.controller) then
            local pattern = router.controller:get_search_pattern()
            if not pattern or pattern == "" then
               UiSounds.play_ui_edge(pindex)
               Speech.speak(pindex, { "fa.search-no-more-results" })
               return EventManager.FINISHED
            end

            local pattern_lower = string.lower(pattern)
            local matcher = function(localised_string)
               local text = LocalisedStringCache.get(pindex, localised_string)
               if not text then return false end
               return string.find(string.lower(text), pattern_lower, 1, true) ~= nil
            end

            local message = MessageBuilder.new()
            local result = ui:search_move(message, pindex, 1, matcher, router.controller)
            if result == mod.SEARCH_RESULT.MOVED then
               UiSounds.play_menu_move(pindex)
               local msg = message:build()
               if msg then Speech.speak(pindex, msg) end
               return EventManager.FINISHED
            elseif result == mod.SEARCH_RESULT.WRAPPED then
               UiSounds.play_menu_wrap(pindex)
               local msg = message:build()
               if msg then Speech.speak(pindex, msg) end
               return EventManager.FINISHED
            elseif result == mod.SEARCH_RESULT.DIDNT_MOVE then
               UiSounds.play_ui_edge(pindex)
               Speech.speak(pindex, { "fa.search-no-more-results" })
               return EventManager.FINISHED
            end
            -- NO_SUPPORT falls through
         end
      end
   end
   return nil
end)

-- fa-c-enter: Previous search result
register_ui_event("fa-c-enter", function(event, pindex)
   local router = mod.get_router(pindex)
   local stack = router_state[pindex].ui_stack

   if #stack > 0 then
      local top_entry = stack[#stack]
      local ui_name = top_entry.name
      if registered_uis[ui_name] then
         local ui = registered_uis[ui_name]
         if ui.supports_search and ui:supports_search(pindex, router.controller) then
            local pattern = router.controller:get_search_pattern()
            if not pattern or pattern == "" then
               UiSounds.play_ui_edge(pindex)
               Speech.speak(pindex, { "fa.search-no-more-results" })
               return EventManager.FINISHED
            end

            local pattern_lower = string.lower(pattern)
            local matcher = function(localised_string)
               local text = LocalisedStringCache.get(pindex, localised_string)
               if not text then return false end
               return string.find(string.lower(text), pattern_lower, 1, true) ~= nil
            end

            local message = MessageBuilder.new()
            local result = ui:search_move(message, pindex, -1, matcher, router.controller)
            if result == mod.SEARCH_RESULT.MOVED then
               UiSounds.play_menu_move(pindex)
               local msg = message:build()
               if msg then Speech.speak(pindex, msg) end
               return EventManager.FINISHED
            elseif result == mod.SEARCH_RESULT.WRAPPED then
               UiSounds.play_menu_wrap(pindex)
               local msg = message:build()
               if msg then Speech.speak(pindex, msg) end
               return EventManager.FINISHED
            elseif result == mod.SEARCH_RESULT.DIDNT_MOVE then
               UiSounds.play_ui_edge(pindex)
               Speech.speak(pindex, { "fa.search-no-more-results" })
               return EventManager.FINISHED
            end
            -- NO_SUPPORT falls through
         end
      end
   end
   return nil
end)

-- fa-c-f: Open search pattern setter
register_ui_event("fa-c-f", function(event, pindex)
   local router = mod.get_router(pindex)
   local stack = router_state[pindex].ui_stack

   if #stack > 0 then
      local top_entry = stack[#stack]
      local ui_name = top_entry.name
      if registered_uis[ui_name] then
         local ui = registered_uis[ui_name]
         -- Check if this UI supports search
         if ui.supports_search then
            local supports = ui:supports_search(pindex, router.controller)
            if supports then
               -- Populate the search cache by requesting translations (async, in background)
               ui:search_hint(pindex, function(localised_string)
                  LocalisedStringCache.hint_submit(pindex, localised_string)
               end, router.controller)

               -- Open search setter (translations populate in background while user types)
               router:open_child_ui(mod.UI_NAMES.SEARCH_SETTER, {}, { node = "search_setter" })
               return EventManager.FINISHED
            end
         end
      end
   end

   -- UI doesn't support search
   UiSounds.play_ui_edge(pindex)
   Speech.speak(pindex, { "fa.search-not-supported" })
   return EventManager.FINISHED
end)

return mod
