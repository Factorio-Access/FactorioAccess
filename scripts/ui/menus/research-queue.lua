--[[
Research queue menu using the new TabList/MenuBuilder UI system.
Shows the force's research queue with the next research at the top.
Left bracket removes the selected research from the queue.
]]

local Menu = require("scripts.ui.menu")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

-- Helper to get localized research name with fallback
---@param tech LuaTechnology|LuaTechnologyPrototype
---@return LocalisedString
local function get_tech_name(tech)
   return { "?", tech.localised_name, { string.format("fa.research-technology-name-%s", tech.name) }, tech.name }
end

---@param ctx fa.ui.TabContext
function mod.state_setup(ctx)
   -- Empty state setup required by TabList
end

---@param ctx fa.ui.TabContext
function mod.render(ctx)
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
      -- Use research name as key
      local key = tech.name

      -- Build label with localized name
      builder:add_item(key, {
         label = function(ctx)
            ctx.message:fragment(get_tech_name(tech))
         end,
      })
   end

   return builder:build()
end

---@param ctx fa.ui.TabContext
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
function mod.on_click(ctx, modifiers)
   local player = game.get_player(ctx.pindex)
   if not player then return end

   local queue = player.force.research_queue
   if not queue or #queue == 0 then
      Speech.speak(ctx.pindex, { "fa.research-queue-empty" })
      return
   end

   -- Get the selected key (which is the research name)
   local selected_key = ctx:get_cursor_key()
   if not selected_key or selected_key == "empty" then return end

   -- Find the research in the queue
   local index_to_remove = nil
   local tech_to_remove = nil
   for i, tech in ipairs(queue) do
      if tech.name == selected_key then
         index_to_remove = i
         tech_to_remove = tech
         break
      end
   end

   if not index_to_remove then return end

   -- Create a copy of the queue and remove the selected item
   local new_queue = {}
   for i, tech in ipairs(queue) do
      if i ~= index_to_remove then table.insert(new_queue, tech.name) end
   end

   -- Assign the modified queue back to the force
   player.force.research_queue = new_queue

   -- Announce what was removed
   if tech_to_remove then
      local message = MessageBuilder.new()
      message:fragment({ "fa.research-queue-removed" })
      message:fragment(get_tech_name(tech_to_remove))
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

mod.name = "research_queue"
mod.title = { "fa.research-queue-title" }

return mod
