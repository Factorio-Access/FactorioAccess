--[[
Crafting Backend - Emits events when crafting machines finish products.

Tracks the products_finished counter on crafting machines and emits an event
each time it increments.
]]

local Consts = require("scripts.consts")
local GridConsts = require("scripts.sonifiers.grid-consts")
local LauncherAudio = require("scripts.launcher-audio")
local SoundModel = require("scripts.sound-model")

local mod = {}

-- Entity types this backend wants to track
mod.ENTITY_TYPES = Consts.CRAFTING_MACHINES

-- Sound configuration
local SOUND_DURATION = 0.1
local SOUND_FADEOUT = 0.05
local SOUND_VOLUME = 0.3

---@class fa.GridSonifier.CraftingBackend: fa.GridSonifier.Backend
---@field tracked_entities table<integer, fa.GridSonifier.CraftingBackend.TrackedEntity>

---@class fa.GridSonifier.CraftingBackend.TrackedEntity
---@field entity LuaEntity
---@field last_products_finished integer

local CraftingBackend = {}
local CraftingBackend_meta = { __index = CraftingBackend }

---Create a new crafting backend
---@return fa.GridSonifier.CraftingBackend
function mod.new()
   local self = {
      tracked_entities = {},
   }
   setmetatable(self, CraftingBackend_meta)
   return self
end

---Called when an entity becomes visible
---@param entity LuaEntity
function CraftingBackend:on_visible(entity)
   if not entity.valid or not entity.unit_number then return end

   self.tracked_entities[entity.unit_number] = {
      entity = entity,
      last_products_finished = entity.products_finished,
   }
end

---Called when an entity is no longer visible
---@param unit_number integer
function CraftingBackend:on_vanished(unit_number)
   self.tracked_entities[unit_number] = nil
end

---Build sound for a crafting completion event
---@param id string
---@param u number
---@param v number
---@return fa.LauncherAudio.PatchBuilder
local function build_crafting_sound(id, u, v)
   local pan, pitch = SoundModel.map_uv_to_pitch_pan(u, v)

   local builder = LauncherAudio.patch(id)

   -- Use triangle wave for north (v < 0), sine for south
   if v < 0 then
      builder:triangle(pitch)
   else
      builder:sine(pitch)
   end

   return builder:duration(SOUND_DURATION):fade_out(SOUND_FADEOUT):volume(SOUND_VOLUME):pan(pan)
end

---Tick handler - checks for products_finished increments and emits events
---@param callback fun(event: fa.GridSonifier.Event)
function CraftingBackend:tick(callback)
   for unit_number, tracked in pairs(self.tracked_entities) do
      local entity = tracked.entity

      if not entity.valid then
         self.tracked_entities[unit_number] = nil
      else
         local current_products = entity.products_finished
         local delta = current_products - tracked.last_products_finished

         if delta > 0 then
            -- Emit an event for each product finished
            local pos = entity.position
            for _ = 1, delta do
               ---@type fa.GridSonifier.Event
               local event = {
                  x = pos.x,
                  y = pos.y,
                  sound_builder = build_crafting_sound,
                  deduplication_key = "craft",
                  grid = GridConsts.GRIDS.CRAFTING_STRUCTURES,
                  unit_number = unit_number,
               }
               callback(event)
            end
         end

         tracked.last_products_finished = current_products
      end
   end
end

-- Register metatable for save/load
if script then script.register_metatable("fa.GridSonifier.CraftingBackend", CraftingBackend_meta) end

return mod
