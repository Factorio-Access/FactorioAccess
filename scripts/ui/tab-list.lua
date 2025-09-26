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
local StorageManager = require("scripts.storage-manager")
local TH = require("scripts.table-helpers")
local Sounds = require("scripts.ui.sounds")

local mod = {}

---@class fa.ui.TabContext
---@field pindex number
---@field player LuaPlayer
---@field state table Goes into storage.
---@field shared_state table
---@field parameters table Whatever was passed to :open()
---@field controller fa.ui.RouterController Controller for UI management
---@field message fa.Speech

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
---@field on_child_result fa.ui.SimpleTabHandler?
---@field enabled fun(number): boolean

---@class fa.ui.TabDescriptor
---@field name string
---@field title LocalisedString? If set, read out when the tab changes to this tab.
---@field callbacks fa.ui.TabCallbacks

---@class fa.ui.SectionDescriptor
---@field name string
---@field title LocalisedString? If set, read out when switching to this section.
---@field tabs fa.ui.TabDescriptor[]

---@class fa.ui.TabListDeclaration (exact)
---@field ui_name fa.ui.UiName used for key routing.
---@field tabs_callback fun(pindex: number, parameters: any): fa.ui.SectionDescriptor[]? Dynamic sections callback
---@field shared_state_setup (fun(number, table): table)? passed the parameters and pindex, should return a shaerd state.
---@field resets_to_first_tab_on_open boolean?
---@field persist_state boolean?

---@class fa.ui.TabListStorageState
---@field active_section number
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
---@field sections fa.ui.SectionDescriptor[]
---@field descriptors  table<string, fa.ui.TabDescriptor>
---@field tab_order string[]
---@field tabs_callback fun(pindex: number, parameters: any): fa.ui.SectionDescriptor[]
---@field shared_state_initializer (fun(number, table): table)?
---@field declaration fa.ui.TabListDeclaration
local TabList = {}
local TabList_meta = { __index = TabList }
mod.TabList = TabList

-- Returns whatever the callback returns, including special responses.  Does
-- nothing if this tablist is not open, which can happen when calling a bunch of
-- events back to back if the tab list has to close in the middle of a sequence
-- of actions.
---@param msg_builder fa.Speech?
---@param params any[]?
---@param controller fa.ui.RouterController
function TabList:_do_callback(pindex, target_tab_index, cb_name, msg_builder, params, controller)
   msg_builder = msg_builder or Speech.new()
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

   -- Get fresh sections from callback
   local new_sections = self.tabs_callback(pindex, tl.parameters)

   if not new_sections then
      -- If callback returns nil, close the UI via controller
      controller:close()
      return
   end

   -- Build flat descriptor map and order from sections
   local new_order = {}
   local new_desc_map = {}
   local valid_sections = {}

   for _, section in ipairs(new_sections) do
      if section.tabs and #section.tabs > 0 then
         -- Only include sections with tabs
         table.insert(valid_sections, section)
         for _, desc in ipairs(section.tabs) do
            new_desc_map[desc.name] = desc
            table.insert(new_order, desc.name)
         end
      end
   end

   -- Error if no valid sections with tabs
   if #valid_sections == 0 then error("UI " .. self.ui_name .. " has no sections with tabs - programmer error") end

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

   -- Determine which section contains the active tab
   local tab_index = 0
   for section_idx, section in ipairs(valid_sections) do
      for _, tab in ipairs(section.tabs) do
         tab_index = tab_index + 1
         if tab_index == tl.active_tab then
            tl.active_section = section_idx
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
   self.sections = valid_sections
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
TabList.on_top = build_simple_method("on_top")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_bottom = build_simple_method("on_bottom")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_leftmost = build_simple_method("on_leftmost")
---@type fun(self, number, table?, fa.ui.RouterController)
TabList.on_rightmost = build_simple_method("on_rightmost")

---Handle child result from textbox or other child UI
---@param pindex number
---@param result_context table { ui_name: string, context: any }
---@param result any
---@param controller fa.ui.RouterController
function TabList:on_child_result(pindex, result_context, result, controller)
   -- Re-render before handling the event (needs controller for potential close)
   self:_rerender(pindex, controller)

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl.currently_open then return end

   -- Pass result_context and result to the active tab's handler
   self:_do_callback(pindex, tl.active_tab, "on_child_result", nil, { result_context, result }, controller)
end

-- Perform the flow for focusing a tab. Does this unconditionally, so be careful
-- not to over-call it.
---@param msg_builder fa.Speech? Optional message builder to prepend section info to
---@param play_sound boolean? Optional boolean, defaults to true. Set to false to suppress sound.
---@param controller fa.ui.RouterController
function TabList:_set_active_tab(pindex, active_tab, msg_builder, play_sound, controller)
   local tl = tablist_storage[pindex][self.ui_name]

   -- Play tab change sound (unless explicitly suppressed)
   if play_sound ~= false then Sounds.play_change_menu_tab(pindex) end

   -- Use provided message builder or create new one
   msg_builder = msg_builder or Speech.new()
   local desc = self.descriptors[self.tab_order[active_tab]]
   local title = desc.title
   if title then msg_builder:list_item(title) end
   self:_do_callback(pindex, tl.active_tab, "on_tab_unfocused", nil, nil, controller)
   self:_do_callback(pindex, active_tab, "on_tab_focused", msg_builder, nil, controller)

   tl.active_tab = active_tab
end

---@param pindex number
---@param direction 1|-1
---@param controller fa.ui.RouterController
function TabList:_cycle(pindex, direction, controller)
   if not tablist_storage[pindex] or not tablist_storage[pindex][self.ui_name] then return end

   -- Re-render before cycling
   self:_rerender(pindex, controller)

   local tl = tablist_storage[pindex][self.ui_name]
   if not tl or not tl.currently_open or not self.sections then return end

   -- Get tabs in current section only
   local current_section = self.sections[tl.active_section]
   if not current_section or #current_section.tabs == 0 then return end

   -- Find current tab index within section
   local current_tab_name = self.tab_order[tl.active_tab]
   local section_tab_index = 0
   for i, tab in ipairs(current_section.tabs) do
      if tab.name == current_tab_name then
         section_tab_index = i
         break
      end
   end

   -- Cycle within section
   local old_section_index = section_tab_index
   local new_section_index = Math2.mod1(section_tab_index + direction, #current_section.tabs)

   while new_section_index ~= old_section_index do
      local tab = current_section.tabs[new_section_index]
      if not tab.callbacks.enabled or tab.callbacks.enabled(pindex) then break end
      new_section_index = Math2.mod1(new_section_index + direction, #current_section.tabs)
   end

   if old_section_index ~= new_section_index then
      -- Find global index of new tab
      local new_tab_name = current_section.tabs[new_section_index].name
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
   if not tl or not tl.currently_open or not self.sections then return end

   -- If only one section, play edge sound
   if #self.sections <= 1 then
      Sounds.play_ui_edge(pindex)
      return
   end

   -- Cycle to next/previous section (wrapping around)
   local old_section = tl.active_section
   local new_section = Math2.mod1(old_section + direction, #self.sections)

   -- Skip empty sections
   local attempts = 0
   while attempts < #self.sections do
      if self.sections[new_section] and #self.sections[new_section].tabs > 0 then break end
      new_section = Math2.mod1(new_section + direction, #self.sections)
      attempts = attempts + 1
   end

   if new_section == old_section then
      -- All other sections are empty, play edge sound
      Sounds.play_ui_edge(pindex)
      return
   end

   -- Switch to new section
   tl.active_section = new_section

   -- Find first enabled tab in new section
   local section = self.sections[new_section]
   local first_tab_name = nil
   for _, tab in ipairs(section.tabs) do
      if not tab.callbacks.enabled or tab.callbacks.enabled(pindex) then
         first_tab_name = tab.name
         break
      end
   end

   if not first_tab_name then
      -- No enabled tabs in section (shouldn't happen but handle gracefully)
      return
   end

   -- Find global index of the tab
   for i, name in ipairs(self.tab_order) do
      if name == first_tab_name then
         -- Build message with section title (if present) and let _set_active_tab add the tab title
         local msg_builder = nil
         if section.title then
            msg_builder = Speech.new()
            msg_builder:fragment(section.title)
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

---@param controller fa.ui.RouterController
function TabList:open(pindex, parameters, controller)
   assert(self.ui_name)
   assert(controller, "TabList:open requires a controller")

   if not self.declaration.persist_state then tablist_storage[pindex][self.ui_name] = nil end

   local tabstate = tablist_storage[pindex][self.ui_name]

   if not tabstate then
      tabstate = {
         parameters = parameters,
         active_section = 1,
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
      tabstate.active_section = 1
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
         -- Create a dummy controller for the close callback
         ---@type fa.ui.RouterController
         local dummy_controller = {}
         self:_do_callback(pindex, i, "on_tab_list_closed", nil, nil, dummy_controller)
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
      sections = {},
      tab_order = {},
      descriptors = {},
      tabs_callback = declaration.tabs_callback,
      shared_state_initializer = declaration.shared_state_setup,
      declaration = declaration,
   }, TabList_meta)

   return ret
end

return mod
