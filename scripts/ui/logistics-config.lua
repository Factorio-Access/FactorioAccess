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
local LogisticsUnified = require("scripts.ui.tabs.logistics-unified")
local LogisticsSectionEditor = require("scripts.ui.tabs.logistics-section-editor")

local mod = {}

---Build tabs dynamically based on entity's logistic points and sections
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_logistics_tabs(pindex, parameters)
   assert(parameters, "build_logistics_tabs: parameters is nil")
   local entity = parameters.entity
   assert(entity, "build_logistics_tabs: entity is nil")
   assert(entity.valid, "build_logistics_tabs: entity is not valid")

   -- Get entity-level logistic sections (works on all entities)
   local sections_obj = entity.get_logistic_sections()
   local all_sections = {}

   if sections_obj then
      for section_idx, section in pairs(sections_obj.sections) do
         if section.is_manual then
            table.insert(all_sections, {
               section_index = section_idx,
               section = section,
            })
         end
      end
   end

   -- Sort sections by section index
   table.sort(all_sections, function(a, b)
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

         table.insert(section_tabs, LogisticsSectionEditor.create_section_tab(sec_info.section_index, title))
      end
   end

   return {
      {
         name = "overview",
         tabs = { LogisticsUnified.create_unified_tab() },
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
