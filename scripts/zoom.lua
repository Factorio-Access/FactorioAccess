--Here: Functions about the zoom system
local fa_graphics = require("scripts.graphics")

local ZOOM_PER_TICK = 1.104086977
local ln_zoom = math.log(ZOOM_PER_TICK)

local mod = {}

mod.MIN_ZOOM = 0.275
mod.MAX_ZOOM = 3.282

function mod.get_zoom_tick(pindex)
   return math.floor(math.log(storage.players[pindex].zoom) / ln_zoom + 0.5)
end

function mod.tick_to_zoom(zoom_tick)
   return ZOOM_PER_TICK ^ zoom_tick
end

function mod.fix_zoom(pindex)
   game.players[pindex].zoom = storage.players[pindex].zoom
end

function mod.set_zoom(value, pindex)
   --Note zoom levels:
   game.players[pindex].zoom = value
   storage.players[pindex].zoom = value
end

local function zoom_change(pindex, etick, change_by_tick)
   -- if storage.players[pindex].last_zoom_event_tick == etick then
   -- print("maybe duplicate")
   -- return
   -- end
   -- storage.players[pindex].last_zoom_event_tick = etick
   if game.players[pindex].render_mode == defines.render_mode.game then
      local tick = mod.get_zoom_tick(pindex)
      tick = tick + change_by_tick
      local zoom = mod.tick_to_zoom(tick)
      if zoom < mod.MAX_ZOOM and zoom > mod.MIN_ZOOM then
         storage.players[pindex].zoom = zoom
         local stack = game.get_player(pindex).cursor_stack
         if stack and stack.valid_for_read and stack.valid and stack.prototype.place_result ~= nil then
            fa_graphics.sync_build_cursor_graphics(pindex)
         else
            fa_graphics.draw_cursor_highlight(pindex, nil, nil)
         end
      end
   end
end

function mod.zoom_in(event)
   zoom_change(event.player_index, event.tick, 1)
end

function mod.zoom_out(event)
   zoom_change(event.player_index, event.tick, -1)
end

script.on_event("fa-zoom-in", mod.zoom_in)
script.on_event("fa-zoom-out", mod.zoom_out)
script.on_event(defines.events.on_cutscene_waypoint_reached, function(event)
   if game.players[event.player_index].render_mode == defines.render_mode.game then mod.fix_zoom(event.player_index) end
end)
script.on_event("fa-debug-reset-zoom", function(event)
   storage.players[event.player_index].zoom = 1
end)
script.on_event("fa-debug-reset-zoom-2x", function(event)
   storage.players[event.player_index].zoom = 2
end)

return mod
