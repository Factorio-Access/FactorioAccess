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
local UiRouter = require("scripts.ui.router")
local sounds = require("scripts.ui.sounds")
local TH = require("scripts.table-helpers")

local mod = {}

---@class fa.ui.CategoryRows.ItemVtable
---@field label fun(ctx: fa.ui.CategoryRows.ItemContext)
---@field on_click? fun(ctx: fa.ui.CategoryRows.ItemContext, modifiers: {control?: boolean, shift?: boolean, alt?: boolean})
---@field on_right_click? fun(ctx: fa.ui.CategoryRows.ItemContext, modifiers: {control?: boolean, shift?: boolean, alt?: boolean})
---@field on_read_coords? fun(ctx: fa.ui.CategoryRows.ItemContext)

---@class fa.ui.CategoryRows.Item
---@field key string Unique identifier for this item
---@field vtable fa.ui.CategoryRows.ItemVtable

---@class fa.ui.CategoryRows.Category
---@field key string Unique identifier for this category
---@field label LocalisedString
---@field items fa.ui.CategoryRows.Item[]

---@class fa.ui.CategoryRows.Render
---@field categories fa.ui.CategoryRows.Category[]

---@class fa.ui.CategoryRows.State
---@field current_category_key string?
---@field cursor_by_category table<string, string> Maps category key to item key
---@field prev_category_order string[]
---@field prev_items_by_category table<string, string[]>

---@class fa.ui.CategoryRows.ItemContext
---@field pindex number
---@field player LuaPlayer
---@field message fa.Speech
---@field state table
---@field shared_state table
---@field parameters table
---@field force_close boolean

---@class fa.ui.CategoryRows.Builder
---@field categories table<string, fa.ui.CategoryRows.Category>
---@field category_order string[]
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

---Build the final render structure
---@return fa.ui.CategoryRows.Render
function CategoryRowsBuilder:build()
   local categories = {}
   for _, key in ipairs(self.category_order) do
      table.insert(categories, self.categories[key])
   end
   return {
      categories = categories,
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
      force_close = false,
   }
end

---Handle vertical navigation (between categories)
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param direction -1|1
local function handle_vertical_navigation(ctx, render, direction)
   local state = get_or_create_state(ctx)
   update_state_after_render(state, render)

   if #render.categories == 0 then
      sounds.play_inventory_edge(ctx.pindex)
      ctx.message:fragment({ "fa.category-rows-no-categories" })
      return
   end

   local current_index = find_category_index(render, state.current_category_key) or 1
   local new_index = current_index + direction

   if new_index < 1 or new_index > #render.categories then
      sounds.play_inventory_edge(ctx.pindex)
   else
      sounds.play_menu_move(ctx.pindex)
      local new_category = render.categories[new_index]
      state.current_category_key = new_category.key

      -- Announce category name
      ctx.message:fragment(new_category.label)
      ctx.message:list_item_forced_comma()

      -- Announce current item in category if any
      local cursor_key = state.cursor_by_category[new_category.key]
      if cursor_key then
         local item_index = find_item_index(new_category, cursor_key)
         if item_index then
            local item = new_category.items[item_index]
            local item_ctx = create_item_context(ctx)
            item.vtable.label(item_ctx)
         end
      elseif #new_category.items > 0 then
         -- Set cursor to first item
         state.cursor_by_category[new_category.key] = new_category.items[1].key
         local item = new_category.items[1]
         local item_ctx = create_item_context(ctx)
         item.vtable.label(item_ctx)
      else
         ctx.message:fragment({ "fa.category-rows-empty-category" })
      end
   end
end

---Handle horizontal navigation (between items in category)
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param direction -1|1
local function handle_horizontal_navigation(ctx, render, direction)
   local state = get_or_create_state(ctx)
   update_state_after_render(state, render)

   if #render.categories == 0 then
      sounds.play_inventory_edge(ctx.pindex)
      ctx.message:fragment({ "fa.category-rows-no-categories" })
      return
   end

   local cat_index = find_category_index(render, state.current_category_key) or 1
   local category = render.categories[cat_index]

   if #category.items == 0 then
      sounds.play_inventory_edge(ctx.pindex)
      ctx.message:fragment({ "fa.category-rows-empty-category" })
      return
   end

   local cursor_key = state.cursor_by_category[category.key] or category.items[1].key
   local current_index = find_item_index(category, cursor_key) or 1
   local new_index = current_index + direction

   if new_index < 1 or new_index > #category.items then
      sounds.play_inventory_edge(ctx.pindex)
   else
      sounds.play_menu_move(ctx.pindex)
      local new_item = category.items[new_index]
      state.cursor_by_category[category.key] = new_item.key

      -- Announce item
      local item_ctx = create_item_context(ctx)
      new_item.vtable.label(item_ctx)
   end
end

---Handle click events
---@param ctx fa.ui.TabContext
---@param render fa.ui.CategoryRows.Render
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
---@param is_right_click boolean
local function handle_click(ctx, render, modifiers, is_right_click)
   local state = get_or_create_state(ctx)
   update_state_after_render(state, render)

   if #render.categories == 0 then return end

   local cat_index = find_category_index(render, state.current_category_key)
   if not cat_index then return end

   local category = render.categories[cat_index]
   if #category.items == 0 then return end

   local cursor_key = state.cursor_by_category[category.key]
   if not cursor_key then return end

   local item_index = find_item_index(category, cursor_key)
   if not item_index then return end

   local item = category.items[item_index]
   local callback_name = is_right_click and "on_right_click" or "on_click"
   local callback = item.vtable[callback_name]

   if callback then
      local item_ctx = create_item_context(ctx)
      callback(item_ctx, modifiers or {})
      if item_ctx.force_close then ctx.force_close = true end
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
   local state = get_or_create_state(ctx)
   update_state_after_render(state, render)

   if #render.categories == 0 then return end

   local cat_index = find_category_index(render, state.current_category_key)
   if not cat_index then return end

   local category = render.categories[cat_index]
   if #category.items == 0 then return end

   local cursor_key = state.cursor_by_category[category.key]
   if not cursor_key then return end

   local item_index = find_item_index(category, cursor_key)
   if not item_index then return end

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
---@return string?, string? category_key, item_key
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
---@return string?, string? category_key, item_key
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

---Declare a category-rows based tab
---@param params {name: string, render_callback: fun(ctx: fa.ui.TabContext): fa.ui.CategoryRows.Render?}
---@return fa.ui.TabDescriptor
function mod.declare_category_rows(params)
   ---@type fa.ui.TabCallbacks
   local callbacks = {}

   function callbacks:on_up(ctx, modifiers)
      local render = params.render_callback(ctx)
      if render then handle_vertical_navigation(ctx, render, -1) end
   end

   function callbacks:on_down(ctx, modifiers)
      local render = params.render_callback(ctx)
      if render then handle_vertical_navigation(ctx, render, 1) end
   end

   function callbacks:on_left(ctx, modifiers)
      local render = params.render_callback(ctx)
      if render then handle_horizontal_navigation(ctx, render, -1) end
   end

   function callbacks:on_right(ctx, modifiers)
      local render = params.render_callback(ctx)
      if render then handle_horizontal_navigation(ctx, render, 1) end
   end

   function callbacks:on_click(ctx, modifiers)
      local render = params.render_callback(ctx)
      if render then handle_click(ctx, render, modifiers, false) end
   end

   function callbacks:on_right_click(ctx, modifiers)
      local render = params.render_callback(ctx)
      if render then handle_click(ctx, render, modifiers, true) end
   end

   function callbacks:on_read_coords(ctx, modifiers)
      local render = params.render_callback(ctx)
      if render then handle_read_coords(ctx, render) end
   end

   function callbacks:on_tab_focused(ctx, modifiers)
      -- Announce current position when tab gains focus
      local render = params.render_callback(ctx)
      if not render or #render.categories == 0 then
         ctx.message:fragment({ "fa.category-rows-no-categories" })
         return
      end

      local state = get_or_create_state(ctx)
      update_state_after_render(state, render)

      local cat_index = find_category_index(render, state.current_category_key) or 1
      local category = render.categories[cat_index]

      -- Announce category
      ctx.message:fragment(category.label)
      ctx.message:list_item_forced_comma()

      -- Announce current item
      if #category.items > 0 then
         local cursor_key = state.cursor_by_category[category.key] or category.items[1].key
         local item_index = find_item_index(category, cursor_key)
         if item_index then
            local item = category.items[item_index]
            local item_ctx = create_item_context(ctx)
            item.vtable.label(item_ctx)
         end
      else
         ctx.message:fragment({ "fa.category-rows-empty-category" })
      end
   end

   return {
      name = params.name,
      callbacks = callbacks,
   }
end

return mod
