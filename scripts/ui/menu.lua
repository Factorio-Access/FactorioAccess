--[[
A menu.

mod.menu_builder() returns a builder which will build a key graph render for you, to be used from within a render
function.  Helpers on it allow for adding controls, etc.
]]
local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")
local UiUtils = require("scripts.ui.ui-utils")

local mod = {}

---@class fa.ui.menu.Entry
---@field vtable fa.ui.graph.NodeVtable
---@field key string

---@class fa.ui.menu.MenuBuilder
---@field entries fa.ui.menu.Entry
local MenuBuilder = {}
local MenuBuilder_meta = { __index = MenuBuilder }

function MenuBuilder.new()
   return setmetatable({
      entries = {},
   }, MenuBuilder_meta)
end

-- Lowest level way to add to the menu.  Consider one of the "control" helpers below.
---@param key string
---@param vtable fa.ui.graph.NodeVtable
---@return fa.ui.menu.MenuBuilder
function MenuBuilder:add_item(key, vtable)
   table.insert(self.entries, { key = key, vtable = vtable })
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
---@param click_handlers { on_click: fa.ui.graph.SimpleCallback }
function MenuBuilder:add_clickable(key, label, click_handlers)
   self:add_item(key, {
      on_click = function(ctx)
         click_handlers.on_click(ctx)
      end,
      label = UiUtils.to_label_function(label),
   })
end

---@return fa.ui.graph.Render
function MenuBuilder:build()
   local render = {
      start_key = "",
      nodes = {},
   }

   assert(#self.entries, "Menus must have at least one item")

   local prev_k = self.entries[1].key
   render.nodes[prev_k] = {
      vtable = self.entries[1].vtable,
      transitions = {},
   }

   render.start_key = prev_k
   for i = 2, #self.entries do
      local k = self.entries[i].key

      render.nodes[prev_k].transitions[UiKeyGraph.TRANSITION_DIR.DOWN] = {
         vtable = {
            play_sound = function(ctx)
               UiSounds.play_menu_move(ctx.pindex)
            end,
         },
         destination = k,
      }

      render.nodes[k] = {
         vtable = self.entries[i].vtable,
         transitions = {
            [UiKeyGraph.TRANSITION_DIR.UP] = {
               vtable = {
                  play_sound = function(ctx)
                     UiSounds.play_menu_move(ctx.pindex)
                  end,
               },
               destination = prev_k,
            },
         },
      }

      prev_k = k
   end
   return render
end

mod.MenuBuilder = MenuBuilder

return mod
