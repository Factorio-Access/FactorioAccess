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

local mod = {}

---@enum fa.ui.UiName
mod.UI_NAMES = {
   INVENTORY = "inventory",
   BUILDING = "building",
   VEHICLE = "vehicle",
   CRAFTING = "crafting",
   TRAVEL = "travel",
   PLAYER_TRASH = "player_trash",
   GUNS = "guns",
   TECHNOLOGY = "technology",
   CRAFTING_QUEUE = "crafting_queue",
   BELT = "belt",
   WARNINGS = "warnings",
   PUMP = "pump",
   RAIL_BUILDER = "rail_builder",
   TRAIN_STOP = "train_stop",
   ROBOPORT = "roboport",
   BLUEPRINT = "blueprint",
   BLUEPRINT_BOOK = "blueprint_book",
   CIRCUIT_NETWORK = "circuit_network",
   SIGNAL_SELECTOR = "signal_selector",
   PROMPT = "prompt",
   TRAIN = "train",
   SPIDERTRON = "spidertron",
   BUILDING_NO_SECTORS = "building_no_sectors",
   VEHICLE_NO_SECTORS = "vehicle_no_sectors",
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

---@param name fa.ui.UiName
function Router:open_ui(name)
   router_state[self.pindex].ui_name = name
end

function Router:close_ui()
   router_state[self.pindex].ui_name = nil
end

---@param name fa.ui.UiName? If null, return true if any UI is open.
---@return boolean
function Router:is_ui_open(name)
   if not name then return router_state[self.pindex].ui_name ~= nil end
   return router_state[self.pindex].ui_name == name
end

-- If a UI is open and one of the names in this list, return true.
---@param list fa.ui.UiName[]
---@return boolean
function Router:is_ui_one_of(list)
   for _, n in pairs(list) do
      if self:is_ui_open(n) then return true end
   end

   return false
end

---@return fa.ui.UiName?
function Router:get_open_ui_name()
   return router_state[pindex].ui_name
end

-- Routers are stateless save for the pindex; we cache them to avoid the overhead of making new ones.
local router_cache = {}

---@param pindex number
---@return fa.ui.Router
function mod.get_router(pindex)
   assert(pindex ~= nil)
   if router_cache[pindex] then return router_cache[pindex] end
   return setmetatable({ pindex = pindex }, Router_meta)
end

return mod
