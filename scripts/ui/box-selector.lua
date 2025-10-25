--[[
A box selector.

The player selects two points and we return them Note that this *DOES* mean that the second point = the first point if
the player didn't move the cursor, and that in effect from the player's perspective this box includes the second point.
]]
local MultipointSelector = require("scripts.ui.selectors.multipoint-selector")

local mod = {}

---@class fa.ui.BoxSelectorDeclaration
---@field ui_name fa.ui.UiName
---@field callback? fun(pindex: number, params: table, result: table) Optional callback when selection completes

---@class fa.ui.BoxSelectorParameters
---@field intro_message? LocalisedString Custom intro message
---@field second_message? LocalisedString|false Custom second message, or false to suppress

---@class fa.ui.BoxSelectorState
---@field first_click? {x: number, y: number, modifiers: table, is_right_click: boolean}

---@param declaration fa.ui.BoxSelectorDeclaration
---@return fa.ui.UiPanelBase
function mod.declare_box_selector(declaration)
   assert(declaration.ui_name, "BoxSelector declaration must have ui_name")

   local callback = declaration.callback

   return MultipointSelector.declare_multipoint_selector({
      ui_name = declaration.ui_name,
      intro_message = { "fa.box-selector-intro" },
      point_selected_callback = function(args)
         ---@type fa.ui.BoxSelectorState
         local state = args.state

         if not state.first_click then
            -- First click - store it
            state.first_click = {
               x = args.position.x,
               y = args.position.y,
               modifiers = args.modifiers or {},
               is_right_click = args.kind == MultipointSelector.SELECTION_KIND.RIGHT,
            }

            -- Only speak second message if explicitly provided (false to suppress)
            if args.parameters.second_message ~= false then
               local second_message = args.parameters.second_message or { "fa.box-selector-second-point" }
               args.router_ctx.message:fragment(second_message)
            end

            return {
               result_kind = MultipointSelector.RESULT_KIND.KEEP_GOING,
               state = state,
            }
         else
            -- Second click - build box and complete
            local result = {
               first_click = state.first_click,
               second_click = {
                  x = args.position.x,
                  y = args.position.y,
                  modifiers = args.modifiers or {},
                  is_right_click = args.kind == MultipointSelector.SELECTION_KIND.RIGHT,
               },
               box = {
                  left_top = {
                     x = math.min(state.first_click.x, args.position.x),
                     y = math.min(state.first_click.y, args.position.y),
                  },
                  right_bottom = {
                     x = math.max(state.first_click.x, args.position.x),
                     y = math.max(state.first_click.y, args.position.y),
                  },
               },
               controller = args.router_ctx,
            }

            if callback then callback(args.router_ctx.pindex, args.parameters, result) end

            args.router_ctx:close_with_result(result)

            return {
               result_kind = MultipointSelector.RESULT_KIND.STOP,
            }
         end
      end,
   })
end

return mod
