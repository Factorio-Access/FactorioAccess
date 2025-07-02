# Control.lua Module Extraction Report
## FactorioAccess Refactoring Recommendations

**Date:** January 2025  
**Author:** Principal Software Engineer Analysis  
**Subject:** Reducing control.lua complexity through strategic module extraction

---

## Executive Summary

The FactorioAccess mod's `control.lua` file has grown to 8,767 lines, creating significant challenges for both human developers and LLMs. This report presents a data-driven analysis of module extraction opportunities that would reduce the file by 47.5% while improving maintainability, testability, and LLM-friendliness.

### Key Findings
- **Current State:** 8,767 lines in a single file
- **Proposed State:** ~4,600 lines with 10 new focused modules
- **Impact:** 4,164 lines extracted (47.5% reduction)
- **Risk Level:** Low to medium with phased approach

---

## Top 10 Module Extraction Recommendations

### 1. Menu Navigation System ⭐ HIGHEST PRIORITY
**Lines to Extract:** 1112-1792, 5670-5910, 6293-6660, 6893-7000  
**New Module:** `scripts/ui/menu-navigation.lua`  
**Size Impact:** ~1,590 lines (18% of control.lua)

**Rationale:**
- Largest single extraction opportunity
- Highly repetitive code across different UI types
- Would dramatically reduce LLM context window usage
- Clear separation between menu types (inventory, crafting, technology, etc.)

**Implementation Notes:**
- Extract all `menu_cursor_*` functions
- Consolidate menu switching logic
- Maintain compatibility with UiRouter

---

### 2. Player Initialization System
**Lines to Extract:** 764-1111  
**New Module:** `scripts/player-init.lua`  
**Size Impact:** ~347 lines

**Rationale:**
- Zero runtime risk (pure data structure initialization)
- Documents all player state in one discoverable location
- Essential for understanding mod architecture
- Easy first extraction to build confidence

**Implementation Notes:**
- Extract entire `initialize()` function
- Include all default state structures
- Consider adding state documentation

---

### 3. Cursor Skip System
**Lines to Extract:** 4109-4520  
**New Module:** `scripts/cursor-skip.lua`  
**Size Impact:** ~411 lines

**Rationale:**
- Complex self-contained functionality
- Main function alone is 184 lines
- Specialized behavior for different entity types
- Perfect candidate for unit testing

**Implementation Notes:**
- Extract `cursor_skip_iteration()`, `apply_skip_by_preview_size()`, `cursor_skip()`
- Include all related event handlers
- Maintain existing API surface

---

### 4. Movement Core System
**Lines to Extract:** 3762-3958, 4018-4107, 4522-4601  
**New Module:** `scripts/movement-core.lua`  
**Size Impact:** ~358 lines

**Rationale:**
- Central movement logic embedded in control.lua
- Handles telestep, smooth walking, and step-by-walk modes
- Critical functionality that needs clarity
- Would consolidate all movement-related code

**Implementation Notes:**
- Extract `move()`, `cursor_mode_move()`, and helpers
- Include all movement key handlers
- Coordinate with existing travel-tools.lua

---

### 5. Coordinate Reading System
**Lines to Extract:** 4605-4999  
**New Module:** `scripts/coordinate-reader.lua`  
**Size Impact:** ~394 lines

**Rationale:**
- Contains massive 237-line `read_coords()` function
- Complex UI-state-dependent behavior
- Would benefit from splitting by UI type
- Frequently modified for new features

**Implementation Notes:**
- Consider breaking `read_coords()` into UI-specific functions
- Extract distance/direction calculation utilities
- Maintain backward compatibility

---

### 6. Entity Selection System
**Lines to Extract:** 124-265  
**New Module:** `scripts/entity-selection.lua`  
**Size Impact:** ~141 lines

**Rationale:**
- Core functionality used throughout the mod
- Clear API boundaries
- Well-defined entity prioritization logic
- High reuse value across features

**Implementation Notes:**
- Extract entity sorting and selection functions
- Include related constants (walkable types, etc.)
- Minimal refactoring needed

---

### 7. Inventory Reading System
**Lines to Extract:** 298-533  
**New Module:** `scripts/inventory-reader.lua`  
**Size Impact:** ~235 lines

**Rationale:**
- Cohesive inventory reading functionality
- Would complement existing crafting.lua
- Clear separation of reading vs. manipulation
- Improves discoverability

**Implementation Notes:**
- Extract all inventory reading functions
- Coordinate with existing crafting module
- Maintain consistent API patterns

---

### 8. Bump Detection System
**Lines to Extract:** 3370-3624  
**New Module:** `scripts/bump-detection.lua`  
**Size Impact:** ~254 lines

**Rationale:**
- Complex collision detection logic
- Manages its own state (bump statistics)
- Can be disabled/enabled independently
- Useful for debugging movement issues

**Implementation Notes:**
- Extract all bump/stuck detection functions
- Include state management
- Consider adding debug utilities

---

### 9. Area Mining Operations
**Lines to Extract:** 6030-6267  
**New Module:** `scripts/area-mining.lua`  
**Size Impact:** ~237 lines

**Rationale:**
- Clear domain boundary
- Works with existing PlayerMiningTools
- Consolidates area-based operations
- Natural module boundary

**Implementation Notes:**
- Could merge into PlayerMiningTools
- Extract area selection and clearing logic
- Maintain rendering integration

---

### 10. Item Click Handler
**Lines to Extract:** 6664-6864  
**New Module:** `scripts/item-click-handler.lua`  
**Size Impact:** ~200 lines

**Rationale:**
- Item-specific click handling logic
- Makes adding new item behaviors cleaner
- Reduces complexity in main click handler
- Clear responsibility boundary

**Implementation Notes:**
- Extract item type switch logic
- Maintain integration with other click handlers
- Consider extensibility pattern

---

