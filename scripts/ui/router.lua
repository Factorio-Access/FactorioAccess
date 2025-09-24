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

local mod = {}

---Storage for registered TabList instances
---@type table<string, fa.ui.TabList>
local registered_uis = {}

---Register a TabList UI with the event routing system
---@param tablist fa.ui.TabList
function mod.register_ui(tablist)
   assert(type(tablist.ui_name) == "string")
   registered_uis[tablist.ui_name] = tablist
end

---Get a registered UI by name
---@param ui_name string
---@return fa.ui.TabList?
function mod.get_registered_ui(ui_name)
   return registered_uis[ui_name]
end

---Get all registered UIs
---@return table<string, fa.ui.TabList>
function mod.get_registered_uis()
   return registered_uis
end

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
   CIRCUIT_NETWORK = "circuit_network",
   SIGNAL_SELECTOR = "signal_selector",
   SPIDERTRON = "spidertron",
}

---@class fa.ui.RouterState
---@field ui_name fa.ui.UiName

---@type table<number, fa.ui.RouterState>
local router_state = StorageManager.declare_storage_module("ui_router", {}, {
   ephemeral_state_version = 1,
})

---@class fa.ui.Router
---@field pindex number
local Router = {}
local Router_meta = { __index = Router }

---@class fa.ui.RouterController
---@field router fa.ui.Router
---@field pindex number
local RouterController = {}
local RouterController_meta = { __index = RouterController }

function RouterController:close()
   self.router:close_ui()
end

---@param name fa.ui.UiName
---@param params? table Optional parameters to pass to the UI
function Router:open_ui(name, params)
   -- If switching to a different UI, close the current one first. That's not just based on name; the current UI might
   -- be reopening on, e.g., a different entity.
   self:_close_current_ui()

   -- Set the UI as open in router state
   router_state[self.pindex].ui_name = name

   -- Get the registered UI and open it with params
   if registered_uis[name] then
      -- Create a controller for the opening UI
      local controller = setmetatable({
         router = self,
         pindex = self.pindex,
      }, RouterController_meta)
      registered_uis[name]:open(self.pindex, params or {}, controller)
   end
   -- If UI is not registered, it might be a legacy UI name - just set it as open
   -- This maintains backward compatibility with old UI system
end

function Router:close_ui()
   self:_close_current_ui()
   router_state[self.pindex].ui_name = nil
end

---Internal method to close the currently open UI
---@private
function Router:_close_current_ui()
   local current_ui = router_state[self.pindex].ui_name
   if not current_ui then return end

   -- Get the registered UI and call its close method
   if registered_uis[current_ui] then
      local ui = registered_uis[current_ui]
      if ui.close then ui:close(self.pindex) end
   end
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
   if not name then return router_state[self.pindex].ui_name ~= nil end
   return router_state[self.pindex].ui_name == name
end

---@return fa.ui.UiName?
function Router:get_open_ui_name()
   return router_state[self.pindex].ui_name
end

-- Routers are stateless save for the pindex; we cache them to avoid the overhead of making new ones.
local router_cache = {}

---@param pindex number
---@return fa.ui.Router
function mod.get_router(pindex)
   assert(pindex ~= nil)
   if router_cache[pindex] then return router_cache[pindex] end
   local new_router = setmetatable({ pindex = pindex }, Router_meta)
   router_cache[pindex] = new_router
   return new_router
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
      local open_ui_name = router:get_open_ui_name()

      -- Only handle if UI is open AND registered with the new system
      if open_ui_name and registered_uis[open_ui_name] then
         local tablist = registered_uis[open_ui_name]
         -- Create a fresh controller for this event
         local controller = setmetatable({
            router = router,
            pindex = pindex,
         }, RouterController_meta)
         -- Call the method on the TabList, passing modifiers and controller
         tablist[method_name](tablist, pindex, modifiers, controller)
         -- Return FINISHED to prevent world handlers from running
         return EventManager.FINISHED
      end

      -- UI not registered or not open, let event pass through to legacy handlers
      return nil
   end
end

-- Register UI event handlers with UI priority at module load time
-- Movement keys (WASD)
EventManager.on_event("fa-w", create_ui_handler("on_up"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-s", create_ui_handler("on_down"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-a", create_ui_handler("on_left"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-d", create_ui_handler("on_right"), EventManager.EVENT_KIND.UI)

-- Arrow keys
EventManager.on_event("fa-up", create_ui_handler("on_up"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-down", create_ui_handler("on_down"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-left", create_ui_handler("on_left"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-right", create_ui_handler("on_right"), EventManager.EVENT_KIND.UI)

-- Edge navigation (Ctrl+WASD)
EventManager.on_event("fa-c-w", create_ui_handler("on_top"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-c-s", create_ui_handler("on_bottom"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-c-a", create_ui_handler("on_leftmost"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-c-d", create_ui_handler("on_rightmost"), EventManager.EVENT_KIND.UI)

-- Click/select (leftbracket is left click, rightbracket is right click)
EventManager.on_event("fa-leftbracket", create_ui_handler("on_click"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-rightbracket", create_ui_handler("on_right_click"), EventManager.EVENT_KIND.UI)

-- Modified click handlers with modifiers
-- Control+click
EventManager.on_event("fa-c-leftbracket", create_ui_handler("on_click", { control = true }), EventManager.EVENT_KIND.UI)
EventManager.on_event(
   "fa-c-rightbracket",
   create_ui_handler("on_right_click", { control = true }),
   EventManager.EVENT_KIND.UI
)

-- Shift+click
EventManager.on_event("fa-s-leftbracket", create_ui_handler("on_click", { shift = true }), EventManager.EVENT_KIND.UI)
EventManager.on_event(
   "fa-s-rightbracket",
   create_ui_handler("on_right_click", { shift = true }),
   EventManager.EVENT_KIND.UI
)

-- Control+Shift+click
EventManager.on_event(
   "fa-cs-leftbracket",
   create_ui_handler("on_click", { control = true, shift = true }),
   EventManager.EVENT_KIND.UI
)

-- Tab navigation (TAB and Shift+TAB)
EventManager.on_event("fa-tab", create_ui_handler("on_next_tab"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-s-tab", create_ui_handler("on_previous_tab"), EventManager.EVENT_KIND.UI)

-- Section navigation (Ctrl+TAB and Ctrl+Shift+TAB)
EventManager.on_event("fa-c-tab", create_ui_handler("on_next_section"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-cs-tab", create_ui_handler("on_previous_section"), EventManager.EVENT_KIND.UI)

-- K key reads coordinates
EventManager.on_event("fa-k", create_ui_handler("on_read_coords"), EventManager.EVENT_KIND.UI)

-- Y key reads custom info
EventManager.on_event("fa-y", create_ui_handler("on_read_info"), EventManager.EVENT_KIND.UI)

-- E key closes the UI (inventory/menu close)
EventManager.on_event("fa-e", function(event)
   local pindex = event.player_index
   local router = mod.get_router(pindex)

   router:close_ui()
   return EventManager.FINISHED
end, EventManager.EVENT_KIND.UI)

return mod
