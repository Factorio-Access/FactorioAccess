--[[
Groups the set cells of an unbounded integer grid into 4-connected groups ("bodies"), or 8-connected ones (cells
touching at a corner join too) when made with diagonal = true, with cells added and removed at any time. Used for bodies of tiles (a cell is a tile) and forests (a cell is a square of tiles with a
tree in it).

# Layout

The grid is cut into blocks of 32 by 32 cells. A block is 32 row masks, one bit per cell: bit x of row y is the
cell at (bx * 32 + x, by * 32 + y). For tiles a block is exactly a Factorio chunk. The block masks are the only
source of truth; everything else is derived from them and rebuilt when they change.

# Algorithm

1. Inside a block, cells are labelled into components with run-length labelling: each row splits into runs of
   set bits, and a run joins every run of the row above that shares a column. That costs per run, not per cell:
   a full row is one run. A component keeps its rows, bounding box, cell and edge counts, and four border masks
   saying which of its cells touch each side of the block. A component spans every row between its first and
   last (it is connected), so its rows are a dense array.
2. The bodies are a union-find over components, never cells: two components in neighbouring blocks join when
   their facing border masks share a bit. With a few thousand components this is cheap enough to redo from
   scratch whenever anything changed, which is what makes removal free: there is nothing to undo.

An edge cell is a set cell with fewer than 4 set neighbours (all set neighbours are in its own body). Cells across
a block border count when that block exists, so a block's edge counts are relabelled when a neighbour changes.

Changing a block marks it and its 4 neighbours dirty; dirty blocks are relabelled and the bodies regrouped
lazily, on the next get_groups.
]]
local band, bor, bnot, lshift, rshift = bit32.band, bit32.bor, bit32.bnot, bit32.lshift, bit32.rshift

local mod = {}

local BLOCK_SIZE = 32
mod.BLOCK_SIZE = BLOCK_SIZE

local FULL_ROW = 0xFFFFFFFF
local TOP_BIT = 0x80000000

-- BIT_INDEX[2^i] = i. 2^32 is there for a run that ends at bit 31: the carry past it.
---@type table<number, integer>
local BIT_INDEX = {}
for i = 0, 32 do
   BIT_INDEX[2 ^ i] = i
end

local POPCOUNT8 = {}
for i = 0, 255 do
   local c, v = 0, i
   while v > 0 do
      c = c + v % 2
      v = math.floor(v / 2)
   end
   POPCOUNT8[i] = c
end

---@param m integer
---@return integer
local function popcount(m)
   return POPCOUNT8[band(m, 0xFF)]
      + POPCOUNT8[band(rshift(m, 8), 0xFF)]
      + POPCOUNT8[band(rshift(m, 16), 0xFF)]
      + POPCOUNT8[rshift(m, 24)]
end
mod.popcount = popcount

---@class fa.ds.BlockClusterer.Component
---@field bx integer
---@field by integer
---@field y0 integer First row, block-local
---@field x0 integer Block-local bounding box columns
---@field x1 integer
---@field rows integer[] Masks of rows y0 up, dense
---@field cells integer
---@field edges integer Edge cells
---@field n integer Border masks: n and s are row masks, w and e have bit y for row y
---@field s integer
---@field w integer
---@field e integer

---@class fa.ds.BlockClusterer.Block
---@field rows integer[] 32 row masks
---@field comps fa.ds.BlockClusterer.Component[]

---@class fa.ds.BlockClusterer.Group
---@field comps fa.ds.BlockClusterer.Component[]
---@field x0 integer Bounding box in cells, inclusive
---@field y0 integer
---@field x1 integer
---@field y1 integer
---@field cells integer
---@field edges integer

---@class fa.ds.BlockClusterer
---@field diagonal boolean Cells touching at a corner join; edge cells are still counted by their 4 neighbours
---@field blocks table<integer, table<integer, fa.ds.BlockClusterer.Block>>
---@field dirty table<integer, table<integer, true>>
---@field groups fa.ds.BlockClusterer.Group[]? Nil when stale
local BlockClusterer = {}
local BlockClusterer_meta = { __index = BlockClusterer }
-- script is nil under plain Lua, outside Factorio
---@diagnostic disable-next-line: unnecessary-if
if script then script.register_metatable("fa.ds.BlockClusterer", BlockClusterer_meta) end
mod.BlockClusterer = BlockClusterer

---@param opts { diagonal: boolean? }?
---@return fa.ds.BlockClusterer
function BlockClusterer.new(opts)
   local diagonal = opts and opts.diagonal or false
   return setmetatable({ diagonal = diagonal, blocks = {}, dirty = {}, groups = nil }, BlockClusterer_meta)
end

-- A mask widened by one bit each way: what a run or border touches when corners count.
---@param m integer
---@return integer
local function widen(m)
   return bor(m, lshift(m, 1), rshift(m, 1))
end

---@return integer[]
function mod.empty_rows()
   local rows = {}
   for i = 1, BLOCK_SIZE do
      rows[i] = 0
   end
   return rows
end

---@param bx integer
---@param by integer
---@return fa.ds.BlockClusterer.Block?
function BlockClusterer:get_block(bx, by)
   local col = self.blocks[bx]
   return col and col[by]
end

-- The block's row masks (row y of the block is rows[y + 1]), or nil for an empty block. Do not modify them.
---@param bx integer
---@param by integer
---@return integer[]?
function BlockClusterer:get_rows(bx, by)
   local b = self:get_block(bx, by)
   return b and b.rows
end

---@param bx integer
---@param by integer
function BlockClusterer:mark_dirty(bx, by)
   local col = self.dirty[bx]
   if not col then
      col = {}
      self.dirty[bx] = col
   end
   col[by] = true
end

-- Replace a block's cells. rows is 32 row masks (row y at rows[y + 1]) and is kept, so the caller must not modify
-- it afterwards. All-zero rows, or nil, remove the block.
---@param bx integer
---@param by integer
---@param rows integer[]?
function BlockClusterer:set_block(bx, by, rows)
   local empty = true
   if rows then
      for i = 1, BLOCK_SIZE do
         if rows[i] ~= 0 then
            empty = false
            break
         end
      end
   end

   local old = self:get_block(bx, by)
   if empty then
      if not old then return end
      self.blocks[bx][by] = nil
      if not next(self.blocks[bx]) then self.blocks[bx] = nil end
   else
      ---@cast rows integer[]
      if old then
         local same = true
         for i = 1, BLOCK_SIZE do
            if old.rows[i] ~= rows[i] then
               same = false
               break
            end
         end
         if same then return end
         old.rows = rows
         old.comps = {}
      else
         local col = self.blocks[bx]
         if not col then
            col = {}
            self.blocks[bx] = col
         end
         col[by] = { rows = rows, comps = {} }
      end
   end

   self:mark_dirty(bx, by)
   self:mark_dirty(bx - 1, by)
   self:mark_dirty(bx + 1, by)
   self:mark_dirty(bx, by - 1)
   self:mark_dirty(bx, by + 1)
   self.groups = nil
end

-- Edge masks of a block (row y at [y + 1]): set cells with fewer than 4 set neighbours, looking into the
-- neighbouring blocks at the borders.
---@param bx integer
---@param by integer
---@return integer[]
function BlockClusterer:block_edges(bx, by)
   local rows = assert(self:get_rows(bx, by))
   local north = self:get_rows(bx, by - 1)
   local south = self:get_rows(bx, by + 1)
   local west = self:get_rows(bx - 1, by)
   local east = self:get_rows(bx + 1, by)
   local edges = {}

   for i = 1, BLOCK_SIZE do
      local row = rows[i]
      if row == 0 then
         edges[i] = 0
      else
         local up = i > 1 and rows[i - 1] or (north and north[BLOCK_SIZE] or 0)
         local down = i < BLOCK_SIZE and rows[i + 1] or (south and south[1] or 0)
         -- Bit x of left says whether cell x - 1 is set; of right, cell x + 1.
         local left = lshift(row, 1)
         if west and band(west[i], TOP_BIT) ~= 0 then left = bor(left, 1) end
         local right = rshift(row, 1)
         if east and band(east[i], 1) ~= 0 then right = bor(right, TOP_BIT) end
         edges[i] = band(row, bnot(band(up, down, left, right)))
      end
   end

   return edges
end

-- Label a block's components, with their edge counts.
---@param bx integer
---@param by integer
---@param block fa.ds.BlockClusterer.Block
local function label_block(self, bx, by, block)
   local rows = block.rows
   local edges = self:block_edges(bx, by)

   -- A full block is one component whose rows are the block's own.
   local full = true
   for i = 1, BLOCK_SIZE do
      if rows[i] ~= FULL_ROW then
         full = false
         break
      end
   end
   if full then
      local edge_count = 0
      for i = 1, BLOCK_SIZE do
         edge_count = edge_count + popcount(edges[i])
      end
      block.comps = {
         {
            bx = bx,
            by = by,
            y0 = 0,
            x0 = 0,
            x1 = BLOCK_SIZE - 1,
            rows = rows,
            cells = BLOCK_SIZE * BLOCK_SIZE,
            edges = edge_count,
            n = FULL_ROW,
            s = FULL_ROW,
            w = FULL_ROW,
            e = FULL_ROW,
         },
      }
      return
   end

   -- Runs: their row, mask and union-find parent, numbered in row order.
   ---@type integer[]
   local run_y = {}
   ---@type integer[]
   local run_mask = {}
   ---@type integer[]
   local parent = {}
   local n_runs = 0
   local prev_first, prev_last = 1, 0
   local diagonal = self.diagonal

   ---@param r integer
   ---@return integer
   local function find(r)
      local p = parent[r]
      while p ~= r do
         local gp = parent[p]
         parent[r] = gp
         r, p = p, gp
      end
      return r
   end

   for i = 1, BLOCK_SIZE do
      local m = rows[i]
      local first = n_runs + 1
      while m ~= 0 do
         -- Adding the lowest set bit carries through the lowest run; and-ing with the sum clears that run.
         local rest = band(m, m + band(m, -m))
         local run = m - rest
         n_runs = n_runs + 1
         run_y[n_runs] = i
         run_mask[n_runs] = run
         parent[n_runs] = n_runs
         local reach = diagonal and widen(run) or run
         for p = prev_first, prev_last do
            if band(reach, run_mask[p]) ~= 0 then
               local a, b = find(n_runs), find(p)
               if a ~= b then
                  -- The older run's root wins, so roots are each component's first run.
                  if a < b then
                     parent[b] = a
                  else
                     parent[a] = b
                  end
               end
            end
         end
         m = rest
      end
      prev_first, prev_last = first, n_runs
   end

   local comps = {}
   local by_root = {}
   for r = 1, n_runs do
      local root = find(r)
      local comp = by_root[root]
      local y = run_y[r] - 1
      local mask = run_mask[r]
      local low = band(mask, -mask)
      local rx0 = BIT_INDEX[low]
      local rx1 = BIT_INDEX[mask + low] - 1
      if not comp then
         comp = {
            bx = bx,
            by = by,
            y0 = y,
            x0 = rx0,
            x1 = rx1,
            rows = {},
            cells = 0,
            edges = 0,
            n = 0,
            s = 0,
            w = 0,
            e = 0,
         }
         by_root[root] = comp
         comps[#comps + 1] = comp
      end
      local ri = y - comp.y0 + 1
      comp.rows[ri] = bor(comp.rows[ri] or 0, mask)
      if rx0 < comp.x0 then comp.x0 = rx0 end
      if rx1 > comp.x1 then comp.x1 = rx1 end
      comp.cells = comp.cells + rx1 - rx0 + 1
      comp.edges = comp.edges + popcount(band(mask, edges[y + 1]))
      if y == 0 then comp.n = bor(comp.n, mask) end
      if y == BLOCK_SIZE - 1 then comp.s = bor(comp.s, mask) end
      if rx0 == 0 then comp.w = bor(comp.w, lshift(1, y)) end
      if rx1 == BLOCK_SIZE - 1 then comp.e = bor(comp.e, lshift(1, y)) end
   end

   block.comps = comps
end

local function relabel_dirty(self)
   for bx, col in pairs(self.dirty) do
      for by in pairs(col) do
         local block = self:get_block(bx, by)
         if block then label_block(self, bx, by, block) end
      end
   end
   self.dirty = {}
end

local function regroup(self)
   ---@type table<fa.ds.BlockClusterer.Component, fa.ds.BlockClusterer.Component>
   local parent = {}

   local function find(c)
      local p = parent[c]
      while p ~= c do
         local gp = parent[p]
         parent[c] = gp
         c, p = p, gp
      end
      return c
   end

   local function union(a, b)
      a, b = find(a), find(b)
      if a ~= b then parent[b] = a end
   end

   local blocks = self.blocks
   ---@type fa.ds.BlockClusterer.Component[]
   local all = {}
   for _, col in pairs(blocks) do
      for _, block in pairs(col) do
         for _, c in ipairs(block.comps) do
            parent[c] = c
            all[#all + 1] = c
         end
      end
   end

   local diagonal = self.diagonal
   for bx, col in pairs(blocks) do
      local east_col = blocks[bx + 1]
      local west_col = blocks[bx - 1]
      for by, block in pairs(col) do
         local east = east_col and east_col[by]
         local south = col[by + 1]
         -- Blocks meeting this one only at a corner, below it: their components join through the corner cells.
         local south_east = diagonal and east_col and east_col[by + 1]
         local south_west = diagonal and west_col and west_col[by + 1]
         for _, a in ipairs(block.comps) do
            if east and a.e ~= 0 then
               local reach = diagonal and widen(a.e) or a.e
               for _, b in ipairs(east.comps) do
                  if band(reach, b.w) ~= 0 then union(a, b) end
               end
            end
            if south and a.s ~= 0 then
               local reach = diagonal and widen(a.s) or a.s
               for _, b in ipairs(south.comps) do
                  if band(reach, b.n) ~= 0 then union(a, b) end
               end
            end
            if south_east and band(a.s, TOP_BIT) ~= 0 then
               for _, b in ipairs(south_east.comps) do
                  if band(b.n, 1) ~= 0 then union(a, b) end
               end
            end
            if south_west and band(a.s, 1) ~= 0 then
               for _, b in ipairs(south_west.comps) do
                  if band(b.n, TOP_BIT) ~= 0 then union(a, b) end
               end
            end
         end
      end
   end

   local groups = {}
   ---@type table<fa.ds.BlockClusterer.Component, fa.ds.BlockClusterer.Group>
   local by_root = {}
   for _, c in ipairs(all) do
      local root = find(c)
      local g = by_root[root]
      local ox, oy = c.bx * BLOCK_SIZE, c.by * BLOCK_SIZE
      local x0, x1 = ox + c.x0, ox + c.x1
      local y0, y1 = oy + c.y0, oy + c.y0 + #c.rows - 1
      if not g then
         g = { comps = {}, x0 = x0, y0 = y0, x1 = x1, y1 = y1, cells = 0, edges = 0 }
         by_root[root] = g
         groups[#groups + 1] = g
      else
         if x0 < g.x0 then g.x0 = x0 end
         if y0 < g.y0 then g.y0 = y0 end
         if x1 > g.x1 then g.x1 = x1 end
         if y1 > g.y1 then g.y1 = y1 end
      end
      g.comps[#g.comps + 1] = c
      g.cells = g.cells + c.cells
      g.edges = g.edges + c.edges
   end

   self.groups = groups
end

-- The current bodies. The array and the groups in it are valid until the next change; do not modify them.
---@return fa.ds.BlockClusterer.Group[]
function BlockClusterer:get_groups()
   if next(self.dirty) then
      relabel_dirty(self)
      self.groups = nil
   end
   if not self.groups then regroup(self) end
   return assert(self.groups)
end

-- The edge cell of a group closest to the point (in cell units; cell x spans x to x + 1), by distance to the
-- cell's centre. Only the components that could hold a closer cell are looked at.
---@param group fa.ds.BlockClusterer.Group
---@param px number
---@param py number
---@return number x, number y Integers: the cell
function BlockClusterer:closest_edge(group, px, py)
   local candidates = {}
   for i, c in ipairs(group.comps) do
      local ox, oy = c.bx * BLOCK_SIZE, c.by * BLOCK_SIZE
      local x0, x1 = ox + c.x0, ox + c.x1 + 1
      local y0, y1 = oy + c.y0, oy + c.y0 + #c.rows
      local dx = px < x0 and x0 - px or (px > x1 and px - x1 or 0)
      local dy = py < y0 and y0 - py or (py > y1 and py - y1 or 0)
      candidates[i] = { d = dx * dx + dy * dy, c = c }
   end
   if #candidates > 1 then table.sort(candidates, function(a, b)
      return a.d < b.d
   end) end

   -- A body always has an edge cell, so these are always replaced.
   ---@type number, number, number
   local best, best_x, best_y = math.huge, 0, 0
   local edges_by_block = {}
   local tx = math.floor(px) --[[@as integer]]

   for _, cand in ipairs(candidates) do
      -- A cell centre is at least half a cell inside its component's box, so this bound is safe.
      if cand.d >= best then break end
      local c = cand.c
      local key = c.bx .. "," .. c.by
      local edges = edges_by_block[key]
      if not edges then
         edges = self:block_edges(c.bx, c.by)
         edges_by_block[key] = edges
      end
      local ox, oy = c.bx * BLOCK_SIZE, c.by * BLOCK_SIZE
      for i, row in ipairs(c.rows) do
         local y = oy + c.y0 + i - 1
         local dy = y + 0.5 - py
         local dy2 = dy * dy
         if dy2 < best then
            local m = band(row, edges[c.y0 + i])
            while m ~= 0 do
               local rest = band(m, m + band(m, -m))
               local run = m - rest
               local low = band(run, -run)
               local s = ox + BIT_INDEX[low]
               local e = ox + BIT_INDEX[run + low] - 1
               local x = tx < s and s or (tx > e and e or tx)
               local dx = x + 0.5 - px
               local d = dx * dx + dy2
               if d < best then
                  best, best_x, best_y =
                     d,
                     x, --[[@as integer]]
                     y --[[@as integer]]
               end
               m = rest
            end
         end
      end
   end

   return best_x, best_y
end

-- Turn cell positions into block rows: { [bx] = { [by] = rows } }, for building blocks from scratch.
---@param points { x: integer, y: integer }[]
---@return table<integer, table<integer, integer[]>>
function mod.rows_from_points(points)
   local out = {}
   for i = 1, #points do
      local p = points[i]
      local bx, by = math.floor(p.x / BLOCK_SIZE), math.floor(p.y / BLOCK_SIZE)
      local col = out[bx]
      if not col then
         col = {}
         out[bx] = col
      end
      local rows = col[by]
      if not rows then
         rows = mod.empty_rows()
         col[by] = rows
      end
      local ri = p.y - by * BLOCK_SIZE + 1
      rows[ri] = bor(rows[ri], lshift(1, p.x - bx * BLOCK_SIZE))
   end
   return out
end

return mod
