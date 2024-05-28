local panel = require("scripts.ui.controls.panel")

local mod = {}

mod.panel_name = panel.build_panel("fast-travel", function(pindex, builder)
   builder.add_tab("All", function()
      return "todo"
   end)
end)

return mod
