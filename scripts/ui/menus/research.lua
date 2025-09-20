--[[
Research menu UI using the CategoryRows system.

Provides a category-based interface for research technologies where:
- Categories are: Researchable, Locked, Researched
- Items are technologies
- Left click enqueues at front, Ctrl+click enqueues at back
- K reads science pack requirements
]]

local CategoryRows = require("scripts.ui.category-rows")
local Research = require("scripts.research")
local Speech = require("scripts.speech")

local mod = {}

---Tech categories
local CATEGORY_RESEARCHABLE = "researchable"
local CATEGORY_LOCKED = "locked"
local CATEGORY_RESEARCHED = "researched"

---Get the localized name for a technology
---@param tech LuaTechnology
---@return LocalisedString
local function get_tech_name(tech)
   return { "?", tech.localised_name, { string.format("fa.research-technology-name-%s", tech.name) }, tech.name }
end

---Get the localized description for a technology
---@param tech LuaTechnology
---@return LocalisedString
local function get_tech_description(tech)
   return {
      "?",
      tech.localised_description,
      { string.format("fa.research-technology-description-%s", tech.name) },
      tech.name,
   }
end

---Categorize technologies into researchable, locked, and researched
---@param player LuaPlayer
---@return table<string, LuaTechnology[]>
local function categorize_technologies(player)
   local force = player.force
   local categories = {
      [CATEGORY_RESEARCHABLE] = {},
      [CATEGORY_LOCKED] = {},
      [CATEGORY_RESEARCHED] = {},
   }

   for _, tech in pairs(force.technologies) do
      if not tech.prototype.hidden then
         if tech.researched then
            table.insert(categories[CATEGORY_RESEARCHED], tech)
         elseif tech.enabled then
            table.insert(categories[CATEGORY_RESEARCHABLE], tech)
         else
            table.insert(categories[CATEGORY_LOCKED], tech)
         end
      end
   end

   -- Sort each category alphabetically by name
   for _, category in pairs(categories) do
      table.sort(category, function(a, b)
         return a.name < b.name
      end)
   end

   return categories
end

---Create the label for a technology
---@param ctx fa.ui.CategoryRows.ItemContext
---@param tech LuaTechnology
local function create_tech_label(ctx, tech)
   ctx.message:fragment(get_tech_name(tech))

   -- Add status information
   if tech.researched then
      ctx.message:fragment({ "fa.research-status-researched" })
   elseif tech.enabled then
      if tech.level > 1 then ctx.message:fragment({ "fa.research-level", tech.level }) end
      -- Check if in queue
      local force = ctx.player.force
      if force.research_queue then
         for i, queued in ipairs(force.research_queue) do
            if queued.name == tech.name then
               ctx.message:fragment({ "fa.research-in-queue", i })
               break
            end
         end
      end
   else
      ctx.message:fragment({ "fa.research-status-locked" })
   end
end

---Handle clicking on a technology (enqueue it)
---@param ctx fa.ui.CategoryRows.ItemContext
---@param tech LuaTechnology
---@param modifiers {control?: boolean, shift?: boolean, alt?: boolean}
local function handle_tech_click(ctx, tech, modifiers)
   if tech.researched then
      ctx.message:fragment({ "fa.research-already-researched" })
      return
   end

   if not tech.enabled then
      ctx.message:fragment({ "fa.research-needs-dependencies" })
      return
   end

   -- Determine queue position
   local queue_index = modifiers.control and nil or 1 -- nil means end of queue

   -- Use Research module's enqueue function
   local message, success = Research.enqueue(ctx.player, tech.name, queue_index)
   ctx.message:fragment(message)
end

---Read technology requirements
---@param ctx fa.ui.CategoryRows.ItemContext
---@param tech LuaTechnology
local function read_tech_requirements(ctx, tech)
   -- Description
   ctx.message:fragment({ "fa.research-description" })
   ctx.message:fragment(get_tech_description(tech))

   -- Science cost or trigger
   if tech.research_unit_count and tech.research_unit_count > 0 then
      ctx.message:fragment({ "fa.research-cost", tech.research_unit_count })

      -- List science packs
      ctx.message:fragment({ "fa.research-science-packs" })
      for _, ingredient in pairs(tech.research_unit_ingredients) do
         local proto = prototypes.item[ingredient.name]
         if proto then
            ctx.message:list_item(proto.localised_name or { "item-name." .. ingredient.name })
            ctx.message:fragment({ "fa.research-amount-per-cycle", ingredient.amount })
         end
      end
   elseif tech.research_trigger then
      ctx.message:fragment({ "fa.research-has-trigger" })
   end

   -- Prerequisites
   if next(tech.prerequisites) then
      ctx.message:fragment({ "fa.research-prerequisites" })
      for _, prereq in pairs(tech.prerequisites) do
         ctx.message:list_item(get_tech_name(prereq))
      end
   end
end

---Render the research menu
---@param ctx fa.ui.TabContext
---@return fa.ui.CategoryRows.Render?
local function render_research_menu(ctx)
   local player = ctx.player
   local categories = categorize_technologies(player)

   local builder = CategoryRows.CategoryRowsBuilder_new()

   -- Add researchable technologies
   if #categories[CATEGORY_RESEARCHABLE] > 0 then
      builder:add_category(CATEGORY_RESEARCHABLE, { "fa.research-category-researchable" })
      for _, tech in ipairs(categories[CATEGORY_RESEARCHABLE]) do
         local vtable = {}

         function vtable.label(item_ctx)
            create_tech_label(item_ctx, tech)
         end

         function vtable.on_click(item_ctx, mods)
            handle_tech_click(item_ctx, tech, mods)
         end

         function vtable.on_read_coords(item_ctx)
            read_tech_requirements(item_ctx, tech)
         end

         builder:add_item(CATEGORY_RESEARCHABLE, tech.name, vtable)
      end
   end

   -- Add locked technologies
   if #categories[CATEGORY_LOCKED] > 0 then
      builder:add_category(CATEGORY_LOCKED, { "fa.research-category-locked" })
      for _, tech in ipairs(categories[CATEGORY_LOCKED]) do
         local vtable = {}

         function vtable.label(item_ctx)
            create_tech_label(item_ctx, tech)
         end

         function vtable.on_click(item_ctx, mods)
            handle_tech_click(item_ctx, tech, mods)
         end

         function vtable.on_read_coords(item_ctx)
            read_tech_requirements(item_ctx, tech)
         end

         builder:add_item(CATEGORY_LOCKED, tech.name, vtable)
      end
   end

   -- Add researched technologies
   if #categories[CATEGORY_RESEARCHED] > 0 then
      builder:add_category(CATEGORY_RESEARCHED, { "fa.research-category-researched" })
      for _, tech in ipairs(categories[CATEGORY_RESEARCHED]) do
         local vtable = {}

         function vtable.label(item_ctx)
            create_tech_label(item_ctx, tech)
         end

         function vtable.on_click(item_ctx, mods)
            ctx.message:fragment({ "fa.research-already-researched" })
         end

         function vtable.on_read_coords(item_ctx)
            read_tech_requirements(item_ctx, tech)
         end

         builder:add_item(CATEGORY_RESEARCHED, tech.name, vtable)
      end
   end

   return builder:build()
end

-- Create the tab descriptor for the research menu
mod.research_tab = CategoryRows.declare_category_rows({
   name = "research",
   title = { "fa.research-title" },
   render_callback = render_research_menu,
})

return mod
