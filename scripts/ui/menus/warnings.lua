--[[
Warnings menu using category-rows.

Displays production warnings (no fuel, no recipe, no power, not connected) where:
- Categories are warning types (sorted by proximity to cursor at open time)
- Items are individual entities with that warning
- Click moves cursor to the entity
]]

local CategoryRows = require("scripts.ui.category-rows")
local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")
local WarningsModule = require("scripts.warnings")
local Help = require("scripts.ui.help")

local mod = {}

---@class fa.ui.Warnings.SharedState
---@field warnings_by_type table<string, LuaEntity[]> Map of warning type to list of entities

---@class fa.ui.Warnings.Parameters

---Calculate distance from a point to an entity
---@param point MapPosition
---@param entity LuaEntity
---@return number
local function distance_to_entity(point, entity)
   local dx = entity.position.x - point.x
   local dy = entity.position.y - point.y
   return math.sqrt(dx * dx + dy * dy)
end

---Set up warnings data on menu open
---@param pindex integer
---@param params fa.ui.Warnings.Parameters
---@return fa.ui.Warnings.SharedState
local function state_setup(pindex, params)
   local cursor_pos = Viewpoint.get_viewpoint(pindex):get_cursor_pos()

   -- Scan for warnings in a large area (500x500 tiles)
   local scan_result = WarningsModule.scan_for_warnings(500, 500, pindex)

   -- Organize warnings by type
   local warnings_by_type = {}
   for _, warning_entry in ipairs(scan_result.warnings) do
      warnings_by_type[warning_entry.name] = warning_entry.ents
   end

   return {
      warnings_by_type = warnings_by_type,
      cursor_pos = cursor_pos,
   }
end

---Render the warnings menu
---@param ctx fa.ui.TabContext
---@return fa.ui.CategoryRows.Render?
local function render_warnings(ctx)
   local shared_state = ctx.shared_state

   -- Build list of categories with their closest entity distance
   local category_distances = {}
   for warning_type, entities in pairs(shared_state.warnings_by_type) do
      if #entities > 0 then
         -- Find closest entity of this type
         local min_dist = math.huge
         for _, entity in ipairs(entities) do
            if entity.valid then
               local dist = distance_to_entity(shared_state.cursor_pos, entity)
               if dist < min_dist then min_dist = dist end
            end
         end
         table.insert(category_distances, {
            warning_type = warning_type,
            min_distance = min_dist,
         })
      end
   end

   -- If no warnings found, return empty (category-rows will announce)
   if #category_distances == 0 then return { categories = {} } end

   -- Sort categories by proximity (closest first)
   table.sort(category_distances, function(a, b)
      return a.min_distance < b.min_distance
   end)

   local builder = CategoryRows.CategoryRowsBuilder_new()

   -- Add categories in sorted order
   for _, cat_info in ipairs(category_distances) do
      local warning_type = cat_info.warning_type
      local entities = shared_state.warnings_by_type[warning_type]

      -- Category label
      local category_label = { "fa.warning-type-" .. warning_type }
      builder:add_category(warning_type, category_label)

      -- Sort entities within category by distance
      local entity_distances = {}
      for _, entity in ipairs(entities) do
         if entity.valid then
            table.insert(entity_distances, {
               entity = entity,
               distance = distance_to_entity(shared_state.cursor_pos, entity),
            })
         end
      end

      table.sort(entity_distances, function(a, b)
         return a.distance < b.distance
      end)

      -- Add entities as items
      for _, ent_info in ipairs(entity_distances) do
         local entity = ent_info.entity
         local entity_key = tostring(entity.unit_number or entity.position.x .. "," .. entity.position.y)

         builder:add_item(warning_type, entity_key, {
            label = function(item_ctx)
               local name = Localising.get_localised_name_with_fallback(entity)
               item_ctx.message:fragment(name)
               item_ctx.message:fragment(FaUtils.format_position(entity.position.x, entity.position.y))
            end,
            on_click = function(item_ctx)
               if entity.valid then
                  Viewpoint.get_viewpoint(item_ctx.pindex):set_cursor_pos(entity.position)
                  item_ctx.message:fragment({ "fa.cursor-moved" })
               else
                  item_ctx.message:fragment({ "fa.warnings-entity-gone" })
               end
            end,
            on_read_coords = function(item_ctx)
               if entity.valid then
                  item_ctx.message:fragment(FaUtils.format_position(entity.position.x, entity.position.y))
               end
            end,
         })
      end
   end

   return builder:build()
end

-- Create the warnings TabList
mod.warnings_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.WARNINGS,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   tabs_callback = function(pindex, parameters)
      return {
         {
            name = "main",
            tabs = {
               CategoryRows.declare_category_rows({
                  name = "warnings",
                  title = { "fa.warnings-menu-title" },
                  render_callback = render_warnings,
                  get_help_metadata = function(ctx)
                     return {
                        Help.message_list("warnings-menu-help"),
                     }
                  end,
               }),
            },
         },
      }
   end,
})

-- Register with the UI router
UiRouter.register_ui(mod.warnings_menu)

return mod
