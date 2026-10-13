--[[
Bottlenecks: which ingredients crafting machines wait for, sampled over time, for the bottleneck analyzer.

Every crafting machine whose recipe the player chose, or which has only the one recipe (rocket silos), is sampled
once a pass, and a pass lasts SAMPLE_TICKS. The game says a machine is waiting for ingredients (its status) but not
for which, so a waiting machine's recipe is compared against its inputs. Furnaces pick their recipe from what they are
given, so they are left out; so is fuel.

The machines come from the scanner, which hands each entity over once, when it is built or its chunk is first
scanned. A save that had the scanner before this module finds its machines once, the first time it runs. All machines
live in one list, walked a few a tick so a pass covers them all; one destroyed is dropped when its turn comes or when
its destruction is raised, whichever is first.

Each force keeps a ring of the last RING passes. A pass's bucket holds, per surface, per missing ingredient, the
machines short of it and by how much. `aggregate` turns a window of passes into what the analyzer shows.
]]

local StorageManager = require("scripts.storage-manager")
local SurfaceScanner = require("scripts.scanner.surface-scanner")

local mod = {}

mod.SAMPLE_TICKS = 300
-- Passes kept: ten minutes.
mod.RING = 120

-- The types sampled. Furnaces are crafting machines too, but choose their own recipe.
local CRAFTER_TYPES = { "assembling-machine", "rocket-silo" }

---@class fa.bottlenecks.Sampler
---@field order integer[] Unit numbers, walked in order each pass
---@field slot table<integer, integer?> Unit number to its index in order
---@field entities table<integer, LuaEntity>
---@field first_pass table<integer, integer?> The pass a machine was found in; it counts from the next
---@field pass integer The pass under way; completed passes are below it
---@field pass_start integer Tick it started
---@field next_index integer In order
---@field discovered boolean? Machines already on the map were found

---@type table<string, fa.bottlenecks.Sampler>
local sampler_storage = StorageManager.declare_storage_module("bottlenecks", function()
   return {
      order = {},
      slot = {},
      entities = {},
      first_pass = {},
      pass = 1,
      pass_start = game.tick,
      next_index = 1,
   }
end, { root_field = "bottleneck_sampler", ephemeral_state_version = 1 })

---Per surface index, per shortage key: the machines short and the amounts, index for index.
---@alias fa.bottlenecks.SurfaceSamples table<string, { u: integer[], a: number[] }>

---@class fa.bottlenecks.Bucket
---@field pass integer
---@field surfaces table<integer, fa.bottlenecks.SurfaceSamples?>

---@class fa.bottlenecks.ForceState
---@field buckets table<integer, fa.bottlenecks.Bucket> By slot, pass % RING + 1; stale when its pass is not the one wanted

---@type table<integer, fa.bottlenecks.ForceState>
local force_storage = StorageManager.declare_storage_module(
   "bottlenecks",
   { buckets = {} },
   { root_field = "forces", ephemeral_state_version = 1 }
)

---@return fa.bottlenecks.Sampler
local function sampler()
   return sampler_storage.state
end

---@param s fa.bottlenecks.Sampler
---@param entity LuaEntity
local function add(s, entity)
   local unit = assert(entity.unit_number)
   if s.slot[unit] then return end
   table.insert(s.order, unit)
   s.slot[unit] = #s.order
   s.entities[unit] = entity
   s.first_pass[unit] = s.pass
end

---@param s fa.bottlenecks.Sampler
---@param unit integer
local function remove(s, unit)
   local index = s.slot[unit]
   if not index then return end
   local last = table.remove(s.order)
   if last ~= unit then
      s.order[index] = last
      s.slot[last] = index
   end
   s.slot[unit] = nil
   s.entities[unit] = nil
   s.first_pass[unit] = nil
end

---@param entity LuaEntity
function mod.on_new_entity(entity)
   add(sampler(), entity)
end

SurfaceScanner.add_new_entity_listener(CRAFTER_TYPES, mod.on_new_entity)

---@param event EventData.on_object_destroyed
function mod.on_object_destroyed(event)
   if event.type == defines.target_type.entity then remove(sampler(), event.useful_id) end
end

---A surface's index is reused once it is gone, so its samples go with it.
---@param surface_index integer
function mod.on_surface_deleted(surface_index)
   for _, state in pairs(force_storage) do
      for _, bucket in pairs(state.buckets) do
         bucket.surfaces[surface_index] = nil
      end
   end
end

---The merged-away force's index is reused too.
---@param event EventData.on_forces_merged
function mod.on_forces_merged(event)
   force_storage[event.source_index] = nil
end

---@param name string
---@param quality string?
---@return string
function mod.item_key(name, quality)
   return "item/" .. name .. "/" .. (quality or "normal")
end

---@param name string
---@return string
function mod.fluid_key(name)
   return "fluid/" .. name
end

---@param key string
---@return "item"|"fluid" type, string name, string? quality
function mod.parse_key(key)
   local kind, rest = string.match(key, "^(%a+)/(.+)$")
   rest = assert(rest)
   if kind == "fluid" then return "fluid", rest, nil end
   local name, quality = string.match(rest, "^(.+)/([^/]+)$")
   return "item", assert(name), quality
end

-- Recipe ingredients by recipe name: reading them from a LuaRecipe makes a new table every time.
---@type table<string, Ingredient[]>
local ingredient_cache = {}

---Each ingredient the machine has too little of for one craft, and how much it lacks.
---@param entity LuaEntity
---@param callback fun(key: string, missing: number)
function mod.shortages(entity, callback)
   local recipe, quality = entity.get_recipe()
   if not recipe then return end
   local ingredients = ingredient_cache[recipe.name]
   if not ingredients then
      ingredients = recipe.prototype.ingredients
      ingredient_cache[recipe.name] = ingredients
   end
   local quality_name = quality and quality.name or "normal"
   local inventory = nil
   for _, ingredient in ipairs(ingredients) do
      if ingredient.type == "item" then
         inventory = inventory or assert(entity.get_inventory(defines.inventory.crafter_input))
         local have = inventory.get_item_count({ name = ingredient.name, quality = quality_name })
         if have < ingredient.amount then
            callback(mod.item_key(ingredient.name, quality_name), ingredient.amount - have)
         end
      else
         local have = entity.get_fluid_count(ingredient.name)
         if have < ingredient.amount then callback(mod.fluid_key(ingredient.name), ingredient.amount - have) end
      end
   end
end

-- The fewest ticks a pass running late spreads its remaining machines over.
local LATE_TICKS = 60

local ITEM_SHORTAGE = defines.entity_status.item_ingredient_shortage
local FLUID_SHORTAGE = defines.entity_status.fluid_ingredient_shortage

---@param pass integer
---@param force_index integer
---@return fa.bottlenecks.Bucket
local function bucket_for(pass, force_index)
   local buckets = force_storage[force_index].buckets
   local slot = pass % mod.RING + 1
   local bucket = buckets[slot]
   if not bucket or bucket.pass ~= pass then
      bucket = { pass = pass, surfaces = {} }
      buckets[slot] = bucket
   end
   return bucket
end

---@param s fa.bottlenecks.Sampler
---@param unit integer
local function sample(s, unit)
   local entity = s.entities[unit]
   if not entity.valid then
      remove(s, unit)
      return
   end
   local status = entity.status
   if status ~= ITEM_SHORTAGE and status ~= FLUID_SHORTAGE then return end
   ---@type fa.bottlenecks.SurfaceSamples?
   local samples = nil
   mod.shortages(entity, function(key, missing)
      if not samples then
         local bucket = bucket_for(s.pass, entity.force.index --[[@as integer]])
         local surface_index = entity.surface.index
         samples = bucket.surfaces[surface_index]
         if not samples then
            samples = {}
            bucket.surfaces[surface_index] = samples
         end
      end
      local list = samples[key]
      if not list then
         list = { u = {}, a = {} }
         samples[key] = list
      end
      local n = #list.u + 1
      list.u[n] = unit
      list.a[n] = missing
   end)
end

---Machines placed before this module first ran: the scanner has already handed them over.
---@param s fa.bottlenecks.Sampler
local function discover(s)
   for _, surface in pairs(game.surfaces) do
      for _, entity in ipairs(surface.find_entities_filtered({ type = CRAFTER_TYPES })) do
         add(s, entity)
      end
   end
   s.discovered = true
end

function mod.on_tick()
   local s = sampler()
   if not s.discovered then discover(s) end

   -- The machines left this pass, spread over the ticks left, and over at least LATE_TICKS once late: machines
   -- found during a pass (a big blueprint, or every machine of an old save on its first pass) join it at the end
   local order = s.order
   local i = s.next_index
   local ticks_left = math.max(LATE_TICKS, s.pass_start + mod.SAMPLE_TICKS - game.tick)
   local per_tick = math.max(math.ceil(#order / mod.SAMPLE_TICKS), math.ceil((#order - i + 1) / ticks_left))
   local stop = math.min(i + per_tick - 1, #order)
   while i <= stop do
      local unit = order[i]
      sample(s, unit)
      -- Removing swaps the last machine into this slot; it is sampled next pass
      if order[i] == unit then i = i + 1 end
      stop = math.min(stop, #order)
   end
   s.next_index = i

   if i > #order and game.tick >= s.pass_start + mod.SAMPLE_TICKS then
      s.pass = s.pass + 1
      s.pass_start = game.tick
      s.next_index = 1
   end
end

---@class fa.bottlenecks.MachineStat
---@field unit integer
---@field entity LuaEntity
---@field surface_index integer
---@field short integer Passes it was short in
---@field sampled integer Passes it was sampled in
---@field missing number Total missing over the passes it was short in

---@class fa.bottlenecks.Window
---@field passes integer Completed passes found, at most the window's length
---@field shortages table<string, fa.bottlenecks.MachineStat[]> By shortage key

---What the force's machines lacked over the last `length` completed passes. Machines since destroyed are left out.
---@param force_index integer
---@param length integer In passes
---@return fa.bottlenecks.Window
function mod.aggregate(force_index, length)
   local s = sampler()
   local buckets = force_storage[force_index].buckets
   local last = s.pass - 1
   local first = math.max(1, last - length + 1)

   local first_pass = s.first_pass
   ---@type table<string, table<integer, fa.bottlenecks.MachineStat?>>
   local by_key = {}
   -- Passes in order, so a machine's first sample counted decides whether its later ones are
   for pass = first, last do
      local bucket = buckets[pass % mod.RING + 1]
      if bucket and bucket.pass == pass then
         for surface_index, samples in pairs(bucket.surfaces) do
            for key, list in pairs(samples) do
               local stats = by_key[key]
               if not stats then
                  stats = {}
                  by_key[key] = stats
               end
               local units, amounts = list.u, list.a
               for n = 1, #units do
                  local unit = units[n]
                  local stat = stats[unit]
                  if stat then
                     stat.short = stat.short + 1
                     stat.missing = stat.missing + amounts[n]
                  else
                     local found = first_pass[unit]
                     -- A machine is counted from the pass after it was found, so every pass counted sampled it
                     if found and found < pass then
                        stats[unit] = {
                           unit = unit,
                           entity = s.entities[unit],
                           surface_index = surface_index,
                           short = 1,
                           sampled = last - math.max(first, found + 1) + 1,
                           missing = amounts[n],
                        }
                     end
                  end
               end
            end
         end
      end
   end

   local shortages = {}
   for key, stats in pairs(by_key) do
      local list = {}
      for _, stat in pairs(stats) do
         if stat.entity.valid then table.insert(list, stat) end
      end
      if next(list) then shortages[key] = list end
   end
   return { passes = math.max(0, last - first + 1), shortages = shortages }
end

---Whether the force has samples from the surface in any pass kept, for tests.
---@param force_index integer
---@param surface_index integer
---@return boolean
function mod._has_samples_on(force_index, surface_index)
   for _, bucket in pairs(force_storage[force_index].buckets) do
      if bucket.surfaces[surface_index] then return true end
   end
   return false
end

---Machines tracked, for tests and benchmarks.
---@return integer
function mod.machine_count()
   return #sampler().order
end

---The pass under way, for tests.
---@return integer
function mod.current_pass()
   return sampler().pass
end

return mod
