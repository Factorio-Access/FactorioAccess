--Here: Descriptors for control behavior fields
--Defines the structure and field types for simple control behaviors

local mod = {}

---@enum ControlBehaviorFieldType
mod.FIELD_TYPE = {
   BOOLEAN = "boolean",
   SIGNAL = "signal",
   CONDITION = "condition",
   CONDITION_WITH_ENABLE = "condition_with_enable",
   CHOICE = "choice",
}

---Merge base and derived field lists, with base fields appearing first
---@param base table|nil Base descriptor
---@param derived table Derived descriptor
---@return table Merged descriptor with combined fields
local function merge(base, derived)
   if not base then return derived end

   local result = {
      base = base.base, -- Keep original base reference
      fields = {},
   }

   -- Add base fields first
   for _, field in ipairs(base.fields) do
      table.insert(result.fields, field)
   end

   -- Add derived fields
   for _, field in ipairs(derived.fields) do
      table.insert(result.fields, field)
   end

   return result
end

-- Descriptor for the base GenericOnOff behavior
local generic_on_off_descriptor = {
   base = nil,
   fields = {
      {
         type = mod.FIELD_TYPE.CONDITION_WITH_ENABLE,
         name = "circuit_condition",
         enable_field = "circuit_enable_disable",
         condition_field = "circuit_condition",
         label = "cb-field.circuit-condition",
      },
      {
         type = mod.FIELD_TYPE.CONDITION_WITH_ENABLE,
         name = "logistic_condition",
         enable_field = "connect_to_logistic_network",
         condition_field = "logistic_condition",
         label = "cb-field.logistic-condition",
      },
   },
}

-- All simple control behavior descriptors
local descriptors = {
   [defines.control_behavior.type.accumulator] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_charge",
            label = "cb-field.read-charge",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "output_signal",
            label = "cb-field.output-signal",
         },
      },
   },

   [defines.control_behavior.type.agricultural_tower] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_contents",
            label = "cb-field.read-contents",
         },
      },
   },

   [defines.control_behavior.type.artillery_turret] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_ammo",
            label = "cb-field.read-ammo",
         },
      },
   },

   [defines.control_behavior.type.assembling_machine] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_set_recipe",
            label = "cb-field.circuit-set-recipe",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_contents",
            label = "cb-field.circuit-read-contents",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "include_in_crafting",
            label = "cb-field.include-in-crafting",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "include_fuel",
            label = "cb-field.include-fuel",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_ingredients",
            label = "cb-field.circuit-read-ingredients",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_recipe_finished",
            label = "cb-field.circuit-read-recipe-finished",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "circuit_recipe_finished_signal",
            label = "cb-field.circuit-recipe-finished-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_working",
            label = "cb-field.circuit-read-working",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "circuit_working_signal",
            label = "cb-field.circuit-working-signal",
         },
      },
   },

   [defines.control_behavior.type.asteroid_collector] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "set_filter",
            label = "cb-field.set-filter",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_content",
            label = "cb-field.read-content",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "include_hands",
            label = "cb-field.include-hands",
         },
      },
   },

   [defines.control_behavior.type.cargo_landing_pad] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "circuit_exclusive_mode_of_operation",
            label = "cb-field.circuit-exclusive-mode-of-operation",
            choices = {
               {
                  value = defines.control_behavior.cargo_landing_pad.exclusive_mode.none,
                  label = "cb-choice.cargo-landing-pad-exclusive-mode.none",
               },
               {
                  value = defines.control_behavior.cargo_landing_pad.exclusive_mode.send_contents,
                  label = "cb-choice.cargo-landing-pad-exclusive-mode.send-contents",
               },
               {
                  value = defines.control_behavior.cargo_landing_pad.exclusive_mode.set_requests,
                  label = "cb-choice.cargo-landing-pad-exclusive-mode.set-requests",
               },
            },
         },
      },
   },

   [defines.control_behavior.type.container] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_contents",
            label = "cb-field.read-contents",
         },
      },
   },

   [defines.control_behavior.type.furnace] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_contents",
            label = "cb-field.circuit-read-contents",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "include_in_crafting",
            label = "cb-field.include-in-crafting",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "include_fuel",
            label = "cb-field.include-fuel",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_ingredients",
            label = "cb-field.circuit-read-ingredients",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_recipe_finished",
            label = "cb-field.circuit-read-recipe-finished",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "circuit_recipe_finished_signal",
            label = "cb-field.circuit-recipe-finished-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_working",
            label = "cb-field.circuit-read-working",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "circuit_working_signal",
            label = "cb-field.circuit-working-signal",
         },
      },
   },

   [defines.control_behavior.type.generic_on_off] = generic_on_off_descriptor,

   [defines.control_behavior.type.inserter] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_set_filters",
            label = "cb-field.circuit-set-filters",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_hand_contents",
            label = "cb-field.circuit-read-hand-contents",
         },
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "circuit_hand_read_mode",
            label = "cb-field.circuit-hand-read-mode",
            choices = {
               {
                  value = defines.control_behavior.inserter.hand_read_mode.hold,
                  label = "cb-choice.inserter-hand-read-mode.hold",
               },
               {
                  value = defines.control_behavior.inserter.hand_read_mode.pulse,
                  label = "cb-choice.inserter-hand-read-mode.pulse",
               },
            },
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_set_stack_size",
            label = "cb-field.circuit-set-stack-size",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "circuit_stack_control_signal",
            label = "cb-field.circuit-stack-control-signal",
         },
      },
   },

   [defines.control_behavior.type.lamp] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "use_colors",
            label = "cb-field.use-colors",
         },
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "color_mode",
            label = "cb-field.color-mode",
            choices = {
               {
                  value = defines.control_behavior.lamp.color_mode.color_mapping,
                  label = "cb-choice.lamp-color-mode.color-mapping",
               },
               {
                  value = defines.control_behavior.lamp.color_mode.components,
                  label = "cb-choice.lamp-color-mode.components",
               },
               {
                  value = defines.control_behavior.lamp.color_mode.packed_rgb,
                  label = "cb-choice.lamp-color-mode.packed-rgb",
               },
            },
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "red_signal",
            label = "cb-field.red-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "green_signal",
            label = "cb-field.green-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "blue_signal",
            label = "cb-field.blue-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "rgb_signal",
            label = "cb-field.rgb-signal",
         },
      },
   },

   [defines.control_behavior.type.loader] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_set_filters",
            label = "cb-field.circuit-set-filters",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_transfers",
            label = "cb-field.circuit-read-transfers",
         },
      },
   },

   [defines.control_behavior.type.logistic_container] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "circuit_exclusive_mode_of_operation",
            label = "cb-field.circuit-exclusive-mode-of-operation",
            choices = {
               {
                  value = defines.control_behavior.logistic_container.exclusive_mode.none,
                  label = "cb-choice.logistic-container-exclusive-mode.none",
               },
               {
                  value = defines.control_behavior.logistic_container.exclusive_mode.send_contents,
                  label = "cb-choice.logistic-container-exclusive-mode.send-contents",
               },
               {
                  value = defines.control_behavior.logistic_container.exclusive_mode.set_requests,
                  label = "cb-choice.logistic-container-exclusive-mode.set-requests",
               },
            },
         },
         {
            type = mod.FIELD_TYPE.CONDITION_WITH_ENABLE,
            name = "circuit_condition",
            enable_field = "circuit_condition_enabled",
            condition_field = "circuit_condition",
            label = "cb-field.circuit-condition",
         },
      },
   },

   [defines.control_behavior.type.mining_drill] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "circuit_read_resources",
            label = "cb-field.circuit-read-resources",
         },
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "resource_read_mode",
            label = "cb-field.resource-read-mode",
            choices = {
               {
                  value = defines.control_behavior.mining_drill.resource_read_mode.entire_patch,
                  label = "cb-choice.mining-drill-resource-read-mode.entire-patch",
               },
               {
                  value = defines.control_behavior.mining_drill.resource_read_mode.this_miner,
                  label = "cb-choice.mining-drill-resource-read-mode.this-miner",
               },
            },
         },
      },
   },

   [defines.control_behavior.type.pump] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "set_filter",
            label = "cb-field.set-filter",
         },
      },
   },

   [defines.control_behavior.type.radar] = {
      base = nil,
      fields = {},
   },

   [defines.control_behavior.type.rail_signal] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "red_signal",
            label = "cb-field.red-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "orange_signal",
            label = "cb-field.orange-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "green_signal",
            label = "cb-field.green-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "blue_signal",
            label = "cb-field.blue-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "close_signal",
            label = "cb-field.close-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_signal",
            label = "cb-field.read-signal",
         },
         {
            type = mod.FIELD_TYPE.CONDITION,
            name = "circuit_condition",
            label = "cb-field.circuit-condition",
         },
      },
   },

   [defines.control_behavior.type.rail_chain_signal] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "red_signal",
            label = "cb-field.red-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "orange_signal",
            label = "cb-field.orange-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "green_signal",
            label = "cb-field.green-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "blue_signal",
            label = "cb-field.blue-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "close_signal",
            label = "cb-field.close-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_signal",
            label = "cb-field.read-signal",
         },
         {
            type = mod.FIELD_TYPE.CONDITION,
            name = "circuit_condition",
            label = "cb-field.circuit-condition",
         },
      },
   },

   [defines.control_behavior.type.reactor] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_fuel",
            label = "cb-field.read-fuel",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_temperature",
            label = "cb-field.read-temperature",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "temperature_signal",
            label = "cb-field.temperature-signal",
         },
      },
   },

   [defines.control_behavior.type.roboport] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "read_items_mode",
            label = "cb-field.read-items-mode",
            choices = {
               {
                  value = defines.control_behavior.roboport.read_items_mode.logistics,
                  label = "cb-choice.roboport-read-items-mode.logistics",
               },
               {
                  value = defines.control_behavior.roboport.read_items_mode.missing_requests,
                  label = "cb-choice.roboport-read-items-mode.missing-requests",
               },
               {
                  value = defines.control_behavior.roboport.read_items_mode.none,
                  label = "cb-choice.roboport-read-items-mode.none",
               },
            },
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_robot_stats",
            label = "cb-field.read-robot-stats",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "available_logistic_output_signal",
            label = "cb-field.available-logistic-output-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "total_logistic_output_signal",
            label = "cb-field.total-logistic-output-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "available_construction_output_signal",
            label = "cb-field.available-construction-output-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "total_construction_output_signal",
            label = "cb-field.total-construction-output-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "roboport_count_output_signal",
            label = "cb-field.roboport-count-output-signal",
         },
      },
   },

   [defines.control_behavior.type.rocket_silo] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "read_mode",
            label = "cb-field.read-mode",
            choices = {
               {
                  value = defines.control_behavior.rocket_silo.read_mode.logistic_inventory,
                  label = "cb-choice.rocket-silo-read-mode.logistic-inventory",
               },
               {
                  value = defines.control_behavior.rocket_silo.read_mode.none,
                  label = "cb-choice.rocket-silo-read-mode.none",
               },
               {
                  value = defines.control_behavior.rocket_silo.read_mode.orbital_requests,
                  label = "cb-choice.rocket-silo-read-mode.orbital-requests",
               },
            },
         },
      },
   },

   [defines.control_behavior.type.space_platform_hub] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_contents",
            label = "cb-field.read-contents",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "send_to_platform",
            label = "cb-field.send-to-platform",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_moving_from",
            label = "cb-field.read-moving-from",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_moving_to",
            label = "cb-field.read-moving-to",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_speed",
            label = "cb-field.read-speed",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "speed_signal",
            label = "cb-field.speed-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_damage_taken",
            label = "cb-field.read-damage-taken",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "damage_taken_signal",
            label = "cb-field.damage-taken-signal",
         },
      },
   },

   [defines.control_behavior.type.storage_tank] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_contents",
            label = "cb-field.read-contents",
         },
      },
   },

   [defines.control_behavior.type.train_stop] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "send_to_train",
            label = "cb-field.send-to-train",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_from_train",
            label = "cb-field.read-from-train",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_stopped_train",
            label = "cb-field.read-stopped-train",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "set_trains_limit",
            label = "cb-field.set-trains-limit",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_trains_count",
            label = "cb-field.read-trains-count",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "stopped_train_signal",
            label = "cb-field.stopped-train-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "trains_count_signal",
            label = "cb-field.trains-count-signal",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "trains_limit_signal",
            label = "cb-field.trains-limit-signal",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "set_priority",
            label = "cb-field.set-priority",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "priority_signal",
            label = "cb-field.priority-signal",
         },
      },
   },

   [defines.control_behavior.type.transport_belt] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_contents",
            label = "cb-field.read-contents",
         },
         {
            type = mod.FIELD_TYPE.CHOICE,
            name = "read_contents_mode",
            label = "cb-field.read-contents-mode",
            choices = {
               {
                  value = defines.control_behavior.transport_belt.content_read_mode.entire_belt_hold,
                  label = "cb-choice.transport-belt-content-read-mode.entire-belt-hold",
               },
               {
                  value = defines.control_behavior.transport_belt.content_read_mode.hold,
                  label = "cb-choice.transport-belt-content-read-mode.hold",
               },
               {
                  value = defines.control_behavior.transport_belt.content_read_mode.pulse,
                  label = "cb-choice.transport-belt-content-read-mode.pulse",
               },
            },
         },
      },
   },

   [defines.control_behavior.type.turret] = {
      base = generic_on_off_descriptor,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "set_priority_list",
            label = "cb-field.set-priority-list",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "set_ignore_unlisted_targets",
            label = "cb-field.set-ignore-unlisted-targets",
         },
         {
            type = mod.FIELD_TYPE.CONDITION,
            name = "ignore_unlisted_targets_condition",
            label = "cb-field.ignore-unlisted-targets-condition",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_ammo",
            label = "cb-field.read-ammo",
         },
      },
   },

   [defines.control_behavior.type.wall] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.CONDITION,
            name = "circuit_condition",
            label = "cb-field.circuit-condition",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "open_gate",
            label = "cb-field.open-gate",
         },
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_sensor",
            label = "cb-field.read-sensor",
         },
         {
            type = mod.FIELD_TYPE.SIGNAL,
            name = "output_signal",
            label = "cb-field.output-signal",
         },
      },
   },

   [defines.control_behavior.type.proxy_container] = {
      base = nil,
      fields = {
         {
            type = mod.FIELD_TYPE.BOOLEAN,
            name = "read_contents",
            label = "cb-field.read-contents",
         },
      },
   },
}

---Get complete descriptor for a control behavior type, merging all base classes
---@param type_from_defines defines.control_behavior.type Control behavior type
---@return table|nil Descriptor with merged fields, or nil if not found or not simple
function mod.describe_control_behavior(type_from_defines)
   local descriptor = descriptors[type_from_defines]
   if not descriptor then return nil end

   -- If no base, return as-is
   if not descriptor.base then return {
      base = nil,
      fields = descriptor.fields,
   } end

   -- Recursively merge with base
   local base_descriptor = descriptor.base
   local merged = merge(base_descriptor, descriptor)

   return merged
end

return mod
