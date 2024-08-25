--Here: Functions related to ghosts, blueprints and blueprint books
--Does not include event handlers

local fa_utils = require("scripts.fa-utils")
local fa_building_tools = require("scripts.building-tools")
local fa_mining_tools = require("scripts.mining-tools")
local fa_graphics = require("scripts.graphics")
local dirs = defines.direction

local mod = {}

--todo cleanup blueprint calls in control.lua so that blueprint data editing calls happen only within this module

function mod.get_bp_data_for_edit(stack)
   ---@diagnostic disable-next-line: param-type-mismatch
   return game.json_to_table(game.decode_string(string.sub(stack.export_stack(), 2)))
end

--Works for blueprints and also books too
function mod.set_stack_bp_from_data(stack, bp_data)
   stack.import_stack("0" .. game.encode_string(game.table_to_json(bp_data)))
end

function mod.set_blueprint_description(stack, description)
   local bp_data = mod.get_bp_data_for_edit(stack)
   bp_data.blueprint.description = description
   mod.set_stack_bp_from_data(stack, bp_data)
end

function mod.get_blueprint_description(stack)
   local bp_data = mod.get_bp_data_for_edit(stack)
   local desc = bp_data.blueprint.description
   if desc == nil then desc = "" end
   return desc
end

function mod.set_blueprint_label(stack, label)
   local bp_data = mod.get_bp_data_for_edit(stack)
   bp_data.blueprint.label = label
   mod.set_stack_bp_from_data(stack, bp_data)
end

function mod.get_blueprint_label(stack)
   local bp_data = mod.get_bp_data_for_edit(stack)
   local label = bp_data.blueprint.label
   if label == nil then label = "" end
   return label
end

--Create a blueprint from a rectangle between any two points and give it to the player's hand
function mod.create_blueprint(pindex, point_1, point_2, prior_bp_data)
   local top_left, bottom_right = fa_utils.get_top_left_and_bottom_right(point_1, point_2)
   local p = game.get_player(pindex)
   if prior_bp_data ~= nil then
      --First clear the bp in hand
      p.cursor_stack.set_stack({ name = "blueprint", count = 1 })
   end
   if
      not p.cursor_stack.valid_for_read
      or p.cursor_stack.valid_for_read
         and not (p.cursor_stack.is_blueprint and p.cursor_stack.is_blueprint_setup() == false and prior_bp_data == nil)
   then
      local cleared = p.clear_cursor()
      if not cleared then
         printout("Error: cursor full.", pindex)
         return
      end
   end
   p.cursor_stack.set_stack({ name = "blueprint" })
   p.cursor_stack.create_blueprint({ surface = p.surface, force = p.force, area = { top_left, bottom_right } })

   --Avoid empty blueprints
   local ent_count = p.cursor_stack.get_blueprint_entity_count()
   if ent_count == 0 then
      if prior_bp_data == nil then p.cursor_stack.set_stack({ name = "blueprint" }) end
      local result = "Blueprint selection area was empty, "
      if prior_bp_data ~= nil then result = result .. " keeping old entities " end
      printout(result, pindex)
   else
      local prior_name = ""
      if prior_bp_data ~= nil then prior_name = prior_bp_data.blueprint.label or "" end
      printout("Blueprint " .. prior_name .. " with " .. ent_count .. " entities created in hand.", pindex)
   end

   --Copy label and description and icons from previous version
   if prior_bp_data ~= nil then
      local bp_data = mod.get_bp_data_for_edit(p.cursor_stack)
      bp_data.blueprint.label = prior_bp_data.blueprint.label or ""
      bp_data.blueprint.label_color = prior_bp_data.blueprint.label_color or { 1, 1, 1 }
      bp_data.blueprint.description = prior_bp_data.blueprint.description or ""
      bp_data.blueprint.icons = prior_bp_data.blueprint.icons or {}
      if ent_count == 0 then bp_data.blueprint.entities = prior_bp_data.blueprint.entities end
      mod.set_stack_bp_from_data(p.cursor_stack, bp_data)
   end

   --Use this opportunity to update saved information about the blueprint's corners (used when drawing the footprint)
   local width, height = mod.get_blueprint_width_and_height(pindex)
   players[pindex].blueprint_width_in_hand = width + 1
   players[pindex].blueprint_height_in_hand = height + 1
end

--Building function for bluelprints
function mod.paste_blueprint(pindex)
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   local pos = players[pindex].cursor_pos

   --Not a blueprint
   if bp.is_blueprint == false then return nil end
   --Empty blueprint
   if not bp.is_blueprint_setup() then return nil end

   --Get the offset blueprint positions
   local left_top, right_bottom, build_pos = mod.get_blueprint_corners(pindex, false)

   --Clear build area for objects up to a certain range, while others are marked for deconstruction
   fa_mining_tools.clear_obstacles_in_rectangle(left_top, right_bottom, pindex, 99)

   --Build it and check if successful
   local dir = players[pindex].blueprint_hand_direction
   local result = bp.build_blueprint({
      surface = p.surface,
      force = p.force,
      position = build_pos,
      direction = dir,
      by_player = p,
      force_build = false,
   })
   if result == nil or #result == 0 then
      p.play_sound({ path = "utility/cannot_build" })
      --Explain build error
      local build_area = { left_top, right_bottom }
      local result = fa_building_tools.identify_building_obstacle(pindex, build_area, nil)
      printout(result, pindex)
      return false
   else
      p.play_sound({ path = "Close-Inventory-Sound" }) --laterdo maybe better blueprint placement sound
      printout("Placed blueprint " .. mod.get_blueprint_label(bp), pindex)
      return true
   end
end

--Returns the left top and right bottom corners of the blueprint, as well as the center position
function mod.get_blueprint_corners(pindex, draw_rect)
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   if bp == nil or bp.valid_for_read == false or bp.is_blueprint == false then error("invalid call. no blueprint") end
   local pos = players[pindex].cursor_pos
   local ents = bp.get_blueprint_entities() or {}
   local west_most_x = 0
   local east_most_x = 0
   local north_most_y = 0
   local south_most_y = 0
   local first_ent = true
   --Empty blueprint: Just report the tile of the cursor
   if bp.is_blueprint_setup() == false then
      local left_top = { x = math.floor(pos.x), y = math.floor(pos.y) }
      local right_bottom = { x = math.ceil(pos.x), y = math.ceil(pos.y) }
      return left_top, right_bottom, pos
   end

   --Find the blueprint borders and corners
   for i, ent in ipairs(ents) do
      local ent_width = game.entity_prototypes[ent.name].tile_width
      local ent_height = game.entity_prototypes[ent.name].tile_height
      if ent.direction == dirs.east or ent.direction == dirs.west then
         ent_width = game.entity_prototypes[ent.name].tile_height
         ent_height = game.entity_prototypes[ent.name].tile_width
      end
      --Find the edges of this ent
      local ent_north = ent.position.y - math.floor(ent_height / 2)
      local ent_east = ent.position.x + math.floor(ent_width / 2)
      local ent_south = ent.position.y + math.floor(ent_height / 2)
      local ent_west = ent.position.x - math.floor(ent_width / 2)
      --Initialize with this entity
      if first_ent then
         first_ent = false
         west_most_x = ent_west
         east_most_x = ent_east
         north_most_y = ent_north
         south_most_y = ent_south
      else
         --Compare ent edges with the blueprint edges
         if west_most_x > ent_west then west_most_x = ent_west end
         if east_most_x < ent_east then east_most_x = ent_east end
         if north_most_y > ent_north then north_most_y = ent_north end
         if south_most_y < ent_south then south_most_y = ent_south end
      end
   end
   --Determine blueprint dimensions from the final edges
   local bp_left_top = { x = math.floor(west_most_x), y = math.floor(north_most_y) }
   local bp_right_bottom = { x = math.ceil(east_most_x), y = math.ceil(south_most_y) }
   local bp_width = bp_right_bottom.x - bp_left_top.x - 1
   local bp_height = bp_right_bottom.y - bp_left_top.y - 1
   if
      players[pindex].blueprint_hand_direction == dirs.east or players[pindex].blueprint_hand_direction == dirs.west
   then
      --Flip width and height
      bp_width = bp_right_bottom.y - bp_left_top.y - 1
      bp_height = bp_right_bottom.x - bp_left_top.x - 1
   end
   local left_top = { x = math.floor(pos.x), y = math.floor(pos.y) }
   local right_bottom = { x = math.ceil(pos.x + bp_width), y = math.ceil(pos.y + bp_height) }

   --Draw the build preview (default is false)
   if draw_rect == true then
      --Draw a temporary rectangle for debugging
      rendering.draw_rectangle({
         left_top = left_top,
         right_bottom = right_bottom,
         color = { r = 0.25, b = 0.25, g = 1.0, a = 0.75 },
         width = 2,
         draw_on_ground = true,
         surface = p.surface,
         players = nil,
         time_to_live = 100,
      })
   end

   --Get the mouse pointer position
   local mouse_pos = { x = pos.x + bp_width / 2, y = pos.y + bp_height / 2 }

   return left_top, right_bottom, mouse_pos
end

--Returns: bp_width, bp_height
function mod.get_blueprint_width_and_height(pindex)
   local p = game.get_player(pindex)
   local bp = p.cursor_stack
   if bp == nil or bp.valid_for_read == false or bp.is_blueprint == false then
      bp = game.get_player(pindex).get_main_inventory()[players[pindex].inventory.index]
   end
   if bp == nil or bp.valid_for_read == false or bp.is_blueprint == false then return nil, nil end
   local pos = players[pindex].cursor_pos
   local ents = bp.get_blueprint_entities()
   local west_most_x = 0
   local east_most_x = 0
   local north_most_y = 0
   local south_most_y = 0
   local first_ent = true

   --Empty blueprint
   if not ents or bp.is_blueprint_setup() == false then return 0, 0 end

   --Find the blueprint borders and corners
   for i, ent in ipairs(ents) do
      local ent_width = game.entity_prototypes[ent.name].tile_width
      local ent_height = game.entity_prototypes[ent.name].tile_height
      if ent.direction == dirs.east or ent.direction == dirs.west then
         ent_width = game.entity_prototypes[ent.name].tile_height
         ent_height = game.entity_prototypes[ent.name].tile_width
      end
      --Find the edges of this ent
      local ent_north = ent.position.y - math.floor(ent_height / 2)
      local ent_east = ent.position.x + math.floor(ent_width / 2)
      local ent_south = ent.position.y + math.floor(ent_height / 2)
      local ent_west = ent.position.x - math.floor(ent_width / 2)
      --Initialize with this entity
      if first_ent then
         first_ent = false
         west_most_x = ent_west
         east_most_x = ent_east
         north_most_y = ent_north
         south_most_y = ent_south
      else
         --Compare ent edges with the blueprint edges
         if west_most_x > ent_west then west_most_x = ent_west end
         if east_most_x < ent_east then east_most_x = ent_east end
         if north_most_y > ent_north then north_most_y = ent_north end
         if south_most_y < ent_south then south_most_y = ent_south end
      end
   end
   --Determine blueprint dimensions from the final edges
   local bp_left_top = { x = math.floor(west_most_x), y = math.floor(north_most_y) }
   local bp_right_bottom = { x = math.ceil(east_most_x), y = math.ceil(south_most_y) }
   local bp_width = bp_right_bottom.x - bp_left_top.x - 1
   local bp_height = bp_right_bottom.y - bp_left_top.y - 1
   if
      players[pindex].blueprint_hand_direction == dirs.east or players[pindex].blueprint_hand_direction == dirs.west
   then
      --Flip width and height
      bp_width = bp_right_bottom.y - bp_left_top.y - 1
      bp_height = bp_right_bottom.x - bp_left_top.x - 1
   end
   return bp_width, bp_height
end

--Export and import the same blueprint so that its parameters reset, e.g. rotation.
function mod.refresh_blueprint_in_hand(pindex)
   local p = game.get_player(pindex)
   if p.cursor_stack.is_blueprint_setup() == false then return end
   local bp_data = mod.get_bp_data_for_edit(p.cursor_stack)
   mod.set_stack_bp_from_data(p.cursor_stack, bp_data)
end

--Basic info for when the blueprint item is read.
function mod.get_blueprint_info(stack, in_hand, pindex)
   --Not a blueprint
   if stack.is_blueprint == false then return "" end
   --Empty blueprint
   if not stack.is_blueprint_setup() then return "Blueprint empty" end

   --Get name
   local name = mod.get_blueprint_label(stack)
   if name == nil then name = "" end
   --Construct result
   local result = "Blueprint " .. name .. " features "
   if in_hand then result = "Blueprint " .. name .. "in hand, features " end
   --Use icons as extra info (in case it is not named)
   local icons = stack.blueprint_icons
   if icons == nil or #icons == 0 then
      result = result .. " no details "
      return result
   end

   for i, signal in ipairs(icons) do
      if signal.index > 1 then result = result .. " and " end
      if signal.signal.name ~= nil then
         result = result .. signal.signal.name --***todo localise
      else
         result = result .. "unknown icon"
      end
   end

   result = result .. ", " .. stack.get_blueprint_entity_count() .. " entities in total "

   --Use this opportunity to update saved information about the blueprint's corners (used when drawing the footprint)
   if in_hand then
      local width, height = mod.get_blueprint_width_and_height(pindex)
      if width == nil or height == nil then return result end
      players[pindex].blueprint_width_in_hand = width + 1
      players[pindex].blueprint_height_in_hand = height + 1
   end
   return result
end

function mod.get_blueprint_icons_info(bp_table)
   local result = ""
   --Use icons as extra info (in case it is not named)
   local icons = bp_table.icons
   if icons == nil or #icons == 0 then
      result = result .. " no icons "
      return result
   end

   for i, signal in ipairs(icons) do
      if signal.index > 1 then result = result .. " and " end
      if signal.signal.name ~= nil then
         result = result .. signal.signal.name
      else
         result = result .. "unknown icon"
      end
   end
   return result
end

function mod.apply_blueprint_import(pindex, text)
   local bp = game.get_player(pindex).cursor_stack
   --local result = bp.import_stack("0"..text)
   local result = bp.import_stack(text)
   if result == 0 then
      if bp.is_blueprint then
         printout("Successfully imported blueprint " .. mod.get_blueprint_label(bp), pindex)
      elseif bp.is_blueprint_book then
         printout("Successfully imported blueprint book ", pindex)
      else
         printout("Successfully imported unknown planner item", pindex)
      end
   elseif result == -1 then
      if bp.is_blueprint then
         printout("Imported with errors, blueprint " .. mod.get_blueprint_label(bp), pindex)
      elseif bp.is_blueprint_book then
         printout("Imported with errors, blueprint book ", pindex)
      else
         printout("Imported with errors, unknown planner item", pindex)
      end
   else --result == 1
      printout("Failed to import blueprint item", pindex)
   end
end

--[[ Blueprint menu options summary
   0. name, menu instructions
   1. Read the description of this blueprint
   2. Read the icons of this blueprint, which are its features components
   3. Read the blueprint dimensions and total component count
   4. List all components of this blueprint
   5. List all missing components for building this blueprint 
   6. Edit the label of this blueprint
   7. Edit the description of this blueprint
   8. Create a copy of this blueprint
   9. Clear this blueprint (press twice)
   10. Export this blueprint as a text string
   11. Import a text string to overwrite this blueprint
   12. Reselect the area for this blueprint 
   13. Use the last selected area to reselect this blueprint --todo will add later***

   This menu opens when you press RIGHT BRACKET on a blueprint in hand 
]]
function mod.run_blueprint_menu(menu_index, pindex, clicked, other_input)
   local index = menu_index
   local other = other_input or -1
   local p = game.get_player(pindex)
   ---@type LuaItemStack
   local bp = p.cursor_stack

   if bp.is_blueprint_setup() == false then
      if index == 0 then
         --Give basic info ...
         printout(
            "Empty blueprint with limited options"
               .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.",
            pindex
         )
      elseif index == 1 then
         --Import a text string to save into this blueprint
         if not clicked then
            local result = "Import a text string to fill this blueprint"
            printout(result, pindex)
         else
            players[pindex].blueprint_menu.edit_import = true
            local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-import")
            local result = "Paste a copied blueprint text string in this box and then press ENTER to load it"
            printout(result, pindex)
         end
      --elseif index == 2 then --use last selected area ***
      else
         players[pindex].blueprint_menu.index = 0
         p.play_sound({ path = "inventory-wrap-around" })
         printout(
            "Empty blueprint with limited options"
               .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.",
            pindex
         )
      end
      return
   end

   if index == 0 then
      --Give basic info ...
      printout(
         "Blueprint "
            .. mod.get_blueprint_label(bp)
            .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select an option or press 'E' to exit this menu.",
         pindex
      )
   elseif index == 1 then
      --Read the description of this blueprint
      if not clicked then
         local result = "Read the description of this blueprint"
         printout(result, pindex)
      else
         local result = mod.get_blueprint_description(bp)
         if result == nil or result == "" then result = "no description" end
         printout(result, pindex)
      end
   elseif index == 2 then
      --Read the icons of this blueprint, which are its features components
      if not clicked then
         local result = "Read the icons of this blueprint, which are its featured components"
         printout(result, pindex)
      else
         local result = "This blueprint features "
         if bp.blueprint_icons and #bp.blueprint_icons > 0 then
            --Icon 1
            if bp.blueprint_icons[1] ~= nil then result = result .. bp.blueprint_icons[1].signal.name .. ", " end
            if bp.blueprint_icons[2] ~= nil then result = result .. bp.blueprint_icons[2].signal.name .. ", " end
            if bp.blueprint_icons[3] ~= nil then result = result .. bp.blueprint_icons[3].signal.name .. ", " end
            if bp.blueprint_icons[4] ~= nil then result = result .. bp.blueprint_icons[4].signal.name .. ", " end
         else
            result = result .. "nothing"
         end
         printout(result, pindex)
      end
   elseif index == 3 then
      --Read the blueprint dimensions and total component count
      if not clicked then
         local result = "Read the blueprint dimensions and total component count"
         printout(result, pindex)
      else
         local count = bp.get_blueprint_entity_count()
         local width, height = mod.get_blueprint_width_and_height(pindex)
         local result = "This blueprint is "
            .. (width + 1)
            .. " tiles wide and "
            .. (height + 1)
            .. " tiles high and contains "
            .. count
            .. " entities "
         printout(result, pindex)
      end
   elseif index == 4 then
      --List all components of this blueprint
      if not clicked then
         local result = "List all components of this blueprint"
         printout(result, pindex)
      else
         --Create a table of entity counts
         local ents = bp.get_blueprint_entities() or {}
         local ent_counts = {}
         local unique_ent_count = 0
         --p.print("blueprint total entity count: " .. #ents)--
         for i, ent in ipairs(ents) do
            local str = ent.name
            if ent_counts[str] == nil then
               ent_counts[str] = 1
               --p.print("adding " .. str)--
               unique_ent_count = unique_ent_count + 1
            else
               ent_counts[str] = ent_counts[str] + 1
               --p.print(str .. " x " .. ent_counts[str])--
            end
         end
         --p.print("blueprint unique entity count: " .. unique_ent_count)
         --Sort by count
         table.sort(ent_counts, function(a, b)
            return ent_counts[a] < ent_counts[b]
         end)
         --List results
         local result = "Blueprint contains "
         for name, count in pairs(ent_counts) do
            result = result .. count .. " " .. name .. ", "
         end
         if unique_ent_count == 0 then result = result .. "nothing" end
         printout(result, pindex)
         --p.print(result)--
      end
   elseif index == 5 then
      --List all missing components for building this blueprint from your inventory
      if not clicked then
         local result = "List all missing components for building this blueprint from your inventory"
         printout(result, pindex)
      else
         --Create a table of entity counts
         local ents = bp.get_blueprint_entities() or {}
         local ent_counts = {}
         local unique_ent_count = 0
         --p.print("blueprint total entity count: " .. #ents)--
         for i, ent in ipairs(ents) do
            local str = ent.name
            if ent_counts[str] == nil then
               ent_counts[str] = 1
               --p.print("adding " .. str)--
               unique_ent_count = unique_ent_count + 1
            else
               ent_counts[str] = ent_counts[str] + 1
               --p.print(str .. " x " .. ent_counts[str])--
            end
         end
         --p.print("blueprint unique entity count: " .. unique_ent_count)
         --Subtract inventory amounts
         local result = "Blueprint contains "
         for name, count in pairs(ent_counts) do
            local item_name = fa_utils.get_item_name_for_ent(name)
            local inv_count = p.get_main_inventory().get_item_count(item_name)
            if inv_count >= count then
               ent_counts[name] = 0
            else
               ent_counts[name] = ent_counts[name] - inv_count
            end
         end
         --Sort by count
         table.sort(ent_counts, function(a, b)
            return ent_counts[a] < ent_counts[b]
         end)
         --Read results
         local result = "You are missing "
         unique_ent_count = 0
         for name, count in pairs(ent_counts) do
            if count > 0 then
               result = result .. count .. " " .. name .. ", "
               unique_ent_count = unique_ent_count + 1
            end
         end
         if unique_ent_count == 0 then result = result .. "nothing" end
         result = result .. " to build this blueprint "
         printout(result, pindex)
         --p.print(result)--
      end
   elseif index == 6 then
      --Rename this blueprint (edit its label)
      if not clicked then
         local result = "Rename this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_label = true
         local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-label")
         local result = "Type in a new name for this blueprint and press 'ENTER' to confirm, or press 'ESC' to cancel."
         printout(result, pindex)
      end
   elseif index == 7 then
      --Rewrite the description of this blueprint
      if not clicked then
         local result = "Rewrite the description of this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_description = true
         local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-description")
         local result =
            "Type in the new description text box for this blueprint and press 'ENTER' to confirm, or press 'ESC' to cancel."
         printout(result, pindex)
      end
   elseif index == 8 then
      --Create a copy of this blueprint
      if not clicked then
         local result = "Create a copy of this blueprint"
         printout(result, pindex)
      else
         p.insert(table.deepcopy(bp))
         local result = "Blue print copy inserted to inventory"
         printout(result, pindex)
      end
   elseif index == 9 then
      --Delete this blueprint
      if not clicked then
         local result = "Delete this blueprint"
         printout(result, pindex)
      else
         bp.set_stack({ name = "blueprint", count = 1 })
         bp.set_stack(nil) --calls event handler to delete empty planners.
         local result = "Blueprint deleted and menu closed"
         printout(result, pindex)
         mod.blueprint_menu_close(pindex)
      end
   elseif index == 10 then
      --Export this blueprint as a text string
      if not clicked then
         local result = "Export this blueprint as a text string"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_export = true
         local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-export", bp.export_stack())
         local result =
            "Copy the text from this box using 'CONTROL + A' and then 'CONTROL + C' and then press ENTER to exit"
         printout(result, pindex)
      end
   elseif index == 11 then
      --Import a text string to save into this blueprint
      if not clicked then
         local result = "Import a text string to save into this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_menu.edit_import = true
         local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-import")
         local result = "Paste a copied blueprint text string in this box and then press ENTER to load it"
         printout(result, pindex)
      end
   elseif index == 12 then
      --Reselect the area for this blueprint
      if not clicked then
         local result = "Re-select the area for this blueprint"
         printout(result, pindex)
      else
         players[pindex].blueprint_reselecting = true
         local result = "Select the first point now."
         printout(result, pindex)
         mod.blueprint_menu_close(pindex, true)
      end
   end
end
BLUEPRINT_MENU_LENGTH = 12

function mod.blueprint_menu_open(pindex)
   if players[pindex].vanilla_mode then return end
   --Set the player menu tracker to this menu
   players[pindex].menu = "blueprint_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}

   --Set the menu line counter to 0
   players[pindex].blueprint_menu = {
      index = 0,
      edit_label = false,
      edit_description = false,
      edit_export = false,
      edit_import = false,
   }

   --Play sound
   game.get_player(pindex).play_sound({ path = "Open-Inventory-Sound" })

   --Load menu
   mod.run_blueprint_menu(players[pindex].blueprint_menu.index, pindex, false)
end

function mod.blueprint_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].blueprint_menu.index = 0

   --play sound
   if not mute then game.get_player(pindex).play_sound({ path = "Close-Inventory-Sound" }) end

   --Destroy text fields
   if game.get_player(pindex).gui.screen["blueprint-edit-label"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-edit-label"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-edit-description"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-edit-description"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-edit-export"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-edit-export"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-edit-import"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-edit-import"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then game.get_player(pindex).opened = nil end
end

function mod.blueprint_menu_up(pindex)
   players[pindex].blueprint_menu.index = players[pindex].blueprint_menu.index - 1
   if players[pindex].blueprint_menu.index < 0 then
      players[pindex].blueprint_menu.index = 0
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   mod.run_blueprint_menu(players[pindex].blueprint_menu.index, pindex, false)
end

function mod.blueprint_menu_down(pindex)
   players[pindex].blueprint_menu.index = players[pindex].blueprint_menu.index + 1
   if players[pindex].blueprint_menu.index > BLUEPRINT_MENU_LENGTH then
      players[pindex].blueprint_menu.index = BLUEPRINT_MENU_LENGTH
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   mod.run_blueprint_menu(players[pindex].blueprint_menu.index, pindex, false)
end

function mod.get_bp_book_data_for_edit(stack)
   ---@diagnostic disable-next-line: param-type-mismatch
   return game.json_to_table(game.decode_string(string.sub(stack.export_stack(), 2)))
end

--We run the export just once because it eats UPS
function mod.set_bp_book_data_from_cursor(pindex)
   players[pindex].blueprint_book_menu.book_data = mod.get_bp_book_data_for_edit(game.get_player(pindex).cursor_stack)
end

function mod.blueprint_book_get_label(pindex)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local label = bp_data.blueprint_book.label
   if label == nil then label = "" end
   return label
end

function mod.blueprint_book_set_label(pindex, new_name)
   local p = game.get_player(pindex)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   bp_data.blueprint_book.label = new_name
   mod.set_stack_bp_from_data(p.cursor_stack, bp_data)
end

--Basic info for when the blueprint book item is read.
function mod.get_blueprint_book_info(stack, in_hand)
   --Not a book
   if stack == nil or stack.is_blueprint_book == false then return "" end

   --Get data
   local book_data = mod.get_bp_book_data_for_edit(stack)
   local label = book_data.blueprint_book.label
   if label == nil then label = "" end
   local item_count = mod.blueprint_book_data_get_item_count(book_data)

   --Construct result
   local result = { "" }
   table.insert(result, "Blueprint book ")
   table.insert(result, label)
   if in_hand then table.insert(result, " in hand") end
   table.insert(result, ", ")
   table.insert(result, " with " .. item_count .. " items")

   return result
end

function mod.get_blueprint_book_description(stack)
   local bp_data = mod.get_bp_book_data_for_edit(stack)
   local desc = bp_data.blueprint_book.description
   if desc == nil then desc = "" end
   return desc
end

function mod.set_blueprint_book_description(pindex, new_name)
   local p = game.get_player(pindex)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   bp_data.blueprint_book.description = new_name
   mod.set_stack_bp_from_data(p.cursor_stack, bp_data)
end

function mod.blueprint_book_get_item_count(pindex)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local items = bp_data.blueprint_book.blueprints
   if items == nil or items == {} then
      return 0
   else
      return #items
   end
end

function mod.blueprint_book_data_get_item_count(book_data)
   local items = book_data.blueprint_book.blueprints
   if items == nil or items == {} then
      return 0
   else
      return #items
   end
end

--Reads a blueprint within the blueprint book
function mod.blueprint_book_read_item(pindex, i)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local items = bp_data.blueprint_book.blueprints
   return items[i]["blueprint"]
end

--Puts the book away and imports the selected blueprint to hand
function mod.blueprint_book_copy_item_to_hand(pindex, i)
   local bp_data = players[pindex].blueprint_book_menu.book_data
   local items = bp_data.blueprint_book.blueprints
   local item_string = "0" .. game.encode_string(game.table_to_json(items[i]))

   local p = game.get_player(pindex)
   p.clear_cursor()
   p.cursor_stack.import_stack(item_string)
   printout("Copied blueprint to hand", pindex)
end

--WIP: Remove a blueprint from a selected blueprint book, based on the index
function mod.blueprint_book_take_out_item(pindex, index)
   --laterdo ***
end

--WIP: Add a selected blueprint to a selected blueprint book
function mod.blueprint_book_add_item(pindex, bp)
   --laterdo ***
end

--[[ Blueprint book menu options summary
   List Mode (Press LEFT BRACKET on the BPB in hand)
   0. name, menu instructions
   X. Read/copy/take out blueprint number X
   
   Settings Mode (Press RIGHT BRACKET on the BPB in hand)
   0. name, bp count, menu instructions
   1. Read the description
   2. Read the icons, which are its featured components
   3. Rename this book
   4. Edit the description 
   5. Create a copy of this blueprint book
   6. Delete this blueprint book (press twice)
   7. Export this blueprint book as a text string
   Later: 8. Import a blueprint or book from a text string

   Note: BPB normally supports description and icons, but it is unclear whether the json tables can access these.
]]
function mod.run_blueprint_book_menu(pindex, menu_index, list_mode, left_clicked, right_clicked)
   local index = menu_index
   local p = game.get_player(pindex)
   if not (p.cursor_stack and p.cursor_stack.valid_for_read and p.cursor_stack.is_blueprint_book) then return end
   ---@type LuaItemStack
   local bpb = p.cursor_stack
   local item_count = mod.blueprint_book_get_item_count(pindex)
   --Update menu length
   players[pindex].blueprint_book_menu.menu_length = BLUEPRINT_BOOK_SETTINGS_MENU_LENGTH
   if list_mode then players[pindex].blueprint_book_menu.menu_length = item_count end

   --Run menu
   if list_mode then
      --Blueprint book list mode
      if index == 0 then
         --stuff
         printout(
            "Browsing blueprint book "
               .. mod.blueprint_book_get_label(pindex)
               .. ", with "
               .. item_count
               .. " items,"
               .. ", Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to copy a blueprint to hand, press 'E' to exit this menu.",
            pindex
         )
      else
         --Examine items
         local item = mod.blueprint_book_read_item(pindex, index)
         local name = ""
         if item == nil or item.item == nil then
            name = "Unknown item (" .. index .. ")"
         elseif item.item == "blueprint" then
            local label = item.label
            if label == nil then label = "" end
            name = "Blueprint " .. label .. ", featuring " .. mod.get_blueprint_icons_info(item)
         elseif item.item == "blueprint-book" or item.item == "blueprint_book" or item.item == "book" then
            local label = item.label
            if label == nil then label = "" end
            local book_data = players[pindex].blueprint_book_menu.book_data
            name = "Blueprint book "
               .. label
               .. ", with "
               .. mod.blueprint_book_data_get_item_count(book_data)
               .. " items "
         else
            name = "unknown item " .. item.item
         end
         if left_clicked == false and right_clicked == false then
            --Read blueprint info
            local result = name
            printout(result, pindex)
         elseif left_clicked == true and right_clicked == false then
            --Copy the blueprint to hand
            if item == nil or item.item == nil then
               printout("Cannot get this.", pindex)
            elseif item.item == "blueprint" or item.item == "blueprint-book" then
               mod.blueprint_book_copy_item_to_hand(pindex, index)
            else
               printout("Cannot get this.", pindex)
            end
         elseif left_clicked == false and right_clicked == true then
            --Take the blueprint to hand (Therefore both copy and delete)
            --...
         elseif false then
            --Delete it (press twice)
         end
      end
   else
      --Blueprint book settings mode
      if index == 0 then
         printout(
            "Settings for blueprint book "
               .. mod.blueprint_book_get_label(pindex)
               .. ", with "
               .. item_count
               .. " items,"
               .. " Press 'W' and 'S' to navigate options, press 'LEFT BRACKET' to select, press 'E' to exit this menu.",
            pindex
         )
      elseif index == 1 then
         if left_clicked ~= true then
            local result = "Read the description of this blueprint book"
            printout(result, pindex)
         else
            local result = mod.get_blueprint_book_description(bpb)
            if result == nil or result == "" then result = "no description" end
            printout(result, pindex)
         end
      elseif index == 2 then
         if left_clicked ~= true then
            local result = "Read the icons of this blueprint book, which are its featured components"
            printout(result, pindex)
         else
            local result = "This book features "
            if bpb.blueprint_icons and #bpb.blueprint_icons > 0 then
               --Icon 1
               if bpb.blueprint_icons[1] ~= nil then result = result .. bpb.blueprint_icons[1].signal.name .. ", " end
               if bpb.blueprint_icons[2] ~= nil then result = result .. bpb.blueprint_icons[2].signal.name .. ", " end
               if bpb.blueprint_icons[3] ~= nil then result = result .. bpb.blueprint_icons[3].signal.name .. ", " end
               if bpb.blueprint_icons[4] ~= nil then result = result .. bpb.blueprint_icons[4].signal.name .. ", " end
            else
               result = result .. "nothing"
            end
            printout(result, pindex)
         end
      elseif index == 3 then
         if left_clicked ~= true then
            local result = "Rename this book"
            printout(result, pindex)
         else
            players[pindex].blueprint_menu.edit_label = true
            local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-label")
            local result =
               "Type in a new name for this blueprint and press 'ENTER' to confirm, or press 'ESC' to cancel."
            printout(result, pindex)
         end
      elseif index == 4 then
         if left_clicked ~= true then
            local result = "Rewrite the description of this book"
            printout(result, pindex)
         else
            players[pindex].blueprint_menu.edit_description = true
            local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-description")
            local result =
               "Type in the new description text box for this blueprint and press 'ENTER' to confirm, or press 'ESC' to cancel."
            printout(result, pindex)
         end
      elseif index == 5 then
         if left_clicked ~= true then
            local result = "Create a copy of this blueprint book"
            printout(result, pindex)
         else
            p.insert(table.deepcopy(bpb))
            local result = "Book copy inserted to inventory"
            printout(result, pindex)
         end
      elseif index == 6 then
         if left_clicked ~= true then
            local result = "Delete this blueprint book"
            printout(result, pindex)
         else
            bpb.set_stack({ name = "blueprint", count = 1 })
            bpb.set_stack(nil) --calls event handler to delete empty planners.
            local result = "Blueprint book deleted and menu closed"
            printout(result, pindex)
            mod.blueprint_menu_close(pindex)
         end
      elseif index == 7 then
         if left_clicked ~= true then
            local result = "Export this blueprint book as a text string"
            printout(result, pindex)
         else
            players[pindex].blueprint_menu.edit_export = true
            local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-export", bpb.export_stack())
            local result =
               "Copy the text from this box using 'CONTROL + A' and then 'CONTROL + C' and then press ENTER to exit"
            printout(result, pindex)
         end
      elseif index == 8 then
         --Import a text string to overwrite this blueprint book
         if left_clicked ~= true then
            local result = "Import a text string to overwrite this blueprint book"
            printout(result, pindex)
         else
            players[pindex].blueprint_menu.edit_import = true
            local frame = fa_graphics.create_text_field_frame(pindex, "blueprint-edit-import")
            local result = "Paste a copied blueprint text string in this box and then press ENTER to load it"
            printout(result, pindex)
         end
      end
   end
end
BLUEPRINT_BOOK_SETTINGS_MENU_LENGTH = 8

function mod.blueprint_book_menu_open(pindex, open_in_list_mode)
   if players[pindex].vanilla_mode then return end
   --Set the player menu tracker to this menu
   players[pindex].menu = "blueprint_book_menu"
   players[pindex].in_menu = true
   players[pindex].move_queue = {}

   --Set the menu line counter to 0
   players[pindex].blueprint_book_menu = {
      book_data = nil,
      index = 0,
      menu_length = 0,
      list_mode = open_in_list_mode,
      edit_label = false,
      edit_description = false,
      edit_export = false,
      edit_import = false,
   }
   mod.set_bp_book_data_from_cursor(pindex)

   --Play sound
   game.get_player(pindex).play_sound({ path = "Open-Inventory-Sound" })

   --Load menu
   local bpb_menu = players[pindex].blueprint_book_menu
   mod.run_blueprint_book_menu(pindex, bpb_menu.index, bpb_menu.list_mode, false, false)
end

function mod.blueprint_book_menu_close(pindex, mute_in)
   local mute = mute_in
   --Set the player menu tracker to none
   players[pindex].menu = "none"
   players[pindex].in_menu = false

   --Set the menu line counter to 0
   players[pindex].blueprint_book_menu.index = 0

   --play sound
   if not mute then game.get_player(pindex).play_sound({ path = "Close-Inventory-Sound" }) end

   --Destroy text fields
   if game.get_player(pindex).gui.screen["blueprint-book-edit-label"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-book-edit-label"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-book-edit-description"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-book-edit-description"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-book-edit-export"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-book-edit-export"].destroy()
   end
   if game.get_player(pindex).gui.screen["blueprint-book-edit-import"] ~= nil then
      game.get_player(pindex).gui.screen["blueprint-book-edit-import"].destroy()
   end
   if game.get_player(pindex).opened ~= nil then game.get_player(pindex).opened = nil end
end

function mod.blueprint_book_menu_up(pindex)
   players[pindex].blueprint_book_menu.index = players[pindex].blueprint_book_menu.index - 1
   if players[pindex].blueprint_book_menu.index < 0 then
      players[pindex].blueprint_book_menu.index = 0
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   local bpb_menu = players[pindex].blueprint_book_menu
   mod.run_blueprint_book_menu(pindex, bpb_menu.index, bpb_menu.list_mode, false, false)
end

function mod.blueprint_book_menu_down(pindex)
   players[pindex].blueprint_book_menu.index = players[pindex].blueprint_book_menu.index + 1
   if players[pindex].blueprint_book_menu.index > players[pindex].blueprint_book_menu.menu_length then
      players[pindex].blueprint_book_menu.index = players[pindex].blueprint_book_menu.menu_length
      game.get_player(pindex).play_sound({ path = "inventory-edge" })
   else
      --Play sound
      game.get_player(pindex).play_sound({ path = "Inventory-Move" })
   end
   --Load menu
   local bpb_menu = players[pindex].blueprint_book_menu
   mod.run_blueprint_book_menu(pindex, bpb_menu.index, bpb_menu.list_mode, false, false)
end

--TODO WIP ****
function mod.add_blueprint_to_book(pindex, book_stack, bp_stack)
   local p = game.get_player(pindex)
   local bp_data = mod.get_bp_data_for_edit(bp_stack)
   local book_data = mod.get_bp_book_data_for_edit(book_stack)
   local items = book_data.blueprint_book.blueprints
   local item_count = mod.blueprint_book_data_get_item_count(book_data)
   if item_count == 0 then
      items = {}
   else
      for i, item in ipairs(items) do
         game.print(item["index"] .. " : " .. item["blueprint"])
      end
   end
   items[item_count]["index"] = item_count
   items[item_count]["blueprint"] = bp_data
   book_data.blueprint_book.blueprints = items
   mod.set_stack_bp_from_data(book_stack, book_data)
   printout("Added blueprint copy to book", pindex)
end

function mod.copy_selected_area_to_clipboard(pindex, point_1, point_2)
   local top_left, bottom_right = fa_utils.get_top_left_and_bottom_right(point_1, point_2)
   local p = game.get_player(pindex)
   if p.cursor_stack == nil or p.cursor_stack.valid_for_read == false then return end
   p.cursor_stack.set_stack({ name = "blueprint", count = 1 })
   p.cursor_stack.create_blueprint({ surface = p.surface, force = p.force, area = { top_left, bottom_right } })
   if
      not (
         p.cursor_stack
         and p.cursor_stack.valid_for_read
         and p.cursor_stack.is_blueprint
         and p.cursor_stack.is_blueprint_setup()
      )
   then
      p.clear_cursor()
      p.cursor_stack.set_stack({ name = "copy-paste-tool", count = 1 })
      printout("Copied nothing", pindex)
      return
   end
   p.add_to_clipboard(p.cursor_stack)
   p.clear_cursor()
   p.activate_paste()

   --Use this opportunity to update saved information about the blueprint's corners (used when drawing the footprint)
   local width, height = mod.get_blueprint_width_and_height(pindex)
   players[pindex].blueprint_width_in_hand = width + 1
   players[pindex].blueprint_height_in_hand = height + 1
end

return mod
