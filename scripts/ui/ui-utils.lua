--[[
UI utility functions shared across UI components.
Provides common patterns for UI development.
]]

local mod = {}

---Convert a static label or function to a message fragment function
---@param label LocalisedString | fun(ctx: fa.ui.graph.Ctx)
---@return fun(ctx: fa.ui.graph.Ctx)
function mod.to_label_function(label)
   if type(label) == "function" then return label end
   return function(ctx)
      ctx.message:fragment(label)
   end
end

return mod
