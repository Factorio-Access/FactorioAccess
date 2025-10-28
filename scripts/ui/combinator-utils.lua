--[[
Common utilities for combinator configuration UIs.
Provides shared functionality across different combinator types.
]]

local mod = {}

---Add common combinator settings to a FormBuilder
---@param form_builder fa.ui.form.FormBuilder The form builder to add settings to
---@param entity LuaEntity The combinator entity
---@return fa.ui.form.FormBuilder The form builder (for chaining)
function mod.common_settings(form_builder, entity)
   assert(entity and entity.valid, "common_settings: entity is nil or invalid")

   -- Add description field
   form_builder:add_textfield("description", {
      label = { "fa.combinator-description" },
      get_value = function()
         return entity.combinator_description or ""
      end,
      set_value = function(value)
         entity.combinator_description = value
      end,
      on_clear = function(ctx)
         entity.combinator_description = ""
         ctx.controller.message:fragment({ "fa.cleared" })
      end,
   })

   return form_builder
end

return mod
