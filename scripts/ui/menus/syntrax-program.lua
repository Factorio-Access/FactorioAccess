---Syntrax Program Editor UI
---
---Editor for creating and modifying custom Syntrax programs.
---Parameters: { program = {name, source}, existing_id = number? }
---If existing_id is nil, this creates a new program. Otherwise edits existing.

local UiKeyGraph = require("scripts.ui.key-graph")
local FormBuilder = require("scripts.ui.form-builder")
local TabList = require("scripts.ui.tab-list")
local UiRouter = require("scripts.ui.router")
local Functools = require("scripts.functools")
local CustomPrograms = require("scripts.rails.syntrax-custom-programs")

local mod = {}

---@class fa.syntrax.ProgramEditorState
---@field name string
---@field source string
---@field existing_id number?

---@param _pindex number
---@param params table
---@return fa.syntrax.ProgramEditorState
local function state_setup(_pindex, params)
   return {
      name = params.program.name,
      source = params.program.source,
      existing_id = params.existing_id,
   }
end

---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render(ctx)
   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   ---@type fa.syntrax.ProgramEditorState
   local state = ctx.tablist_shared_state
   local existing_id = state.existing_id

   local builder = FormBuilder.FormBuilder.new()

   builder:add_textfield("name", {
      label = { "fa.syntrax-program-name-label" },
      get_value = function()
         return state.name
      end,
      set_value = function(v)
         if v ~= "" then state.name = v end
      end,
   })

   builder:add_textfield("source", {
      label = { "fa.syntrax-program-source-label" },
      get_value = function()
         return state.source
      end,
      set_value = function(v)
         state.source = v
      end,
   })

   builder:add_action("save", { "fa.syntrax-program-save" }, function(controller)
      local err = CustomPrograms.compile_check(state.source)
      if err then
         controller.message:fragment({ "fa.syntrax-program-compile-error", err })
         return
      end

      if existing_id then
         CustomPrograms.update_program(ctx.pindex, existing_id, state.name, state.source)
         controller.message:fragment({ "fa.syntrax-program-saved" })
      else
         CustomPrograms.create_program(ctx.pindex, state.name, state.source)
         controller.message:fragment({ "fa.syntrax-program-created" })
      end

      controller:close()
   end)

   if existing_id then
      builder:add_action("delete", { "fa.syntrax-program-delete" }, function(controller)
         CustomPrograms.delete_program(ctx.pindex, existing_id)
         controller.message:fragment({ "fa.syntrax-program-deleted" })
         controller:close()
      end)
   end

   return builder:build()
end

mod.syntrax_program_menu = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.SYNTRAX_PROGRAM,
   shared_state_setup = state_setup,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               name = "syntrax-program-editor",
               title = { "fa.syntrax-program-editor-title" },
               render_callback = render,
            }),
         },
      },
   }),
   resets_to_first_tab_on_open = true,
})

UiRouter.register_ui(mod.syntrax_program_menu)

return mod
