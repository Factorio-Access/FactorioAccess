--Here: Functions related to Kruise Kontrol Remote

local Viewpoint = require("scripts.viewpoint")
local FaUtils = require("scripts.fa-utils")
local EntitySelection = require("scripts.entity-selection")
local Speech = require("scripts.speech")

local mod = {}

local interface_name = "kruise_kontrol_updated"

---The remote interface of the Kruise Kontrol mod, as this file uses it
---@class fa.KruiseKontrol.Interface
---@field start_job fun(pindex: integer, opts: { x: integer, y: integer }, target: LuaEntity?)
---@field get_description fun(pindex: integer): LocalisedString?
---@field is_active fun(pindex: integer): boolean
---@field cancel fun(pindex: integer)

---@class (partial) LuaRemote.InterfaceMap
---@field kruise_kontrol_updated fa.KruiseKontrol.Interface

-- Call the closure if kk is present, returning what it returns. Otherwise don't
-- call it and return `or_default`.  Recall that unspecified parameters are
-- already nil; `or_default`, therefore, is optional.
local function call_with_interface(closure, or_default)
   if not remote.interfaces[interface_name] then return or_default end
   return closure()
end

--FA actions to take when KK activate input is pressed
function mod.activate_kk(pindex)
   local announcing = call_with_interface(function()
      local p = assert(game.get_player(pindex))
      -- Kruise Kontrol walks the character
      if not FaUtils.controlled_character(p) then return FaUtils.no_controlled_character_reason(p) end

      -- we want the mod's view of the cursor, which may be off the screen.
      --
      -- Without the deep copy, control.lua touches this from under us.
      --
      -- For now the fractional components are still present.  We're about to
      -- fix that.
      local vp = Viewpoint.get_viewpoint(pindex)
      local kk_pos = vp:get_cursor_pos()

      -- we must duplicate a bit of logic since the mouse is not on our side; FA
      -- has its own idea of selections.
      EntitySelection.reset_entity_index(pindex)
      local target = EntitySelection.get_first_ent_at_tile(pindex)

      -- Okay, but what other edge cases can we find?  Turns out that, again, KK
      -- doesn't work if there's a blueprint in the player's hand.  This one is
      -- really hard to resolve because some blueprints are and some blueprints
      -- aren't temporary, and mod hacking around blueprints is currently going
      -- on.  For now, we will short-circuit and announce this to the player.
      --
      -- Funnily enough deconstruction planners seem to be fine.  As we find
      -- problems we can add them to the conditional below.

      local hand = p.cursor_stack
      if hand and hand.valid_for_read and (hand.name == "blueprint" or hand.name == "blueprint-book") then
         return { "fa.kk-blueprints-not-allowed" }
      end

      -- If in a car, make sure to activate it
      if p.vehicle and p.vehicle.type == "car" and p.vehicle.active == false then
         p.vehicle.disabled_by_script = false
         p.vehicle.speed = 0
      end

      -- Okay. Finally we're good.  Let's kick this off.
      local opts = { x = math.floor(kk_pos.x), y = math.floor(kk_pos.y) }
      p.selected = nil
      remote.call(interface_name, "start_job", pindex, opts, target)
      local desc = remote.call(interface_name, "get_description", pindex)
      if not desc then return { "fa.kk-not-started" } end

      return { "fa.kk-start", desc }
   end, { "fa.kk-not-available" })

   Speech.speak(pindex, announcing)
end

--FA actions to take when KK cancel input is pressed
function mod.cancel_kk(pindex)
   local p = game.get_player(pindex)
   call_with_interface(function()
      local active = remote.call(interface_name, "is_active", pindex)
      if not active then
         -- If there was no interface then KK isn't installed; if the player
         -- isn't active already then the enter key is doing enter/exit vehicle.
         -- In that case there's nothing to say here.
         return
      end

      remote.call(interface_name, "cancel", pindex)

      Speech.speak(pindex, { "fa.kk-cancel" })
   end)
   -- If in a car, make sure to stop it because we are exiting it too because of the overlapping keys
   if p.vehicle and p.vehicle.type == "car" and p.vehicle.active == true then p.vehicle.speed = 0 end
end

function mod.is_active(pindex)
   return call_with_interface(function()
      return remote.call(interface_name, "is_active", pindex)
   end, false)
end

return mod
