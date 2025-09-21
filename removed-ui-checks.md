# Removed UI Checks from FactorioAccess

This document tracks all `is_ui_open` and `is_ui_one_of` checks that were removed from the codebase as part of the UI system modernization effort.

## Summary
- Total checks removed from control.lua: 132
- Total checks removed from other files: 8
- Total: 140 UI checks removed
- Date: 2025-09-20 (Updated: 2025-09-21)
- Purpose: Enable UI system to evolve beyond simple FSM to support advanced features like textboxes and item choosers

## UIs with Removed Checks

### PUMP (Offshore Pump Placement)
- **Lines affected**: 740-756, 883-900, 5031-5039
- **Functionality lost**:
  - Menu navigation (up/down) for pump placement options
  - Pump placement confirmation
- **Functions preserved**: `BuildingTools.build_offshore_pump_in_hand()` still exists

### WARNINGS
- **Lines affected**: 733-739, 869-882, 986-991, 1068-1084, 4436-4438, 4543-4545, 5040-5072
- **Functionality lost**:
  - Menu navigation (up/down/left/right)
  - Category/sector switching
  - Warning selection and actions
- **Functions preserved**: `Warnings.read_warnings_slot()` still exists

### TRAVEL (Fast Travel)
- **Lines affected**: 757-758, 901-902, 992-993, 1085-1086, 1344-1345, 1742-1744, 1872-1883, 3358-3362, 5073-5074
- **Functionality lost**:
  - Menu navigation
  - Travel point selection
  - Travel point editing via textfield
- **Functions preserved**:
  - `TravelTools.fast_travel_menu_up/down/left/right()`
  - `TravelTools.fast_travel_menu_click()`
  - `TravelTools.fast_travel_menu_close()`

### BLUEPRINT_BOOK
- **Lines affected**: 761-762, 905-906, 1352-1353, 1622-1624, 4624-4626, 4716-4718, 5079-5081
- **Functionality lost**:
  - Menu navigation
  - Blueprint selection
  - List mode handling
- **Functions preserved**:
  - `Blueprints.blueprint_book_menu_up/down()`
  - `Blueprints.blueprint_book_menu_close()`
  - `Blueprints.run_blueprint_book_menu()`

### CIRCUIT_NETWORK
- **Lines affected**: 763-765, 907-909, 1354-1355, 1815-1871, 4210-4237, 5082-5089
- **Functionality lost**:
  - Menu navigation
  - Circuit network configuration
  - Textfield input for constant values
- **Functions preserved**:
  - `CircuitNetworks.circuit_network_menu_open()`
  - `CircuitNetworks.circuit_network_menu_run()`
  - `CircuitNetworks.circuit_network_menu_close()`

### SIGNAL_SELECTOR
- **Lines affected**: 766-768, 910-912, 994-996, 1087-1089, 5090-5095
- **Functionality lost**:
  - Signal group navigation
  - Signal selection
- **Functions preserved**:
  - `CircuitNetworks.signal_selector_group_up/down()`
  - `CircuitNetworks.signal_selector_signal_prev/next()`
  - `CircuitNetworks.read_selected_signal_group()`
  - `CircuitNetworks.read_selected_signal_slot()`
  - `CircuitNetworks.apply_selected_signal_to_enabled_condition()`

### ROBOPORT
- **Lines affected**: 759-760, 903-904, 1348-1349, 5077-5078
- **Functionality lost**: None (already migrated to new UI system)
- **Note**: Comments indicate "Now handled by new UI system"

### SPIDERTRON
- **Lines affected**: 1317, 1346-1347, 5075-5076
- **Functionality lost**: None (already migrated to new UI system)
- **Functions preserved**: `SpidertronMenuUi.spidertron_menu:close()` still called in some contexts

### BLUEPRINT
- **Lines affected**: 1350-1351, 1620
- **Functionality lost**: Menu close handling
- **Functions preserved**: `BlueprintsMenu.blueprint_menu_tabs:close()`

### BUILDING/VEHICLE (via is_ui_one_of)
- **Lines affected**: 330-332, 671-732, 798-865, 923-983, 1008-1067, 3353-3357, 3532-3558, 4062-4063, 4078-4079, 4091-4092, 4106-4107, 4122-4123, 4135-4136, 4175-4178, 4358-4390, 4395-4435, 4502-4541, 4784-4787, 4799-4854, 5415-5460, 5635-5689, 5798-5800, 5817-5819, 6416-6418
- **Functionality lost**:
  - Extensive menu navigation for building/vehicle inventories
  - Recipe selection
  - Sector navigation
  - Inventory bar adjustments
- **Functions preserved**: Various building/vehicle sector functions

### Generic is_ui_open() (no specific UI)
- **Lines affected**: 632, 1138-1141, 1154, 1739-1745, 2091-2093, 2558-2561, 2578, 2619, 2721-2723, 2736, 2742, 2744, 2803, 2813, 2823, 2833, 3773-3774, 3965, 4020, 4030, 4041, 4212, 4292, 4340-4343, 4356, 4393-4394, 4462-4465, 4489-4491, 4500-4501, 4569-4571, 4595-4597, 4723, 4741, 4754, 5332-5334, 5577-5579, 5733, 5739-5740, 5762, 5880-5882, 5901-5903, 5992-5994
- **Functionality lost**:
  - Menu vs world input routing
  - Audio ruler updates when not in menus
  - Cursor mode restrictions
  - Various action guards
- **Note**: Many of these were simple guards to prevent world actions while in menus

## Migration Path
Each removed UI will need to be reimplemented using the new TabList-based UI system. Priority should be based on user impact:

1. **High Priority**: BUILDING/VEHICLE (core gameplay)
2. **Medium Priority**: TRAVEL, CIRCUIT_NETWORK, PUMP
3. **Low Priority**: WARNINGS, SIGNAL_SELECTOR, BLUEPRINT_BOOK (less frequently used)

## Additional Files with Removed Checks

### scanner/entrypoint.lua
- **Lines affected**: 497, 508, 519, 529, 537
- **Functionality lost**: Scanner blocking when in menus
- **Note**: Scanner can now be used while menus are open (handled by event priority)

### worker-robots.lua
- **Lines affected**: 341-389 (find_player_item_name), 516-533 (logistics_request_toggle_handler)
- **Functionality lost**:
  - Context-aware logistic request detection (chest vs personal vs spidertron)
  - Toggle buffer requests for requester chests
  - Spidertron logistics toggle
- **Note**: Now defaults to personal logistics only

### teleport.lua
- **Lines affected**: 47-49
- **Functionality lost**: Menu blocking for teleportation
- **Note**: Teleportation now allowed while in menus

## Notes
- Functions called from removed UI checks remain in the codebase for future use
- Inline UI code that wasn't abstracted to functions has been deleted
- The router module remains public for now (file moving was out of scope)
- Event priority system handles UI interception before world handlers