# LLM Prompt Template for Debugging FactorioAccess

Use this template when working with LLMs other than Claude to debug FactorioAccess crashes from manual gameplay.

## System Prompt / Initial Instructions

```
You are helping debug crashes in FactorioAccess, a Factorio mod that makes the game accessible to blind players through audio cues and keyboard controls.

IMPORTANT CONTEXT:
- You are in a WSL environment with access to a Windows Factorio installation
- The user is playing Factorio manually (not through any launcher)
- When crashes occur, logs are overwritten on the next game start, so you must act quickly
- The codebase is large - avoid reading entire files, use search/grep instead

KEY TOOLS YOU NEED:
- git and gh (GitHub CLI) for version control
- Python 3 for running the launcher script
- grep/rg for searching the codebase

WORKING DIRECTORY: The FactorioAccess mod directory

CRITICAL FILES TO KNOW:
- control.lua - Main runtime entry point, use grep or partial reads
- launch_factorio.py - Development launcher with debugging tools
- scripts/ - Feature implementations
- CLAUDE.md - Development guide with patterns and pitfalls
```

## Initial Onboarding Check

When starting a session, run these checks:

```bash
# Check for required tools
which git
which gh
which python3
which rg || which grep

# Get current branch
git status

# Understand the crash capture tool
python3 launch_factorio.py --help | grep -A5 "capture-logs"
```

## Debugging Workflow Instructions

```
When the user reports a crash:

1. IMMEDIATELY capture logs (they're lost on restart!):
   python3 launch_factorio.py --capture-logs

2. Analyze the captured logs:
   - Look for stack tracebacks in factorio-current.log
   - Check last actions in factorio-access-printout.log
   - Review errors in factorio-access.log

3. Find the error location:
   - Use grep/rg to search for the function/line
   - DO NOT read entire files, especially control.lua
   - Use grep/rg for efficient navigation

4. Assess fix size:
   - Small (<50 lines): Apply immediately
   - Large (>50 lines): Ask user permission first

5. Apply and test fixes:
   python3 launch_factorio.py --format     # Format code
   python3 launch_factorio.py --lint       # Check for errors
   python3 launch_factorio.py --run-tests  # Run tests if available

6. Ask user to test the fix
```

## Common Patterns to Know

```lua
-- Nil checks (very common fix):
if entity and entity.valid then
    -- use entity
end

-- Event handler pattern:
EventManager.on_event(defines.events.on_built_entity, function(event)
    -- handler code
end)

-- Printout for debugging:
printout("DEBUG: " .. serpent.line(variable), pindex)

-- Logging for persistent debugging:
local logger = Logging.Logger("ModuleName")
logger:error("Something went wrong: " .. message)
```

## Example Interaction

```
User: "Factorio crashed when I pressed K on a belt"

LLM: I'll immediately capture the crash logs to analyze what happened.

[Run: python3 launch_factorio.py --capture-logs]

I can see from the logs that there's a nil reference error in transport-belts.lua 
when trying to access belt contents. Looking at line 234...

[Run: rg -A10 -B10 "function.*analyze_belt" scripts/transport-belts.lua]

I found the issue - the code isn't checking if the belt has contents before 
accessing them. This is a small fix (3 lines). Let me apply it:

[Make the fix with proper nil checks]
[Run: python3 launch_factorio.py --format]

The fix is applied. Please try pressing K on a belt again and let me know if it works.
```

## Key Warnings for LLMs

1. **NEVER read all of control.lua** - It will exhaust your context window
2. **Time is critical** - Capture logs immediately when user reports a crash  
3. **Test all changes** - Format and lint before asking user to test
4. **Check CLAUDE.md** - Contains important patterns and anti-patterns
5. **Prefer grep/search** over reading entire files

## Additional Resources

- See `llm-docs/debugging-manual-runs.md` for detailed debugging guide
- See `CLAUDE.md` for codebase patterns and common mistakes
- See `DEVELOPMENT-WORKFLOW.md` for git and testing practices