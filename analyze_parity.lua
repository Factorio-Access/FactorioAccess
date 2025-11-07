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

print("=== THE COORDINATE PARITY PATTERN ===\n")

print("Rails are placed at origin (0,0). Let's see what positions they create:\n")

-- Analyze straight rail at different placements
local function analyze_placement(rail_type, placement_dir)
   local rail = railtable[rail_type][placement_dir]
   if not rail then return end

   print(rail_type .. " placed at " .. placement_dir .. " (origin 0,0):")

   for end_dir, end_data in pairs(rail) do
      local end_num = dir_to_num[end_dir]
      print("  End facing " .. end_dir .. " (dir " .. end_num .. "):")

      -- Group extensions by parity
      local odd_odd, odd_even, even_odd, even_even = {}, {}, {}, {}

      for ext_dir, ext_data in pairs(end_data.extensions) do
         local x, y = ext_data.position.x, ext_data.position.y
         local x_odd = (x % 2 ~= 0)
         local y_odd = (y % 2 ~= 0)

         local key = ext_dir .. " (" .. ext_data.prototype .. ")"
         if x_odd and y_odd then
            table.insert(odd_odd, key)
         elseif x_odd and not y_odd then
            table.insert(odd_even, key)
         elseif not x_odd and y_odd then
            table.insert(even_odd, key)
         else
            table.insert(even_even, key)
         end
      end

      if #odd_odd > 0 then print("    (odd, odd):   " .. table.concat(odd_odd, ", ")) end
      if #odd_even > 0 then print("    (odd, even):  " .. table.concat(odd_even, ", ")) end
      if #even_odd > 0 then print("    (even, odd):  " .. table.concat(even_odd, ", ")) end
      if #even_even > 0 then print("    (even, even): " .. table.concat(even_even, ", ")) end
   end
   print()
end

analyze_placement("straight-rail", "north")
analyze_placement("straight-rail", "east")
analyze_placement("half-diagonal-rail", "northeast")

print("\n=== THE PATTERN ===")
print("Notice how straight-rail extensions to STRAIGHT have (odd,odd) parity,")
print("while extensions to CURVED have (odd,even) parity!")
print("")
print("This is the grid alignment constraint in action:")
print("- Straight pieces connect at (odd,odd) or (even,even) positions")
print("- Curved pieces connect at (odd,even) or (even,odd) positions")
print("")
print("Why? Because rails are 2 tiles long:")
print("- Going straight: move 2 in one axis (same parity)")
print("- Going curved: move different amounts (parity changes)")
print("")
print("This parity pattern is how Factorio ensures rails stay on the grid!\n")

-- Now let's verify this pattern holds
print("=== VERIFICATION: Does parity predict piece type? ===\n")
local parity_predictions = {
   ["straight-rail"] = { both_odd = "straight", mixed = "curved" },
   ["half-diagonal-rail"] = { both_odd = "half-diagonal", mixed = "curved" },
   ["curved-rail-a"] = { both_odd = "straight or half-diagonal", mixed = "curved" },
   ["curved-rail-b"] = { both_odd = "straight or half-diagonal", mixed = "curved" },
}

local errors = 0
local total = 0

for rail_type, placements in pairs(railtable) do
   for placement_dir, ends in pairs(placements) do
      for end_dir, end_data in pairs(ends) do
         for ext_dir, ext_data in pairs(end_data.extensions) do
            total = total + 1
            local x, y = ext_data.position.x, ext_data.position.y
            local both_odd = (x % 2 ~= 0) and (y % 2 ~= 0)
            local both_even = (x % 2 == 0) and (y % 2 == 0)
            local mixed = not (both_odd or both_even)

            local pred_type
            if both_odd or both_even then
               pred_type = "straight or half-diagonal"
            else
               pred_type = "curved"
            end

            local actual_type
            if ext_data.prototype:find("curved") then
               actual_type = "curved"
            else
               actual_type = "straight or half-diagonal"
            end

            if pred_type ~= actual_type then
               print("ERROR: " .. rail_type .. " " .. placement_dir .. " end " .. end_dir .. " ext " .. ext_dir)
               print(
                  "  Position: (" .. x .. "," .. y .. ") predicted " .. pred_type .. " but got " .. ext_data.prototype
               )
               errors = errors + 1
            end
         end
      end
   end
end

if errors == 0 then
   print("SUCCESS: Parity perfectly predicts whether extension uses straight/half-diagonal vs curved!")
   print("(" .. total .. " extensions checked)")
else
   print("ERRORS: " .. errors .. " out of " .. total .. " predictions failed")
end
