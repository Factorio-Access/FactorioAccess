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

return mod
