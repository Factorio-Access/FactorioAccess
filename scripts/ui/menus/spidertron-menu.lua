--[[
Spidertron remote menu UI using the new TabList/Menu system.
Provides a vertical menu interface for managing spidertron remotes.
]]

local Functools = require("scripts.functools")
local Menu = require("scripts.ui.menu")
local Speech = require("scripts.speech")
local TabList = require("scripts.ui.tab-list")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@class fa.ui.SpidertronMenu.SharedState
---@field remote LuaItemStack? The spidertron remote being used

---@class fa.ui.SpidertronMenu.Parameters
-- Empty for now but available for extensions

---@class fa.ui.SpidertronMenu.Context: fa.ui.graph.Ctx
---@field parameters fa.ui.SpidertronMenu.Parameters
---@field tablist_shared_state fa.ui.SpidertronMenu.SharedState

-- Shared state setup function
---@param pindex number
---@param params fa.ui.SpidertronMenu.Parameters
---@return fa.ui.SpidertronMenu.SharedState
local function state_setup(pindex, params)
   local player = game.get_player(pindex)
   local remote = player.cursor_stack

   if remote and remote.valid_for_read and remote.name == "spidertron-remote" then
      return {
         remote = remote,
      }
   end

   return {
      remote = nil,
   }
end

-- Main render function
---@param ctx fa.ui.SpidertronMenu.Context
---@return fa.ui.graph.Render?
local function render_spidertron_menu(ctx)
   local remote = ctx.tablist_shared_state.remote
   if not remote or not remote.valid_for_read then
      Speech.speak(ctx.pindex, "Spidertron remote not available")
      ctx.controller:close()
      return nil
   end

   local p = game.get_player(ctx.pindex)
   local vp = Viewpoint.get_viewpoint(ctx.pindex)
   local cursor = vp:get_cursor_pos()
   local cursortarget = p.selected

   local builder = Menu.MenuBuilder.new()

   -- Menu item 0: Basic info and instructions
   builder:add_label("info", function(label_ctx)
      label_ctx:render({ "fa.spidertron-menu-info" })
   end, function(action_ctx)
      local spidertrons = p.spidertron_remote_selection
      local message = Speech.new()
      if spidertrons ~= nil and #spidertrons > 0 then
         if #spidertrons == 1 then
            if spidertrons[1].entity_label ~= nil then
               message:fragment({ "fa.spidertron-connected-named", spidertrons[1].entity_label })
            else
               message:fragment({ "fa.spidertron-connected-unnamed" })
            end
         else
            message:fragment({ "fa.spidertrons-connected", #spidertrons })
         end
      else
         message:fragment({ "fa.spidertron-not-connected" })
      end
      message:fragment({ "fa.spidertron-menu-instructions" })
      Speech.speak(ctx.pindex, message:build())
   end)

   -- Menu item 1: Link/add spidertron
   builder:add_label("link", function(label_ctx)
      label_ctx:render({ "fa.spidertron-menu-link" })
   end, function(action_ctx)
      -- Only add if focus is on a spidertron
      if cursortarget and cursortarget.type == "spider-vehicle" then
         -- Make sure selection array exists
         local spidertrons = p.spidertron_remote_selection or {}
         -- Prevent duplicates
         local already_linked = false
         for _, s in ipairs(spidertrons) do
            if s == cursortarget then
               already_linked = true
               break
            end
         end
         if already_linked then
            Speech.speak(ctx.pindex, { "fa.spidertron-already-linked" })
         else
            table.insert(spidertrons, cursortarget)
            p.spidertron_remote_selection = spidertrons
            local message = Speech.new()
            if cursortarget.entity_label and cursortarget.entity_label ~= "" then
               message:fragment({ "fa.spidertron-remote-linked-added-named", cursortarget.entity_label })
            else
               message:fragment({ "fa.spidertron-remote-linked-added-unnamed" })
            end
            message:fragment({ "fa.spidertrons-connected", #p.spidertron_remote_selection })
            Speech.speak(ctx.pindex, message:build())
         end
      else
         Speech.speak(ctx.pindex, { "fa.spidertron-invalid-link-target" })
      end
   end)

   -- Menu item 2: Clear all linked spidertrons
   builder:add_label("clear", function(label_ctx)
      label_ctx:render({ "fa.spidertron-menu-clear-all" })
   end, function(action_ctx)
      local spidertrons = p.spidertron_remote_selection
      if spidertrons ~= nil and #spidertrons > 0 then
         -- Clear the list
         p.spidertron_remote_selection = {}
         Speech.speak(ctx.pindex, { "fa.spidertron-clear-all-confirm" })
      else
         Speech.speak(ctx.pindex, { "fa.spidertron-clear-all-none" })
      end
   end)

   -- Menu item 3: Send to cursor position
   builder:add_label("send", function(label_ctx)
      label_ctx:render({ "fa.spidertron-menu-send-to-cursor" })
   end, function(action_ctx)
      if p.spidertron_remote_selection == nil or #p.spidertron_remote_selection == 0 then
         Speech.speak(ctx.pindex, { "fa.spidertron-link-first-move" })
      else
         for _, s in ipairs(p.spidertron_remote_selection) do
            s.autopilot_destination = cursor
         end
         Speech.speak(ctx.pindex, {
            "fa.spidertrons-sent-to-coords",
            #p.spidertron_remote_selection,
            tostring(math.floor(cursor.x)),
            tostring(math.floor(cursor.y)),
         })
      end
   end)

   -- Menu item 4: Add cursor position to queue
   builder:add_label("queue", function(label_ctx)
      label_ctx:render({ "fa.spidertron-menu-add-to-queue" })
   end, function(action_ctx)
      if p.spidertron_remote_selection == nil or #p.spidertron_remote_selection == 0 then
         Speech.speak(ctx.pindex, { "fa.spidertron-link-first-move" })
      else
         for _, s in ipairs(p.spidertron_remote_selection) do
            s.add_autopilot_destination(cursor)
         end
         Speech.speak(ctx.pindex, {
            "fa.spidertrons-added-coords",
            tostring(math.floor(cursor.x)),
            tostring(math.floor(cursor.y)),
            #p.spidertron_remote_selection,
         })
      end
   end)

   -- Menu item 5: Follow selected entity
   builder:add_label("follow", function(label_ctx)
      label_ctx:render({ "fa.spidertron-menu-follow" })
   end, function(action_ctx)
      if p.spidertron_remote_selection ~= nil and #p.spidertron_remote_selection > 0 then
         for _, s in ipairs(p.spidertron_remote_selection) do
            s.follow_target = cursortarget
         end
         Speech.speak(ctx.pindex, { "fa.spidertron-started-following", #p.spidertron_remote_selection })
      else
         Speech.speak(ctx.pindex, { "fa.spidertron-link-required" })
      end
   end)

   return builder:build()
end

mod.spidertron_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SPIDERTRON,
   resets_to_first_tab_on_open = true,
   shared_state_setup = state_setup,
   tabs_callback = Functools.functionize({
      UiKeyGraph.declare_graph({
         name = "spidertron",
         title = { "fa.spidertron-menu-title" },
         render_callback = render_spidertron_menu,
      }),
   }),
})

return mod
