--[[
Logistic group selector UI.

Allows selecting a logistic group from existing groups or creating a new one.
Returns the selected group name to the parent UI.
]]

local Menu = require("scripts.ui.menu")
local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local KeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")
local BotLogistics = require("scripts.worker-robots")

local mod = {}

---Build the group selector menu
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_group_selector(ctx)
   local player = game.get_player(ctx.pindex)
   if not player then return nil end

   local force = player.force

   -- Validate entity at render time
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   if not entity or not entity.valid then return nil end

   -- Determine group type based on entity
   local group_type = BotLogistics.get_logistic_group_type_for_entity(entity)

   -- Get existing groups
   local groups = force.get_logistic_groups(group_type) or {}
   table.sort(groups)

   local menu = Menu.MenuBuilder.new()

   -- Add a "no group" option
   menu:add_item("no_group", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-no-group" })
      end,
      on_click = function(ctx)
         ctx.controller:close_with_result("")
      end,
   })

   -- Add existing groups
   for i, group_name in ipairs(groups) do
      menu:add_item("group_" .. i, {
         label = function(ctx)
            ctx.message:fragment(group_name)
         end,
         on_click = function(ctx)
            ctx.controller:close_with_result(group_name)
         end,
         on_dangerous_delete = function(ctx)
            local force = game.get_player(ctx.pindex).force
            local entity = ctx.global_parameters.entity
            local group_type = BotLogistics.get_logistic_group_type_for_entity(entity)

            force.delete_logistic_group(group_name, group_type)

            UiSounds.play_menu_move(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-group-deleted", group_name })
         end,
      })
   end

   -- Add "Create new group" option
   menu:add_item("create_new", {
      label = function(ctx)
         ctx.message:fragment({ "fa.logistics-create-new-group" })
      end,
      on_click = function(ctx)
         ctx.controller:open_textbox("", { node = "create_new" }, { "fa.logistics-enter-group-name" })
      end,
      on_child_result = function(ctx, result)
         if result and result ~= "" then
            local force = game.get_player(ctx.pindex).force

            -- Entity already validated at render callback entry
            local entity = ctx.global_parameters.entity
            local group_type = BotLogistics.get_logistic_group_type_for_entity(entity)

            -- Create the group (this is idempotent - safe to call if it exists)
            force.create_logistic_group(result, group_type)

            -- Return the new group name
            ctx.controller:close_with_result(result)
         else
            UiSounds.play_ui_edge(ctx.pindex)
            ctx.controller.message:fragment({ "fa.logistics-invalid-group-name" })
         end
      end,
   })

   return menu:build()
end

---Create the group selector tab
---@return fa.ui.TabDescriptor
local function create_group_selector_tab()
   return KeyGraph.declare_graph({
      name = "group_selector",
      title = { "fa.logistics-select-group" },
      render_callback = render_group_selector,
   })
end

---Create and register the group selector UI
mod.group_selector_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.LOGISTIC_GROUP_SELECTOR,
   resets_to_first_tab_on_open = true,
   tabs_callback = function()
      return {
         {
            name = "selector",
            tabs = { create_group_selector_tab() },
         },
      }
   end,
})

Router.register_ui(mod.group_selector_ui)

return mod
