--[[
Panels are the root of a UI workflow.  They contain control-common stuff, plus
the root event handling, focus and state management, etc.

All of a panel's direct state is derive from two things: some state in global,
and the result of a builder function used to describe this panel to itself.  You
supply the builder, which gets a builder object as a single argument; that
object allows for adding controls.  Each kind of control returns a builder
itself, linked to the in-progress panel, to build control-specific stuff.

Since this mod has one "control" per panel, for lack of better phrasing, and tab
actually moves between tabs, controls themselves handle focus to subcontrols as
necessary, and document what may be nested under them.  Panel tabs have only one
child control called the root.

As with the panel, controls get their vtable, their state, and a pindex.  Their
vtables are not cached between panels and may use the pindex, as long as it is
safe to call the builder n times.  This is necessary: otherwise, you couldn't
make simple menus.  Internally, the vtable is shoved inside a cache in our
stateful vtable; it is suggested that child controls do the same, except that
their vtables are already per player.  Immediate child controls also obtain a
controller that can talk to the panel it's in and the tab, e.g. to switch tabs
or close the panel.

The builder itself contains some implicit state.  global-state.lua will call the
builder for a registered panel, then yank that out and cache it.  This is
supplied back for all other panel ops.

specifically, all internal functions in this file will be called as (pindex,
vtable, gstate, ...other args).
]]

local ustate = require("scripts.ui.global-state")
local forwarding_vtab = require("scripts.ui.forwarding-vtab").forwarding_vtab
local mod1 = require("math-helpers").mod1

local mod = {}

---@alias ControlBuilderFn fun(pindex:number): ControlDef

---@class TabEphemeralState
---@field name string
---@field title LocalisedString
---@field control ControlBuilderFn

---@class TabGlobalState
---@field focused_control number Index in control_order.

---@class PanelGlobalState
---@field active_tab number
---@field tab_states table<string, TabGlobalState>

---@class TabBuilderCallRecord
---@field name string
---@field title LocalisedString
---@field builder ControlBuilderFn

---@alias TabFun  fun(name:string, title:LocalisedString, control_builder: ControlBuilderFn)

---@class PanelEphemeralState
---@field tab_vtables table<number, table<string, table>> The vtables for root controls.
---@field tab_builders TabBuilderCallRecord[]

---@class BuilderOutcome
---@field ephemeral PanelEphemeralState

---@class PanelVtab extends table
---@field state PanelEphemeralState

---@class PanelBuilder
---@field  add_tab TabFun

---@returns PanelBuilder
local function get_builder()
   ---@type PanelEphemeralState
   local vstate = {
      tab_builders = {},
      tab_vtables = {},
   }

   return {
      add_tab = function(name, title, builder)
         table.insert(vstate.tab_builders, { name = name, title = title, builder = builder })
      end,

      ---@returns BuilderOutcome
      _outcome = function()
         return vstate
      end,
   }
end

--@param v PanelVtable
---@param g PanelGlobalState
local function tab_move(pindex, v, g, delta)
   local state = v.state
   local next_ind = mod1(g.active_tab + delta, #state.tab_builders)
   local title = state.tab_builders[next_ind].title
   g.active_tab = next_ind
   printout(title)
end

---@param v PanelVtab
---@param g PanelGlobalState
local function find_tab_vtab(pindex, v, g)
   local ephemeral = v.state
   local r1 = ephemeral.tab_vtables[g.active_tab]
   local r2 = g.tab_states[g.active_tab]
   return r1, r2
end

---@returns PanelVtab
local function make_vtab()
   local vtab = forwarding_vtab(find_tab_vtab)
   vtab.state = {}

   vtab.evt_tab_forward = function(pindex, v, g)
      tab_move(pindex, v, g, 1)
   end

   vtab.evt_tab_backward = function(pindex, v, g)
      tab_move(pindex, v, g, -1)
   end

   return vtab
end

---@param name string
---@param builder fun(builder: PanelBuilder)
function mod.register_panel(name, builder)
   ustate.register_panel(name, function()
      local b = get_builder()
      builder(b)
      local vstate = b._outcome()
      local vtab = make_vtab()
      vtab.state = vstate
      return vtab, {
         active_tab = 1,
         tab_states = {},
      }
   end)
end

return mod
