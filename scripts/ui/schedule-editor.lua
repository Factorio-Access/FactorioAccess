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
local UiSounds = require("scripts.ui.sounds")
local RichText = require("scripts.rich-text")
local TrainHelpers = require("scripts.rails.train-helpers")

local mod = {}

---Condition type cycle order for main schedule wait conditions
---Edit this table to reorder condition types for better UX
local MAIN_SCHEDULE_CONDITION_TYPES = {
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

---Condition type cycle order for interrupt trigger conditions
local INTERRUPT_TRIGGER_CONDITION_TYPES = {
   "at_station",
   "not_at_station",
   "damage_taken",
   "specific_destination_full",
   "specific_destination_not_full",
   "destination_full_or_no_path",
   "passenger_present",
   "passenger_not_present",
   "item_count",
   "empty",
   "not_empty",
   "fuel_full",
   "fuel_item_count_all",
   "fuel_item_count_any",
   "circuit",
}

---Backward compatibility alias
local CONDITION_TYPE_ORDER = MAIN_SCHEDULE_CONDITION_TYPES

---Get the next condition type in the cycle
---@param current_type WaitConditionType
---@param allowed_types string[]? List of allowed types (defaults to MAIN_SCHEDULE_CONDITION_TYPES)
---@return WaitConditionType
local function get_next_condition_type(current_type, allowed_types)
   allowed_types = allowed_types or MAIN_SCHEDULE_CONDITION_TYPES

   -- Normalize fluid_count to item_count for cycling
   local search_type = current_type == "fluid_count" and "item_count" or current_type

   for i, ctype in ipairs(allowed_types) do
      if ctype == search_type then
         local next_index = (i % #allowed_types) + 1
         return allowed_types[next_index]
      end
   end

   -- If not found, default to first type
   return allowed_types[1]
end

---Check if a signal is a fluid
---@param signal SignalID
---@return boolean
local function is_fluid_signal(signal)
   return signal.type == "fluid"
end

---Create a record position for schedule operations
---@param schedule_index number
---@param interrupt_index number?
---@return ScheduleRecordPosition
local function make_record_position(schedule_index, interrupt_index)
   return {
      schedule_index = schedule_index,
      interrupt_index = interrupt_index,
   }
end

---Get the key for a schedule record tracking position within sublists
---@param records ScheduleRecord[] All records in the schedule
---@param record_index number Current record's 1-based index
---@param prefix string? Optional prefix
---@return string
local function get_record_key(records, record_index, prefix)
   prefix = prefix or ""
   local record = records[record_index]

   -- Determine suffix and count position within sublist
   local suffix, position = "", 0

   if record.created_by_interrupt then
      suffix = "-i"
      for i = 1, record_index do
         if records[i].created_by_interrupt then position = position + 1 end
      end
   elseif record.temporary then
      suffix = "-t"
      for i = 1, record_index do
         if records[i].temporary then position = position + 1 end
      end
   else
      suffix = "-p"
      for i = 1, record_index do
         if not records[i].temporary and not records[i].created_by_interrupt then position = position + 1 end
      end
   end

   return prefix .. "s" .. tostring(position) .. suffix
end

---Get the key for a wait condition
---@param records ScheduleRecord[] All records in the schedule
---@param record_index number Current record's 1-based index
---@param condition_index number Condition's 1-based index
---@param prefix string? Optional prefix
---@return string
local function get_condition_key(records, record_index, condition_index, prefix)
   local record_key = get_record_key(records, record_index, prefix)
   return record_key .. "-c" .. tostring(condition_index)
end

---Get the LuaSchedule from the train
---@param entity LuaEntity Locomotive entity
---@return LuaSchedule?
local function get_schedule(entity)
   local train = entity.train
   if not train then return nil end
   return train.get_schedule()
end

---Parameter handler for each condition type and parameter
---Each handler has:
---  - constant(condition, new_value) -> new_condition_data | nil (for textbox input)
---  - setter(condition, new_value) -> new_condition_data | nil (for signal chooser input)
---  - get_current(condition) -> string (to pre-populate textbox)
---  - announcer(new_value, condition) -> message fragment
local PARAM_HANDLERS = {}

-- Time condition handlers
PARAM_HANDLERS.time = {
   p1 = {
      constant = function(condition, new_value)
         local seconds = tonumber(new_value)
         if not seconds then return nil end

         return {
            type = "time",
            ticks = math.floor(seconds) * 60,
         }
      end,
      get_current = function(condition)
         return tostring((condition.ticks or 0) / 60)
      end,
      announcer = function(new_value, condition)
         return tostring(math.floor(tonumber(new_value)))
      end,
   },
}

-- Inactivity condition handlers
PARAM_HANDLERS.inactivity = {
   p1 = {
      constant = function(condition, new_value)
         local seconds = tonumber(new_value)
         if not seconds then return nil end

         return {
            type = "inactivity",
            ticks = math.floor(seconds) * 60,
         }
      end,
      get_current = function(condition)
         return tostring((condition.ticks or 0) / 60)
      end,
      announcer = function(new_value, condition)
         return tostring(math.floor(tonumber(new_value)))
      end,
   },
}

-- Item count condition handlers
PARAM_HANDLERS.item_count = {
   p1 = {
      setter = function(condition, new_value)
         local signal = new_value
         if not signal or not signal.name then return nil end

         -- Auto-convert to fluid_count if signal is a fluid
         local new_type = is_fluid_signal(signal) and "fluid_count" or "item_count"

         return {
            type = new_type,
            condition = {
               first_signal = signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               constant = (condition.condition and condition.condition.constant) or 0,
            },
         }
      end,
      announcer = function(new_value, condition)
         return CircuitNetwork.localise_signal(new_value)
      end,
   },
   constant = {
      constant = function(condition, new_value)
         local num = tonumber(new_value)
         if not num then return nil end

         return {
            type = condition.type,
            condition = {
               first_signal = condition.condition and condition.condition.first_signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               constant = math.floor(num),
            },
         }
      end,
      get_current = function(condition)
         return tostring((condition.condition and condition.condition.constant) or 0)
      end,
      announcer = function(new_value, condition)
         return tostring(math.floor(tonumber(new_value)))
      end,
   },
}

-- Fluid count uses same handlers as item_count
PARAM_HANDLERS.fluid_count = PARAM_HANDLERS.item_count

-- Circuit condition handlers
PARAM_HANDLERS.circuit = {
   p1 = {
      setter = function(condition, new_value)
         local signal = new_value
         if not signal or not signal.name then return nil end

         return {
            type = "circuit",
            condition = {
               first_signal = signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               constant = (condition.condition and condition.condition.constant) or 0,
            },
         }
      end,
      announcer = function(new_value, condition)
         return CircuitNetwork.localise_signal(new_value)
      end,
   },
   p2 = {
      setter = function(condition, new_value)
         local signal = new_value
         if not signal or not signal.name then return nil end

         return {
            type = "circuit",
            condition = {
               first_signal = condition.condition and condition.condition.first_signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               second_signal = signal,
            },
         }
      end,
      announcer = function(new_value, condition)
         return CircuitNetwork.localise_signal(new_value)
      end,
   },
   constant = {
      constant = function(condition, new_value)
         local num = tonumber(new_value)
         if not num then return nil end

         return {
            type = "circuit",
            condition = {
               first_signal = condition.condition and condition.condition.first_signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               constant = math.floor(num),
            },
         }
      end,
      get_current = function(condition)
         return tostring((condition.condition and condition.condition.constant) or 0)
      end,
      announcer = function(new_value, condition)
         return tostring(math.floor(tonumber(new_value)))
      end,
   },
}

-- Fuel condition handlers (both all and any use same logic)
local fuel_handlers = {
   p1 = {
      setter = function(condition, new_value)
         local signal = new_value
         if not signal or not signal.name then return nil end

         return {
            type = condition.type,
            condition = {
               first_signal = signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               constant = (condition.condition and condition.condition.constant) or 0,
            },
         }
      end,
      announcer = function(new_value, condition)
         return CircuitNetwork.localise_signal(new_value)
      end,
   },
   constant = {
      constant = function(condition, new_value)
         local num = tonumber(new_value)
         if not num then return nil end

         return {
            type = condition.type,
            condition = {
               first_signal = condition.condition and condition.condition.first_signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               constant = math.floor(num),
            },
         }
      end,
      get_current = function(condition)
         return tostring((condition.condition and condition.condition.constant) or 0)
      end,
      announcer = function(new_value, condition)
         return tostring(math.floor(tonumber(new_value)))
      end,
   },
}

PARAM_HANDLERS.fuel_item_count_all = fuel_handlers
PARAM_HANDLERS.fuel_item_count_any = fuel_handlers

-- Specific destination condition handlers
local destination_handlers = {
   p1 = {
      constant = function(condition, new_value)
         return {
            type = condition.type,
            station = new_value,
         }
      end,
      get_current = function(condition)
         return condition.station or ""
      end,
      announcer = function(new_value, condition)
         return new_value
      end,
   },
}

PARAM_HANDLERS.specific_destination_full = destination_handlers
PARAM_HANDLERS.specific_destination_not_full = destination_handlers

-- at_station / not_at_station (interrupt triggers)
local at_station_handlers = {
   p1 = {
      constant = function(condition, new_value)
         return {
            type = condition.type,
            station = new_value,
         }
      end,
      get_current = function(condition)
         return condition.station or ""
      end,
      announcer = function(new_value, condition)
         return new_value
      end,
   },
}

PARAM_HANDLERS.at_station = at_station_handlers
PARAM_HANDLERS.not_at_station = at_station_handlers

-- damage_taken (interrupt trigger)
PARAM_HANDLERS.damage_taken = {
   p1 = {
      constant = function(condition, new_value)
         local damage = tonumber(new_value)
         if not damage then return nil end
         return {
            type = "damage_taken",
            damage = math.floor(damage),
         }
      end,
      get_current = function(condition)
         return tostring(condition.damage or 1000)
      end,
      announcer = function(new_value, condition)
         return tostring(math.floor(tonumber(new_value)))
      end,
   },
}

---Build vtable for a wait condition
---@param entity LuaEntity Locomotive entity
---@param schedule LuaSchedule
---@param record_position ScheduleRecordPosition
---@param condition_index number
---@param condition WaitCondition
---@param row_key string
---@param key_prefix string? Prefix for node keys
---@param records ScheduleRecord[] All records for key generation
---@param allowed_types string[]? Allowed condition types (defaults to MAIN_SCHEDULE_CONDITION_TYPES)
---@return fa.ui.graph.NodeVtable
local function build_condition_vtable(
   entity,
   schedule,
   record_position,
   condition_index,
   condition,
   row_key,
   key_prefix,
   records,
   allowed_types
)
   key_prefix = key_prefix or ""
   allowed_types = allowed_types or MAIN_SCHEDULE_CONDITION_TYPES

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
         local new_type = get_next_condition_type(condition.type, allowed_types)
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
         elseif new_type == "at_station" or new_type == "not_at_station" then
            new_condition.station = condition.station or "Station"
         elseif new_type == "damage_taken" then
            new_condition.damage = condition.damage or 1000
         end

         schedule.change_wait_condition(record_position, condition_index, new_condition)
         ScheduleReader.read_wait_condition(ctx.controller.message, new_condition)
      end,

      on_action1 = function(ctx)
         local cond_type = condition.type
         local type_handlers = PARAM_HANDLERS[cond_type]

         if not type_handlers or not type_handlers.p1 then
            ctx.controller.message:fragment({ "fa.schedule-no-action1" })
            return
         end

         if ctx.modifiers and ctx.modifiers.shift then
            -- Shift+M: textbox (if p1 has constant)
            if type_handlers.p1.constant then
               ctx.controller:open_textbox("", { node = row_key, target = "p1" })
            else
               ctx.controller.message:fragment({ "fa.schedule-no-text-param" })
            end
         else
            -- M: signal chooser (if p1 has setter)
            if type_handlers.p1.setter then
               ctx.controller:open_child_ui(Router.UI_NAMES.SIGNAL_CHOOSER, {}, { node = row_key, target = "p1" })
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
         local type_handlers = PARAM_HANDLERS[cond_type]

         if not type_handlers then
            ctx.controller.message:fragment({ "fa.schedule-no-action3" })
            return
         end

         if ctx.modifiers and ctx.modifiers.shift then
            -- Shift+dot: type a constant (if constant parameter has constant function)
            if type_handlers.constant and type_handlers.constant.constant then
               ctx.controller:open_textbox("", { node = row_key, target = "constant" })
            else
               ctx.controller.message:fragment({ "fa.schedule-no-constant-param" })
            end
         else
            -- Dot: select p2 signal (if p2 has setter)
            if type_handlers.p2 and type_handlers.p2.setter then
               ctx.controller:open_child_ui(Router.UI_NAMES.SIGNAL_CHOOSER, {}, { node = row_key, target = "p2" })
            else
               ctx.controller.message:fragment({ "fa.schedule-no-second-signal" })
            end
         end
      end,

      on_add_to_row = function(ctx)
         local new_type = "time" -- Default condition type
         schedule.add_wait_condition(record_position, condition_index + 1, new_type)
         ctx.controller.message:fragment({ "fa.schedule-condition-added" })
         ctx.graph_controller:suggest_move(
            get_condition_key(records, record_position.schedule_index, condition_index + 1, key_prefix)
         )
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
         ctx.graph_controller:suggest_move(
            get_condition_key(records, record_position.schedule_index, condition_index - 1, key_prefix)
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
         ctx.graph_controller:suggest_move(
            get_condition_key(records, record_position.schedule_index, condition_index + 1, key_prefix)
         )
      end,

      on_child_result = function(ctx, result)
         if not ctx.child_context then return end
         local target = ctx.child_context.target
         local cond_type = condition.type

         -- Look up handler for this condition type and parameter
         local type_handlers = PARAM_HANDLERS[cond_type]
         if not type_handlers then
            ctx.controller.message:fragment({ "fa.schedule-unknown-condition", tostring(cond_type) })
            return
         end

         local param_handler = type_handlers[target]
         if not param_handler then
            ctx.controller.message:fragment({ "fa.error-invalid-parameter" })
            return
         end

         -- Try constant first, then setter
         local new_condition_data
         if param_handler.constant then
            new_condition_data = param_handler.constant(condition, result)
         elseif param_handler.setter then
            new_condition_data = param_handler.setter(condition, result)
         end

         if not new_condition_data then
            ctx.controller.message:fragment({ "fa.error-invalid-value" })
            return
         end

         -- Apply the change
         schedule.change_wait_condition(record_position, condition_index, new_condition_data)

         -- Announce the new value
         ctx.controller.message:fragment(param_handler.announcer(result, condition))
      end,
   }
end

---Build vtable for a schedule record (station/destination)
---@param entity LuaEntity Locomotive entity
---@param schedule LuaSchedule
---@param record_position ScheduleRecordPosition
---@param record ScheduleRecord
---@param row_key string
---@param key_prefix string? Prefix for node keys
---@param records ScheduleRecord[] All records for key generation
---@return fa.ui.graph.NodeVtable
local function build_record_vtable(entity, schedule, record_position, record, row_key, key_prefix, records)
   key_prefix = key_prefix or ""

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
            -- Type a station name with rich text support
            ctx.controller:open_textbox("", { node = row_key, target = "station" }, { rich_text = true })
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
         if record_position.schedule_index == 1 then
            ctx.controller.message:fragment({ "fa.schedule-already-first-record" })
            return
         end

         schedule.drag_record(record_position.schedule_index, record_position.schedule_index - 1)
         ctx.controller.message:fragment({ "fa.schedule-record-moved-up" })
         ctx.graph_controller:suggest_move(get_record_key(records, record_position.schedule_index - 1, key_prefix))
      end,

      on_drag_down = function(ctx)
         local record_count = schedule.get_record_count()
         if not record_count or record_position.schedule_index >= record_count then
            ctx.controller.message:fragment({ "fa.schedule-already-last-record" })
            return
         end

         schedule.drag_record(record_position.schedule_index, record_position.schedule_index + 1)
         ctx.controller.message:fragment({ "fa.schedule-record-moved-down" })
         ctx.graph_controller:suggest_move(get_record_key(records, record_position.schedule_index + 1, key_prefix))
      end,

      on_child_result = function(ctx, result)
         if not ctx.child_context then return end
         local target = ctx.child_context.target

         if target == "station" then
            -- Handle rich text result (table with value and errors) or plain string
            local station_name
            if type(result) == "table" and result.value then
               if result.errors then
                  -- Announce errors but still accept the value
                  UiSounds.play_ui_edge(ctx.pindex)
                  for _, error_msg in ipairs(result.errors) do
                     ctx.controller.message:fragment(error_msg)
                  end
               end
               station_name = result.value
            else
               station_name = result
            end

            -- Validation
            if not station_name or station_name == "" then
               UiSounds.play_ui_edge(ctx.pindex)
               ctx.controller.message:fragment({ "fa.schedule-station-name-required" })
               return
            end

            -- Update the schedule
            schedule.remove_record(record_position)
            schedule.add_record({
               station = station_name,
               wait_conditions = record.wait_conditions,
               index = record_position,
            })

            -- Announce verbalized version
            local verbalized = RichText.verbalize_rich_text(station_name)
            ctx.controller.message:fragment(verbalized)
         end
      end,
   }
end

---Build a list of schedule records and their conditions
---@param builder MenuBuilder The menu builder to add to
---@param schedule LuaSchedule
---@param entity LuaEntity Locomotive entity
---@param interrupt_index number? Optional interrupt index
---@param key_prefix string? Prefix for node keys
local function build_records_list(builder, schedule, entity, interrupt_index, key_prefix)
   key_prefix = key_prefix or ""

   local records
   if interrupt_index then
      records = schedule.get_records(interrupt_index)
   else
      records = schedule.get_records()
   end
   if not records then records = {} end

   -- Each record as a row with its conditions
   for i, record in ipairs(records) do
      builder:start_row("row-" .. key_prefix .. tostring(i))

      -- Create record position with optional interrupt_index
      local record_position = make_record_position(i, interrupt_index)

      -- Stop/destination
      local record_key = get_record_key(records, i, key_prefix)
      builder:add_item(
         record_key,
         build_record_vtable(entity, schedule, record_position, record, record_key, key_prefix, records)
      )

      -- Wait conditions
      local wait_conditions = schedule.get_wait_conditions(record_position)
      if wait_conditions and #wait_conditions > 0 then
         for j, condition in ipairs(wait_conditions) do
            local condition_key = get_condition_key(records, i, j, key_prefix)
            builder:add_item(
               condition_key,
               build_condition_vtable(
                  entity,
                  schedule,
                  record_position,
                  j,
                  condition,
                  condition_key,
                  key_prefix,
                  records
               )
            )
         end
      else
         -- Empty placeholder for adding first condition
         builder:add_item(get_condition_key(records, i, 0, key_prefix) .. "-empty", {
            label = function(label_ctx)
               label_ctx.message:fragment({ "fa.schedule-no-conditions" })
            end,
            on_add_to_row = function(add_ctx)
               local new_type = "time"
               local condition_count = schedule.get_wait_condition_count(record_position) or 0
               local new_condition_index = condition_count + 1
               schedule.add_wait_condition(record_position, new_condition_index, new_type)
               add_ctx.controller.message:fragment({ "fa.schedule-condition-added" })
               add_ctx.graph_controller:suggest_move(get_condition_key(records, i, new_condition_index, key_prefix))
            end,
         })
      end

      builder:end_row()
   end
end

---Render an interrupt tab
---@param ctx fa.ui.graph.Ctx
---@param interrupt_index integer
---@return fa.ui.graph.Render?
local function render_interrupt_tab(ctx, interrupt_index)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   assert(entity and entity.valid, "render_interrupt_tab: entity is nil or invalid")
   assert(entity.type == "locomotive", "render_interrupt_tab: entity is not a locomotive")

   local schedule = get_schedule(entity)
   if not schedule then return nil end

   local interrupts = schedule.get_interrupts()
   local interrupt = interrupts[interrupt_index]
   if not interrupt then return nil end

   local builder = Menu.MenuBuilder.new()

   -- Interrupt name controls
   builder:add_label("interrupt-name-header", { "fa.schedule-interrupt-name" })
   builder:add_clickable("interrupt-name", interrupt.name, {
      on_click = function(click_ctx)
         click_ctx.controller:open_textbox(interrupt.name, "rename_interrupt", {
            intro_message = { "fa.schedule-enter-interrupt-name" },
         })
      end,
      on_child_result = function(click_ctx, result)
         local new_name = result

         if not new_name or new_name == "" then
            UiSounds.play_ui_edge(click_ctx.pindex)
            click_ctx.controller.message:fragment({ "fa.schedule-interrupt-name-required" })
            return
         end

         if not TrainHelpers.is_interrupt_name_unique(schedule, new_name, interrupt_index) then
            UiSounds.play_ui_edge(click_ctx.pindex)
            click_ctx.controller.message:fragment({ "fa.schedule-interrupt-name-exists", new_name })
            return
         end

         schedule.rename_interrupt(interrupt.name, new_name)
         click_ctx.controller.message:fragment({ "fa.schedule-interrupt-renamed", new_name })
      end,
   })

   -- Remove interrupt button
   builder:add_clickable("remove-interrupt", { "fa.schedule-remove-interrupt" }, {
      on_click = function(click_ctx)
         local name = interrupt.name
         schedule.remove_interrupt(interrupt_index)
         click_ctx.controller.message:fragment({ "fa.schedule-interrupt-removed", name })
         click_ctx.graph_controller:suggest_move("interrupts-header")
      end,
   })

   -- Trigger conditions section (single row with all conditions)
   builder:add_label("trigger-conditions-header", { "fa.schedule-trigger-conditions" })

   local conditions = interrupt.conditions or {}
   local key_prefix = "interrupt-" .. tostring(interrupt_index) .. "-"

   builder:start_row("trigger-conditions-row")

   if #conditions > 0 then
      for i, condition in ipairs(conditions) do
         local condition_key = key_prefix .. "c" .. tostring(i)

         local interrupt_vtable = build_condition_vtable(
            entity,
            schedule,
            { interrupt_index = interrupt_index },
            i,
            condition,
            condition_key,
            key_prefix,
            {},
            INTERRUPT_TRIGGER_CONDITION_TYPES
         )

         builder:add_item(condition_key, interrupt_vtable)
      end
   else
      -- Empty placeholder for adding first condition
      builder:add_item(key_prefix .. "c0-empty", {
         label = function(label_ctx)
            label_ctx.message:fragment({ "fa.schedule-no-conditions" })
         end,
         on_add_to_row = function(add_ctx)
            schedule.add_wait_condition({ interrupt_index = interrupt_index }, 1, "at_station")
            add_ctx.controller.message:fragment({ "fa.schedule-condition-added" })
            add_ctx.graph_controller:suggest_move(key_prefix .. "c1")
         end,
      })
   end

   builder:end_row()

   -- Target stops section
   builder:add_label("target-stops-header", { "fa.schedule-interrupt-targets" })

   -- Build the interrupt's target stops using build_records_list
   build_records_list(builder, schedule, entity, interrupt_index, key_prefix)

   -- Add target stop button
   builder:add_clickable("add-target-stop", { "fa.schedule-add-target-stop" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_textbox(
            "",
            { node = "add-target-stop" },
            { intro_message = { "fa.schedule-enter-station-name" }, rich_text = true }
         )
      end,
      on_child_result = function(click_ctx, result)
         local station_name
         if type(result) == "table" and result.value then
            if result.errors then
               UiSounds.play_ui_edge(click_ctx.pindex)
               for _, error_msg in ipairs(result.errors) do
                  click_ctx.controller.message:fragment(error_msg)
               end
            end
            station_name = result.value
         else
            station_name = result
         end

         if not station_name or station_name == "" then
            UiSounds.play_ui_edge(click_ctx.pindex)
            click_ctx.controller.message:fragment({ "fa.schedule-station-name-required" })
            return
         end

         local new_index = schedule.add_record({
            station = station_name,
            wait_conditions = {},
            index = { interrupt_index = interrupt_index },
         })

         local verbalized = RichText.verbalize_rich_text(station_name)
         click_ctx.controller.message:fragment({ "fa.schedule-record-added", verbalized })
         if new_index then
            local updated_records = schedule.get_records(interrupt_index) or {}
            click_ctx.graph_controller:suggest_move(get_record_key(updated_records, new_index, key_prefix))
         end
      end,
   })

   return builder:build()
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

   -- Build the main schedule records list
   build_records_list(builder, schedule, entity, nil, "main-")

   -- Add new stop button
   builder:add_clickable("add_stop", { "fa.schedule-add-stop" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_textbox(
            "",
            "add_stop",
            { intro_message = { "fa.schedule-enter-station-name" }, rich_text = true }
         )
      end,
      on_child_result = function(click_ctx, result)
         -- Handle rich text result (table with value and errors) or plain string
         local station_name
         if type(result) == "table" and result.value then
            if result.errors then
               -- Announce errors but still accept the value
               UiSounds.play_ui_edge(click_ctx.pindex)
               for _, error_msg in ipairs(result.errors) do
                  click_ctx.controller.message:fragment(error_msg)
               end
            end
            station_name = result.value
         else
            station_name = result
         end

         -- Validation
         if not station_name or station_name == "" then
            UiSounds.play_ui_edge(click_ctx.pindex)
            click_ctx.controller.message:fragment({ "fa.schedule-station-name-required" })
            return
         end

         local new_index = schedule.add_record({
            station = station_name,
            wait_conditions = {},
         })

         -- Announce verbalized version
         local verbalized = RichText.verbalize_rich_text(station_name)
         click_ctx.controller.message:fragment({ "fa.schedule-record-added", verbalized })
         if new_index then
            local updated_records = schedule.get_records() or {}
            click_ctx.graph_controller:suggest_move(get_record_key(updated_records, new_index, "main-"))
         end
      end,
   })

   -- Interrupts section
   builder:add_label("interrupts-header", { "fa.schedule-interrupts" })

   local interrupts = schedule.get_interrupts()
   for i, interrupt in ipairs(interrupts) do
      local interrupt_key = "interrupt-" .. tostring(i)
      builder:add_clickable(interrupt_key, interrupt.name, {
         on_click = function(click_ctx)
            -- Open the interrupt tab for this interrupt
            click_ctx.graph_controller:suggest_move("interrupt-tab-" .. tostring(i))
         end,
         drag_enabled = true,
         on_drag = function(drag_ctx, direction)
            local new_index = i + direction
            if new_index >= 1 and new_index <= #interrupts then
               schedule.drag_interrupt(i, new_index)
               if direction == -1 then
                  drag_ctx.controller.message:fragment({ "fa.schedule-interrupt-moved-up" })
               else
                  drag_ctx.controller.message:fragment({ "fa.schedule-interrupt-moved-down" })
               end
               drag_ctx.graph_controller:suggest_move("interrupt-" .. tostring(new_index))
            else
               UiSounds.play_ui_edge(drag_ctx.pindex)
               if direction == -1 then
                  drag_ctx.controller.message:fragment({ "fa.schedule-already-first-interrupt" })
               else
                  drag_ctx.controller.message:fragment({ "fa.schedule-already-last-interrupt" })
               end
            end
         end,
         on_delete = function(delete_ctx)
            schedule.remove_interrupt(i)
            delete_ctx.controller.message:fragment({ "fa.schedule-interrupt-removed", interrupt.name })
         end,
      })
   end

   -- Add interrupt button
   builder:add_clickable("add_interrupt", { "fa.schedule-add-interrupt" }, {
      on_click = function(click_ctx)
         local player = game.get_player(click_ctx.pindex)
         if not player then return end

         local all_interrupts = TrainHelpers.get_train_interrupts(player.force)

         if #all_interrupts == 0 then
            UiSounds.play_ui_edge(click_ctx.pindex)
            click_ctx.controller.message:fragment({ "fa.locomotive-no-interrupts-available" })
            return
         end

         click_ctx.controller:open_child_ui(Router.UI_NAMES.TRAIN_INTERRUPT_SELECTOR, {}, { node = "add_interrupt" })
      end,
      on_action1 = function(m_ctx)
         m_ctx.controller:open_textbox("", { node = "add_interrupt" }, { "fa.schedule-enter-interrupt-name" })
      end,
      on_child_result = function(ctx, result, context)
         if not result or result == "" then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.schedule-interrupt-name-required" })
            return
         end

         if not TrainHelpers.is_interrupt_name_unique(schedule, result) then
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.schedule-interrupt-name-exists", result })
            return
         end

         schedule.add_interrupt({
            name = result,
            conditions = {},
            targets = {},
         })
         ctx.controller.message:fragment({ "fa.schedule-interrupt-added", result })
         local updated_interrupts = schedule.get_interrupts()
         ctx.graph_controller:suggest_move("interrupt-" .. tostring(#updated_interrupts))
      end,
   })

   -- Clear all interrupts button
   if #interrupts > 0 then
      builder:add_clickable("clear_interrupts", { "fa.schedule-clear-interrupts" }, {
         on_click = function(click_ctx)
            local count = #interrupts
            for i = count, 1, -1 do
               schedule.remove_interrupt(i)
            end
            click_ctx.controller.message:fragment({ "fa.schedule-interrupts-cleared", tostring(count) })
         end,
      })
   end

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
      local entity = parameters and parameters.entity
      if not entity or not entity.valid or entity.type ~= "locomotive" then
         return {
            {
               name = "main",
               tabs = { schedule_editor_tab },
            },
         }
      end

      local schedule = get_schedule(entity)
      if not schedule then
         return {
            {
               name = "main",
               tabs = { schedule_editor_tab },
            },
         }
      end

      local tabs = { schedule_editor_tab }

      local interrupts = schedule.get_interrupts()
      for i, interrupt in ipairs(interrupts) do
         local interrupt_tab = KeyGraph.declare_graph({
            name = "interrupt-tab-" .. tostring(i),
            title = interrupt.name,
            render_callback = function(ctx)
               return render_interrupt_tab(ctx, i)
            end,
            get_help_metadata = function()
               return {
                  Help.message_list("schedule-editor"),
               }
            end,
         })

         table.insert(tabs, interrupt_tab)
      end

      return {
         {
            name = "main",
            tabs = tabs,
         },
      }
   end,
})

Router.register_ui(mod.schedule_editor_ui)

return mod
