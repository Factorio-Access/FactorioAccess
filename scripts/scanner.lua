--Here: Functions relating to the scanner tool
--Does not include event handlers directly, but can have functions called by them.
local util = require("util")
local fa_utils = require("scripts.fa-utils")
local fa_mouse = require("scripts.mouse")
local localising = require("scripts.localising")
local dirs = defines.direction
local fa_graphics = require("scripts.graphics")
local fa_building_tools = require("scripts.building-tools")
local fa_trains = require("scripts.trains")
local fa_zoom = require("scripts.zoom")
local fa_bot_logistics = require("scripts.worker-robots")

local mod = {}
--Find islands of resources or water or trees to create the aggregate entries in the scanner list. Does not run for every scan.
function mod.find_islands(surf, area, pindex)
   local islands = {}
   local ents = surf.find_entities_filtered({ area = area, type = "resource" })
   local waters = surf.find_tiles_filtered({ area = area, name = "water" })
   local trents = surf.find_entities_filtered({ area = area, type = "tree" })
   --   if trents ~= nil and #trents > 0 then      printout("trees galore", pindex) end
   local i = 1
   while i <= #trents do
      local trent = trents[i]
      local check = (
         trent.position.x >= area.left_top.x
         and trent.position.y >= area.left_top.y
         and trent.position.x < area.right_bottom.x
         and trent.position.y < area.right_bottom.y
      )

      if check == false then
         table.remove(trents, i)
      else
         i = i + 1
      end
   end
   if #trents > 0 then
      --printout("trees galore", pindex) **beta
   end
   if #ents == 0 and #waters == 0 and #trents == 0 then return {} end

   for i, ent in ipairs(ents) do
      local destroy_id = script.register_on_entity_destroyed(ent)
      players[pindex].destroyed[destroy_id] =
         { name = ent.name, position = ent.position, type = ent.type, area = ent.bounding_box }
      if islands[ent.name] == nil then
         islands[ent.name] = {
            name = ent.name,
            groups = {},
            resources = {},
            edges = {},
            neighbors = {},
         }
      end
      islands[ent.name].groups[i] = { fa_utils.pos2str(ent.position) }
      islands[ent.name].resources[fa_utils.pos2str(ent.position)] = { group = i, edge = false }
   end
   if #waters > 0 then
      islands["water"] = {
         name = "water",
         groups = {},
         resources = {},
         edges = {},
         neighbors = {},
      }
   end
   for i, water in pairs(waters) do
      local str = fa_utils.pos2str(water.position)
      if islands["water"].resources[str] == nil then
         islands["water"].groups[i] = { str }
         islands["water"].resources[str] = { group = i, edge = false }
      end
   end
   if #trents > 0 then
      islands["forest"] = {
         name = "forest",
         groups = {},
         resources = {},
         edges = {},
         neighbors = {},
      }
   end
   for i, trent in pairs(trents) do
      local destroy_id = script.register_on_entity_destroyed(trent)
      players[pindex].destroyed[destroy_id] =
         { name = trent.name, position = trent.position, type = trent.type, area = trent.bounding_box }

      local pos = table.deepcopy(trent.position)
      pos.x = math.floor(pos.x / 8)
      pos.y = math.floor(pos.y / 8)

      local str = fa_utils.pos2str(pos)

      if islands["forest"].resources[str] == nil then
         islands["forest"].groups[i] = { str }
         islands["forest"].resources[str] = { group = i, edge = false, count = 1 }
      else
         islands["forest"].resources[str].count = islands["forest"].resources[str].count + 1
      end
   end

   for name, entry in pairs(islands) do
      for pos, resource in pairs(entry.resources) do
         local position = fa_utils.str2pos(pos)
         local adj = {}
         for dir = 0, 7 do
            adj[dir] = fa_utils.pos2str(fa_utils.offset_position(position, dir, 1))
         end
         local new_group = resource.group
         for dir, index in ipairs(adj) do
            if entry.resources[index] == nil then
               resource.edge = true
            else
               new_group = math.min(new_group, entry.resources[index].group)
            end
         end
         if resource.edge then
            --            table.insert(entry.edges, pos)
            entry.edges[pos] = false
            if fa_utils.area_edge(area, 0, position, name) then
               entry.neighbors[0] = true
               entry.edges[pos] = true
            end
            if fa_utils.area_edge(area, 6, position, name) then
               entry.neighbors[6] = true
               entry.edges[pos] = true
            end
            if fa_utils.area_edge(area, 4, position, name) then
               entry.neighbors[4] = true
               entry.edges[pos] = true
            end
            if fa_utils.area_edge(area, 2, position, name) then
               entry.neighbors[2] = true
               entry.edges[pos] = true
            end
         end
         table.insert(adj, pos)
         for dir, index in ipairs(adj) do
            if entry.resources[index] ~= nil and entry.resources[index].group ~= new_group then
               local old_group = entry.resources[index].group
               fa_utils.table_concat(entry.groups[new_group], entry.groups[old_group])
               for i, index in pairs(entry.groups[old_group]) do
                  entry.resources[index].group = new_group
               end
               entry.groups[old_group] = nil
            end
         end
      end
   end
   return islands
end

--Run any sort of scan
function mod.scan_area(x, y, w, h, pindex, filter_direction, start_with_existing_list, close_object_limit_in)
   local first_player = game.get_player(pindex)
   local surf = first_player.surface
   local ents = surf.find_entities_filtered({
      area = { { x, y }, { x + w, y + h } },
      type = { "resource", "tree", "highlight-box", "flying-text" },
      invert = true,
   }) --Get all ents in the area except for these types
   local result = {}
   if start_with_existing_list == true then result = players[pindex].nearby.ents end
   local pos = players[pindex].position
   local forest_density = nil
   local close_object_limit = close_object_limit_in or 10.1

   --Find the nearest edges of already-loaded resource groups according to player pos, and insert them to the initial list as aggregates
   for name, resource in pairs(players[pindex].resources) do
      --Insert scanner entries
      table.insert(
         result,
         { name = name, count = table_size(players[pindex].resources[name].patches), ents = {}, aggregate = true }
      )
      --Insert instances for the entry
      local index = #result
      for group, patch in pairs(resource.patches) do
         local nearest_edge = fa_utils.nearest_edge(patch.edges, pos, name)
         --Filter check 1: Is the entity in the filter diection? (If a filter is set at all)
         local dir_of_ent = fa_utils.get_direction_biased(nearest_edge, pos)
         local filter_passed = (filter_direction == nil or filter_direction == dir_of_ent)
         if not filter_passed then
            --Filter check 2: Is the entity nearby and almost within the filter diection?
            if util.distance(nearest_edge, pos) < close_object_limit then
               local new_dir_of_ent = fa_utils.get_direction_precise(nearest_edge, pos) --Check with less bias towards diagonal directions to preserve 135 degrees FOV
               local CW_dir = (filter_direction + dirs.northeast) % (2 * dirs.south)
               local CCW_dir = (filter_direction - dirs.northeast) % (2 * dirs.south)
               filter_passed = (
                  new_dir_of_ent == filter_direction
                  or new_dir_of_ent == CW_dir
                  or new_dir_of_ent == CCW_dir
               )
            end
         end
         if filter_passed then
            --If it is a forest, check density
            if name == "forest" then
               local forest_pos = nearest_edge
               forest_density = mod.classify_forest(forest_pos, pindex, false, false)
            else
               forest_density = nil
            end
            --Insert to the list if this group is not a forest at all, or not an empty or tiny forest
            if forest_density == nil or (forest_density ~= "empty" and forest_density ~= "patch") then
               table.insert(result[index].ents, { group = group, position = nearest_edge })
            end
         end
      end
      --Remove empty entries
      if result[index].ents == nil or result[index].ents == {} or result[index].ents[1] == nil then
         table.remove(result, index)
      end
   end

   --Insert entities to the initial list
   for i = 1, #ents, 1 do
      local extra_entry_info = mod.ent_extra_list_info(ents[i], pindex, false)
      local scan_entry = ents[i].name .. extra_entry_info
      local index = fa_utils.index_of_entity(result, scan_entry)

      --Filter check 1: Is the entity in the filter diection? (If a filter is set at all)
      local dir_of_ent = fa_utils.get_direction_biased(ents[i].position, pos)
      local filter_passed = (filter_direction == nil or filter_direction == dir_of_ent)
      if not filter_passed then
         --Filter check 2: Is the entity nearby and almost within the filter diection?
         if util.distance(ents[i].position, pos) < close_object_limit then
            local new_dir_of_ent = fa_utils.get_direction_precise(ents[i].position, pos) --Check with less bias towards diagonal directions to preserve 135 degrees FOV
            local CW_dir = (filter_direction + 1) % (2 * dirs.south)
            local CCW_dir = (filter_direction - 1) % (2 * dirs.south)
            filter_passed = (
               new_dir_of_ent == filter_direction
               or new_dir_of_ent == CW_dir
               or new_dir_of_ent == CCW_dir
            )
         end
      end

      if filter_passed then
         if index == nil then --The entry is not already indexed, so add a new entry line to the list
            table.insert(result, { name = scan_entry, count = 1, ents = { ents[i] }, aggregate = false })
         elseif #result[index] >= 100 then --If there are more than 100 instances of this specific entry (?), replace a random one of them to add this
            table.remove(result[index].ents, math.random(100))
            table.insert(result[index].ents, ents[i])
            result[index].count = result[index].count + 1
         else
            table.insert(result[index].ents, ents[i]) --Add this ent as another instance of the entry
            result[index].count = result[index].count + 1
            --         result[index] = ents[i]
         end
      end
   end

   --Sort the list
   if players[pindex].nearby.count == nil then players[pindex].nearby.count = false end
   if players[pindex].nearby.count == false then
      --Sort results by distance to player position when first creating the scanner list
      table.sort(result, function(k1, k2)
         local pos = players[pindex].position
         local ent1 = nil
         local ent2 = nil
         if k1.aggregate then
            table.sort(k1.ents, function(k3, k4)
               return fa_utils.squared_distance(pos, k3.position) < fa_utils.squared_distance(pos, k4.position)
            end)
            ent1 = k1.ents[1]
         --            end
         else
            ent1 = surf.get_closest(pos, k1.ents)
         end
         if k2.aggregate then
            table.sort(k2.ents, function(k3, k4)
               return fa_utils.squared_distance(pos, k3.position) < fa_utils.squared_distance(pos, k4.position)
            end)
            ent2 = k2.ents[1]
         --            end
         else
            ent2 = surf.get_closest(pos, k2.ents)
         end
         return util.distance(pos, ent1.position) < util.distance(pos, ent2.position)
      end)
   else
      --Sort results by count
      table.sort(result, function(k1, k2)
         return k1.count > k2.count
      end)
   end
   return result
end

--Scans an area but only for trees. Copies the "Insert entities to the initial list" part from scan_area(). Separate so that one can specify a smaller radius for this.
function mod.scan_nearby_trees(pindex, filter_direction, radius_in)
   local p = game.get_player(pindex)
   local pos = players[pindex].position
   local surf = first_player.surface
   local radius_s = radius_in or 25
   local close_object_limit = 10.1
   local result = {}
   local ents = surf.find_entities_filtered({ position = p.position, radius = radius_s, type = "tree", limit = 200 })
   if ents == nil or #ents == 0 then return result end

   local scan_entry = "tree type" --**laterdo localise here

   --Insert entities to the initial list
   for i = 1, #ents, 1 do
      local index = fa_utils.index_of_entity(result, scan_entry)
      --Filter check 1: Is the entity in the filter diection? (If a filter is set at all)
      local dir_of_ent = fa_utils.get_direction_biased(ents[i].position, pos)
      local filter_passed = (filter_direction == nil or filter_direction == dir_of_ent)
      if not filter_passed then
         --Filter check 2: Is the entity nearby and almost within the filter diection?
         if util.distance(ents[i].position, pos) < close_object_limit then
            local new_dir_of_ent = fa_utils.get_direction_precise(ents[i].position, pos) --Check with less bias towards diagonal directions to preserve 135 degrees FOV
            local CW_dir = (filter_direction + 1) % (2 * dirs.south)
            local CCW_dir = (filter_direction - 1) % (2 * dirs.south)
            filter_passed = (
               new_dir_of_ent == filter_direction
               or new_dir_of_ent == CW_dir
               or new_dir_of_ent == CCW_dir
            )
         end
      end
      if filter_passed then
         if index == nil then --The entry is not already indexed, so add a new entry line to the list
            table.insert(result, { name = scan_entry, count = 1, ents = { ents[i] }, aggregate = false })
         elseif #result[index] >= 100 then --If there are more than 100 instances of this specific entry (?), replace a random one of them to add this
            table.remove(result[index].ents, math.random(100))
            table.insert(result[index].ents, ents[i])
            result[index].count = result[index].count + 1
         else
            table.insert(result[index].ents, ents[i]) --Add this ent as another instance of the entry
            result[index].count = result[index].count + 1
            --         result[index] = ents[i]
         end
      end
   end

   return result
end

--Adds scanned ents to categories of the scan results list.
function mod.populate_list_categories(pindex)
   players[pindex].nearby.resources = {}
   players[pindex].nearby.containers = {}
   players[pindex].nearby.logistics_buildings = {}
   players[pindex].nearby.production_buildings = {}
   players[pindex].nearby.other_buildings = {}
   players[pindex].nearby.ghosts = {}
   players[pindex].nearby.vehicles = {}
   players[pindex].nearby.players = {}
   players[pindex].nearby.enemies = {}
   players[pindex].nearby.others = {}

   for i, ent in ipairs(players[pindex].nearby.ents) do
      if ent.aggregate then
         table.insert(players[pindex].nearby.resources, ent)
      else
         while #ent.ents > 0 and ent.ents[1].valid == false do
            table.remove(ent.ents, 1)
         end
         if #ent.ents == 0 then
            print("Empty ent")
         elseif ent.name == "water" then
            table.insert(players[pindex].nearby.resources, ent)
         elseif
            ent.ents[1].type == "resource"
            or ent.ents[1].type == "tree"
            or ent.ents[1].name == "sand-rock-big"
            or ent.ents[1].name == "rock-big"
            or ent.ents[1].name == "rock-huge"
         then --Note: There is no rock type, so they are specified by name.
            table.insert(players[pindex].nearby.resources, ent)
         elseif
            ent.ents[1].type == "container"
            or ent.ents[1].type == "logistic-container"
            or ent.ents[1].type == "storage-tank"
         then
            table.insert(players[pindex].nearby.containers, ent)
         elseif
            ent.ents[1].prototype.is_building
            and ent.ents[1].prototype.group.name == "logistics"
            and ent.ents[1].type ~= "train-stop"
         then
            table.insert(players[pindex].nearby.logistics_buildings, ent)
         elseif ent.ents[1].prototype.is_building and ent.ents[1].prototype.group.name == "production" then
            table.insert(players[pindex].nearby.production_buildings, ent)
         elseif
            ent.ents[1].prototype.is_building
            and ent.ents[1].type ~= "unit-spawner"
            and ent.ents[1].type ~= "turret"
            and ent.ents[1].type ~= "train-stop"
         then
            table.insert(players[pindex].nearby.other_buildings, ent)
         elseif ent.ents[1].type == "entity-ghost" then
            table.insert(players[pindex].nearby.ghosts, ent)
         elseif
            ent.ents[1].type == "car"
            or ent.ents[1].type == "locomotive"
            or ent.ents[1].type == "cargo-wagon"
            or ent.ents[1].type == "fluid-wagon"
            or ent.ents[1].type == "artillery-wagon"
            or ent.ents[1].type == "spider-vehicle"
            or ent.ents[1].type == "train-stop" --Exception
         then
            table.insert(players[pindex].nearby.vehicles, ent)
         elseif ent.ents[1].type == "character" or ent.ents[1].type == "character-corpse" then
            table.insert(players[pindex].nearby.players, ent)
         elseif ent.ents[1].type == "unit" or ent.ents[1].type == "unit-spawner" or ent.ents[1].type == "turret" then
            table.insert(players[pindex].nearby.enemies, ent)
         else --if ent.ents[1].type == "simple-entity" or ent.ents[1].type == "simple-entity-with-owner" or ent.ents[1].type == "entity-ghost" or ent.ents[1].type == "item-entity" then --(allowing all makes it include corpses/remnants as well)
            table.insert(players[pindex].nearby.others, ent)
         end
      end
   end
   --Report category populations For debugging
   if false then
      game.print(" 1. all count: " .. #players[pindex].nearby.ents, { volume_modifier = 0 })
      game.print(" 2. resources count: " .. #players[pindex].nearby.resources, { volume_modifier = 0 })
      game.print(" 3. containers count: " .. #players[pindex].nearby.containers, { volume_modifier = 0 })
      game.print(" 4. logis buildings count: " .. #players[pindex].nearby.logistics_buildings, { volume_modifier = 0 })
      game.print(" 5. prod  buildings count: " .. #players[pindex].nearby.production_buildings, { volume_modifier = 0 })
      game.print(" 6. other buildings count: " .. #players[pindex].nearby.other_buildings, { volume_modifier = 0 })
      game.print(" 7. ghosts count: " .. #players[pindex].nearby.ghosts, { volume_modifier = 0 })
      game.print(" 8. vehicles count: " .. #players[pindex].nearby.vehicles, { volume_modifier = 0 })
      game.print(" 9. players count: " .. #players[pindex].nearby.players, { volume_modifier = 0 })
      game.print("10. enemies count: " .. #players[pindex].nearby.enemies, { volume_modifier = 0 })
      game.print("11. others count: " .. #players[pindex].nearby.others, { volume_modifier = 0 })
   end
end

--Run the entity scanner tool ("rescan")
function mod.run_scan(pindex, filter_dir, mute)
   players[pindex].nearby.index = 1
   players[pindex].nearby.selection = 1
   first_player = game.get_player(pindex)
   players[pindex].nearby.ents = mod.scan_nearby_trees(pindex, filter_dir, 25)
   players[pindex].nearby.ents = mod.scan_area(
      math.floor(players[pindex].cursor_pos.x) - 2500,
      math.floor(players[pindex].cursor_pos.y) - 2500,
      5000,
      5000,
      pindex,
      filter_dir,
      true
   )
   mod.populate_list_categories(pindex)
   players[pindex].nearby.index = 1
   players[pindex].nearby.selection = 1
   players[pindex].cursor_scanned = false

   --Use the waiting period as a chance to recalibrate
   fa_zoom.fix_zoom(pindex)

   if mute ~= true then
      if filter_dir == nil then
         printout("Scan complete.", pindex)
      else
         printout(fa_utils.direction_lookup(filter_dir) .. " direction scan complete.", pindex)
      end
   end
end

--Sound and visual effects for the scanner
function mod.run_scanner_effects(pindex)
   --Scanner visual and sound effects
   game.get_player(pindex).play_sound({ path = "scanner-pulse" })
   rendering.draw_circle({
      color = { 1, 1, 1 },
      radius = 1,
      width = 4,
      target = game.get_player(pindex).position,
      surface = game.get_player(pindex).surface,
      draw_on_ground = true,
      time_to_live = 60,
   })
   rendering.draw_circle({
      color = { 1, 1, 1 },
      radius = 2,
      width = 8,
      target = game.get_player(pindex).position,
      surface = game.get_player(pindex).surface,
      draw_on_ground = true,
      time_to_live = 60,
   })
end

--Sort scanner list entries by distance from the reference position, or by total count
function mod.list_sort(pindex)
   --First check for invalid entries in the list. If there are any, then rescan.
   for i, name in ipairs(players[pindex].nearby.ents) do
      for j, ent_j in ipairs(name.ents) do --this appears to be removing invalid ents within a set.
         if ent_j == nil or ent_j.valid == false or (ent_j.valid == nil and ent_j.aggregate == false) then
            --Just rescan
            mod.run_scanner_effects(pindex)
            mod.run_scan(pindex, nil, true)
            return
         end
      end
      if #name.ents == 0 then
         --Just rescan
         mod.run_scanner_effects(pindex)
         mod.run_scan(pindex, nil, true)
         return
      end
   end

   --Check sorting type (count or distance)
   if players[pindex].nearby.count == false then
      --Sort by distance to player position
      table.sort(players[pindex].nearby.ents, function(k1, k2)
         local pos = players[pindex].position
         local surf = game.get_player(pindex).surface
         local ent1 = nil
         local ent2 = nil
         if k1.name == "water" then
            table.sort(k1.ents, function(k3, k4)
               return fa_utils.squared_distance(pos, k3.position) < fa_utils.squared_distance(pos, k4.position)
            end)
            ent1 = k1.ents[1]
         else
            if k1.aggregate then
               table.sort(k1.ents, function(k3, k4)
                  return fa_utils.squared_distance(pos, k3.position) < fa_utils.squared_distance(pos, k4.position)
               end)
               ent1 = k1.ents[1]
            else
               ent1 = surf.get_closest(pos, k1.ents)
            end
         end
         if k2.name == "water" then
            table.sort(k2.ents, function(k3, k4)
               return fa_utils.squared_distance(pos, k3.position) < fa_utils.squared_distance(pos, k4.position)
            end)
            ent2 = k2.ents[1]
         else
            if k2.aggregate then
               table.sort(k2.ents, function(k3, k4)
                  return fa_utils.squared_distance(pos, k3.position) < fa_utils.squared_distance(pos, k4.position)
               end)
               ent2 = k2.ents[1]
            else
               ent2 = surf.get_closest(pos, k2.ents)
            end
         end
         return fa_utils.squared_distance(pos, ent1.position) < fa_utils.squared_distance(pos, ent2.position)
      end)
   else
      --Sort table by count
      table.sort(players[pindex].nearby.ents, function(k1, k2)
         return k1.count > k2.count
      end)
   end
   mod.populate_list_categories(pindex)
end

local function get_ents_of_scanner_category(cat_no)
   local ents = {}
   if cat_no == 1 then
      ents = players[pindex].nearby.ents
   elseif cat_no == 2 then
      ents = players[pindex].nearby.resources
   elseif cat_no == 3 then
      ents = players[pindex].nearby.containers
   elseif cat_no == 4 then
      ents = players[pindex].nearby.logistics_buildings
   elseif cat_no == 5 then
      ents = players[pindex].nearby.production_buildings
   elseif cat_no == 6 then
      ents = players[pindex].nearby.other_buildings
   elseif cat_no == 7 then
      ents = players[pindex].nearby.ghosts
   elseif cat_no == 8 then
      ents = players[pindex].nearby.vehicles
   elseif cat_no == 9 then
      ents = players[pindex].nearby.players
   elseif cat_no == 10 then
      ents = players[pindex].nearby.enemies
   elseif cat_no == 11 then
      ents = players[pindex].nearby.others
   end
   return ents
end

--Returns the name of the currently selected scanner category of a player
function mod.get_selected_scanner_category_name(pindex)
   local cat_no = players[pindex].nearby.category
   if cat_no == 1 then
      return "All"
   elseif cat_no == 2 then
      return "Resources"
   elseif cat_no == 3 then
      return "Containers"
   elseif cat_no == 4 then
      return "Logistics buildings"
   elseif cat_no == 5 then
      return "Production buildings"
   elseif cat_no == 6 then
      return "Other buildings"
   elseif cat_no == 7 then
      return "Ghosts"
   elseif cat_no == 8 then
      return "Vehicles"
   elseif cat_no == 9 then
      return "Players"
   elseif cat_no == 10 then
      return "Enemies"
   elseif cat_no == 11 then
      return "Others"
   else
      return "Unknwon category"
   end
end

--Switch to and read out the previous category. Skip if empty.
function mod.category_up(pindex)
   local new_category = players[pindex].nearby.category - 1
   local ents = get_ents_of_scanner_category(new_category)
   while new_category > 0 and next(ents) == nil do
      new_category = new_category - 1
      ents = get_ents_of_scanner_category(new_category)
   end
   if new_category > 0 then
      players[pindex].nearby.index = 1
      players[pindex].nearby.category = new_category
   end
   local result = mod.get_selected_scanner_category_name(pindex)
   printout(result, pindex)
end

--Switch to and read out the next category. Skip if empty.
function mod.category_down(pindex)
   local category_count = 11
   local new_category = players[pindex].nearby.category + 1
   local ents = get_ents_of_scanner_category(new_category)
   while new_category <= category_count and next(ents) == nil do
      new_category = new_category + 1
      ents = get_ents_of_scanner_category(new_category)
   end
   if new_category <= category_count then
      players[pindex].nearby.category = new_category
      players[pindex].nearby.index = 1
   end

   local result = mod.get_selected_scanner_category_name(pindex)
   printout(result, pindex)
end

--Reads the currently selected entity of the scanner list
function mod.list_index(pindex)
   if not check_for_player(pindex) then
      printout("Scan pindex error.", pindex)
      return
   end
   local p = game.get_player(pindex)
   local ents = get_ents_of_scanner_category(players[pindex].nearby.category)
   if next(ents) == nil then
      printout("No entities found.  Try refreshing with end key.", pindex)
   else
      local ent = nil

      if ents[players[pindex].nearby.index].aggregate == false then
         --The scan target is an entity
         local i = 1
         --Remove invalid or unwanted instances of the entity
         while i <= #ents[players[pindex].nearby.index].ents do
            local ents_i = ents[players[pindex].nearby.index].ents[i]
            if
               ents_i.valid
               and ents_i.name ~= "highlight-box"
               and ents_i.type ~= "flying-text"
               and ents_i.name ~= "rocket-silo-rocket"
               and ents_i.name ~= "rocket-silo-rocket-shadow"
               and ents_i.type ~= "spider-leg"
               and (
                  players[pindex].cursor_scanned ~= true
                  or (
                     players[pindex].cursor_scanned == true
                     and util.distance(ents_i.position, players[pindex].cursor_scan_center)
                        < players[pindex].cursor_size + 1
                  )
               )
            then
               i = i + 1
            else
               table.remove(ents[players[pindex].nearby.index].ents, i)
               if players[pindex].nearby.selection > i then
                  players[pindex].nearby.selection = players[pindex].nearby.selection - 1
               end
            end
         end
         --If there is none left of the entity, remove it
         if #ents[players[pindex].nearby.index].ents == 0 then
            table.remove(ents, players[pindex].nearby.index)
            players[pindex].nearby.index = math.min(players[pindex].nearby.index, #ents)
            mod.list_index(pindex)
            return
         end
         --Sort by distance to player pos while describing indexed entries
         table.sort(ents[players[pindex].nearby.index].ents, function(k1, k2)
            local pos = p.position
            return fa_utils.squared_distance(pos, k1.position) < fa_utils.squared_distance(pos, k2.position)
         end)
         if players[pindex].nearby.selection > #ents[players[pindex].nearby.index].ents then
            players[pindex].selection = 1
         end
         --The scan target is an entity, select it now
         ent = ents[players[pindex].nearby.index].ents[players[pindex].nearby.selection]
         if ent == nil then
            printout("Error: This object no longer exists. Try rescanning.", pindex)
            return
         end
         if not ent.valid then
            printout("Error: This object is no longer valid. Try rescanning.", pindex)
            return
         end
         --Select the northwest corner of the entity
         players[pindex].cursor_pos = fa_utils.get_ent_northwest_corner_position(ent)
         p.selected = ent
         --Select spaceship wreck pieces from the center because of their irregular shapes
         local check = ent.name
         local a = string.find(check, "spaceship")
         if a ~= nil then players[pindex].cursor_pos = ent.position end
         --Select curved rails from the center because of their irregular shapes
         if ent.name == "curved-rail" then players[pindex].cursor_pos = ent.position end
         --Select splitters from the center because for some reason their northwest corner is off center
         --Select vehicles from the center because they have orientation rather than direction and so the northwest corner does not apply
         if ent.type == "car" or ent.type == "spider-vehicle" or ent.train ~= nil then
            players[pindex].cursor_pos = ent.position
         end
         --Update cursor graphics
         fa_graphics.draw_cursor_highlight(pindex, ent, "train-visualization")
         fa_graphics.sync_build_cursor_graphics(pindex)
         players[pindex].last_indexed_ent = ent
      else
         --The scan target is an aggregate
         if players[pindex].nearby.selection > #ents[players[pindex].nearby.index].ents then
            players[pindex].selection = 1
         end
         local name = ents[players[pindex].nearby.index].name
         local entry = ents[players[pindex].nearby.index].ents[players[pindex].nearby.selection]
         --If there is none left of the entry or it is an unwanted type (does this ever happen?), remove it
         if entry ~= nil then
            if table_size(entry) == 0 or name == "highlight-box" then
               table.remove(ents[players[pindex].nearby.index].ents, players[pindex].nearby.selection)
               players[pindex].nearby.selection = players[pindex].nearby.selection - 1
               mod.list_index(pindex)
               return
            end
            --The scan target is an aggregate, select it now
            ent = { name = name, position = table.deepcopy(entry.position), group = entry.group } --maybe use "aggregate = true" ?
            players[pindex].cursor_pos = ent.position
            fa_graphics.draw_cursor_highlight(pindex, nil, "train-visualization")
            fa_graphics.sync_build_cursor_graphics(pindex)
            players[pindex].last_indexed_ent = ent
            game.get_player(pindex).selected = nil
         end
      end

      if
         ent == nil or (ents[players[pindex].nearby.index].aggregate == false and (ent == nil or ent.valid ~= true))
      then
         printout("Error: Invalid object, maybe try rescanning.", pindex)
         return
      end

      if
         players[pindex].cursor_scanned == true
         and util.distance(ent.position, players[pindex].cursor_scan_center) > players[pindex].cursor_size + 1
      then
         local final_result = { "" }
         table.insert(final_result, fa_utils.ent_name_locale(ent))
         table.insert(final_result, " reference point outside of scan area")
         printout(final_result, pindex)
         return
      end

      refresh_player_tile(pindex)

      local dir_dist = fa_utils.dir_dist_locale(p.position, players[pindex].cursor_pos)
      if players[pindex].nearby.count == false then
         --Read the entity in terms of distance and direction, taking the cursor position as the reference point
         local result = { "access.thing-producing-listpos-dirdist", fa_utils.ent_name_locale(ent) }
         table.insert(result, mod.ent_extra_list_info(ent, pindex, true))
         table.insert(
            result,
            { "description.of", players[pindex].nearby.selection, #ents[players[pindex].nearby.index].ents }
         ) --"X of Y"
         table.insert(result, dir_dist)
         local final_result = { "" }
         table.insert(final_result, result)
         table.insert(final_result, ", ")
         table.insert(final_result, fa_mouse.cursor_visibility_info(pindex))
         printout(final_result, pindex)
      else
         --Read the entity in terms of count, and give the direction and distance of an example
         local result = {
            "access.item_and_quantity-example-at-dirdist",
            { "access.item-quantity", fa_utils.ent_name_locale(ent), ents[players[pindex].nearby.index].count },
            dir_dist,
         }
         local final_result = { "" }
         table.insert(final_result, result)
         table.insert(final_result, ", ")
         table.insert(final_result, fa_mouse.cursor_visibility_info(pindex))
         printout(final_result, pindex)
      end
   end
end

--Move up one entry in the scanner list
function mod.list_up(pindex)
   if players[pindex].in_menu then
      --These keys may overlap a lot so might as well
      return
   end
   if players[pindex].nearby.index > 1 then
      players[pindex].nearby.index = players[pindex].nearby.index - 1
      players[pindex].nearby.selection = 1
   elseif players[pindex].nearby.index <= 1 then
      players[pindex].nearby.index = 1
      players[pindex].nearby.selection = 1
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   end
   mod.list_index(pindex)
end

--Move down one entry in the scanner list
function mod.list_down(pindex)
   if players[pindex].in_menu then
      --These keys may overlap a lot so might as well
      return
   end
   --Check if out of bounds
   local ents = get_ents_of_scanner_category(players[pindex].nearby.category)
   if players[pindex].nearby.index < #ents then
      players[pindex].nearby.index = players[pindex].nearby.index + 1
      players[pindex].nearby.selection = 1
   else
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
      players[pindex].nearby.selection = 1
   end
   mod.list_index(pindex)
end

--Repeat the current entry in the scanner list
function mod.list_current(pindex)
   if players[pindex].in_menu then
      --These keys may overlap a lot so might as well
      return
   end
   local ents = get_ents_of_scanner_category(players[pindex].nearby.category)
   --Correct an invalid index
   if players[pindex].nearby.index < 1 then
      players[pindex].nearby.index = 1
   elseif players[pindex].nearby.index > #ents then
      players[pindex].nearby.index = #ents
   end
   --Call the list index
   if not (pcall(function()
      mod.list_index(pindex)
   end)) then
      table.remove(ents, players[pindex].nearby.index)
      mod.list_current(pindex)
   end
end

--Switch to the previous instance of this scanner list entry
function mod.selection_up(pindex)
   if not players[pindex].in_menu then
      if players[pindex].nearby.selection > 1 then
         players[pindex].nearby.selection = players[pindex].nearby.selection - 1
      else
         game.get_player(pindex).play_sound({ path = "inventory-edge" })
         players[pindex].nearby.selection = 1
      end
      mod.list_index(pindex)
   end
end

--Switch to the next instance of this scanner list entry
function mod.selection_down(pindex)
   if not players[pindex].in_menu then
      local ents = get_ents_of_scanner_category(players[pindex].nearby.category)
      if next(ents) == nil then
         printout("No entities found.  Try refreshing with end key.", pindex)
      else
         if players[pindex].nearby.selection < #ents[players[pindex].nearby.index].ents then
            players[pindex].nearby.selection = players[pindex].nearby.selection + 1
         else
            game.get_player(pindex).play_sound({ path = "inventory-edge" })
            players[pindex].nearby.selection = #ents[players[pindex].nearby.index].ents
         end
      end
      mod.list_index(pindex)
   end
end

--Returns an info string about the entities and tiles found within an area scan done by an enlarged cursor.
function mod.area_scan_summary_info(scan_left_top, scan_right_bottom, pindex)
   local result = ""
   local explored_left_top = {
      x = math.floor((players[pindex].cursor_pos.x - 1 - players[pindex].cursor_size) / 32),
      y = math.floor((players[pindex].cursor_pos.y - 1 - players[pindex].cursor_size) / 32),
   }
   local explored_right_bottom = {
      x = math.floor((players[pindex].cursor_pos.x + 1 + players[pindex].cursor_size) / 32),
      y = math.floor((players[pindex].cursor_pos.y + 1 + players[pindex].cursor_size) / 32),
   }
   local count = 0
   local total = 0
   for i = explored_left_top.x, explored_right_bottom.x do
      for i1 = explored_left_top.y, explored_right_bottom.y do
         if game.get_player(pindex).surface.is_chunk_generated({ i, i1 }) then count = count + 1 end
         total = total + 1
      end
   end
   if total > 0 and count < 1 then
      result = result .. "Charted 0%, you need to chart this area by approaching it or using a radar."
      return result
   elseif total > 0 and count < total then
      result = result .. "Charted " .. math.floor((count / total) * 100) .. "%, "
   end

   local percentages = {}
   local percent_total = 0
   local surf = game.get_player(pindex).surface
   --Scan for Tiles and Resources, because they behave weirdly in scan_area due to aggregation, or are skipped
   local percent = 0
   local res_count = surf.count_tiles_filtered({
      name = { "water", "deepwater", "water-green", "deepwater-green", "water-shallow", "water-mud", "water-wube" },
      area = { scan_left_top, scan_right_bottom },
   })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "water", percent = percent, count = "resource" }) end
   percent_total = percent_total + percent --water counts as filling a space

   res_count = surf.count_tiles_filtered({ name = "stone-path", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then
      table.insert(percentages, { name = "stone-brick-path", percent = percent, count = "flooring" })
   end

   res_count = surf.count_tiles_filtered({
      name = { "concrete", "hazard-concrete-left", "hazard-concrete-right" },
      area = { scan_left_top, scan_right_bottom },
   })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "concrete", percent = percent, count = "flooring" }) end

   res_count = surf.count_tiles_filtered({
      name = { "refined-concrete", "refined-hazard-concrete-left", "refined-hazard-concrete-right" },
      area = { scan_left_top, scan_right_bottom },
   })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then
      table.insert(percentages, { name = "refined-concrete", percent = percent, count = "flooring" })
   end

   res_count = surf.count_entities_filtered({ name = "coal", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "coal", percent = percent, count = "resource" }) end

   res_count = surf.count_entities_filtered({ name = "stone", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "stone", percent = percent, count = "resource" }) end

   res_count = surf.count_entities_filtered({ name = "iron-ore", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "iron-ore", percent = percent, count = "resource" }) end

   res_count = surf.count_entities_filtered({ name = "copper-ore", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "copper-ore", percent = percent, count = "resource" }) end

   res_count = surf.count_entities_filtered({ name = "uranium-ore", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "uranium-ore", percent = percent, count = "resource" }) end

   res_count = surf.count_entities_filtered({ name = "crude-oil", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((9 * res_count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5)
   if percent > 0 then table.insert(percentages, { name = "crude-oil", percent = percent, count = "resource" }) end

   res_count = surf.count_entities_filtered({ type = "tree", area = { scan_left_top, scan_right_bottom } })
   percent = math.floor((res_count * 4 / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.5) --trees are bigger than 1 tile
   if percent > 0 then table.insert(percentages, { name = "trees", percent = percent, count = res_count }) end
   percent_total = percent_total + percent

   if #players[pindex].nearby.ents > 0 then --Note: Resources are included here as aggregates.
      for i, ent in ipairs(players[pindex].nearby.ents) do
         local area = 0
         --this confirmation is necessary because all we have is the ent name, and some distant resources show up on the list.
         if
            fa_utils.is_ent_inside_area(
               fa_utils.get_substring_before_space(fa_utils.get_substring_before_comma(ent.name)),
               scan_left_top,
               scan_right_bottom,
               pindex
            )
         then
            area = fa_utils.get_ent_area_from_name(
               fa_utils.get_substring_before_space(fa_utils.get_substring_before_comma(ent.name)),
               pindex
            )
            if area == -1 then
               area = 1
               game.get_player(pindex).print(
                  fa_utils.get_substring_before_space(fa_utils.get_substring_before_comma(ent.name))
                     .. " could not be found for the area check ",
                  { volume_modifier = 0 }
               ) --bug: unable to get area from name
            end
         end
         local percentage = math.floor(
            (area * players[pindex].nearby.ents[i].count / ((1 + players[pindex].cursor_size * 2) ^ 2) * 100) + 0.95
         ) --Tolerate up to 0.05%
         if not ent.aggregate and percentage > 0 then
            table.insert(
               percentages,
               { name = ent.name, percent = percentage, count = players[pindex].nearby.ents[i].count }
            )
         end
         percent_total = percent_total + percentage
      end
      table.sort(percentages, function(k1, k2)
         return k1.percent > k2.percent
      end)
      result = result .. " Area contains "
      local i = 1
      while i <= #percentages and (i <= 4 or percentages[i].percent > 1) do
         result = result .. ", " .. percentages[i].count .. " " .. percentages[i].name .. " "
         if percentages[i].count == "resource" or percentages[i].count == "flooring" then
            result = result .. percentages[i].percent .. "% "
         end
         i = i + 1
      end
      if percent_total == 0 then --Note there are still some entities in here, but with zero area...
         result = result .. " nothing "
      elseif i >= 4 then
         result = result .. ", and other things "
      end
      result = result .. ", total space occupied " .. math.floor(percent_total) .. " percent "
   else
      result = result .. " Empty Area  "
   end
   players[pindex].cursor_scanned = true
   return result
end

--Brief extra entity info is given here, for mentioning in the scanner list. If the parameter "info_comes_after_indexing" is not true, then this info distinguishes the entity plus its description as a new line of the scanner list, such as how assembling machines with different recipes are listed separately.
function mod.ent_extra_list_info(ent, pindex, info_comes_after_indexing)
   local result = ""

   if ent.name ~= "water" and ent.type == "mining-drill" then
      --Mining drill products
      local pos = ent.position
      local radius = ent.prototype.mining_drill_radius
      local area = { { pos.x - radius, pos.y - radius }, { pos.x + radius, pos.y + radius } }
      local resources = ent.surface.find_entities_filtered({ area = area, type = "resource" })
      local dict = {}
      for i, resource in pairs(resources) do
         if dict[resource.name] == nil then
            dict[resource.name] = resource.amount
         else
            dict[resource.name] = dict[resource.name] + resource.amount
         end
      end
      if table_size(dict) > 0 then
         result = result .. " mining From "
         for i, amount in pairs(dict) do
            result = result .. " " .. i .. " "
         end
      else
         result = result .. " out of minable resources"
      end
   end
   --Assemblers and furnaces
   pcall(function()
      if ent.get_recipe() ~= nil then
         result = result .. " producing " .. ent.get_recipe().name
      elseif ent.type == "furnace" and #ent.get_output_inventory() > 0 then
         local output_item = ent.get_output_inventory()[1]
         if output_item and output_item.valid_for_read then result = result .. " producing " .. output_item.name end
      end
   end)

   if ent.name == "entity-ghost" then
      --Ghost names
      result = " of " .. ent.ghost_name
   end

   if ent.type == "container" or ent.type == "logistic-container" then
      --Chests are identified by whether they contain nothing a specific item, or simply various items
      local itemset = ent.get_inventory(defines.inventory.chest).get_contents()
      local itemtable = {}
      for name, count in pairs(itemset) do
         table.insert(itemtable, { name = name, count = count })
      end
      --table.sort(itemtable, function(k1, k2)
      --   return k1.count > k2.count
      --end)
      if #itemtable == 0 then
         result = result .. " empty "
      elseif #itemtable == 1 then
         result = result .. " with " .. itemtable[1].name
      elseif #itemtable > 1 then
         result = result .. " with various items "
      end
   elseif ent.type == "unit-spawner" then
      --Group spawners by pollution level
      if ent.absorbed_pollution > 0 then
         result = " polluted lightly "
         if ent.absorbed_pollution > 99 then result = " polluted heavily " end
      else
         local pos = ent.position
         local pollution_nearby = false
         pollution_nearby = pollution_nearby and (ent.surface.get_pollution({ pos.x + 00, pos.y + 00 }) > 0)
         pollution_nearby = pollution_nearby and (ent.surface.get_pollution({ pos.x + 33, pos.y + 00 }) > 0)
         pollution_nearby = pollution_nearby and (ent.surface.get_pollution({ pos.x - 33, pos.y + 00 }) > 0)
         pollution_nearby = pollution_nearby and (ent.surface.get_pollution({ pos.x + 00, pos.y + 33 }) > 0)
         pollution_nearby = pollution_nearby and (ent.surface.get_pollution({ pos.x + 00, pos.y - 33 }) > 0)
         if pollution_nearby then
            result = " almost polluted " --**laterdo bug: this does not seem to ever be reached
         else
            result = " normal "
         end
      end
   end

   if info_comes_after_indexing == true and ent.train ~= nil and ent.train.valid then
      --Train name for train vehicles
      result = result .. " of train " .. fa_trains.get_train_name(ent.train)
   elseif ent.name == "character" then
      --Character names
      local p = ent.player
      local p2 = ent.associated_player
      if p ~= nil and p.valid and p.name ~= nil and p.name ~= "" then
         result = result .. " " .. p.name
      elseif p2 ~= nil and p2.valid and p2.name ~= nil and p2.name ~= "" then
         result = result .. " " .. p2.name
      elseif p ~= nil and p.valid and p.index == pindex then
         result = result .. " you "
      elseif pindex ~= nil then
         result = result .. " " .. pindex
      else
         result = result .. " X "
      end
   elseif ent.name == "character-corpse" then
      --Character corpse info
      if ent.character_corpse_player_index == pindex then
         result = result .. " of your character "
      elseif ent.character_corpse_player_index ~= nil then
         result = result .. " of another character "
      end
   elseif info_comes_after_indexing == true and ent.name == "train-stop" then
      --Train stop name
      result = result .. " " .. ent.backer_name
   elseif ent.name == "forest" then
      --Forest type by density
      result = result .. mod.classify_forest(ent.position, pindex, true, false)
   elseif ent.name == "roboport" then
      --Roboport network name
      result = result .. " of network " .. fa_bot_logistics.get_network_name(ent)
   elseif ent.type == "spider-vehicle" then
      local label = ent.entity_label
      if label == nil then label = "" end
      result = result .. label
   elseif ent.name == "pipe" or ent.name == "storage-tank" then
      --Pipe ends are labelled to distinguish them
      if ent.name == "pipe" and fa_building_tools.is_a_pipe_end(ent, pindex) then result = result .. " end, " end
      --Pipes and storage tanks are separated depending on the fluid they contain
      local dict = ent.get_fluid_contents()
      local fluids = {}
      for name, count in pairs(dict) do
         table.insert(fluids, { name = name, count = count })
      end
      if #fluids > 0 and fluids[1].count ~= nil then
         if #fluids == 1 then
            result = result .. " with " .. localising.get_fluid_from_name(fluids[1].name, pindex)
         elseif #fluids > 1 and fluids[2].count ~= nil then
            result = result .. " with multiple fluids "
         end
      else
         result = result .. " empty "
      end
   end

   return result
end

--Examines a forest position and classifies it by tree density. Used for the scanner list.
function mod.classify_forest(position, pindex, drawing_forest, drawing_trees)
   local tree_count = 0
   local tree_group = game
      .get_player(pindex).surface
      .find_entities_filtered({ type = "tree", position = position, radius = 16, limit = 15 })
   if drawing_forest == true then
      --Draw the forest checking boundaries
      rendering.draw_circle({
         color = { 0, 1, 0.25 },
         radius = 16,
         width = 4,
         target = position,
         surface = game.get_player(pindex).surface,
         time_to_live = 60,
         draw_on_ground = true,
      })
   end
   if tree_group then tree_count = #tree_group end
   if drawing_trees == true then
      for i, tree in ipairs(tree_group) do
         --Draw the trees identified
         rendering.draw_circle({
            color = { 0, 1, 0.5 },
            radius = 1,
            width = 4,
            target = tree.position,
            surface = tree.surface,
            time_to_live = 60,
            draw_on_ground = true,
         })
      end
   end
   if tree_count < 1 then
      return "empty"
   elseif tree_count < 6 then
      return "patch"
   elseif tree_count < 11 then
      return "sparse"
   else
      return "dense"
   end
end

return mod
