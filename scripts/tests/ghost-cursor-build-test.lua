local TestRegistry = require("scripts.test-registry")
local BuildingTools = require("scripts.building-tools")
local Viewpoint = require("scripts.viewpoint")
local describe, it = TestRegistry.describe, TestRegistry.it

---@param player LuaPlayer
---@param x integer
---@param y integer
---@return boolean
local function build_at(player, x, y)
   local vp = Viewpoint.get_viewpoint(player.index)
   vp:set_cursor_pos({ x = x, y = y })
   return BuildingTools.build_item_in_hand_with_params({
      pindex = player.index,
      building_direction = vp:get_hand_direction(),
      teleport_player = false,
   })
end

describe("Building from a ghost cursor", function()
   it("places entity and tile ghosts", function(ctx)
      ctx:init(function()
         local player, surface = ctx:setup_test_area(1)
         assert(player and surface)
         local pos = player.position --[[@as MapPosition.struct]]
         local x, y = math.floor(pos.x) + 3, math.floor(pos.y)
         local tiles = {}
         for dx = 0, 4 do
            table.insert(tiles, { name = "grass-1", position = { x + dx, y } })
         end
         surface.set_tiles(tiles)
         local cursor = assert(player.cursor_stack)
         cursor.clear()
         local vp = Viewpoint.get_viewpoint(1)

         player.cursor_ghost = "transport-belt"
         vp:set_hand_direction(defines.direction.east)
         ctx:assert(build_at(player, x, y), "the belt ghost was built")
         local ghosts = surface.find_entities_filtered({ type = "entity-ghost", position = { x + 0.5, y + 0.5 } })
         ctx:assert_equals(1, #ghosts)
         ctx:assert_equals("transport-belt", ghosts[1].ghost_name)
         ctx:assert_equals(defines.direction.east, ghosts[1].direction)
         ctx:assert_not_nil(BuildingTools.hand_build_preview_info(1), "a ghost in hand has a build preview")
         ghosts[1].destroy()

         player.cursor_ghost = "stone-brick"
         vp:set_cursor_size(0)
         ctx:assert(build_at(player, x + 2, y), "the tile ghost was built")
         local tile_ghosts =
            surface.find_entities_filtered({ type = "tile-ghost", area = { { x + 2, y }, { x + 3, y + 1 } } })
         ctx:assert_equals(1, #tile_ghosts)
         ctx:assert_equals("stone-path", tile_ghosts[1].ghost_name)
         tile_ghosts[1].destroy()

         player.clear_cursor()
      end)
   end)

   it("places an entity ghost over a tree in remote view", function(ctx)
      ctx:init(function()
         local player, surface = ctx:setup_test_area(1)
         assert(player and surface)
         local pos = player.position --[[@as MapPosition.struct]]
         local x, y = math.floor(pos.x) + 6, math.floor(pos.y)
         local tree = assert(surface.create_entity({ name = "tree-01", position = { x + 0.5, y + 0.5 } }))
         assert(player.cursor_stack).clear()
         player.set_controller({ type = defines.controllers.remote, position = pos, surface = surface })

         player.cursor_ghost = "stone-furnace"
         ctx:assert(build_at(player, x, y), "the furnace ghost was built")
         local ghosts = surface.find_entities_filtered({ type = "entity-ghost", area = { { x, y }, { x + 2, y + 2 } } })
         ctx:assert_equals(1, #ghosts)
         ctx:assert_equals("stone-furnace", ghosts[1].ghost_name)
         ctx:assert(tree.to_be_deconstructed(), "the tree is marked for deconstruction")
         ghosts[1].destroy()
         tree.destroy()

         player.clear_cursor()
         player.exit_remote_view()
      end)
   end)
end)
