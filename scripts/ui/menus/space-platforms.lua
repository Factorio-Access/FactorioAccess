--[[
The force's space platforms, from the mod menu with space travel. The list starts with "New platform" and reads
each platform's status; clicking one opens its actions: rename, thrust, schedule, delete or cancel deletion.

New platforms are made the game's way: create_space_platform leaves the platform waiting for a starter pack, which
a rocket silo on the chosen planet sends up when it has one and automatic requests are on.
]]

local FaUtils = require("scripts.fa-utils")
local FormBuilder = require("scripts.ui.form-builder")
local KeyGraph = require("scripts.ui.key-graph")
local Localising = require("scripts.localising")
local Menu = require("scripts.ui.menu")
local PlatformTravel = require("scripts.platform-travel")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")

local mod = {}

---@param ctx fa.ui.graph.Ctx
local function build_platform_list(ctx)
   local builder = Menu.MenuBuilder.new()
   local force = game.get_player(ctx.pindex).force --[[@as LuaForce]]

   if force.is_space_platforms_unlocked() then
      builder:add_clickable("new", { "fa.space-platforms-new" }, {
         on_click = function(click_ctx)
            click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.NEW_SPACE_PLATFORM)
         end,
      })
   else
      builder:add_label("locked", { "gui-side-menu.space-platforms-locked" })
   end

   ---@type LuaSpacePlatform[]
   local platforms = {}
   for _, platform in pairs(force.platforms) do
      if not platform.hidden then table.insert(platforms, platform) end
   end
   table.sort(platforms, function(a, b)
      return a.index < b.index
   end)

   for _, platform in ipairs(platforms) do
      builder:add_clickable("platform-" .. platform.index, function(label_ctx)
         PlatformTravel.describe(platform, label_ctx.message)
      end, {
         on_click = function(click_ctx)
            click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.SPACE_PLATFORM, { platform = platform })
         end,
      })
   end

   return builder:build()
end

---The GUI refuses to delete a platform with players aboard; so do we.
---@param platform LuaSpacePlatform
---@return boolean
local function has_passengers(platform)
   -- Nil until the starter pack arrives
   local surface = platform.surface --[[@as LuaSurface?]]
   if not surface then return false end
   for _, player in pairs(game.players) do
      if player.physical_surface == surface then return true end
   end
   return false
end

---@param paused boolean
---@return LocalisedString
local function thrust_mode_name(paused)
   return paused and { "gui-train.paused-mode" } or { "gui-train.automatic-mode" }
end

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function build_platform(ctx)
   local platform = ctx.global_parameters.platform --[[@as LuaSpacePlatform]]
   if not platform.valid then return nil end

   local builder = Menu.MenuBuilder.new()

   builder:add_label("status", function(label_ctx)
      PlatformTravel.describe(platform, label_ctx.message)
   end)

   builder:add_clickable("rename", { "fa.space-platform-rename" }, {
      on_click = function(click_ctx)
         click_ctx.controller:open_textbox(platform.name, "rename")
      end,
      on_child_result = function(result_ctx, result)
         if result == "" then return end
         platform.name = result
         result_ctx.controller.message:fragment({ "fa.space-platform-renamed", platform.name })
      end,
   })

   builder:add_item("thrust", {
      label = function(label_ctx)
         label_ctx.message:fragment(thrust_mode_name(platform.paused))
      end,
      on_click = function(click_ctx)
         platform.paused = not platform.paused
         click_ctx.controller.message:fragment(thrust_mode_name(platform.paused))
      end,
   })

   local hub = platform.hub
   if hub then
      builder:add_clickable("schedule", { "fa.locomotive-edit-schedule" }, {
         on_click = function(click_ctx)
            click_ctx.controller:open_child_ui(UiRouter.UI_NAMES.SCHEDULE_EDITOR, { entity = hub })
         end,
      })
   end

   -- One key for both, so the cursor stays put when deleting turns into cancelling
   if platform.scheduled_for_deletion > 0 then
      builder:add_clickable("delete", { "gui-space-platforms.cancel-delete" }, {
         on_click = function(click_ctx)
            platform.cancel_deletion()
            click_ctx.controller.message:fragment({ "fa.space-platform-deletion-cancelled" })
         end,
      })
   else
      builder:add_clickable("delete", { "gui-space-platforms.delete" }, {
         on_click = function(click_ctx)
            click_ctx.controller.message:fragment({ "fa.space-platform-delete-hint" })
         end,
         on_dangerous_delete = function(delete_ctx)
            if has_passengers(platform) then
               delete_ctx.controller.message:fragment({ "gui-space-platforms.cant-delete-platform" })
               return
            end
            platform.destroy()
            local ticks = platform.valid and platform.scheduled_for_deletion or 0
            if ticks > 0 then
               delete_ctx.controller.message:fragment({ "fa.space-platform-deleting", FaUtils.format_time(ticks) })
            else
               delete_ctx.controller.message:fragment({ "fa.space-platform-deleted" })
               delete_ctx.controller:close()
            end
         end,
      })
   end

   return builder:build()
end

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render
local function build_new_platform(ctx)
   local player = game.get_player(ctx.pindex) --[[@as LuaPlayer]]
   local force = player.force --[[@as LuaForce]]
   local state = ctx.state
   local form = FormBuilder.FormBuilder.new()

   -- The rocket with the starter pack comes from the planet's own surface
   ---@type LuaPlanet[]
   local planets = {}
   for name, planet in pairs(game.planets) do
      -- The API docs omit this method's boolean return
      local unlocked = force.is_space_location_unlocked(name) --[[@as boolean]]
      if not planet.prototype.hidden and planet.surface and unlocked then table.insert(planets, planet) end
   end
   if #planets == 0 then
      form:add_label("no_planet", { "fa.space-platform-no-planet" })
      return form:build()
   end
   table.sort(planets, function(a, b)
      return a.prototype.order < b.prototype.order
   end)
   -- The player's own planet first; in space, the first planet
   local here = player.physical_surface.planet
   local default_index = 1
   for i, planet in ipairs(planets) do
      if here and planet.name == here.name then default_index = i end
   end
   local planet_choices = {}
   for i, planet in ipairs(planets) do
      table.insert(planet_choices, {
         label = Localising.get_localised_name_with_fallback(planet.prototype),
         value = planet.name,
         default = i == default_index,
      })
   end

   ---@type LuaItemPrototype[]
   local packs = {}
   for _, item in pairs(prototypes.get_item_filtered({ { filter = "type", type = "space-platform-starter-pack" } })) do
      if not item.hidden then table.insert(packs, item) end
   end
   table.sort(packs, function(a, b)
      return a.order < b.order
   end)
   state.pack = state.pack or packs[1].name

   form:add_textfield("name", {
      label = { "gui-new-space-platform.name" },
      get_value = function()
         return state.name or ""
      end,
      set_value = function(value)
         state.name = value
      end,
   })

   state.planet = state.planet or planets[default_index].name

   form:add_choice_field("planet", { "gui-new-space-platform.planet" }, function()
      return state.planet
   end, function(value)
      state.planet = value
   end, planet_choices)

   if #packs > 1 then
      local pack_choices = {}
      for _, pack in ipairs(packs) do
         table.insert(pack_choices, { label = Localising.get_localised_name_with_fallback(pack), value = pack.name })
      end
      form:add_choice_field("starter_pack", { "gui-new-space-platform.starter-pack" }, function()
         return state.pack
      end, function(value)
         state.pack = value
      end, pack_choices)
   end

   form:add_action("create", { "gui-new-space-platform.create" }, function(controller)
      local name = state.name
      local platform = force.create_space_platform({
         name = name ~= "" and name or nil,
         planet = state.planet,
         starter_pack = state.pack,
      })
      if not platform then
         controller.message:fragment({ "fa.space-platform-create-failed" })
         return
      end
      local planet = Localising.get_localised_name_with_fallback(prototypes.space_location[state.planet])
      controller.message:fragment({ "fa.space-platform-created", platform.name, planet })
      controller:close()
   end)

   return form:build()
end

local platform_list_tab = KeyGraph.declare_graph({
   name = "space_platforms",
   render_callback = build_platform_list,
   title = { "gui-space-platforms.title" },
})

local platform_tab = KeyGraph.declare_graph({
   name = "space_platform",
   render_callback = build_platform,
   title = { "fa.space-platform-title" },
})

local new_platform_tab = KeyGraph.declare_graph({
   name = "new_space_platform",
   render_callback = build_new_platform,
   title = { "gui-new-space-platform.title" },
})

---@param ui_name fa.ui.UiName
---@param tab fa.ui.TabDescriptor
local function single_tab_ui(ui_name, tab)
   return TabList.declare_tablist({
      ui_name = ui_name,
      resets_to_first_tab_on_open = true,
      tabs_callback = function()
         return { { name = "main", tabs = { tab } } }
      end,
   })
end

mod.space_platforms = single_tab_ui(UiRouter.UI_NAMES.SPACE_PLATFORMS, platform_list_tab)
mod.space_platform = single_tab_ui(UiRouter.UI_NAMES.SPACE_PLATFORM, platform_tab)
mod.new_space_platform = single_tab_ui(UiRouter.UI_NAMES.NEW_SPACE_PLATFORM, new_platform_tab)

UiRouter.register_ui(mod.space_platforms)
UiRouter.register_ui(mod.space_platform)
UiRouter.register_ui(mod.new_space_platform)

return mod
