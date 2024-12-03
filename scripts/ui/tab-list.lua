--[[
Holds a list of named tabs, and lets you select between them.  This is a lesser
form of #263, which can be converted to the full form as a special case, by
creating a layer that just calls the methods.  That's a good idea anyway:
ultimately no one wants to write complex UI by individually handling keys.

For now this does not support dynamicism.  That is to say that tabs must be
declared at the top level of a file.  You don't get multiple instances per
player.  For example you can't have two open belt analyzers.  As is the theme,
this can also be extended later once we are at the point of being able to have a
proper framework.  In particular, layers can be used to provide the missing UI
stack abstractions that would allow multiple arbitrary sets of UIs to all be
open at once.

For now this isn't super documented.  If you are looking for some overarching
framework you won't find it.  That comes later.  This just gets us off the
ground.

This is the top level of the UI hierarchy and also handles the state management.
Each tab will receive a context with a field to use for persistent state.
Whatever it stores there persists.  It can reset this state by forcing closure;
to do so, it should write `force_close=true` to the context.  A shared state,
also cleared on forced closure, is `shared_state`.  Callbacks passed to creation
of this tablist can initialize the shared state, but cannot print to the player
by design; do not perform mutable actions in state setup or else.

To clarify how input gets here, this is currently hardcoded in the menu logic in
control.lua.  That is, by checking global.players[pindex].menu_name, and setting
it for the open tab list.

You should not use printout. Instead, you are given a builder in the context.
Sometimes, the tab needs to add output before yours, so you should print through
that.
]]
local MessageBuilder = require("scripts.message-builder")
local StorageManager = require("scripts.storage-manager")
local Math2 = require("math-helpers")

local mod = {}

---@class fa.ui.TabContext
---@field pindex number
---@field player LuaPlayer
---@field state table Goes into storage.
---@field shared_state table
---@field parameters table Whatever was passed to :open()
---@field force_close boolean If true, close this tablist.
---@field message fa.MessageBuilder

---@alias fa.ui.SimpleTabHandler fun(self, fa.ui.TabContext)

---@class fa.ui.TabCallbacks
---@field on_tab_focused fa.ui.SimpleTabHandler?
---@field on_tab_unfocused fa.ui.SimpleTabHandler?
---@field on_tab_list_opened fa.ui.SimpleTabHandler?
---@field on_tab_list_closed fa.ui.SimpleTabHandler?
---@field on_up fa.ui.SimpleTabHandler?
---@field on_down fa.ui.SimpleTabHandler?
---@field on_left fa.ui.SimpleTabHandler?
---@field on_right fa.ui.SimpleTabHandler?

---@class fa.ui.TabDescriptor
---@field name string
---@field title LocalisedString? If set, read out when the tab changes to this tab.
---@field callbacks fa.ui.TabCallbacks

---@class fa.ui.TabListDeclaration (exact)
---@field menu_name string
---@field tabs fa.ui.TabDescriptor[]
---@field shared_state_setup (fun(number, table): table)? passed the parameters and pindex, should return a shaerd state.
---@field resets_to_first_tab_on_open boolean?

---@class fa.ui.TabListStorageState
---@field active_tab number
---@field tab_states table<string, table>
---@field parameters any
---@field currently_open boolean
---@field shared_state table

---@type table<number, table<string, fa.ui.TabListStorageState>>
local tablist_storage = StorageManager.declare_storage_module("tab_list", {})

---@class fa.ui.TabList
---@field descriptors  table<string, fa.ui.TabDescriptor>
---@field menu_name string
---@field tab_order string[]
---@field shared_state_initializer (fun(number, table): table)?
---@field declaration fa.ui.TabListDeclaration
local TabList = {}
local TabList_meta = { __index = TabList }
mod.TabList = TabList

-- Returns whatever the callback returns, including special responses.  Does
-- nothing if this tablist is not open, which can happen when calling a bunch of
-- events back to back if the tab list has to close in the middle of a sequence
-- of actions.
---@param msg_builder fa.MessageBuilder?
---@param params any[]?
function TabList:_do_callback(pindex, target_tab_index, cb_name, msg_builder, params)
   msg_builder = msg_builder or MessageBuilder.MessageBuilder.new()
   params = params or {}

   local tl = tablist_storage[pindex][self.menu_name]
   local tabname = self.tab_order[target_tab_index]
   local tabstate = tl.tab_states[tabname]
   assert(tabstate, "this gets set up on self:open()")
   if not tl.currently_open then return end

   local callbacks = self.descriptors[tabname].callbacks
   local callback = callbacks[cb_name]

   -- The tab might not want to do anything.  But the message builder might
   -- still end up with stuff, if the parent added some.
   if callback then
      local player = game.get_player(pindex)
      assert(player, "Somehow got input from a dead player")

      ---@type fa.ui.TabContext
      local context = {
         pindex = pindex,
         player = player,
         state = tabstate,
         parameters = tl.parameters,
         force_close = false,
         message = msg_builder,
         shared_state = tl.shared_state,
      }

      -- It's a method on callbacks, so we must pass callbacks as the self
      -- parameter since we aren't using the `:` syntax.
      callback(callbacks, context, table.unpack(params))

      if context.force_close then self:close(true) end
   end

   local msg = msg_builder:build()
   if msg then printout(msg, pindex) end
end

-- Returns a method which will call the event handler for the given name, so
-- that we may avoid rewriting the same body over and over.
local function build_simple_method(evt_name)
   return function(self, pindex)
      local tl = tablist_storage[pindex][self.menu_name]
      self:_do_callback(pindex, tl.active_tab, evt_name)
   end
end

---@type fun(self, number)
TabList.on_up = build_simple_method("on_up")
---@type fun(self, number)
TabList.on_down = build_simple_method("on_down")
---@type fun(self, number)
TabList.on_left = build_simple_method("on_left")
---@type fun(self, number)
TabList.on_right = build_simple_method("on_right")

-- Perform the flow for focusing a tab. Does this unconditionally, so be careful
-- not to over-call it.
function TabList:_set_active_tab(pindex, active_tab)
   local tl = tablist_storage[pindex][self.menu_name]

   -- Note: for now, control.lua has the sound logic for tab cycling because it
   -- turns out that is generic and all of the other menus that don't use a
   -- cohesive framework are relying on it; playing sounds here is
   -- double-playing.

   local msg_builder = MessageBuilder.MessageBuilder.new()
   local desc = self.descriptors[self.tab_order[active_tab]]
   local title = desc.title
   if title then msg_builder:list_item(title) end
   self:_do_callback(pindex, tl.active_tab, "on_tab_unfocused")
   self:_do_callback(pindex, active_tab, "on_tab_focused", msg_builder)

   tl.active_tab = active_tab
end

---@param pindex number
---@param direction 1|-1
function TabList:_cycle(pindex, direction)
   local tl = tablist_storage[pindex][self.menu_name]
   local old_index = tl.active_tab

   local new_index = Math2.mod1(tl.active_tab + direction, #self.tab_order)

   if old_index ~= new_index then self:_set_active_tab(pindex, new_index) end
end

function TabList:on_next_tab(pindex)
   self:_cycle(pindex, 1)
end

function TabList:on_previous_tab(pindex)
   self:_cycle(pindex, -1)
end

function TabList:open(pindex, parameters)
   storage.players[pindex].menu = self.menu_name
   storage.players[pindex].in_menu = true

   local tabstate = tablist_storage[pindex][self.menu_name]

   if not tabstate then
      tabstate = {
         parameters = parameters,
         active_tab = 1,
         tab_states = {},
         currently_open = true,
         shared_state = {},
      }
      tablist_storage[pindex][self.menu_name] = tabstate
   end

   -- Parameters always gets updated.
   tabstate.parameters = parameters
   -- And so does the shared state, if there is one.
   if self.shared_state_initializer then tabstate.shared_state = self.shared_state_initializer(pindex, parameters) end
   -- And it is now open.
   tabstate.currently_open = true

   if self.declaration.resets_to_first_tab_on_open then tabstate.active_tab = 1 end

   -- Tell all the tabs that they have opened, but abort if any of them close.
   for i = 1, #self.tab_order do
      local tabname = self.tab_order[i]
      if not tabstate.tab_states[tabname] then tabstate.tab_states[tabname] = {} end

      self:_do_callback(pindex, i, "on_tab_list_opened")
   end

   self:_set_active_tab(pindex, tabstate.active_tab)
end

---@param force_reset boolean? If true, also dump state.
function TabList:close(pindex, force_reset)
   for i = 1, #self.tab_order do
      self:_do_callback(pindex, i, "on_tab_list_closed")
   end

   tablist_storage[pindex][self.menu_name].currently_open = false

   if force_reset then tablist_storage[pindex][self.menu_name] = nil end

   storage.players[pindex].menu = nil
   storage.players[pindex].in_menu = false
end

---@param declaration fa.ui.TabListDeclaration
---@return fa.ui.TabList
function mod.declare_tablist(declaration)
   ---@type fa.ui.TabList
   local ret = {
      menu_name = declaration.menu_name,
      tab_order = {},
      descriptors = {},
      shared_state_initializer = declaration.shared_state_setup,
      declaration = declaration,
   }

   for _, d in pairs(declaration.tabs) do
      assert(not ret.descriptors[d.name], "duplicate tabs not allowed")
      ret.descriptors[d.name] = d
      table.insert(ret.tab_order, d.name)
   end

   assert(#ret.tab_order, "All tablists must have tabs")

   return setmetatable(ret, TabList_meta)
end

return mod
