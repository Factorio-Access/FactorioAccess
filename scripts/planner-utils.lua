--[[
Planner Utilities
Common functions for finding upgrade/deconstruction planners,
including when they're active inside blueprint books.
]]

local mod = {}

---Get the active item from a blueprint book
---@param book LuaItemStack
---@return LuaItemStack|nil
local function get_book_active_item(book)
   local book_inv = book.get_inventory(defines.inventory.item_main)
   if not book_inv then return nil end
   local idx = book.active_index
   if not idx or idx < 1 or idx > #book_inv then return nil end
   local item = book_inv[idx]
   if item and item.valid_for_read then return item end
   return nil
end

---Get the upgrade planner from cursor (direct or in book)
---@param pindex number
---@return LuaItemStack|nil planner The upgrade planner stack
---@return boolean in_book Whether the planner is inside a book
function mod.get_upgrade_planner(pindex)
   local player = game.get_player(pindex)
   if not player then return nil, false end

   local stack = player.cursor_stack
   if not stack or not stack.valid_for_read then return nil, false end

   -- Direct upgrade planner
   if stack.is_upgrade_item then return stack, false end

   -- Check inside blueprint book
   if stack.is_blueprint_book then
      local active = get_book_active_item(stack)
      if active and active.is_upgrade_item then return active, true end
   end

   return nil, false
end

---Get the deconstruction planner from cursor (direct or in book)
---@param pindex number
---@return LuaItemStack|nil planner The deconstruction planner stack
---@return boolean in_book Whether the planner is inside a book
function mod.get_decon_planner(pindex)
   local player = game.get_player(pindex)
   if not player then return nil, false end

   local stack = player.cursor_stack
   if not stack or not stack.valid_for_read then return nil, false end

   -- Direct deconstruction planner
   if stack.is_deconstruction_item then return stack, false end

   -- Check inside blueprint book
   if stack.is_blueprint_book then
      local active = get_book_active_item(stack)
      if active and active.is_deconstruction_item then return active, true end
   end

   return nil, false
end

---Check if player is holding an upgrade planner (direct or in book)
---@param pindex number
---@return boolean
function mod.has_upgrade_planner(pindex)
   local planner = mod.get_upgrade_planner(pindex)
   return planner ~= nil
end

---Check if player is holding a deconstruction planner (direct or in book)
---@param pindex number
---@return boolean
function mod.has_decon_planner(pindex)
   local planner = mod.get_decon_planner(pindex)
   return planner ~= nil
end

return mod
