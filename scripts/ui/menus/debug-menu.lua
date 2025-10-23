local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local BoxSelector = require("scripts.ui.box-selector")
local Help = require("scripts.ui.help")
local serpent = require("serpent")

-- Load the form builder test UI
require("scripts.ui.menus.debug-formbuilder")

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_debug_menu(ctx)
   local builder = Menu.MenuBuilder.new()

   builder:add_clickable("choose_item", { "fa.debug-menu-choose-item" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.ITEM_CHOOSER, {}, { node = "choose_item" })
      end,
      on_child_result = function(result_ctx, item_name)
         if item_name then result_ctx.controller.message:fragment({ "fa.debug-item-chosen", item_name }) end
      end,
   })

   builder:add_clickable("choose_signal", { "fa.debug-menu-choose-signal" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.SIGNAL_CHOOSER, {}, { node = "choose_signal" })
      end,
      on_child_result = function(result_ctx, signal_id)
         if signal_id then
            local msg = { "fa.debug-signal-chosen", signal_id.type or "item", signal_id.name or "unknown" }
            result_ctx.controller.message:fragment(msg)
         end
      end,
   })

   builder:add_clickable("test_box_selection", { "fa.debug-menu-box-selection" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.BOX_SELECTOR)
      end,
      on_child_result = function(result_ctx, result)
         -- Result is already spoken by the box selector callback
      end,
   })

   builder:add_clickable("open_form_builder", { "fa.debug-menu-form-builder" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.DEBUG_FORMBUILDER)
      end,
      on_child_result = function(result_ctx, result)
         if result then
            result_ctx.controller.message:fragment("Form builder test closed with result: " .. tostring(result))
         end
      end,
   })

   return builder:build()
end

local debug_menu_tab = KeyGraph.declare_graph({
   name = "debug_menu",
   render_callback = build_debug_menu,
   title = { "fa.debug-menu-title" },
   get_help_metadata = function(ctx)
      return {
         Help.message_list("debug-menu-help"),
      }
   end,
})

mod.debug_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.DEBUG,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "debug",
            tabs = { debug_menu_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.debug_menu)

-- Register box selector UI
local test_box_selector = BoxSelector.declare_box_selector({
   ui_name = UiRouter.UI_NAMES.BOX_SELECTOR,
   callback = function(pindex, params, result)
      -- This is called when selection completes
      local msg = MessageBuilder.new()
      msg:fragment("Box selection result: ")
      msg:fragment(serpent.line(result, { nocode = true }))
      Speech.speak(pindex, msg:build())
   end,
})

UiRouter.register_ui(test_box_selector)

return mod
