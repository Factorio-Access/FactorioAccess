--- Test Framework: A testing framework for FactorioAccess
-- Provides tick-based testing with setup and assertions

local EventManager = require("scripts.event-manager")
local sounds = require("scripts.ui.sounds")
local TestRegistry = require("scripts.test-registry")

local mod = {}

-- Logger wrapper to handle cases where Logger isn't initialized yet
local function log_info(module, message)
   if _G.Logger then Logger.info(module, message) end
end

local function log_warn(module, message)
   if _G.Logger then Logger.warn(module, message) end
end

local function log_error(module, message)
   if _G.Logger then Logger.error(module, message) end
end

-- Test files to load
local test_files = {
   -- Integration/smoke tests as per claude-prompt.md
   "simple-smoke-test", -- Very basic tests to verify framework works
   "cursor-movement-test", -- Test mod's cursor system (not vanilla)
   "wasd-event-test", -- Test cursor movement via WASD simulation
   -- Selected tests from feedback
   "cursor-bookmark-test", -- Test cursor bookmark system (test #1)
   "crafting-menu-test", -- Test crafting menu navigation (test #10)
   "inventory-coordinates-test", -- Test inventory coordinate announcements (test #12)
   -- Additional tests
   "belt-direction-test", -- Test transport belt direction detection
   "assembler-recipe-test", -- Test assembling machine recipe management
   "building-footprint-tests", -- Test centralized building footprint calculations
   -- "fa-info-smoke-test", -- Test entity information extraction system (temporarily disabled)
   -- "sound-tests", -- Test sound system integration (temporarily disabled)
}

-- Test execution state
local current_test = nil
local test_queue = {}
local scheduled_actions = {}
local test_results = {}
local is_running = false
local start_tick = 0

-- Get assertions from registry
local assertions = TestRegistry.get_assertions()

-- Test context object
local TestContext = {}
TestContext.__index = TestContext

function TestContext.new(test_name)
   local ctx = {
      name = test_name,
      init_func = nil,
      actions = {},
      last_tick = 0,
      state = {}, -- For storing test-specific state
   }

   -- Add assertion methods with proper self binding
   for name, func in pairs(assertions) do
      ctx[name] = function(self, ...)
         return func(...)
      end
   end

   setmetatable(ctx, TestContext)
   return ctx
end

--- Initialize the test (runs at tick 0)
function TestContext:init(func)
   self.init_func = func
end

-- Common test setup helper
function TestContext:setup_player(pindex)
   pindex = pindex or 1
   local player = game.get_player(pindex)

   if not player then
      self:error("No player found at index " .. pindex)
      return nil
   end

   -- Ensure player has a character
   if not player.character then player.create_character() end

   return player
end

-- Clear area around a position
function TestContext:clear_area(surface, position, radius)
   radius = radius or 10
   local area = {
      { position.x - radius, position.y - radius },
      { position.x + radius, position.y + radius },
   }

   for _, entity in pairs(surface.find_entities(area)) do
      if entity.name ~= "character" then entity.destroy() end
   end
end

-- Combined helper for common test setup
function TestContext:setup_test_area(pindex)
   local player = self:setup_player(pindex)
   if not player then return nil, nil end

   local surface = player.surface
   self:clear_area(surface, player.position)

   return player, surface
end

--- Run a function at a specific tick
function TestContext:at_tick(tick, func)
   table.insert(self.actions, {
      type = "at_tick",
      tick = tick,
      func = func,
   })
end

--- Run a function after a delta from the last action
function TestContext:in_ticks(delta, func)
   table.insert(self.actions, {
      type = "in_ticks",
      delta = delta,
      func = func,
   })
end

--- Run all registered tests
function mod.run_all()
   if is_running then
      log_warn("TestFramework", "Tests are already running")
      return
   end

   log_info("TestFramework", "Starting test run")
   if _G.Logger then Logger.use_test_log() end

   -- Enable test modes
   EventManager.enable_test_mode()
   sounds.enable_test_mode()

   is_running = true
   start_tick = game.tick
   test_results = {
      total = 0,
      passed = 0,
      failed = 0,
      errors = {},
      start_time = game.tick,
   }

   local test_suites = TestRegistry.get_test_suites()
   log_info("TestFramework", "Found " .. #test_suites .. " test suites")

   -- Build test queue
   test_queue = {}
   for _, suite in ipairs(test_suites) do
      log_info("TestFramework", "Suite '" .. suite.name .. "' has " .. #suite.tests .. " tests")
      for _, test in ipairs(suite.tests) do
         table.insert(test_queue, {
            suite = suite,
            test = test,
         })
      end
   end

   test_results.total = #test_queue
   log_info("TestFramework", "Total tests to run: " .. test_results.total)

   -- Start first test
   if #test_queue > 0 then
      mod._run_next_test()
   else
      mod._finish_tests()
   end
end

--- Check if the current save is a test save
-- Test saves are identified by having a lab tile at position 0,0
-- @return boolean True if this is a test save
function mod.is_test_save()
   if not game then return false end

   local surface = game.surfaces[1]
   if not surface then return false end

   -- Get the tile at position 0,0
   local tile = surface.get_tile(0, 0)
   if not tile or not tile.valid then return false end

   -- Check if it's a lab tile (any tile starting with "lab-")
   return string.find(tile.name, "^lab%-") ~= nil
end

--- Internal: Reset game state between tests
function mod._reset_game_state()
   -- Clear the entire surface instead of just a range
   local surface = game.surfaces["nauvis"]
   if surface then
      -- Get all entities on the surface
      local entities = surface.find_entities()
      for _, entity in pairs(entities) do
         if entity.valid and entity.type ~= "character" then entity.destroy() end
      end
   end

   -- Reset all players
   for _, player in pairs(game.players) do
      -- Reset player position
      if player.character then
         player.teleport({ 0, 0 })
      else
         -- Try to restore physical controller and respawn
         player.set_controller({ type = defines.controllers.character })
         if not player.character then player.create_character() end
         if player.character then player.teleport({ 0, 0 }) end
      end

      -- Clear cursor stack
      if player.cursor_stack then player.cursor_stack.clear() end

      -- Clear inventory
      if player.character then player.get_main_inventory().clear() end
   end

   -- Clear scheduled actions
   scheduled_actions = {}
end

--- Internal: Run the next test in the queue
function mod._run_next_test()
   if #test_queue == 0 then
      mod._finish_tests()
      return
   end

   -- Reset state
   mod._reset_game_state()

   -- Get next test
   local test_data = table.remove(test_queue, 1)
   current_test = {
      suite = test_data.suite,
      test = test_data.test,
      context = TestContext.new(test_data.test.name),
      start_tick = game.tick,
   }

   log_info("TestFramework", string.format("Running test: %s - %s", current_test.suite.name, current_test.test.name))

   -- Run before_all if this is the first test in the suite
   if test_data.suite.before_all and not test_data.suite._before_all_run then
      local success, err = pcall(test_data.suite.before_all)
      if not success then log_error("TestFramework", "before_all failed: " .. tostring(err)) end
      test_data.suite._before_all_run = true
   end

   -- Run before_each
   if test_data.suite.before_each then
      local success, err = pcall(test_data.suite.before_each)
      if not success then log_error("TestFramework", "before_each failed: " .. tostring(err)) end
   end

   -- Execute the test function to build the test plan
   local success, err = pcall(current_test.test.func, current_test.context)
   if not success then
      mod._complete_test(false, err)
      return
   end

   -- Schedule init function for NEXT tick to ensure it runs
   if current_test.context.init_func then
      local init_tick = game.tick + 1
      log_info("TestFramework", "Scheduling init function for tick " .. init_tick)
      scheduled_actions[init_tick] = scheduled_actions[init_tick] or {}
      local ctx = current_test.context
      table.insert(scheduled_actions[init_tick], function()
         log_info("TestFramework", "Running init function")
         local init_success, init_err = pcall(current_test.context.init_func)
         if not init_success then mod._complete_test(false, init_err) end
      end)
   else
      log_info("TestFramework", "No init function for test")
   end

   -- Schedule all actions (starting from next tick after init)
   local current_tick = game.tick + 1 -- Start from next tick since init runs there
   for _, action in ipairs(current_test.context.actions) do
      if action.type == "at_tick" then
         current_tick = game.tick + 1 + action.tick -- Add 1 to account for init tick
      elseif action.type == "in_ticks" then
         current_tick = current_tick + action.delta
      end

      scheduled_actions[current_tick] = scheduled_actions[current_tick] or {}
      -- Execute the action function (it already has access to ctx via closure)
      log_info("TestFramework", string.format("Scheduling action for tick %d (type: %s)", current_tick, action.type))
      table.insert(scheduled_actions[current_tick], function()
         action.func()
      end)
   end

   -- Schedule test completion
   local complete_tick = current_tick + 1
   scheduled_actions[complete_tick] = scheduled_actions[complete_tick] or {}
   table.insert(scheduled_actions[complete_tick], function()
      mod._complete_test(true)
   end)
end

--- Internal: Complete the current test
function mod._complete_test(passed, error_msg)
   if not current_test then return end

   -- Run after_each
   if current_test.suite.after_each then pcall(current_test.suite.after_each) end

   -- Check if this is the last test in the suite
   local is_last_in_suite = true
   for _, test_data in ipairs(test_queue) do
      if test_data.suite == current_test.suite then
         is_last_in_suite = false
         break
      end
   end

   -- Run after_all if this is the last test in the suite
   if is_last_in_suite and current_test.suite.after_all then pcall(current_test.suite.after_all) end

   -- Record result
   if passed then
      test_results.passed = test_results.passed + 1
      log_info("TestFramework", string.format("✓ %s - %s", current_test.suite.name, current_test.test.name))
   else
      test_results.failed = test_results.failed + 1
      table.insert(test_results.errors, {
         suite = current_test.suite.name,
         test = current_test.test.name,
         error = error_msg or "Unknown error",
      })
      log_error(
         "TestFramework",
         string.format("✗ %s - %s: %s", current_test.suite.name, current_test.test.name, error_msg or "Unknown error")
      )
   end

   -- Clear current test
   current_test = nil

   -- Schedule next test for next tick to ensure init functions run properly
   scheduled_actions[game.tick + 1] = scheduled_actions[game.tick + 1] or {}
   table.insert(scheduled_actions[game.tick + 1], function()
      mod._run_next_test()
   end)
end

--- Internal: Finish test run and report results
function mod._finish_tests()
   is_running = false

   -- Disable test modes
   EventManager.disable_test_mode()
   sounds.disable_test_mode()

   -- Calculate duration
   local duration = (game.tick - start_tick) / 60

   -- Log results
   log_info(
      "TestFramework",
      string.format(
         "\nTest Results:\n" .. "Total: %d\n" .. "Passed: %d\n" .. "Failed: %d\n" .. "Duration: %.2f seconds",
         test_results.total,
         test_results.passed,
         test_results.failed,
         duration
      )
   )

   -- Log errors
   if #test_results.errors > 0 then
      log_error("TestFramework", "\nFailed Tests:")
      for _, error in ipairs(test_results.errors) do
         log_error("TestFramework", string.format("  %s - %s: %s", error.suite, error.test, error.error))
      end
   end

   -- Flush logs
   if _G.Logger then
      Logger.flush()
      -- Switch back to main log
      Logger.use_main_log()
   end

   -- Print summary to console
   print(string.format("\nTest run complete: %d/%d passed", test_results.passed, test_results.total))

   -- Write detailed test results as JSON
   local results_data = {
      total = test_results.total,
      passed = test_results.passed,
      failed = test_results.failed,
      duration = duration,
      errors = test_results.errors,
   }
   helpers.write_file("test-results.json", game.table_to_json(results_data), false)

   -- Exit with appropriate code
   if test_results.failed > 0 then
      -- In benchmarking mode, we can't actually exit with a code
      -- but we can write a marker file
      helpers.write_file("test-failed", "1", false)
   else
      helpers.write_file("test-passed", "1", false)
   end
end

--- Called on each tick to execute scheduled actions
function mod.on_tick(event)
   if not is_running then return end

   local actions = scheduled_actions[event.tick]
   if actions then
      log_info("TestFramework", string.format("Running %d scheduled actions for tick %d", #actions, event.tick))
      for _, action in ipairs(actions) do
         local success, err = xpcall(action, debug.traceback)
         if not success and current_test then
            -- Test action failed
            mod._complete_test(false, err)
            -- Clear remaining scheduled actions for this test
            for tick, _ in pairs(scheduled_actions) do
               if tick >= event.tick then scheduled_actions[tick] = nil end
            end
         end
      end
      scheduled_actions[event.tick] = nil
   end
end

--- Load all test files (must be done at top level during module load)
for _, file in ipairs(test_files) do
   local success, module = pcall(require, "scripts.tests." .. file)
   if not success then
      -- Can't log yet since Logger might not be initialized
      print("TestFramework: Failed to load test file " .. file .. ": " .. tostring(module))
   end
end

--- Initialize test framework (called from control.lua)
function mod.load_tests()
   -- Just log the summary since tests are already loaded
   local test_suites = TestRegistry.get_test_suites()
   if _G.Logger then log_info("TestFramework", "Test loading complete. " .. #test_suites .. " suites registered.") end
end

function mod.on_init()
   if mod.is_test_save() then
      log_info("TestFramework", "Detected test save, initializing test framework")
      mod.run_all()
   end
end

return mod
