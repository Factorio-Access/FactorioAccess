local mod = {}

local interface_name = "kruise_kontrol_updated"

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
      local p = game.get_player(pindex)
      -- The mod modifies this for e.g. telestep.
      p.character_running_speed_modifier = 0

      -- we want the mod's view of the cursor, which may be off the screen.
      --
      -- Without the deep copy, control.lua touches this from under us.
      --
      -- For now the fractional components are still present.  We're about to
      -- fix that.
      local kk_pos = table.deepcopy(players[pindex].cursor_pos)

      -- we must duplicate a bit of logic since the mouse is not on our side; FA
      -- has its own idea of selections.
      refresh_player_tile(pindex)
      local target = get_selected_ent_deprecated(pindex)

      -- Okay, but what other edge cases can we find?  Turns out that, again, KK
      -- doesn't work if there's a blueprint in the player's hand.  This one is
      -- really hard to resolve because some blueprints are and some blueprints
      -- aren't temporary, and mod hacking around blueprints is currently going
      -- on.  For now, we will short-circuit and announce this to the player.
      --
      -- Funnily enough deconstruction planners seem to be fine.  As we find
      -- problems we can add them to the conditional below.
      local p = game.players[pindex]
      local c = p and p.valid and p.character

      -- But, actually, if there's no player entity and that player entity
      -- doesn't have a character, then we're done.  Can't do KK for that.
      if not c.valid then return end

      local hand = c.cursor_stack
      if hand and hand.valid_for_read and (hand.name == "blueprint" or hand.name == "blueprint-book") then
         return { "access.kk-blueprints-not-allowed" }
      end

      -- Okay. Finally we're good.  Let's kick this off.

      close_menu_resets(pindex)

      -- If cursor mode is on then the best case is that the mod announces a
      -- bunch of stuff it shouldn't, but sometimes this just flat out means
      -- that KK doesn't work.  I don't know why; I'm guessing that's to do with
      -- how we hack WASD not to move the player.
      --
      -- Don't say anything either, this is silent.
      force_cursor_off(pindex, true)

      remote.call(interface_name, "start_job", pindex, { x = math.floor(kk_pos.x), y = math.floor(kk_pos.y) }, target)
      local desc = remote.call(interface_name, "get_description", pindex)
      if not desc then return { "access.kk-not-started" } end

      return { "access.kk-start", desc }
   end, { "access.kk-not-available" })

   printout(announcing, pindex)
end

--FA actions to take when KK cancel input is pressed
function mod.cancel_kk(pindex)
   call_with_interface(function()
      if not remote.call(interface_name, "is_active", pindex) then
         -- If there was no interface then KK isn't installed; if the player
         -- isn't active already then the enter key is doing enter/exit vehicle.
         -- In that case there's nothing to say here.
         return
      end

      remote.call(interface_name, "cancel", pindex)

      -- Prevent saying KK is done after it is cancelled.
      players[pindex].kruise_kontrol_active_last_time = false

      -- We screwed around with the running modifier. Put it back based on
      -- cursor mode.
      fix_walk(pindex)

      printout({ "access.kk-cancel" }, pindex)
   end)
end

function mod.status_read(pindex, short_version)
   call_with_interface(function()
      -- We must remember if KK was last active and then use it to detect the
      -- falling edge.  This is the only way to really know if it's finished.
      local active = remote.call(interface_name, "is_active", pindex)
      local was_active = players[pindex].kruise_kontrol_active_last_time
      players[pindex].kruise_kontrol_active_last_time = active
      if active then
         printout({ "access.kk-state", remote.call(interface_name, "get_description", pindex) }, pindex)
      elseif not active and was_active then
         printout({ "access.kk-done" }, pindex)
      end
   end)
end

function mod.is_active(pindex)
   return call_with_interface(function()
      return remote.call(interface_name, "is_active", pindex)
   end, false)
end

return mod
