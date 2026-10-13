local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

local FaInfo = require("scripts.fa-info")
local Speech = require("scripts.speech")
local TileReader = require("scripts.tile-reader")
local Viewpoint = require("scripts.viewpoint")

local DECON_KEY = "entity-status.marked-for-deconstruction"

---@param s any A LocalisedString or one of its parts
---@param key string
---@return integer
local function count_key(s, key)
   if type(s) ~= "table" then return 0 end
   local n = s[1] == key and 1 or 0
   for i = 2, #s do
      n = n + count_key(s[i], key)
   end
   return n
end

---What the cursor says on the entity's tile
---@param ent LuaEntity
---@return LocalisedString
local function read_at_cursor(ent)
   Viewpoint.get_viewpoint(1):set_cursor_pos(ent.position --[[@as MapPosition.struct]])
   local message = Speech.MessageBuilder.new()
   TileReader.read_tile_inner(1, message)
   return message:build()
end

describe("Deconstruction mark in entity info", function()
   ---@param name string
   ---@param position MapPosition
   ---@param read fun(ent: LuaEntity): LocalisedString
   local function check(name, position, read)
      return function(ctx)
         ---@type LuaEntity
         local ent
         ---@type LuaPlayer
         local player

         ctx:init(function()
            player = assert(game.get_player(1))
            ent = assert(player.surface.create_entity({ name = name, position = position, force = player.force }))
         end)

         ctx:at_tick(2, function()
            ctx:assert_equals(0, count_key(read(ent), DECON_KEY), "not marked yet")
            ent.order_deconstruction(player.force, player)
         end)

         ctx:at_tick(4, function()
            ctx:assert_equals(1, count_key(read(ent), DECON_KEY), "said once")
            ent.destroy()
         end)
      end
   end

   ---@param ent LuaEntity
   local function ent_info(ent)
      return FaInfo.ent_info(1, ent)
   end

   it("is said for a wall, which has no status", check("stone-wall", { x = 31.5, y = 35.5 }, ent_info))
   it(
      "is said once for a machine, which has the status too",
      check("assembling-machine-1", { x = 40.5, y = 30.5 }, ent_info)
   )
   it(
      "is said for a rail at the cursor, which reads rails itself",
      check("straight-rail", { x = 31, y = 31 }, read_at_cursor)
   )
end)
