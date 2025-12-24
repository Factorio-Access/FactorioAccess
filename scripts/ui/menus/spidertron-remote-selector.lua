local FaInfo = require("scripts.fa-info")
local FaUtils = require("scripts.fa-utils")
local FormBuilder = require("scripts.ui.form-builder")
local KeyGraph = require("scripts.ui.key-graph")
local SpidertronRemote = require("scripts.spidertron-remote")
local Speech = require("scripts.speech")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---Get all spidertrons on the player's force on the relevant surface
---@param pindex number
---@return LuaEntity[]
local function get_available_spidertrons(pindex)
   local player = game.get_player(pindex)
   if not player then return {} end

   -- Determine which surface to search
   local surface
   local current_list = player.spidertron_remote_selection or {}
   if #current_list > 0 then
      -- Use surface from first spidertron in remote
      surface = game.surfaces[current_list[1].surface_index]
   elseif player.character then
      -- Use player's surface
      surface = player.character.surface
   else
      return {}
   end

   -- Find all spidertrons on the surface
   local all_spidertrons = surface.find_entities_filtered({
      type = "spider-vehicle",
      force = player.force,
   })

   -- Filter out ghosts and sort by unit number
   local valid_spidertrons = {}
   for _, spider in ipairs(all_spidertrons) do
      if spider.valid and spider.name ~= "entity-ghost" then table.insert(valid_spidertrons, spider) end
   end

   table.sort(valid_spidertrons, function(a, b)
      return a.unit_number < b.unit_number
   end)

   return valid_spidertrons
end

---Build the spidertron selector form
---@param ctx fa.ui.graph.Ctx
local function build_spidertron_form(ctx)
   local player = game.get_player(ctx.pindex)
   if not player then return nil end

   local spidertrons = get_available_spidertrons(ctx.pindex)
   local builder = FormBuilder.FormBuilder.new()

   if #spidertrons == 0 then
      builder:add_label("no-spidertrons", { "fa.spidertron-remote-no-spidertrons" })
   else
      local vp = Viewpoint.get_viewpoint(ctx.pindex)
      local player_pos = vp:get_cursor_pos()

      for _, spider in ipairs(spidertrons) do
         local unit_number = spider.unit_number
         local key = "spidertron-" .. unit_number

         local label = function(label_ctx)
            local mb = Speech.MessageBuilder.new()
            mb:fragment(FaInfo.ent_info(ctx.pindex, spider, true))
            mb:fragment(FaUtils.dir_dist_locale(player_pos, spider.position))
            return mb:build()
         end

         builder:add_checkbox(key, label, function()
            return SpidertronRemote.is_spidertron_in_remote(player, unit_number)
         end, function(new_value)
            if new_value then
               SpidertronRemote.add_to_remote(player, spider)
            else
               SpidertronRemote.remove_spider(player, unit_number)
            end
         end)
      end
   end

   return builder:build()
end

local spidertron_selector_tab = KeyGraph.declare_graph({
   name = "spidertron_selector",
   render_callback = build_spidertron_form,
   title = { "fa.spidertron-remote-selector-title" },
})

mod.spidertron_selector_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SPIDERTRON_REMOTE_SELECTOR,
   resets_to_first_tab_on_open = true,
   get_binds = function(pindex, parameters)
      return { { kind = UiRouter.BIND_KIND.HAND_CONTENTS } }
   end,
   tabs_callback = function()
      return {
         {
            name = "selector",
            tabs = { spidertron_selector_tab },
         },
      }
   end,
})

UiRouter.register_ui(mod.spidertron_selector_menu)

---Open the spidertron remote selector menu
---@param pindex number
function mod.open_spidertron_selector(pindex)
   local router = UiRouter.get_router(pindex)
   router:open_ui(UiRouter.UI_NAMES.SPIDERTRON_REMOTE_SELECTOR)
end

return mod
