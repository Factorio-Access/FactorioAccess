--[[
Stuff internal to the UI system. This file exists to avoid circular imports; the
public API is scripts/ui.lua and ui/controls, which are mostly reexported via
ui.lua for convenience.

Mainly this is functions to manipulate the global state and do event handling,
as pulling those out to a file avoids any possible issues around circular
importing.  If controls had to require ui.lua, and ui.lua wants to reexport the
controls, that won't work. Instead controls require this file.

The rest of this comment explains the internal structure.  For better
end-user-facing docs and conceptual info, see ui.lua.  If you are building a new
interface look at ui/flows/fast-travel.lua.  This handles most of the following
in a way that allows for building interfaces without having to fully understand
it.  In other words most of the following is internal to the implementation.

To briefly summarize, the registered panels are mostly opaque.  For example the
inventory workflow is in ui/workflows, and someone wanting to play with the
inventory is supposed to just open it.

UIs have 3 entities:

- Panels, which are "windows".
- Tabs. All panels must have at least one tab.
- Controls. Controls respond to events.  Technically panels and windows are
  special controls.

Panels and tabs are special.  Panels always handle all events fed to them, even
if there is nowhere to send it.  That is unhandled events are swallowed.  Tabs
are always immediate children of panels, and always handle only tab and
shift+tab, via evt_next_tab and evt_prev_tab.  A panel without tabs from the UX
perspective is a panel with one tab.

To allow for nesting, we place a stack for panels in global.  This module owns
(for now) global.ui_new.  Once we remove the old systems, this will change to
global.ui.  It looks like this.

```
{
   stack = {
      -- Rightmost is currently active.
      panels = { name, name, name },
   },
   panel_states = { name: opaque, opaque, ... }
}
```

The code in the mod is already enforced to be the same for all players by
Factorio's hashing, and as a consequence users need only consistently build the
same UI.  The non-global-safe code can thus include functions in tables.  This
module will include the global state necessary for each piece to run in the
calls.

When this module says "calls", it means `a.b`, which can be done however you
want.  It doesn't care how, and it won't be trying to save functions in global,
so a simple table of closures or normal functions is generally good enough, and
it's not necessary to do more complicated things with metatables.

Event dispatching finds the top of the panel stack.  Then it locates the
player's focus.  It climbs up the stack until something handles it, giving each
control a chance.  As an example of why this is important, it allows for
building the fast travel menu as a vertical menu with horizontal rows, where the
horizontal rows  are other controls: the deepest control handles
left/right/click, the vertical part handles up/down/search.  In the case of
other boring menus with a fixed list, using a label control lets them not worry
about state themselves.  That said, this is actually split: panels themselves
handle the focus management and panel-local dispatch, not this file.

To allow controls to respond to state changes, they periodically have `rebuild`
called on them, starting at the panel and moving down (because starting at the
bottom for a control that may no longer need to exist isn't cheap).  In many
cases options also support being functions instead of fixed values.  For the
time being, however, the only argument such functions get is the player index,
so use closures for any extra state.  When implementing a new control, don't
read user-passed fields directly.  Instead, use `ui_index` to index into the
table, which will call functions whenever it hits one.  Actually wanting
closures to get through to the control itself must be handled specially by the
control as these will be mistaken for lazy values.  This mechanism allows one to
write functions to compute something (e.g. an item and a count), then just plug
it in and the UI will do the rest.

Or put more simply, controls themselves are "normal" objects, and only part
lives in global state.

It's fine for closures to capture things, but only so long as they can
reconstitute between  restarts.  That is, capturing some settings or something
is fine.  Capturing a computed value probably isn't.

Each function at the panel level in the internals is passed a section of global
state derived from the player who triggered the event.  This defaults to the
empty table.  They also get pindex.  All state must remember to integrate pindex
if reaching beyond the encapsulated management.  This is because each panel
builds once only and must be used with all players, each of whom have their own
stack and state.

We would like to be more convenient.  Unfortunately Factorio has both
straightforward state management like the travel menu, and more complex things
like listing off entities which sometimes don't have a unit number and thus
cannot be uniquely identified.

One may be asking how one handles the case in which some control changes in a
way incompatible with ui global state.  It's wiped out in on_init and
on_configuration_changed.  That covers mod and game updates both, as well as
settings changes.  It turns out it's not possible to reliably detect save
restarts, so we cannot handle that case.

Panels have to register at the time control.lua is loaded, and there can only be
one of each name.  This basically means that for a complex workflow or whatever,
it may reuse a panel it already made if it wants, but it can't make more after
control.lua finishes loading.  These registration functions return the passed
name.  So:

```
mod.travel_menu = ustat.register('travel', travel_builder)
assert(mod.travel_menu == 'travel')
```

And then panels are referred to by their names.

The workaround for multiple panels or recursive panels or w/e that doesn't
require reusing is to register multiple under different names.  If this is ever
required, it is best to re-examine the problem, but this module could probably
be extended if someone comes up with a good use case.

All this said, the concrete flow for an event is as follows:

- This file finds the panel
- It gets the panel's global state and calls the panel's event function, passing
  it the global state.
- The panel finds the focused control and goes up to the panel as the root, then
  tells ui that it handled it even if it didn't.
]]

local mod = {}

---@class PanelStack
---@field panels  string[]

---@class UiPlayerState
---@field stack PanelStack
---@field panel_states table<string, any>

---@alias UiGlobalState UiPlayerState[]

-- Return a reference to our part of global state.  UI usage before on_init is
-- not possible and will result in nil indexing errors.
--
-- Just a table of players.  Each player gets their own state.
local function ui_global()
   if not global.ui_new then mod.reset_global() end

   return global.ui_new
end

-- Used to reset our global state in on_init, on_configuration_changed.
function mod.reset_global()
   global.ui_new = {}
end

--- Index a table calling functions whenever we find one before applying the
--  next index.  If the last index is a function, also call it, then return that
--  value.
mod.ui_index = function(pindex, tab, first, ...)
   local nargs = select("#", ...)
   local ret = tab[first]

   for i = 1, nargs do
      if type(ret) == "function" then ret = ret(pindex) end
      ret = ret[select(i, ...)]
   end

   -- Possibly we need to resolve the final function call here.
   if type(ret) == "function" then ret = ret(pindex) end
   return ret
end

--- @returns UiPlayerState
function mod.global_state_for_player(pindex)
   local ug = ui_global()
   if not ug[pindex] then ug[pindex] = { stack = { panels = {} }, panel_states = {} } end
   return ug[pindex]
end

-- Cache of panel builder functions
local panel_builder_registry = {}

-- Cache of the first result of the builder function, the vtable with which to
-- control the panel, and initial global state.
--- @type table<string, { vtable: any, initial_state: any}>
local panel_built_results = {}

-- Register a panel's builder.
--
-- Builders should return two values.  The first is a table of functions which
-- will be passed the panel's global state.  The second is the initial global
-- state to use for this panel.  The initial global state and the vtable need to
-- be deterministic.  The global state is cloned per player and installed if and
-- only if there already isn't one.  The builder is called only once per run,
-- and the results must apply to all players.
--
---@param name string
---@param builder function
---@returns string
function mod.register_panel(name, builder)
   assert(panel_builder_registry[name] == nil)
   panel_builder_registry[name] = builder
   return name
end

function mod.is_open(pindex)
   local state = mod.global_state_for_player(pindex)
   return #state.stack.panels == 0
end

---@param pindex number
--- @returns string?
--
-- Get the name of the currently active panel. If this returns nil the UI is
-- closed.
function mod.active_panel_name(pindex)
   local l = mod.global_state_for_player(pindex)
   local stack_ent = l.stack.panels[#l.stack.panels]
   return stack_ent
end

local function active_panel_state(pindex)
   local ug = ui_global()[pindex]
   local len = #ug.stack.panels
   if len == 0 then return end
   local s = ug.stack.panels[len]
   if not ug.panel_states[s] then ug.panel_states[s] = {} end
   return ug.panel_states[s.panel_name]
end

-- Get or build a panel.  Return the vtable and the global state in that order.
function mod.get_panel(pindex, name)
   assert(panel_builder_registry[name])
   local pstate = mod.global_state_for_player(pindex)
   if not panel_built_results[name] then
      local vtab, init = panel_builder_registry[name]()
      panel_built_results[name] = { vtable = vtab, initial_state = init }
   end

   if not pstate.panel_states[name] then
      pstate.panel_states[name] = table.deepcopy(panel_built_results[name].initial_state)
   end

   return panel_built_results[name].vtable, pstate.panel_states[name]
end

function mod.ui_is_open(pindex)
   return next(mod.global_state_for_player(pindex).stack.panels) ~= nil
end

-- Build a panel for a given pindex if it has not been cached, then push it onto the panel stack.
---@param name string
---@returns nil
function mod.oepn_panel(pindex, name)
   -- Just ensure it's built.
   mod.get_panel(pindex, name)
   local ug = mod.global_state_for_player(pindex)
   table.insert(ug.stack.panels, name)
end

-- Compare to this unique value to find out if an operation is not supported.
mod.NOT_SUPPORTED = { "NOT SUPPORTED!" }
mod.NOT_OPEN = { "NOT OPEN!" }

-- Call fn_name with the listed arguments on obj.  Returns mod.NOT_SUPPORTED if
-- the function isn't there.  obj is not implicitrly passed.
function mod.call_against(obj, fn_name, ...)
   local f = obj[fn_name]
   if not f then return mod.NOT_SUPPORTED end
   return f(...)
end

--- Call a function for a panel at the top of the player's stack.
--
-- Fetches the state, and makes the call panel.fn(pindex, vtab,
-- global_state_for_this_player, ...)
--
-- Returns either the sentinel value NOT_SUPPORTED or the return value of the
-- function.  IMPORTANT: if this returns nil it is from the underlying function.
--
---@param pindex number
--- @param fn_name string
--- @returns any?
function mod.call_on_active_panel(pindex, fn_name, ...)
   local active = mod.active_panel_name(pindex)
   if not active then return mod.NOT_OPEN end
   local vtab, g = mod.get_panel(pindex, active)
   return mod.call_against(vtab, fn_name, pindex, vtab, g, ...)
end

-- Internal. name is prefixed with evt_ by the closure variant below, , then
-- passed off to the currently open panel's handle_event function.  Returns
-- whether or not the caller should treat the event as handled which, in this
-- case, is synonymous with whether or not the UI is open.
--
---@param pindex number
---@param name string
--- @returns bool
function mod.dispatch_event(pindex, name, ...)
   local r = mod.call_on_active_panel(pindex, name, ...)
   return r ~= mod.NOT_SUPPORTED and r ~= mod.NOT_OPEN
end

---@type string[]
--
-- An array of every event name this module uses in no particular order, with
-- the evt_ prefix prepended.  Occasionally useful to add something for all
-- events in a loop.
mod.all_event_names = {}

local function decl_evt_fn(name)
   local name = "evt_" .. name
   table.insert(mod.all_event_names, name)

   return function(pindex, ...)
      return mod.dispatch_event(pindex, name, ...)
   end
end

-- these are our event handlers.  All take the pindex, save for click, which
-- needs to know about ctrl and shift as well.

--- @alias SimpleEventFn fun(pindex: number): boolean

---@type SimpleEventFn
mod.evt_left = decl_evt_fn("left")

---@type SimpleEventFn
mod.evt_right = decl_evt_fn("right")

---@type SimpleEventFn
mod.evt_up = decl_evt_fn("up")

---@type SimpleEventFn
mod.evt_down = decl_evt_fn("down")

---@type SimpleEventFn
mod.evt_tab_forward = decl_evt_fn("tab_forward")

---@type SimpleEventFn
mod.evt_tab_backward = decl_evt_fn("tab_backward")

---@alias ClickEvt fun(pindex: number, flags: { ctrl: boolean, shift: boolean, alt: boolean }): boolean

-- Click events are [(left) and ] (right) by default.  This doesn't quite map to
-- the mod's controls in the world vs vanilla, but it does map to the UI
-- reasonably well.

---@type ClickEvt
mod.evt_left_click = decl_evt_fn("left_click")

---@type ClickEvt
mod.evt_right_click = decl_evt_fn("right_click")

--These are types used internally to easily name "lazy" values that can be
--either a function or a value.

---@alias LazyString fun(pindex: number): string
---@alias LazyNumber fun(pindex: number): number
---@alias LazyBool fun(pindex: number): boolean
---@alias LazyTable fun(pindex: number): table
---@alias LazyArray fun(pindex: number): any[]


---@class ControlDef
---@field vtable table
---@field global_state table


return mod
