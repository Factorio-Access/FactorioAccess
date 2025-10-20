---Centralized build dimension calculation
---Determines the dimensions of items in hand (blueprints, entities, tiles)

local mod = {}

-- Special cases where we cannot compute off the game's datga, but where we can do the right thing by hardcoding.
local SPECIAL_CASES = {
   ["offshore-pump"] = { width = 3, height = 2 },
}

---Analyze blueprint to determine base dimensions (before rotation)
---@param stack LuaItemStack The blueprint stack
---@return integer|nil width The width in tiles (north orientation)
---@return integer|nil height The height in tiles (north orientation)
local function analyze_blueprint_base_dimensions(stack)
   if not stack.is_blueprint_setup() then return 0, 0 end

   local ents = stack.get_blueprint_entities()
   if not ents then return 0, 0 end

   local west_most_x = 0
   local east_most_x = 0
   local north_most_y = 0
   local south_most_y = 0
   local first_ent = true

   for i, ent in ipairs(ents) do
      local ent_width = prototypes.entity[ent.name].tile_width
      local ent_height = prototypes.entity[ent.name].tile_height
      if ent.direction == defines.direction.east or ent.direction == defines.direction.west then
         ent_width = prototypes.entity[ent.name].tile_height
         ent_height = prototypes.entity[ent.name].tile_width
      end

      local ent_north = ent.position.y - math.floor(ent_height / 2)
      local ent_east = ent.position.x + math.floor(ent_width / 2)
      local ent_south = ent.position.y + math.floor(ent_height / 2)
      local ent_west = ent.position.x - math.floor(ent_width / 2)

      if first_ent then
         first_ent = false
         west_most_x = ent_west
         east_most_x = ent_east
         north_most_y = ent_north
         south_most_y = ent_south
      else
         if west_most_x > ent_west then west_most_x = ent_west end
         if east_most_x < ent_east then east_most_x = ent_east end
         if north_most_y > ent_north then north_most_y = ent_north end
         if south_most_y < ent_south then south_most_y = ent_south end
      end
   end

   local bp_left_top = { x = math.floor(west_most_x), y = math.floor(north_most_y) }
   local bp_right_bottom = { x = math.ceil(east_most_x), y = math.ceil(south_most_y) }
   local width = bp_right_bottom.x - bp_left_top.x
   local height = bp_right_bottom.y - bp_left_top.y

   return width, height
end

---Get the build dimensions of a stack, accounting for rotation
---@param stack LuaItemStack The item stack to measure
---@param direction defines.direction The rotation direction (from viewpoint)
---@return integer|nil width The width in tiles
---@return integer|nil height The height in tiles
function mod.get_stack_build_dimensions(stack, direction)
   if not stack or not stack.valid_for_read then return nil, nil end

   local width, height

   if SPECIAL_CASES[stack.name] then
      width = SPECIAL_CASES[stack.name].width
      height = SPECIAL_CASES[stack.name].height
   elseif stack.is_blueprint_book then
      -- Blueprint books: get dimensions from active blueprint
      local book_inv = stack.get_inventory(defines.inventory.item_main)
      if book_inv and stack.active_index then
         local active_bp = book_inv[stack.active_index]
         if active_bp and active_bp.valid_for_read and active_bp.is_blueprint then
            width, height = analyze_blueprint_base_dimensions(active_bp)
         end
      end
   elseif stack.is_blueprint then
      --Blueprints: analyze constituent entities
      width, height = analyze_blueprint_base_dimensions(stack)
   --Entities: get dimensions from prototype
   elseif stack.prototype.place_result then
      width = stack.prototype.place_result.tile_width
      height = stack.prototype.place_result.tile_height
   elseif stack.prototype.place_as_tile_result then
      --Tiles: always 1x1
      width = 1
      height = 1
   else
      return nil, nil
   end

   --Apply rotation: swap dimensions for east/west
   if direction == defines.direction.east or direction == defines.direction.west then
      width, height = height, width
   end

   return width, height
end

---Get the rotation count for a stack
---@param stack LuaItemStack The item stack to check
---@return integer|nil rotation_count nil (no rotation), 2 (180° only), 4 (cardinal), or 8 (all 8 directions)
function mod.get_rotation_count(stack)
   if not stack or not stack.valid_for_read then return nil end

   -- Blueprint books always support 4-way rotation
   if stack.is_blueprint_book then return 4 end

   -- Blueprints always support 4-way rotation
   if stack.is_blueprint then return 4 end

   -- Regular entities
   if stack.prototype.place_result then
      local placed = stack.prototype.place_result

      -- Locomotives and artillery wagons are 2-way (180° only)
      if placed.type == "locomotive" or placed.type == "artillery-wagon" then return 2 end

      -- Cars and entities that support direction are 4-way
      if placed.supports_direction or placed.type == "car" then return 4 end
   end

   return nil
end

return mod
