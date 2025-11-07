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

print("=== COMPREHENSIVE RAIL PATTERN ANALYSIS ===\n")

print("1. RAIL END DIRECTIONS (relative to placement)")
print("   Format: [offset1, offset2] where offset = (end_dir - placement_dir) mod 16\n")
print("   straight-rail:      [0, 8]       - ends at placement dir and opposite")
print("   half-diagonal-rail: [7, 15]      - ends at +7 and -1 from placement\n")
print("   curved-rail-a (cardinals N,E,S,W):     [8, 15]  - ends at +8 and -1")
print("   curved-rail-a (diagonals NE,SE,SW,NW): [6, 15]  - ends at +6 and -1\n")
print("   curved-rail-b (cardinals N,E,S,W):     [7, 14]  - ends at +7 and -2")
print("   curved-rail-b (diagonals NE,SE,SW,NW): [0, 7]   - ends at +0 and +7")

print("\n2. EXTENSION DIRECTIONS (from each end)")
print("   ALL rail types: extensions at offsets [0, 1, 15] = [same, +1, -1]")
print("   Each end has exactly 3 extensions")
print("   Total 6 unique extension directions per rail piece")

print("\n3. GEOMETRIC PROPERTIES")
print("   Straight rails: 180 deg between ends (8 * 22.5 deg)")
print("   Half-diagonal rails: 180 deg between ends")
print("   Curved-rail-a: 157.5 deg between ends (7 * 22.5 deg)")
print("   Curved-rail-b: 157.5 deg between ends")

print("\n4. COMPLEMENTARITY")
print("   curved-rail-a and curved-rail-b are complementary:")
print("   - On cardinals: a=[8,15], b=[7,14]")
print("   - On diagonals: a=[6,15], b=[0,7]")
print("   Together they cover all possible 22.5 deg turns")

-- Verify we can reconstruct the table from these rules
print("\n5. VERIFICATION: Can we predict all ends from rules?")
local errors = 0
for rail_type, placements in pairs(railtable) do
   for placement_dir, ends in pairs(placements) do
      local placement_num = dir_to_num[placement_dir]
      local is_cardinal = (placement_num % 4 == 0)

      local expected_offsets
      if rail_type == "straight-rail" then
         expected_offsets = { 0, 8 }
      elseif rail_type == "half-diagonal-rail" then
         expected_offsets = { 7, 15 }
      elseif rail_type == "curved-rail-a" then
         expected_offsets = is_cardinal and { 8, 15 } or { 6, 15 }
      elseif rail_type == "curved-rail-b" then
         expected_offsets = is_cardinal and { 7, 14 } or { 0, 7 }
      end

      local actual_offsets = {}
      for end_dir, _ in pairs(ends) do
         local offset = (dir_to_num[end_dir] - placement_num + 16) % 16
         table.insert(actual_offsets, offset)
      end
      table.sort(actual_offsets)

      if actual_offsets[1] ~= expected_offsets[1] or actual_offsets[2] ~= expected_offsets[2] then
         print("ERROR: " .. rail_type .. " at " .. placement_dir)
         errors = errors + 1
      end
   end
end

if errors == 0 then
   print("   SUCCESS: All rail ends can be predicted from simple rules!")
else
   print("   ERRORS: " .. errors .. " mismatches found")
end
