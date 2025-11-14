--Train schedule editor UI
--Provides editing interface for train schedules (non-interrupt records only)
--Uses 2D layout: each row is a stop with its conditions

local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local CircuitNetwork = require("scripts.circuit-network")
local ScheduleReader = require("scripts.rails.schedule-reader")
local Speech = require("scripts.speech")
local Help = require("scripts.ui.help")

local mod = {}

---Condition type cycle order (excluding fluid_count which is reached via item_count)
---Edit this table to reorder condition types for better UX
local CONDITION_TYPE_ORDER = {
   "time",
   "inactivity",
   "item_count", -- fluid_count is skipped, reached by selecting fluid in signal picker
   "full",
   "empty",
   "not_empty",
   "fuel_item_count_all",
   "fuel_item_count_any",
   "fuel_full",
   "circuit",
   "robots_inactive",
   "passenger_present",
   "passenger_not_present",
   "specific_destination_full",
   "specific_destination_not_full",
}

---Get the next condition type in the cycle
---@param current_type WaitConditionType
---@return WaitConditionType
local function get_next_condition_type(current_type)
   -- Normalize fluid_count to item_count for cycling
   local search_type = current_type == "fluid_count" and "item_count" or current_type

   for i, ctype in ipairs(CONDITION_TYPE_ORDER) do
      if ctype == search_type then
         local next_index = (i % #CONDITION_TYPE_ORDER) + 1
         return CONDITION_TYPE_ORDER[next_index]
      end
   end

   -- If not found, default to first type
   return CONDITION_TYPE_ORDER[1]
end

---Check if a signal is a fluid
---@param signal SignalID
---@return boolean
local function is_fluid_signal(signal)
   return signal.type == "fluid"
end

---Get the key for a schedule record at index i
---@param i number
---@return string
local function get_record_key(i)
   return "s-" .. tostring(i)
end

---Get the key for a wait condition at record i, condition j
---@param record_index number
---@param condition_index number
---@return string
local function get_condition_key(record_index, condition_index)
   return "s-" .. tostring(record_index) .. "-c-" .. tostring(condition_index)
end

---Get the LuaSchedule from the train
---@param entity LuaEntity Locomotive entity
---@return LuaSchedule?
local function get_schedule(entity)
   local train = entity.train
   if not train then return nil end
   return train.get_schedule()
end

---Helper to validate and set a number from text input
---@param text_result string
---@param on_valid fun(num: number)
---@param ctx fa.ui.graph.Ctx
local function validate_and_set_number(text_result, on_valid, ctx)
   local num_value = tonumber(text_result)
   if num_value then
      on_valid(math.floor(num_value))
      ctx.controller.message:fragment(tostring(math.floor(num_value)))
   else
      ctx.controller.message:fragment({ "fa.error-invalid-number" })
   end
end

---Build vtable for a wait condition
---@param entity LuaEntity Locomotive entity
---@param schedule LuaSchedule
---@param record_index number
---@param condition_index number
---@param condition WaitCondition
---@param row_key string
---@return fa.ui.graph.NodeVtable
local function build_condition_vtable(entity, schedule, record_index, condition_index, condition, row_key)
   local record_position = { schedule_index = record_index }

   return {
      label = function(ctx)
         -- Add connector for conditions after the first
         if condition_index > 1 then
            local connector = condition.compare_type or "and"
            ctx.message:fragment({ "fa.schedule-connector-" .. connector })
         end

         ScheduleReader.read_wait_condition(ctx.message, condition)
      end,

      on_conjunction_modification = function(ctx)
         if condition_index == 1 then
            ctx.controller.message:fragment({ "fa.error-cannot-modify-first-condition" })
            return
         end

         local new_mode = (condition.compare_type == "and") and "or" or "and"
         schedule.set_wait_condition_mode(record_position, condition_index, new_mode)
         ctx.controller.message:fragment({ "fa.schedule-connector-" .. new_mode })
      end,

      on_toggle_supertype = function(ctx)
         local new_type = get_next_condition_type(condition.type)
         local new_condition = { type = new_type }

         -- Preserve compatible fields when changing types
         if new_type == "time" or new_type == "inactivity" then
            new_condition.ticks = condition.ticks or 3600 -- Default 60 seconds
         elseif new_type == "item_count" or new_type == "circuit" then
            if condition.condition then new_condition.condition = condition.condition end
         elseif new_type == "fuel_item_count_all" or new_type == "fuel_item_count_any" then
            if condition.condition then new_condition.condition = condition.condition end
         elseif new_type == "specific_destination_full" or new_type == "specific_destination_not_full" then
            new_condition.station = condition.station or "Station"
         end

         schedule.change_wait_condition(record_position, condition_index, new_condition)
         ScheduleReader.read_wait_condition(ctx.controller.message, new_condition)
      end,

      on_action1 = function(ctx)
         local cond_type = condition.type

         if ctx.modifiers and ctx.modifiers.shift then
            -- Shift+M: type a value (for station names, constants, etc.)
            if cond_type == "time" or cond_type == "inactivity" then
               local current_seconds = (condition.ticks or 0) / 60
               ctx.controller:open_textbox(tostring(current_seconds), { node = row_key, target = "seconds" })
            elseif cond_type == "specific_destination_full" or cond_type == "specific_destination_not_full" then
               ctx.controller:open_textbox(condition.station or "", { node = row_key, target = "station" })
            else
               ctx.controller.message:fragment({ "fa.schedule-no-text-param" })
            end
         else
            -- M: select signal/item
            if cond_type == "item_count" or cond_type == "fluid_count" then
               ctx.controller:open_child_ui(Router.UI_NAMES.SIGNAL_CHOOSER, {}, { node = row_key, target = "signal" })
            elseif cond_type == "circuit" then
               ctx.controller:open_child_ui(
                  Router.UI_NAMES.SIGNAL_CHOOSER,
                  {},
                  { node = row_key, target = "first_signal" }
               )
            elseif cond_type == "fuel_item_count_all" or cond_type == "fuel_item_count_any" then
               ctx.controller:open_child_ui(Router.UI_NAMES.SIGNAL_CHOOSER, {}, { node = row_key, target = "signal" })
            else
               ctx.controller.message:fragment({ "fa.schedule-no-signal-param" })
            end
         end
      end,

      on_action2 = function(ctx)
         local cond_type = condition.type

         -- Comma: change operator (for circuit/item/fluid conditions)
         if
            cond_type == "item_count"
            or cond_type == "fluid_count"
            or cond_type == "circuit"
            or cond_type == "fuel_item_count_all"
            or cond_type == "fuel_item_count_any"
         then
            if not condition.condition then
               ctx.controller.message:fragment({ "fa.schedule-no-condition-set" })
               return
            end

            local current_op = condition.condition.comparator or "<"
            local new_op = ctx.modifiers
                  and ctx.modifiers.shift
                  and CircuitNetwork.get_prev_comparison_operator(current_op)
               or CircuitNetwork.get_next_comparison_operator(current_op)

            local new_condition_data = {
               type = cond_type,
               condition = {
                  first_signal = condition.condition.first_signal,
                  comparator = new_op,
                  constant = condition.condition.constant,
               },
            }
            schedule.change_wait_condition(record_position, condition_index, new_condition_data)
            ctx.controller.message:fragment(CircuitNetwork.localise_comparator(new_op))
         else
            ctx.controller.message:fragment({ "fa.schedule-no-operator" })
         end
      end,

      on_action3 = function(ctx)
         local cond_type = condition.type

         if ctx.modifiers and ctx.modifiers.shift then
            -- Shift+dot: type a constant
            if
               cond_type == "item_count"
               or cond_type == "fluid_count"
               or cond_type == "circuit"
               or cond_type == "fuel_item_count_all"
               or cond_type == "fuel_item_count_any"
            then
               local current_value = (condition.condition and condition.condition.constant) or 0
               ctx.controller:open_textbox(tostring(current_value), { node = row_key, target = "constant" })
            else
               ctx.controller.message:fragment({ "fa.schedule-no-constant-param" })
            end
         else
            -- Dot: select second signal (circuit conditions only)
            if cond_type == "circuit" then
               ctx.controller:open_child_ui(
                  Router.UI_NAMES.SIGNAL_CHOOSER,
                  {},
                  { node = row_key, target = "second_signal" }
               )
            else
               ctx.controller.message:fragment({ "fa.schedule-no-second-signal" })
            end
         end
      end,

      on_add_to_row = function(ctx)
         local new_type = "time" -- Default condition type
         schedule.add_wait_condition(record_position, condition_index + 1, new_type)
         ctx.controller.message:fragment({ "fa.schedule-condition-added" })
         ctx.graph_controller:suggest_move(get_condition_key(record_index, condition_index + 1))
      end,

      on_clear = function(ctx)
         schedule.remove_wait_condition(record_position, condition_index)
         ctx.controller.message:fragment({ "fa.schedule-condition-removed" })
      end,

      on_drag_up = function(ctx)
         if condition_index == 1 then
            ctx.controller.message:fragment({ "fa.schedule-already-first-condition" })
            return
         end

         schedule.drag_wait_condition(record_position, condition_index, condition_index - 1)
         ctx.controller.message:fragment({ "fa.schedule-condition-moved-up" })
         ctx.graph_controller:hint_key(
            get_condition_key(record_index, condition_index),
            get_condition_key(record_index, condition_index - 1)
         )
      end,

      on_drag_down = function(ctx)
         local condition_count = schedule.get_wait_condition_count(record_position)
         if not condition_count or condition_index >= condition_count then
            ctx.controller.message:fragment({ "fa.schedule-already-last-condition" })
            return
         end

         schedule.drag_wait_condition(record_position, condition_index, condition_index + 1)
         ctx.controller.message:fragment({ "fa.schedule-condition-moved-down" })
         ctx.graph_controller:hint_key(
            get_condition_key(record_index, condition_index),
            get_condition_key(record_index, condition_index + 1)
         )
      end,

      on_child_result = function(ctx, result)
         if not ctx.child_context then return end
         local target = ctx.child_context.target
         local cond_type = condition.type

         if target == "signal" then
            -- For item_count/fluid_count: auto-convert based on signal type
            local signal = result
            if not signal or not signal.name then
               ctx.controller.message:fragment({ "fa.schedule-invalid-signal" })
               return
            end

            -- Determine if we need to switch between item_count and fluid_count
            local new_type = cond_type
            if cond_type == "item_count" or cond_type == "fluid_count" then
               new_type = is_fluid_signal(signal) and "fluid_count" or "item_count"
            end

            local new_condition_data = {
               type = new_type,
               condition = {
                  first_signal = signal,
                  comparator = (condition.condition and condition.condition.comparator) or "<",
                  constant = (condition.condition and condition.condition.constant) or 0,
               },
            }
            schedule.change_wait_condition(record_position, condition_index, new_condition_data)
            ctx.controller.message:fragment(CircuitNetwork.localise_signal(signal))
         elseif target == "first_signal" then
            -- Circuit condition first signal
            local signal = result
            if not signal or not signal.name then
               ctx.controller.message:fragment({ "fa.schedule-invalid-signal" })
               return
            end

            local new_condition_data = {
               type = cond_type,
               condition = {
                  first_signal = signal,
                  comparator = (condition.condition and condition.condition.comparator) or "<",
                  constant = (condition.condition and condition.condition.constant) or 0,
               },
            }
            schedule.change_wait_condition(record_position, condition_index, new_condition_data)
            ctx.controller.message:fragment(CircuitNetwork.localise_signal(signal))
         elseif target == "second_signal" then
            -- Circuit condition second signal
            local signal = result
            if not signal or not signal.name then
               ctx.controller.message:fragment({ "fa.schedule-invalid-signal" })
               return
            end

            local new_condition_data = {
               type = cond_type,
               condition = {
                  first_signal = condition.condition and condition.condition.first_signal,
                  comparator = (condition.condition and condition.condition.comparator) or "<",
                  second_signal = signal,
               },
            }
            schedule.change_wait_condition(record_position, condition_index, new_condition_data)
            ctx.controller.message:fragment(CircuitNetwork.localise_signal(signal))
         elseif target == "constant" then
            -- Set constant for conditions with CircuitCondition
            validate_and_set_number(result, function(num)
               local new_condition_data = {
                  type = cond_type,
                  condition = {
                     first_signal = condition.condition and condition.condition.first_signal,
                     comparator = (condition.condition and condition.condition.comparator) or "<",
                     constant = num,
                  },
               }
               schedule.change_wait_condition(record_position, condition_index, new_condition_data)
            end, ctx)
         elseif target == "seconds" then
            -- Time/inactivity seconds
            validate_and_set_number(result, function(seconds)
               local new_condition_data = {
                  type = cond_type,
                  ticks = seconds * 60,
               }
               schedule.change_wait_condition(record_position, condition_index, new_condition_data)
               ctx.controller.message:fragment({ "fa.schedule-seconds-set", tostring(seconds) })
            end, ctx)
         elseif target == "station" then
            -- Station name for specific_destination conditions
            local new_condition_data = {
               type = cond_type,
               station = result,
            }
            schedule.change_wait_condition(record_position, condition_index, new_condition_data)
            ctx.controller.message:fragment({ "fa.schedule-station-set", result })
         end
      end,
   }
end

---Build vtable for a schedule record (station/destination)
---@param entity LuaEntity Locomotive entity
---@param schedule LuaSchedule
---@param record_index number
---@param record ScheduleRecord
---@param row_key string
---@return fa.ui.graph.NodeVtable
local function build_record_vtable(entity, schedule, record_index, record, row_key)
   local record_position = { schedule_index = record_index }

   return {
      label = function(ctx)
         -- Just the destination name or rail position
         if record.station then
            ctx.message:fragment({ "fa.schedule-station", record.station })
         elseif record.rail then
            ctx.message:fragment({ "fa.schedule-rail-position" })
         else
            ctx.message:fragment({ "fa.schedule-no-destination" })
         end
      end,

      on_action1 = function(ctx)
         if ctx.modifiers and ctx.modifiers.shift then
            -- Type a station name
            local current_value = record.station or ""
            ctx.controller:open_textbox(current_value, { node = row_key, target = "station" })
         else
            -- TODO: Open station selector?
            ctx.controller.message:fragment({ "fa.schedule-station-selector-not-implemented" })
         end
      end,

      on_clear = function(ctx)
         -- Remove the entire record
         schedule.remove_record(record_position)
         ctx.controller.message:fragment({ "fa.schedule-record-removed" })
      end,

      on_drag_up = function(ctx)
         if record_index == 1 then
            ctx.controller.message:fragment({ "fa.schedule-already-first-record" })
            return
         end

         schedule.drag_record(record_index, record_index - 1)
         ctx.controller.message:fragment({ "fa.schedule-record-moved-up" })
         ctx.graph_controller:hint_key(get_record_key(record_index), get_record_key(record_index - 1))
      end,

      on_drag_down = function(ctx)
         local record_count = schedule.get_record_count()
         if not record_count or record_index >= record_count then
            ctx.controller.message:fragment({ "fa.schedule-already-last-record" })
            return
         end

         schedule.drag_record(record_index, record_index + 1)
         ctx.controller.message:fragment({ "fa.schedule-record-moved-down" })
         ctx.graph_controller:hint_key(get_record_key(record_index), get_record_key(record_index + 1))
      end,

      on_child_result = function(ctx, result)
         if not ctx.child_context then return end
         local target = ctx.child_context.target

         if target == "station" then
            -- Set the station name
            schedule.remove_record(record_position)
            schedule.add_record({
               station = result,
               wait_conditions = record.wait_conditions,
               index = record_position,
            })
            ctx.controller.message:fragment({ "fa.schedule-station-set", result })
         end
      end,
   }
end

---Render the train schedule editor
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_schedule_editor(ctx)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   assert(entity and entity.valid, "render_schedule_editor: entity is nil or invalid")
   assert(entity.type == "locomotive", "render_schedule_editor: entity is not a locomotive")

   local schedule = get_schedule(entity)
   if not schedule then return nil end

   local records = schedule.get_records()
   if not records then records = {} end

   local builder = Menu.MenuBuilder.new()

   -- Summary row
   builder:add_label("summary", function(label_ctx)
      local record_count = #records
      label_ctx.message:fragment({ "fa.schedule-record-count", tostring(record_count) })
   end)

   -- Each record as a row with its conditions
   for i, record in ipairs(records) do
      builder:start_row("row-" .. tostring(i))

      -- Stop/destination
      local record_key = get_record_key(i)
      builder:add_item(record_key, build_record_vtable(entity, schedule, i, record, record_key))

      -- Wait conditions
      local wait_conditions = schedule.get_wait_conditions({ schedule_index = i })
      if wait_conditions and #wait_conditions > 0 then
         for j, condition in ipairs(wait_conditions) do
            local condition_key = get_condition_key(i, j)
            builder:add_item(condition_key, build_condition_vtable(entity, schedule, i, j, condition, condition_key))
         end
      else
         -- Empty placeholder for adding first condition
         builder:add_item(get_condition_key(i, 0) .. "-empty", {
            label = function(label_ctx)
               label_ctx.message:fragment({ "fa.schedule-no-conditions" })
            end,
            on_add_to_row = function(add_ctx)
               local new_type = "time"
               local record_pos = { schedule_index = i }
               -- Get current condition count to know where to insert
               local condition_count = schedule.get_wait_condition_count(record_pos) or 0
               local new_condition_index = condition_count + 1
               print("Trying swapped params: record_pos first, then index " .. new_condition_index)
               schedule.add_wait_condition(record_pos, new_condition_index, new_type)
               add_ctx.controller.message:fragment({ "fa.schedule-condition-added" })
               add_ctx.graph_controller:suggest_move(get_condition_key(i, new_condition_index))
            end,
         })
      end

      builder:end_row()
   end

   -- Add new stop button
   builder:add_clickable("add_stop", { "fa.schedule-add-stop" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_textbox("", "add_stop", { "fa.schedule-enter-station-name" })
      end,
      on_child_result = function(click_ctx, result)
         if not result or result == "" then
            click_ctx.controller.message:fragment({ "fa.schedule-station-name-required" })
            return
         end

         local new_index = schedule.add_record({
            station = result,
            wait_conditions = {},
         })
         click_ctx.controller.message:fragment({ "fa.schedule-record-added", result })
         if new_index then click_ctx.graph_controller:suggest_move(get_record_key(new_index)) end
      end,
   })

   return builder:build()
end

-- Create the tab descriptor
local schedule_editor_tab = KeyGraph.declare_graph({
   name = "schedule-editor",
   title = { "fa.schedule-editor-title" },
   render_callback = render_schedule_editor,
   get_help_metadata = function()
      return {
         Help.message_list("schedule-editor"),
      }
   end,
})

---Create and register the schedule editor UI
mod.schedule_editor_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.SCHEDULE_EDITOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = function(pindex, parameters)
      return {
         {
            name = "main",
            tabs = { schedule_editor_tab },
         },
      }
   end,
})

Router.register_ui(mod.schedule_editor_ui)

return mod
