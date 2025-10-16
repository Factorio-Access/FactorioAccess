# Control Behavior Analysis for FactorioAccess

Analysis of all 34 control behavior types in Factorio 2.0, categorized by complexity.

## Categories

### Combinator (4 types)
Complex parameter objects requiring specialized UI. All need dedicated handling.

1. **LuaArithmeticCombinatorControlBehavior**
   - Parameters: `ArithmeticCombinatorParameters` (complex struct)
   - Parent: LuaCombinatorControlBehavior

2. **LuaDeciderCombinatorControlBehavior**
   - Parameters: `DeciderCombinatorParameters` (complex struct)
   - Methods: `get_condition`, `set_condition`, `add_condition`, `remove_condition`, `get_output`, `set_output`, `add_output`, `remove_output`
   - Parent: LuaCombinatorControlBehavior

3. **LuaSelectorCombinatorControlBehavior**
   - Parameters: `SelectorCombinatorParameters` (complex struct)
   - Parent: LuaCombinatorControlBehavior

4. **LuaConstantCombinatorControlBehavior**
   - Fields: `enabled` (boolean), `sections` (Array[LuaLogisticSection]), `sections_count` (uint)
   - Methods: `add_section`, `remove_section`, `get_section`
   - Parent: LuaControlBehavior

### Complex (2 types)
Require specialized UI or complex nested structures.

5. **LuaDisplayPanelControlBehavior**
   - Fields: `messages` (Array[DisplayPanelMessageDefinition])
   - Methods: `get_message(index)`, `set_message(index, message)`
   - Parent: LuaControlBehavior

6. **LuaProgrammableSpeakerControlBehavior**
   - Fields: `circuit_parameters` (ProgrammableSpeakerCircuitParameters), `circuit_condition` (CircuitConditionDefinition)
   - Parent: LuaControlBehavior

### Simple (28 types)
Only have fields that can be toggled/set. These are the target for initial implementation.

#### Base Class
- **LuaGenericOnOffControlBehavior** (abstract, parent for many simple types)
  - `disabled` (boolean, read-only)
  - `circuit_enable_disable` (boolean)
  - `circuit_condition` (CircuitConditionDefinition)
  - `connect_to_logistic_network` (boolean)
  - `logistic_condition` (CircuitConditionDefinition)

#### Simple Control Behaviors

7. **LuaAccumulatorControlBehavior**
   - Parent: LuaControlBehavior
   - Fields:
     - `read_charge` (boolean)
     - `output_signal` (SignalID, optional)

8. **LuaAgriculturalTowerControlBehavior**
   - Parent: LuaGenericOnOffControlBehavior
   - Fields:
     - `read_contents` (boolean)

9. **LuaArtilleryTurretControlBehavior**
   - Parent: LuaGenericOnOffControlBehavior
   - Fields:
     - `read_ammo` (boolean)

10. **LuaAssemblingMachineControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `circuit_set_recipe` (boolean)
      - `circuit_read_contents` (boolean)
      - `include_in_crafting` (boolean)
      - `include_fuel` (boolean)
      - `circuit_read_ingredients` (boolean)
      - `circuit_read_recipe_finished` (boolean)
      - `circuit_recipe_finished_signal` (SignalID, optional)
      - `circuit_read_working` (boolean)
      - `circuit_working_signal` (SignalID, optional)

11. **LuaAsteroidCollectorControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `set_filter` (boolean)
      - `read_content` (boolean)
      - `include_hands` (boolean)

12. **LuaCargoLandingPadControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `circuit_exclusive_mode_of_operation` (defines.control_behavior.cargo_landing_pad.exclusive_mode)

13. **LuaContainerControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `read_contents` (boolean)

14. **LuaFurnaceControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `circuit_read_contents` (boolean)
      - `include_in_crafting` (boolean)
      - `include_fuel` (boolean)
      - `circuit_read_ingredients` (boolean)
      - `circuit_read_recipe_finished` (boolean)
      - `circuit_recipe_finished_signal` (SignalID, optional)
      - `circuit_read_working` (boolean)
      - `circuit_working_signal` (SignalID, optional)

15. **LuaInserterControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `circuit_set_filters` (boolean)
      - `circuit_read_hand_contents` (boolean)
      - `circuit_hand_read_mode` (defines.control_behavior.inserter.hand_read_mode)
      - `circuit_set_stack_size` (boolean)
      - `circuit_stack_control_signal` (SignalID, optional)

16. **LuaLampControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `use_colors` (boolean)
      - `color_mode` (defines.control_behavior.lamp.color_mode)
      - `red_signal` (SignalID, optional)
      - `green_signal` (SignalID, optional)
      - `blue_signal` (SignalID, optional)
      - `rgb_signal` (SignalID, optional)
      - `color` (Color, read-only, optional)

17. **LuaLoaderControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `circuit_set_filters` (boolean)
      - `circuit_read_transfers` (boolean)

18. **LuaLogisticContainerControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `circuit_exclusive_mode_of_operation` (defines.control_behavior.logistic_container.exclusive_mode)
      - `circuit_condition_enabled` (boolean)
      - `circuit_condition` (CircuitConditionDefinition)

19. **LuaMiningDrillControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `circuit_read_resources` (boolean)
      - `resource_read_mode` (defines.control_behavior.mining_drill.resource_read_mode)
      - `resource_read_targets` (Array[LuaEntity], read-only)

20. **LuaPumpControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `set_filter` (boolean)

21. **LuaRadarControlBehavior**
    - Parent: LuaControlBehavior
    - Fields: NONE (only inherits base class fields)

22. **LuaRailSignalBaseControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `red_signal` (SignalID, optional)
      - `orange_signal` (SignalID, optional)
      - `green_signal` (SignalID, optional)
      - `blue_signal` (SignalID, optional)
      - `close_signal` (boolean)
      - `read_signal` (boolean)
      - `circuit_condition` (CircuitConditionDefinition)

23. **LuaReactorControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `read_fuel` (boolean)
      - `read_temperature` (boolean)
      - `temperature_signal` (SignalID, optional)

24. **LuaRoboportControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `read_items_mode` (defines.control_behavior.roboport.read_items_mode)
      - `read_logistics` (boolean, legacy)
      - `read_robot_stats` (boolean)
      - `available_logistic_output_signal` (SignalID, optional)
      - `total_logistic_output_signal` (SignalID, optional)
      - `available_construction_output_signal` (SignalID, optional)
      - `total_construction_output_signal` (SignalID, optional)
      - `roboport_count_output_signal` (SignalID, optional)

25. **LuaRocketSiloControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `read_mode` (defines.control_behavior.rocket_silo.read_mode)

26. **LuaSpacePlatformHubControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `read_contents` (boolean)
      - `send_to_platform` (boolean)
      - `read_moving_from` (boolean)
      - `read_moving_to` (boolean)
      - `read_speed` (boolean)
      - `speed_signal` (SignalID, optional)
      - `read_damage_taken` (boolean)
      - `damage_taken_signal` (SignalID, optional)

27. **LuaStorageTankControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `read_contents` (boolean)

28. **LuaTrainStopControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `send_to_train` (boolean)
      - `read_from_train` (boolean)
      - `read_stopped_train` (boolean)
      - `set_trains_limit` (boolean)
      - `read_trains_count` (boolean)
      - `stopped_train_signal` (SignalID, optional)
      - `trains_count_signal` (SignalID, optional)
      - `trains_limit_signal` (SignalID, optional)
      - `set_priority` (boolean)
      - `priority_signal` (SignalID, optional)

29. **LuaTransportBeltControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `read_contents` (boolean)
      - `read_contents_mode` (defines.control_behavior.transport_belt.content_read_mode)

30. **LuaTurretControlBehavior**
    - Parent: LuaGenericOnOffControlBehavior
    - Fields:
      - `set_priority_list` (boolean)
      - `set_ignore_unlisted_targets` (boolean)
      - `ignore_unlisted_targets_condition` (CircuitConditionDefinition)
      - `read_ammo` (boolean)

31. **LuaWallControlBehavior**
    - Parent: LuaControlBehavior
    - Fields:
      - `circuit_condition` (CircuitConditionDefinition)
      - `open_gate` (boolean)
      - `read_sensor` (boolean)
      - `output_signal` (SignalID, optional)

## Field Types in Simple Control Behaviors

All simple control behaviors use only the following field types:

### 1. **boolean**
Simple on/off toggle values.
Examples: `read_charge`, `circuit_enable_disable`, `use_colors`

### 2. **SignalID** (optional)
Circuit signal selection. Always optional (can be nil).
Structure: `{type = "item"/"fluid"/"virtual", name = "signal-name"}`
Examples: `output_signal`, `red_signal`, `circuit_stack_control_signal`

### 3. **CircuitConditionDefinition**
Circuit network condition (comparator + signals/constant).
Structure: `{comparator = "...", first_signal = SignalID, second_signal = SignalID, constant = int, ...}`
Examples: `circuit_condition`, `logistic_condition`, `ignore_unlisted_targets_condition`

### 4. **defines.control_behavior.X.Y**
Enumeration values from nested defines.
Examples:
- `defines.control_behavior.inserter.hand_read_mode`
- `defines.control_behavior.lamp.color_mode`
- `defines.control_behavior.mining_drill.resource_read_mode`
- `defines.control_behavior.transport_belt.content_read_mode`
- `defines.control_behavior.rocket_silo.read_mode`
- `defines.control_behavior.roboport.read_items_mode`
- `defines.control_behavior.logistic_container.exclusive_mode`
- `defines.control_behavior.cargo_landing_pad.exclusive_mode`

### 5. **Color** (read-only)
Only in LuaLampControlBehavior. Read-only field, not settable.
Structure: `{r = 0-1, g = 0-1, b = 0-1, a = 0-1}`

### 6. **Array[LuaEntity]** (read-only)
Only in LuaMiningDrillControlBehavior (`resource_read_targets`). Read-only field, not settable.

## Summary

- **Combinator behaviors:** 4 types - require specialized handling
- **Complex behaviors:** 2 types - require specialized handling
- **Simple behaviors:** 28 types - **TARGET FOR INITIAL IMPLEMENTATION**

Simple behaviors only use:
- Writable: boolean, SignalID, CircuitConditionDefinition, define enumerations
- Read-only: Color, Array[LuaEntity]

All 28 simple behaviors can be described using a unified system based on these 4 writable field types.
