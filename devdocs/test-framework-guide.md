# FactorioAccess Test Framework Guide

This guide covers the FactorioAccess test framework, which provides tick-based testing capabilities for mod features.

## Quick Start

### Minimal Test Example

```lua
-- scripts/tests/my-test.lua
local TestRegistry = require("scripts.test-registry")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("My Feature Tests", function()
   it("should do something simple", function(ctx)
      ctx:init(function()
         -- Test initialization runs at tick 0
         local player = game.get_player(1)
         ctx:assert_not_nil(player, "Player should exist")
      end)
   end)
end)
```

### How to Run Tests

Use the launcher script with the `--run-tests` flag:

```bash
python launch_factorio.py --run-tests --timeout 30
```

This will:
1. Load the `lab_tiles.zip` save file
2. Run all registered tests
3. Output results after completion

### How to Add a New Test File

1. Create a new file in `scripts/tests/` with a descriptive name ending in `-test.lua`
2. Add your test file to the `test_files` table in `scripts/test-framework.lua`:

```lua
local test_files = {
   -- ... existing tests ...
   "my-new-test", -- Add your test file name (without .lua extension)
}
```

3. Write your tests using `describe` and `it` blocks
4. Run the tests to verify they work

## Test Structure

### describe/it Blocks

Tests are organized into suites using `describe` blocks, with individual tests in `it` blocks:

```lua
describe("Feature Name", function()
   -- Setup hooks (optional)
   before_all(function()
      -- Runs once before all tests in this suite
   end)
   
   before_each(function()
      -- Runs before each test
   end)
   
   after_each(function()
      -- Runs after each test
   end)
   
   after_all(function()
      -- Runs once after all tests
   end)
   
   -- Individual tests
   it("should do something specific", function(ctx)
      -- Test implementation
   end)
   
   it("should handle another case", function(ctx)
      -- Another test
   end)
end)
```

### Test Lifecycle

Each test follows this lifecycle:

1. **init** - Runs at tick 0 for setup
2. **at_tick** - Runs at specific tick numbers
3. **in_ticks** - Runs after a delta from the previous action

```lua
it("should test over multiple ticks", function(ctx)
   -- Local variables persist across tick handlers
   local my_entity
   local counter = 0
   
   ctx:init(function()
      -- Runs at tick 0
      local player = game.get_player(1)
      my_entity = player.surface.create_entity{
         name = "assembling-machine-1",
         position = {0, 0},
         force = player.force
      }
   end)
   
   ctx:at_tick(10, function()
      -- Runs at tick 10
      counter = counter + 1
      ctx:assert_equals(1, counter)
   end)
   
   ctx:in_ticks(5, function()
      -- Runs 5 ticks after previous action (tick 15)
      counter = counter + 1
      ctx:assert_equals(2, counter)
   end)
end)
```

### State Management Between Ticks

Use local variables in the test function to maintain state across tick handlers:

```lua
it("should maintain state across ticks", function(ctx)
   -- Local variables accessible to all closures
   local test_value
   local player
   
   ctx:init(function()
      test_value = 42
      player = game.get_player(1)
   end)
   
   ctx:at_tick(1, function()
      -- Can access and modify local variables
      ctx:assert_equals(42, test_value)
      test_value = 100
   end)
   
   ctx:at_tick(2, function()
      -- Changes persist
      ctx:assert_equals(100, test_value)
   end)
end)
```

**Important**: Do NOT use `ctx.state` - it exists but local variables are the preferred pattern.

## Assertion Reference

All assertions are available as methods on the test context (`ctx`):

### Basic Assertions

```lua
-- Assert truthy value
ctx:assert(value, "optional message")

-- Assert equality
ctx:assert_equals(expected, actual, "optional message")

-- Assert nil
ctx:assert_nil(value, "optional message")

-- Assert not nil
ctx:assert_not_nil(value, "optional message")

-- Assert inequality
ctx:assert_not_equals(expected, actual, "optional message")
```

### Table Assertions

```lua
-- Deep table comparison
ctx:assert_table_equals(
   {a = 1, b = {c = 2}},
   {a = 1, b = {c = 2}},
   "Tables should match"
)
```

### Error Assertions

```lua
-- Assert that a function throws an error
ctx:assert_error(function()
   error("This should fail")
end, "Function should throw error")
```

### Common Assertion Patterns

```lua
-- Entity validation
ctx:assert_not_nil(entity)
ctx:assert(entity.valid, "Entity should be valid")

-- Position checking
ctx:assert_equals(expected_pos.x, entity.position.x)
ctx:assert_equals(expected_pos.y, entity.position.y)

-- Force/player validation
ctx:assert_not_nil(player.force)
ctx:assert_equals("player", player.force.name)
```

## Advanced Patterns

### Multi-tick Testing

Test complex sequences of actions:

```lua
it("should handle complex interaction sequence", function(ctx)
   local player, surface
   local assembler
   
   ctx:init(function()
      player, surface = ctx:setup_test_area(1)
      
      assembler = surface.create_entity{
         name = "assembling-machine-1",
         position = {0, 0},
         force = player.force
      }
   end)
   
   ctx:at_tick(1, function()
      -- Set recipe
      assembler.set_recipe("iron-gear-wheel")
      ctx:assert_not_nil(assembler.get_recipe())
   end)
   
   ctx:in_ticks(60, function()
      -- Check after 1 second
      local recipe = assembler.get_recipe()
      ctx:assert_equals("iron-gear-wheel", recipe.name)
   end)
end)
```

### Event Mocking

Test event handlers by mocking events:

```lua
it("should respond to keyboard events", function(ctx)
   local pindex = 1
   local initial_pos
   
   ctx:init(function()
      -- Enable cursor mode
      EventManager.mock_event("fa-i", {
         name = "fa-i",
         player_index = pindex,
         tick = game.tick
      })
   end)
   
   ctx:at_tick(1, function()
      -- Mock WASD movement
      EventManager.mock_event("fa-d", {
         name = "fa-d",
         player_index = pindex,
         tick = game.tick
      })
   end)
   
   ctx:at_tick(2, function()
      -- Verify movement happened
      local vp = viewpoint.get_viewpoint(pindex)
      local pos = vp:get_cursor_pos()
      ctx:assert(pos.x > initial_pos.x, "Should have moved east")
   end)
end)
```

### Testing with Entities

Common patterns for entity testing:

```lua
it("should interact with entities", function(ctx)
   local player, surface
   local entities = {}
   
   ctx:init(function()
      -- Use helper to setup clean test area
      player, surface = ctx:setup_test_area(1)
      
      -- Create test entities
      entities.chest = surface.create_entity{
         name = "wooden-chest",
         position = {2, 0},
         force = player.force
      }
      
      entities.belt = surface.create_entity{
         name = "transport-belt",
         position = {0, 2},
         direction = defines.direction.east,
         force = player.force
      }
   end)
   
   ctx:at_tick(1, function()
      -- Test entity properties
      ctx:assert_equals(defines.direction.east, entities.belt.direction)
      ctx:assert_equals("transport-belt", entities.belt.name)
   end)
end)
```

### Player Simulation

Simulate player actions:

```lua
it("should simulate player building", function(ctx)
   local player, surface
   
   ctx:init(function()
      player, surface = ctx:setup_test_area(1)
      
      -- Give player items
      player.insert{name = "transport-belt", count = 10}
   end)
   
   ctx:at_tick(1, function()
      -- Simulate selecting belt
      player.cursor_stack.set_stack{name = "transport-belt", count = 1}
      
      -- Simulate building
      local built = player.build_from_cursor{
         position = {5, 0},
         direction = defines.direction.north
      }
      
      ctx:assert(built, "Should have built entity")
   end)
end)
```

## Common Mistakes

### 1. Testing Factorio APIs vs Mod Behavior

**Wrong**: Testing that Factorio's API works correctly
```lua
-- DON'T do this - we're testing Factorio, not our mod
it("should create entities", function(ctx)
   ctx:init(function()
      local surface = game.surfaces[1]
      local entity = surface.create_entity{
         name = "transport-belt",
         position = {0, 0}
      }
      ctx:assert_not_nil(entity) -- This just tests Factorio works
   end)
end)
```

**Right**: Testing your mod's behavior
```lua
-- DO this - test how your mod handles entities
it("should read belt direction correctly", function(ctx)
   local belt
   
   ctx:init(function()
      local surface = game.surfaces[1]
      belt = surface.create_entity{
         name = "transport-belt",
         position = {0, 0},
         direction = defines.direction.east
      }
   end)
   
   ctx:at_tick(1, function()
      -- Test YOUR mod's direction reading function
      local result = localising.get_direction_description_cardinal(belt)
      ctx:assert_equals("east", result)
   end)
end)
```

### 2. Complex Integration Tests vs Simple Unit Tests

**Avoid**: Overly complex tests that test everything at once
```lua
-- Too complex - hard to debug when it fails
it("should handle entire gameplay loop", function(ctx)
   -- 500 lines of setup and testing...
end)
```

**Prefer**: Focused tests for specific features
```lua
-- Good - test one specific thing
it("should announce cursor position changes", function(ctx)
   -- Just test position announcement logic
end)

it("should handle cursor size increases", function(ctx)
   -- Just test size changes
end)
```

### 3. State Persistence Issues

**Wrong**: Using undefined variables
```lua
it("should fail", function(ctx)
   ctx:init(function()
      local value = 42
   end)
   
   ctx:at_tick(1, function()
      -- Error: 'value' is not in scope here
      ctx:assert_equals(42, value)
   end)
end)
```

**Right**: Declare variables in test scope
```lua
it("should work", function(ctx)
   local value -- Declare in test function scope
   
   ctx:init(function()
      value = 42
   end)
   
   ctx:at_tick(1, function()
      -- Now 'value' is accessible
      ctx:assert_equals(42, value)
   end)
end)
```

## Debugging Tests

### Using print() for Debugging

The test framework captures `print()` output:

```lua
it("should debug with print", function(ctx)
   local value = 0
   
   ctx:init(function()
      print("Test starting, value:", value)
      value = 42
   end)
   
   ctx:at_tick(1, function()
      print("At tick 1, value:", value)
      -- Prints help debug test failures
   end)
end)
```

### Reading Test Logs

Test output includes:
- Test name and suite
- Assertion failures with line numbers
- Any print() output
- Final summary of passed/failed tests

Example output:
```
[TestFramework] Running test: My Feature Tests :: should do something
[Test] Test starting, value: 0
[Test] At tick 1, value: 42
[TestFramework] Test passed: My Feature Tests :: should do something
```

### Common Error Messages

1. **"No player found at index X"**
   - The test environment should have player 1 by default
   - Use `ctx:setup_test_area(1)` to ensure proper setup

2. **"Assertion failed: expected X, got Y"**
   - Check the exact values being compared
   - Use `print()` to debug intermediate values

3. **"attempt to index nil value"**
   - Entity might be invalid or destroyed
   - Always check `entity.valid` before using entities

4. **"it() must be called within a describe() block"**
   - Ensure your test structure is correct
   - All `it()` calls must be inside a `describe()` function

## Test Helpers

The framework provides several helpers:

### setup_test_area

Clears an area and returns player/surface:
```lua
local player, surface = ctx:setup_test_area(pindex)
```

### clear_area

Removes entities in a radius:
```lua
ctx:clear_area(surface, position, radius)
```

### setup_player

Ensures player exists with character:
```lua
local player = ctx:setup_player(pindex)
```

## Best Practices

1. **Keep tests focused** - One test should verify one behavior
2. **Use descriptive names** - Test names should explain what they verify
3. **Clean up after tests** - Use `ctx:clear_area()` to avoid interference
4. **Test edge cases** - Don't just test the happy path
5. **Use local variables** - Prefer locals over ctx.state
6. **Mock sparingly** - Only mock what's necessary for the test
7. **Avoid timing dependencies** - Use explicit tick counts, not assumptions

## Example: Complete Test File

Here's a complete example showing all concepts:

```lua
-- scripts/tests/example-complete-test.lua
local TestRegistry = require("scripts.test-registry")
local EventManager = require("scripts.event-manager")
local describe = TestRegistry.describe
local it = TestRegistry.it

describe("Complete Example Tests", function()
   -- Suite-level setup
   before_all(function()
      print("Starting Complete Example test suite")
   end)
   
   after_all(function()
      print("Finished Complete Example test suite")
   end)
   
   it("should demonstrate all test features", function(ctx)
      -- Test-scoped variables
      local player, surface
      local test_entities = {}
      local event_fired = false
      
      -- Initialization
      ctx:init(function()
         -- Setup test environment
         player, surface = ctx:setup_test_area(1)
         
         -- Create test entities
         test_entities.assembler = surface.create_entity{
            name = "assembling-machine-1",
            position = {0, 0},
            force = player.force
         }
         
         -- Give player items
         player.insert{name = "iron-plate", count = 100}
      end)
      
      -- Test at specific tick
      ctx:at_tick(1, function()
         -- Test entity creation
         ctx:assert_not_nil(test_entities.assembler)
         ctx:assert(test_entities.assembler.valid)
         
         -- Set recipe
         test_entities.assembler.set_recipe("iron-gear-wheel")
      end)
      
      -- Test after delay
      ctx:in_ticks(10, function()
         -- Verify recipe was set
         local recipe = test_entities.assembler.get_recipe()
         ctx:assert_not_nil(recipe)
         ctx:assert_equals("iron-gear-wheel", recipe.name)
         
         -- Mock an event
         EventManager.mock_event(defines.events.on_built_entity, {
            created_entity = test_entities.assembler,
            player_index = 1,
            tick = game.tick
         })
      end)
      
      -- Final verification
      ctx:in_ticks(5, function()
         -- Verify player inventory
         local iron_count = player.get_item_count("iron-plate")
         ctx:assert_equals(100, iron_count)
         
         -- Clean assertion example
         ctx:assert_table_equals(
            {x = 0, y = 0},
            test_entities.assembler.position,
            "Assembler should be at origin"
         )
      end)
   end)
end)
```

This guide should help you write effective tests for FactorioAccess features. Remember to focus on testing mod behavior, not Factorio's built-in functionality!