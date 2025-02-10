local mod = {}

---@param key string
---@param callback fun(fa.MenuCtx)
---@return fa.MenuRender
function mod.lazy_label(key, callback)
   return {
      key = key,
      label = callback,
      clikc = callback,
   }
end

---@param key string
---@param text LocalisedString
---@return fa.MenuRender
function mod.simple_label(key, text)
   return mod.lazy_label(key, function(ctx)
      ctx.message:fragment(text)
   end)
end

--[[
A "button"-like label: the text is static but you can click it to do something.

Remember though! This can change text on each render, so it's often useful for
dynamic labels too (the next render gets a chance to recompute).
]]
---@param key string
---@param label LocalisedString
---@param click_handler fun(fa.MenuCtx)
---@return fa.MenuItemRender
function mod.clickable_label(key, label, click_handler)
   return {
      label = function(ctx)
         ctx.message:fragment(label)
      end,
      click = click_handler,
   }
end
return mod
