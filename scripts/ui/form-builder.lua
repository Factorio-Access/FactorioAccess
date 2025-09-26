local Menu = require("scripts.ui.menu")
local UiUtils = require("scripts.ui.ui-utils")
local UiSounds = require("scripts.ui.sounds")
local Speech = require("scripts.speech")

local mod = {}

---@class fa.ui.form.FormBuilder
---@field entries fa.ui.menu.Entry[]
local FormBuilder = {}
local FormBuilder_meta = { __index = FormBuilder }

---Create a new form builder
---@return fa.ui.form.FormBuilder
function FormBuilder.new()
   return setmetatable({
      entries = {},
   }, FormBuilder_meta)
end

---Add a checkbox control
---@param name string Unique identifier for this control
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param get_value fun(): boolean Function that returns the current value
---@param set_value fun(boolean) Function that sets the new value
---@return fa.ui.form.FormBuilder
function FormBuilder:add_checkbox(name, label, get_value, set_value)
   -- Create label builder function that uses the getter
   local function build_label(message, ctx)
      local base_label = UiUtils.to_label_function(label)(ctx)
      local state_text = get_value() and { "fa.enabled" } or { "fa.disabled" }
      message:fragment(base_label)
      message:fragment(": ")
      message:fragment(state_text)
   end

   self:add_item(name, {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         local new_val = not get_value()
         set_value(new_val)
         UiSounds.play_menu_move(ctx.pindex)
         -- Only announce the new state, not the label
         local state_text = new_val and { "fa.enabled" } or { "fa.disabled" }
         Speech.speak(ctx.pindex, state_text)
      end,
   })

   return self
end

---Add a textfield control
---@param name string Unique identifier for this control
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param get_value fun(): string Function that returns the current value
---@param set_value fun(string) Function that sets the new value
---@return fa.ui.form.FormBuilder
function FormBuilder:add_textfield(name, label, get_value, set_value)
   -- Create label builder function that uses the getter
   local function build_label(message, ctx)
      local base_label = UiUtils.to_label_function(label)(ctx)
      local val = get_value()
      local value_text = val and val ~= "" and val or { "fa.empty" }
      message:fragment(base_label)
      message:fragment(": ")
      message:fragment(value_text)
   end

   self:add_item(name, {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         -- Pass the node key as the context so Graph can route the result back
         ctx.controller:open_textbox(get_value() or "", name)
      end,
      on_child_result = function(ctx, result)
         -- This will be called when textbox returns
         set_value(result)
         -- Only announce the new value
         local value_text = result ~= "" and result or { "fa.empty" }
         Speech.speak(ctx.pindex, value_text)
      end,
   })

   return self
end

---Add a choice field control
---@param name string Unique identifier for this control
---@param get_value fun(): any Function that returns the current value
---@param set_value fun(any) Function that sets the new value
---@param choices {label: LocalisedString, value: any}[] Array of choices
---@return fa.ui.form.FormBuilder
function FormBuilder:add_choice_field(name, get_value, set_value, choices)
   assert(#choices > 0, "Choice field must have at least one choice")

   local function find_current_index()
      local current = get_value()
      for i, choice in ipairs(choices) do
         if choice.value == current then return i end
      end
      error(string.format("Current value '%s' not found in choices for field '%s'", tostring(current), name))
   end

   local function get_current_label()
      local index = find_current_index()
      return choices[index].label
   end

   -- Create label builder function that uses the getter
   local function build_label(message, ctx)
      message:fragment(name)
      message:fragment(": ")
      message:fragment(get_current_label())
   end

   self:add_item(name, {
      label = function(ctx)
         build_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         local current_index = find_current_index()
         local direction = (ctx.modifiers and ctx.modifiers.shift) and -1 or 1
         local new_index = current_index + direction

         if new_index > #choices then
            new_index = 1
         elseif new_index < 1 then
            new_index = #choices
         end

         set_value(choices[new_index].value)
         UiSounds.play_menu_move(ctx.pindex)
         -- Only announce the new choice, not the full label
         Speech.speak(ctx.pindex, choices[new_index].label)
      end,
   })

   return self
end

---Add an action button
---@param name string Unique identifier for this control
---@param label LocalisedString | fun(fa.ui.graph.Ctx): LocalisedString
---@param callback fun(fa.ui.RouterController) Called when clicked, receives the controller
---@return fa.ui.form.FormBuilder
function FormBuilder:add_action(name, label, callback)
   self:add_item(name, {
      label = UiUtils.to_label_function(label),
      on_click = function(ctx)
         UiSounds.play_menu_move(ctx.pindex)
         callback(ctx.controller)
      end,
   })

   return self
end

---Internal method to add an item (delegates to menu builder pattern)
---@param key string
---@param vtable fa.ui.graph.NodeVtable
---@return fa.ui.form.FormBuilder
function FormBuilder:add_item(key, vtable)
   table.insert(self.entries, { key = key, vtable = vtable })
   return self
end

---Build the form into a key graph render
---@return fa.ui.graph.Render
function FormBuilder:build()
   local menu_builder = Menu.MenuBuilder.new()

   for _, entry in ipairs(self.entries) do
      menu_builder:add_item(entry.key, entry.vtable)
   end

   return menu_builder:build()
end

mod.FormBuilder = FormBuilder

return mod
