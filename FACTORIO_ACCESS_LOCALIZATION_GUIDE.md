# FactorioAccess Localization Guide

## Overview

This guide provides a systematic approach to localizing the FactorioAccess mod, converting hardcoded English strings to Factorio's LocalisedString format. The mod currently uses three patterns for text output, and this guide will help standardize on the correct patterns while maintaining the mod's functionality.

## Background: Localization Patterns in FactorioAccess

### Current Patterns (from worst to best)

1. **❌ Raw Strings (NOT localized)**
   ```lua
   Speech.speak(pindex, "This is English only")
   ```

2. **✅ Factorio LocalisedString**
   ```lua
   Speech.speak(pindex, {"fa.empty_cursor"})
   ```

3. **✅ MessageBuilder (for complex messages)**
   ```lua
   local message = MessageBuilder.new()
   message:fragment({"entity-name.transport-belt"})
   message:fragment({"fa.ent-info-facing", direction})
   Speech.speak(pindex, message:build())
   ```

## Understanding Factorio's LocalisedString

A LocalisedString is an array where:
- First element: The locale key (e.g., `"fa.empty-cursor"`)
- Remaining elements: Parameters to substitute

**CRITICAL**: All custom locale keys MUST use the `"fa."` prefix in code to reference the `[fa]` section in locale files, or they will display as "Unknown key: whatever" at runtime!

### Special Keys
- `""` - Concatenates all parameters
- `"?"` - Uses first valid parameter (fallback)

### Examples
```lua
-- Simple (CORRECT - starts with fa.)
{"fa.empty-cursor"}

-- With parameters (CORRECT)
{"fa.ent-info-facing", "north"}  -- Template: "facing __1__"

-- WRONG - missing fa. prefix
{"empty-cursor"}  -- Will show as "Unknown key: empty-cursor"

-- Concatenation using MessageBuilder (PREFERRED)
local msg = MessageBuilder.new()
msg:fragment({"entity-name.transport-belt"})
msg:fragment({"fa.ent-info-facing", "north"})
Speech.speak(pindex, msg:build())
```

### Limitations
- Maximum 20 parameters per LocalisedString (MessageBuilder handles this automatically)
- Maximum 20 levels of recursion
- Keys limited to 200 characters

## Current Status (December 2024)

### Completed Work

#### Wave 1: Simple Printout Localization ✓
- All direct `printout("string", pindex)` calls have been localized across major modules
- Modules completed: rail-builder, worker-robots, circuit-networks, and many others
- Over 100 simple messages converted to use locale keys

#### Wave 2: Localising.get() Replacement ✓
- All `localising.get()` calls replaced with `get_localised_name_with_fallback()`
- Fixed concatenated messages using LocalisedString arrays
- Modules updated: building-vehicle-sectors, circuit-networks, crafting

#### Wave 3: Unit Formatting and Dynamic Messages ✓
- Created unit formatting helpers in fa-utils.lua:
  - `format_power()` for watts/kilowatts/megawatts/etc
  - `format_distance_with_direction()` for "X tiles north"
  - `format_item_count()` for "item-name x count"
  - `format_slot_state()` for inventory slots
- Converted complex concatenations in building-tools, electrical, equipment
- Note: List building should use MessageBuilder, not custom helpers

#### Wave 9: High-Priority Concatenation Fixes ✓
- Fixed critical concatenations in control.lua printout calls
- Replaced remaining Localising.get() calls in control.lua
- Updated spidertron.lua, building-tools.lua, circuit-networks.lua, crafting.lua
- All tests passing (25/25)

### Remaining Work

Based on comprehensive analysis (see `hardcoded-strings-to-localize.md` for full details):

#### High Priority: Control.lua Localization
Control.lua contains **70+ hardcoded strings** that need immediate attention:
- **Menu messages**: "Another menu is open", "Menu closed", movement instructions
- **Error messages**: "Invalid input", "Error: No signals found", various craft requirement errors  
- **Status messages**: "Switched on/off", "Blank", "Empty", state changes
- **Combat messages**: "No ready weapons", damage reports
- **Building/crafting messages**: Machine requirements, placement errors

This represents the largest concentration of non-localized user-facing text.

#### Medium Priority: Remaining Module Strings
Several modules still have hardcoded strings:
- **fa-info.lua**: Damaged structure messages
- **building-vehicle-sectors.lua**: Menu navigation strings
- **rail-builder.lua**: Rail finding messages
- **menu-search.lua**: Search capability announcements

#### Low Priority: Complex Refactoring
Some areas require architectural changes:
- **String concatenation patterns**: Many functions build strings dynamically
- **Menu option keys**: Used for both display and logic
- **Debug/development messages**: Low user impact

### What "Wave 4" Actually Looks Like

Given that research.lua is already well-localized, the next logical "wave" should focus on:

1. **Control.lua Simple Strings** (30-40 messages)
   - Direct printout calls with hardcoded strings
   - Simple status messages that don't require refactoring
   - Error messages with no dynamic content

2. **Control.lua Complex Patterns** (20-30 patterns)
   - Damage/combat message building
   - Recipe requirement messages
   - Movement result messages

3. **Remaining Module Cleanup** (10-15 messages)
   - fa-info.lua damaged messages
   - Various menu-related strings

The actual work is less about "waves" now and more about systematic cleanup of the remaining ~100 hardcoded strings, with control.lua being the primary target.

## The Dependency Order Problem

The critical challenge is that functions returning strings for concatenation cannot be localized until their callers handle LocalisedStrings properly:

```lua
-- BEFORE: Can't localize get_status() yet
function get_status()
    return "Status: OK"  -- Returns plain string
end

function report_status(pindex)
    Speech.speak(pindex, "System " .. get_status())  -- Uses .. concatenation
end

-- MUST FIRST convert caller to handle LocalisedString
function report_status(pindex)
    local msg = MessageBuilder.new()
    msg:fragment({"fa.system"})
    msg:fragment(get_status())  -- Now can accept LocalisedString
    Speech.speak(pindex, msg:build())
end

-- THEN localize the function
function get_status()
    return {"fa.status-ok"}  -- Now returns LocalisedString
end
```

## Systematic Localization Process - Iterative Waves

The key to localizing a complex codebase is working in iterative "waves", where each wave unlocks more localization opportunities.

### Wave 1: Direct Printout Calls (Low-Hanging Fruit)

1. **Find Leaf Nodes**:
   ```bash
   rg 'printout\("' -n
   rg 'game\.print\("' -n  # Less common but exists
   ```

2. **Verify Safety**:
   - Function doesn't return the string
   - String isn't stored in a variable used elsewhere
   - No concatenation with .. operator

### Wave 2: String-Returning Functions

1. **Identify String Builders**:
   ```bash
   # Functions that return strings
   rg 'return\s+"[^"]+"\s*$' -n
   
   # Functions that might return concatenated strings
   rg 'return.*\.\.' -n
   
   # Table insertions of strings (often used in menu builders)
   rg 'table\.insert.*"[^"]+"' -n
   ```

2. **Trace Usage**:
   - Find where these functions are called
   - Check if callers can handle LocalisedString
   - If not, add to blocked list with reason

### Wave 3: String Constants and Tables

1. **Find String Storage**:
   ```bash
   # Module-level string constants
   rg '^local\s+\w+\s*=\s*"[^"]+"' -n
   
   # String tables/arrays
   rg '{\s*"[^"]+"\s*,' -n
   
   # String keys in tables (might be menu options)
   rg '\["[^"]+"\]\s*=' -n
   ```

2. **Analyze Usage Pattern**:
   - Used in comparisons? (might need to stay as strings)
   - Displayed to user? (should be localized)
   - Used as keys? (probably keep as strings)

### Wave 4: Complex String Builders

1. **Identify Accumulator Patterns**:
   ```bash
   # String concatenation in loops
   rg 'for.*do.*\.\.' -A 5 -B 2
   
   # Result building patterns
   rg 'result\s*=\s*result\s*\.\.' -n
   
   # String formatting patterns
   rg 'string\.format' -n
   ```

2. **Common Patterns to Look For**:
   - Status report builders
   - Menu content generators  
   - Multi-line message builders
   - Error message accumulators

### Wave 5: Cross-Function Dependencies

1. **Map String Flow**:
   ```bash
   # Find functions that pass strings as parameters
   rg 'function.*\(.*,\s*"[^"]+"\s*[,)]' -n
   
   # Find string method calls
   rg '"[^"]+":.*\(' -n
   ```

2. **Identify Refactoring Opportunities**:
   - Functions that could be merged
   - String builders that could use MessageBuilder
   - Duplicate string generation logic

### Tracking Progress and Dependencies

Create a `LOCALIZATION_PROGRESS.md` file:

```markdown
# Localization Progress Tracker

## Blocked Functions

### control.lua:1234 - get_status_string()
- **Blocked by**: Used with .. concatenation in report_status() 
- **Solution**: Convert report_status() to use MessageBuilder first
- **Callers**: report_status(), display_full_status()

### scanner.lua:567 - format_result()  
- **Blocked by**: Returns string used as table key
- **Solution**: May need architectural change or dual return

## Patterns Identified

### Menu Builders
- control.lua:2345 - build_menu_options()
- inventory.lua:123 - create_item_menu()
- **Pattern**: table.insert with strings, then table.concat

### Status Reporters
- power.lua:234 - get_power_status()
- production.lua:567 - format_production_stats()
- **Pattern**: Accumulate parts, join with spaces

## Completed Waves

### Wave 1 Complete
- 45 direct printout calls localized
- All in scanner, inventory, and travel modules

### Wave 2 In Progress  
- 12 string-returning functions identified
- 3 converted, 9 blocked (see above)
```

### Strategic Insights

1. **Start with isolated modules** - Scanner, specific UI components
2. **Avoid core systems initially** - control.lua event handlers are complex
3. **Look for duplication** - Similar strings might appear in multiple places
4. **Consider partial localization** - Some functions can be partially converted
5. **Document architectural issues** - Some patterns may need redesign

### Phase 2: Conversion Strategy

#### For Simple Printouts (Leaf Nodes)
```lua
-- BEFORE
Speech.speak(pindex, "Blank")

-- AFTER
Speech.speak(pindex, {"fa.blank"})
```

#### For Concatenated Messages
```lua
-- BEFORE
Speech.speak(pindex, "Building " .. entity.name .. " at " .. x .. "," .. y)

-- AFTER (using MessageBuilder - PREFERRED)
local msg = MessageBuilder.new()
msg:fragment({"fa.building"})
msg:fragment({"entity-name." .. entity.name})
msg:fragment({"fa.at-coordinates", x, y})
Speech.speak(pindex, msg:build())
```

#### For Entity/Item Names
Use the modern functions in `localising.lua`:
```lua
-- For getting localized entity/item names with fallback
local entity_desc = Localising.get_localised_name_with_fallback(entity)

-- For item stacks with quality and count
local item_desc = Localising.localise_item(stack)
Speech.speak(pindex, item_desc)

-- For custom item descriptions
local item_desc = Localising.localise_item({
    name = "transport-belt",  -- or item prototype
    quality = "legendary",    -- optional
    count = 50               -- optional
})

-- NOTE: Localising.get() is legacy and buggy - avoid it!
```

#### For Functions Returning Strings
Document these for manual review - they require careful analysis of the call chain.

### Phase 3: Implementation Steps

1. **Determine the Correct Prefix**
   - Look at the file/module location
   - Check existing keys in that module
   - Examples:
     - `scripts/scanner/` → use `scanner-` prefix
     - Entity information → use `ent-info-` prefix
     - UI components → use `ui-[component]-` prefix
     - General/control.lua → use no prefix (just under `[fa]`)

2. **Add Locale Entry to Correct File**
   ```cfg
   # All entries go under [fa] section in their respective files
   
   # For scanner module - in factorio-access.cfg
   [fa]
   scanner-blank-sector=blank sector
   scanner-refreshed=Scanner refreshed
   
   # For entity info - in entity-info.cfg
   [fa]
   ent-info-cannot-place=Cannot place here
   
   # For UI grid - in ui-grid.cfg
   [fa]
   ui-grid-navigation-help=Use WASD to navigate
   ```
   
   **Remember**: The `fa.` prefix in code maps to the `[fa]` section in .cfg files:
   - In code: `{"fa.scanner-blank-sector"}`
   - In .cfg: Under `[fa]`, just `scanner-blank-sector=blank sector`

3. **Update Code**
   - Replace string with locale key
   - Use MessageBuilder for complex concatenation
   - Use spacecat for simple space-separated lists

4. **Test**
   ```bash
   # Verify syntax
   python launch_factorio.py --run-tests --timeout 60
   
   # Check linting
   python launch_factorio.py --lint
   
   # Format code
   python launch_factorio.py --format
   ```

5. **Commit**
   ```bash
   git add -A
   git commit -m "localise: Convert [function_name] to use locale key [key_name]

   Safe to localize because:
   - Function only calls printout directly
   - No string return value used elsewhere
   - Maintains exact same user-facing text"
   ```

## Tools and Utilities

### MessageBuilder (scripts/message-builder.lua) - PREFERRED
- Use for all message concatenation
- Automatically handles 20-parameter limit
- Separates fragments with spaces, list items with commas
```lua
local msg = MessageBuilder.new()
msg:fragment({"fa.building-placed"})
msg:fragment({"entity-name.transport-belt"})
msg:list_item({"fa.facing", "north"})
msg:list_item({"fa.at-position", x, y})
Speech.speak(pindex, msg:build())
```

### Localising (scripts/localising.lua)
For entity and item names:
```lua
-- Get localized name with fallback (PREFERRED)
local name_desc = Localising.get_localised_name_with_fallback(entity)

-- Localise items with quality/count
local desc = Localising.localise_item(stack)

-- Legacy functions (REMOVED in Wave 9):
-- Localising.get() - REMOVED - was buggy and returned raw strings
-- Still available but prefer modern alternatives:
-- Localising.get_item_from_name() - legacy cache-based
-- Localising.get_fluid_from_name() - legacy cache-based  
-- Localising.get_recipe_from_name() - legacy cache-based
```

### spacecat/localise_cat_table (scripts/fa-utils.lua)
Still available but **prefer MessageBuilder** for new code

## Locale Key Naming Conventions

Based on existing patterns in `locale/en/`:

**CRITICAL RULES:**
1. **Always use hyphens (`-`), never underscores (`_`)**
2. **Always prefix with module name** (e.g., `ent-info-`, `ui-menu-`, `ui-grid-`)
3. **Keep keys lowercase**

```cfg
[fa]
# Actions (no specific prefix for general actions)
grabbed-stuff=Grabbed __1__
placed-stuff=Placed __1__

# Entity info (MUST use ent-info- prefix)
ent-info-facing=facing __1__
ent-info-marked-for-deconstruction=marked for deconstruction
ent-info-generator-load=__1__ percent load

# Entity status (MUST use ent-status- prefix)
ent-status-no-power=No power, __1__
ent-status-full-health=full health

# UI elements (MUST use ui-[component]- prefix)
ui-menu-empty=Empty menu
ui-grid-empty=Empty grid
ui-grid-cell-location=Row __1__ column __2__
ui-belt-analyzer-tab-local=This Belt
ui-blueprints-menu-title=Blueprint Configuration

# Scanner (use scanner- prefix)
scanner-refreshed=Scanner refreshed

# Directions/positions (general fa prefix)
direction=__plural_for_parameter__1__{...}__
at-coordinates=at __1__, __2__
```

### Module Prefix Examples:
- `ent-info-` - Entity information fragments
- `ent-status-` - Entity status messages  
- `ui-menu-` - General menu UI
- `ui-grid-` - Grid UI specific
- `ui-belt-analyzer-` - Belt analyzer UI
- `ui-blueprints-` - Blueprint UI
- `scanner-` - Scanner related
- `fa-` - General/core functionality

### Which Locale File to Use:
- `entity-info.cfg` - Entity information fragments (ent-info-, ent-status-)
- `ui-menu.cfg` - General menu messages
- `ui-grid.cfg` - Grid UI specific messages
- `ui-belt-analyzer.cfg` - Belt analyzer specific
- `ui-blueprints.cfg` - Blueprint UI specific
- `factorio-access.cfg` - Core functionality, general messages
- Create new .cfg files for new major features

## Priority Order for Localization

1. **High Priority**: Simple printout calls in frequently used functions
2. **Medium Priority**: Menu text and UI elements  
3. **Low Priority**: Debug messages and rarely seen text
4. **Complex Cases**: Functions with string returns - document for manual review

## Common Patterns to Look For

### In control.lua
```lua
-- Many hardcoded strings in menu handlers
Speech.speak(pindex, "Press left bracket to confirm your selection.")
Speech.speak(pindex, "Another menu is open.")

-- String building in loops
local result = ""
for i, item in pairs(items) do
    result = result .. item.name .. ", "
end
Speech.speak(pindex, result)
```

### In scanner modules
```lua
-- Entity descriptions often hardcoded
Speech.speak(pindex, "blank sector")

-- Distance/direction announcements
Speech.speak(pindex, ent.name .. " " .. dir .. " " .. dist .. " tiles")
```

### In building tools
```lua
-- Status messages frequently hardcoded  
Speech.speak(pindex, "Cannot place here")

-- Building feedback
Speech.speak(pindex, "Building " .. building_name .. " placed")
```

### Menu Building Patterns
```lua
-- Common pattern: building option lists
local options = {}
table.insert(options, "Option 1")
table.insert(options, "Option 2")
-- Later: table.concat(options, ", ")
```

### Status Reporting Patterns  
```lua
-- Accumulating status information
local status = entity.name .. " "
if entity.crafting then
    status = status .. "crafting " .. recipe .. " "
end
status = status .. "at " .. percent .. "% "
Speech.speak(pindex, status)
```

### Challenges Requiring Refactoring

1. **String as Table Keys**:
   ```lua
   local actions = {
       ["Mine"] = function() ... end,
       ["Build"] = function() ... end,
   }
   -- Keys need to stay as strings for lookup
   ```

2. **String Comparisons**:
   ```lua
   if menu_option == "Close menu" then
       -- Needs careful handling to maintain compatibility
   end
   ```

3. **Multi-level String Building**:
   ```lua
   function get_part()
       return "part of message"
   end
   
   function build_message()
       return "Full message: " .. get_part()
   end
   ```

## Testing Localized Strings

To verify your LocalisedString works correctly, create a temporary test:

```lua
-- In scripts/tests/test-localisation.lua (create if needed)
describe("Localization test", function()
    it("should verify new locale keys", function(ctx)
        ctx:at_tick(1, function()
            -- Test your new LocalisedString
            localised_print({"fa.your-new-key", "param1", "param2"})
            -- This prints to stdout showing the resolved string
            
            -- Or test with MessageBuilder
            local msg = MessageBuilder.new()
            msg:fragment({"fa.new-fragment-key"})
            msg:fragment({"fa.another-key", "value"})
            localised_print(msg:build())
        end)
    end)
end)

-- Remember to add to test_files in control.lua!
```

Then run:
```bash
python launch_factorio.py --run-tests --timeout 60
```

## Handling Edge Cases

### Dynamic Entity Names
```lua
-- Use entity locale keys when available
{"entity-name." .. entity.name}

-- Fallback for unknown entities
{"?", {"entity-name." .. entity.name}, entity.name}
```

### Number Formatting
```lua
-- Numbers are automatically converted
{"fa.item-count", 42}  -- Works fine
```

### Conditional Messages
```lua
-- Use MessageBuilder for conditional parts
local msg = MessageBuilder.new()
msg:fragment({"fa.base-message"})
if condition then
    msg:fragment({"fa.additional-info"})
end
Speech.speak(pindex, msg:build())
```

### Entity/Item Names
```lua
-- DON'T hardcode entity names
Speech.speak(pindex, "You found " .. entity.name)  -- BAD

-- DON'T try to make your own locale key
Speech.speak(pindex, {"fa.found", entity.name})  -- BAD - shows raw prototype name

-- DO use modern Localising functions
local entity_desc = Localising.get_localised_name_with_fallback(entity)
local msg = MessageBuilder.new()
msg:fragment({"fa.found"})
msg:fragment(entity_desc)  -- LocalisedString with fallback
Speech.speak(pindex, msg:build())

-- OR for built-in entity locale keys (if you know they exist)
msg:fragment({"entity-name." .. entity.name})  -- Game's built-in keys

-- For items with details
local item_desc = Localising.localise_item(stack)  -- Includes quality/count
Speech.speak(pindex, item_desc)
```

## What NOT to Localize (Yet)

1. **Complex string-building functions** - Require refactoring
2. **Debug/development messages** - Low priority
3. **Syntrax error messages** - Separate system
4. **Test framework output** - Development only

## Commit Message Template

```
localise: [description of what was localized]

Converted [function/feature] to use locale keys:
- [list of keys added]

Safe to localize because:
- [reason why this won't break anything]
- [verification steps taken]

Part of systematic localization effort.
```

## Useful Commands for Analysis

```bash
# Find all printout calls with hardcoded strings
rg 'printout\("' -n

# Find all game.print calls (avoid these - GUI only)
rg 'game\.print\(' -n  

# Find string concatenation near printouts
rg 'printout.*\.\.' -n

# Find functions that might return strings
rg 'return\s+"[^"]+"\s*$' -n

# Check usage of a specific function
rg "function_name\(" --type lua
```

## Real Example from the Codebase

Here's a concrete example of proper localization from the scanner module:

**BEFORE** (hardcoded string):
```lua
-- In scripts/scanner/entrypoint.lua
if #results == 0 then
    Speech.speak(pindex, "blank sector")
    return
end
```

**AFTER** (properly localized):
```lua
-- In scripts/scanner/entrypoint.lua  
if #results == 0 then
    Speech.speak(pindex, {"fa.scanner-blank-sector"})
    return
end

-- In locale/en/factorio-access.cfg
[fa]
scanner-blank-sector=blank sector
```

**Why this is safe to localize:**
- Direct printout call with no return value
- String is not concatenated elsewhere
- Simple replacement maintains exact behavior

## Key Learnings from Completed Waves

### Critical Patterns Discovered

1. **LocalisedString Concatenation**
   ```lua
   -- WRONG: Using .. operator
   local msg = {"fa.prefix"} .. " and " .. {"fa.suffix"}
   
   -- RIGHT: Using {""} concatenation
   local msg = {"", {"fa.prefix"}, " and ", {"fa.suffix"}}
   ```

2. **Function Return Values**
   ```lua
   -- Functions that return strings for concatenation MUST return LocalisedString
   function get_description()
       return {"fa.description"}  -- Not "description string"
   end
   ```

3. **Menu Search Exception**
   ```lua
   -- menu-search.lua requires actual strings, not LocalisedStrings
   -- This is a special case that should NOT be converted
   ```

4. **List Building Pattern**
   ```lua
   -- DON'T create custom list builders with "and"
   -- DO use MessageBuilder for all list construction
   local msg = MessageBuilder.new()
   msg:list_item({"fa.item1"})
   msg:list_item({"fa.item2"})
   msg:list_item({"fa.item3"})
   -- MessageBuilder handles separators correctly
   ```

## Practical Workflow for Iterative Localization

### Step 1: Initial Analysis (Per Module)
```bash
# Pick a module (e.g., scripts/scanner/)
cd scripts/scanner

# Count total strings needing localization
rg '"[^"]+"' -c

# Find direct printouts (Wave 1 candidates)
rg 'printout\("' -n > wave1_candidates.txt

# Find string returns (Wave 2 candidates)  
rg 'return\s+"' -n > wave2_candidates.txt

# Find string concatenations (Complex cases)
rg '\.\.\s*"' -n > concatenations.txt
```

### Step 2: Dependency Mapping
For each Wave 2+ candidate, trace its usage:
```bash
# Example: function returns "Status: OK"
rg "function_name\(" -A 2 -B 2

# See if callers use concatenation
rg "function_name\(.*\).*\.\." 
```

### Step 3: Batch Processing
```lua
-- Process 5-10 related functions per batch
-- Group by:
-- 1. Same file
-- 2. Same feature (e.g., all scanner messages)
-- 3. Same pattern (e.g., all menu builders)
```

### Step 4: Progressive Unlocking
After each batch:
1. Review blocked functions list
2. Check if any are now unblocked
3. Move unblocked functions to next batch

### Example Iteration

**Batch 1**: Simple scanner messages
```lua
-- BEFORE
Speech.speak(pindex, "blank sector")
Speech.speak(pindex, "No entities found")

-- AFTER  
Speech.speak(pindex, {"fa.scanner-blank-sector"})
Speech.speak(pindex, {"fa.scanner-no-entities"})
```

**Batch 2**: Scanner with entity names (now safe)
```lua
-- BEFORE
Speech.speak(pindex, "Found " .. ent.name)

-- AFTER
local msg = MessageBuilder.new()
msg:fragment({"fa.scanner-found"})
msg:fragment(Localising.get_localised_name_with_fallback(ent))
Speech.speak(pindex, msg:build())
```

**Batch 3**: Scanner result formatting (unblocked by Batch 2)
```lua
-- BEFORE
function format_scanner_result(ent, dist, dir)
    return ent.name .. " " .. dir .. " " .. dist .. " tiles"
end

-- AFTER
function format_scanner_result(ent, dist, dir)
    local msg = MessageBuilder.new()
    msg:fragment(Localising.get_localised_name_with_fallback(ent))
    msg:fragment({"fa.scanner-direction-distance", dir, dist})
    return msg:build()
end
```

## Final Notes

- **Preserve behavior**: Keep the exact same text when creating locale entries
- **Test incrementally**: Run tests after each batch of changes
- **Commit frequently**: One logical change per commit for easy bisection
- **Document blockers**: Keep a list of complex cases that need refactoring
- **Use existing examples**: `fa-info.lua` demonstrates best practices
- **Follow the prefix convention**: Always use module-specific prefixes with hyphens
- **Think in waves**: Each localization enables more localizations

This is a large task that benefits from systematic, incremental progress. The key insight is that localization is not a one-pass process - it's an iterative transformation where each wave of changes unlocks new possibilities. Start with the easy wins, document the blockers, and progressively work through more complex cases as the codebase becomes more localization-ready.