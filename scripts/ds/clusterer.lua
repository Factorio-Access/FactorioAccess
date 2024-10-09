--[[
A sort of spatial hash, which takes *points* and groups them together based on a
given approximated radius.  Each point may have data associated.

This is intended to scale very far, and consequently does not store all points.
Instead, this also takes a "fold" function which will be called `fold(cluster,
cluster)` where cluster is whatever the last fold folded.  The lowest level fold
will fold two points, so the inputted associated data should be a single-point
cluster.

Like with other problematic Factorio issues, what actually happens is you call
`declare_clusterer` which returns a function that can manufacture clusterers.
This "early-binds" the callbacks.  Other options are then passed to the
function.  See the scanner for a concrete example.

This data structure maintains the bounding box for you.  Don't do that yourself.
it doesn't maintain the center position for you.  You have to do that yourself.
This is because center has a fuzzy meaning: it could be center of the box, but
also "highest point" e.g. most iron in an iron ore patch.

For now the returned bounding boxes are dilated to integral coordinates and
assume that entities fit in one tile.  We can lift that restriction in future if
needed, but that can just be cheaply accounted for by increasing search bradii.

IMPORTANT: the implementation owns the writes.  The returned data when doing
queries must be treated as immutable.  The data structure doesn't write in place
save for `logical_delete`, so returned clusters may be valid but out of date if
they're kept around.

What comes out is:

```
{
   aabb = { left_top = { x, y }, right_bottom = { x, y } },
   -- The aabb plus the search radius on all sides.
   dilated_aabb = { aabb },
   cluster = your folded data,
}
```

# Implementation

This is surprisingly simple:

- Single points are clusters, dilated by the search radius.
- Clusters are stored in a spatial hash.
- When a new point arrives, it's dilated and any other clusters which it may
  bucket with are consulted to see if it belongs in one or more of them.
- If it belongs in one, it's merged with that one.
- If it belongs in more than one, all are folded and then the point gets merged
  in.

For fast removal wee use the Lua trick of putting the data in keys and using
`true` as the value so that we need only set keys to nil to remove.

The one trick is that removal must account for things which are in more buckets
than were iterated when merging the last point. To do this, we clean up when the
user requests all of the clusters since that must iterate over all buckets
anyway, and mark things as logically deleted which is O(1).

The clusterer gets "bound" callbacks via an augmented metatable which knows how
to return the right indices through "magic", namely nested metatables, usually
used to implement inheritance.  We lie to LuaLS a little bit as to where we add
the keys and then this all works out. (TODO: we should document these patterns
somewhere)

This doesn't really scale quite as far as tiles. For tiles or anything which can
be reduced to such, see tile-clusterer.lua.
]]
local TH = require("scripts.table-helpers")

local mod = {}

---@class fa.ds.clusterer.Item
---@field aabb fa.AABB
---@field dilated_aabb fa.AABB includes the magnification due to the search radius
---@field data any
---@field logical_delete boolean

---@class fa.ds.clusterer.Bucket
---@field items table<fa.ds.clusterer.Item, true>

---@class fa.ds.Clusterer
---@field buckets table<number, table<number, fa.ds.clusterer.Bucket>>
---@field search_radius number
---@field bucket_size number cached search_radius * 2
---@field fold fun(a: any, b: any): any
local Clusterer = {}
-- We don't declare or register a metatable right now.  Instead,
-- declare_clusterer does it later, injecting `fold`.

-- Cached for perf
local floor = math.floor
local min = math.min
local max = math.max

-- Return (x_low, y_low, x_high, y_high) For all the buckets covered by a
-- bounding box x1 y1 to x2 y2.  We do it this way to avoid tons of hash
-- lookups, without having to inline this logic by hand in many places.
--
---@return number, number, number, number
local function aabb_bucket_ranges(x1, y1, x2, y2, bucket_size)
   -- The math is simple: the low buckets are the bucket of the first point, the high buckets of the second point, then the caller loops.
   return floor(x1 / bucket_size), floor(y1 / bucket_size), floor(x2 / bucket_size), floor(y2 / bucket_size)
end

local function merge_aabbs(b1, b2)
   local b1tl = b1.left_top
   local b2tl = b2.left_top
   local b1br = b1.right_bottom
   local b2br = b2.right_bottom
   return {
      left_top = { x = min(b1tl.x, b2tl.x), y = min(b1tl.y, b2tl.y) },
      right_bottom = { x = max(b1br.x, b2br.x), y = max(b1br.y, b2br.y) },
   }
end

---@param x number
---@param y number
---@param data any
function Clusterer:insert(x, y, data)
   -- This is the function which drives the whole thing even though it doesn't
   -- look like it from the interface perspective.  The only time two clusters
   -- can merge is on a new point, when that point lands in both.

   -- Cache for performance.

   local sr = self.search_radius

   -- Step 1: given the new point find anything which might overlap it.
   local x1b, y1b, x2b, y2b = aabb_bucket_ranges(x - sr, y - sr, x + sr, y + sr, self.bucket_size)

   --[[
   step 2: do folds, if needed.

   Don't forget: things can be in more than one bucket, thus logical deletion.
   ]]

   ---@type fa.ds.clusterer.Item
   local prev
   do
      local fx, fy = floor(x), floor(y)
      prev = {
         aabb = {
            left_top = { x = fx, y = fy },
            right_bottom = { x = fx + 1, y = fy + 1 },
         },
         dilated_aabb = {
            left_top = { x = x - sr, y = y - sr },
            right_bottom = { x = x + sr, y = y + sr },
         },
         logical_delete = false,
         data = data,
      }
   end

   for xbi = x1b, x2b do
      for ybi = y1b, y2b do
         local bucket = self.buckets[xbi][ybi]
         if not bucket then goto continue end
         for item in pairs(bucket.items) do
            if item.logical_delete then
               -- We can do some of the cleanup here. This will usually hit
               -- everything.
               bucket.items[item] = nil
               goto continue
            end

            -- We may merge if the point is inside the dilated AABB
            local dab = item.dilated_aabb
            local tl, br = dab.left_top, dab.right_bottom
            local tlx, tly = tl.x, tl.y
            local brx, bry = br.x, br.y

            local inbox = tlx <= x and tly <= y and brx >= x and bry >= y
            if inbox then
               -- Remove this entry, then fold it with prev.  The final folded
               -- cluster will go back in later on.  Also mark it logically
               -- deleted, as it may be in buckets we aren't iterating over.
               bucket.items[item] = nil
               item.logical_delete = true
               pdata = self.fold(prev.data, item.data)

               prev.aabb = merge_aabbs(prev.aabb, item.aabb)
               prev.dilated_aabb = merge_aabbs(prev.dilated_aabb, item.dilated_aabb)
               prev.data = pdata
            end
            ::continue::
         end

         ::continue::
      end
   end

   -- Now we must put prev back in all buckets.
   local lx, ly, hx, hy = aabb_bucket_ranges(
      prev.dilated_aabb.left_top.x,
      prev.dilated_aabb.left_top.y,
      prev.dilated_aabb.right_bottom.x,
      prev.dilated_aabb.right_bottom.y,
      self.bucket_size
   )
   for i = lx, hx do
      for j = ly, hy do
         local bx = self.buckets[i]
         local b = bx[j]
         if not b then
            b = { items = {} }
            bx[j] = b
         end
         b.items[prev] = true
      end
   end
end

-- Call a closure over all entries in this clusterer.
--
-- It might seem as if we'd want an iterator, but an iterator over a table of
-- tables without coroutines is hard to get right and the heavy work was done
-- when inserting points.  This is also used to do some cleanup work.
---@param callback fun(item: fa.ds.clusterer.Item)
function Clusterer:get_clusters(callback)
   local seen = {}
   for _, buckets in pairs(self.buckets) do
      for _, bucket in pairs(buckets) do
         for i in pairs(bucket.items) do
            if i.logical_delete then
               bucket.items[i] = nil
            elseif not seen[i] then
               callback(i)
               seen[i] = true
            end
         end
      end
   end
end

---@class fa.ds.clusterer.DeclarationOpts
---@field fold fun(a: any, b: any): any

local declared_names = {}

---@param name string
---@param opts fa.ds.clusterer.DeclarationOpts
---@return fun(search_radius: number, bucket_size: number?): fa.ds.Clusterer
function mod.declare_clusterer(name, opts)
   assert(not declared_names[name], "Attempt to declare two clusteres with the name " .. name)
   declared_names[name] = true

   local newmeta = TH.nested_indexer(Clusterer, { fold = opts.fold })
   if script then script.register_metatable(name, newmeta) end

   return function(search_radius, bucket_size)
      local state = {
         search_radius = search_radius,
         bucket_size = bucket_size or search_radius * 2,
         buckets = TH.defaulting_table(),
      }

      setmetatable(state, newmeta)
      return state
   end
end

-- The self tests below are expensive. Comment the following line to run them.
-- Note they require hand-examining output.
-- stylua: ignore
do return mod end

local serpent = require("serpent")

local fac1 = mod.declare_clusterer("fac1", {
   fold = function(a, b)
      return a + b
   end,
})
local c1 = fac1(10)

c1:insert(0, 0, 1)
c1:insert(5, 0, 1)
c1:insert(100, 100, 1)

local got = {}
c1:get_clusters(function(x)
   assert(x)
   table.insert(got, x)
end)

--@param a fa.ds.clusterer.Item
---@param b fa.ds.clusterer.Item
function xycomp(a, b)
   if a.aabb.left_top.x < b.aabb.left_top.x then return true end
   return a.aabb.left_top.x == b.aabb.left_top.x and a.aabb.left_top.y < b.aabb.left_top.y
end

table.sort(got, xycomp)

print(serpent.line(got, { comment = false }))

return mod
