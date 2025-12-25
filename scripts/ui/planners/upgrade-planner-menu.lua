--[[
Upgrade Planner Menu
Main menu for configuring upgrade planner rules.
24 slots for upgrade rules, plus actions for clear/name/export/import.
]]

local Menu = require("scripts.ui.menu")
local TabList = require("scripts.ui.tab-list")
local KeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder
local UpgradePlanner = require("scripts.upgrade-planner")
local Localising = require("scripts.localising")
local EntityChooser = require("scripts.ui.tabs.entity-chooser")
local ItemChooser = require("scripts.ui.tabs.item-chooser")
local LauncherCommands = require("scripts.launcher-commands")
local PlannerUtils = require("scripts.planner-utils")

local mod = {}

local MAX_SLOTS = 24

---Get the upgrade planner from cursor (direct or in book)
---@param pindex number
---@return LuaItemStack|nil
local function get_planner(pindex)
   local planner = PlannerUtils.get_upgrade_planner(pindex)
   return planner
end

---Make the planner permanent (not temporary cursor item)
---@param pindex number
local function make_permanent(pindex)
   local player = game.get_player(pindex)
   if player then player.cursor_stack_temporary = false end
end

---Render a single slot row
---@param builder fa.ui.menu.MenuBuilder
---@param planner LuaItemStack
---@param slot_index number
local function render_slot(builder, planner, slot_index)
   local row_key = "slot_" .. slot_index

   builder:start_row(row_key)

   local has_rule = UpgradePlanner.is_rule_defined(planner, slot_index)

   builder:add_clickable(row_key .. "_main", function(ctx)
      if has_rule then
         local mb = MessageBuilder.new()
         UpgradePlanner.read_planner_rule(mb, planner, slot_index)
         ctx.message:fragment(mb:build())
         ctx.message:list_item({ "fa.upgrade-slot-number", slot_index })
      else
         ctx.message:fragment({ "fa.upgrade-no-rule", slot_index })
      end
   end, {
      on_click = function(ctx)
         -- Start entity rule flow (step 1: select source)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.ENTITY_CHOOSER, {
            filter_type = EntityChooser.FILTER_TYPES.UPGRADEABLE,
         }, {
            node = row_key .. "_main",
            slot_index = slot_index,
            step = "entity_source",
         })
      end,
      on_action1 = function(ctx)
         -- Start module rule flow (step 1: select source)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.ITEM_CHOOSER, {
            filter_type = ItemChooser.FILTER_TYPES.MODULE,
         }, {
            node = row_key .. "_main",
            slot_index = slot_index,
            step = "module_source",
         })
      end,
      on_clear = function(ctx)
         -- Remove rule at this slot
         planner.set_mapper(slot_index, "from", nil)
         planner.set_mapper(slot_index, "to", nil)
         make_permanent(ctx.pindex)
         ctx.message:fragment({ "fa.upgrade-rule-removed" })
      end,
      on_child_result = function(ctx, result)
         local child_ctx = ctx.child_context
         local step = child_ctx.step
         local idx = child_ctx.slot_index

         if step == "entity_source" then
            -- Got source entity, now select target
            local source_name = result
            local fast_group = UpgradePlanner.get_fast_replaceable_group(source_name)
            ctx.controller:open_child_ui(UiRouter.UI_NAMES.ENTITY_CHOOSER, {
               filter_type = EntityChooser.FILTER_TYPES.SAME_FAST_GROUP,
               fast_replaceable_group = fast_group,
            }, {
               node = row_key .. "_main",
               slot_index = idx,
               step = "entity_target",
               source_name = source_name,
            })
         elseif step == "entity_target" then
            -- Got target entity, create the rule
            local source_name = child_ctx.source_name
            local target_name = result
            planner.set_mapper(idx, "from", { type = "entity", name = source_name })
            planner.set_mapper(idx, "to", { type = "entity", name = target_name })
            make_permanent(ctx.pindex)
            ctx.message:fragment({ "fa.upgrade-rule-added" })
         elseif step == "module_source" then
            -- Got source module, now select target
            local source_name = result
            ctx.controller:open_child_ui(UiRouter.UI_NAMES.ITEM_CHOOSER, {
               filter_type = ItemChooser.FILTER_TYPES.MODULE,
            }, {
               node = row_key .. "_main",
               slot_index = idx,
               step = "module_target",
               source_name = source_name,
            })
         elseif step == "module_target" then
            -- Got target module, create the rule
            local source_name = child_ctx.source_name
            local target_name = result
            planner.set_mapper(idx, "from", { type = "item", name = source_name })
            planner.set_mapper(idx, "to", { type = "item", name = target_name })
            make_permanent(ctx.pindex)
            ctx.message:fragment({ "fa.upgrade-rule-added" })
         end
      end,
   })

   builder:end_row()
end

---Render the actions section
---@param builder fa.ui.menu.MenuBuilder
---@param planner LuaItemStack
---@param pindex number
local function render_actions(builder, planner, pindex)
   builder:start_row("actions")

   -- Clear all
   builder:add_clickable("clear_all", { "fa.upgrade-clear-all" }, {
      on_click = function(ctx)
         planner.clear_upgrade_item()
         make_permanent(pindex)
         ctx.message:fragment({ "fa.upgrade-rules-cleared" })
      end,
   })

   -- Set name
   builder:add_clickable("set_name", { "fa.upgrade-set-name" }, {
      on_click = function(ctx)
         ctx.controller:open_textbox(planner.label or "", "set_name")
      end,
      on_child_result = function(ctx, result)
         planner.label = result
         make_permanent(pindex)
         ctx.message:fragment({ "fa.upgrade-name-set" })
      end,
   })

   -- Export
   builder:add_clickable("export", { "fa.upgrade-export" }, {
      on_click = function(ctx)
         LauncherCommands.copy_to_clipboard(pindex, planner.export_stack())
         ctx.message:fragment({ "fa.upgrade-planner-exported" })
      end,
   })

   -- Import
   builder:add_clickable("import", { "fa.upgrade-import" }, {
      on_click = function(ctx)
         ctx.controller:open_textbox("", "import")
      end,
      on_child_result = function(ctx, result)
         if result and result ~= "" then
            local status = planner.import_stack(result)
            if status == 0 then
               make_permanent(pindex)
               ctx.message:fragment({ "fa.upgrade-planner-imported" })
            elseif status == -1 then
               make_permanent(pindex)
               ctx.message:fragment({ "fa.upgrade-planner-imported-with-errors" })
            else
               ctx.message:fragment({ "fa.upgrade-planner-import-failed" })
            end
         end
      end,
   })

   builder:end_row()
end

---@param ctx fa.ui.graph.Ctx
local function render_upgrade_planner(ctx)
   local planner = get_planner(ctx.pindex)
   if not planner then return nil end

   local builder = Menu.MenuBuilder.new()

   -- Render action buttons at top
   render_actions(builder, planner, ctx.pindex)

   -- Render 24 slots
   for i = 1, MAX_SLOTS do
      render_slot(builder, planner, i)
   end

   return builder:build()
end

local upgrade_planner_tab = KeyGraph.declare_graph({
   name = "upgrade_planner",
   render_callback = render_upgrade_planner,
   title = { "fa.upgrade-planner-title" },
})

mod.upgrade_planner_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.UPGRADE_PLANNER,
   resets_to_first_tab_on_open = true,
   get_binds = function(pindex, parameters)
      return { { kind = UiRouter.BIND_KIND.HAND_CONTENTS } }
   end,
   tabs_callback = function()
      return {
         {
            name = "upgrade_planner",
            tabs = { upgrade_planner_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.upgrade_planner_menu)

return mod
