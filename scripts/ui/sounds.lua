--[[
Wraps common sounds in a way which lets us put them in one place.  You call e.g.
`sounds.play_menu_moved(pindex)` and get whatever the menu movement sound is.

This module is not pointless because prior to it, we had one-off play calls all
over the codebase.  One had to find an example of the sound they wanted, hunt
down where it was played from, and copy/paste it.  Let's not and say we did.
]]

local mod = {}

-- Call to play the sound for moving in a menu, e.g. inventory, belt analyzer,
-- pretty much all of them.
function mod.play_menu_move(pindex)
   game.get_player(pindex).play_sound({ path = "Inventory-Move" })
end

function mod.play_menu_click(pindex)
   game.get_player(pindex).play_sound({ path = "utility/inventory_click" })
end

function mod.play_menu_wrap(pindex)
   game.get_player(pindex).play_sound({ path = "inventory-wrap-around" })
end

-- Reached the edge of the menu, the end or beginning of a slider, etc.
function mod.play_ui_edge(pindex)
   game.get_player(pindex).play_sound({ path = "inventory-edge" })
end

return mod
