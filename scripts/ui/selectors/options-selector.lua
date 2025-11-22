--[[
Generic options selector.

A reusable selector that displays a menu of options provided by a callback function.
Used as a building block for specific selectors like train groups, station lists, etc.
]]

local Menu = require("scripts.ui.menu")
local TabList = require("scripts.ui.tab-list")
local KeyGraph = require("scripts.ui.key-graph")

local mod = {}

---@class fa.ui.selectors.OptionItem
---@field label LocalisedString|string The display label for this option
---@field value any The value to return when selected (can be nil)

---@class fa.ui.selectors.OptionsResult
---@field options fa.ui.selectors.OptionItem[] Array of options to display

---@class fa.ui.selectors.OptionsSelectorDeclaration
---@field ui_name fa.ui.UiName Unique UI name for this selector
---@field title LocalisedString Title for the selector tab
---@field get_options fun(pindex: number, parameters: table): fa.ui.selectors.OptionsResult Callback to get options

---@param declaration fa.ui.selectors.OptionsSelectorDeclaration
---@return fa.ui.TabList
function mod.declare_options_selector(declaration)
   assert(declaration.ui_name, "OptionsSelectorDeclaration must have ui_name")
   assert(declaration.title, "OptionsSelectorDeclaration must have title")
   assert(declaration.get_options, "OptionsSelectorDeclaration must have get_options")

   ---Build the options menu
   ---@param ctx fa.ui.graph.Ctx
   ---@return fa.ui.graph.Render?
   local function render_options(ctx)
      local player = game.get_player(ctx.pindex)
      if not player then return nil end

      -- Get options from callback
      local result = declaration.get_options(ctx.pindex, ctx.global_parameters or {})
      local options = result.options

      local menu = Menu.MenuBuilder.new()

      -- Add each option
      for i, option in ipairs(options) do
         local option_value = option.value
         menu:add_item("option_" .. i, {
            label = function(ctx)
               if type(option.label) == "string" then
                  ctx.message:fragment(option.label)
               else
                  ctx.message:fragment(option.label)
               end
            end,
            on_click = function(ctx)
               ctx.controller:close_with_result(option_value)
            end,
         })
      end

      return menu:build()
   end

   ---Create the selector tab
   ---@return fa.ui.TabDescriptor
   local function create_selector_tab()
      return KeyGraph.declare_graph({
         name = "options_selector",
         title = declaration.title,
         render_callback = render_options,
      })
   end

   ---Create and return the selector UI
   return TabList.declare_tablist({
      ui_name = declaration.ui_name,
      resets_to_first_tab_on_open = true,
      tabs_callback = function()
         return {
            {
               name = "selector",
               tabs = { create_selector_tab() },
            },
         }
      end,
   })
end

return mod
