--[[
Locomotive configuration tab.

Provides a configuration form for locomotives with:
- Manual/automatic mode toggle
- Train name
- Train contents
- Train fuel
]]

local FormBuilder = require("scripts.ui.form-builder")
local InventoryUtils = require("scripts.inventory-utils")
local TrainHelpers = require("scripts.rails.train-helpers")
local UiKeyGraph = require("scripts.ui.key-graph")
local Router = require("scripts.ui.router")
local UiSounds = require("scripts.ui.sounds")
local Speech = require("scripts.speech")

local mod = {}

---@class fa.ui.LocomotiveTabContext: fa.ui.TabContext
---@field tablist_shared_state fa.ui.EntityUI.SharedState

---Render the locomotive configuration form
---@param ctx fa.ui.LocomotiveTabContext
---@return fa.ui.graph.Render?
local function render_locomotive_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end
   assert(entity.type == "locomotive", "render: entity is not a locomotive")

   local train = entity.train
   if not train then return nil end

   local builder = FormBuilder.FormBuilder.new()

   -- Manual/automatic mode checkbox
   builder:add_checkbox("manual_mode", { "fa.locomotive-manual-mode" }, function()
      return train.manual_mode
   end, function(value)
      train.manual_mode = value
   end)

   -- Train name field
   builder:add_item("name", {
      label = function(ctx)
         local name = TrainHelpers.get_name(entity)
         local value_text = name ~= "" and name or { "fa.empty" }
         ctx.message:fragment(value_text)
         ctx.message:fragment({ "fa.locomotive-train-name" })
      end,
      on_click = function(ctx)
         ctx.controller:open_textbox("", "name")
      end,
      on_child_result = function(ctx, result)
         if not result or result == "" then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.locomotive-name-cannot-be-empty" })
         else
            TrainHelpers.set_name(entity, result)
            ctx.controller.message:fragment(result)
         end
      end,
   })

   -- Train contents label
   builder:add_label("contents", function(label_ctx)
      local train_contents = train.get_contents()
      local presenting = InventoryUtils.present_list(train_contents)
      if presenting then
         label_ctx.message:fragment({ "fa.locomotive-train-contents", presenting })
      else
         label_ctx.message:fragment({ "fa.locomotive-train-contents", { "fa.ent-info-inventory-empty" } })
      end
   end)

   -- Train fuel label
   builder:add_label("fuel", function(label_ctx)
      local train_fuel = TrainHelpers.get_fuel(entity)
      local presenting = InventoryUtils.present_list(train_fuel)
      if presenting then
         label_ctx.message:fragment({ "fa.locomotive-train-fuel", presenting })
      else
         label_ctx.message:fragment({ "fa.locomotive-train-fuel", { "fa.ent-info-inventory-empty" } })
      end
   end)

   -- Edit schedule button
   builder:add_action("edit_schedule", { "fa.locomotive-edit-schedule" }, function(controller)
      controller:open_child_ui(Router.UI_NAMES.SCHEDULE_EDITOR, { entity = entity })
   end)

   -- Train group control
   builder:add_item("train_group", {
      label = function(ctx)
         local player = game.get_player(ctx.pindex)
         if not player then return end
         local train = entity.train
         if not train then return end

         local group = train.group or ""
         if group == "" then
            ctx.message:fragment({ "fa.train-no-group" })
         else
            ctx.message:fragment(group)
         end
         ctx.message:fragment({ "fa.locomotive-train-group" })

         -- Add hint
         local groups = TrainHelpers.get_train_groups(player.force)
         if #groups > 0 then
            ctx.message:fragment({ "fa.locomotive-group-hint" })
         else
            ctx.message:fragment({ "fa.locomotive-no-groups-available" })
         end
      end,
      on_click = function(ctx)
         local player = game.get_player(ctx.pindex)
         if not player then return end

         local groups = TrainHelpers.get_train_groups(player.force)
         if #groups > 0 then
            ctx.controller:open_child_ui(Router.UI_NAMES.TRAIN_GROUP_SELECTOR, {}, { node = "train_group" })
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.locomotive-no-groups-available" })
         end
      end,
      on_child_result = function(ctx, result)
         if result ~= nil then
            local train = entity.train
            if not train then return end

            train.group = result
            if result == "" then
               ctx.controller.message:fragment({ "fa.locomotive-group-cleared" })
            else
               ctx.controller.message:fragment({ "fa.locomotive-group-set", result })
            end
         end
      end,
      on_clear = function(ctx)
         local train = entity.train
         if not train then return end

         train.group = ""
         ctx.controller.message:fragment({ "fa.locomotive-group-cleared" })
      end,
      on_action1 = function(ctx)
         ctx.controller:open_textbox("", { node = "train_group" }, { "fa.locomotive-train-group" })
      end,
      on_textbox_result = function(ctx, result)
         if result and result ~= "" then
            local train = entity.train
            if not train then return end

            train.group = result
            ctx.controller.message:fragment({ "fa.locomotive-group-set", result })
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.locomotive-name-cannot-be-empty" })
         end
      end,
   })

   return builder:build()
end

-- Create the tab descriptor
mod.locomotive_config_tab = UiKeyGraph.declare_graph({
   name = "locomotive-config",
   title = { "fa.locomotive-config-title" },
   render_callback = render_locomotive_config,
})

return mod
