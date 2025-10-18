---Centralized build dimension calculation
---Determines the dimensions of items in hand (blueprints, entities, tiles)

local mod = {}

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

   --Blueprints: analyze constituent entities
   if stack.is_blueprint then
      width, height = analyze_blueprint_base_dimensions(stack)
   --Entities: get dimensions from prototype
   elseif stack.prototype.place_result then
      width = stack.prototype.place_result.tile_width
      height = stack.prototype.place_result.tile_height
   --Tiles: always 1x1
   elseif stack.prototype.place_as_tile_result then
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

return mod
