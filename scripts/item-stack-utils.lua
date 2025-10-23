--[[
Utilities for aggregating and working with item stacks.
Centralizes the common pattern of grouping items by name and quality.
]]

local mod = {}

---Add a stack to the groups map
---@param groups table The groups map (name -> quality -> {count, stacks})
---@param stack LuaItemStack The stack to add
local function push_stack_to_groups(groups, stack)
   local name = stack.name
   local quality = stack.quality.name

   if not groups[name] then groups[name] = {} end
   if not groups[name][quality] then groups[name][quality] = {
      count = 0,
      stacks = {},
   } end

   groups[name][quality].count = groups[name][quality].count + stack.count
   table.insert(groups[name][quality].stacks, stack)
end

---Add all filtered stacks from an inventory to the groups map
---@param groups table The groups map (name -> quality -> {count, stacks})
---@param inventory LuaInventory The inventory to iterate
---@param filter fun(stack: LuaItemStack): boolean The filter function
local function push_inventory_to_groups(groups, inventory, filter)
   for i = 1, #inventory do
      local stack = inventory[i]
      if stack.valid_for_read and filter(stack) then push_stack_to_groups(groups, stack) end
   end
end

---Flatten groups map to array
---@param groups table The groups map (name -> quality -> {count, stacks})
---@return table[] Array of {name, quality, count, stacks}
local function flatten_groups(groups)
   local result = {}
   for name, qualities in pairs(groups) do
      for quality, data in pairs(qualities) do
         table.insert(result, {
            name = name,
            quality = quality,
            count = data.count,
            stacks = data.stacks,
         })
      end
   end
   return result
end

---Aggregate items from an inventory by name and quality
---@param inventory LuaInventory
---@param filter fun(stack: LuaItemStack): boolean? Optional filter function, defaults to including all valid stacks
---@return table[] Array of {name, quality, count, stacks}
function mod.aggregate_inventory(inventory, filter)
   if not inventory then return {} end
   if not filter then filter = function(stack)
      return true
   end end

   local groups = {}
   push_inventory_to_groups(groups, inventory, filter)
   return flatten_groups(groups)
end

---Aggregate items from multiple inventories by name and quality
---@param inventories LuaInventory[] Array of inventories to aggregate
---@param filter fun(stack: LuaItemStack): boolean? Optional filter function
---@return table[] Array of {name, quality, count, stacks}
function mod.aggregate_inventories(inventories, filter)
   if not inventories then return {} end
   if not filter then filter = function(stack)
      return true
   end end

   local groups = {}

   for _, inventory in ipairs(inventories) do
      if inventory then push_inventory_to_groups(groups, inventory, filter) end
   end

   return flatten_groups(groups)
end

return mod
