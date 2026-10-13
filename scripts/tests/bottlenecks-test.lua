local Bottlenecks = require("scripts.bottlenecks")
local Speech = require("scripts.speech")
local TestRegistry = require("scripts.test-registry")
local UiRouter = require("scripts.ui.router")
local describe, it = TestRegistry.describe, TestRegistry.it

---Whether a localised string mentions the key anywhere.
---@param message LocalisedString
---@param key string
---@return boolean
local function mentions(message, key)
   if message == key then return true end
   if type(message) ~= "table" then return false end
   for _, part in ipairs(message) do
      if mentions(part, key) then return true end
   end
   return false
end

---@param recipe string
---@param ingredient string
---@return number
local function amount_of(recipe, ingredient)
   for _, i in ipairs(prototypes.recipe[recipe].ingredients) do
      if i.name == ingredient then return i.amount end
   end
   error(recipe .. " takes no " .. ingredient)
end

describe("Bottlenecks", function()
   it("finds what machines lack, shows it, and forgets them", function(ctx)
      ---@type LuaSurface
      local surface
      ---@type integer
      local surface_index
      ---@type LuaEntity, LuaEntity
      local empty, one_plate
      ---@type integer
      local before

      ctx:init(function()
         -- Short passes, so the test sees several
         Bottlenecks.SAMPLE_TICKS = 10
         before = Bottlenecks.machine_count()
         surface = game.create_surface("bottleneck-test")
         surface_index = surface.index
         surface.request_to_generate_chunks({ x = 0, y = 0 }, 1)
         surface.force_generate_chunk_requests()
         -- The network reaches every machine, and the interface powers it
         surface.create_global_electric_network()
         surface.create_entity({ name = "electric-energy-interface", position = { x = 10, y = 10 }, force = "player" })
         local function machine(x)
            return assert(surface.create_entity({
               name = "assembling-machine-1",
               position = { x = x, y = 0 },
               force = "player",
               recipe = "iron-gear-wheel",
               raise_built = true,
            }))
         end
         empty = machine(0)
         one_plate = machine(5)
         one_plate.get_inventory(defines.inventory.crafter_input).insert({ name = "iron-plate", count = 1 })
      end)

      ctx:at_tick(80, function()
         ctx:assert_equals(before + 2, Bottlenecks.machine_count(), "the scanner handed both over")
         local window = Bottlenecks.aggregate(game.forces.player.index, 6)
         ctx:assert(window.passes > 0, "passes completed")
         local found = {}
         for _, stat in ipairs(window.shortages[Bottlenecks.item_key("iron-plate")] or {}) do
            found[stat.unit] = stat
         end
         local a, b = found[empty.unit_number], found[one_plate.unit_number]
         ctx:assert(a and b, "both short of iron plate")
         ctx:assert_equals(a.sampled, a.short, "short every pass")
         ctx:assert_equals(2, a.missing / a.short, "the empty one lacks 2")
         ctx:assert_equals(1, b.missing / b.short, "the other lacks 1")
         ctx:assert_equals(surface_index, a.surface_index, "on the test surface")

         Speech.start_capture()
         local router = UiRouter.get_router(1)
         router:open_ui(UiRouter.UI_NAMES.BOTTLENECK_ANALYZER)
         ctx:assert(router:is_ui_open(UiRouter.UI_NAMES.BOTTLENECK_ANALYZER), "open")
         router:close_ui()
         local said = false
         for _, m in ipairs(Speech.stop_capture()) do
            said = said or mentions(m.message, "fa.bottlenecks-row")
         end
         ctx:assert(said, "opening reads the worst row")

         empty.destroy()
      end)

      ctx:at_tick(84, function()
         ctx:assert_equals(before + 1, Bottlenecks.machine_count(), "the destroyed one is dropped")
         ctx:assert(Bottlenecks._has_samples_on(game.forces.player.index, surface_index), "samples kept")
         game.delete_surface(surface)
      end)

      ctx:at_tick(110, function()
         ctx:assert_equals(before, Bottlenecks.machine_count(), "the deleted surface's machine is dropped")
         ctx:assert(not Bottlenecks._has_samples_on(game.forces.player.index, surface_index), "and its samples")
         Bottlenecks.SAMPLE_TICKS = 300
      end)
   end)

   it("reads fluid shortages and rocket silos", function(ctx)
      ---@type LuaSurface
      local surface
      ---@type LuaEntity, LuaEntity
      local plant, silo
      ---@type table<string, boolean>
      local enabled = {}

      ctx:init(function()
         Bottlenecks.SAMPLE_TICKS = 10
         local recipes = game.forces.player.recipes
         for _, name in ipairs({ "sulfuric-acid", "rocket-part" }) do
            enabled[name] = recipes[name].enabled
            recipes[name].enabled = true
         end
         surface = game.create_surface("bottleneck-test-2")
         surface.request_to_generate_chunks({ x = 0, y = 0 }, 2)
         surface.force_generate_chunk_requests()
         surface.create_global_electric_network()
         surface.create_entity({ name = "electric-energy-interface", position = { x = -10, y = -10 }, force = "player" })
         plant = assert(surface.create_entity({
            name = "chemical-plant",
            position = { x = 0.5, y = 0.5 },
            force = "player",
            recipe = "sulfuric-acid",
            raise_built = true,
         }))
         local input = plant.get_inventory(defines.inventory.crafter_input)
         input.insert({ name = "sulfur", count = 5 })
         input.insert({ name = "iron-plate", count = 1 })
         plant.insert_fluid({ name = "water", amount = 40 })
         silo = assert(surface.create_entity({
            name = "rocket-silo",
            position = { x = 20.5, y = 0.5 },
            force = "player",
            raise_built = true,
         }))
         -- Space Age makes rocket parts far cheaper: one short of the recipe, whatever it is
         local needed = amount_of("rocket-part", "processing-unit")
         if needed > 1 then
            silo
               .get_inventory(defines.inventory.crafter_input)
               .insert({ name = "processing-unit", count = math.floor(needed) - 1 })
         end
      end)

      ctx:at_tick(80, function()
         ctx:assert_equals(
            defines.entity_status.fluid_ingredient_shortage,
            plant.status,
            "the plant waits for water alone"
         )
         local window = Bottlenecks.aggregate(game.forces.player.index, 6)
         ---@param key string
         ---@param entity LuaEntity
         ---@return number?
         local function missing(key, entity)
            for _, stat in ipairs(window.shortages[key] or {}) do
               if stat.unit == entity.unit_number then return stat.missing / stat.short end
            end
            return nil
         end
         ctx:assert_equals(60, missing(Bottlenecks.fluid_key("water"), plant), "60 of 100 water missing")
         ctx:assert_equals(nil, missing(Bottlenecks.item_key("sulfur"), plant), "its items are there")
         ctx:assert_equals(1, missing(Bottlenecks.item_key("processing-unit"), silo), "the silo lacks one processor")
         ctx:assert_equals(
            amount_of("rocket-part", "rocket-fuel"),
            missing(Bottlenecks.item_key("rocket-fuel"), silo),
            "and all its fuel"
         )
         game.delete_surface(surface)
         for name, was in pairs(enabled) do
            game.forces.player.recipes[name].enabled = was
         end
         Bottlenecks.SAMPLE_TICKS = 300
      end)
   end)
end)
