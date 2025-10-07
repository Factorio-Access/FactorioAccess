--[[
Research queue menu using the new TabList/MenuBuilder UI system.
Shows the force's research queue with the next research at the top.
Left bracket removes the selected research from the queue.
]]

local Menu = require("scripts.ui.menu")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local KeyGraph = require("scripts.ui.key-graph")

local mod = {}

-- Helper to get localized research name with fallback
---@param tech LuaTechnology|LuaTechnologyPrototype
---@return LocalisedString
local function get_tech_name(tech)
   return { "?", tech.localised_name, { string.format("fa.research-technology-name-%s", tech.name) }, tech.name }
end

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render
local function render_research_queue(ctx)
   local builder = Menu.MenuBuilder.new()
   local player = game.get_player(ctx.pindex)
   if not player then return builder:build() end

   -- Refresh queue from force
   local queue = player.force.research_queue

   if not queue or #queue == 0 then
      -- Add a single item that announces the empty state
      builder:add_item("empty", {
         label = function(ctx)
            ctx.message:fragment({ "fa.research-queue-empty" })
         end,
      })
      return builder:build()
   end

   -- Add researches from the queue, next research first
   for i, tech in ipairs(queue) do
      ---@cast tech LuaTechnology
      -- Use research name as key
      local key = tech.name

      -- Build label with localized name
      builder:add_item(key, {
         label = function(label_ctx)
            label_ctx.message:fragment(get_tech_name(tech))
         end,
         on_click = function(click_ctx, modifiers)
            -- Create a copy of the queue and remove this item
            local new_queue = {}
            for j, q_tech in ipairs(queue) do
               if j ~= i then table.insert(new_queue, q_tech.name) end
            end

            -- Assign the modified queue back to the force
            player.force.research_queue = new_queue

            -- Announce what was removed
            click_ctx.message:fragment({ "fa.research-queue-removed" })
            click_ctx.message:fragment(get_tech_name(tech))
         end,
      })
   end

   return builder:build()
end

-- Create the tab descriptor
mod.research_queue_tab = KeyGraph.declare_graph({
   name = "research_queue",
   title = { "fa.research-queue-title" },
   render_callback = render_research_queue,
})

return mod
