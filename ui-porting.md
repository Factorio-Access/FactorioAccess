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
4. **GUNS** (`scripts/gun-menu.lua`) - Uses StorageManager and UiRouter but not TabList/KeyGraph

### ❌ Not Ported - Old System (15)

#### Core Game Interface (6)
1. **INVENTORY** - Player inventory management
2. **BUILDING** - Building/entity inventory and configuration
3. **VEHICLE** - Vehicle inventory and settings
4. **CRAFTING** - Crafting menu
5. **PLAYER_TRASH** - Trash slot management
6. **CRAFTING_QUEUE** - Crafting queue display

#### Entity Configuration (5)
7. **SPIDERTRON** (`scripts/spidertron.lua`) - Spidertron remote and settings
8. **ROBOPORT** (`scripts/worker-robots.lua`) - Roboport network management
9. **PUMP** - Pump configuration
10. **CIRCUIT_NETWORK** (`scripts/circuit-networks.lua`) - Circuit network configuration
11. **SIGNAL_SELECTOR** (`scripts/circuit-networks.lua`) - Signal selection for circuits
12. **BLUEPRINT_BOOK** (`scripts/blueprints.lua`) - Blueprint book management

#### Other Systems (3)
13. **TRAVEL** (`scripts/travel-tools.lua`) - Fast travel point management
14. **TECHNOLOGY** - Research menu
15. **WARNINGS** - Warning/alert display

## Removed Systems (Factorio 2.0 Incompatible)

The following systems have been removed due to complete API changes in Factorio 2.0:
- **TRAIN** - Train schedule and configuration (will be reimplemented)
- **TRAIN_STOP** - Train stop configuration (will be reimplemented)
- **RAIL_BUILDER** - Rail building interface (will be reimplemented)


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