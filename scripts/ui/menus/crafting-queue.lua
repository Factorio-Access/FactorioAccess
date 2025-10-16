--[[
Crafting queue menu using the new TabList/MenuBuilder UI system.
Shows the player's crafting queue with the next item at the top.
Left bracket cancels the selected item.
]]

local Menu = require("scripts.ui.menu")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local localising = require("scripts.localising")
local KeyGraph = require("scripts.ui.key-graph")

local mod = {}

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render
local function render_crafting_queue(ctx)
   local builder = Menu.MenuBuilder.new()
   local player = game.get_player(ctx.pindex)
   if not player then return builder:build() end

   -- Refresh queue from player
   local queue = player.crafting_queue

   if not queue or #queue == 0 then
      -- Add a single item that announces the empty state
      builder:add_item("empty", {
         label = function(ctx)
            ctx.message:fragment({ "fa.crafting-queue-empty" })
         end,
      })
      return builder:build()
   end

   -- Add items from the queue, next item first
   for i, queue_item in ipairs(queue) do
      local recipe_proto = prototypes.recipe[queue_item.recipe]
      if recipe_proto then
         -- Create unique key using prototype name and index
         local key = queue_item.recipe .. "-" .. i

         -- Build label with localized name and count
         builder:add_item(key, {
            label = function(label_ctx)
               local name = localising.get_localised_name_with_fallback(recipe_proto)
               label_ctx.message:fragment(name):fragment(" x " .. queue_item.count)
            end,
            on_click = function(click_ctx)
               -- Cancel crafting
               local count = 1
               if click_ctx.modifiers.shift and click_ctx.modifiers.control then
                  count = queue_item.count
               elseif click_ctx.modifiers.shift then
                  count = 5
               end

               -- Cancel the crafting
               local cancelled_count = math.min(count, queue_item.count)
               player.cancel_crafting({
                  index = i,
                  count = cancelled_count,
               })

               -- Announce what was cancelled
               click_ctx.message:fragment({
                  "fa.crafting-queue-cancelled",
                  cancelled_count,
                  localising.get_localised_name_with_fallback(recipe_proto),
               })
            end,
         })
      end
   end

   return builder:build()
end

-- Create the tab descriptor
mod.crafting_queue_tab = KeyGraph.declare_graph({
   name = "crafting_queue",
   title = { "fa.crafting-queue-title" },
   render_callback = render_crafting_queue,
})

return mod
