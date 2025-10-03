--[[
Logistics configuration UI for entities with logistic sections.
Supports Factorio 2.0 multi-section logistics with groups.

Provides:
- Overview tab showing all logistic points and their compiled state
- Section editor tabs for each manual section
- Group management for organizing sections
]]

local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local LogisticsOverview = require("scripts.ui.logistics-overview")
local LogisticsSectionEditor = require("scripts.ui.logistics-section-editor")

local mod = {}

---Check if a logistic mode supports sections (requester or buffer)
---@param mode defines.logistic_mode
---@return boolean
local function supports_sections(mode)
   return mode == defines.logistic_mode.requester or mode == defines.logistic_mode.buffer
end

---Build tabs dynamically based on entity's logistic points and sections
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_logistics_tabs(pindex, parameters)
   assert(parameters, "build_logistics_tabs: parameters is nil")
   local entity = parameters.entity
   assert(entity, "build_logistics_tabs: entity is nil")
   assert(entity.valid, "build_logistics_tabs: entity is not valid")

   -- Get all logistic points
   local points_result = entity.get_logistic_point()
   local points = {}
   if points_result then
      if type(points_result) == "table" and points_result.object_name ~= "LuaLogisticPoint" then
         points = points_result
      else
         points = { points_result }
      end
   end

   -- Sort points: requester/buffer first, then others
   table.sort(points, function(a, b)
      local a_supports = supports_sections(a.mode)
      local b_supports = supports_sections(b.mode)
      if a_supports ~= b_supports then
         return a_supports -- true (requester/buffer) comes before false
      end
      return a.logistic_member_index < b.logistic_member_index
   end)

   -- Build point tabs
   local point_tabs = {}
   for i, point in ipairs(points) do
      table.insert(point_tabs, LogisticsOverview.create_point_tab(i, point))
   end

   -- Collect all manual sections from all points
   local all_sections = {}
   for point_idx, point in ipairs(points) do
      if supports_sections(point.mode) then
         for section_idx, section in pairs(point.sections) do
            if section.is_manual then
               table.insert(all_sections, {
                  point_index = point_idx,
                  section_index = section_idx,
                  section = section,
               })
            end
         end
      end
   end

   -- Sort sections by point index then section index
   table.sort(all_sections, function(a, b)
      if a.point_index ~= b.point_index then return a.point_index < b.point_index end
      return a.section_index < b.section_index
   end)

   -- Build section tabs
   local section_tabs = {}
   if #all_sections == 0 then
      -- No sections, add placeholder
      table.insert(section_tabs, LogisticsSectionEditor.create_no_sections_tab())
   else
      -- One tab per section
      for i, sec_info in ipairs(all_sections) do
         local title
         if sec_info.section.group and sec_info.section.group ~= "" then
            title = { "fa.logistics-section-in-group", tostring(i), sec_info.section.group }
         else
            title = { "fa.logistics-section-title", tostring(i) }
         end

         table.insert(
            section_tabs,
            LogisticsSectionEditor.create_section_tab(sec_info.point_index, sec_info.section_index, title)
         )
      end
   end

   return {
      {
         name = "points",
         tabs = point_tabs,
      },
      {
         name = "sections",
         tabs = section_tabs,
      },
   }
end

---Create and register the logistics configuration UI
mod.logistics_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.LOGISTICS_CONFIG,
   resets_to_first_tab_on_open = true,
   tabs_callback = build_logistics_tabs,
})

Router.register_ui(mod.logistics_ui)

return mod
