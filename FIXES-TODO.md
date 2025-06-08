# Fixes Required Based on Feedback

## Critical Architecture Changes

1. **EventManager Module Pattern**
   - Change from `EventManager = {}` to `local mod = {}`
   - Fix all other modules to use `local mod = {}` pattern

2. **Move ALL event registrations from control.lua to EventManager**
   - This enables proper event mocking for tests
   - EventManager should self-initialize on require

3. **Test Framework Improvements**
   - Remove excessive pcall/xpcall (only keep around test execution)
   - Move test file loading from control.lua to test_framework.lua
   - Fix TestContext to use `.new()` not `:new()`
   - Clear entire surface, not just a range
   - Properly handle player controller restoration

## Test Fixes

4. **Import Pattern Issues**
   - Always import modules at TOP of test files
   - Example: `local Info = require('scripts.fa-info')`
   - NEVER import inside test functions

5. **Stop Cheating in Tests**
   - wasd_event_test.lua must mock events, not manipulate storage directly
   - cursor_movement_test.lua should send fake events via EventManager
   - Tests should drive functionality through events, not direct state manipulation

6. **Test Organization**
   - Create `scripts/tests/framework/` for framework tests
   - Move framework-specific tests there
   - Delete pointless tests (scanner_test.lua, entity_tests.lua)

7. **Specific Test Fixes**
   - Remove @module annotations
   - Fix tick timing tests to assert against game.tick
   - Let storage-manager modules lazy-init (don't init in tests)
   - Run linter on all test code

## Selected Tests to Implement

From the 30 ideas, implement these 7:
1. Cursor bookmark system
10. Crafting menu navigation
12. Character inventory coordinate announcements
17. Quickbar slot management
20. Belt direction detection
21. Assembler recipe status
22. Power network info

## Documentation

- Document the import pattern issue clearly
- Add comments explaining why we mock events vs manipulating state
- Clarify that framework tests are separate from functionality tests