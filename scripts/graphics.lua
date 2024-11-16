--Here: Mod GUI and graphics drawing
--Note: Does not include every single rendering call made by the mod, such as circles being drawn by obstacle clearing.

local fa_utils = require("scripts.fa-utils")
local fa_mouse = require("scripts.mouse")
local dirs = defines.direction

local mod = {}

--Shows a GUI to demonstrate different sprites from the game files.
function mod.show_sprite_demo(pindex)
   --Set these 5 sprites to sprites that you want to demo
   local sprite1 = "utility.decorative_editor_icon"
   local sprite2 = "item-group.signals"
   local sprite3 = "utility.select_icon_white"
   local sprite4 = "utility.white_square"
   local sprite5 = "utility.editor_selection"
   --center
   --bookmark

   --Let the gunction do the rest. Clear it with CTRL + ALT + R
   local player = players[pindex]
   local p = game.get_player(pindex)

   local f = nil
   local s1 = nil
   local s2 = nil
   local s3 = nil
   local s4 = nil
   local s5 = nil
   --Set the frame
   if f == nil or not f.valid then
      f = game.get_player(pindex).gui.screen.add({ type = "frame" })
      f.force_auto_center()
      f.bring_to_front()
   end
   --Set the main sprite
   if s1 == nil or not s1.valid then s1 = f.add({ type = "sprite", caption = "custom menu" }) end
   if s1.sprite ~= sprite1 then s1.sprite = sprite1 end
   if s2 == nil or not s2.valid then s2 = f.add({ type = "sprite", caption = "custom menu" }) end
   if s2.sprite ~= sprite2 then s2.sprite = sprite2 end
   if s3 == nil or not s3.valid then s3 = f.add({ type = "sprite", caption = "custom menu" }) end
   if s3.sprite ~= sprite3 then s3.sprite = sprite3 end
   if s4 == nil or not s4.valid then s4 = f.add({ type = "sprite", caption = "custom menu" }) end
   if s4.sprite ~= sprite4 then s4.sprite = sprite4 end
   if s5 == nil or not s5.valid then s5 = f.add({ type = "sprite", caption = "custom menu" }) end
   if s5.sprite ~= sprite5 then s5.sprite = sprite5 end

   --test style changes...
   s5.style.size = 5
end

--For each player, checks the open menu and appropriately calls to update the overhead sprite and the open GUI.
function mod.update_menu_visuals()
   for pindex, player in pairs(players) do
      if player.in_menu then
         if player.menu == "technology" then
            mod.update_overhead_sprite("item.lab", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.lab", 3, pindex)
         elseif player.menu == "inventory" then
            mod.update_overhead_sprite("item.wooden-chest", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.wooden-chest", 3, pindex)
            if players[pindex].vanilla_mode then mod.update_custom_GUI_sprite(nil, 1, pindex) end
         elseif player.menu == "crafting" then
            mod.update_overhead_sprite("item.repair-pack", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.repair-pack", 3, pindex)
         elseif player.menu == "crafting_queue" then
            mod.update_overhead_sprite("item.repair-pack", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.repair-pack", 3, pindex, "utility.clock")
         elseif player.menu == "player_trash" then
            mod.update_overhead_sprite("utility.trash_white", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("utility.trash_white", 3, pindex)
         elseif player.menu == "guns" then
            mod.update_overhead_sprite("item.pistol", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.pistol", 1, pindex)
         elseif player.menu == "travel" then
            mod.update_overhead_sprite("utility.downloading", 1.5, 1.25, pindex)
            mod.update_custom_GUI_sprite("utility.downloading", 3, pindex)
         elseif player.menu == "warnings" then
            mod.update_overhead_sprite("utility.warning_white", 3, 1.25, pindex)
            mod.update_custom_GUI_sprite("utility.warning_white", 3, pindex)
         elseif player.menu == "rail_builder" then
            mod.update_overhead_sprite("item.rail", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.rail", 3, pindex)
         elseif player.menu == "train_menu" then
            mod.update_overhead_sprite("item.locomotive", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.locomotive", 3, pindex)
         elseif player.menu == "spider_menu" then
            mod.update_overhead_sprite("item.spidertron", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.spidertron", 3, pindex)
         elseif player.menu == "train_stop_menu" then
            mod.update_overhead_sprite("item.train-stop", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.train-stop", 3, pindex)
         elseif player.menu == "roboport_menu" then
            mod.update_overhead_sprite("item.roboport", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.roboport", 3, pindex)
         elseif player.menu == "blueprint_menu" then
            mod.update_overhead_sprite("item.blueprint", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.blueprint", 3, pindex)
         elseif player.menu == "blueprint_book_menu" then
            mod.update_overhead_sprite("item.blueprint-book", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.blueprint-book", 3, pindex)
         elseif player.menu == "circuit_network_menu" then
            mod.update_overhead_sprite("item.electronic-circuit", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.electronic-circuit", 3, pindex)
         elseif player.menu == "signal_selector" then
            local sprite = "item-group.signals"
            mod.update_overhead_sprite(sprite, 1, 1.25, pindex)
            mod.update_custom_GUI_sprite(sprite, 0.5, pindex)
         elseif player.menu == "pump" then
            mod.update_overhead_sprite("item.offshore-pump", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite("item.offshore-pump", 3, pindex)
         elseif player.menu == "belt" then
            mod.update_overhead_sprite("item.transport-belt", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite(nil, 1, pindex)
         elseif players[pindex].menu == "building" or players[pindex].menu == "vehicle" then
            if game.get_player(pindex).opened == nil then
               --Open building menu with no GUI
               mod.update_overhead_sprite("utility.search", 2, 1.25, pindex)
               mod.update_custom_GUI_sprite("utility.search", 3, pindex)
            else
               --A building with a GUI is open
               mod.update_overhead_sprite("utility.search", 2, 1.25, pindex)
               mod.update_custom_GUI_sprite(nil, 1, pindex)
            end
         elseif players[pindex].menu == "building_no_sectors" or players[pindex].menu == "vehicle_no_sectors" then
            if game.get_player(pindex).opened == nil then
               --Open building menu with no GUI
               mod.update_overhead_sprite("utility.search", 2, 1.25, pindex)
               mod.update_custom_GUI_sprite("utility.search", 3, pindex, "utility.questionmark")
            else
               --A building with a GUI is open
               mod.update_overhead_sprite("utility.search", 2, 1.25, pindex)
               mod.update_custom_GUI_sprite(nil, 1, pindex)
            end
         else
            --Other menu type ...
            if player.vanilla_mode then
               --No "missing image"
               mod.update_overhead_sprite(nil, 1, 1, pindex)
               mod.update_custom_GUI_sprite(nil, 1, pindex)
            else
               --"Missing image"
               mod.update_overhead_sprite("utility.select_icon_white", 1, 1, pindex)
               mod.update_custom_GUI_sprite("utility.select_icon_white", 1, pindex)
            end
         end
      else
         if game.get_player(pindex).opened ~= nil then
            --Not in menu, but open GUI
            mod.update_overhead_sprite("utility.white_square", 2, 1.25, pindex)
            mod.update_custom_GUI_sprite(nil, 1, pindex)
         else
            --Not in menu, no open GUI
            mod.update_overhead_sprite(nil, 1, 1, pindex)
            mod.update_custom_GUI_sprite(nil, 1, pindex)
         end
      end
   end
end

--Updates graphics to match the mod's current construction preview in hand.
--Draws stuff like the building footprint, direction indicator arrow, selection tool selection box.
--Also moves the mouse pointer to hold the preview at the correct position on screen.
function mod.sync_build_cursor_graphics(pindex)
   local player = players[pindex]
   if player == nil or player.player.character == nil then return end
   local p = game.get_player(pindex)
   local stack = game.get_player(pindex).cursor_stack
   if player.building_direction == nil then player.building_direction = dirs.north end
   turn_to_cursor_direction_cardinal(pindex)
   local dir = player.building_direction
   local dir_indicator = player.building_dir_arrow
   local p_dir = player.player_direction
   local width = nil
   local height = nil
   local left_top = nil
   local right_bottom = nil
   if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result then
      --Redraw direction indicator arrow
      if dir_indicator ~= nil then player.building_dir_arrow.destroy() end
      local arrow_pos = player.cursor_pos
      if players[pindex].build_lock and not players[pindex].cursor and stack.name ~= "rail" then
         arrow_pos =
            fa_utils.center_of_tile(fa_utils.offset_position_legacy(arrow_pos, players[pindex].player_direction, -2))
      end
      player.building_dir_arrow = rendering.draw_sprite({
         sprite = "fluid.crude-oil",
         tint = { r = 0.25, b = 0.25, g = 1.0, a = 0.75 },
         render_layer = "254",
         surface = game.get_player(pindex).surface,
         players = nil,
         target = arrow_pos,
         orientation = dir / (2 * dirs.south),
      })
      dir_indicator = player.building_dir_arrow
      --rendering.set_visible(dir_indicator, true)
      if
         players[pindex].hide_cursor
         or stack.name == "locomotive"
         or stack.name == "cargo-wagon"
         or stack.name == "fluid-wagon"
         or stack.name == "artillery-wagon"
      then
         --rendering.set_visible(dir_indicator, false)
      end

      --Redraw footprint (ent)
      if player.building_footprint ~= nil then player.building_footprint.destroy() end

      --Get correct width and height
      width = stack.prototype.place_result.tile_width
      height = stack.prototype.place_result.tile_height
      if dir == dirs.east or dir == dirs.west then
         --Flip width and height. Note: diagonal cases are rounded to north/south cases
         height = stack.prototype.place_result.tile_width
         width = stack.prototype.place_result.tile_height
      end

      left_top = { x = math.floor(player.cursor_pos.x), y = math.floor(player.cursor_pos.y) }
      right_bottom = { x = (left_top.x + width), y = (left_top.y + height) }

      if not player.cursor then
         --Apply offsets when facing west or north so that items can be placed in front of the character
         if p_dir == dirs.west then
            left_top.x = (left_top.x - width + 1)
            right_bottom.x = (right_bottom.x - width + 1)
         elseif p_dir == dirs.north then
            left_top.y = (left_top.y - height + 1)
            right_bottom.y = (right_bottom.y - height + 1)
         end

         --In build lock mode and outside cursor mode, build from behind the player
         if players[pindex].build_lock and not players[pindex].cursor and stack.name ~= "rail" then
            local base_offset = -2
            local size_offset = 0
            if p_dir == dirs.north or p_dir == dirs.south then
               size_offset = -height + 1
            elseif p_dir == dirs.east or p_dir == dirs.west then
               size_offset = -width + 1
            end
            left_top =
               fa_utils.offset_position_legacy(left_top, players[pindex].player_direction, base_offset + size_offset)
            right_bottom = fa_utils.offset_position_legacy(
               right_bottom,
               players[pindex].player_direction,
               base_offset + size_offset
            )
         end
      end

      --Update the footprint info and draw it
      player.building_footprint_left_top = left_top
      player.building_footprint_right_bottom = right_bottom
      player.building_footprint = rendering.draw_rectangle({
         left_top = left_top,
         right_bottom = right_bottom,
         color = { r = 0.25, b = 0.25, g = 1.0, a = 0.75 },
         draw_on_ground = true,
         surface = game.get_player(pindex).surface,
         players = nil,
      })
      --rendering.set_visible(player.building_footprint, true)

      --Hide the drawing in the desired cases
      if
         players[pindex].hide_cursor
         or stack.name == "locomotive"
         or stack.name == "cargo-wagon"
         or stack.name == "fluid-wagon"
         or stack.name == "artillery-wagon"
      then
         --rendering.set_visible(player.building_footprint, false)
      end

      --Move mouse pointer according to building box
      if player.cursor then
         --Adjust for cursor
         local new_pos = { x = (left_top.x + width / 2), y = (left_top.y + height / 2) }
         fa_mouse.move_mouse_pointer(new_pos, pindex)
      else
         --Adjust for direct placement
         local pos = player.cursor_pos
         if p_dir == dirs.north then
            pos = fa_utils.offset_position_legacy(pos, dirs.north, height / 2 - 0.5)
            pos = fa_utils.offset_position_legacy(pos, dirs.east, width / 2 - 0.5)
         elseif p_dir == dirs.east then
            pos = fa_utils.offset_position_legacy(pos, dirs.south, height / 2 - 0.5)
            pos = fa_utils.offset_position_legacy(pos, dirs.east, width / 2 - 0.5)
         elseif p_dir == dirs.south then
            pos = fa_utils.offset_position_legacy(pos, dirs.south, height / 2 - 0.5)
            pos = fa_utils.offset_position_legacy(pos, dirs.east, width / 2 - 0.5)
         elseif p_dir == dirs.west then
            pos = fa_utils.offset_position_legacy(pos, dirs.south, height / 2 - 0.5)
            pos = fa_utils.offset_position_legacy(pos, dirs.west, width / 2 - 0.5)
         end

         --In build lock mode and outside cursor mode, build from behind the player
         if players[pindex].build_lock and not players[pindex].cursor and stack.name ~= "rail" then
            local base_offset = -2
            local size_offset = 0
            if p_dir == dirs.north or p_dir == dirs.south then
               size_offset = -height + 1
            elseif p_dir == dirs.east or p_dir == dirs.west then
               size_offset = -width + 1
            end
            pos = fa_utils.offset_position_legacy(pos, players[pindex].player_direction, base_offset + size_offset)
         end
         fa_mouse.move_mouse_pointer(pos, pindex)
      end
   elseif stack == nil or not stack.valid_for_read then
      --Invalid stack: Hide the objects
      --if dir_indicator ~= nil then rendering.set_visible(dir_indicator, false) end
      --if player.building_footprint ~= nil then rendering.set_visible(player.building_footprint, false) end
   elseif
      stack
      and stack.valid_for_read
      and stack.is_blueprint
      and stack.is_blueprint_setup()
      and players[pindex].blueprint_reselecting ~= true
   then
      --Blueprints have their own data:
      --Redraw the direction indicator arrow
      if dir_indicator ~= nil then player.building_dir_arrow.destroy() end
      local arrow_pos = player.cursor_pos
      local dir = players[pindex].blueprint_hand_direction
      if dir == nil then
         players[pindex].blueprint_hand_direction = dirs.north
         dir = dirs.north
      end
      player.building_dir_arrow = rendering.draw_sprite({
         sprite = "fluid.crude-oil",
         tint = { r = 0.25, b = 0.25, g = 1.0, a = 0.75 },
         render_layer = "254",
         surface = game.get_player(pindex).surface,
         players = nil,
         target = arrow_pos,
         orientation = dir / (2 * dirs.south),
      })
      dir_indicator = player.building_dir_arrow
      --rendering.set_visible(dir_indicator, true)

      --Redraw the bp footprint
      if player.building_footprint ~= nil then player.building_footprint.destroy() end
      local bp_width = players[pindex].blueprint_width_in_hand
      local bp_height = players[pindex].blueprint_height_in_hand
      if bp_width ~= nil then
         local left_top = { x = math.floor(player.cursor_pos.x), y = math.floor(player.cursor_pos.y) }
         local right_bottom = { x = (left_top.x + bp_width), y = (left_top.y + bp_height) }
         local center_pos = { x = (left_top.x + bp_width / 2), y = (left_top.y + bp_height / 2) }
         player.building_footprint = rendering.draw_rectangle({
            left_top = left_top,
            right_bottom = right_bottom,
            color = { r = 0.25, b = 0.25, g = 1.0, a = 0.75 },
            width = 2,
            draw_on_ground = true,
            surface = p.surface,
            players = nil,
         })
         --rendering.set_visible(player.building_footprint, true)

         --Move the mouse pointer
         if players[pindex].remote_view == true then
            fa_mouse.move_mouse_pointer(center_pos, pindex)
         elseif fa_mouse.cursor_position_is_on_screen_with_player_centered(pindex) then
            fa_mouse.move_mouse_pointer(center_pos, pindex)
         else
            fa_mouse.move_mouse_pointer(players[pindex].position, pindex)
         end
      end
   else
      --Hide the objects
      --if dir_indicator ~= nil then rendering.set_visible(dir_indicator, false) end
      --if player.building_footprint ~= nil then rendering.set_visible(player.building_footprint, false) end

      --Tile placement preview
      if stack.valid and stack.prototype.place_as_tile_result and players[pindex].blueprint_reselecting ~= true then
         local left_top = {
            math.floor(players[pindex].cursor_pos.x) - players[pindex].cursor_size,
            math.floor(players[pindex].cursor_pos.y) - players[pindex].cursor_size,
         }
         local right_bottom = {
            math.floor(players[pindex].cursor_pos.x) + players[pindex].cursor_size + 1,
            math.floor(players[pindex].cursor_pos.y) + players[pindex].cursor_size + 1,
         }
         mod.draw_large_cursor(left_top, right_bottom, pindex, { r = 0.25, b = 0.25, g = 1.0, a = 0.75 })
      elseif
         (
            stack.is_blueprint
            or stack.is_deconstruction_item
            or stack.is_upgrade_item
            or stack.prototype.type == "selection-tool"
            or stack.prototype.type == "copy-paste-tool"
         ) and (players[pindex].bp_selecting == true)
      then
         --Draw planner rectangles
         local top_left, bottom_right =
            fa_utils.get_top_left_and_bottom_right(players[pindex].bp_select_point_1, players[pindex].cursor_pos)
         local color = { 1, 1, 1 }
         if stack.is_blueprint then
            color = { r = 0.25, b = 1.00, g = 0.50, a = 0.75 }
         elseif stack.is_deconstruction_item then
            color = { r = 1.00, b = 0.25, g = 0.50, a = 0.75 }
         elseif stack.is_upgrade_item then
            color = { r = 0.25, b = 0.25, g = 1.00, a = 0.75 }
         end
         player.building_footprint = rendering.draw_rectangle({
            color = color,
            width = 2,
            surface = game.get_player(pindex).surface,
            left_top = top_left,
            right_bottom = bottom_right,
            draw_on_ground = false,
            players = nil,
         })
         --rendering.set_visible(player.building_footprint, true)
      end
   end

   --Recolor cursor boxes if multiplayer
   if game.is_multiplayer() then mod.set_cursor_colors_to_player_colors(pindex) end
end

--Draws the mod cursor box and highlights an entity selected by the cursor. Also moves the mouse pointer to the mod cursor position.
function mod.draw_cursor_highlight(pindex, ent, box_type, skip_mouse_movement)
   local p = game.get_player(pindex)
   local c_pos = players[pindex].cursor_pos
   local h_box = players[pindex].cursor_ent_highlight_box
   local h_tile = players[pindex].cursor_tile_highlight_box
   if c_pos == nil then return end
   if h_box ~= nil and h_box.valid then h_box.destroy() end
   if h_tile ~= nil and h_tile.valid then h_tile.destroy() end

   --Skip drawing if hide cursor is enabled
   if players[pindex].hide_cursor then
      players[pindex].cursor_ent_highlight_box = nil
      players[pindex].cursor_tile_highlight_box = nil
      return
   end

   --Draw highlight box
   if ent ~= nil and ent.valid and ent.name ~= "highlight-box" and (p.selected == nil or p.selected.valid == false) then
      h_box = p.surface.create_entity({
         name = "highlight-box",
         force = "neutral",
         surface = p.surface,
         render_player_index = pindex,
         box_type = "entity",
         position = c_pos,
         source = ent,
      })
      if box_type ~= nil then
         h_box.highlight_box_type = box_type
      else
         h_box.highlight_box_type = "entity"
      end
   end

   --Highlight the currently focused ground tile.
   if math.floor(c_pos.x) == math.ceil(c_pos.x) then c_pos.x = c_pos.x - 0.01 end
   if math.floor(c_pos.y) == math.ceil(c_pos.y) then c_pos.y = c_pos.y - 0.01 end
   h_tile = rendering.draw_rectangle({
      color = { 0.75, 1, 1, 0.75 },
      surface = p.surface,
      draw_on_ground = true,
      players = nil,
      left_top = { math.floor(c_pos.x) + 0.05, math.floor(c_pos.y) + 0.05 },
      right_bottom = { math.ceil(c_pos.x) - 0.05, math.ceil(c_pos.y) - 0.05 },
   })

   players[pindex].cursor_ent_highlight_box = h_box
   players[pindex].cursor_tile_highlight_box = h_tile

   --Recolor cursor boxes if multiplayer
   if game.is_multiplayer() then mod.set_cursor_colors_to_player_colors(pindex) end

   --Highlight nearby entities by default means (reposition the cursor)
   if players[pindex].vanilla_mode or skip_mouse_movement == true then return end
   local stack = game.get_player(pindex).cursor_stack
   if
      stack ~= nil
      and stack.valid_for_read
      and stack.valid
      and (stack.prototype.place_result ~= nil or stack.is_blueprint)
   then
      return
   end

   --Move the mouse cursor to the object on screen or to the player position for objects off screen
   if players[pindex].remote_view == true then
      fa_mouse.move_mouse_pointer(fa_utils.center_of_tile(c_pos), pindex)
   elseif fa_mouse.cursor_position_is_on_screen_with_player_centered(pindex) then
      fa_mouse.move_mouse_pointer(fa_utils.center_of_tile(c_pos), pindex)
   else
      fa_mouse.move_mouse_pointer(fa_utils.center_of_tile(p.position), pindex)
   end
end

--Redraws the player's cursor highlight box as a rectangle around the defined area.
function mod.draw_large_cursor(input_left_top, input_right_bottom, pindex, colour_in)
   local h_tile = players[pindex].cursor_tile_highlight_box
   if h_tile ~= nil then h_tile.destroy() end
   local colour = { 0.75, 1, 1 }
   if colour_in ~= nil then colour = colour_in end
   h_tile = rendering.draw_rectangle({
      color = colour,
      surface = game.get_player(pindex).surface,
      left_top = input_left_top,
      right_bottom = input_right_bottom,
      draw_on_ground = true,
      players = nil,
   })
   --rendering.set_visible(h_tile, true)
   players[pindex].cursor_tile_highlight_box = h_tile

   --Recolor cursor boxes if multiplayer
   if game.is_multiplayer() then mod.set_cursor_colors_to_player_colors(pindex) end
end

---@param sig SignalID
local function sprite_name(sig)
   local typemap = {
      item = "item",
      fluid = "fluid",
      virtual = "virtual-signal",
   }
   return typemap[sig.type] .. "." .. sig.name
end

---@param elem LuaGuiElement
---@param icon BlueprintSignalIcon | nil
local function prep_blueprint_icon(elem, icon)
   if icon and icon.signal and icon.signal.name then
      elem.sprite = sprite_name(icon.signal)
      elem.visible = true
   else
      elem.visible = false
   end
end

--Draws a custom GUI with a sprite in the middle of the screen. Set it to nil to clear it.
function mod.update_custom_GUI_sprite(sprite, scale_in, pindex, sprite_2)
   local player = players[pindex]
   local p = game.get_player(pindex)

   if sprite == nil then
      if player.custom_GUI_frame ~= nil and player.custom_GUI_frame.valid then
         player.custom_GUI_frame.visible = false
      end
      return
   else
      local f = player.custom_GUI_frame
      local s1 = player.custom_GUI_sprite
      local s2 = player.custom_GUI_sprite_2
      --Set the frame
      if f == nil or not f.valid then
         f = game.get_player(pindex).gui.screen.add({ type = "frame" })
         f.force_auto_center()
         f.bring_to_front()
      end
      --Set the main sprite
      if s1 == nil or not s1.valid then
         s1 = f.add({ type = "sprite", caption = "custom menu" })
         player.custom_GUI_sprite = s1
      end
      if s1.sprite ~= sprite then s1.sprite = sprite end
      --Set the secondary sprite
      if sprite_2 == nil and s2 ~= nil and s2.valid then
         player.custom_GUI_sprite_2.visible = false
      elseif sprite_2 ~= nil then
         if s2 == nil or not s2.valid then
            s2 = f.add({ type = "sprite", caption = "custom menu" })
            player.custom_GUI_sprite_2 = s2
         end
         if s2.sprite ~= sprite_2 then s2.sprite = sprite_2 end
         player.custom_GUI_sprite_2.visible = true
      end
      --If a blueprint is in hand, set the blueprint sprites
      if
         players[pindex].menu == "blueprint_menu"
         and p.cursor_stack
         and p.cursor_stack.valid_for_read
         and p.cursor_stack.is_blueprint
      then
         local bp = p.cursor_stack
         local bp_icons = bp.preview_icons or {}
         for i = 1, 4 do
            local player_sprite_handle = "custom_GUI_sprite_" .. (i + 1)
            local icon_sprite = player[player_sprite_handle]
            if icon_sprite == nil or not icon_sprite.valid then
               icon_sprite = f.add({ type = "sprite", caption = "custom menu" })
               player[player_sprite_handle] = icon_sprite
            end
            prep_blueprint_icon(icon_sprite, bp_icons[i])
         end
      end

      --Finalize
      f.visible = true
      player.custom_GUI_frame = f
      f.bring_to_front()
   end
end

function mod.clear_player_GUI_remnants(pindex)
   local p = game.get_player(pindex)
   if
      players[pindex].in_menu == false
      and players[pindex].menu == "none"
      and p.opened == nil
      and players[pindex].text_field_open ~= true
   then
      if p and p.gui and p.gui.screen then p.gui.screen.clear() end
   end
end

--Draws a sprite over the head of the player, with the selected scale. Set it to nil to clear it.
function mod.update_overhead_sprite(sprite, scale_in, radius_in, pindex)
   local player = players[pindex]
   local p = game.get_player(pindex)
   local scale = scale_in
   local radius = radius_in

   if player.overhead_circle ~= nil then player.overhead_circle.destroy() end
   if player.overhead_sprite ~= nil then player.overhead_sprite.destroy() end
   if sprite ~= nil then
      player.overhead_circle = rendering.draw_circle({
         color = { r = 0.2, b = 0.2, g = 0.2, a = 0.9 },
         radius = radius,
         draw_on_ground = true, --laterdo figure out render layer blend issue
         surface = p.surface,
         target = { x = p.position.x, y = p.position.y - 3 - radius },
         filled = true,
         time_to_live = 60,
      })
      --rendering.set_visible(player.overhead_circle, true)
      player.overhead_sprite = rendering.draw_sprite({
         sprite = sprite,
         x_scale = scale,
         y_scale = scale, --tint = {r = 0.9, b = 0.9, g = 0.9, a = 1.0},
         surface = p.surface,
         target = { x = p.position.x, y = p.position.y - 3 - radius },
         orientation = 0,
         time_to_live = 60,
      })
      --rendering.set_visible(player.overhead_sprite, true)
   end
end

--Recolors the mod cursor box to match the player's color. Useful in multiplayer when multiple cursors are on screen.
function mod.set_cursor_colors_to_player_colors(pindex)
   if not check_for_player(pindex) then return end
   local p = game.get_player(pindex)
   if
      players[pindex].cursor_tile_highlight_box ~= nil and rendering.is_valid(players[pindex].cursor_tile_highlight_box)
   then
      rendering.set_color(players[pindex].cursor_tile_highlight_box, p.color)
   end
   if players[pindex].building_footprint ~= nil and rendering.is_valid(players[pindex].building_footprint) then
      rendering.set_color(players[pindex].building_footprint, p.color)
   end
end

function mod.create_text_field_frame(pindex, frame_name, frame_text)
   players[pindex].text_field_open = true
   local text = frame_text or ""
   local frame = game.get_player(pindex).gui.screen.add({ type = "frame", name = frame_name })
   frame.bring_to_front()
   frame.force_auto_center()
   frame.focus()
   local input = frame.add({ type = "textfield", name = "input", text = text })
   input.focus()
   return frame
end

return mod
