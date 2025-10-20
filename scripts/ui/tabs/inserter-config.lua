--[[
Inserter configuration tab.

Provides controls for:
- Hand size (stack size override)
- Filter mode (allow/deny)
- Individual filter slots
]]

local FormBuilder = require("scripts.ui.form-builder")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiUtils = require("scripts.ui.ui-utils")
local UiSounds = require("scripts.ui.sounds")
local Filters = require("scripts.filters")
local Localising = require("scripts.localising")

local mod = {}

---Get the maximum stack size for an inserter based on prototype and force bonuses
---@param entity LuaEntity
---@return number
local function get_max_stack_size(entity)
   local force = entity.force
   local prototype = entity.prototype

   -- Base stack size from prototype
   local base_size = prototype.inserter_stack_size_bonus or 0
   -- That's a bonus, so 1 less than the real value.
   base_size = base_size + 1

   -- Add force bonuses
   if prototype.bulk then
      return base_size + force.bulk_inserter_capacity_bonus
   else
      return base_size + force.inserter_stack_size_bonus
   end
end

---Render the inserter configuration form
---@param ctx fa.ui.TabContext
---@return fa.ui.graph.Render?
local function render_inserter_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local form = FormBuilder.FormBuilder.new()

   -- Get max stack size for this inserter
   local max_stack_size = get_max_stack_size(entity)

   -- Row 1: Hand size control (textfield with 0 = unset)
   local function build_hand_size_label(message, ctx)
      message:fragment({ "fa.inserter-hand-size" })

      local override = entity.inserter_stack_size_override
      if override == 0 then
         message:fragment({ "fa.inserter-hand-size-unset" })
      else
         message:fragment(tostring(override))
      end

      message:fragment({ "fa.inserter-hand-size-help" })
   end

   form:add_item("hand_size", {
      label = function(ctx)
         build_hand_size_label(ctx.message, ctx)
      end,
      on_click = function(ctx)
         local override = entity.inserter_stack_size_override
         local current_value = override == 0 and "" or tostring(override)
         ctx.controller:open_textbox(current_value, "hand_size")
      end,
      on_child_result = function(ctx, result)
         if result == "" or result == nil then
            -- Empty string means unset
            entity.inserter_stack_size_override = 0
            ctx.controller.message:fragment({ "fa.inserter-hand-size-unset" })
         else
            local num = tonumber(result)
            if num and num >= 1 and num <= max_stack_size and math.floor(num) == num then
               entity.inserter_stack_size_override = num
               ctx.controller.message:fragment(tostring(num))
            else
               UiSounds.play_ui_edge(ctx.pindex)
               ctx.controller.message:fragment({ "fa.inserter-hand-size-invalid", tostring(max_stack_size) })
            end
         end
      end,
      on_clear = function(ctx)
         entity.inserter_stack_size_override = 0
         ctx.controller.message:fragment({ "fa.inserter-hand-size-unset" })
      end,
   })

   -- Check if this inserter supports filters
   if entity.filter_slot_count == 0 then
      -- Row 2: No filters supported message
      form:add_label("no_filters", { "fa.inserter-filters-not-supported" })
   else
      -- Row 2: Filter mode control
      form:add_choice_field("filter_mode", { "fa.inserter-filter-mode" }, function()
         return entity.inserter_filter_mode or "whitelist"
      end, function(value)
         entity.inserter_filter_mode = value
      end, {
         { label = { "fa.inserter-filter-mode-allow" }, value = "whitelist" },
         { label = { "fa.inserter-filter-mode-deny" }, value = "blacklist" },
      })

      -- Row 3: Filter slots (all in one row)
      for i = 1, entity.filter_slot_count do
         local slot_index = i
         local get_value = function()
            local filter = entity.get_filter(slot_index)
            if filter and filter.name then return { type = "item", name = filter.name } end
            return nil
         end
         local set_value = function(signal)
            if signal and signal.name then
               Filters.set_filter(entity, slot_index, { name = signal.name })
            else
               Filters.set_filter(entity, slot_index, nil)
            end
         end

         -- Build vtable manually (same as add_signal but we need row_key)
         local label = { "fa.inserter-filter-slot", tostring(slot_index) }

         local function build_label(message, ctx)
            local base_label = UiUtils.to_label_function(label)(ctx)
            local signal = get_value()
            local value_text
            if signal and signal.name then
               local signal_type = signal.type or "item"
               value_text = signal_type .. " " .. signal.name
            else
               value_text = { "fa.empty" }
            end
            message:fragment(base_label)
            message:fragment(value_text)
         end

         local vtable = {
            label = function(ctx)
               build_label(ctx.message, ctx)
            end,
            on_click = function(ctx)
               ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = "filter_" .. slot_index })
            end,
            on_child_result = function(ctx, result)
               set_value(result)
               if result and result.name then
                  local signal_type = result.type or "item"
                  ctx.controller.message:fragment(signal_type .. " " .. result.name)
               else
                  ctx.controller.message:fragment({ "fa.empty" })
               end
            end,
            on_clear = function(ctx)
               set_value(nil)
               ctx.controller.message:fragment({ "fa.empty" })
            end,
         }

         -- Add with row_key to group all filters in one row
         form:add_item("filter_" .. slot_index, vtable, "filters")
      end
   end

   return form:build()
end

-- Create the tab descriptor
mod.inserter_config_tab = UiKeyGraph.declare_graph({
   name = "inserter-config",
   title = { "fa.inserter-config-title" },
   render_callback = render_inserter_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "inserter"
end

return mod
