---UI Event Routing Module -This module handles routing of events to registered UI components at UI priority.
---
---Why this exists as a separate module: -The mod has a circular dependency issue that prevents router.lua from directly
---requiring EventManager:
---  - EventManager requires player-init (to initialize players on first event)
---  - player-init requires bump-detection (as part of player initialization)
---  - bump-detection requires router (to check UI state)
---  - If router required EventManager, we'd have a circular dependency
---
---This module breaks the cycle by being a leaf node in the dependency graph. -It's loaded from control.lua after all
--other modules, so it can safely -require both EventManager and router without creating a cycle.
---
---Additionally, Factorio requires all event handlers to be registered at the -top level during module loading, not in
--callbacks like on_init.

local EventManager = require("scripts.event-manager")
local UiRouter = require("scripts.ui.router")

local mod = {}

---Storage for registered TabList instances
---@type table<string, fa.ui.TabList>
local registered_uis = {}

---Register a TabList UI with the event routing system
---@param tablist fa.ui.TabList
function mod.register_ui(tablist)
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
local function get_all_registered_uis()
   return registered_uis
end

-- Set the getter in the router module
UiRouter.get_registered_uis = get_all_registered_uis

---Create a handler that routes to the appropriate TabList method
---@param method_name string The method name to call on the TabList
---@param modifiers? {control?: boolean, shift?: boolean, alt?: boolean} Optional modifier keys state
---@return fun(event: EventData, pindex: integer): any
local function create_ui_handler(method_name, modifiers)
   -- Default to no modifiers if not provided
   modifiers = modifiers or { control = false, shift = false, alt = false }

   return function(event, pindex)
      local router = UiRouter.get_router(pindex)
      local open_ui_name = router:get_open_ui_name()

      -- Only handle if UI is open AND registered with the new system
      if open_ui_name and registered_uis[open_ui_name] then
         local tablist = registered_uis[open_ui_name]
         -- Call the method on the TabList, passing modifiers as third parameter
         tablist[method_name](tablist, pindex, modifiers)
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
-- TODO: fa-cs-rightbracket keybinding doesn't exist in data/input.lua
-- EventManager.on_event(
--    "fa-cs-rightbracket",
--    create_ui_handler("on_right_click", { control = true, shift = true }),
--    EventManager.EVENT_KIND.UI
-- )

-- Tab navigation (TAB and Shift+TAB)
EventManager.on_event("fa-tab", create_ui_handler("on_next_tab"), EventManager.EVENT_KIND.UI)
EventManager.on_event("fa-s-tab", create_ui_handler("on_previous_tab"), EventManager.EVENT_KIND.UI)

-- K key reads coordinates
EventManager.on_event("fa-k", create_ui_handler("on_read_coords"), EventManager.EVENT_KIND.UI)

-- Y key reads custom info
EventManager.on_event("fa-y", create_ui_handler("on_read_info"), EventManager.EVENT_KIND.UI)

return mod
