--[[
This is like the more generic clusterer, but for tiles.

To use it, call submit_points with a set of points whose coordinates are
integers.  It will combine them as they come in to form groups, and track the
current edges of those groups  so that we can find the closest points.  Repeated
tiles are acceptible but cause performance degradation (they are simply
ignored).

What makes this different from the generic clusterer is that by the nature of
the generic clusterer, the generic one is very slow on huge numbers of items.
Unlike resources, a single patch of water can literally reach hundreds of
thousands if not millions of tiles in some cases.  Representing this in a
spatial hash or quadtree or whatever the generic one happens to be using at the
time is very slow.

# Algorithm

Today in I wish this was easy.  What we want is a floodfill algorithm from any
tile to all others.  Before saying get_connected_tiles, this is also used for
trees.  We must collect all tiles, as well as detect all tiles without 4
neighbors.

What we have instead is an incremental list of points coming in in arbitrary
order.

There's a couple insights that can make that work anyway.

Let's start with edges.  There's 4 adjacent tiles to any stand-alone tile, and
at least 1 for any edge.  We can thus keep a counter for each tile which doesn't
have 4 adjacents, and decrement that counter every time another adjacent is
found; on the last, the tile can be removed from a list of edges.

The more complicated part is grouping.  We associate each tile with a group.
This is either an adjacent group if there is one, or a new single-tile group. We
refer to group by number, into a table of group objects; we'll explain why in a
second.

This means that up to 4 groups can merge.  We get the group ids from our uid
module, which means older groups are lower numbered.  We want a small number of
large groups, so we always use the oldest.  To merge any number of groups, we
merge their tile and edge lists, then mark the current tile and adjacents as in
that group.

But if that was it, then this would be easy.  Consider 4 groups of tiles, a, b,
c, and d.  A touches b and nothing else.  C touches d and nothing else.  Suppose
the groups come in a, d, c, b.

This means we will merge b into a.  We will merge d into c.

Now suppose a tile merges b and c.  We can't afford to go around and renumber
every tile we know about because that's O(N^2).  So fine, we put the tile in b
and merge c into b.  But that's wrong.  Why?  C merged into d, and b merged into
a.  B and C still exist, but a and d are the proper groups which have been
merged into--that is, b and c are out of date and do not know about those tiles.
That means we end up with extra groups just sitting around, and for example
you'd get 4 entries out the other side instead of 1 when it comes to e.g. the
scanner, where two of the entries "cover" parts of the larger ones, and two of
the entries are separate-but-not-actually groups.

So, we introduce a term: the canonical group.  In the above example, a is b's
canonical group.  A canonical group always has a lower number than the
non-canonical groups for which it may be canonical.  When merging two groups
together, the lower number group is the canonical group for the other group in
the merge.  Doing it this way ensures no cycles in the canonization lists
without having to check. We describe that now.

So here's the trick.  Each merge strictly increases the scope of both groups.
What we want to say is "fine, you might be b, but b became a because of a merge,
and contains at least everything b did".  To do that, we maintain a second table
mapping group numbers to their canonical group numbers.  To findf a canonical
group, we consult that table and walk it like a linked list.  It is entirely
possible to have d->c->b->a, if tiles are touched in the right order.

It might seem that we need to do cleanup.  We may, and that's definitely a
future direction.  But what actually happens is that each patch of whatever gets
one canonical group and, eventually after all are seen, "freezes".  At that
point the canonical group and all the "wasted" groups for that cluster are just
wasting memory, and no longer get touched because the clusterer is off handling
other clusters that don't touch it.  That means that on "normal" maps, the
linked list never gets too deep (is Seablock a problem? Probably-but Seablock is
always a problem).
]]
local TH = require("scripts.table-helpers")
local uid = require("scripts.uid").uid

local mod = {}

local ADJ_COORDS = {
   { -1, 0 },
   { 1, 0 },
   { 0, -1 },
   { 0, 1 },
}

---@class fa.ds.TileClusterer.Group
---@field tiles table<number, table<number, true>> All tiles in this group.
---@field edge_tiles table<number, table<number, true>> The tiles on the edge.

---@class fa.ds.TileClusterer.Options
---@field track_interior boolean if false, only fill out edges.

---@class fa.ds.TileClusterer
---@field seen_tiles table<number, table<number, number>> The number is a group index.
---@field groups table<number, fa.ds.TileClusterer.Group>
---@field canonical_linked_list table<number, number>
---@field edge_counters table<number, table<number, number>> Doesn't use defaulting_table.
---@field options fa.ds.TileClusterer.Options
local TileClusterer = {}
local TileClusterer_meta = { __index = TileClusterer }
if script then script.register_metatable("fa.ds.TileClusterer", TileClusterer_meta) end
mod.TileClusterer = TileClusterer

---@param opts fa.ds.TileClusterer.Options
function TileClusterer.new(opts)
   return setmetatable({
      seen_tiles = {},
      edge_counters = {},
      groups = {},
      canonical_linked_list = {},
      options = opts,
   }, TileClusterer_meta)
end

---@param group_number number
---@return number
function TileClusterer:walk_canonical_list(group_number)
   local old_group_number = group_number
   while group_number do
      old_group_number = group_number
      group_number = self.canonical_linked_list[group_number]
   end

   return old_group_number
end

---@param points fa.Point[]
function TileClusterer:submit_points(points)
   local seen_tiles = self.seen_tiles

   for i = 1, #points do
      local p = points[i]
      local point_x, point_y = p.x, p.y

      if seen_tiles[point_x] and seen_tiles[point_x][point_y] then goto continue end

      local adjacents = {}

      -- For each point, find all adjacent groups. If we have 4 it's a middle tile.
      -- If we have less than 4 then we need to add it to possible edges.
      for c_i = 1, #ADJ_COORDS do
         x_i, y_i = point_x + ADJ_COORDS[c_i][1], point_y + ADJ_COORDS[c_i][2]

         adjacents[c_i] = nil
         if seen_tiles[x_i] then adjacents[c_i] = seen_tiles[x_i][y_i] end
      end

      local adj_count = 0
      local merge_target_num = nil

      -- We will merge into the oldest adjacent group, under the hypothesis that
      -- it is the largest.
      for i = 1, 4 do
         local a = adjacents[i]
         if a then
            adj_count = adj_count + 1
            if not merge_target_num then
               merge_target_num = a
            else
               merge_target_num = math.min(merge_target_num, a)
            end
         end
      end

      -- If we found a merge target and this is not the canonical group, we will
      -- use the canonical group instead.
      if merge_target_num then merge_target_num = self:walk_canonical_list(merge_target_num) end

      local final_group_num
      local final_group_obj

      -- If we aren't merging into anything, we create a new group with only
      -- this tile in it, marking this tile as an edge as well.
      if not merge_target_num then
         final_group_obj = {
            tiles = { [point_x] = { [point_y] = true } },
            edge_tiles = { [point_x] = { [point_y] = true } },
         }
         final_group_num = uid()
         self.groups[final_group_num] = final_group_obj
      else
         final_group_num = merge_target_num
         final_group_obj = self.groups[final_group_num]

         -- We have to merge. To do so, merge into the merge target and then
         -- replace the other indices after.
         local did = {}

         for i = 1, 4 do
            local src = adjacents[i]
            src = self:walk_canonical_list(src)

            -- Never into itself.
            if src and src ~= merge_target_num and not did[src] then
               did[src] = true

               local src_obj = self.groups[src]
               local merge_into = self.groups[merge_target_num]

               -- This is the magic optimization for edges. We allow single tile
               -- groups but just drop them when merging up.
               if self.options.track_interior then
                  for x, ty in pairs(src_obj.tiles) do
                     for y in pairs(ty) do
                        local xt = merge_into.tiles[x]
                        if not xt then
                           xt = {}
                           merge_into.tiles[x] = xt
                        end
                        xt[y] = true
                     end
                  end
               end

               for x, ty in pairs(src_obj.edge_tiles) do
                  for y in pairs(ty) do
                     local xt = merge_into.edge_tiles[x]
                     if not xt then
                        xt = {}
                        merge_into.edge_tiles[x] = xt
                     end
                     xt[y] = true
                  end
               end
            end
         end
      end

      -- We now know enough to make this tile seen.
      do
         local sx = seen_tiles[point_x]
         if sx then
            sx[point_y] = final_group_num
         else
            seen_tiles[point_x] = { [point_y] = final_group_num }
         end
      end

      -- Same, but for getting ourself into our own group.
      if self.options.track_interior then
         local t = final_group_obj.tiles[point_x]
         if not t then
            t = {}
            final_group_obj.tiles[point_x] = t
         end
         t[point_y] = true
      end

      -- We now have a target group and count of adjacents.  This tile might be
      -- an edge if there weren't 4 adjacents. If so, remember that.
      if adj_count < 4 then
         local ec = self.edge_counters[point_x]
         if not ec then
            ec = { [point_y] = 4 - adj_count }
            self.edge_counters[point_x] = ec
         else
            ec[point_y] = 4 - adj_count
         end

         -- And the group.
         local ec = final_group_obj.edge_tiles[point_x]
         if not ec then
            ec = { [point_y] = true }
            final_group_obj.edge_tiles[point_x] = ec
         else
            ec[point_y] = true
         end
      end

      -- Next up: subtract 1 from all counters, if present, for our 4 adjacents,
      -- and see what falls out as not edges.
      for c_i = 1, #ADJ_COORDS do
         local x_i, y_i = point_x + ADJ_COORDS[c_i][1], point_y + ADJ_COORDS[c_i][2]

         local xt = self.edge_counters[x_i]
         if xt then
            if xt[y_i] then
               xt[y_i] = xt[y_i] - 1
               if xt[y_i] < 1 then
                  xt[y_i] = nil
                  assert(final_group_obj.edge_tiles[x_i][y_i])
                  final_group_obj.edge_tiles[x_i][y_i] = nil
               end
            end
         end
      end

      for c_i = 1, #ADJ_COORDS do
         local i_x, i_y = point_x + ADJ_COORDS[c_i][1], point_y + ADJ_COORDS[c_i][2]
         local a_x = seen_tiles[i_x]
         if a_x then
            -- We must have seen it already. If there's no tile here yet
            -- there's nothing to have merged with.
            if a_x[i_y] then
               -- Anything in the other group was merged to this one, so replace
               -- the group then mark the old group as no longer canonical.
               local other = a_x[i_y]
               -- No cycles.
               if other ~= final_group_num then self.canonical_linked_list[a_x[i_y]] = final_group_num end
               a_x[i_y] = final_group_num
            end
         end
      end

      ::continue::
   end
end

-- Iterate over all current groups, calling the closure on each.
---@param callback fun(group: fa.ds.TileClusterer.Group)
function TileClusterer:get_groups(callback)
   local seen = {}

   for num_old in pairs(self.groups) do
      num = self:walk_canonical_list(num_old)
      -- Very quick cleanup: nothing consults non-canonical groups and this is
      -- free.
      if num < num_old then self.groups[num_old] = nil end
      local candidate = self.groups[num]
      if not seen[candidate] then
         seen[candidate] = true
         callback(candidate)
      end
   end
end

return mod
