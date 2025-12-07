-- Shared setting declarations used by both settings.lua (data stage) and runtime UI
-- Each entry defines a setting that will be registered with Factorio and displayed in our settings menu

---@class fa.SettingDecl
---@field name string
---@field type "bool-setting"|"int-setting"|"double-setting"|"string-setting"
---@field setting_type "runtime-per-user"
---@field default_value boolean|number|string
---@field order string
---@field minimum_value number?
---@field maximum_value number?
---@field allowed_values string[]?

---@type fa.SettingDecl[]
return {
   {
      name = "fa-inserter-sonification",
      type = "bool-setting",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "a",
   },
   {
      name = "fa-crafting-sonification",
      type = "bool-setting",
      setting_type = "runtime-per-user",
      default_value = false,
      order = "b",
   },
}
