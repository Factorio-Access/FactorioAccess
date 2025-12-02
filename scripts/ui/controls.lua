--[[
Control factory functions for building vtables.

These functions return vtables that can be passed to MenuBuilder:add_item() or used directly
with KeyGraph. They provide standardized behavior for common control types while maintaining
the layout flexibility of MenuBuilder.

Example:
   menu:add_item("active", Controls.checkbox({
      label = { "fa.logistics-active" },
      get = function() return section.active end,
      set = function(v) section.active = v end,
   }))
]]

local UiSounds = require("scripts.ui.sounds")
local UiUtils = require("scripts.ui.ui-utils")

local mod = {}

---@class fa.ui.controls.CheckboxConfig
---@field label LocalisedString | fun(ctx: fa.ui.graph.Ctx): LocalisedString The label to display after the state
---@field get fun(): boolean Function that returns the current checked state
---@field set fun(value: boolean) Function that sets the new checked state
---@field state_labels { on: LocalisedString, off: LocalisedString }? Optional custom state labels (defaults to checked/unchecked)

---Create a checkbox control vtable.
---
---The label displays state-first: "checked, label text" or "unchecked, label text".
---On click, toggles the value, plays a sound, and announces only the new state.
---
---@param config fa.ui.controls.CheckboxConfig
---@return fa.ui.graph.NodeVtable
function mod.checkbox(config)
   local state_on = config.state_labels and config.state_labels.on or { "fa.checked" }
   local state_off = config.state_labels and config.state_labels.off or { "fa.unchecked" }
   local label_fn = UiUtils.to_label_function(config.label)

   return {
      label = function(ctx)
         local state_text = config.get() and state_on or state_off
         ctx.message:fragment(state_text)
         label_fn(ctx)
      end,
      on_click = function(ctx)
         local new_val = not config.get()
         config.set(new_val)
         UiSounds.play_menu_move(ctx.pindex)
         local state_text = new_val and state_on or state_off
         ctx.controller.message:fragment(state_text)
      end,
   }
end

return mod
