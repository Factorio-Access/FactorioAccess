--[[
Upgrade Planner Utility Module
Provides functions for reading and describing upgrade planner contents.
]]

local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---Get the localized name for a mapper (source or destination)
---@param mapper UpgradeMapperSource|UpgradeMapperDestination|nil
---@return LocalisedString|nil
local function get_mapper_name(mapper)
   if not mapper or not mapper.name then return nil end

   local proto
   if mapper.type == "entity" then
      proto = prototypes.entity[mapper.name]
   else
      proto = prototypes.item[mapper.name]
   end

   if not proto then return mapper.name end

   return Localising.get_localised_name_with_fallback(proto)
end

---Check if a mapper rule at the given index is defined
---@param planner LuaItemStack
---@param index integer 1-indexed
---@return boolean
function mod.is_rule_defined(planner, index)
   -- Check bounds first - get_mapper throws for indices beyond mapper_count
   local mapper_count = planner.mapper_count or 0
   if index > mapper_count then return false end
   local from = planner.get_mapper(index, "from")
   return from and from.name ~= nil
end

---Read a single planner rule into MessageBuilder
---Format: "Transport belt to Fast transport belt"
---@param mb fa.MessageBuilder
---@param planner LuaItemStack
---@param index integer 1-indexed
---@return boolean has_rule Whether a rule exists at this index
function mod.read_planner_rule(mb, planner, index)
   -- Check bounds first - get_mapper throws for indices beyond mapper_count
   local mapper_count = planner.mapper_count or 0
   if index > mapper_count then return false end

   local from = planner.get_mapper(index, "from")
   local to = planner.get_mapper(index, "to")

   local from_name = get_mapper_name(from)
   if not from_name then return false end

   local to_name = get_mapper_name(to)
   if not to_name then
      -- Incomplete rule (only source defined)
      mb:fragment(from_name)
      mb:fragment({ "fa.upgrade-to-nothing" })
      return true
   end

   mb:fragment({ "fa.upgrade-rule-format", from_name, to_name })
   return true
end

---Describe a planner: name, rule count, first few rules
---@param mb fa.MessageBuilder
---@param planner LuaItemStack
---@param max_rules integer? Maximum rules to list (default 3)
function mod.describe_planner(mb, planner, max_rules)
   max_rules = max_rules or 3

   -- Always say "upgrade planner" first
   mb:fragment({ "item-name.upgrade-planner" })

   -- Add custom label if present
   local label = planner.label
   if label and label ~= "" then mb:list_item(label) end

   -- List all defined rules
   local mapper_count = planner.mapper_count or 0
   local has_rules = false
   for i = 1, mapper_count do
      if mod.is_rule_defined(planner, i) then
         local rule_mb = MessageBuilder.new()
         mod.read_planner_rule(rule_mb, planner, i)
         mb:list_item(rule_mb:build())
         has_rules = true
      end
   end

   if not has_rules then mb:list_item({ "fa.upgrade-no-rules" }) end
end

---Get the fast_replaceable_group for an entity prototype
---@param entity_name string
---@return string|nil
function mod.get_fast_replaceable_group(entity_name)
   local proto = prototypes.entity[entity_name]
   if proto then return proto.fast_replaceable_group end
   return nil
end

---Check if an entity can be upgraded (has a fast_replaceable_group)
---@param entity_name string
---@return boolean
function mod.is_entity_upgradeable(entity_name)
   return mod.get_fast_replaceable_group(entity_name) ~= nil
end

return mod
