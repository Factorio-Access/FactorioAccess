--[[
Trains overview tabs for the main menu.

Two tabs: surface trains and all trains.
Each train row has: name/position/state, move cursor, manual mode toggle.
]]

local Menu = require("scripts.ui.menu")
local KeyGraph = require("scripts.ui.key-graph")
local TrainHelpers = require("scripts.rails.train-helpers")
local EntityUi = require("scripts.ui.entity-ui")
local Viewpoint = require("scripts.viewpoint")
local Graphics = require("scripts.graphics")
local UiSounds = require("scripts.ui.sounds")
local Help = require("scripts.ui.help")

local mod = {}

---Get a rolling stock from a train for use with TrainHelpers
---@param train LuaTrain
---@return LuaEntity?
local function get_stock(train)
   return train.front_stock or train.back_stock
end

---Sort trains by name, then by id for ties
---@param trains LuaTrain[]
local function sort_trains(trains)
   table.sort(trains, function(a, b)
      local stock_a, stock_b = get_stock(a), get_stock(b)
      local name_a = stock_a and TrainHelpers.get_name(stock_a) or ""
      local name_b = stock_b and TrainHelpers.get_name(stock_b) or ""
      if name_a ~= name_b then return name_a < name_b end
      return a.id < b.id
   end)
end

---Build train rows for a list of trains
---@param builder fa.ui.menu.MenuBuilder
---@param trains LuaTrain[]
local function build_train_rows(builder, trains)
   for _, train in ipairs(trains) do
      local train_id = train.id
      local stock = get_stock(train)

      builder:start_row("train")

      -- Main train info (click to open train menu)
      builder:add_clickable("train-" .. train_id, function(ctx)
         if stock then
            ctx.message:fragment(TrainHelpers.get_name(stock))
            local pos = stock.position
            ctx.message:fragment({ "fa.trains-overview-at-position", math.floor(pos.x), math.floor(pos.y) })
            TrainHelpers.push_state_message(ctx.message, stock)
         else
            ctx.message:fragment("id " .. train_id)
         end
         ctx.message:fragment({ "fa.trains-overview-click-to-open" })
      end, {
         on_click = function(ctx)
            if not stock then
               ctx.message:fragment({ "fa.trains-overview-no-rolling-stock" })
               return
            end

            local loco = TrainHelpers.get_identifying_locomotive(stock)
            local target = loco or stock

            ctx.controller:close()
            EntityUi.open_entity_ui(ctx.pindex, target)
         end,
      })

      -- Move cursor action
      builder:add_clickable("cursor-" .. train_id, function(ctx)
         ctx.message:fragment({ "fa.trains-overview-move-cursor" })
      end, {
         on_click = function(ctx)
            if not stock then
               ctx.message:fragment({ "fa.trains-overview-no-rolling-stock" })
               return
            end

            local vp = Viewpoint.get_viewpoint(ctx.pindex)
            vp:set_cursor_pos(stock.position)
            Graphics.draw_cursor_highlight(ctx.pindex, nil, "train-visualization")
            ctx.message:fragment({ "fa.trains-overview-cursor-moved", TrainHelpers.get_name(stock) })
         end,
      })

      -- Manual mode checkbox
      builder:add_clickable("manual-" .. train_id, function(ctx)
         local state_text = train.manual_mode and { "fa.checked" } or { "fa.unchecked" }
         ctx.message:fragment(state_text)
         ctx.message:fragment({ "fa.trains-overview-manual-mode" })
      end, {
         on_click = function(ctx)
            train.manual_mode = not train.manual_mode
            UiSounds.play_menu_move(ctx.pindex)
            local state_text = train.manual_mode and { "fa.checked" } or { "fa.unchecked" }
            ctx.message:fragment(state_text)
         end,
      })

      builder:end_row()
   end
end

---Render trains tab
---@param surface_getter (fun(player: LuaPlayer): LuaSurface?)? Returns surface or nil for all
---@return fun(ctx: fa.ui.graph.Ctx): fa.ui.graph.Render
local function make_render_callback(surface_getter)
   return function(ctx)
      local builder = Menu.MenuBuilder.new()
      local player = game.get_player(ctx.pindex)
      if not player then return builder:add_label("error", { "fa.trains-overview-error" }):build() end

      local surface = surface_getter and surface_getter(player) or nil
      local trains = TrainHelpers.get_trains(player.force, surface)
      sort_trains(trains)

      if #trains == 0 then
         builder:add_label("empty", { "fa.trains-overview-no-trains" })
         return builder:build()
      end

      build_train_rows(builder, trains)
      return builder:build()
   end
end

-- Tab for trains on current surface
mod.surface_trains_tab = KeyGraph.declare_graph({
   name = "surface_trains",
   title = { "fa.trains-overview-surface-title" },
   render_callback = make_render_callback(function(player)
      return player.physical_surface
   end),
   get_help_metadata = function(ctx)
      return {
         Help.message_list("trains-overview-help"),
      }
   end,
})

-- Tab for all trains
mod.all_trains_tab = KeyGraph.declare_graph({
   name = "all_trains",
   title = { "fa.trains-overview-all-title" },
   render_callback = make_render_callback(nil),
   get_help_metadata = function(ctx)
      return {
         Help.message_list("trains-overview-help"),
      }
   end,
})

return mod
