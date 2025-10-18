--[[
A menu.

mod.menu_builder() returns a builder which will build a key graph render for you, to be used from within a render
function.  Helpers on it allow for adding controls, etc.
]]
local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")
local UiUtils = require("scripts.ui.ui-utils")

local mod = {}

---@class (exact) fa.ui.menu.ClickHandlers
---@field on_click? fa.ui.graph.SimpleCallback
---@field on_child_result? fa.ui.graph.ChildResultCallback
---@field on_clear? fa.ui.graph.SimpleCallback
---@field on_dangerous_delete? fa.ui.graph.SimpleCallback
---@field on_bar_min? fa.ui.graph.SimpleCallback
---@field on_bar_max? fa.ui.graph.SimpleCallback
---@field on_bar_up_small? fa.ui.graph.SimpleCallback
---@field on_bar_down_small? fa.ui.graph.SimpleCallback
---@field on_bar_up_large? fa.ui.graph.SimpleCallback
---@field on_bar_down_large? fa.ui.graph.SimpleCallback
---@field on_trash? fa.ui.graph.SimpleCallback

---@class fa.ui.menu.Entry
---@field vtable fa.ui.graph.NodeVtable
---@field key string

---@class fa.ui.menu.Row
---@field items fa.ui.menu.Entry[]
---@field key string?
---@field is_explicit boolean

---@class fa.ui.menu.MenuBuilder
---@field rows fa.ui.menu.Row[]
---@field current_row fa.ui.menu.Row?
local MenuBuilder = {}
local MenuBuilder_meta = { __index = MenuBuilder }

function MenuBuilder.new()
   return setmetatable({
      rows = {},
      current_row = nil,
   }, MenuBuilder_meta)
end

---Helper to add item to current or new row
---@param entry fa.ui.menu.Entry
---@private
function MenuBuilder:_add_entry_to_row(entry)
   if self.current_row then
      -- Add to explicit row
      table.insert(self.current_row.items, entry)
   else
      -- Create implicit single-item row
      table.insert(self.rows, {
         items = { entry },
         key = nil,
         is_explicit = false,
      })
   end
end

-- Lowest level way to add to the menu.  Consider one of the "control" helpers below.
---@param key string
---@param vtable fa.ui.graph.NodeVtable
---@return fa.ui.menu.MenuBuilder
function MenuBuilder:add_item(key, vtable)
   self:_add_entry_to_row({ key = key, vtable = vtable })
   return self
end

---Start an explicit row with optional key for column navigation
---@param key string?
---@return fa.ui.menu.MenuBuilder
function MenuBuilder:start_row(key)
   assert(not self.current_row, "Cannot start a row while another is open")
   self.current_row = {
      items = {},
      key = key,
      is_explicit = true,
   }
   return self
end

---End the current explicit row
---@return fa.ui.menu.MenuBuilder
function MenuBuilder:end_row()
   assert(self.current_row, "No row to end")
   table.insert(self.rows, self.current_row)
   self.current_row = nil
   return self
end

---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@return fa.ui.menu.MenuBuilder
function MenuBuilder:add_label(key, label)
   self:add_item(key, {
      label = UiUtils.to_label_function(label),
   })
   return self
end

---@param key string
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param click_handlers fa.ui.menu.ClickHandlers
function MenuBuilder:add_clickable(key, label, click_handlers)
   local vtable = {
      label = UiUtils.to_label_function(label),
   }

   -- Copy over any provided handlers
   if click_handlers.on_click then vtable.on_click = click_handlers.on_click end
   if click_handlers.on_child_result then vtable.on_child_result = click_handlers.on_child_result end
   if click_handlers.on_clear then vtable.on_clear = click_handlers.on_clear end
   if click_handlers.on_dangerous_delete then vtable.on_dangerous_delete = click_handlers.on_dangerous_delete end
   if click_handlers.on_bar_min then vtable.on_bar_min = click_handlers.on_bar_min end
   if click_handlers.on_bar_max then vtable.on_bar_max = click_handlers.on_bar_max end
   if click_handlers.on_bar_up_small then vtable.on_bar_up_small = click_handlers.on_bar_up_small end
   if click_handlers.on_bar_down_small then vtable.on_bar_down_small = click_handlers.on_bar_down_small end
   if click_handlers.on_bar_up_large then vtable.on_bar_up_large = click_handlers.on_bar_up_large end
   if click_handlers.on_bar_down_large then vtable.on_bar_down_large = click_handlers.on_bar_down_large end
   if click_handlers.on_trash then vtable.on_trash = click_handlers.on_trash end

   self:add_item(key, vtable)
end

---@return fa.ui.graph.Render
function MenuBuilder:build()
   local render = {
      start_key = "",
      nodes = {},
   }

   assert(self.current_row == nil, "Unclosed row - call end_row()")
   assert(#self.rows > 0, "Menus must have at least one item")

   -- Flatten rows to get all items
   local all_items = {}
   local item_to_row = {} -- Map item index to row index
   for row_idx, row in ipairs(self.rows) do
      assert(#row.items > 0, "Row cannot be empty")
      for _, item in ipairs(row.items) do
         table.insert(all_items, item)
         item_to_row[#all_items] = row_idx
      end
   end

   -- Build nodes
   for item_idx, item in ipairs(all_items) do
      local row_idx = item_to_row[item_idx]
      local row = self.rows[row_idx]
      local vtable = item.vtable

      -- If this is the first item in a multi-item row, wrap label to add count
      if row.items[1] == item and #row.items > 1 then
         local original_label = vtable.label
         local wrapped_vtable = {}
         for k, v in pairs(vtable) do
            wrapped_vtable[k] = v
         end
         wrapped_vtable.label = function(ctx)
            original_label(ctx)
            ctx.message:fragment({ "fa.row-of-items", tostring(#row.items) })
         end
         vtable = wrapped_vtable
      end

      render.nodes[item.key] = {
         vtable = vtable,
         transitions = {},
      }
   end

   render.start_key = all_items[1].key

   -- Helper to determine target item for vertical navigation
   local function get_vertical_target(current_row, target_row, pos_in_row)
      -- Check if rows have same key for column navigation
      if
         current_row.key
         and target_row.key
         and current_row.key == target_row.key
         and pos_in_row <= #target_row.items
      then
         -- Column navigation - go to same position in target row
         return target_row.items[pos_in_row]
      else
         -- Different keys or no keys - go to first item of target row
         return target_row.items[1]
      end
   end

   -- Helper to create vertical transition
   local function add_vertical_transition(node, direction, target_key)
      node.transitions[direction] = {
         vtable = {
            play_sound = function(ctx)
               UiSounds.play_menu_move(ctx.pindex)
            end,
         },
         destination = target_key,
      }
   end

   -- Build transitions
   for item_idx, item in ipairs(all_items) do
      local current_row_idx = item_to_row[item_idx]
      local current_row = self.rows[current_row_idx]

      -- Find position within current row
      local pos_in_row = 1
      for i, row_item in ipairs(current_row.items) do
         if row_item == item then
            pos_in_row = i
            break
         end
      end

      -- UP navigation
      if current_row_idx > 1 then
         local prev_row = self.rows[current_row_idx - 1]
         local target_item = get_vertical_target(current_row, prev_row, pos_in_row)
         add_vertical_transition(render.nodes[item.key], UiKeyGraph.TRANSITION_DIR.UP, target_item.key)
      end

      -- DOWN navigation
      if current_row_idx < #self.rows then
         local next_row = self.rows[current_row_idx + 1]
         local target_item = get_vertical_target(current_row, next_row, pos_in_row)
         add_vertical_transition(render.nodes[item.key], UiKeyGraph.TRANSITION_DIR.DOWN, target_item.key)
      end

      -- LEFT navigation within row
      if pos_in_row > 1 then
         local prev_item = current_row.items[pos_in_row - 1]
         render.nodes[item.key].transitions[UiKeyGraph.TRANSITION_DIR.LEFT] = {
            vtable = {
               play_sound = function(ctx)
                  UiSounds.play_menu_move(ctx.pindex)
               end,
            },
            destination = prev_item.key,
         }
      end

      -- RIGHT navigation within row
      if pos_in_row < #current_row.items then
         local next_item = current_row.items[pos_in_row + 1]
         render.nodes[item.key].transitions[UiKeyGraph.TRANSITION_DIR.RIGHT] = {
            vtable = {
               play_sound = function(ctx)
                  UiSounds.play_menu_move(ctx.pindex)
               end,
            },
            destination = next_item.key,
         }
      end
   end

   return render
end

mod.MenuBuilder = MenuBuilder

return mod
