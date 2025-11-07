local railtable = require("railtable")

print("=== GEOMETRIC MENTAL MODEL ===\n")

print("1. RAIL LENGTHS AND SPACING")
print("   Factorio uses a 2-tile grid. All rails snap to this grid.")
print("   A straight rail segment is 2 tiles long.")
print("")

local straight = railtable["straight-rail"]["north"]
for end_dir, end_data in pairs(straight) do
   for ext_dir, ext_data in pairs(end_data.extensions) do
      if ext_dir == "south" or ext_dir == "north" then
         local dx = ext_data.goal_position.x - ext_data.position.x
         local dy = ext_data.goal_position.y - ext_data.position.y
         local piece_to_end = math.sqrt((ext_data.goal_position.x - 0) ^ 2 + (ext_data.goal_position.y - 0) ^ 2)
         print("   Straight rail continuation: piece at (" .. ext_data.position.x .. ", " .. ext_data.position.y .. ")")
         print("   Next end at (" .. ext_data.goal_position.x .. ", " .. ext_data.goal_position.y .. ")")
         print("   Distance: " .. math.sqrt(dx * dx + dy * dy) .. " tiles\n")
         break
      end
   end
   break
end

print("2. THE 2-TILE GRID CONSTRAINT")
print("   Rails must connect end-to-end on this grid.")
print("   Cardinal straight rails (N/S/E/W): easy - just stack them")
print("   Diagonal rails: need special pieces to maintain grid alignment\n")

print("3. CURVED RAILS: THE ROTATION STORY")
print("   Curved rails turn by 22.5 degrees (1/16 of a circle)")
print("   But they also need to preserve grid alignment!")
print("")
print("   Think of it this way:")
print("   - You're heading north (direction 0)")
print("   - You want to turn slightly right")
print("   - curved-rail-a will rotate you to northnortheast (direction 1)")
print("   - But it ALSO moves you in space to stay on grid\n")

print("4. WHY TWO CURVED PIECES?")
print("   curved-rail-a and curved-rail-b are mirror images")
print("   They handle different geometric situations:")
print("")

-- Show the actual end positions for both curved types
local ca_north = railtable["curved-rail-a"]["north"]
local cb_north = railtable["curved-rail-b"]["north"]

print("   curved-rail-a placed at north (0):")
for end_dir, _ in pairs(ca_north) do
   print("     Ends: " .. end_dir)
end

print("\n   curved-rail-b placed at north (0):")
for end_dir, _ in pairs(cb_north) do
   print("     Ends: " .. end_dir)
end

print("\n   Notice: different end configurations!")
print("   This is because the curve needs to fit the grid differently")
print("   depending on which way it's bending.\n")

print("5. HALF-DIAGONAL RAILS")
print('   These are the "intermediate" directions (NNE, ENE, ESE, etc.)')
print("   They go 180 degrees but at a diagonal angle")
print('   Think of them as "diagonal straight rails"\n')

print("6. THE EXTENSION PATTERN: ALWAYS ±1")
print("   From ANY rail end, you can extend in 3 directions:")
print("   - Straight ahead (same direction)")
print("   - Turn left 22.5° (direction - 1)")
print("   - Turn right 22.5° (direction + 1)")
print("")
print("   This is universal! The game lets you make gentle curves.")
print("   You can't make sharp 90° turns directly.\n")

print("7. MENTAL MODEL: THINK IN DIRECTIONS, NOT COORDINATES")
print("   The key insight: rail connections are about DIRECTIONS")
print("   - Each rail end faces a direction (0-15)")
print("   - You can extend ±1 direction from there")
print("   - The coordinates follow from the geometry")
print("")
print("   When planning rail paths:")
print("   1. Know your current end direction")
print("   2. Pick extension: same, +1 (right), or -1 (left)")
print("   3. Place the appropriate piece type")
print("   4. New end faces the goal direction\n")

print("8. THE OFFSET PATTERNS EXPLAINED")
print("   Why does curved-rail-a have different offsets on cardinals vs diagonals?")
print("")
print("   Cardinals (N,E,S,W = 0,4,8,12): directions divisible by 4")
print("   Diagonals (NE,SE,SW,NW = 2,6,10,14): directions = 2 mod 4")
print("")
print("   The geometry of how a curve fits the 2-tile grid is different")
print("   when starting from cardinal vs diagonal directions.")
print("   The pieces are physically shaped to handle these cases.\n")

print("9. WORKING WITHOUT THE TABLE")
print("   Given: rail piece type + placement direction + end direction")
print("   You know: extensions are at end_dir, end_dir+1, end_dir-1")
print("")
print("   To choose which piece:")
print("   - Same direction? Use straight (if going cardinal->cardinal)")
print("   - Same direction? Use half-diagonal (if going diagonal->diagonal)")
print("   - ±1 direction? Use one of the curved pieces")
print("")
print("   The specific curved piece (a vs b) depends on the geometry,")
print("   but the table tells you which one works for each extension.\n")
