# Debugging Manual Factorio Runs - LLM Guide

This guide helps LLMs assist users in debugging FactorioAccess crashes and issues that occur during manual gameplay.

## Overview

When a user experiences a crash or issue while playing Factorio manually (not through the launcher), you need to:
1. Capture logs before they're overwritten
2. Analyze the crash information
3. Apply fixes if the issue is small
4. Get user approval for larger fixes

## Quick Start Commands

### Capture logs immediately after a crash:
```bash
python3 launch_factorio.py --capture-logs
```

This will:
- Find and save factorio-current.log
- Find and save factorio-access.log 
- Find and save factorio-access-printout.log (if available)
- Create a timestamped crash report JSON file
- Display the last lines of each log for immediate analysis

### Capture more lines from logs:
```bash
python3 launch_factorio.py --capture-logs --last-lines 200
```

## Workflow

### 1. Initial Response
When a user reports a crash, immediately:
```bash
# Capture the logs before the user restarts Factorio
python3 launch_factorio.py --capture-logs
```

Tell the user: "I'm waiting for you to report a bug. When you're ready, let me know what happened."

### 2. Analyze the Logs
Look for:
- **Stack tracebacks** in factorio-current.log
- **Error messages** with file names and line numbers
- **Last actions** in factorio-access-printout.log
- **Mod errors** in factorio-access.log

### 3. If You Need More Information

#### Add logging to specific areas:
```lua
-- In the suspected problem area
local logger = Logging.Logger("ModuleName")
logger:error("Variable state: " .. serpent.line(suspicious_variable))
```

#### Add debug printouts:
```lua
-- These will appear in factorio-access-printout.log
printout("DEBUG: Entering problematic function with value: " .. tostring(value), pindex)
```

Then ask the user to reproduce the crash.

### 4. Fix Size Assessment
- **Small fixes (<50 lines)**: Apply immediately
- **Large fixes (>50 lines)**: Ask user for permission first

### 5. Apply the Fix
```bash
# Always format after making changes
python3 launch_factorio.py --format

# Run tests if available (automated, no GUI)
python3 launch_factorio.py --run-tests --timeout 60

# IMPORTANT: Never load saves directly without --run-tests
# This would open a GUI window instead of running automated tests
```

### 6. Verify the Fix
Ask the user to test the fix and report back.

## Log File Locations

The launcher dynamically searches these locations:

### factorio-current.log:
- `{factorio_exe_dir}/factorio-current.log`
- `{factorio_exe_dir}/../factorio-current.log`
- `%APPDATA%/Factorio/factorio-current.log` (Windows)

### Mod logs (script-output directory):
- `{factorio_exe_dir}/../../script-output/`
- `{factorio_exe_dir}/../script-output/`
- `%APPDATA%/Factorio/script-output/` (Windows)

## Common Crash Patterns

### 1. Nil Reference Errors
```
attempt to index local 'entity' (a nil value)
```
**Fix**: Add validity checks
```lua
if entity and entity.valid then
    -- Use entity
end
```

### 2. API Changes (2.0 Migration)
```
attempt to call field 'recipe_prototypes' (a nil value)
```
**Fix**: Update to new API
```lua
-- Old: game.recipe_prototypes
-- New: prototypes.recipe
```

### 3. Event Handler Errors
Look for errors in on_tick, on_built_entity, etc.
Check the stack trace for the specific handler.

## Tips for LLMs

1. **Act quickly** - Logs are overwritten when Factorio restarts
2. **Use grep/rg** for efficient file navigation
3. **Check CLAUDE.md** for known issues and patterns
4. **Focus on the error line** and work backwards through the stack trace
5. **Test fixes** with the launcher before asking the user to test

## Integration with Other Tools

- **GitHub integration**: Can create issues or PRs for larger fixes, ONLY WITH USER PERMISSION.
- **Logging framework**: Already integrated, use `Logging.Logger("ModuleName")`.  Requires importing.

## Example Session

```
User: Factorio just crashed when I tried to place a rail

LLM: I'll capture the crash logs immediately to see what happened.
*runs: python3 launch_factorio.py --capture-logs*

[Analyzes logs, finds nil reference in rail-builder.lua:142]

LLM: I found the issue. The rail placement code isn't checking if the surface position is valid. This is a small fix (about 5 lines). I'll apply it now.

[Makes the fix, formats, and tests]

LLM: I've fixed the issue. The rail placement now checks for valid positions before trying to place. Please try placing rails again and let me know if it works.
```