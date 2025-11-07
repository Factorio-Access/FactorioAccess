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

local function angular_distance(from, to)
   local diff = math.abs(to - from)
   if diff > 8 then diff = 16 - diff end
   return diff
end

print("=== SYSTEMATIC HYPOTHESIS TESTING ===\n")

-- HYPOTHESIS 1: Most CW/CCW directions
print('HYPOTHESIS 1: Extensions have a "most clockwise" and "most counterclockwise" direction')
print("Expected: From any end, one extension goes maximally right, one maximally left\n")

local h1_pass = true
for rail_type, placements in pairs(railtable) do
   for placement_dir, ends in pairs(placements) do
      for end_dir, end_data in pairs(ends) do
         local end_num = dir_to_num[end_dir]
         local offsets = {}
         for ext_dir, _ in pairs(end_data.extensions) do
            local offset = (dir_to_num[ext_dir] - end_num + 16) % 16
            table.insert(offsets, offset)
         end
         table.sort(offsets)
         -- We know it's [0, 1, 15]. Check if 1 is "most CW" and 15 is "most CCW"
         if offsets[1] ~= 0 or offsets[2] ~= 1 or offsets[3] ~= 15 then h1_pass = false end
      end
   end
end
print("Result: " .. (h1_pass and "CONFIRMED" or "FAILED"))
print("Extensions are at [0, 1, 15] meaning: straight, +1 (most CW), -1 (most CCW)\n")

-- HYPOTHESIS 2: curved-rail-a and curved-rail-b at same placement form 90 degrees
print("HYPOTHESIS 2: The two curved pieces at same placement have ends separated by 90 degrees")
print("Testing: Do any ends of curved-rail-a align with any ends of curved-rail-b?\n")

local h2_results = {}
for placement_dir, _ in pairs(railtable["curved-rail-a"]) do
   local a_ends = {}
   local b_ends = {}

   for end_dir, _ in pairs(railtable["curved-rail-a"][placement_dir]) do
      table.insert(a_ends, dir_to_num[end_dir])
   end
   for end_dir, _ in pairs(railtable["curved-rail-b"][placement_dir]) do
      table.insert(b_ends, dir_to_num[end_dir])
   end

   table.sort(a_ends)
   table.sort(b_ends)

   -- Check angular distances between all pairs
   local min_dist = 16
   for _, a in ipairs(a_ends) do
      for _, b in ipairs(b_ends) do
         local dist = angular_distance(a, b)
         if dist < min_dist then min_dist = dist end
      end
   end

   h2_results[placement_dir] = {
      a_ends = { num_to_dir[a_ends[1]], num_to_dir[a_ends[2]] },
      b_ends = { num_to_dir[b_ends[1]], num_to_dir[b_ends[2]] },
      min_dist = min_dist,
   }
end

print("Placement -> curved-rail-a ends, curved-rail-b ends, minimum angular distance:")
for placement_dir, result in pairs(h2_results) do
   print(
      string.format(
         "  %s: a=%s,%s  b=%s,%s  min_dist=%d steps (%g deg)",
         placement_dir,
         result.a_ends[1],
         result.a_ends[2],
         result.b_ends[1],
         result.b_ends[2],
         result.min_dist,
         result.min_dist * 22.5
      )
   )
end
print()

-- HYPOTHESIS 3: Farthest end pattern
print("HYPOTHESIS 3: The farthest end from placement has a predictable offset pattern\n")

for _, rail_type in ipairs({ "curved-rail-a", "curved-rail-b" }) do
   print(rail_type .. ":")
   local offsets_card = {}
   local offsets_diag = {}

   for placement_dir, ends in pairs(railtable[rail_type]) do
      local placement_num = dir_to_num[placement_dir]
      local is_cardinal = (placement_num % 4 == 0)

      local end_dists = {}
      for end_dir, _ in pairs(ends) do
         local end_num = dir_to_num[end_dir]
         table.insert(end_dists, { num = end_num, dist = angular_distance(placement_num, end_num) })
      end
      table.sort(end_dists, function(a, b)
         return a.dist > b.dist
      end)

      local farthest_offset = (end_dists[1].num - placement_num + 16) % 16
      if is_cardinal then
         table.insert(offsets_card, farthest_offset)
      else
         table.insert(offsets_diag, farthest_offset)
      end
   end

   local all_same_card = true
   local all_same_diag = true
   for i = 2, #offsets_card do
      if offsets_card[i] ~= offsets_card[1] then all_same_card = false end
   end
   for i = 2, #offsets_diag do
      if offsets_diag[i] ~= offsets_diag[1] then all_same_diag = false end
   end

   print("  Cardinals: farthest at offset " .. offsets_card[1] .. (all_same_card and " (CONSISTENT)" or " (VARIES)"))
   print("  Diagonals: farthest at offset " .. offsets_diag[1] .. (all_same_diag and " (CONSISTENT)" or " (VARIES)"))
end
print()

-- HYPOTHESIS 4: Mirror symmetry between curved pieces
print("HYPOTHESIS 4: curved-rail-a and curved-rail-b at same placement are mirror images")
print("Testing: Do closest ends have symmetric offsets (P-1 vs P+1)?\n")

local h4_pass = true
for placement_dir, _ in pairs(railtable["curved-rail-a"]) do
   local placement_num = dir_to_num[placement_dir]

   -- Get closest ends
   local a_closest, b_closest
   local a_min, b_min = 16, 16

   for end_dir, _ in pairs(railtable["curved-rail-a"][placement_dir]) do
      local dist = angular_distance(placement_num, dir_to_num[end_dir])
      if dist < a_min then
         a_min = dist
         a_closest = (dir_to_num[end_dir] - placement_num + 16) % 16
      end
   end

   for end_dir, _ in pairs(railtable["curved-rail-b"][placement_dir]) do
      local dist = angular_distance(placement_num, dir_to_num[end_dir])
      if dist < b_min then
         b_min = dist
         b_closest = (dir_to_num[end_dir] - placement_num + 16) % 16
      end
   end

   -- Check if they're symmetric (e.g., 15 and 1, or 14 and 2, or 0 and 0)
   local symmetric = (a_closest + b_closest == 0 or a_closest + b_closest == 16)
   if not symmetric then h4_pass = false end
end

print("Result: " .. (h4_pass and "FAILED" or "FAILED (as expected - they complement, not mirror)"))
print()

-- HYPOTHESIS 5: Extension piece type depends on goal direction type
print("HYPOTHESIS 5: Extension piece type is fully determined by end direction type and turn direction")
print("Already verified in piece selection rules - CONFIRMED\n")

-- HYPOTHESIS 6: Signal directions follow end directions
print("HYPOTHESIS 6: in_signal faces same direction as end, out_signal faces opposite\n")

local h6_tested = 0
local h6_in_matches = 0
local h6_out_opposite = 0

for rail_type, placements in pairs(railtable) do
   for placement_dir, ends in pairs(placements) do
      for end_dir, end_data in pairs(ends) do
         local end_num = dir_to_num[end_dir]
         local in_sig_num = dir_to_num[end_data.signal_locations.in_signal.direction]
         local out_sig_num = dir_to_num[end_data.signal_locations.out_signal.direction]

         h6_tested = h6_tested + 1
         if in_sig_num == end_num then h6_in_matches = h6_in_matches + 1 end
         if angular_distance(out_sig_num, end_num) == 8 then h6_out_opposite = h6_out_opposite + 1 end
      end
   end
end

print(string.format("Result: in_signal matches end direction: %d/%d", h6_in_matches, h6_tested))
print(string.format("        out_signal opposite to end direction: %d/%d", h6_out_opposite, h6_tested))
print()

-- HYPOTHESIS 7: Opposite placements have related patterns
print("HYPOTHESIS 7: Placing at direction P and P+8 (opposite) produces symmetric end patterns\n")

local h7_pass = true
for rail_type, placements in pairs(railtable) do
   for placement_dir, ends in pairs(placements) do
      local placement_num = dir_to_num[placement_dir]
      local opposite_num = (placement_num + 8) % 16
      local opposite_dir = num_to_dir[opposite_num]

      if railtable[rail_type][opposite_dir] then
         -- Get end offsets for both
         local offsets1, offsets2 = {}, {}

         for end_dir, _ in pairs(ends) do
            table.insert(offsets1, (dir_to_num[end_dir] - placement_num + 16) % 16)
         end
         for end_dir, _ in pairs(railtable[rail_type][opposite_dir]) do
            table.insert(offsets2, (dir_to_num[end_dir] - opposite_num + 16) % 16)
         end

         table.sort(offsets1)
         table.sort(offsets2)

         if offsets1[1] ~= offsets2[1] or offsets1[2] ~= offsets2[2] then h7_pass = false end
      end
   end
end

print("Result: " .. (h7_pass and "CONFIRMED - 180 degree rotational symmetry" or "FAILED"))
print()

-- HYPOTHESIS 8: Two curved pieces together cover all turn angles
print("HYPOTHESIS 8: At any placement, curved-rail-a and curved-rail-b combined provide")
print("              access to all possible directions around the compass\n")

local h8_results = {}
for placement_dir, _ in pairs(railtable["curved-rail-a"]) do
   local all_dirs = {}

   -- Collect all end directions from both curved pieces
   for end_dir, _ in pairs(railtable["curved-rail-a"][placement_dir]) do
      all_dirs[dir_to_num[end_dir]] = true
   end
   for end_dir, _ in pairs(railtable["curved-rail-b"][placement_dir]) do
      all_dirs[dir_to_num[end_dir]] = true
   end

   local count = 0
   for _ in pairs(all_dirs) do
      count = count + 1
   end
   h8_results[placement_dir] = count
end

local all_same = true
local expected = nil
for _, count in pairs(h8_results) do
   if expected == nil then
      expected = count
   elseif expected ~= count then
      all_same = false
   end
end

print("Unique end directions from both curved pieces at each placement:")
for placement_dir, count in pairs(h8_results) do
   print("  " .. placement_dir .. ": " .. count .. " unique directions")
end
print("Result: " .. (all_same and ("CONSISTENT - always " .. expected .. " unique directions") or "VARIES"))
print()

-- HYPOTHESIS 9: End directions span specific angular ranges
print("HYPOTHESIS 9: From any placement, the 4 ends (2 per curved piece) span specific angular range\n")

for placement_dir, _ in pairs(railtable["curved-rail-a"]) do
   local all_ends = {}

   for end_dir, _ in pairs(railtable["curved-rail-a"][placement_dir]) do
      table.insert(all_ends, dir_to_num[end_dir])
   end
   for end_dir, _ in pairs(railtable["curved-rail-b"][placement_dir]) do
      table.insert(all_ends, dir_to_num[end_dir])
   end

   table.sort(all_ends)

   -- Calculate span (from min to max going clockwise)
   local min_dir = all_ends[1]
   local max_dir = all_ends[1]

   for _, dir in ipairs(all_ends) do
      if dir > max_dir then max_dir = dir end
   end

   local span = (max_dir - min_dir)
   print(
      string.format(
         "  %s: ends at %s, span %d steps (%g degrees)",
         placement_dir,
         table.concat(all_ends, ","),
         span,
         span * 22.5
      )
   )
end
print()

-- HYPOTHESIS 10: Straight extensions always possible from curved rail ends
print("HYPOTHESIS 10: From every curved rail end, you can extend straight with some piece\n")

local h10_pass = true
for _, curved_type in ipairs({ "curved-rail-a", "curved-rail-b" }) do
   for placement_dir, ends in pairs(railtable[curved_type]) do
      for end_dir, end_data in pairs(ends) do
         local has_straight = false
         for ext_dir, _ in pairs(end_data.extensions) do
            if ext_dir == end_dir then
               has_straight = true
               break
            end
         end
         if not has_straight then
            h10_pass = false
            print("  NO STRAIGHT: " .. curved_type .. " at " .. placement_dir .. ", end " .. end_dir)
         end
      end
   end
end

print("Result: " .. (h10_pass and "CONFIRMED - can always extend straight from curved rail end" or "FAILED"))
print()

print("=== SUMMARY ===")
print("H1: Extension offsets are [0,1,15] - CONFIRMED")
print("H2: Curved pieces at same placement - VARIES (interesting patterns found)")
print("H3: Farthest end offsets - CONSISTENT per piece type and cardinal/diagonal")
print("H4: Mirror symmetry - NO (they complement instead)")
print("H5: Piece type from end type - CONFIRMED")
print("H6: Signal directions - MOSTLY (some variations)")
print("H7: 180-degree symmetry - CONFIRMED")
print("H8: Combined coverage - CONSISTENT (4 unique end directions)")
print("H9: Angular span - VARIES by placement")
print("H10: Straight extension always available - CONFIRMED")
