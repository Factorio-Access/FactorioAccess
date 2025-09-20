--[[
Crafting queue menu using the new TabList/MenuBuilder UI system.
Shows the player's crafting queue with the next item at the top.
Left bracket cancels the selected item.
]]

local Menu = require("scripts.ui.menu")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local localising = require("scripts.localising")

local mod = {}

---@param ctx fa.ui.TabContext
function mod.state_setup(ctx)
   -- Empty state setup required by TabList
end

---@param ctx fa.ui.TabContext
function mod.render(ctx)
   local builder = Menu.MenuBuilder.new()
   local player = game.get_player(ctx.pindex)
   if not player then return builder:build() end

   -- Refresh queue from player
   local queue = player.crafting_queue

   if not queue or #queue == 0 then
      builder:add_label("empty", { "fa.crafting-queue-empty" })
      return builder:build()
   end

   -- Add items from the queue, next item first
   for i, item in ipairs(queue) do
      local recipe_proto = prototypes.recipe[item.recipe]
      if recipe_proto then
         -- Create unique key using prototype name and index
         local key = item.recipe .. "-" .. i

         -- Build label with localized name and count
         builder:add_item(key, {
            label = function(ctx)
               local name = localising.get_localised_name_with_fallback(recipe_proto)
               ctx.message:fragment(name):fragment(" x " .. item.count)
            end,
         })
      end
   end

   return builder:build()
end

---@param ctx fa.ui.TabContext
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
function mod.on_click(ctx, modifiers)
   local player = game.get_player(ctx.pindex)
   if not player then return end

   local queue = player.crafting_queue
   if not queue or #queue == 0 then
      Speech.speak(ctx.pindex, { "fa.crafting-queue-empty" })
      return
   end

   -- Get the selected key
   local selected_key = ctx:get_cursor_key()
   if not selected_key or selected_key == "empty" then return end

   -- Extract the index from the key (format: "recipename-index")
   local dash_pos = string.find(selected_key, "-[^-]*$")
   if not dash_pos then return end

   local index_str = string.sub(selected_key, dash_pos + 1)
   local index = tonumber(index_str)
   if not index or index < 1 or index > #queue then return end

   local item = queue[index]
   if not item then return end

   -- Cancel crafting
   local cancel_count = 1
   if modifiers and modifiers.shift then
      cancel_count = 5
   elseif modifiers and modifiers.control then
      cancel_count = item.count
   end

   -- Cancel the crafting
   player.cancel_crafting({
      index = index,
      count = math.min(cancel_count, item.count),
   })

   -- Announce what was cancelled
   local recipe_proto = prototypes.recipe[item.recipe]
   if recipe_proto then
      local message = Speech.new()
      message:fragment({ "fa.crafting-queue-cancelled" })
      message:fragment(tostring(math.min(cancel_count, item.count)))
      message:fragment(localising.get_localised_name_with_fallback(recipe_proto))
      Speech.speak(ctx.pindex, message:build())
   end

   -- Request re-render
   ctx:request_render()
end

-- Create callbacks structure for TabList compatibility
mod.callbacks = {
   render = mod.render,
   state_setup = mod.state_setup,
   on_click = mod.on_click,
}

mod.name = "crafting_queue"
mod.title = { "fa.crafting-queue-title" }

return mod
