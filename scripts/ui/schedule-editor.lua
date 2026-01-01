--Train schedule editor UI
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

-- Lookup tables for condition type field preservation when cycling types
local TYPES_WITH_TICKS = { time = true, inactivity = true }
local TYPES_WITH_CONDITION = {
   item_count = true,
   circuit = true,
   fuel_item_count_all = true,
   fuel_item_count_any = true,
}
local TYPES_WITH_STATION = {
   specific_destination_full = true,
   specific_destination_not_full = true,
   at_station = true,
   not_at_station = true,
}
local TYPES_WITH_COMPARATOR = {
   item_count = true,
   fluid_count = true,
   circuit = true,
   fuel_item_count_all = true,
   fuel_item_count_any = true,
}

---Get the next or previous condition type in the cycle
---@param current_type WaitConditionType
---@param allowed_types string[]? List of allowed types (defaults to MAIN_SCHEDULE_CONDITION_TYPES)
---@param reverse boolean? If true, cycle backward instead of forward
---@return WaitConditionType
local function get_next_condition_type(current_type, allowed_types, reverse)
   allowed_types = allowed_types or MAIN_SCHEDULE_CONDITION_TYPES

   -- Normalize fluid_count to item_count for cycling
   local search_type = current_type == "fluid_count" and "item_count" or current_type

   for i, ctype in ipairs(allowed_types) do
      if ctype == search_type then
         local next_index
         if reverse then
            next_index = ((i - 2) % #allowed_types) + 1
         else
            next_index = (i % #allowed_types) + 1
         end
         return allowed_types[next_index]
      end
   end

   -- If not found, default to first type
   return allowed_types[1]
end

---Check if a signal is a fluid (including the "any fluid" virtual signal)
---@param signal SignalID
---@return boolean
local function is_fluid_signal(signal)
   return signal.type == "fluid" or (signal.type == "virtual" and signal.name == "signal-fluid-parameter")
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

---Extract station name from rich text result, announcing any errors
---@param result string|{value: string, errors: LocalisedString[]?} Rich text result or plain string
---@param ctx fa.ui.graph.Ctx Context for error announcement
---@return string? station_name The extracted station name, or nil if empty
local function extract_station_name(result, ctx)
   local station_name
   if type(result) == "table" and result.value then
      if result.errors then
         UiSounds.play_ui_edge(ctx.pindex)
         for _, error_msg in ipairs(result.errors) do
            ctx.controller.message:fragment(error_msg)
         end
      end
      station_name = result.value
   else
      station_name = result
   end

   if not station_name or station_name == "" then
      UiSounds.play_ui_edge(ctx.pindex)
      ctx.controller.message:fragment({ "fa.schedule-station-name-required" })
      return nil
   end

   return station_name
end

---Generate condition key and suggest move, handling both interrupt and main schedule
---@param ctx fa.ui.graph.Ctx
---@param record_position ScheduleRecordPosition
---@param new_condition_index number
---@param key_prefix string
---@param records ScheduleRecord[]
local function suggest_condition_move(ctx, record_position, new_condition_index, key_prefix, records)
   local new_key
   if record_position.interrupt_index and not record_position.schedule_index then
      new_key = key_prefix .. "c" .. tostring(new_condition_index)
   else
      new_key = get_condition_key(records, record_position.schedule_index, new_condition_index, key_prefix)
   end
   ctx.graph_controller:suggest_move(new_key)
end

-- Shared announcers
local function announce_number(new_value)
   return tostring(math.floor(tonumber(new_value)))
end

local function announce_signal(new_value)
   return CircuitNetwork.localise_signal(new_value)
end

-- Factory for ticks-based conditions (time, inactivity)
local function make_ticks_handler(type_name)
   return {
      p1 = {
         constant = function(condition, new_value)
            local seconds = tonumber(new_value)
            if not seconds then return nil end
            return { type = type_name, ticks = math.floor(seconds) * 60 }
         end,
         get_current = function(condition)
            return tostring((condition.ticks or 0) / 60)
         end,
         announcer = announce_number,
      },
   }
end

-- Shared constant handler for circuit-like conditions
local function make_circuit_constant_handler(fixed_type)
   return {
      constant = function(condition, new_value)
         local num = tonumber(new_value)
         if not num then return nil end
         return {
            type = fixed_type or condition.type,
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
      announcer = announce_number,
   }
end

-- Shared p1 signal setter for circuit-like conditions
local function make_signal_setter(fixed_type, auto_fluid)
   return {
      setter = function(condition, new_value)
         local signal = new_value
         if not signal or not signal.name then return nil end
         local new_type = fixed_type or condition.type
         if auto_fluid and is_fluid_signal(signal) then new_type = "fluid_count" end
         return {
            type = new_type,
            condition = {
               first_signal = signal,
               comparator = (condition.condition and condition.condition.comparator) or "<",
               constant = (condition.condition and condition.condition.constant) or 0,
            },
         }
      end,
      announcer = announce_signal,
   }
end

-- Station name handler (shared by destination and at_station conditions)
local station_name_handler = {
   p1 = {
      constant = function(condition, new_value)
         return { type = condition.type, station = new_value }
      end,
      get_current = function(condition)
         return condition.station or ""
      end,
      announcer = function(new_value)
         return new_value
      end,
   },
}

-- Build PARAM_HANDLERS using factories
local PARAM_HANDLERS = {
   time = make_ticks_handler("time"),
   inactivity = make_ticks_handler("inactivity"),

   item_count = {
      p1 = make_signal_setter("item_count", true), -- auto_fluid converts to fluid_count
      constant = make_circuit_constant_handler(),
   },

   circuit = {
      p1 = make_signal_setter("circuit"),
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
         announcer = announce_signal,
      },
      constant = make_circuit_constant_handler("circuit"),
   },

   -- damage_taken is not in the cycle list but we keep the handler for reading existing conditions
   damage_taken = {
      p1 = {
         constant = function(condition, new_value)
            local damage = tonumber(new_value)
            if not damage then return nil end
            return { type = "damage_taken", damage = math.floor(damage) }
         end,
         get_current = function(condition)
            return tostring(condition.damage or 1000)
         end,
         announcer = announce_number,
      },
   },

   specific_destination_full = station_name_handler,
   specific_destination_not_full = station_name_handler,
   at_station = station_name_handler,
   not_at_station = station_name_handler,
}

-- Fuel handlers use same pattern as item_count but preserve type
local fuel_handlers = {
   p1 = make_signal_setter(), -- nil type means preserve condition.type
   constant = make_circuit_constant_handler(),
}
PARAM_HANDLERS.fuel_item_count_all = fuel_handlers
PARAM_HANDLERS.fuel_item_count_any = fuel_handlers
PARAM_HANDLERS.fluid_count = PARAM_HANDLERS.item_count

---Build vtable for a wait condition
---@param schedule LuaSchedule
---@param record_position ScheduleRecordPosition
---@param condition_index number
---@param condition WaitCondition
---@param row_key string
---@param key_prefix string? Prefix for node keys
---@param records ScheduleRecord[] All records for key generation
---@param allowed_types string[]? Allowed condition types (defaults to MAIN_SCHEDULE_CONDITION_TYPES)
---@param default_type WaitConditionType? Default type when adding new conditions
---@return fa.ui.graph.NodeVtable
local function build_condition_vtable(
   schedule,
   record_position,
   condition_index,
   condition,
   row_key,
   key_prefix,
   records,
   allowed_types,
   default_type
)
   key_prefix = key_prefix or ""
   allowed_types = allowed_types or MAIN_SCHEDULE_CONDITION_TYPES
   default_type = default_type or allowed_types[1]

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
         local reverse = ctx.modifiers and ctx.modifiers.shift
         local new_type = get_next_condition_type(condition.type, allowed_types, reverse)
         local new_condition = { type = new_type, compare_type = condition.compare_type }

         -- Preserve compatible fields when changing types
         if TYPES_WITH_TICKS[new_type] then
            new_condition.ticks = condition.ticks or 3600
         elseif TYPES_WITH_CONDITION[new_type] then
            if condition.condition then new_condition.condition = condition.condition end
         elseif TYPES_WITH_STATION[new_type] then
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

         if not TYPES_WITH_COMPARATOR[cond_type] then
            ctx.controller.message:fragment({ "fa.schedule-no-operator" })
            return
         end

         if not condition.condition then
            ctx.controller.message:fragment({ "fa.schedule-no-condition-set" })
            return
         end

         local current_op = condition.condition.comparator or "<"
         local new_op = (ctx.modifiers and ctx.modifiers.shift)
               and CircuitNetwork.get_prev_comparison_operator(current_op)
            or CircuitNetwork.get_next_comparison_operator(current_op)

         schedule.change_wait_condition(record_position, condition_index, {
            type = cond_type,
            condition = {
               first_signal = condition.condition.first_signal,
               comparator = new_op,
               constant = condition.condition.constant,
            },
         })
         ctx.controller.message:fragment(CircuitNetwork.localise_comparator(new_op))
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
         schedule.add_wait_condition(record_position, condition_index + 1, default_type)
         ctx.controller.message:fragment({ "fa.schedule-condition-added" })
         suggest_condition_move(ctx, record_position, condition_index + 1, key_prefix, records)
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
         suggest_condition_move(ctx, record_position, condition_index - 1, key_prefix, records)
      end,

      on_drag_down = function(ctx)
         local condition_count = schedule.get_wait_condition_count(record_position)
         if not condition_count or condition_index >= condition_count then
            ctx.controller.message:fragment({ "fa.schedule-already-last-condition" })
            return
         end

         schedule.drag_wait_condition(record_position, condition_index, condition_index + 1)
         ctx.controller.message:fragment({ "fa.schedule-condition-moved-down" })
         suggest_condition_move(ctx, record_position, condition_index + 1, key_prefix, records)
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
---@param schedule LuaSchedule
---@param record_position ScheduleRecordPosition
---@param record ScheduleRecord
---@param row_key string
---@param key_prefix string? Prefix for node keys
---@param records ScheduleRecord[] All records for key generation
---@return fa.ui.graph.NodeVtable
local function build_record_vtable(schedule, record_position, record, row_key, key_prefix, records)
   key_prefix = key_prefix or ""

   return {
      label = function(ctx)
         -- Announce temporary or interrupt status first (varies sooner = better for screen readers)
         if record.created_by_interrupt then
            ctx.message:fragment({ "fa.schedule-from-interrupt" })
         elseif record.temporary then
            ctx.message:fragment({ "fa.schedule-temporary" })
         end

         -- Destination name or rail position
         if record.station then
            ctx.message:fragment({ "fa.schedule-station", record.station })
         elseif record.rail then
            ctx.message:fragment({ "fa.schedule-rail-position" })
         else
            ctx.message:fragment({ "fa.schedule-no-destination" })
         end
         ctx.message:fragment({ "fa.schedule-station-hint" })
      end,

      on_click = function(ctx)
         -- Open station selector filtered to same surface
         local entity = ctx.global_parameters and ctx.global_parameters.entity
         local surface = entity and entity.valid and entity.surface or nil
         ctx.controller:open_child_ui(
            Router.UI_NAMES.STOP_SELECTOR,
            { surface = surface },
            { node = row_key, target = "station" }
         )
      end,

      on_action1 = function(ctx)
         -- Type a station name with rich text support
         ctx.controller:open_textbox("", { node = row_key, target = "station" }, { rich_text = true })
      end,

      -- Right click: go to this station (main schedule only, not interrupts)
      on_right_click = not record_position.interrupt_index and function(ctx)
         schedule.go_to_station(record_position.schedule_index)
         local destination = record.station or { "fa.schedule-rail-position" }
         ctx.controller.message:fragment({ "fa.schedule-going-to", destination })
      end or nil,

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
            local station_name = extract_station_name(result, ctx)
            if not station_name then return end

            schedule.remove_record(record_position)
            schedule.add_record({
               station = station_name,
               wait_conditions = record.wait_conditions,
               index = record_position,
            })

            ctx.controller.message:fragment(station_name)
         end
      end,
   }
end

---Build a list of schedule records and their conditions
---@param builder fa.ui.menu.MenuBuilder The menu builder to add to
---@param schedule LuaSchedule
---@param interrupt_index number? Optional interrupt index
---@param key_prefix string? Prefix for node keys
local function build_records_list(builder, schedule, interrupt_index, key_prefix)
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
         build_record_vtable(schedule, record_position, record, record_key, key_prefix, records)
      )

      -- Wait conditions
      local wait_conditions = schedule.get_wait_conditions(record_position)
      if wait_conditions and #wait_conditions > 0 then
         for j, condition in ipairs(wait_conditions) do
            local condition_key = get_condition_key(records, i, j, key_prefix)
            builder:add_item(
               condition_key,
               build_condition_vtable(schedule, record_position, j, condition, condition_key, key_prefix, records)
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
   local key_prefix = "interrupt-" .. tostring(interrupt_index) .. "-"

   -- Interrupt name row: label + editable name + remove button
   builder:start_row("interrupt-name-row")
   builder:add_item("interrupt-name", {
      label = function(label_ctx)
         label_ctx.message:fragment({ "fa.schedule-interrupt-name" })
         label_ctx.message:list_item(interrupt.name)
      end,
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
   builder:add_item("remove-interrupt", {
      label = function(label_ctx)
         label_ctx.message:fragment({ "fa.schedule-remove-interrupt" })
      end,
      on_click = function(click_ctx)
         local name = interrupt.name
         schedule.remove_interrupt(interrupt_index)
         click_ctx.controller.message:fragment({ "fa.schedule-interrupt-removed", name })
         click_ctx.graph_controller:suggest_move("interrupts-header")
      end,
   })
   builder:end_row()

   -- Trigger conditions row: header + conditions on same row
   local conditions = interrupt.conditions or {}

   builder:start_row("trigger-conditions-row")
   builder:add_label("trigger-conditions-header", { "fa.schedule-trigger-conditions" })

   if #conditions > 0 then
      for i, condition in ipairs(conditions) do
         local condition_key = key_prefix .. "c" .. tostring(i)

         local interrupt_vtable = build_condition_vtable(
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
   build_records_list(builder, schedule, interrupt_index, key_prefix)

   -- Add target stop button
   builder:add_clickable("add-target-stop", { "fa.schedule-add-target-stop" }, {
      on_click = function(click_ctx)
         local entity = click_ctx.global_parameters and click_ctx.global_parameters.entity
         local surface = entity and entity.valid and entity.surface or nil
         click_ctx.controller:open_child_ui(
            Router.UI_NAMES.STOP_SELECTOR,
            { surface = surface },
            { node = "add-target-stop" }
         )
      end,
      on_action1 = function(click_ctx)
         click_ctx.controller:open_textbox(
            "",
            { node = "add-target-stop" },
            { intro_message = { "fa.schedule-enter-station-name" }, rich_text = true }
         )
      end,
      on_child_result = function(click_ctx, result)
         local station_name = extract_station_name(result, click_ctx)
         if not station_name then return end

         local new_index = schedule.add_record({
            station = station_name,
            wait_conditions = {},
            index = { interrupt_index = interrupt_index },
         })

         click_ctx.controller.message:fragment({ "fa.schedule-record-added", station_name })
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
   build_records_list(builder, schedule, nil, "main-")

   -- Add stop buttons row
   builder:start_row("add-stops-row")

   builder:add_clickable("add_stop", { "fa.schedule-add-stop" }, {
      on_click = function(click_ctx)
         local entity = click_ctx.global_parameters and click_ctx.global_parameters.entity
         local surface = entity and entity.valid and entity.surface or nil
         click_ctx.controller:open_child_ui(Router.UI_NAMES.STOP_SELECTOR, { surface = surface }, { node = "add_stop" })
      end,
      on_action1 = function(click_ctx)
         click_ctx.controller:open_textbox(
            "",
            "add_stop",
            { intro_message = { "fa.schedule-enter-station-name" }, rich_text = true }
         )
      end,
      on_child_result = function(click_ctx, result)
         local station_name = extract_station_name(result, click_ctx)
         if not station_name then return end

         local new_index = schedule.add_record({
            station = station_name,
            wait_conditions = {},
         })

         click_ctx.controller.message:fragment({ "fa.schedule-record-added", station_name })
         if new_index then
            local updated_records = schedule.get_records() or {}
            click_ctx.graph_controller:suggest_move(get_record_key(updated_records, new_index, "main-"))
         end
      end,
   })

   builder:add_clickable("add_temp_stop", { "fa.schedule-add-temporary-stop" }, {
      on_click = function(click_ctx)
         local entity = click_ctx.global_parameters and click_ctx.global_parameters.entity
         local surface = entity and entity.valid and entity.surface or nil
         click_ctx.controller:open_child_ui(
            Router.UI_NAMES.STOP_SELECTOR,
            { surface = surface },
            { node = "add_temp_stop" }
         )
      end,
      on_action1 = function(click_ctx)
         click_ctx.controller:open_textbox(
            "",
            "add_temp_stop",
            { intro_message = { "fa.schedule-enter-station-name" }, rich_text = true }
         )
      end,
      on_child_result = function(click_ctx, result)
         local station_name = extract_station_name(result, click_ctx)
         if not station_name then return end

         local new_index = schedule.add_record({
            station = station_name,
            wait_conditions = {},
            temporary = true,
         })

         click_ctx.controller.message:fragment({ "fa.schedule-temporary-record-added", station_name })
         if new_index then
            local updated_records = schedule.get_records() or {}
            click_ctx.graph_controller:suggest_move(get_record_key(updated_records, new_index, "main-"))
         end
      end,
   })

   builder:end_row()

   -- Interrupts section
   builder:add_label("interrupts-header", { "fa.schedule-interrupts" })

   local interrupts = schedule.get_interrupts()
   for i, interrupt in ipairs(interrupts) do
      local interrupt_key = "interrupt-" .. tostring(i)
      builder:add_clickable(interrupt_key, interrupt.name, {
         on_click = function(click_ctx)
            click_ctx.graph_controller:suggest_move("interrupt-tab-" .. tostring(i))
         end,
         on_drag_up = function(drag_ctx)
            if i == 1 then
               UiSounds.play_ui_edge(drag_ctx.pindex)
               drag_ctx.controller.message:fragment({ "fa.schedule-already-first-interrupt" })
               return
            end
            schedule.drag_interrupt(i, i - 1)
            drag_ctx.controller.message:fragment({ "fa.schedule-interrupt-moved-up" })
            drag_ctx.graph_controller:suggest_move("interrupt-" .. tostring(i - 1))
         end,
         on_drag_down = function(drag_ctx)
            if i >= #interrupts then
               UiSounds.play_ui_edge(drag_ctx.pindex)
               drag_ctx.controller.message:fragment({ "fa.schedule-already-last-interrupt" })
               return
            end
            schedule.drag_interrupt(i, i + 1)
            drag_ctx.controller.message:fragment({ "fa.schedule-interrupt-moved-down" })
            drag_ctx.graph_controller:suggest_move("interrupt-" .. tostring(i + 1))
         end,
         on_clear = function(clear_ctx)
            schedule.remove_interrupt(i)
            clear_ctx.controller.message:fragment({ "fa.schedule-interrupt-removed", interrupt.name })
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
