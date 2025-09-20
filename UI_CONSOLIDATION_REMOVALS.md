# UI Consolidation - Functionality Removal Tracker

This document tracks functionality that has been temporarily removed during the UI consolidation from multiple UI names (INVENTORY, GUNS, CRAFTING, CRAFTING_QUEUE, TECHNOLOGY) to a single "main" UI.

## Status: IN PROGRESS
Most removals completed but additional references found that need cleanup.

## Additional References Found (2025-09-19)
### control.lua
- **Line 269**: `UI_NAMES.INVENTORY` check in toggle_menu - needs removal
- **Line 276**: `router:open_ui(UiRouter.UI_NAMES.INVENTORY)` in toggle_menu - should use MAIN
- **Line 6467**: `router:open_ui(UiRouter.UI_NAMES.CRAFTING)` - should use MAIN

## UI Names Being Consolidated into "main"
- **INVENTORY** - Player inventory
- **GUNS** - Weapons menu
- **CRAFTING** - Crafting menu
- **CRAFTING_QUEUE** - Crafting queue view
- **TECHNOLOGY** - Research/technology menu

## Affected Functionality by File

### control.lua

#### Navigation (WASD/Arrow Keys)
**Lines 670-698, 834-862, 992-1017, 1113-1141**
- **INVENTORY**: 10-slot vertical/horizontal movement with wrapping
- **CRAFTING**: Category-based navigation with menu sounds
- **CRAFTING_QUEUE**: Queue navigation with total count announcements
- **TECHNOLOGY**: Horizontal/vertical research menu navigation

#### Tab Navigation
**Lines 4633-4650, 4758-4773**
- Tab cycling between INVENTORY → CRAFTING → CRAFTING_QUEUE → TECHNOLOGY
- Shift+Tab reverse cycling
- Each transition includes specific announcements (e.g., "Crafting queue, X total")

#### Left Click Actions (Left Bracket)
**Lines 5024-5084**
- **INVENTORY**: Stack swapping with cursor
- **CRAFTING**: Recipe crafting with material checks, queuing support
- **CRAFTING_QUEUE**: Cancel single crafting order

#### Right Click Actions (Right Bracket)
**Lines 5647-5701**
- **INVENTORY**: Take half stack functionality
- **CRAFTING**: Craft 5 of selected recipe
- **CRAFTING_QUEUE**: Cancel 5 from queue

#### Special Actions
**Lines 5895-5921, 5996-5998, 6088-6090**
- **CRAFTING**: Craft all available (fa-crafting-all)
- **CRAFTING_QUEUE**: Cancel all in queue
- **TECHNOLOGY**: Add to research queue (start/end positions)

#### K Key (Read Coordinates/Info)
**Lines 3674-3738**
- **INVENTORY**: Read slot position as coordinates
- **CRAFTING**: Read recipe ingredients and products
- **TECHNOLOGY**: Read research costs

#### Y Key (Read Description)
**Lines 3795-3834**
- **CRAFTING**: Detailed recipe info with crafting time

#### Other Functions
**Lines 1884-1886**: Inventory close sound
**Lines 6342-6344**: Open guns menu from inventory (fa-guns-menu)
**Lines 6718-6720, 6761-6765**: Locate hand in inventory checks
**Lines 6983-6985, 7015-7017**: Logistics requests (inventory/spidertron)

### scripts/graphics.lua
**Lines 61-76**
- Visual indicators for each UI:
  - **TECHNOLOGY**: Lab sprite overhead
  - **INVENTORY**: Wooden chest sprite
  - **CRAFTING**: Repair pack sprite
  - **CRAFTING_QUEUE**: Repair pack with clock
  - **GUNS**: Pistol sprite

### scripts/item-descriptions.lua
**Lines 209-215**
- **GUNS**: Read guns menu description
- **TECHNOLOGY**: Technology description via Research.menu_describe
- **CRAFTING**: Crafting menu description

### scripts/quickbar.lua
**Lines 30-31, 92-93**
- Quick bar slot assignment from inventory

### scripts/worker-robots.lua
**Lines 352-359**
- **INVENTORY**: Logistics request setting from inventory slot
- **CRAFTING**: Logistics request from recipe products

## Logistics Keybindings to Track
While not directly removed, these will need reimplementation:
- Personal logistics requests toggle (fa-personal-logistics-requests-toggle)
- Toggle requesting from buffers (fa-buffers)
- Various logistics slot operations

## Legacy UI Logic Removed

### Crafting System (scripts/crafting.lua) - COMPLETED
Removed functions:
- `read_crafting_queue` - Queue reading for UI
- `load_crafting_queue` - Queue loading for UI
- `get_crafting_que_total` - Queue total calculation
- `read_crafting_slot` - Slot reading for UI

Kept utility functions:
- `get_recipes` - Recipe retrieval (still needed)
- `count_in_crafting_queue` - Queue counting (still needed)
- `recipe_missing_ingredients_info` - Ingredient checking
- `recipe_raw_ingredients_info` - Raw ingredient info
- `get_raw_ingredients_table` - Ingredient table creation

### Research System (scripts/research.lua) - COMPLETED
Removed functions:
- `menu_move_vertical` - Vertical navigation
- `menu_move_horizontal` - Horizontal navigation
- `menu_describe` - Technology description
- `menu_describe_costs` - Cost description
- `menu_start_research` - Start research from menu
- `menu_enqueue` - Queue from menu
- `menu_announce_entry` - Entry announcement

Kept utility functions:
- `enqueue` - Queue management (still needed)
- `get_progress_string` - Progress reporting
- `queue_announce` - Queue announcements
- `clear_queue` - Queue clearing
- `on_research_finished` - Event handler

### Guns Menu
- Weapons/ammo selection interface
- Gun statistics display

## Tab System Architecture
The current tab system uses sequential navigation (Tab/Shift+Tab) to cycle through UIs. This entire mechanism will be replaced with the new TabList-based architecture.

## Notes for Reimplementation

1. **Coordinate Reading**: The K key currently reads different info per UI type - needs unified handling in new system

2. **Visual Indicators**: Each UI has unique overhead sprites - need to handle in new unified UI

3. **Sound Feedback**: Different UIs use different sounds (menu moves, inventory clicks, etc.)

4. **Navigation Patterns**:
   - Inventory uses 10-column grid
   - Crafting uses category-based lists
   - Technology uses 2D navigation
   - All need reimplementation in new Grid/Menu builders

5. **Stack Operations**: Right-click and left-click have UI-specific behaviors that need to be reimplemented as tab-specific handlers

6. **Logistics Integration**: Current checks for inventory/crafting context when setting logistics requests

## Testing Considerations
After removal, these features will be non-functional until reimplemented:
- All crafting operations
- All research operations
- Inventory navigation beyond basic cursor movement
- Guns menu access
- Tab-based UI switching