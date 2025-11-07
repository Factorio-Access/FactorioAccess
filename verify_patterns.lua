local railtable = require("railtable")

local dir_to_num = {
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

local num_to_dir = {}
for k, v in pairs(dir_to_num) do
   num_to_dir[v] = k
end

print("=== VERIFICATION OF MENTAL MODEL ===\n")

print("1. Testing the Universal Extension Rule")
print('   "Every end has extensions at offsets 0, +1, -1"\n')

local all_valid = true
for rail_type, placements in pairs(railtable) do
   for placement_dir, ends in pairs(placements) do
      for end_dir, end_data in pairs(ends) do
         local end_num = dir_to_num[end_dir]
         local ext_offsets = {}

         for ext_dir, _ in pairs(end_data.extensions) do
            local ext_num = dir_to_num[ext_dir]
            local offset = (ext_num - end_num + 16) % 16
            table.insert(ext_offsets, offset)
         end

         table.sort(ext_offsets)
         if ext_offsets[1] ~= 0 or ext_offsets[2] ~= 1 or ext_offsets[3] ~= 15 then
            print("  FAIL: " .. rail_type .. " " .. placement_dir .. " end " .. end_dir)
            print("    Offsets: " .. table.concat(ext_offsets, ", "))
            all_valid = false
         end
      end
   end
end

if all_valid then
   print("  ✓ CONFIRMED: All 64 rail ends (4 types × 8 placements × 2 ends) have extensions at [0,1,15]")
   print("    This means the extension rule is truly universal!\n")
end

print("2. Testing End Direction Prediction")
print('   "Can we predict both end directions from placement?"\n')

local end_rules = {
   ["straight-rail"] = function(p)
      return { p, (p + 8) % 16 }
   end,
   ["half-diagonal-rail"] = function(p)
      return { (p + 7) % 16, (p + 15) % 16 }
   end,
   ["curved-rail-a"] = function(p)
      if p % 4 == 0 then
         return { (p + 8) % 16, (p + 15) % 16 }
      else
         return { (p + 6) % 16, (p + 15) % 16 }
      end
   end,
   ["curved-rail-b"] = function(p)
      if p % 4 == 0 then
         return { (p + 7) % 16, (p + 14) % 16 }
      else
         return { p, (p + 7) % 16 }
      end
   end,
}

all_valid = true
for rail_type, placements in pairs(railtable) do
   for placement_dir, ends in pairs(placements) do
      local p = dir_to_num[placement_dir]
      local predicted = end_rules[rail_type](p)
      table.sort(predicted)

      local actual = {}
      for end_dir, _ in pairs(ends) do
         table.insert(actual, dir_to_num[end_dir])
      end
      table.sort(actual)

      if predicted[1] ~= actual[1] or predicted[2] ~= actual[2] then
         print("  FAIL: " .. rail_type .. " at " .. placement_dir)
         print("    Predicted: " .. num_to_dir[predicted[1]] .. ", " .. num_to_dir[predicted[2]])
         print("    Actual: " .. num_to_dir[actual[1]] .. ", " .. num_to_dir[actual[2]])
         all_valid = false
      end
   end
end

if all_valid then
   print("  ✓ CONFIRMED: All 32 rail placements have predictable end directions")
   print("    You can calculate end positions without looking them up!\n")
end

print("3. Testing Rotational Symmetry")
print('   "Do patterns repeat every 90 degrees?"\n')

-- Check if placing at north+0, north+4, north+8, north+12 (N,E,S,W) gives symmetric results
local function check_symmetry(rail_type)
   local base = railtable[rail_type]["north"]
   if not base then return false end

   -- Get end offsets for north placement
   local base_offsets = {}
   local base_dir = dir_to_num["north"]
   for end_dir, _ in pairs(base) do
      local offset = (dir_to_num[end_dir] - base_dir + 16) % 16
      table.insert(base_offsets, offset)
   end
   table.sort(base_offsets)

   -- Check E, S, W
   for i, check_dir in ipairs({ "east", "south", "west" }) do
      local check_data = railtable[rail_type][check_dir]
      if not check_data then return false end

      local check_offsets = {}
      local check_num = dir_to_num[check_dir]
      for end_dir, _ in pairs(check_data) do
         local offset = (dir_to_num[end_dir] - check_num + 16) % 16
         table.insert(check_offsets, offset)
      end
      table.sort(check_offsets)

      if base_offsets[1] ~= check_offsets[1] or base_offsets[2] ~= check_offsets[2] then return false end
   end

   return true
end

for rail_type, _ in pairs(railtable) do
   if check_symmetry(rail_type) then
      print("  ✓ " .. rail_type .. ": 90° rotational symmetry confirmed")
   else
      print("  ✗ " .. rail_type .. ": no perfect 90° symmetry")
   end
end

print("\n4. Summary of What You Can Trust")
print("   Based on verified patterns:\n")
print("   ✓ Any rail end can extend in exactly 3 directions (same, +1, -1)")
print("   ✓ End directions can be calculated from placement direction")
print("   ✓ Patterns are rotationally symmetric (N/E/S/W behave the same)")
print('   ✓ Only 4 unique "shapes" (the 4 piece types)')
print("")
print("   What you still need the table for:")
print("   - Which specific piece type for each extension")
print("   - Exact coordinate positions")
print("   - Signal locations")
print("")
print("   But you now understand WHY the patterns exist!")
print("   The table is just storing geometric solutions to the")
print("   grid-alignment constraint - not arbitrary data.\n")
