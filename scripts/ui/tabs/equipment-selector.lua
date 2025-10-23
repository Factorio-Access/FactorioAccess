--[[
Equipment selector for choosing equipment to place in grid.
Shows equipment from character inventory and target entity.
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Equipment = require("scripts.equipment")

local mod = {}

---Build the equipment selector menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_equipment_selector(ctx)
   local params = ctx.global_parameters

   local builder = Menu.MenuBuilder.new()

   -- Row 1: Dimension info (if provided)
   if params.max_x and params.max_y then
      builder:add_label("dimensions", { "fa.equipment-selector-dimensions", params.max_x, params.max_y })
   end

   -- Add equipment selection rows using the generified function
   Equipment.add_equipment_selection_rows(builder, params, function(equip_data)
      -- Close with result when equipment is selected
      ctx.controller:close_with_result({
         prototype_name = equip_data.name,
         quality_name = equip_data.quality,
         source = "inventory",
         first_stack = equip_data.stacks[1],
      })
   end)

   return builder:build()
end

local equipment_selector_tab = KeyGraph.declare_graph({
   name = "equipment_selector",
   title = { "fa.equipment-selector-title" },
   render_callback = render_equipment_selector,
})

mod.equipment_selector_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.EQUIPMENT_SELECTOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "equipment_selector",
            tabs = { equipment_selector_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.equipment_selector_menu)

return mod
