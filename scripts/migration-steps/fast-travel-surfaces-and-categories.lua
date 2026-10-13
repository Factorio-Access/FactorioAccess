--[[
Fast travel points gain a surface and a category, and their order is kept apart from them.

Before: { points = { point, ... } }, an array sorted by label, each point { id, label, position, description }.
After: { points = { [id] = point }, categories = {}, order = { [surface_index] = { id, ... } } }, each point also with
surface_index. Points from before surfaces were recorded are all on Nauvis, the only place they could be made; without
Nauvis (a mod removed it) they are dropped.

Frozen with the migration that uses it: it converts exactly the format above, whatever the travel module becomes.
]]

---@param old { points: { id: integer, label: string, position: fa.Point, description: string? }[], order: nil, categories: nil }
---@param nauvis_index integer?
---@return table
return function(old, nauvis_index)
   assert(old.order == nil and old.categories == nil, "fast travel storage is already in the new format")
   local new = { points = {}, categories = {}, order = {} }
   if not nauvis_index or #old.points == 0 then return new end
   local ids = {}
   for _, point in ipairs(old.points) do
      new.points[point.id] = {
         id = point.id,
         label = point.label,
         description = point.description or "",
         surface_index = nauvis_index,
         position = point.position,
      }
      table.insert(ids, point.id)
   end
   new.order[nauvis_index] = ids
   return new
end
