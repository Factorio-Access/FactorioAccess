# Development Workflow Guide for FactorioAccess

This guide provides step-by-step workflows for common development tasks on the FactorioAccess mod. Follow these patterns to maintain consistency and avoid common pitfalls.

## 1. Starting a New Feature

### Step 1: Understand the Issue
```bash
# Read the issue description carefully
# If working from GitHub issue, fetch details:
gh issue view <issue-number>

# Search for related issues or context
gh issue list --search "keyword"
```

### Step 2: Explore the Codebase
```bash
# Use grep/rg to understand code structure

# Find relevant files using pattern matching
python3 launch_factorio.py --lint  # Get familiar with the codebase structure

# Search for related functionality
rg "feature_name" --type lua
rg "defines.events.on_built_entity" scripts/  # Find event handlers

# IMPORTANT: Avoid reading control.lua entirely - use targeted searches
rg "function.*building" control.lua | head -20  # Targeted search
```

### Step 3: Create TODO List
Use the TodoWrite tool to organize your work:
```
1. Analyze existing implementation
2. Design new feature architecture
3. Implement core functionality
4. Add event handlers
5. Create locale strings
6. Write tests
7. Manual testing with screen reader
8. Format and lint code
```

### Step 4: Implementation Pattern
```lua
-- 1. Create new module in scripts/
-- scripts/my-feature.lua
local mod = {}
local storage_manager = require("scripts.storage-manager")

-- 2. Declare storage if needed
local my_storage = storage_manager.declare_storage_module('my_feature', {
    enabled = true,
    data = {}
})

-- 3. Implement functionality
function mod.do_something(pindex)
    local player = game.get_player(pindex)
    if not (player and player.valid) then return end
    
    -- Implementation
    printout("Feature activated", pindex)
end

-- 4. Register events through EventManager
local EventManager = require("scripts.event-manager")
EventManager.on_event(defines.events.on_tick, function(event)
    if event.tick % 60 == 0 then  -- Every second
        -- Periodic checks
    end
end)

return mod
```

### Step 5: Add to control.lua
```lua
-- Add require at appropriate location
require("scripts.my-feature")
```

## 2. Making Changes to Existing Features

### Step 1: Locate the Feature
```bash
# Use grep to find feature structure
grep -r "feature_name" scripts/

# Find which module handles specific events
rg "on_player_cursor_stack_changed" scripts/ -A 5 -B 5

# Trace function calls
rg "function_name\(" --type lua
```

### Step 2: Understand Dependencies
```bash
# Find what requires this module
rg "require.*module-name" --type lua

# Find what this module calls
rg "require" scripts/module-name.lua

# Use grep for dependency analysis
grep "require" scripts/module.lua
```

### Step 3: Make Changes Safely
```lua
-- Before changing, understand the pattern:
-- 1. Check if feature uses storage_manager
-- 2. Check if it's registered with EventManager
-- 3. Look for related tests

-- Make minimal changes
-- Preserve existing behavior unless explicitly changing it
-- Add comments for non-obvious changes
```

### Step 4: Test Impact
```bash
# Run tests immediately after changes
python3 launch_factorio.py --run-tests --timeout 60

# Run specific test if available
python3 launch_factorio.py --run-tests --filter "feature_name"

# Manual testing with a save file
python3 launch_factorio.py --load-game test-save.zip --timeout 300
```

## 3. Debugging Issues

### Step 1: Choose the Right Output Method
```lua
-- For debugging during development (appears in Factorio log)
print("Debug: value = " .. serpent.line(value))

-- For user-facing messages (goes to screen reader)
printout("Building placed successfully", pindex)

-- NEVER use game.print() - it only shows in GUI, not accessible
-- game.print("This won't help!")  -- DON'T DO THIS
```

### Step 2: Check Logs
```bash
# Windows log location
# %APPDATA%/Factorio/factorio-current.log

# In WSL, access Windows logs
tail -f /mnt/c/Users/USERNAME/AppData/Roaming/Factorio/factorio-current.log

# Filter for your debug output
grep "Debug:" /mnt/c/Users/USERNAME/AppData/Roaming/Factorio/factorio-current.log
```

### Step 3: Common Error Patterns
```lua
-- 1. Nil reference errors
-- Always check validity
if entity and entity.valid then
    -- Safe to use entity
end

-- 2. Wrong stage errors
-- "attempt to index global 'game' (a nil value)"
-- This means you're accessing runtime objects from data stage

-- 3. Event handler errors
-- Wrap in safe handlers
EventManager.on_event(defines.events.on_built_entity, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end  -- Safety check
    
    -- Your code here
end)
```

### Step 4: Isolate Issues
```lua
-- Create minimal test case
describe("Bug reproduction", function()
    it("should demonstrate the issue", function(ctx)
        local player
        
        ctx:init(function()
            player = game.get_player(1)
            -- Set up minimal scenario
        end)
        
        ctx:at_tick(5, function()
            -- Trigger the problematic behavior
            -- Use ctx:assert to verify
        end)
    end)
end)
```

## 4. Testing Workflow

### Step 1: Write Tests When Appropriate
```lua
-- scripts/tests/my-feature-test.lua
describe("My Feature", function()
    it("should handle basic case", function(ctx)
        local player, result
        
        ctx:init(function()
            player = game.get_player(1)
            -- Setup test scenario
        end)
        
        ctx:at_tick(5, function()
            -- Execute feature
            result = my_module.do_something(player.index)
        end)
        
        ctx:in_ticks(1, function()
            -- Verify results
            ctx:assert_equals("expected", result)
        end)
    end)
end)
```

### Step 2: Run Tests
```bash
# Run all tests
python3 launch_factorio.py --run-tests --timeout 60

# Run with more time for complex tests
python3 launch_factorio.py --run-tests --timeout 300

# Check test output carefully
# Look for: "All tests passed!" or specific failures
```

### Step 3: Debug Test Failures
```lua
-- Add debug output in tests
ctx:at_tick(10, function()
    print("Debug: Current state = " .. serpent.line(storage.players[1]))
    ctx:assert_equals(expected, actual, "Custom failure message")
end)
```

### Step 4: Integration Testing
```bash
# Create a test save with specific scenario
python3 launch_factorio.py --load-game test-scenario.zip --timeout 600

# Test with screen reader integration
# 1. Start Factorio with the mod
# 2. Use screen reader to navigate
# 3. Verify audio output is correct
# 4. Test edge cases
```

## 5. Pre-Commit Checklist

### Step 1: Format Code
```bash
# Format all Lua files
python3 launch_factorio.py --format

# Check formatting without changing
python3 launch_factorio.py --format-check
```

### Step 2: Run Linter
```bash
# Run LuaLS linter
python3 launch_factorio.py --lint

# Fix any warnings about:
# - Missing type annotations
# - Undefined globals
# - Unused variables
```

### Step 3: Run Tests
```bash
# Full test suite
python3 launch_factorio.py --run-tests --timeout 120

# Verify output shows all tests passing
```

### Step 4: Check for Common Mistakes
- [ ] No hardcoded strings (use locale system)
- [ ] No global variables (`_G.x = y` is forbidden)
- [ ] All entities checked for validity
- [ ] No `game.print()` calls
- [ ] Storage accessed through storage_manager
- [ ] Events registered through EventManager (for new code)
- [ ] LuaLS annotations added for new functions
- [ ] No test-only code in production files

### Step 5: Review Changes
```bash
# Review your changes
git diff

# Check you haven't accidentally modified unrelated files
git status

# Stage changes carefully
git add -p  # Interactive staging
```

## 6. PR Workflow

### Step 1: Create Feature Branch
```bash
# Branch from main or f2.0-dev as appropriate
git checkout -b feature/descriptive-name

# For bug fixes
git checkout -b fix/issue-description

# For refactoring
git checkout -b refactor/what-is-being-refactored
```

### Step 2: Commit Strategy
```bash
# Make logical, atomic commits
git add scripts/my-feature.lua
git commit -m "feat: Add initial my-feature module structure"

git add locale/en/my-feature.cfg
git commit -m "feat: Add locale strings for my-feature"

git add scripts/tests/my-feature-test.lua
git commit -m "test: Add tests for my-feature functionality"

# Fix any issues found during testing
git add scripts/my-feature.lua
git commit -m "fix: Handle edge case in my-feature"
```

### Step 3: Final Checks
```bash
# Ensure all tests pass
python3 launch_factorio.py --run-tests --timeout 120

# Format check
python3 launch_factorio.py --format-check

# Lint check
python3 launch_factorio.py --lint

# Update from main/f2.0-dev
git fetch origin
git rebase origin/f2.0-dev  # or main
```

### Step 4: Create PR
```bash
# Push branch
git push -u origin feature/descriptive-name

# Create PR with comprehensive description
gh pr create --title "feat: Add my awesome feature" --body "$(cat <<'EOF'
## Summary
- Added new feature for doing X
- Improves accessibility by Y
- Fixes issue #123

## Changes
- New module: `scripts/my-feature.lua`
- Added event handlers for feature activation
- Created comprehensive test suite
- Added locale strings for all user-facing text

## Testing
- [x] All automated tests pass
- [x] Manual testing with screen reader
- [x] Tested edge cases (list them)
- [x] No regressions in existing features

## Notes
- This feature requires Factorio 2.0
- Performance impact is minimal (checked with profiler)

Closes #123
EOF
)"
```

### Step 5: PR Description Template
```markdown
## Summary
Brief description of what this PR does

## Motivation
Why this change is needed (link to issue)

## Changes
- Bullet points of specific changes
- File modifications
- New features added
- Bugs fixed

## Testing
- [ ] Automated tests pass
- [ ] Manual testing completed
- [ ] Screen reader testing done
- [ ] Edge cases handled

## Breaking Changes
List any breaking changes or "None"

## Screenshots/Examples
If applicable, code examples or behavior descriptions

## Notes
Additional context, performance considerations, etc.
```

## Common Commands Reference

```bash
# Development
python3 launch_factorio.py --run-tests --timeout 60
python3 launch_factorio.py --format
python3 launch_factorio.py --lint
python3 launch_factorio.py --load-game save.zip --timeout 300

# Searching
rg "pattern" --type lua
rg "defines.events.on_built" scripts/ -A 5 -B 5

# Git operations
git add -p  # Interactive staging
git commit -m "type: description"
git rebase -i HEAD~3  # Clean up commits

# GitHub CLI
gh issue view 123
gh pr create --title "Title" --body "Description"
gh pr list --author @me
```

## Tips for Success

1. **Always use grep/rg** for searching - it's much more efficient than reading entire files
2. **Never read control.lua entirely** - use targeted searches with grep/rg
3. **Test early and often** - catch issues before they compound
4. **Use the TODO system** - it helps track complex multi-step tasks
5. **Ask when unsure** - The docs might be wrong; confirm with maintainers
6. **Think accessibility first** - Every feature must work with audio-only feedback
7. **Performance matters** - Code runs 60 times per second in on_tick handlers

Remember: This mod makes Factorio accessible to blind players. Every decision should prioritize audio-first interaction and keyboard accessibility.