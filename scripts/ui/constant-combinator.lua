--[[
Constant combinator UI for Factorio 2.0.

Provides a TabList UI for constant combinators with:
- Main tabstop: Overview + Circuit network signals
- Sections tabstop: One tab per section for editing outputs
]]

local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local CircuitNetworkSignals = require("scripts.ui.tabs.circuit-network-signals")
local CircuitNetwork = require("scripts.circuit-network")
local LogisticsSectionEditor = require("scripts.ui.tabs.logistics-section-editor")

local mod = {}

---Render the constant combinator overview tab
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_overview(ctx)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   assert(entity and entity.valid, "render_overview: entity is nil or invalid")

   local cb = entity.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
   assert(cb, "render_overview: no control behavior found")

   local menu = Menu.MenuBuilder.new()

   -- Row 1: Active toggle
   menu:start_row("active_row")
   menu:add_item("active", {
      label = function(ctx)
         if cb.enabled then
            ctx.message:fragment({ "fa.logistics-active-checked" })
         else
            ctx.message:fragment({ "fa.logistics-active-unchecked" })
         end
      end,
      on_click = function(ctx)
         cb.enabled = not cb.enabled
      end,
   })
   menu:end_row()

   -- Row 2: Outputs overview
   menu:add_label("outputs_overview", function(ctx)
      local all_signals = CircuitNetwork.get_constant_combinator_filters(entity)

      if #all_signals > 0 then
         ctx.message:list_item({ "fa.constant-combinator-outputs" })
         for _, signal_info in ipairs(all_signals) do
            ctx.message:list_item()
            ctx.message:fragment(CircuitNetwork.localise_signal(signal_info.signal))
            if signal_info.count > 0 then
               ctx.message:fragment("x")
               ctx.message:fragment(tostring(signal_info.count))
            end
         end
      else
         ctx.message:list_item({ "fa.constant-combinator-no-outputs" })
      end
   end)

   -- Row 3: Section management
   menu:start_row("section_management")

   -- Section info
   menu:add_item("section_info", {
      label = function(ctx)
         local manual_count = 0
         local groups_set = {}
         for _, section in ipairs(cb.sections or {}) do
            if section.is_manual then
               manual_count = manual_count + 1
               if section.group and section.group ~= "" then groups_set[section.group] = true end
            end
         end

         local groups = {}
         for group, _ in pairs(groups_set) do
            table.insert(groups, group)
         end
         table.sort(groups)

         if manual_count == 0 then
            ctx.message:fragment({ "fa.logistics-no-sections" })
         elseif manual_count == 1 then
            ctx.message:fragment({ "fa.logistics-one-section" })
         else
            ctx.message:fragment({ "fa.logistics-n-sections", tostring(manual_count) })
         end

         if #groups > 0 then
            ctx.message:fragment({ "fa.logistics-sections-in-groups" })
            for _, group in ipairs(groups) do
               ctx.message:fragment(group)
            end
         end
      end,
   })

   -- Add section at end (constant combinators don't support adding at specific index)
   menu:add_item("add_section", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-add-section-end" })
      end,
      on_click = function(ctx)
         local new_section = cb.add_section()
         if new_section then
            ctx.controller.message:fragment({ "fa.logistics-section-added-end" })
         else
            ctx.controller.message:fragment({ "fa.logistics-section-add-failed" })
         end
      end,
   })

   menu:end_row()

   return menu:build()
end

---Build tabs for the constant combinator
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_constant_combinator_tabs(pindex, parameters)
   assert(parameters, "build_constant_combinator_tabs: parameters is nil")
   local entity = parameters.entity
   assert(entity, "build_constant_combinator_tabs: entity is nil")
   assert(entity.valid, "build_constant_combinator_tabs: entity is not valid")

   local cb = entity.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
   assert(cb, "build_constant_combinator_tabs: no control behavior")

   -- Tabstop 1: Main (Overview + Circuit signals)
   local main_tabs = {}

   -- Overview tab
   table.insert(
      main_tabs,
      KeyGraph.declare_graph({
         name = "overview",
         title = { "fa.logistics-overview-title" },
         render_callback = render_overview,
      })
   )

   -- Circuit network signals tabs (red and green)
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-red" },
         false,
         defines.wire_connector_id.circuit_red
      )
   )
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-green" },
         false,
         defines.wire_connector_id.circuit_green
      )
   )

   -- Tabstop 2: Sections (one tab per manual section)
   local section_tabs = {}

   -- Collect all manual sections
   local manual_sections = {}
   for section_idx, section in ipairs(cb.sections or {}) do
      if section.is_manual then
         table.insert(manual_sections, {
            section_index = section_idx,
            section = section,
         })
      end
   end

   if #manual_sections == 0 then
      -- No sections placeholder
      table.insert(
         section_tabs,
         KeyGraph.declare_graph({
            name = "no_sections",
            title = { "fa.logistics-no-sections" },
            render_callback = function(ctx)
               local menu = Menu.MenuBuilder.new()
               menu:add_label("no_sections_msg", function(ctx)
                  ctx.message:fragment({ "fa.constant-combinator-no-sections-message" })
               end)
               return menu:build()
            end,
         })
      )
   else
      -- Section editor tabs
      for i, sec_info in ipairs(manual_sections) do
         local title
         if sec_info.section.group and sec_info.section.group ~= "" then
            title = { "fa.logistics-section-in-group", tostring(i), sec_info.section.group }
         else
            title = { "fa.logistics-section-title", tostring(i) }
         end

         -- For constant combinators, pass nil for point_index
         table.insert(section_tabs, LogisticsSectionEditor.create_section_tab(nil, sec_info.section_index, title))
      end
   end

   return {
      {
         name = "main",
         tabs = main_tabs,
      },
      {
         name = "sections",
         tabs = section_tabs,
      },
   }
end

---Create and register the constant combinator UI
mod.constant_combinator_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.CONSTANT_COMBINATOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = build_constant_combinator_tabs,
})

Router.register_ui(mod.constant_combinator_ui)

return mod
