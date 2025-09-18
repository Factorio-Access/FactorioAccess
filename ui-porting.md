# UI System Porting Status

This document tracks the status of porting UIs from the old menu system to the new UI system (TabList/KeyGraph/MenuBuilder/GridBuilder).

## New UI System Components

The new UI system is located in `scripts/ui/` and consists of:
- **TabList** - Multi-tab UI support with shared state
- **KeyGraph** - Low-level directed graph for navigation
- **MenuBuilder** - High-level menu construction
- **GridBuilder** - Grid-based UI construction
- **Router** - Central UI state management

## Porting Status

### ✅ Fully Ported to New System (3)
1. **BELT** (`scripts/ui/belt-analyzer.lua`) - Belt network analysis
2. **GENERIC_INVENTORY** (`scripts/ui/generic-inventory.lua`) - New inventory system
3. **BLUEPRINT** (`scripts/ui/menus/blueprints-menu.lua`) - Blueprint editing

### 🔄 Partially Ported (1)
1. **GUNS** (`scripts/gun-menu.lua`) - Uses StorageManager and UiRouter but not TabList/KeyGraph

### ❌ Not Ported - Old System (18)

#### Core Game Interface (6)
1. **INVENTORY** - Player inventory management
2. **BUILDING** - Building/entity inventory and configuration
3. **VEHICLE** - Vehicle inventory and settings
4. **CRAFTING** - Crafting menu
5. **PLAYER_TRASH** - Trash slot management
6. **CRAFTING_QUEUE** - Crafting queue display

#### Entity Configuration (8)
7. **TRAIN** (`scripts/trains.lua`) - Train schedule and configuration
8. **SPIDERTRON** (`scripts/spidertron.lua`) - Spidertron remote and settings
9. **TRAIN_STOP** (`scripts/train-stops.lua`) - Train stop configuration
10. **ROBOPORT** (`scripts/worker-robots.lua`) - Roboport network management
11. **PUMP** - Pump configuration
12. **CIRCUIT_NETWORK** (`scripts/circuit-networks.lua`) - Circuit network configuration
13. **SIGNAL_SELECTOR** (`scripts/circuit-networks.lua`) - Signal selection for circuits
14. **BLUEPRINT_BOOK** (`scripts/blueprints.lua`) - Blueprint book management

#### Other Systems (4)
15. **TRAVEL** (`scripts/travel-tools.lua`) - Fast travel point management
16. **TECHNOLOGY** - Research menu
17. **WARNINGS** - Warning/alert display
18. **RAIL_BUILDER** (`scripts/rail-builder.lua`) - Rail building interface (currently broken in Factorio 2.0)

### 🚫 Not Real UIs (3)
These are state markers, not actual menus to port:
- **PROMPT** - Never opened, only checked to block input (appears to be unused)
- **BUILDING_NO_SECTORS** - Placeholder for buildings with no configurable options
- **VEHICLE_NO_SECTORS** - Placeholder for vehicles with no inventory

## Old System Characteristics

The old menu system typically uses:
- Direct storage access: `storage.players[pindex].MENU_NAME_menu`
- Navigation functions: `menu_up()`, `menu_down()`, `menu_left()`, `menu_right()`
- String-based menu states: `storage.players[pindex].menu = "menu_name"`
- Manual state management in `control.lua`
- Individual menu initialization in `scripts/player-init.lua`

## Migration Priority

Based on usage frequency and complexity, suggested migration order:

### High Priority
1. **INVENTORY** - Core gameplay, frequently used
2. **CRAFTING** - Core gameplay, frequently used
3. **BUILDING** - Very common interaction
4. **VEHICLE** - Common interaction

### Medium Priority
5. **TRAVEL** - Useful but not critical
6. **TRAIN** - Important for train users
7. **TECHNOLOGY** - Important but less frequent
8. **CIRCUIT_NETWORK** - Complex but less common

### Low Priority
- Remaining specialized menus

## Notes

- The new UI system provides better state management, navigation consistency, and error handling
- Migration requires significant refactoring as old menus are deeply integrated with control.lua
- Event handling needs to be moved from the massive if-elseif chain in control.lua to individual UI modules
- Textbox support needs to be integrated with the new UI system (currently uses old patterns)