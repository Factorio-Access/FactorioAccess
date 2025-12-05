---Rail Builder Menu
---
---Menu for building rails using predefined and custom Syntrax programs.
---Categories: Turns, Forks, Signal pairs, Custom programs, Add new program.
---
---Predefined program names are localized in locale/en/syntrax-program-names.cfg

local UiKeyGraph = require("scripts.ui.key-graph")
local Menu = require("scripts.ui.menu")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Functools = require("scripts.functools")
local CustomPrograms = require("scripts.rails.syntrax-custom-programs")
local VTD = require("scripts.rails.virtual-train-driving")
local UID = require("scripts.uid")

local mod = {}

-- Predefined turn programs
local TURNS = {
   { name = { "fa.syntrax-left-45" }, source = "l45" },
   { name = { "fa.syntrax-right-45" }, source = "r45" },
   { name = { "fa.syntrax-left-90" }, source = "l90" },
   { name = { "fa.syntrax-right-90" }, source = "r90" },
}

-- Predefined fork programs
local FORKS = {
   { name = { "fa.syntrax-fork-straight-left-45" }, source = "s x 5 reset l45" },
   { name = { "fa.syntrax-fork-straight-right-45" }, source = "s x 5 reset r45" },
   { name = { "fa.syntrax-fork-straight-left-90" }, source = "s x 7 reset l90" },
   { name = { "fa.syntrax-fork-straight-right-90" }, source = "s x 7 reset r90" },
   { name = { "fa.syntrax-split-45" }, source = "l45 reset r45" },
   { name = { "fa.syntrax-split-90" }, source = "l90 reset r90" },
}

-- Predefined signal programs
local SIGNALS = {
   { name = { "fa.syntrax-signal-pair" }, source = "sig" },
   { name = { "fa.syntrax-chain-pair" }, source = "chain" },
   { name = { "fa.syntrax-signal-right" }, source = "sigright" },
   { name = { "fa.syntrax-chain-right" }, source = "chainright" },
   { name = { "fa.syntrax-signal-left" }, source = "sigleft" },
   { name = { "fa.syntrax-chain-left" }, source = "chainleft" },
   { name = { "fa.syntrax-intersection-entrance" }, source = "sigleft chainright" },
   { name = { "fa.syntrax-intersection-exit" }, source = "chainleft sigright" },
}

---Execute a syntrax program and report result
---@param ctx fa.ui.graph.Ctx
---@param source string
---@param program_name LocalisedString|string
local function execute_program(ctx, source, program_name)
   local entities, err = VTD.execute_syntrax(ctx.pindex, source)

   if err then
      ctx.message:fragment({ "fa.syntrax-error", err })
   elseif entities and #entities > 0 then
      ctx.message:fragment({ "fa.syntrax-placed", #entities })
   else
      ctx.message:fragment({ "fa.syntrax-placed", 0 })
   end
end

---Add a predefined program row to the builder (label + programs in same row)
---@param builder fa.ui.menu.MenuBuilder
---@param row_key string
---@param label LocalisedString
---@param programs table[]
local function add_predefined_row(builder, row_key, label, programs)
   builder:start_row(row_key)
   builder:add_label(row_key .. "-label", label)
   for i, prog in ipairs(programs) do
      builder:add_clickable(row_key .. "-" .. i, prog.name, {
         on_click = function(ctx)
            execute_program(ctx, prog.source, prog.name)
         end,
      })
   end
   builder:end_row()
end

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render(ctx)
   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   local builder = Menu.MenuBuilder.new()

   -- Turns category
   add_predefined_row(builder, "turns", { "fa.syntrax-category-turns" }, TURNS)

   -- Forks category
   add_predefined_row(builder, "forks", { "fa.syntrax-category-forks" }, FORKS)

   -- Signal pairs category
   add_predefined_row(builder, "signals", { "fa.syntrax-category-signals" }, SIGNALS)

   -- Custom programs category
   local custom_programs = CustomPrograms.get_all_programs(ctx.pindex)

   builder:start_row("custom")
   builder:add_label("custom-label", { "fa.syntrax-category-custom" })

   if #custom_programs > 0 then
      for _, prog in ipairs(custom_programs) do
         local prog_id = prog.id -- Capture for closures
         builder:add_clickable("custom-" .. prog_id, prog.name, {
            on_click = function(c)
               execute_program(c, prog.source, prog.name)
            end,
            on_right_click = function(c)
               -- Open editor with a copy of the program
               c.controller:open_child_ui(UiRouter.UI_NAMES.SYNTRAX_PROGRAM, {
                  program = { name = prog.name, source = prog.source },
                  existing_id = prog_id,
               }, { node = "custom-" .. prog_id })
            end,
            on_clear = function(c)
               c.message:fragment({ "fa.syntrax-use-control-backspace" })
            end,
            on_dangerous_delete = function(c)
               CustomPrograms.delete_program(c.pindex, prog_id)
               c.message:fragment({ "fa.syntrax-program-deleted" })
            end,
         })
      end
   end
   builder:end_row()

   -- Add new program
   builder:add_clickable("add-new", { "fa.syntrax-add-new-program" }, {
      on_click = function(c)
         -- Open editor with a new program
         local new_name = "unnamed " .. tostring(UID.uid())
         c.controller:open_child_ui(UiRouter.UI_NAMES.SYNTRAX_PROGRAM, {
            program = { name = new_name, source = "" },
            existing_id = nil,
         }, { node = "add-new" })
      end,
   })

   return builder:build()
end

mod.rail_builder_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.RAIL_BUILDER,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               name = "rail-builder",
               title = { "fa.syntrax-rail-builder-title" },
               render_callback = render,
            }),
         },
      },
   }),
   resets_to_first_tab_on_open = true,
})

UiRouter.register_ui(mod.rail_builder_menu)

return mod
