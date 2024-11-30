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
to do so, it should write `force_close=true` to the context.

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
---@field parameters table Whatever was passed to :open()
---@field force_close boolean If true, close this tablist.
---@field message fa.MessageBuilder

---@alias fa.ui.SimpleTabHandler fun(fa.ui.TabContext)

---@class fa.ui.TabCallbacks
---@field title LocalisedString? If set, read out when the tab changes to this tab.
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
---@field callbacks fa.ui.TabCallbacks

---@class fa.ui.TabListDeclaration
---@field menu_name string
---@field tabs fa.ui.TabDescriptor[]

---@class fa.ui.TabListStorageState
---@field active_tab number
---@field tab_states table<string, table>
---@field parameters any
---@field currently_open boolean

---@type table<number, table<string, fa.ui.TabListStorageState>>
local tablist_storage = StorageManager.declare_storage_module("tab_list", {})

---@class fa.ui.TabList
---@field descriptors  table<string, fa.ui.TabDescriptor>
---@field menu_name string
---@field tab_order string[]
local TabList = {}
local TabList_meta = { __index = TabList }
mod.TabList = TabList

-- Returns whatever the callback returns, including special responses.  Does
-- nothing if this tablist is not open, which can happen when calling a bunch of
-- events back to back if the tab list has to close in the middle of a sequence
-- of actions.
function TabList:_do_callback(pindex, target_tab_index, cb_name, ...)
   local tl = tablist_storage[pindex][self.menu_name]
   local tabname = self.tab_order[target_tab_index]
   local tabstate = tl.tab_states[tabname]
   assert(tabstate, "this gets set up on self:open()")
   if not tabstate.currently_open then return end

   local callbacks = self.descriptors[tabname].callbacks
   local callback = callbacks[cb_name]

   -- The tab might not want to do anything.
   if not callback then return end

   local player = game.get_player(pindex)
   assert(player, "Somehow got input from a dead player")

   ---@type fa.ui.TabContext
   local context = {
      pindex = pindex,
      player = player,
      state = tabstate,
      parameters = tl.parameters,
      force_close = false,
      message = MessageBuilder.MessageBuilder.new(),
   }

   callback(context, ...)

   local msg = context.message:build()
   if msg then printout(msg, pindex) end
   if context.force_close then self:close(true) end
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

---@param pindex number
---@param direction 1|-1
function TabList:_cycle(self, pindex, direction)
   local tl = tablist_storage[pindex][self.menu_name]
   local old_index = tl.active_tab

   local new_index = Math2.mod1(tl.active_tab + direction, #self.tab_order)
   local wrapped = new_index ~= tl.active_tab + direction

   -- Need to play sounds here.

   local tabname = self.tab_order[tl.active_tab]
   local desc = self.tabs[tabname]
   local title = desc.callbacks.title
   if title then printout(title, pindex) end

   -- Call the event on the old tab, then change to the new tab, then call the
   -- focused event on the new tab.  But only do these if the tab actually
   -- changed, so that we don't duplicate work in the case of one tab.
   if old_index ~= new_index then
      self:_do_callback(pindex, old_index, "on_tab_unfocused")
      self:_do_callback(pindex, new_index, "on_tab_focused")
   end
   tl.active_tab = new_index
end

function TabList:on_next_tab(self, pindex)
   self:_cycle(pindex, 1)
end

function TabList:on_previous_tab(self, pindex)
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
         tab_order = {},
         tab_states = {},
         currently_open = true,
      }
      tablist_storage[pindex][self.menu_name] = tabstate

      for _, desc in pairs(self.descriptors) do
         table.insert(tabstate.tab_order, desc.name)
         tabstate.tab_states[desc.name] = {}
      end
   end

   -- Parameters always gets updated.
   tabstate.parameters = parameters
   -- And it is now open.
   tabstate.currently_open = true

   -- Tell all the tabs that they have opened, but abort if any of them close.
   for i = 1, #tabstate.tab_order do
      self:_do_callback(pindex, i, "on_tab_list_opened")
   end
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
