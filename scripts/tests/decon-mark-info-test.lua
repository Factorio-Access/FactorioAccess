local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it

local FaInfo = require("scripts.fa-info")

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

describe("Deconstruction mark in entity info", function()
   ---@param name string
   ---@param position MapPosition
   local function check(name, position)
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
            ctx:assert_equals(0, count_key(FaInfo.ent_info(1, ent), DECON_KEY), "not marked yet")
            ent.order_deconstruction(player.force, player)
         end)

         ctx:at_tick(4, function()
            ctx:assert_equals(1, count_key(FaInfo.ent_info(1, ent), DECON_KEY), "said once")
            ent.destroy()
         end)
      end
   end

   it("is said for a rail, which has no status", check("straight-rail", { x = 31, y = 31 }))
   it("is said once for a machine, which has the status too", check("assembling-machine-1", { x = 40.5, y = 30.5 }))
end)
