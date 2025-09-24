# Event Handler Migration Script

This script migrates event handlers in `control.lua` from the old `check_for_player` pattern to the new `EventManager.create_player_handler` wrapper pattern.

## Why This Migration?

The old pattern:
```lua
EventManager.on_event("fa-w", function(event)
   local pindex = event.player_index
   if not check_for_player(pindex) then return end
   -- handler code
end)
```

The new pattern:
```lua
EventManager.on_event("fa-w", EventManager.create_player_handler(function(event, pindex)
   -- handler code
end))
```

Benefits:
- Cleaner code with less boilerplate
- Automatic player validation
- Consistent player initialization handling
- Better error handling

## Usage

```bash
# Show help
python3 migrate_event_handlers.py --help

# Dry run - preview changes without modifying files
python3 migrate_event_handlers.py --dry-run

# Dry run with verbose output showing examples
python3 migrate_event_handlers.py --dry-run --verbose

# Apply migrations (will prompt for confirmation)
python3 migrate_event_handlers.py
```

## What It Does

1. **Finds** all `EventManager.on_event` handlers in `control.lua`
2. **Identifies** which ones use the `check_for_player` pattern
3. **Categorizes** them by complexity:
   - **Simple**: Just `if not check_for_player(pindex) then return end`
   - **Router**: Includes `Router.navigate_back` after the check
   - **UI Check**: Combined with `router:is_ui_open` checks
   - **No Return**: Calls `check_for_player` without return (cutscene events)
   - **Complex**: Other patterns needing manual review

4. **Transforms** simple patterns automatically
5. **Preserves** router and UI checks appropriately
6. **Creates** a backup before making changes
7. **Generates** preview and manual review files

## Output Files

- `migration_preview.lua` - Shows all proposed changes
- `manual_review_needed.lua` - Cases requiring human attention
- `control.lua.backup.<timestamp>` - Backup of original file

## Pattern Recognition

The script recognizes and handles these patterns:

### Simple Pattern
```lua
-- Before
local pindex = event.player_index
if not check_for_player(pindex) then return end

-- After
EventManager.create_player_handler(function(event, pindex)
```

### Router Pattern
```lua
-- Before
local pindex = event.player_index
if not check_for_player(pindex) then return end
Router.navigate_back(pindex)

-- After (preserves router navigation)
EventManager.create_player_handler(function(event, pindex)
   local router = UiRouter.get_router(pindex)
   Router.navigate_back(pindex)
```

### UI Check Pattern
```lua
-- Before
if not check_for_player(pindex) or router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end

-- After
EventManager.create_player_handler(function(event, pindex)
   local router = UiRouter.get_router(pindex)
   if router:is_ui_open(UiRouter.UI_NAMES.PROMPT) then return end
```

## Manual Review Cases

Some patterns require manual review:

1. **No Return Pattern**: Events that call `check_for_player` without checking the return value (typically cutscene events)
2. **Complex Patterns**: Unusual check combinations or control flow

## Safety Features

- Always creates a timestamped backup
- Dry run mode for previewing changes
- Prompts for confirmation before applying
- Generates preview files for review
- Preserves all functionality (router checks, UI checks, etc.)
- Handles events that already use `create_player_handler`

## Limitations

- Only processes `EventManager.on_event` handlers (not direct `script.on_event`)
- Requires manual review for complex patterns
- Assumes standard code formatting

## After Migration

1. Review the changes with `git diff`
2. Run the formatter: `python launch_factorio.py --format`
3. Run tests: `python launch_factorio.py --run-tests`
4. Test the game manually
5. Address any manual review cases in `manual_review_needed.lua`