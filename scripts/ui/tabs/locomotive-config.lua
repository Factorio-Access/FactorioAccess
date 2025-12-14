--[[
Locomotive configuration tab.

Provides a configuration form for locomotives with:
- Manual/automatic mode toggle
- Train name
- Train driving (go to stop)
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

---Build a vtable for a "go to stop" button that adds a temporary schedule entry
---@param entity LuaEntity The locomotive entity
---@param wait_condition_type WaitConditionType The wait condition type to use
---@param label LocalisedString The button label
---@param node_key string The node key for child context
---@return fa.ui.graph.NodeVtable
local function build_go_to_stop_vtable(entity, wait_condition_type, label, node_key)
   return {
      label = function(ctx)
         ctx.message:fragment(label)
      end,
      on_click = function(ctx)
         local surface = entity.valid and entity.surface or nil
         ctx.controller:open_child_ui(Router.UI_NAMES.STOP_SELECTOR, { surface = surface }, { node = node_key })
      end,
      on_child_result = function(ctx, result)
         local station_name = result
         if not station_name or station_name == "" then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.locomotive-no-station-selected" })
            return
         end

         local train = entity.train
         if not train then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.locomotive-train-invalid" })
            return
         end

         local schedule = train.get_schedule()
         if not schedule then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.locomotive-no-schedule" })
            return
         end

         -- Add temporary stop with wait condition
         local new_index = schedule.add_record({
            station = station_name,
            temporary = true,
            wait_conditions = { { type = wait_condition_type } },
         })

         if new_index then
            -- Go to the new station (sets train to automatic)
            schedule.go_to_station(new_index)
            ctx.controller.message:fragment({ "fa.locomotive-going-to-stop", station_name })
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.locomotive-failed-to-add-stop" })
         end
      end,
   }
end

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

   -- Manual mode, edit schedule, and train group in a row
   builder:start_row("controls")

   -- Manual/automatic mode checkbox
   builder:add_checkbox("manual_mode", { "fa.locomotive-manual-mode" }, function()
      return train.manual_mode
   end, function(value)
      train.manual_mode = value
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
         ctx.message:fragment({ "fa.locomotive-group-hint" })
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

   builder:end_row()

   -- Train driving row
   builder:start_row("driving")

   builder:add_item(
      "go_to_wait_passenger",
      build_go_to_stop_vtable(
         entity,
         "passenger_present",
         { "fa.locomotive-go-wait-passenger" },
         "go_to_wait_passenger"
      )
   )

   builder:add_item(
      "go_to_wait_disembark",
      build_go_to_stop_vtable(
         entity,
         "passenger_not_present",
         { "fa.locomotive-go-wait-disembark" },
         "go_to_wait_disembark"
      )
   )

   builder:end_row()

   -- Train contents label (items)
   builder:add_label("contents", function(label_ctx)
      local train_contents = train.get_contents()
      local presenting = InventoryUtils.present_list(train_contents)
      if presenting then
         label_ctx.message:fragment({ "fa.locomotive-train-contents", presenting })
      else
         label_ctx.message:fragment({ "fa.locomotive-train-contents", { "fa.ent-info-inventory-empty" } })
      end
   end)

   -- Train fluid contents label
   builder:add_label("fluids", function(label_ctx)
      local fluid_contents = train.get_fluid_contents()
      local presenting = InventoryUtils.present_fluid_list(fluid_contents)
      if presenting then
         label_ctx.message:fragment({ "fa.locomotive-train-fluids", presenting })
      else
         label_ctx.message:fragment({ "fa.locomotive-train-fluids", { "fa.ent-info-inventory-empty" } })
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

   return builder:build()
end

-- Create the tab descriptor
mod.locomotive_config_tab = UiKeyGraph.declare_graph({
   name = "locomotive-config",
   title = { "fa.locomotive-config-title" },
   render_callback = render_locomotive_config,
})

return mod
