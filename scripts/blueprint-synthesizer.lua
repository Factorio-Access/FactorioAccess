--- Synthesizes blueprint strings for single entities
--- Used for building via build_from_cursor to get proper obstacle detection

local mod = {}

---Synthesize a blueprint string containing a single entity
---@param name string Entity prototype name
---@param direction defines.direction? Direction of the entity (defaults to north)
---@param control_behavior table? Control behavior settings for the entity
---@return string blueprint_string The blueprint string ready for import_stack
function mod.synthesize_simple_blueprint(name, direction, control_behavior)
   local entity = {
      entity_number = 1,
      name = name,
      position = { x = 0, y = 0 },
      direction = direction or defines.direction.north,
   }

   if control_behavior then entity.control_behavior = control_behavior end

   local bp_data = {
      blueprint = {
         entities = { entity },
         item = "blueprint",
         version = 562949954666496, -- Factorio 2.0 version number
      },
   }

   local json = helpers.table_to_json(bp_data)
   local encoded = helpers.encode_string(json)

   return "0" .. encoded
end

return mod
