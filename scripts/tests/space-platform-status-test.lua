--[[
The platform status description. Runs only with space travel (the default test run has no Space Age).
]]

local TestRegistry = require("scripts.test-registry")
local PlatformTravel = require("scripts.platform-travel")
local Speech = require("scripts.speech")
local describe, it = TestRegistry.describe, TestRegistry.it

---The fa locale keys in a built message, each with its parameters.
---@param message LocalisedString
---@return table<string, any[]>
local function keys_of(message)
   local found = {}
   local function walk(node)
      if type(node) ~= "table" then return end
      local key = node[1]
      if type(key) == "string" and key:sub(1, 3) == "fa." then found[key] = { table.unpack(node, 2) } end
      for i = 2, #node do
         walk(node[i])
      end
   end
   walk(message)
   return found
end

---@param platform LuaSpacePlatform
local function status(platform)
   local message = Speech.MessageBuilder.new()
   PlatformTravel.describe(platform, message)
   return keys_of(message:build())
end

describe("Space platform status", function()
   it("reads a built platform with nothing scheduled", function(ctx)
      if not script.feature_flags.space_travel then return end
      ---@type LuaSpacePlatform
      local platform
      ctx:init(function()
         platform = assert(
            game.forces.player.create_space_platform({ planet = "nauvis", starter_pack = "space-platform-starter-pack" })
         )
         platform.apply_starter_pack()
         platform.paused = false
      end)
      ctx:at_tick(3, function()
         ctx:assert_equals(defines.space_platform_state.no_schedule, platform.state)
         ctx:assert(status(platform)["fa.platform-status-no-schedule"] ~= nil, "no schedule")
         platform.destroy(0)
      end)
   end)

   it("reads an unbuilt platform, then a trip flown backwards along its connection", function(ctx)
      if not script.feature_flags.space_travel then return end
      ---@type LuaSpacePlatform
      local platform

      ctx:init(function()
         platform = assert(
            game.forces.player.create_space_platform({ planet = "nauvis", starter_pack = "space-platform-starter-pack" })
         )
         local keys = status(platform)
         ctx:assert(keys["fa.platform-status-waiting-for-starter-pack"] ~= nil, "waiting for starter pack")
         ctx:assert(keys["fa.platform-status-orbiting"] ~= nil, "orbiting")
         ctx:assert(keys["fa.platform-status-mass"] == nil, "no mass before the hub exists")

         platform.apply_starter_pack()
         local surface = platform.surface
         local tiles = {}
         for x = -12, 11 do
            for y = -12, 16 do
               tiles[#tiles + 1] = { name = "space-platform-foundation", position = { x, y } }
            end
         end
         surface.set_tiles(tiles)
         for _, x in pairs({ -4, 4 }) do
            local thruster =
               assert(surface.create_entity({ name = "thruster", position = { x, 13 }, force = "player" }))
            thruster.set_fluid(1, { name = "thruster-fuel", amount = 1000 })
            thruster.set_fluid(2, { name = "thruster-oxidizer", amount = 1000 })
         end
         -- Vulcanus is the to end of nauvis-vulcanus, so this trip runs distance from 1 down to 0
         platform.space_location = "vulcanus"
         platform.schedule = { current = 1, records = { { station = "nauvis", wait_conditions = {} } } }
         platform.paused = false
      end)

      ctx:at_tick(30, function()
         ctx:assert_equals("nauvis-vulcanus", assert(platform.space_connection).name)
         local keys = status(platform)
         local travelling = keys["fa.platform-status-travelling"]
         ctx:assert_not_nil(travelling, "travelling")
         -- The name comes with a fallback: { "?", localised name, prototype name }
         ctx:assert_equals("nauvis", travelling[1][3])
         ctx:assert(tonumber(travelling[2]) < 10, "progress counts from Vulcanus, got " .. travelling[2])
         ctx:assert(keys["fa.platform-status-speed"] ~= nil, "speed")
         ctx:assert_equals("179.2", keys["fa.platform-status-mass"][1])
         platform.destroy(0)
      end)
   end)
end)
