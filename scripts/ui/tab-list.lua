--[[
Holds a list of named tabs, and lets you select between them.

For now this does not support dynamicism.  That is to say that tabs must be declared at the top level of a file.  You
don't get multiple instances per player.  For example you can't have two open belt analyzers.  As is the theme, this can
also be extended later once we are at the point of being able to have a proper framework.  In particular, layers can be
used to provide the missing UI stack abstractions that would allow multiple arbitrary sets of UIs to all be open at
once.

For now this isn't super documented.  If you are looking for some overarching framework you won't find it.  That comes
later.  This just gets us off the ground.  However, see ui/menu.lua, which simplifies, well, menus.

This is the top level of the UI hierarchy and also handles the state management. Each tab will receive a context with a
field to use for persistent state. Whatever it stores there can persist between opens, if `persist_state` is set.  It
can reset this state by forcing closure; to do so, it should call `context.controller:close()`.  A shared state,
also cleared on forced closure, is `shared_state`.  Callbacks passed to creation of this tablist can initialize the
shared state, but cannot print to the player by design; do not perform mutable actions in state setup or else.

You should not use printout/speak. Instead, you are given a message builder in the context. Sometimes, the tab needs to
add output before yours, so you should print through that.

There is limited support for enabling and disabling tabs.  A stateless callback given only the pindex may be provided on
a tab's callbacks. This will configure that tab to enable/disable itself based on the return value.  This is an interim
step toward building the tabs on demand that lets us get things going.  It's enough to use the same tab list for all
generic containers.  Until the wider form, two limitations must be observed:

- Tabs which are focused will not be disabled if their callback says they should be.
- The first tab should always be enabled, because it will receive initial focus.
]]
local Math2 = require("math-helpers")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local StorageManager = require("scripts.storage-manager")
local TH = require("scripts.table-helpers")
local Sounds = require("scripts.ui.sounds")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@class fa.ui.TabContext
---@field pindex number
---@field player LuaPlayer
---@field state table Goes into storage.
---@field shared_state table
---@field parameters table Whatever was passed to :open()
---@field controller fa.ui.RouterController? Controller for UI management. Nil for close callback.
---@field message fa.MessageBuilder

---@alias fa.ui.SimpleTabHandler fun(self, fa.ui.TabContext, modifiers?: {control?: boolean, shift?: boolean, alt?: boolean})

---@class fa.ui.TabCallbacks
---@field on_tab_focused fa.ui.SimpleTabHandler?
---@field on_tab_unfocused fa.ui.SimpleTabHandler?
---@field on_tab_list_opened fa.ui.SimpleTabHandler?
---@field on_tab_list_closed fa.ui.SimpleTabHandler?
---@field on_up fa.ui.SimpleTabHandler?
---@field on_down fa.ui.SimpleTabHandler?
---@field on_left fa.ui.SimpleTabHandler?
---@field on_right fa.ui.SimpleTabHandler?
---@field on_top fa.ui.SimpleTabHandler?
---@field on_bottom fa.ui.SimpleTabHandler?
---@field on_leftmost fa.ui.SimpleTabHandler?
---@field on_rightmost fa.ui.SimpleTabHandler?
---@field on_click fa.ui.SimpleTabHandler?
---@field on_right_click fa.ui.SimpleTabHandler?
---@field on_read_coords fa.ui.SimpleTabHandler?
---@field on_read_info fa.ui.SimpleTabHandler?
---@field on_production_stats_announcement fa.ui.SimpleTabHandler?
---@field on_child_result fa.ui.SimpleTabHandler?
---@field on_accelerator fun(self, ctx: fa.ui.TabContext, accelerator_name: string)?
---@field on_clear fa.ui.SimpleTabHandler?
---@field on_dangerous_delete fa.ui.SimpleTabHandler?
---@field on_trash fa.ui.SimpleTabHandler?
---@field enabled fun(number): boolean
---@field supports_search fun(self, ctx: fa.ui.TabContext): boolean? Returns true if search is supported
---@field search_hint fun(self, ctx: fa.ui.TabContext, hint_callback: fun(localised_string: LocalisedString))? Called to hint strings for caching
---@field search_move fun(self, message: fa.MessageBuilder, ctx: fa.ui.TabContext, direction: integer, matcher: fun(localised_string: LocalisedString): boolean): fa.ui.SearchResult? Move to next/prev search result, populate message with announcement
---@field search_all_from_start fun(self, ctx: fa.ui.TabContext): fa.ui.SearchResult? Search from start, move to first match

---@class fa.ui.TabDescriptor
---@field name string
---@field title LocalisedString? If set, read out when the tab changes to this tab.
---@field callbacks fa.ui.TabCallbacks

---@class fa.ui.TabstopDescriptor
---@field name string
---@field title LocalisedString? If set, read out when switching to this tabstop.
---@field tabs fa.ui.TabDescriptor[]

---@class fa.ui.TabListDeclaration (exact)
---@field ui_name fa.ui.UiName used for key routing.
---@field tabs_callback fun(pindex: number, parameters: any): fa.ui.TabstopDescriptor[]? Dynamic tabstops callback
---@field shared_state_setup (fun(number, table): table)? passed the parameters and pindex, should return a shaerd state.
---@field resets_to_first_tab_on_open boolean?
---@field persist_state boolean?

---@class fa.ui.TabListStorageState
---@field active_tabstop number
---@field active_tab number
---@field tab_states table<string, table>
---@field parameters any
---@field currently_open boolean
---@field shared_state table
---@field prev_tab_order string[]? Previous tab order for removal detection

---@type table<number, table<string, fa.ui.TabListStorageState>>
local tablist_storage = StorageManager.declare_storage_module("tab_list", {}, {
   ephemeral_state_version = 1,
})

---@class fa.ui.TabList : fa.ui.UiPanelBase
---@field tabstops fa.ui.TabstopDescriptor[]
---@field descriptors  table<string, fa.ui.TabDescriptor>
---@field tab_order string[]
---@field tabs_callback fun(pindex: number, parameters: any): fa.ui.TabstopDescriptor[]
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
---@param controller? fa.ui.RouterController Not present for close
function TabList:_do_callback(pindex, target_tab_index, cb_name, msg_builder, params, controller)
   msg_builder = msg_builder or MessageBuilder.new()
   params = params or {}

   local tl = tablist_storage[pindex][self.ui_name]
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
         controller = controller,
         message = msg_builder,
         shared_state = tl.shared_state,
      }

      -- It's a method on callbacks, so we must pass callbacks as the self
      -- parameter since we aren't using the `:` syntax.
      callback(callbacks, context, table.unpack(params))
      -- Makes assigning to state when initializing etc. work.
      tl.tab_states[tabname] = context.state
   end

   local msg = msg_builder:build()
   if msg then Speech.speak(pindex, msg) end
end

-- Re-render the tabs, handling additions and removals
---@param pindex number
---@param controller fa.ui.RouterController
---@private
function TabList:_rerender(pindex, controller)
   local tl = tablist_storage[pindex][self.ui_name]
   assert(tl)

   -- Get fresh tabstops from callback
   local new_tabstops = self.tabs_callback(pindex, tl.parameters)

   if not new_tabstops then
      -- If callback returns nil, close the UI via controller
      controller:close()
      return
   end

   -- Build flat descriptor map and order from tabstops
   local new_order = {}
   local new_desc_map = {}
   local valid_tabstops = {}

   for _, tabstop in ipairs(new_tabstops) do
      if tabstop.tabs and #tabstop.tabs > 0 then
         -- Only include tabstops with tabs
         table.insert(valid_tabstops, tabstop)
         for _, desc in ipairs(tabstop.tabs) do
            new_desc_map[desc.name] = desc
            table.insert(new_order, desc.name)
         end
      end
   end

   -- Error if no valid tabstops with tabs
   if #valid_tabstops == 0 then error("UI " .. self.ui_name .. " has no tabstops with tabs - programmer error") end

   -- Get previous tab order from storage (or current if first render)
   local prev_tab_order = tl.prev_tab_order or self.tab_order

   -- If active tab was removed, find the best replacement
   local active_tab_name = prev_tab_order[tl.active_tab]
   if active_tab_name and not new_desc_map[active_tab_name] then
      -- Find the last tab that still exists, searching backwards from the old position
      local found = false
      for i = tl.active_tab, 1, -1 do
         local old_name = prev_tab_order[i]
         if new_desc_map[old_name] then
            -- Find the index of this tab in the new order
            for j, name in ipairs(new_order) do
               if name == old_name then
                  tl.active_tab = j
                  found = true
                  break
               end
            end
            if found then break end
         end
      end

      -- If nothing found going backwards, default to first tab
      if not found then tl.active_tab = 1 end
   else
      -- Active tab still exists, find its new index
      for i, name in ipairs(new_order) do
         if name == active_tab_name then
            tl.active_tab = i
            break
         end
      end
   end

   -- Determine which tabstop contains the active tab
   local tab_index = 0
   for tabstop_idx, tabstop in ipairs(valid_tabstops) do
      for _, tab in ipairs(tabstop.tabs) do
         tab_index = tab_index + 1
         if tab_index == tl.active_tab then
            tl.active_tabstop = tabstop_idx
            break
         end
      end
   end

   -- Clean up states for removed tabs
   if prev_tab_order then
      for _, old_name in ipairs(prev_tab_order) do
         if not new_desc_map[old_name] then tl.tab_states[old_name] = nil end
      end
   end

   -- Initialize states for new tabs
   for _, desc in pairs(new_desc_map) do
      if not tl.tab_states[desc.name] then tl.tab_states[desc.name] = {} end
   end

   -- Update the TabList's descriptor tables
   self.tabstops = valid_tabstops
   self.descriptors = new_desc_map
   self.tab_order = new_order

   -- Store the new order in storage for next time
   tl.prev_tab_order = new_order
end

-- Returns a method which will call the event handler for the given name, so
-- that we may avoid rewriting the same body over and over.
local function build_simple_method(evt_name)
   return function(self, pindex, modifiers, controller)
      -- Re-render before handling the event (needs controller for potential close)
      self:_rerender(pindex, controller)

      local tl = tablist_storage[pindex][self.ui_name]
      if not tl.currently_open then return end

      -- Pass modifiers and controller as part of params array to _do_callback
      self:_do_callback(pindex, tl.active_tab, evt_name, nil, { modifiers }, controller)
   end
end

---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_up = build_simple_method("on_up")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_down = build_simple_method("on_down")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_left = build_simple_method("on_left")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_right = build_simple_method("on_right")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_click = build_simple_method("on_click")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_right_click = build_simple_method("on_right_click")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_read_coords = build_simple_method("on_read_coords")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_read_info = build_simple_method("on_read_info")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_production_stats_announcement = build_simple_method("on_production_stats_announcement")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_top = build_simple_method("on_top")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bottom = build_simple_method("on_bottom")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_leftmost = build_simple_method("on_leftmost")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_rightmost = build_simple_method("on_rightmost")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_clear = build_simple_method("on_clear")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_dangerous_delete = build_simple_method("on_dangerous_delete")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bar_min = build_simple_method("on_bar_min")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bar_max = build_simple_method("on_bar_max")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bar_up_small = build_simple_method("on_bar_up_small")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bar_down_small = build_simple_method("on_bar_down_small")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bar_up_large = build_simple_method("on_bar_up_large")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bar_down_large = build_simple_method("on_bar_down_large")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_trash = build_simple_method("on_trash")

---Handle accelerator events (one callback for all accelerators)
---@param pindex number
---@param accelerator_name string The accelerator constant name
---@param modifiers table?
---@param controller fa.ui.RouterController
function TabList:on_accelerator(pindex, accelerator_name, modifiers, controller)
   -- Re-render before handling the event (needs controller for potential close)
   self:_rerender(pindex, controller)

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl.currently_open then return end

   -- Pass accelerator_name as first parameter to the callback
   self:_do_callback(pindex, tl.active_tab, "on_accelerator", nil, { accelerator_name }, controller)
end

---Handle child result from textbox or other child UI
---@param pindex number
---@param result any
---@param context any The context from when child UI was opened
---@param controller fa.ui.RouterController
function TabList:on_child_result(pindex, result, context, controller)
   -- Re-render before handling the event (needs controller for potential close)
   self:_rerender(pindex, controller)

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl.currently_open then return end

   -- Pass result and context to the active tab's handler
   self:_do_callback(pindex, tl.active_tab, "on_child_result", nil, { result, context }, controller)
end

---Announce the current tab's title
---@param pindex number
---@param modifiers table?
---@param controller fa.ui.RouterController
function TabList:on_announce_title(pindex, modifiers, controller)
   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open then return end

   local desc = self.descriptors[self.tab_order[tl.active_tab]]
   if desc and desc.title then controller.message:fragment(desc.title) end
end

-- Perform the flow for focusing a tab. Does this unconditionally, so be careful
-- not to over-call it.
---@param msg_builder fa.MessageBuilder? Optional message builder to prepend tabstop info to
---@param play_sound boolean? Optional boolean, defaults to true. Set to false to suppress sound.
---@param controller fa.ui.RouterController
function TabList:_set_active_tab(pindex, active_tab, msg_builder, play_sound, controller)
   local tl = tablist_storage[pindex][self.ui_name]

   -- Play tab change sound (unless explicitly suppressed)
   if play_sound ~= false then Sounds.play_change_menu_tab(pindex) end

   -- Use provided message builder or create new one
   msg_builder = msg_builder or MessageBuilder.new()
   local desc = self.descriptors[self.tab_order[active_tab]]
   local title = desc.title
   if title then msg_builder:list_item(title) end
   self:_do_callback(pindex, tl.active_tab, "on_tab_unfocused", nil, nil, controller)
   self:_do_callback(pindex, active_tab, "on_tab_focused", msg_builder, nil, controller)

   tl.active_tab = active_tab

   -- Re-hint search strings if there's an active search pattern
   controller:suggest_search_rehint()
end

---@param pindex number
---@param direction 1|-1
---@param controller fa.ui.RouterController
function TabList:_cycle(pindex, direction, controller)
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then return end

   -- Re-render before cycling
   self:_rerender(pindex, controller)

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open or not self.tabstops then return end

   -- Get tabs in current tabstop only
   local current_tabstop = self.tabstops[tl.active_tabstop]
   if not current_tabstop or #current_tabstop.tabs == 0 then return end

   -- Find current tab index within tabstop
   local current_tab_name = self.tab_order[tl.active_tab]
   local tabstop_tab_index = 0
   for i, tab in ipairs(current_tabstop.tabs) do
      if tab.name == current_tab_name then
         tabstop_tab_index = i
         break
      end
   end

   -- Cycle within tabstop
   local old_index = tabstop_tab_index
   local new_index = Math2.mod1(tabstop_tab_index + direction, #current_tabstop.tabs)

   while new_index ~= old_index do
      local tab = current_tabstop.tabs[new_index]
      if not tab.callbacks.enabled or tab.callbacks.enabled(pindex) then break end
      new_index = Math2.mod1(new_index + direction, #current_tabstop.tabs)
   end

   if old_index ~= new_index then
      -- Find global index of new tab
      local new_tab_name = current_tabstop.tabs[new_index].name
      for i, name in ipairs(self.tab_order) do
         if name == new_tab_name then
            self:_set_active_tab(pindex, i, nil, true, controller)
            break
         end
      end
   end
end

function TabList:on_next_tab(pindex, modifiers, controller)
   -- Tab navigation doesn't use modifiers, but we pass controller through
   self:_cycle(pindex, 1, controller)
end

function TabList:on_previous_tab(pindex, modifiers, controller)
   -- Tab navigation doesn't use modifiers, but we pass controller through
   self:_cycle(pindex, -1, controller)
end

---@param pindex number
---@param direction 1|-1
---@param controller fa.ui.RouterController
function TabList:_cycle_section(pindex, direction, controller)
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then return end

   -- Re-render before cycling
   self:_rerender(pindex, controller)

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open or not self.tabstops then return end

   -- If only one tabstop, play edge sound
   if #self.tabstops <= 1 then
      Sounds.play_ui_edge(pindex)
      return
   end

   -- Cycle to next/previous tabstop (wrapping around)
   local old_tabstop = tl.active_tabstop
   local new_tabstop = Math2.mod1(old_tabstop + direction, #self.tabstops)

   -- Skip empty tabstops
   local attempts = 0
   while attempts < #self.tabstops do
      if self.tabstops[new_tabstop] and #self.tabstops[new_tabstop].tabs > 0 then break end
      new_tabstop = Math2.mod1(new_tabstop + direction, #self.tabstops)
      attempts = attempts + 1
   end

   if new_tabstop == old_tabstop then
      -- All other tabstops are empty, play edge sound
      Sounds.play_ui_edge(pindex)
      return
   end

   -- Switch to new tabstop
   tl.active_tabstop = new_tabstop

   -- Find first enabled tab in new tabstop
   local tabstop = self.tabstops[new_tabstop]
   local first_tab_name = nil
   for _, tab in ipairs(tabstop.tabs) do
      if not tab.callbacks.enabled or tab.callbacks.enabled(pindex) then
         first_tab_name = tab.name
         break
      end
   end

   if not first_tab_name then
      -- No enabled tabs in tabstop (shouldn't happen but handle gracefully)
      return
   end

   -- Find global index of the tab
   for i, name in ipairs(self.tab_order) do
      if name == first_tab_name then
         -- Build message with tabstop title (if present) and let _set_active_tab add the tab title
         local msg_builder = nil
         if tabstop.title then
            msg_builder = MessageBuilder.new()
            msg_builder:fragment(tabstop.title)
         end
         -- Pass the message builder to _set_active_tab so it can add the tab title
         -- But we need to modify _set_active_tab to accept an optional message builder
         self:_set_active_tab(pindex, i, msg_builder, true, controller)
         break
      end
   end
end

function TabList:on_next_section(pindex, modifiers, controller)
   -- Section navigation doesn't use modifiers, but we pass controller through
   self:_cycle_section(pindex, 1, controller)
end

function TabList:on_previous_section(pindex, modifiers, controller)
   -- Section navigation doesn't use modifiers, but we pass controller through
   self:_cycle_section(pindex, -1, controller)
end

-- Search support - delegate to active tab

function TabList:supports_search(pindex, controller)
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then return false end

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open then return false end

   local tabname = self.tab_order[tl.active_tab]
   local tabstate = tl.tab_states[tabname]
   local callbacks = self.descriptors[tabname].callbacks

   if callbacks.supports_search then
      local ctx = {
         pindex = pindex,
         player = game.get_player(pindex),
         state = tabstate,
         parameters = tl.parameters,
         controller = controller,
         message = MessageBuilder.new(),
         shared_state = tl.shared_state,
      }
      return callbacks:supports_search(ctx)
   end

   return false
end

function TabList:search_hint(pindex, hint_callback, controller)
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then return end

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open then return end

   local tabname = self.tab_order[tl.active_tab]
   local tabstate = tl.tab_states[tabname]
   local callbacks = self.descriptors[tabname].callbacks

   if callbacks.search_hint then
      local ctx = {
         pindex = pindex,
         player = game.get_player(pindex),
         state = tabstate,
         parameters = tl.parameters,
         controller = controller,
         message = MessageBuilder.new(),
         shared_state = tl.shared_state,
      }
      callbacks:search_hint(ctx, hint_callback)
      -- Save state back
      tl.tab_states[tabname] = ctx.state
   end
end

function TabList:search_move(message, pindex, direction, matcher, controller)
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then
      return UiRouter.SEARCH_RESULT.NO_SUPPORT
   end

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open then return UiRouter.SEARCH_RESULT.NO_SUPPORT end

   local tabname = self.tab_order[tl.active_tab]
   local tabstate = tl.tab_states[tabname]
   local callbacks = self.descriptors[tabname].callbacks

   if callbacks.search_move then
      local ctx = {
         pindex = pindex,
         player = game.get_player(pindex),
         state = tabstate,
         parameters = tl.parameters,
         controller = controller,
         message = message,
         shared_state = tl.shared_state,
      }
      local result = callbacks:search_move(message, ctx, direction, matcher)
      -- Save state back
      tl.tab_states[tabname] = ctx.state
      return result
   end

   return UiRouter.SEARCH_RESULT.NO_SUPPORT
end

function TabList:search_all_from_start(pindex, controller)
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then
      return UiRouter.SEARCH_RESULT.NO_SUPPORT
   end

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open then return UiRouter.SEARCH_RESULT.NO_SUPPORT end

   local tabname = self.tab_order[tl.active_tab]
   local tabstate = tl.tab_states[tabname]
   local callbacks = self.descriptors[tabname].callbacks

   if callbacks.search_all_from_start then
      local ctx = {
         pindex = pindex,
         player = game.get_player(pindex),
         state = tabstate,
         parameters = tl.parameters,
         controller = controller,
         message = MessageBuilder.new(),
         shared_state = tl.shared_state,
      }
      local result = callbacks:search_all_from_start(ctx)
      -- Save state back
      tl.tab_states[tabname] = ctx.state
      return result
   end

   return UiRouter.SEARCH_RESULT.NO_SUPPORT
end

---@param controller fa.ui.RouterController
function TabList:open(pindex, parameters, controller)
   assert(self.ui_name)
   assert(controller, "TabList:open requires a controller")

   if not self.declaration.persist_state then tablist_storage[pindex][self.ui_name] = nil end

   local tabstate = tablist_storage[pindex][self.ui_name]

   if not tabstate then
      tabstate = {
         parameters = parameters,
         active_tabstop = 1,
         active_tab = 1,
         tab_states = {},
         currently_open = true,
         shared_state = {},
      }
      tablist_storage[pindex][self.ui_name] = tabstate
   end

   -- Parameters always gets updated.
   tabstate.parameters = parameters
   -- And so does the shared state, if there is one.
   if self.shared_state_initializer then tabstate.shared_state = self.shared_state_initializer(pindex, parameters) end
   -- And it is now open.
   tabstate.currently_open = true

   if self.declaration.resets_to_first_tab_on_open then
      tabstate.active_tab = 1
      tabstate.active_tabstop = 1
   end

   -- Perform initial render
   self:_rerender(pindex, controller)
   if not tabstate.currently_open then return end -- Rerender might have closed

   -- Tell all the tabs that they have opened, but abort if any of them close.
   for i = 1, #self.tab_order do
      local tabname = self.tab_order[i]
      if not tabstate.tab_states[tabname] then tabstate.tab_states[tabname] = {} end

      self:_do_callback(pindex, i, "on_tab_list_opened", nil, nil, controller)
   end

   -- Set the active tab without playing sound (we're opening, not switching)
   self:_set_active_tab(pindex, tabstate.active_tab, nil, false, controller)
end

---@param force_reset boolean? If true, also dump state.
function TabList:close(pindex, force_reset)
   -- Our lame event handling story where more than one event handler can get called for the same event combined with
   -- the new GUI framework still being WIP means that double-close is apparently possible.  We already know we're going
   -- to fix that, so for now just guard against it.
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then return end

   if tablist_storage[pindex][self.ui_name].currently_open then
      for i = 1, #self.tab_order do
         self:_do_callback(pindex, i, "on_tab_list_closed", nil, nil, nil)
      end
   end

   tablist_storage[pindex][self.ui_name].currently_open = false

   if force_reset then tablist_storage[pindex][self.ui_name] = nil end
end

---@param declaration fa.ui.TabListDeclaration
---@return fa.ui.TabList
function mod.declare_tablist(declaration)
   assert(declaration.tabs_callback, "TabList declaration must have tabs_callback")

   ---@type fa.ui.TabList
   local ret = setmetatable({
      ui_name = declaration.ui_name,
      tabstops = {},
      tab_order = {},
      descriptors = {},
      tabs_callback = declaration.tabs_callback,
      shared_state_initializer = declaration.shared_state_setup,
      declaration = declaration,
   }, TabList_meta)

   return ret
end

return mod
