--[[
Infinity pipe configuration tab.

Provides a single fluid selector:
- Empty = voids fluids
- Set to a fluid = produces that fluid
]]

local Menu = require("scripts.ui.menu")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiRouter = require("scripts.ui.router")
local UiUtils = require("scripts.ui.ui-utils")
local Localising = require("scripts.localising")

local mod = {}

---Render the infinity pipe configuration menu
---@param ctx fa.ui.TabContext
---@return fa.ui.graph.Render?
local function render_infinity_pipe_config(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then return nil end

   local menu = Menu.MenuBuilder.new()

   -- Single fluid selector
   menu:add_clickable("fluid_selector", function(ctx)
      local filter = entity.get_infinity_pipe_filter()
      if filter and filter.name then
         local fluid_proto = prototypes.fluid[filter.name]
         ctx.message:fragment({ "fa.infinity-pipe-fluid" })
         if fluid_proto then
            ctx.message:fragment(fluid_proto.localised_name)
         else
            ctx.message:fragment(filter.name)
         end
         if filter.temperature then
            ctx.message:fragment({ "fa.infinity-pipe-temperature", tostring(filter.temperature) })
         end
      else
         ctx.message:fragment({ "fa.infinity-pipe-no-fluid" })
      end
   end, {
      on_click = function(ctx)
         ctx.controller:open_child_ui(UiRouter.UI_NAMES.FLUID_CHOOSER, {}, { node = "fluid_selector" })
      end,
      on_child_result = function(ctx, result)
         if result and result.name then
            -- Set the fluid with default temperature
            local fluid_proto = prototypes.fluid[result.name]
            local default_temp = fluid_proto and fluid_proto.default_temperature or 25

            entity.set_infinity_pipe_filter({
               name = result.name,
               temperature = default_temp,
               percentage = 1.0,
               mode = "exactly",
            })

            if fluid_proto then
               ctx.controller.message:fragment(fluid_proto.localised_name)
            else
               ctx.controller.message:fragment(result.name)
            end
         end
      end,
      on_clear = function(ctx)
         -- Clear the filter to void fluids
         entity.set_infinity_pipe_filter(nil)
         ctx.controller.message:fragment({ "fa.infinity-pipe-cleared" })
      end,
   })

   return menu:build()
end

-- Create the tab descriptor
mod.infinity_pipe_config_tab = UiKeyGraph.declare_graph({
   name = "infinity-pipe-config",
   title = { "fa.infinity-pipe-config-title" },
   render_callback = render_infinity_pipe_config,
})

---Check if this tab is available for the given entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.type == "infinity-pipe"
end

return mod
