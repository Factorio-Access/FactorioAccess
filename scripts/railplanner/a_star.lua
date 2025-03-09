local util = require("util")
local geometries = require("rail-data")
local dirs16 = require("dirs")

local PriorityQueue = require("priorityqueue")

local mod = {}

local max_elevated_height = 3

local mod_dir = dirs16.south * 2

local colors = {
   [0] = { 0, 0, 1 },
   [3] = { 0.5, 0, 0.5 },
}

---rotates the point around the origin by 90 degree increments.
---@param point MapPosition
---@param dir dirs16
---@return MapPosition
local function rotate_point_origin(point, dir)
   dir = dir % mod_dir
   if dir == dirs16.north then
      return { point[1], point[2] }
   elseif dir == dirs16.east then
      return { -point[2], point[1] }
   elseif dir == dirs16.south then
      return { -point[1], -point[2] }
   elseif dir == dirs16.west then
      return { point[2], -point[1] }
   end
   error("passed invalid direction:" .. str(point))
end

---converts a mod 2 position and direction requirement to an integer
---@param req RailGeometry.ends.end
---@return integer
local function abstract_requirement(req)
   return req.dir % mod_dir * 4 + req.pos[1] % 2 * 2 + req.pos[2] % 2
end

---@class node_edge
---The direction from which this node edge is allowed.
---@field pos_change MapPosition
---@field elevation_change integer
---@field dir_change dirs16
---@field key_change integer
---the rail prototype type that can create this node_edge
---@field prototype string
---the direction that the entity needs to take
---@field ent_dir dirs16
---The position the entity needs to be placed relative to current
---@field ent_pos_offset MapPosition
---@field cost number
---the category of the next node
---@field after integer

---returns a unique integer for a given position assuming MapPosition is within 4194304 of the origin
---@param pos MapPosition
---@param dir dirs16
---@param elevation integer
---@return integer
local function location_key(pos, dir, elevation)
   return ((dir % mod_dir * 4 + elevation) * 8388608 + pos[1] + 4194304) * 8388608 + pos[2] + 4194304
end

---returns an integer that can be added to a location key to get another key
---@param pos MapPosition
---@param dir dirs16
---@param elevation integer
---@return integer
local function location_diff(pos, dir, elevation)
   return ((dir % mod_dir * 4 + elevation) * 8388608 + pos[1]) * 8388608 + pos[2]
end

---@type table<integer,node_edge[]>
local edges_by_abstract_req = {}

---adds a new edge based on the geometry
---@param geo RailGeometry
local function add_geo_as_edge(geo)
   local a = geo.ends.entrance
   local b = geo.ends.exit
   local start_req = abstract_requirement({
      dir = a.dir,
      pos = { a.pos[1] + geo.mod_pos[1], a.pos[2] + geo.mod_pos[2] },
   })
   local end_req = abstract_requirement({
      dir = b.dir,
      pos = { b.pos[1] + geo.mod_pos[1], b.pos[2] + geo.mod_pos[2] },
   })
   ---@type node_edge
   local e = {
      pos_change = { b.pos[1] - a.pos[1], b.pos[2] - a.pos[2] },
      dir_change = (b.dir - a.dir) % mod_dir,
      elevation_change = geo.elevation_gain,
      key_change = 0,
      prototype = geo.prototype,
      ent_dir = geo.dir,
      ent_pos_offset = { -a.pos[1], -a.pos[2] },
      cost = geo.distance,
      after = end_req,
   }
   e.key_change = location_diff(e.pos_change, e.dir_change, e.elevation_change)
   edges_by_abstract_req[start_req] = edges_by_abstract_req[start_req] or {}
   table.insert(edges_by_abstract_req[start_req], e)
end

---expands a geometry to all valid rotations
---@param geo RailGeometry
local function expand_geometry_rotate(geo)
   local end_rotation = dirs16.west
   if geo.two_way_rotational_symmetry then end_rotation = dirs16.east end
   for rotation = dirs16.north, end_rotation, dirs16.east do
      local r_geo = table.deepcopy(geo)
      r_geo.dir = (r_geo.dir + rotation) % mod_dir
      r_geo.ends.entrance = {
         pos = rotate_point_origin(geo.ends.entrance.pos, rotation),
         dir = (geo.ends.entrance.dir + rotation) % mod_dir,
      }
      r_geo.ends.exit = {
         pos = rotate_point_origin(geo.ends.exit.pos, rotation),
         dir = (geo.ends.exit.dir + rotation) % mod_dir,
      }
      if rotation % dirs16.south == dirs16.east then r_geo.mod_pos = { r_geo.mod_pos[2], r_geo.mod_pos[1] } end
      add_geo_as_edge(r_geo)
   end
end

---passed the goe to be rotated along with it's mirror if applicable
---@param geo RailGeometry
local function expand_geometry_mirror(geo)
   expand_geometry_rotate(geo)
   if geo.mirrored_dir then
      geo = table.deepcopy(geo)
      geo.ends.entrance.pos[1] = -geo.ends.entrance.pos[1]
      geo.ends.exit.pos[1] = -geo.ends.exit.pos[1]
      geo.ends.entrance.dir = -geo.ends.entrance.dir % mod_dir
      geo.ends.exit.dir = -geo.ends.exit.dir % mod_dir
      geo.dir = geo.mirrored_dir
      expand_geometry_rotate(geo)
   end
end

---reverses the geometry and passes both on to be further expanded
---@param geo RailGeometry
local function expand_geometry_reverse(geo)
   expand_geometry_mirror(geo)
   geo = table.deepcopy(geo)
   geo.ends = {
      entrance = geo.ends.exit,
      exit = geo.ends.entrance,
   }
   geo.ends.entrance.dir = (geo.ends.entrance.dir + dirs16.south) % mod_dir
   geo.ends.exit.dir = (geo.ends.exit.dir + dirs16.south) % mod_dir
   geo.elevation_gain = -geo.elevation_gain
   expand_geometry_mirror(geo)
end

for _, geo in pairs(geometries) do
   expand_geometry_reverse(geo)
end

local abstract_prerequisite_map = {}
local abstract_prerequisite_map_reversed = {}

---@type table<integer, node_edge[]>
local edges_by_req = {}
for abstract_req, edges in pairs(edges_by_abstract_req) do
   table.insert(abstract_prerequisite_map, abstract_req)
   table.insert(edges_by_req, edges)
end
for node_type, abstract_req in pairs(abstract_prerequisite_map) do
   abstract_prerequisite_map_reversed[abstract_req] = node_type
end
for _, edges in pairs(edges_by_req) do
   for _, edge in pairs(edges) do
      edge.after = abstract_prerequisite_map_reversed[edge.after]
   end
end

local key_mod = 2 ^ 52

---@alias RailPlanner table<string,string>

---@class node
---@field pos MapPosition
---@field dir dirs16
---@field elevation integer
---@field key integer
---@field cost_so_far number
---The edge that got here or nil if cost_so_far is zero
---@field edge? node_edge
---The last node or nil if cost_so_far is zero
---@field last_node? node

---@class PathFinderData
---@field to MapPosition
---@field to_dir? dirs16
---@field to_elevation integer
---@field planner RailPlanner
---@field queue PriorityQueue
---@field added table<integer, true>

local function h(data, pos, dir, elevation)
   local diff_x = data.to[1] - pos[1]
   local diff_y = data.to[2] - pos[2]
   return math.sqrt(diff_x * diff_x + diff_y * diff_y)
end

---@param data PathFinderData
---@param node node
local function add_node(data, node)
   if data.added[node.key] then return end
   data.added[node.key] = true
   local expected_cost = h(data, node.pos, node.dir, node.elevation) + node.cost_so_far
   data.queue:put(node, expected_cost)
end

---initialize the a_star pathfinder
---@param from_pos MapPosition
---@param from_dir dirs16
---@param from_elevation integer
---@param to_pos MapPosition
---@param to_dir? dirs16
---@param planner RailPlanner
local function request_path(from_pos, from_dir, from_elevation, to_pos, to_dir, to_elevation, planner)
   ---@type PathFinderData
   local path_finder_data = {
      to = to_pos,
      to_dir = to_dir,
      to_elevation = to_elevation,
      planner = planner,
      queue = PriorityQueue(),
      added = {},
   }
   add_node(path_finder_data, {
      pos = from_pos,
      dir = from_dir,
      elevation = from_elevation,
      cost_so_far = 0,
      key = location_key(from_pos, from_dir, from_elevation),
   })
end

---will add a new node from node taking edge. If the new node reaches the target it will return the node.
---@param data PathFinderData
---@param node node
---@param edge node_edge
---@return nil|node
local function try_to_add(data, node, edge)
   ---@type node
   local next_node = {
      pos = { node.pos[1] + edge.pos_change[1], node.pos[2] + edge.pos_change[2] },
      dir = (node.dir + edge.dir_change) % mod_dir,
      elevation = node.elevation + edge.elevation_change,
      cost_so_far = node.cost_so_far + edge.cost,
      key = (node.key + edge.key_change) % key_mod,
      edge = edge,
      last_node = node,
   }
   if next_node.elevation < 0 then return nil end
   if next_node.elevation > max_elevated_height then return nil end
   --todo: check collisions

   if data.to[1] == next_node.pos[1] and data.to[2] == next_node.pos[2] then
      if not data.to_dir or data.to_dir == next_node.dir then return next_node end
   end
   add_node(data, node)
end

---expand one node into up to three nodes
---@param data PathFinderData
---@return boolean
local function do_step(data)
   ---@type node
   local best_chance, _ = data.queue:pop()
   for _, edge in pairs(edges_by_req[best_chance.edge.after]) do
   end
   return false
end

---@alias geo_drawer fun(pos:MapPosition,height:integer)

---creates a function to draw the edge
---@param edge node_edge
---@return geo_drawer
local function make_draw_function(edge)
   if edge.elevation_change ~= 0 then
      error("ramps currently unsupported")
   elseif edge.dir_change == 0 then
      local end_point_offset = edge.pos_change
      ---@type geo_drawer
      function ret_drawer(pos, height)
         local start_point = { pos[1], pos[2] - height }
         local end_point = { pos[1] + end_point_offset[1], pos[2] - height + end_point_offset[1] }
         rendering.draw_line({
            color = colors[height],
            from = start_point,
            to = end_point,
            width = 0.1875,
            surface = 1,
            time_to_live = 600,
         })
      end
      return ret_drawer
   else --curve
      local angle = 2 * math.pi / mod_dir * edge.pos_change
      local mid_point = { edge.pos_change[1] / 2, edge.pos_change[2] / 2 }
      local ratio = 1 / math.tan(angle / 2)
      local centerpoint = {
         mid_point[1] - mid_point[2] * ratio,
         mid_point[2] + mid_point[1] * ratio,
      }
      local start_angle = math.atan2(edge.pos_change[1], edge.pos_change[2]) + angle / 2
      local mid = math.sqrt(centerpoint[0] * centerpoint[0] + centerpoint[1] * centerpoint[1])
      local max_r = mid + 0.09375
      local min_r = mid - 0.09375
      ---@type geo_drawer
      function ret_drawer(pos, height)
         rendering.draw_arc({
            color = colors[height],
            angle = angle,
            max_radius = max_r,
            min_radius = min_r,
            start_angle = start_angle,
            target = { centerpoint[1] + pos[1], centerpoint[2] + pos[2] },
            surface = 1,
            time_to_live = 600,
         })
      end
      return ret_drawer
   end
end

--make_draw_function_from_geo(geo[1])
