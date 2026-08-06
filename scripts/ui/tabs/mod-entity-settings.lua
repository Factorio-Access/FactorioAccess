--[[
Renders the settings another mod declares for one of its entities.

The schema is fetched on every render rather than cached, so a provider can
change the fields as the game changes, for example dropping belt tiers the
force has not researched.
]]

local FormBuilder = require("scripts.ui.form-builder")
local ModEntitySettings = require("scripts.mod-entity-settings")
local TH = require("scripts.table-helpers")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---@param builder fa.ui.form.FormBuilder
---@param entity LuaEntity
---@param pindex number
---@param field fa.ModEntitySettings.Field
local function add_field(builder, entity, pindex, field)
   local function get()
      return ModEntitySettings.get_value(entity, pindex, field.name)
   end

   local function set(value)
      ModEntitySettings.set_value(entity, pindex, field.name, value)
   end

   if field.kind == ModEntitySettings.FIELD_KIND.BOOLEAN then
      builder:add_checkbox(field.name, field.label, get, set)
   else
      -- The only other kind is a choice; validate_field has already rejected
      -- anything else.
      --
      -- Choice fields error out if the current value is not in the list and no
      -- choice is marked default.  A provider whose list varies with game state
      -- can hit that, so the first choice stands in when it says nothing.  The
      -- default is marked on copies: the schema belongs to the other mod, which
      -- may well hand us the same table again.
      local choices = field.choices
      local has_default = false
      for _, choice in ipairs(choices) do
         has_default = has_default or choice.default == true
      end

      if not has_default then
         choices = TH.shallow_copy(choices)
         choices[1] = TH.shallow_copy(choices[1])
         choices[1].default = true
      end

      builder:add_choice_field(field.name, field.label, get, set, choices)
   end
end

---@param ctx fa.ui.TabContext
---@return fa.ui.graph.Render?
local function render_mod_entity_settings(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local schema = ModEntitySettings.get_schema(entity, ctx.pindex)
   if not schema then return nil end

   local builder = FormBuilder.FormBuilder.new()

   for _, field in ipairs(schema.fields) do
      add_field(builder, entity, ctx.pindex, field)
   end

   return builder:build()
end

mod.mod_entity_settings_tab = UiKeyGraph.declare_graph({
   name = "mod-entity-settings",
   title = { "fa.mod-entity-settings-title" },
   render_callback = render_mod_entity_settings,
})

---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return ModEntitySettings.has_settings(entity)
end

return mod
