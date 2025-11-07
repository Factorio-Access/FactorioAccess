-- Validation script for rail-geometry.md patterns
-- Run with: lua52 validate_rail_patterns.lua

local data = dofile("railtable.lua")

-- Direction name to number mapping
local DIR_TO_NUM = {
   north = 0,
   northnortheast = 1,
   northeast = 2,
   eastnortheast = 3,
   east = 4,
   eastsoutheast = 5,
   southeast = 6,
   southsoutheast = 7,
   south = 8,
   southsouthwest = 9,
   southwest = 10,
   westsouthwest = 11,
   west = 12,
   westnorthwest = 13,
   northwest = 14,
   northnorthwest = 15,
}

local NUM_TO_DIR = {}
for name, num in pairs(DIR_TO_NUM) do
   NUM_TO_DIR[num] = name
end

-- Helper to get direction type
local function get_dir_type(dir_num)
   if dir_num % 4 == 0 then
      return "cardinal"
   elseif dir_num % 4 == 2 then
      return "diagonal"
   else
      return "intermediate"
   end
end

-- Normalize direction to 0-15
local function normalize_dir(d)
   return d % 16
end

print("=" .. string.rep("=", 79))
print("RAIL PATTERN VALIDATION")
print("=" .. string.rep("=", 79))
print()

-- Test 1: Universal Extension Rule
print("TEST 1: Universal Extension Rule")
print("Every rail end should have exactly 3 extensions at offsets [0, +1, -1]")
print("-" .. string.rep("-", 79))

local test1_pass = 0
local test1_fail = 0

for proto, directions in pairs(data) do
   for placement_dir, entry in pairs(directions) do
      if type(entry) == "table" then
         for end_dir, end_data in pairs(entry) do
            if type(end_data) == "table" and end_data.extensions then
               local end_num = DIR_TO_NUM[end_dir]
               if end_num then
                  local extensions = end_data.extensions
                  local ext_count = 0
                  local expected_offsets = { [0] = true, [1] = true, [15] = true }
                  local found_offsets = {}

                  for goal_dir, ext in pairs(extensions) do
                     ext_count = ext_count + 1
                     local goal_num = DIR_TO_NUM[goal_dir]
                     local offset = normalize_dir(goal_num - end_num)
                     found_offsets[offset] = true
                  end

                  if ext_count == 3 and found_offsets[0] and found_offsets[1] and found_offsets[15] then
                     test1_pass = test1_pass + 1
                  else
                     test1_fail = test1_fail + 1
                     print(
                        string.format(
                           "  FAIL: %s @ %s, end %s: found %d extensions, offsets: %s",
                           proto,
                           placement_dir,
                           end_dir,
                           ext_count,
                           table.concat(
                              (function()
                                 local t = {}
                                 for o in pairs(found_offsets) do
                                    table.insert(t, tostring(o))
                                 end
                                 return t
                              end)(),
                              ", "
                           )
                        )
                     )
                  end
               end
            end
         end
      end
   end
end

print(string.format("Result: %d/%d PASS", test1_pass, test1_pass + test1_fail))
print()

-- Test 2: End Direction Prediction Formulas
print("TEST 2: End Direction Prediction Formulas")
print("-" .. string.rep("-", 79))

local expected_offsets = {
   ["straight-rail"] = { [0] = { 0, 8 }, [2] = { 0, 8 } }, -- cardinal and diagonal
   ["half-diagonal-rail"] = { [0] = { 7, 15 }, [2] = { 7, 15 } },
   ["curved-rail-a"] = { [0] = { 8, 15 }, [2] = { 6, 15 } },
   ["curved-rail-b"] = { [0] = { 7, 14 }, [2] = { 0, 7 } },
}

local test2_pass = 0
local test2_fail = 0

for proto, directions in pairs(data) do
   local proto_expected = expected_offsets[proto]
   if proto_expected then
      for placement_dir, entry in pairs(directions) do
         if type(entry) == "table" then
            local placement_num = DIR_TO_NUM[placement_dir]
            if placement_num then
               local dir_type_key = (placement_num % 4 == 0) and 0 or 2
               local expected = proto_expected[dir_type_key]

               -- Find actual end offsets
               local actual_offsets = {}
               for end_dir in pairs(entry) do
                  local end_num = DIR_TO_NUM[end_dir]
                  if end_num then
                     local offset = normalize_dir(end_num - placement_num)
                     table.insert(actual_offsets, offset)
                  end
               end

               table.sort(actual_offsets)
               table.sort(expected)

               if #actual_offsets == 2 and actual_offsets[1] == expected[1] and actual_offsets[2] == expected[2] then
                  test2_pass = test2_pass + 1
               else
                  test2_fail = test2_fail + 1
                  print(
                     string.format(
                        "  FAIL: %s @ %s (%s): expected [%d,%d], got [%s]",
                        proto,
                        placement_dir,
                        get_dir_type(placement_num),
                        expected[1],
                        expected[2],
                        table.concat(actual_offsets, ",")
                     )
                  )
               end
            end
         end
      end
   end
end

print(string.format("Result: %d/%d PASS", test2_pass, test2_pass + test2_fail))
print()

-- Test 3: Signal Direction Patterns
print("TEST 3: Signal Direction Patterns")
print("in_signal should match end direction, out_signal should be opposite (180°)")
print("-" .. string.rep("-", 79))

local test3_in_pass = 0
local test3_in_fail = 0
local test3_out_pass = 0
local test3_out_fail = 0

for proto, directions in pairs(data) do
   for placement_dir, entry in pairs(directions) do
      if type(entry) == "table" then
         for end_dir, end_data in pairs(entry) do
            if type(end_data) == "table" and end_data.signal_locations then
               local end_num = DIR_TO_NUM[end_dir]
               if end_num then
                  local signals = end_data.signal_locations

                  -- Check in_signal
                  if signals.in_signal then
                     local in_dir_num = DIR_TO_NUM[signals.in_signal.direction]
                     if in_dir_num == end_num then
                        test3_in_pass = test3_in_pass + 1
                     else
                        test3_in_fail = test3_in_fail + 1
                        print(
                           string.format(
                              "  FAIL in_signal: %s @ %s, end %s: expected %s, got %s",
                              proto,
                              placement_dir,
                              end_dir,
                              end_dir,
                              signals.in_signal.direction
                           )
                        )
                     end
                  end

                  -- Check out_signal
                  if signals.out_signal then
                     local out_dir_num = DIR_TO_NUM[signals.out_signal.direction]
                     local expected_out = normalize_dir(end_num + 8)
                     if out_dir_num == expected_out then
                        test3_out_pass = test3_out_pass + 1
                     else
                        test3_out_fail = test3_out_fail + 1
                        print(
                           string.format(
                              "  FAIL out_signal: %s @ %s, end %s: expected %s, got %s",
                              proto,
                              placement_dir,
                              end_dir,
                              NUM_TO_DIR[expected_out],
                              signals.out_signal.direction
                           )
                        )
                     end
                  end
               end
            end
         end
      end
   end
end

print(string.format("in_signal: %d/%d PASS", test3_in_pass, test3_in_pass + test3_in_fail))
print(string.format("out_signal: %d/%d PASS", test3_out_pass, test3_out_pass + test3_out_fail))
print()

-- Summary
print("=" .. string.rep("=", 79))
print("SUMMARY")
print("=" .. string.rep("=", 79))
print(string.format("Test 1 (Universal Extension): %d/%d PASS", test1_pass, test1_pass + test1_fail))
print(string.format("Test 2 (End Direction Formulas): %d/%d PASS", test2_pass, test2_pass + test2_fail))
print(string.format("Test 3a (in_signal direction): %d/%d PASS", test3_in_pass, test3_in_pass + test3_in_fail))
print(string.format("Test 3b (out_signal direction): %d/%d PASS", test3_out_pass, test3_out_pass + test3_out_fail))
print()

local all_pass = (test1_fail + test2_fail + test3_in_fail + test3_out_fail) == 0
if all_pass then
   print("✓ ALL TESTS PASSED")
else
   print("✗ SOME TESTS FAILED")
end
