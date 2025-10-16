--[[
Fluids tab for entity UI
Displays and manages entity fluids
]]

local Fluids = require("scripts.fluids")
local Localising = require("scripts.localising")
local Menu = require("scripts.ui.menu")
local UiKeyGraph = require("scripts.ui.key-graph")

local mod = {}

---Check if fluids tab is available for this entity
---@param entity LuaEntity
---@return boolean
function mod.is_available(entity)
   return entity.valid and entity.fluids_count > 0
end

---Main render function for fluids tab
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_fluids_tab(ctx)
   local entity = ctx.tablist_shared_state.entity
   if not entity or not entity.valid then
      ctx.controller.message:fragment({ "fa.fluids-entity-invalid" })
      ctx.controller:close()
      return nil
   end

   local descriptors = Fluids.build_fluid_descriptors(entity)
   local builder = Menu.MenuBuilder.new()

   if #descriptors == 0 then
      -- No fluids present - show a single menu item
      builder:add_label("no_fluids", { "fa.fluids-menu-no-fluids" })
      return builder:build()
   end

   -- Build menu items from descriptors
   for i, desc in ipairs(descriptors) do
      local key = string.format("fluid_%d", i)

      builder:add_clickable(key, function(label_ctx)
         local msg = label_ctx.message
         local fluid_proto = prototypes.fluid[desc.fluid_name]
         local fluid_name = fluid_proto and Localising.get_localised_name_with_fallback(fluid_proto) or desc.fluid_name

         -- Build the label based on descriptor
         if desc.empty then
            -- Empty locked fluidbox
            if desc.direction_type then
               msg:fragment({ "fa.fluids-locked-direction", desc.direction_type, fluid_name })
            else
               msg:fragment({ "fa.fluids-locked", fluid_name })
            end
         else
            -- Fluid with amount
            if desc.direction_type then
               msg:fragment({
                  "fa.fluids-with-direction",
                  fluid_name,
                  tostring(math.floor(desc.amount)),
                  desc.direction_type,
               })
            else
               msg:fragment({ "fa.fluids-no-direction", fluid_name, tostring(math.floor(desc.amount)) })
            end
         end
      end, {
         on_clear = function(clear_ctx)
            local ent = clear_ctx.tablist_shared_state.entity
            if not ent or not ent.valid then
               clear_ctx.message:fragment({ "fa.fluids-entity-invalid" })
               return
            end

            -- Always use remove_fluid (fluidbox.flush has bugs in 2.0)
            -- Use a very large number to flush all fluid of this type
            local removed = ent.remove_fluid({ name = desc.fluid_name, amount = 1e9 })
            if removed and removed > 0 then
               clear_ctx.message:fragment({ "fa.fluids-flushed" })
            else
               clear_ctx.message:fragment({ "fa.fluids-cant-flush" })
            end
         end,
      })
   end

   return builder:build()
end

-- Export the fluids tab
mod.fluids_tab = UiKeyGraph.declare_graph({
   name = "fluids",
   title = { "fa.fluids-tab-title" },
   render_callback = render_fluids_tab,
})

return mod
