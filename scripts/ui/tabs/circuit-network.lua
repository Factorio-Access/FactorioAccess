--[[
Circuit network configuration tab for entities with control behaviors.

Uses control-behavior-descriptors to dynamically build a form based on the entity's control behavior type.
]]

local ControlBehaviorDescriptors = require("scripts.control-behavior-descriptors")
local FormBuilder = require("scripts.ui.form-builder")
local KeyGraph = require("scripts.ui.key-graph")
local Speech = require("scripts.speech")
local CircuitNetwork = require("scripts.circuit-network")

local mod = {}

---Check if circuit network tab should be available for an entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   if not entity or not entity.valid then return false end

   local control_behavior = entity.get_control_behavior()
   if not control_behavior then return false end

   -- Get the descriptor for this control behavior type
   local descriptor = ControlBehaviorDescriptors.describe_control_behavior(control_behavior.type)
   if not descriptor then return false end

   -- Available if descriptor exists and has fields
   return descriptor.fields and #descriptor.fields > 0
end

---Add control behavior fields to a FormBuilder based on entity's control behavior type
---@param builder fa.ui.form.FormBuilder The FormBuilder to add fields to
---@param entity LuaEntity The entity whose control behavior to use
---@return boolean success Whether fields were added successfully
function mod.add_control_behavior_fields(builder, entity)
   if not entity or not entity.valid then return false end

   local control_behavior = entity.get_control_behavior()
   if not control_behavior then return false end

   -- Get the descriptor for this control behavior type
   local descriptor = ControlBehaviorDescriptors.describe_control_behavior(control_behavior.type)
   if not descriptor or not descriptor.fields or #descriptor.fields == 0 then return false end

   -- Build form fields from descriptor
   for _, field in ipairs(descriptor.fields) do
      -- Check if field is available for this entity
      if field.available and not field.available(entity) then goto continue end

      local field_name = field.name
      local field_label = field.label

      if field.type == ControlBehaviorDescriptors.FIELD_TYPE.BOOLEAN then
         -- Boolean field (checkbox)
         builder:add_checkbox(field_name, field_label, function()
            local cb = entity.get_control_behavior()
            if not cb then return false end
            return cb[field_name] or false
         end, function(value)
            local cb = entity.get_control_behavior()
            if not cb then return end
            cb[field_name] = value
         end)
      elseif field.type == ControlBehaviorDescriptors.FIELD_TYPE.SIGNAL then
         -- Signal field
         builder:add_signal(field_name, field_label, function()
            local cb = entity.get_control_behavior()
            if not cb then return nil end
            return cb[field_name]
         end, function(value)
            local cb = entity.get_control_behavior()
            if not cb then return end
            cb[field_name] = value
         end)
      elseif field.type == ControlBehaviorDescriptors.FIELD_TYPE.CONDITION then
         -- Condition field (complex row)
         builder:add_condition(field_name, function()
            local cb = entity.get_control_behavior()
            if not cb then return nil end
            return cb[field_name]
         end, function(value)
            local cb = entity.get_control_behavior()
            if not cb then return end
            cb[field_name] = value
         end)
      elseif field.type == ControlBehaviorDescriptors.FIELD_TYPE.CONDITION_WITH_ENABLE then
         -- Condition field with enable/disable toggle (complex row)
         local enable_field = field.enable_field
         local condition_field = field.condition_field
         builder:add_condition_with_enable(field_name, field_label, function()
            local cb = entity.get_control_behavior()
            if not cb then return false end
            return cb[enable_field] or false
         end, function(value)
            local cb = entity.get_control_behavior()
            if not cb then return end
            cb[enable_field] = value
         end, function()
            local cb = entity.get_control_behavior()
            if not cb then return nil end
            return cb[condition_field]
         end, function(value)
            local cb = entity.get_control_behavior()
            if not cb then return end
            cb[condition_field] = value
         end)
      elseif field.type == ControlBehaviorDescriptors.FIELD_TYPE.CHOICE then
         -- Choice field
         builder:add_choice_field(field_name, field_label, function()
            local cb = entity.get_control_behavior()
            if not cb then return field.choices[1].value end
            return cb[field_name] or field.choices[1].value
         end, function(value)
            local cb = entity.get_control_behavior()
            if not cb then return end
            cb[field_name] = value
         end, field.choices)
      end

      ::continue::
   end

   return true
end

---Render the circuit network configuration form
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_circuit_network(ctx)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   if not entity or not entity.valid then return nil end

   local control_behavior = entity.get_control_behavior()
   if not control_behavior then
      ctx.controller.message:fragment({ "fa.circuit-network-no-control-behavior" })
      return nil
   end

   -- Get the descriptor for this control behavior type
   local descriptor = ControlBehaviorDescriptors.describe_control_behavior(control_behavior.type)
   if not descriptor or not descriptor.fields or #descriptor.fields == 0 then
      ctx.controller.message:fragment({ "fa.circuit-network-no-fields" })
      return nil
   end

   local builder = FormBuilder.FormBuilder.new()

   -- Add network ID info at the top
   local red_network_id = CircuitNetwork.get_network_id_string(entity, defines.wire_connector_id.circuit_red)
   local green_network_id = CircuitNetwork.get_network_id_string(entity, defines.wire_connector_id.circuit_green)

   if red_network_id ~= "nil" or green_network_id ~= "nil" then
      builder:add_label("network_info", function(ctx)
         if red_network_id ~= "nil" then ctx.message:fragment({ "fa.circuit-network-in-red", red_network_id }) end
         if green_network_id ~= "nil" then ctx.message:fragment({ "fa.circuit-network-in-green", green_network_id }) end
      end)
   else
      builder:add_label("network_info", function(ctx)
         ctx.message:fragment({ "fa.circuit-network-not-connected" })
      end)
   end

   -- Add control behavior fields
   mod.add_control_behavior_fields(builder, entity)

   return builder:build()
end

---Get the circuit network tab descriptor
---@return fa.ui.TabDescriptor
function mod.get_tab()
   return KeyGraph.declare_graph({
      name = "circuit-network",
      title = { "fa.circuit-network-title" },
      render_callback = render_circuit_network,
   })
end

return mod
