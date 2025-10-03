--[[
Generic abstraction for entities that provide logistic sections.

Provides a uniform interface for working with logistic sections regardless of
whether they come from:
- LuaLogisticPoint (requester/buffer chests, characters, vehicles, etc.)
- LuaConstantCombinatorControlBehavior (constant combinators)

This allows the section editor UI to work with both types.
]]

local mod = {}

---@class fa.LogisticSectionProvider
---@field entity LuaEntity The entity this provider wraps
---@field get_sections fun(): table<number, LuaLogisticSection> Get all sections
---@field get_section fun(index: number): LuaLogisticSection? Get section by index
---@field add_section fun(group: string?, index: number?): LuaLogisticSection? Add a new section
---@field remove_section fun(index: number): boolean Remove a section
---@field get_sections_count fun(): number Get the number of sections
---@field get_enabled fun(): boolean Get whether the provider is enabled
---@field set_enabled fun(enabled: boolean) Set whether the provider is enabled
---@field get_filters fun(): table Get compiled filters/outputs

---Create a provider for a logistic point
---@param entity LuaEntity
---@param point_index number
---@return fa.LogisticSectionProvider
function mod.create_point_provider(entity, point_index)
   assert(entity and entity.valid, "create_point_provider: entity is nil or invalid")

   local function get_point()
      if not entity or not entity.valid then return nil end
      local points_result = entity.get_logistic_point()
      if not points_result then return nil end

      local points = {}
      if type(points_result) == "table" and points_result.object_name ~= "LuaLogisticPoint" then
         points = points_result
      else
         points = { points_result }
      end

      return points[point_index]
   end

   return {
      entity = entity,

      get_sections = function()
         local point = get_point()
         if not point then return {} end
         return point.sections or {}
      end,

      get_section = function(index)
         local point = get_point()
         if not point then return nil end
         return point.sections[index]
      end,

      add_section = function(group, index)
         local point = get_point()
         if not point then return nil end
         return point.add_section(group or "", index)
      end,

      remove_section = function(index)
         local point = get_point()
         if not point then return false end
         return point.remove_section(index)
      end,

      get_sections_count = function()
         local point = get_point()
         if not point then return 0 end
         return point.sections_count or 0
      end,

      get_enabled = function()
         local point = get_point()
         if not point then return false end
         return point.enabled
      end,

      set_enabled = function(enabled)
         local point = get_point()
         if not point then return end
         point.enabled = enabled
      end,

      get_filters = function()
         local point = get_point()
         if not point then return {} end
         return point.filters or {}
      end,
   }
end

---Create a provider for a constant combinator
---@param entity LuaEntity
---@return fa.LogisticSectionProvider
function mod.create_constant_combinator_provider(entity)
   assert(entity and entity.valid, "create_constant_combinator_provider: entity is nil or invalid")

   local function get_control_behavior()
      if not entity or not entity.valid then return nil end
      return entity.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
   end

   return {
      entity = entity,

      get_sections = function()
         local cb = get_control_behavior()
         if not cb then return {} end
         -- Convert array to dictionary-like table for consistency with points
         local sections_dict = {}
         for i, section in ipairs(cb.sections or {}) do
            sections_dict[i] = section
         end
         return sections_dict
      end,

      get_section = function(index)
         local cb = get_control_behavior()
         if not cb then return nil end
         return cb.get_section(index)
      end,

      add_section = function(group, index)
         local cb = get_control_behavior()
         if not cb then return nil end
         -- Constant combinators don't support index parameter
         return cb.add_section(group or "")
      end,

      remove_section = function(index)
         local cb = get_control_behavior()
         if not cb then return false end
         return cb.remove_section(index)
      end,

      get_sections_count = function()
         local cb = get_control_behavior()
         if not cb then return 0 end
         return cb.sections_count or 0
      end,

      get_enabled = function()
         local cb = get_control_behavior()
         if not cb then return false end
         return cb.enabled
      end,

      set_enabled = function(enabled)
         local cb = get_control_behavior()
         if not cb then return end
         cb.enabled = enabled
      end,

      get_filters = function()
         -- For constant combinators, get compiled filters from all sections
         local cb = get_control_behavior()
         if not cb then return {} end

         local all_filters = {}
         for _, section in ipairs(cb.sections or {}) do
            for _, filter in pairs(section.filters or {}) do
               table.insert(all_filters, filter)
            end
         end
         return all_filters
      end,
   }
end

---Auto-detect and create the appropriate provider
---@param entity LuaEntity
---@param point_index number? Required if entity has logistic points
---@return fa.LogisticSectionProvider?
function mod.create_provider(entity, point_index)
   if not entity or not entity.valid then return nil end

   -- Check if it's a constant combinator
   if entity.type == "constant-combinator" then return mod.create_constant_combinator_provider(entity) end

   -- Otherwise try to create a logistic point provider
   if point_index then return mod.create_point_provider(entity, point_index) end

   return nil
end

return mod
