--[[
Fast travel categories gain an order the player arranges.

Before: { points, categories = { [id] = name }, order }. After: the same with category_order, the category IDs sorted by
name, the order the menu showed them in until now.

Frozen with the migration that uses it: it converts exactly the format above, whatever the travel module becomes.
]]

---@param old { points: table, categories: table<integer, string>, order: table, category_order: nil }
---@return table
return function(old)
   assert(old.category_order == nil, "fast travel storage already has a category order")
   local ids = {}
   for id in pairs(old.categories) do
      table.insert(ids, id)
   end
   table.sort(ids, function(a, b)
      return old.categories[a] < old.categories[b]
   end)
   old.category_order = ids
   return old
end
