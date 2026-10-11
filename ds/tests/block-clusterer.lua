local lu = require("luaunit")
local BC = require("ds.block-clusterer")

local mod = {}

local function key(x, y)
   return x .. "," .. y
end

-- Deterministic pseudo-random numbers, so a failure reproduces.
local function rng(seed)
   local state = seed
   return function(n)
      state = (state * 1103515245 + 12345) % 2147483648
      return state % n
   end
end

-- Load a set of cells ({ [key] = {x, y} }) into the clusterer, block by block. Blocks in `touched` that end up
-- with no cells are cleared.
local function load(c, cells, touched)
   local points = {}
   for _, p in pairs(cells) do
      points[#points + 1] = { x = p[1], y = p[2] }
   end
   local by_block = BC.rows_from_points(points)
   for bx, col in pairs(touched) do
      for by in pairs(col) do
         c:set_block(bx, by, by_block[bx] and by_block[bx][by] or nil)
      end
   end
   for bx, col in pairs(by_block) do
      for by, rows in pairs(col) do
         c:set_block(bx, by, rows)
      end
   end
end

-- Flood fill the cells into bodies: sorted summaries "x0 y0 x1 y1 cells edges", each body's edge cells, and the
-- body index of every cell.
local function brute_force(cells)
   local body_of = {}
   local summaries = {}
   local bodies = {}
   local function has(x, y)
      return cells[key(x, y)] ~= nil
   end
   for k, p in pairs(cells) do
      if not body_of[k] then
         local id = #bodies + 1
         body_of[k] = id
         local stack = { p }
         local x0, y0, x1, y1 = p[1], p[2], p[1], p[2]
         local count, edges = 0, {}
         while #stack > 0 do
            local q = table.remove(stack)
            local x, y = q[1], q[2]
            count = count + 1
            x0, y0, x1, y1 = math.min(x0, x), math.min(y0, y), math.max(x1, x), math.max(y1, y)
            if not (has(x - 1, y) and has(x + 1, y) and has(x, y - 1) and has(x, y + 1)) then edges[#edges + 1] = q end
            for _, d in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
               local nk = key(x + d[1], y + d[2])
               if cells[nk] and not body_of[nk] then
                  body_of[nk] = id
                  stack[#stack + 1] = cells[nk]
               end
            end
         end
         summaries[#summaries + 1] = string.format("%d %d %d %d %d %d", x0, y0, x1, y1, count, #edges)
         bodies[id] = edges
      end
   end
   table.sort(summaries)
   return summaries, bodies, body_of
end

local function summaries_of(c)
   local out = {}
   for _, g in ipairs(c:get_groups()) do
      out[#out + 1] = string.format("%d %d %d %d %d %d", g.x0, g.y0, g.x1, g.y1, g.cells, g.edges)
   end
   table.sort(out)
   return out
end

-- Some cell of a group: the lowest bit of its first component's first row.
local function a_cell_of(g)
   local comp = g.comps[1]
   local row = comp.rows[1]
   local x = 0
   while row % 2 == 0 do
      row = row / 2
      x = x + 1
   end
   return comp.bx * 32 + x, comp.by * 32 + comp.y0
end

local function check(c, cells, label)
   local expected, bodies, body_of = brute_force(cells)
   lu.assertEquals(summaries_of(c), expected, label)

   -- The closest edge cell is in the group's body and as close as the brute force's, for a few probe points.
   for _, g in ipairs(c:get_groups()) do
      local id = body_of[key(a_cell_of(g))]
      for _, probe in ipairs({ { 0.5, 0.5 }, { -37.2, 81.9 }, { 100.5, -20.25 }, { 15.5, 40.5 } }) do
         local px, py = probe[1], probe[2]
         local best = math.huge
         for _, e in ipairs(bodies[id]) do
            best = math.min(best, (e[1] + 0.5 - px) ^ 2 + (e[2] + 0.5 - py) ^ 2)
         end
         local x, y = c:closest_edge(g, px, py)
         lu.assertEquals(body_of[key(x, y)], id, label .. " closest edge is in the body")
         lu.assertAlmostEquals((x + 0.5 - px) ^ 2 + (y + 0.5 - py) ^ 2, best, 1e-9, label .. " closest edge")
      end
   end
end

local function touch(touched, x, y)
   local bx, by = math.floor(x / 32), math.floor(y / 32)
   touched[bx] = touched[bx] or {}
   touched[bx][by] = true
end

function mod.TestSingleCell()
   local c = BC.BlockClusterer.new()
   local cells = { [key(5, 7)] = { 5, 7 } }
   load(c, cells, {})
   lu.assertEquals(summaries_of(c), { "5 7 5 7 1 1" })
   local x, y = c:closest_edge(c:get_groups()[1], 100, 100)
   lu.assertEquals({ x, y }, { 5, 7 })
end

function mod.TestFullBlocksJoinAcrossBorders()
   local c = BC.BlockClusterer.new()
   local cells = {}
   for x = -32, 63 do
      for y = 0, 31 do
         cells[key(x, y)] = { x, y }
      end
   end
   load(c, cells, {})
   check(c, cells, "three full blocks")
   lu.assertEquals(#c:get_groups(), 1)
   lu.assertEquals(c:get_groups()[1].edges, 2 * 96 + 2 * 30)
end

function mod.TestLakeSplitByLandfillAndRejoined()
   local c = BC.BlockClusterer.new()
   local cells = {}
   for x = 0, 79 do
      for y = 10, 20 do
         cells[key(x, y)] = { x, y }
      end
   end
   load(c, cells, {})
   lu.assertEquals(#c:get_groups(), 1)

   -- Landfill a column across the lake, on a block border.
   local touched = {}
   for y = 10, 20 do
      cells[key(32, y)] = nil
      touch(touched, 32, y)
   end
   load(c, cells, touched)
   check(c, cells, "split")
   lu.assertEquals(#c:get_groups(), 2)

   -- Mine one landfill tile: water comes back and the halves join.
   cells[key(32, 15)] = { 32, 15 }
   load(c, cells, { [1] = { [0] = true } })
   check(c, cells, "rejoined")
   lu.assertEquals(#c:get_groups(), 1)

   -- Fill all of it.
   local all = {}
   for _, p in pairs(cells) do
      touch(all, p[1], p[2])
   end
   load(c, {}, all)
   lu.assertEquals(#c:get_groups(), 0)
end

function mod.TestUShapeJoinsInsideOneBlock()
   -- Two arms that meet only at the bottom row: labelling must merge runs seen as separate earlier.
   local c = BC.BlockClusterer.new()
   local cells = {}
   for y = 0, 9 do
      cells[key(2, y)] = { 2, y }
      cells[key(8, y)] = { 8, y }
   end
   for x = 2, 8 do
      cells[key(x, 10)] = { x, 10 }
   end
   load(c, cells, {})
   check(c, cells, "U")
   lu.assertEquals(#c:get_groups(), 1)
end

function mod.TestRandomAgainstFloodFill()
   for seed = 1, 12 do
      local r = rng(seed)
      local c = BC.BlockClusterer.new()
      local cells = {}
      -- A region over 4 by 4 blocks, including negative coordinates, at a density that makes many bodies.
      local density = 30 + r(50)
      for x = -48, 79 do
         for y = -40, 87 do
            if r(100) < density then cells[key(x, y)] = { x, y } end
         end
      end
      load(c, cells, {})
      check(c, cells, "seed " .. seed .. " initial")

      -- Rounds of random edits: rectangles cleared or filled, the way landfill and mining change tiles.
      for round = 1, 6 do
         local touched = {}
         for _ = 1, 3 do
            local x0, y0 = r(128) - 48, r(128) - 40
            local w, h = 1 + r(20), 1 + r(20)
            local fill = r(2) == 0
            for x = x0, x0 + w - 1 do
               for y = y0, y0 + h - 1 do
                  cells[key(x, y)] = fill and { x, y } or nil
                  touch(touched, x, y)
               end
            end
         end
         load(c, cells, touched)
         check(c, cells, "seed " .. seed .. " round " .. round)
      end
   end
end

function mod.TestUnchangedBlockStaysClean()
   local c = BC.BlockClusterer.new()
   local cells = { [key(1, 1)] = { 1, 1 } }
   load(c, cells, {})
   local groups = c:get_groups()
   load(c, cells, {})
   lu.assertTrue(c:get_groups() == groups, "setting the same rows again does not regroup")
end

function mod.TestPopcount()
   lu.assertEquals(BC.popcount(0), 0)
   lu.assertEquals(BC.popcount(0xFFFFFFFF), 32)
   lu.assertEquals(BC.popcount(0x80000001), 2)
end

return mod
