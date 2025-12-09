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

local mod = {}

mod.SETTING_NAMES = {
   SONIFICATION_INSERTER = "fa-inserter-sonification",
   SONIFICATION_CRAFTING = "fa-crafting-sonification",
}

---@type fa.SettingDecl[]
mod.declarations = {
   {
      name = mod.SETTING_NAMES.SONIFICATION_INSERTER,
      type = "bool-setting",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "a",
   },
   {
      name = mod.SETTING_NAMES.SONIFICATION_CRAFTING,
      type = "bool-setting",
      setting_type = "runtime-per-user",
      default_value = true,
      order = "b",
   },
}

return mod
