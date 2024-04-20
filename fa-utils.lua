--Here: Utility functions called by other files. Examples include distance and position calculations, string processing.
local util = require('util')

local directions={
   [defines.direction.north]="North",
   [defines.direction.northeast]="Northeast",
   [defines.direction.east]="East",
   [defines.direction.southeast]="Southeast",
   [defines.direction.south]="South",
   [defines.direction.southwest]="Southwest",
   [defines.direction.west]="West",
   [defines.direction.northwest]="Northwest",
   [8] = ""
}

function center_of_tile(pos)
   return {x = math.floor(pos.x)+0.5, y = math.floor(pos.y)+ 0.5}
end

function add_position(p1,p2)
   return { x = p1.x + p2.x, y = p1.y + p2.y}
end

function sub_position(p1,p2)
   return { x = p1.x - p2.x, y = p1.y - p2.y}
end

function mult_position(p,m)
   return { x = p.x * m, y = p.y * m }
end

function offset_position(oldpos,direction,distance)
   if direction == defines.direction.north then
      return { x = oldpos.x, y = oldpos.y - distance}
   elseif direction == defines.direction.south then
      return { x = oldpos.x, y = oldpos.y + distance}
   elseif direction == defines.direction.east then
      return { x = oldpos.x + distance, y = oldpos.y}
   elseif direction == defines.direction.west then
      return { x = oldpos.x - distance, y = oldpos.y}
   elseif direction == defines.direction.northwest then
      return { x = oldpos.x - distance, y = oldpos.y - distance}
   elseif direction == defines.direction.northeast then
      return { x = oldpos.x + distance, y = oldpos.y - distance}
   elseif direction == defines.direction.southwest then
      return { x = oldpos.x - distance, y = oldpos.y + distance}
   elseif direction == defines.direction.southeast then
      return { x = oldpos.x + distance, y = oldpos.y + distance}
   end
end

function dir_dist(pos1,pos2)
   local x1 = pos1.x
   local x2 = pos2.x
   local dx = x2 - x1
   local y1 = pos1.y
   local y2 = pos2.y
   local dy = y2 - y1
   if dx == 0 and dy == 0 then
      return {8,0}
   end
   local dir = math.atan2(dy,dx) --scaled -pi to pi 0 being east
   dir = dir + math.sin(4*dir)/4 --bias towards the diagonals
   dir = dir/math.pi -- now scaled as -0.5 north, 0 east, 0.5 south
   dir=math.floor(dir*defines.direction.south + defines.direction.east + 0.5) --now scaled correctly
   dir=dir%(2*defines.direction.south) --now wrapped correctly
   local dist = math.sqrt(dx*dx+dy*dy)
   return {dir, dist}
end

function dir(pos1,pos2)
   return dir_dist(pos1,pos2)[1]
end

function direction (pos1, pos2)
   return directions[dir(pos1,pos2)]
end

function distance ( pos1, pos2)
   return dir_dist( pos1, pos2)[2]
end

function squared_distance(pos1, pos2)
   local offset = {x = pos1.x - pos2.x, y = pos1.y - pos2.y}
   local result = offset.x * offset.x + offset.y * offset.y
   return result
end

--[[
* Returns the direction of that entity from this entity based on the ratios of the x and y distances, with bias. 
* Returns 1 of 8 main directions, with a bias away from the 4 cardinal directions, to make it easier to align with them. 
* The deciding ratio is 1 to 4, meaning that for an object that is 100 tiles north, it can be offset by up to 25 tiles east or west before it stops being counted as "directly" in the north. 
* The arctangent of 1/4 is about 14 degrees, meaning that the field of view that directly counts as a cardinal direction is about 30 degrees, while for a diagonal direction it is about 60 degrees.]]
function get_direction_of_that_from_this(pos_that,pos_this)
   local diff_x = pos_that.x - pos_this.x
   local diff_y = pos_that.y - pos_this.y
   local dir = -1
   
   if math.abs(diff_x) > 4 * math.abs(diff_y) then --along east-west
      if diff_x > 0 then 
	     dir = defines.direction.east 
	  else 
	     dir = defines.direction.west 
	  end
   elseif math.abs(diff_y) > 4 * math.abs(diff_x) then --along north-south
      if diff_y > 0 then 
	     dir = defines.direction.south 
	  else 
	     dir = defines.direction.north 
	  end
   else --along diagonals
      if diff_x > 0 and diff_y > 0 then
	     dir = defines.direction.southeast
      elseif diff_x > 0 and diff_y < 0 then
	     dir = defines.direction.northeast
      elseif diff_x < 0 and diff_y > 0 then
	     dir = defines.direction.southwest
	  elseif diff_x < 0 and diff_y < 0 then
	     dir = defines.direction.northwest
	  elseif diff_x == 0 and diff_y == 0 then
        dir = defines.direction.north
     else
	     dir = -2
	  end
   end
   return dir
end

--[[
* Returns the direction of that entity from this entity based on the ratios of the x and y distances, without bias. 
* Returns 1 of 8 main directions, with each getting about equal representation (45 degrees). 
* The deciding ratio is 1 to 2.5, meaning that for an object that is 25 tiles north, it can be offset by up to 10 tiles east or west before it stops being counted as "directly" in the north. 
* The arctangent of 1/2.5 is about 22 degrees, meaning that the field of view that directly counts as a cardinal direction is about 44 degrees, while for a diagonal direction it is about 46 degrees.]]
function get_balanced_direction_of_that_from_this(pos_that,pos_this)
   local diff_x = pos_that.x - pos_this.x
   local diff_y = pos_that.y - pos_this.y
   local dir = -1
   
   if math.abs(diff_x) > 2.5 * math.abs(diff_y) then --along east-west
      if diff_x > 0 then 
	     dir = defines.direction.east 
	  else 
	     dir = defines.direction.west 
	  end
   elseif math.abs(diff_y) > 2.5 * math.abs(diff_x) then --along north-south
      if diff_y > 0 then 
	     dir = defines.direction.south 
	  else 
	     dir = defines.direction.north 
	  end
   else --along diagonals
      if diff_x > 0 and diff_y > 0 then
	     dir = defines.direction.southeast
      elseif diff_x > 0 and diff_y < 0 then
	     dir = defines.direction.northeast
      elseif diff_x < 0 and diff_y > 0 then
	     dir = defines.direction.southwest
	  elseif diff_x < 0 and diff_y < 0 then
	     dir = defines.direction.northwest
	  elseif diff_x == 0 and diff_y == 0 then
        dir = defines.direction.north
     else
	     dir = -2
	  end
   end
   return dir
end

--Directions lookup table 
function direction_lookup(dir)
   local reading = "unknown"
   if dir < 0 then
      return "unknown direction ID " .. dir
   end
   if dir >= dirs.north and dir <= dirs.northwest then
      return game.direction_to_string(dir)
   else
      -- if dir == dirs.north then
         -- reading = "North"
      -- elseif dir == dirs.northeast then
         -- reading = "Northeast"
      -- elseif dir == dirs.east then
         -- reading = "East"
      -- elseif dir == dirs.southeast then
         -- reading = "Southeast"
      -- elseif dir == dirs.south then
         -- reading = "South"
      -- elseif dir == dirs.southwest then
         -- reading = "Southwest"
      -- elseif dir == dirs.west then
         -- reading = "West"
      -- elseif dir == dirs.northwest then
         -- reading = "Northwest"
      -- end
      if dir == 99 then --Defined by mod 
         reading = "Here"
      else
         reading = "unknown direction ID " .. dir
      end      
      return reading
   end
end

function rotate_90(dir)
   return (dir + dirs.east) % (2 * dirs.south)
end

function rotate_180(dir)
   return (dir + dirs.south) % (2 * dirs.south)
end

function rotate_270(dir)
   return (dir + dirs.east * 3) % (2 * dirs.south)
end


function nearest_edge(edges, pos, name)
   local pos = table.deepcopy(pos)
   if name == "forest" then
      pos.x = pos.x / 8 
      pos.y = pos.y / 8 
   end
   local result = {}
   local min = math.huge
   for str, b in pairs(edges) do
      local edge_pos = str2pos(str)
      local d = util.distance(pos, edge_pos)
      if d < min then
         result = edge_pos
         min = d
      end
   end
   if name == "forest" then
      result.x = result.x * 8 - 4
      result.y = result.y * 8 - 4
   end
   return result
end

function scale_area(area, factor)
   result = table.deepcopy(area)
   result.left_top.x = area.left_top.x * factor
   result.left_top.y = area.left_top.y * factor
   result.right_bottom.x = area.right_bottom.x * factor
   result.right_bottom.y = area.right_bottom.y * factor
   return result
end

function area_edge(area,dir,pos,name)
   local adjusted_area = table.deepcopy(area)
   if name == "forest" then
      local chunk_size = 8
      adjusted_area.left_top.x = adjusted_area.left_top.x / chunk_size
      adjusted_area.left_top.y = adjusted_area.left_top.y / chunk_size
      adjusted_area.right_bottom.x = adjusted_area.right_bottom.x / chunk_size
      adjusted_area.right_bottom.y = adjusted_area.right_bottom.y / chunk_size
   end
   if dir == 0 then
      if adjusted_area.left_top.y == math.floor(pos.y) then
         return true
      else
         return false
      end
   elseif dir == 2 then
      if adjusted_area.right_bottom.x == math.ceil( .001 + pos.x) then
         return true
      else
         return false
      end
   elseif dir == 4 then
      if adjusted_area.right_bottom.y == math.ceil(.001+pos.y) then
         return true
      else
         return false
      end

   elseif dir == 6 then
      if adjusted_area.left_top.x == math.floor(pos.x) then
         return true
      else
         return false
      end
   end
end

function table_concat (T1, T2)
   if T2 == nil then
      return
   end
   if T1 == nil then
      T1 = {}
   end
   for i, v in pairs(T2) do
         table.insert(T1, v)
   end
end

function pos2str (pos)
   return pos.x .. " " .. pos.y
end

function str2pos(str)
   local t = {}
   for s in string.gmatch(str, "([^%s]+)") do
      table.insert(t, s)
   end
      return {x = t[1], y = t[2]}
end

function breakup_string(str)
   result = {""}
   if table_size(str) > 20 then
      local i = 0
      while i < #str do
         if i%20 == 0 then
         table.insert(result, {""})
         end
         table.insert(result[math.ceil((i+1)/20)+1], table.deepcopy(str[i+1]))
         i = i + 1
      end
      return result
   else
      return str
   end
end

function get_iterable_array(dict)
   result = {}
   for i, v in pairs(dict) do
      table.insert(result, v)
   end
   return result
end

function into_lookup(array)
    local lookup = {}
    for key, value in pairs(array) do
        lookup[value] = key
    end
    return lookup
end

function get_substring_before_space(str)
   local first, final = string.find(str," ")
   if first == nil or first == 1 then --No space, or space at the start only
      return str
   else
      return string.sub(str,1,first-1)
   end
end

function get_substring_after_space(str)--***
   local first, final = string.find(str," ")
   if final == nil then --No spaces
      return str
   end
   if first == 1 then --spaces at start only
      return string.sub(str,final+1,string.len(str))
   end
   
   if final == string.len(str) then --space at the end only?
      return str
   end
   
   return string.sub(str,final+1,string.len(str))
end

function get_substring_before_comma(str)
   local first, final = string.find(str,",")
   if first == nil or first == 1 then
      return str
   else
      return string.sub(str,1,first-1)
   end
end

function get_substring_before_dash(str)
   local first, final = string.find(str,"-")
   if first == nil or first == 1 then
      return str
   else
      return string.sub(str,1,first-1)
   end
end

function dir_dist_locale_h(dir_dist)
   return {"access.dir-dist",{"access.direction",dir_dist[1]},math.floor(dir_dist[2]+0.5)}
end

function dir_dist_locale(pos1,pos2)
   return dir_dist_locale_h( dir_dist(pos1,pos2) )
end

function ent_name_locale(ent)
   if ent.name == "water" then
      print("todo: water isn't an entity")
      return {"gui-map-generator.water"}
   end
   if ent.name == "forest" then
      print("todo: forest isn't an entity")
      return {"access.forest"}
   end
   if not game.entity_prototypes[ent.name] then
      error(ent.name .. " is not an entity")
   end
   return ent.localised_name or game.entity_prototypes[ent.name].localised_name
end