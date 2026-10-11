--[[
Asteroid collector configuration tab.

Provides controls for:
- Individual chunk filter slots, each cycling through the asteroid chunk types and empty

While the circuit network sets the filters, the slots are replaced by a label saying so.
]]

local FormBuilder = require("scripts.ui.form-builder")
local Localising = require("scripts.localising")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---Chunk choices for a filter slot: empty, then every chunk a player can pick, in prototype order
---@return {label: LocalisedString, value: string?}[]
local function chunk_choices()
   local chunks = {}
   for _, proto in pairs(prototypes.asteroid_chunk) do
      if not proto.hidden and not proto.parameter then table.insert(chunks, proto) end
   end
   table.sort(chunks, function(a, b)
      if a.order ~= b.order then return a.order < b.order end
      return a.name < b.name
   end)

   local choices = { { label = { "fa.empty" }, value = nil } }
   for _, proto in ipairs(chunks) do
      table.insert(choices, { label = Localising.get_localised_name_with_fallback(proto), value = proto.name })
   end
   return choices
end

---@param entity LuaEntity
---@param slot_index integer
---@return string?
local function get_chunk_filter(entity, slot_index)
   local filter = entity.get_filter(slot_index) --[[@as AsteroidChunkID?]]
   if not filter then return nil end
   if type(filter) == "string" then return filter end
   return filter.name
end

---Render the asteroid collector configuration form
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_asteroid_collector_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local form = FormBuilder.FormBuilder.new()

   local cb = entity.get_control_behavior() --[[@as LuaAsteroidCollectorControlBehavior?]]
   if cb and cb.set_filter then
      form:add_label("filters_from_circuit", { "fa.asteroid-collector-filters-from-circuit" })
      return form:build()
   end

   local choices = chunk_choices()
   form:start_row("filters")
   for i = 1, entity.filter_slot_count do
      local slot_index = i
      form:add_choice_field("filter_" .. slot_index, { "fa.inserter-filter-slot", tostring(slot_index) }, function()
         return get_chunk_filter(entity, slot_index)
      end, function(value)
         entity.set_filter(slot_index, value)
      end, choices)
   end
   form:end_row()

   return form:build()
end

mod.asteroid_collector_config_tab = UiKeyGraph.declare_graph({
   name = "asteroid-collector-config",
   title = { "fa.asteroid-collector-config-title" },
   render_callback = render_asteroid_collector_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "asteroid-collector"
end

return mod
