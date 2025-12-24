--[[
Category-based row navigation UI component.

Provides 2D navigation where:
- W/S moves between categories (vertical)
- A/D moves between items within a category (horizontal)
- Cursor position is remembered per category
- Handles dynamic changes to categories and items

This component does NOT use KeyGraph, instead implementing its own navigation
to support sticky horizontal positions.
]]

local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UiRouter = require("scripts.ui.router")
local sounds = require("scripts.ui.sounds")
local TH = require("scripts.table-helpers")

local mod = {}

---@enum fa.ui.CategoryRows.CategoryPosition
mod.CATEGORY_POSITION = {
   BEFORE = "before",
   AFTER = "after",
}

---@class fa.ui.CategoryRows.ItemVtable
---@field label fun(ctx: fa.ui.CategoryRows.ItemContext)
---@field on_click? fun(ctx: fa.ui.CategoryRows.ItemContext, modifiers: {control?: boolean, shift?: boolean, alt?: boolean})
---@field on_right_click? fun(ctx: fa.ui.CategoryRows.ItemContext, modifiers: {control?: boolean, shift?: boolean, alt?: boolean})
---@field on_read_coords? fun(ctx: fa.ui.CategoryRows.ItemContext)
---@field on_read_info? fun(ctx: fa.ui.CategoryRows.ItemContext)
---@field on_production_stats_announcement? fun(ctx: fa.ui.CategoryRows.ItemContext)

---@class fa.ui.CategoryRows.Item
---@field key string Unique identifier for this item
---@field vtable fa.ui.CategoryRows.ItemVtable

---@class fa.ui.CategoryRows.Category
---@field key string Unique identifier for this category
---@field label LocalisedString
---@field items fa.ui.CategoryRows.Item[]

---@class fa.ui.CategoryRows.Render
---@field categories fa.ui.CategoryRows.Category[]
---@field focus_category_key string? Optional: category to focus when tab gains focus
---@field focus_item_key string? Optional: item to focus when tab gains focus

---@class fa.ui.CategoryRows.State
---@field current_category_key string?
---@field cursor_by_category table<string, string> Maps category key to item key
---@field prev_category_order string[]
---@field prev_items_by_category table<string, string[]>

---@class fa.ui.CategoryRows.ItemContext
---@field pindex number
---@field player LuaPlayer
---@field message fa.MessageBuilder
---@field state table
---@field shared_state table
---@field parameters table
---@field controller fa.ui.RouterController Controller for UI management

---@class fa.ui.CategoryRows.Builder
---@field categories table<string, fa.ui.CategoryRows.Category>
---@field category_order string[]
---@field focus_category_key string?
---@field focus_item_key string?
local CategoryRowsBuilder = {}
local CategoryRowsBuilder_meta = { __index = CategoryRowsBuilder }

---Add a category to the builder
---@param key string Unique identifier
---@param label LocalisedString
---@return fa.ui.CategoryRows.Builder
function CategoryRowsBuilder:add_category(key, label)
   if not self.categories[key] then
      self.categories[key] = {
         key = key,
         label = label,
         items = {},
      }
      table.insert(self.category_order, key)
   end
   return self
end

---Add an item to a category
---@param category_key string
---@param item_key string
---@param vtable fa.ui.CategoryRows.ItemVtable
---@return fa.ui.CategoryRows.Builder
function CategoryRowsBuilder:add_item(category_key, item_key, vtable)
   local category = self.categories[category_key]
   if category then table.insert(category.items, {
      key = item_key,
      vtable = vtable,
   }) end
   return self
end

---Set the focus position for when the tab gains focus
---@param category_key string
---@param item_key string
---@return fa.ui.CategoryRows.Builder
function CategoryRowsBuilder:set_focus(category_key, item_key)
   self.focus_category_key = category_key
   self.focus_item_key = item_key
   return self
end

---Build the final render structure
---@return fa.ui.CategoryRows.Render
function CategoryRowsBuilder:build()
   local categories = {}
   for _, key in ipairs(self.category_order) do
      table.insert(categories, self.categories[key])
   end
   return {
      categories = categories,
      focus_category_key = self.focus_category_key,
      focus_item_key = self.focus_item_key,
   }
end

---Create a new builder
---@return fa.ui.CategoryRows.Builder
function mod.CategoryRowsBuilder_new()
   return setmetatable({
      categories = {},
      category_order = {},
   }, CategoryRowsBuilder_meta)
end

---Find category index by key
---@param render fa.ui.CategoryRows.Render
---@param key string
---@return number?
local function find_category_index(render, key)
   for i, category in ipairs(render.categories) do
      if category.key == key then return i end
   end
   return nil
end

---Find item index in category by key
---@param category fa.ui.CategoryRows.Category
---@param key string
---@return number?
local function find_item_index(category, key)
   for i, item in ipairs(category.items) do
      if item.key == key then return i end
   end
   return nil
end

---Get or create the persistent state for this component
---@param ctx fa.ui.TabContext
---@return fa.ui.CategoryRows.State
local function get_or_create_state(ctx)
   if not ctx.state.category_rows then
      ctx.state.category_rows = {
         current_category_key = nil,
         cursor_by_category = {},
         prev_category_order = {},
         prev_items_by_category = {},
      }
   end
   return ctx.state.category_rows
end

---Update state after a render, handling removed categories/items
---@param state fa.ui.CategoryRows.State
---@param render fa.ui.CategoryRows.Render
local function update_state_after_render(state, render)
   -- Build new order arrays
   local new_category_order = {}
   local new_items_by_category = {}

   for _, category in ipairs(render.categories) do
      table.insert(new_category_order, category.key)
      new_items_by_category[category.key] = {}
      for _, item in ipairs(category.items) do
         table.insert(new_items_by_category[category.key], item.key)
      end
   end

   -- If current category was removed, find the closest one that still exists
   if state.current_category_key and not find_category_index(render, state.current_category_key) then
      local old_index = TH.find_index_of(state.prev_category_order, state.current_category_key)
      if old_index then
         -- Search backwards from the old position for a category that still exists
         for i = old_index, 1, -1 do
            local old_key = state.prev_category_order[i]
            if find_category_index(render, old_key) then
               state.current_category_key = old_key
               break
            end
         end
      end
   end

   -- Default to first category if needed
   if not state.current_category_key or not find_category_index(render, state.current_category_key) then
      state.current_category_key = new_category_order[1]
   end

   -- For each category, check if cursor item was removed
   for cat_key, item_key in pairs(state.cursor_by_category) do
      local category = nil
      for _, c in ipairs(render.categories) do
         if c.key == cat_key then
            category = c
            break
         end
      end

      if category and not find_item_index(category, item_key) then
         local prev_items = state.prev_items_by_category[cat_key]
         if prev_items then
            local old_index = TH.find_index_of(prev_items, item_key)
            if old_index then
               -- Search backwards for an item that still exists
               for i = old_index, 1, -1 do
                  local old_item_key = prev_items[i]
                  if find_item_index(category, old_item_key) then
                     state.cursor_by_category[cat_key] = old_item_key
                     break
                  end
               end
            end
         end
         -- Default to first item if nothing found
         if not find_item_index(category, state.cursor_by_category[cat_key]) and #category.items > 0 then
            state.cursor_by_category[cat_key] = category.items[1].key
         end
      end
   end

   -- Store the new state for next time
   state.prev_category_order = new_category_order
   state.prev_items_by_category = new_items_by_category
end

---Ensure cursor is initialized for the current category
---@param state fa.ui.CategoryRows.State
---@param render fa.ui.CategoryRows.Render
local function _ensure_cursor_initialized(state, render)
   if not state.current_category_key then
      if #render.categories > 0 then
         state.current_category_key = render.categories[1].key
      else
         return
      end
   end

   local cat_index = find_category_index(render, state.current_category_key)
   if not cat_index then
      -- Current category doesn't exist, default to first
      if #render.categories > 0 then
         state.current_category_key = render.categories[1].key
         cat_index = 1
      else
         return
      end
   end

   local category = render.categories[cat_index]
   if #category.items > 0 and not state.cursor_by_category[category.key] then
      -- Initialize cursor to first item
      state.cursor_by_category[category.key] = category.items[1].key
   end
end

---Get current position, initializing if needed
---@param state fa.ui.CategoryRows.State
---@param render fa.ui.CategoryRows.Render
---@return number?, number?
local function _get_position(state, render)
   -- Ensure cursor is initialized
   _ensure_cursor_initialized(state, render)

   if not state.current_category_key then return nil, nil end

   local cat_index = find_category_index(render, state.current_category_key)
   if not cat_index then return nil, nil end

   local category = render.categories[cat_index]
   if #category.items == 0 then return cat_index, nil end

   local cursor_key = state.cursor_by_category[category.key]
   if not cursor_key then
      -- This shouldn't happen after _ensure_cursor_initialized, but be defensive
      if #category.items > 0 then
         state.cursor_by_category[category.key] = category.items[1].key
         cursor_key = category.items[1].key
      else
         return cat_index, nil
      end
   end

   local item_index = find_item_index(category, cursor_key)
   if not item_index and #category.items > 0 then
      -- Cursor points to invalid item, reset to first
      state.cursor_by_category[category.key] = category.items[1].key
      item_index = 1
   end

   return cat_index, item_index
end

---Create an item context from a tab context
---@param tab_ctx fa.ui.TabContext
---@return fa.ui.CategoryRows.ItemContext
local function create_item_context(tab_ctx)
   return {
      pindex = tab_ctx.pindex,
      player = tab_ctx.player,
      message = tab_ctx.message,
      state = tab_ctx.state,
      shared_state = tab_ctx.shared_state,
      parameters = tab_ctx.parameters,
      controller = tab_ctx.controller,
   }
end

---Announce current position (category and optionally item)
---@param ctx fa.ui.TabContext
---@param category fa.ui.CategoryRows.Category
---@param item_index number? nil to skip item announcement
---@param category_position fa.ui.CategoryRows.CategoryPosition? where to announce category (nil to skip category)
local function announce_position(ctx, category, item_index, category_position)
   if category_position == mod.CATEGORY_POSITION.BEFORE then
      ctx.message:fragment(category.label)
      ctx.message:list_item_forced_comma()
   end

   if #category.items == 0 then
      ctx.message:fragment({ "fa.category-rows-empty-category" })
   elseif item_index then
      local item = category.items[item_index]
      if item then
         local item_ctx = create_item_context(ctx)
         item.vtable.label(item_ctx)
      end
   end

   if category_position == mod.CATEGORY_POSITION.AFTER then
      ctx.message:list_item_forced_comma()
      ctx.message:fragment(category.label)
   end
end

---Wrap an index within bounds with sound feedback
---@param current_index number
---@param direction -1|1
---@param max_index number
---@param pindex number
---@return number new_index
local function wrap_index(current_index, direction, max_index, pindex)
   local new_index = current_index + direction

   if new_index < 1 then
      sounds.play_menu_wrap(pindex)
      return max_index
   elseif new_index > max_index then
      sounds.play_menu_wrap(pindex)
      return 1
   else
      sounds.play_menu_move(pindex)
      return new_index
   end
end

---Prepare state for an operation
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@return fa.ui.CategoryRows.State
local function prepare_state(ctx, render)
   local state = get_or_create_state(ctx)
   update_state_after_render(state, render)
   return state
end

---Check if render has no categories and announce if empty
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@return boolean is_empty
local function check_empty_categories(ctx, render)
   if #render.categories == 0 then
      sounds.play_ui_edge(ctx.pindex)
      ctx.message:fragment({ "fa.category-rows-no-categories" })
      return true
   end
   return false
end

---Handle vertical navigation (between categories)
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param direction -1|1
local function handle_vertical_navigation(ctx, render, direction)
   local state = prepare_state(ctx, render)
   if check_empty_categories(ctx, render) then return end

   local current_index, _ = _get_position(state, render)
   if not current_index then current_index = 1 end

   local new_index = wrap_index(current_index, direction, #render.categories, ctx.pindex)
   local new_category = render.categories[new_index]
   state.current_category_key = new_category.key

   -- Ensure cursor is initialized for new category
   _ensure_cursor_initialized(state, render)

   -- Announce position
   local cursor_key = state.cursor_by_category[new_category.key]
   local item_index = cursor_key and find_item_index(new_category, cursor_key) or nil
   announce_position(ctx, new_category, item_index, mod.CATEGORY_POSITION.BEFORE)
end

---Handle horizontal navigation (between items in category)
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param direction -1|1
local function handle_horizontal_navigation(ctx, render, direction)
   local state = prepare_state(ctx, render)
   if check_empty_categories(ctx, render) then return end

   local cat_index, current_index = _get_position(state, render)
   if not cat_index then return end

   local category = render.categories[cat_index]
   if #category.items == 0 then
      sounds.play_ui_edge(ctx.pindex)
      ctx.message:fragment({ "fa.category-rows-empty-category" })
      return
   end

   if not current_index then current_index = 1 end
   local new_index = wrap_index(current_index, direction, #category.items, ctx.pindex)

   local new_item = category.items[new_index]
   state.cursor_by_category[category.key] = new_item.key

   -- Announce item only (no category)
   announce_position(ctx, category, new_index, nil)
end

---Handle click events
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
---@param is_right_click boolean
local function handle_click(ctx, render, modifiers, is_right_click)
   local state = prepare_state(ctx, render)
   if #render.categories == 0 then return end

   local cat_index, item_index = _get_position(state, render)
   if not cat_index or not item_index then return end

   local category = render.categories[cat_index]
   if #category.items == 0 then return end

   local item = category.items[item_index]
   local callback_name = is_right_click and "on_right_click" or "on_click"
   local callback = item.vtable[callback_name]

   if callback then
      local item_ctx = create_item_context(ctx)
      callback(item_ctx, modifiers or {})
      -- Controller is passed through, so callbacks can use it directly
   else
      -- Default to reading the label
      local item_ctx = create_item_context(ctx)
      item.vtable.label(item_ctx)
   end
end

---Handle read coords
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
local function handle_read_coords(ctx, render)
   local state = prepare_state(ctx, render)
   if #render.categories == 0 then return end

   local cat_index, item_index = _get_position(state, render)
   if not cat_index or not item_index then return end

   local category = render.categories[cat_index]
   local item = category.items[item_index]
   if item.vtable.on_read_coords then
      local item_ctx = create_item_context(ctx)
      item.vtable.on_read_coords(item_ctx)
   end
end

---Get next position in flattened representation
---@param render fa.ui.CategoryRows.Render
---@param category_key string
---@param item_key string
---@return string?, string?
function mod.get_next_position(render, category_key, item_key)
   local cat_index = find_category_index(render, category_key)
   if not cat_index then return nil, nil end

   local category = render.categories[cat_index]
   local item_index = find_item_index(category, item_key)
   if not item_index then return nil, nil end

   -- Try next item in same category
   if item_index < #category.items then return category_key, category.items[item_index + 1].key end

   -- Try first item in next category
   if cat_index < #render.categories then
      local next_cat = render.categories[cat_index + 1]
      if #next_cat.items > 0 then return next_cat.key, next_cat.items[1].key end
   end

   -- Wrap to beginning
   if #render.categories > 0 and #render.categories[1].items > 0 then
      return render.categories[1].key, render.categories[1].items[1].key
   end

   return nil, nil
end

---Get previous position in flattened representation
---@param render fa.ui.CategoryRows.Render
---@param category_key string
---@param item_key string
---@return string?, string?
function mod.get_prev_position(render, category_key, item_key)
   local cat_index = find_category_index(render, category_key)
   if not cat_index then return nil, nil end

   local category = render.categories[cat_index]
   local item_index = find_item_index(category, item_key)
   if not item_index then return nil, nil end

   -- Try previous item in same category
   if item_index > 1 then return category_key, category.items[item_index - 1].key end

   -- Try last item in previous category
   if cat_index > 1 then
      local prev_cat = render.categories[cat_index - 1]
      if #prev_cat.items > 0 then return prev_cat.key, prev_cat.items[#prev_cat.items].key end
   end

   -- Wrap to end
   local last_cat = render.categories[#render.categories]
   if last_cat and #last_cat.items > 0 then return last_cat.key, last_cat.items[#last_cat.items].key end

   return nil, nil
end

---@class fa.ui.CategoryRows
---@field render_callback fun(ctx: fa.ui.TabContext): fa.ui.CategoryRows.Render?
---@field name string
local CategoryRows = {}
local CategoryRows_meta = { __index = CategoryRows }

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_up(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then handle_vertical_navigation(ctx, render, -1) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_down(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then handle_vertical_navigation(ctx, render, 1) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_left(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then handle_horizontal_navigation(ctx, render, -1) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_right(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then handle_horizontal_navigation(ctx, render, 1) end
end

---Helper function to jump to a specific category (first or last)
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param target_index number 1 for first, or #categories for last
local function jump_to_category(ctx, render, target_index)
   local state = prepare_state(ctx, render)
   if check_empty_categories(ctx, render) then return end

   local current_index, _ = _get_position(state, render)
   if not current_index then current_index = 1 end

   if current_index == target_index then
      -- Already at target, play edge sound and re-announce
      sounds.play_ui_edge(ctx.pindex)
   else
      -- Move to target category
      state.current_category_key = render.categories[target_index].key
   end

   -- Ensure cursor is initialized for target category
   _ensure_cursor_initialized(state, render)

   -- Announce position
   local category = render.categories[target_index]
   local cursor_key = state.cursor_by_category[category.key]
   local item_index = cursor_key and find_item_index(category, cursor_key) or nil
   announce_position(ctx, category, item_index, mod.CATEGORY_POSITION.BEFORE)
end

---Helper function to jump to a specific item in current category (first or last)
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param target_index_fn fun(category: fa.ui.CategoryRows.Category): number
local function jump_to_item(ctx, render, target_index_fn)
   local state = prepare_state(ctx, render)
   if check_empty_categories(ctx, render) then return end

   local cat_index, current_index = _get_position(state, render)
   if not cat_index then return end

   local category = render.categories[cat_index]

   if #category.items == 0 then
      sounds.play_ui_edge(ctx.pindex)
      ctx.message:fragment({ "fa.category-rows-empty-category" })
      return
   end

   if not current_index then current_index = 1 end
   local target_index = target_index_fn(category)

   if current_index == target_index then
      -- Already at target, play edge sound and re-announce
      sounds.play_ui_edge(ctx.pindex)
   else
      -- Move to target item
      state.cursor_by_category[category.key] = category.items[target_index].key
   end

   -- Announce target item only (no category)
   announce_position(ctx, category, target_index, nil)
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_top(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then jump_to_category(ctx, render, 1) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_bottom(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then jump_to_category(ctx, render, #render.categories) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_leftmost(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then jump_to_item(ctx, render, function(category)
      return 1
   end) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_rightmost(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then jump_to_item(ctx, render, function(category)
      return #category.items
   end) end
end

---@param ctx fa.ui.TabContext
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
function CategoryRows:on_click(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then handle_click(ctx, render, modifiers, false) end
end

---@param ctx fa.ui.TabContext
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
function CategoryRows:on_right_click(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then handle_click(ctx, render, modifiers, true) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_read_coords(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then handle_read_coords(ctx, render) end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_read_info(ctx, modifiers)
   local render = self.render_callback(ctx)
   if not render then return end

   local state = prepare_state(ctx, render)
   if #render.categories == 0 then return end

   local cat_index, item_index = _get_position(state, render)
   if not cat_index or not item_index then return end

   local category = render.categories[cat_index]
   local item = category.items[item_index]
   if item.vtable.on_read_info then
      local item_ctx = create_item_context(ctx)
      item.vtable.on_read_info(item_ctx)
   end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_production_stats_announcement(ctx, modifiers)
   local render = self.render_callback(ctx)
   if render then
      local state = prepare_state(ctx, render)
      if #render.categories == 0 then return end

      local cat_index, item_index = _get_position(state, render)
      if not cat_index or not item_index then return end

      local category = render.categories[cat_index]
      local item = category.items[item_index]
      if item.vtable.on_production_stats_announcement then
         local item_ctx = create_item_context(ctx)
         item.vtable.on_production_stats_announcement(item_ctx)
      end
   end
end

---@param ctx fa.ui.TabContext
---@param modifiers any
function CategoryRows:on_tab_focused(ctx, modifiers)
   -- Announce current position when tab gains focus
   local render = self.render_callback(ctx)
   if not render or check_empty_categories(ctx, render) then return end

   local state = prepare_state(ctx, render)

   -- If render specifies a focus position, jump to it
   if render.focus_category_key and render.focus_item_key then
      local focus_cat_index = find_category_index(render, render.focus_category_key)
      if focus_cat_index then
         state.current_category_key = render.focus_category_key
         state.cursor_by_category[render.focus_category_key] = render.focus_item_key
      end
   end

   -- Get or initialize position
   local cat_index, item_index = _get_position(state, render)
   if not cat_index then return end

   local category = render.categories[cat_index]

   -- Announce position
   announce_position(ctx, category, item_index, mod.CATEGORY_POSITION.BEFORE)
end

---Check if this UI supports search
---@param ctx fa.ui.TabContext
---@return boolean
function CategoryRows:supports_search(ctx)
   return true
end

---Hint search system with all searchable items
---@param ctx fa.ui.TabContext
---@param hint_callback fun(localised_string: LocalisedString)
function CategoryRows:search_hint(ctx, hint_callback)
   local render = self.render_callback(ctx)
   if not render then return end

   -- Hint all item labels
   for _, category in ipairs(render.categories) do
      for _, item in ipairs(category.items) do
         local msg_builder = MessageBuilder.new()
         local item_ctx = create_item_context(ctx)
         item_ctx.message = msg_builder
         item.vtable.label(item_ctx)
         local built = msg_builder:build()
         if built then hint_callback(built) end
      end
   end
end

---Search for next/prev match
---@param message fa.MessageBuilder Message builder to populate with announcement
---@param ctx fa.ui.TabContext
---@param direction integer 1 for next, -1 for prev
---@param matcher fun(localised_string: LocalisedString): boolean Function to test if a localised string matches
---@return fa.ui.SearchResult
function CategoryRows:search_move(message, ctx, direction, matcher)
   local render = self.render_callback(ctx)
   if not render or check_empty_categories(ctx, render) then return UiRouter.SEARCH_RESULT.DIDNT_MOVE end

   local state = prepare_state(ctx, render)

   -- Build flat list of all items with their positions
   local all_items = {}
   for cat_idx, category in ipairs(render.categories) do
      for item_idx, item in ipairs(category.items) do
         table.insert(all_items, {
            cat_idx = cat_idx,
            item_idx = item_idx,
            category = category,
            item = item,
         })
      end
   end

   if #all_items == 0 then return UiRouter.SEARCH_RESULT.DIDNT_MOVE end

   -- Find current position in flat list
   local cat_idx, item_idx = _get_position(state, render)
   local current_flat_idx = nil
   for i, entry in ipairs(all_items) do
      if entry.cat_idx == cat_idx and entry.item_idx == item_idx then
         current_flat_idx = i
         break
      end
   end

   if not current_flat_idx then current_flat_idx = 0 end

   local start_idx = current_flat_idx
   local i = current_flat_idx
   local wrapped = false

   -- Search loop
   while true do
      i = i + direction
      if direction > 0 and i > #all_items then
         i = 1
         wrapped = true
      elseif direction < 0 and i < 1 then
         i = #all_items
         wrapped = true
      end

      local entry = all_items[i]
      -- Build the label as a localised string
      local temp_msg = MessageBuilder.new()
      local item_ctx = create_item_context(ctx)
      item_ctx.message = temp_msg
      entry.item.vtable.label(item_ctx)
      local label_localised = temp_msg:build()

      if label_localised and matcher(label_localised) then
         -- Found a match
         state.current_category_key = entry.category.key
         state.cursor_by_category[entry.category.key] = entry.item.key

         -- Build announcement into provided message (announce category after item for search)
         local announce_ctx = {
            pindex = ctx.pindex,
            player = ctx.player,
            message = message,
            state = ctx.state,
            shared_state = ctx.shared_state,
            parameters = ctx.parameters,
            controller = ctx.controller,
         }
         announce_position(announce_ctx, entry.category, entry.item_idx, mod.CATEGORY_POSITION.AFTER)

         return wrapped and UiRouter.SEARCH_RESULT.WRAPPED or UiRouter.SEARCH_RESULT.MOVED
      end

      -- If we've wrapped and returned to start, no more matches
      if i == start_idx then break end
   end

   return UiRouter.SEARCH_RESULT.DIDNT_MOVE
end

function CategoryRows:get_help_metadata(ctx)
   -- Call user-provided callback if it exists
   local user_help = self.user_get_help_metadata and self.user_get_help_metadata(ctx) or {}

   -- Inject category-rows generic help
   table.insert(user_help, { kind = 1, value = "category-rows-help" }) -- MESSAGE_LIST

   return user_help
end

---@param ctx fa.ui.TabContext
---@return fa.ui.Bind[]?
function CategoryRows:get_binds(ctx)
   if self.get_binds_callback then return self.get_binds_callback(ctx) end
   return {}
end

---@class fa.ui.CategoryRows.Declaration
---@field title LocalisedString?
---@field render_callback fun(ctx: fa.ui.TabContext): fa.ui.CategoryRows.Render?
---@field name string
---@field get_help_metadata (fun(ctx: fa.ui.TabContext): fa.ui.help.HelpItem[]?)?
---@field get_binds (fun(ctx: fa.ui.TabContext): fa.ui.Bind[]?)?

---Declare a category-rows based tab
---@param declaration fa.ui.CategoryRows.Declaration
---@return fa.ui.TabDescriptor
function mod.declare_category_rows(declaration)
   local category_rows = setmetatable({
      render_callback = declaration.render_callback,
      name = declaration.name,
      user_get_help_metadata = declaration.get_help_metadata,
      get_binds_callback = declaration.get_binds,
   }, CategoryRows_meta)

   return {
      name = declaration.name,
      title = declaration.title,
      callbacks = category_rows,
   }
end

return mod
