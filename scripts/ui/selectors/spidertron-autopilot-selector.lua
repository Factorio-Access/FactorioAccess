--[[
Spidertron autopilot position selector.

Uses the multipoint selector to let users set autopilot destinations for a spidertron.
]]
local MultipointSelector = require("scripts.ui.selectors.multipoint-selector")
local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

---@param args fa.ui.selectors.MultipointCallbackArgs
---@return fa.ui.selectors.MultipointCallbackResult
local function on_point_selected(args)
   local spidertron = args.parameters.spidertron

   if not spidertron or not spidertron.valid then
      args.router_ctx.message:fragment({ "fa.spidertron-invalid" })
      return { result_kind = MultipointSelector.RESULT_KIND.STOP }
   end

   if args.kind == MultipointSelector.SELECTION_KIND.LEFT then
      -- Track if this is the first waypoint
      if not args.state.has_selected_first then
         -- First waypoint: clear queue and set destination
         spidertron.autopilot_destination = args.position
         args.state.has_selected_first = true
         args.state.waypoint_count = 1
      else
         -- Subsequent waypoints: add to queue
         spidertron.add_autopilot_destination(args.position)
         args.state.waypoint_count = (args.state.waypoint_count or 1) + 1
      end

      local message = MessageBuilder.new()
      message:fragment({ "fa.spidertron-autopilot-added" })
      message:fragment(tostring(math.floor(args.position.x)))
      message:fragment(tostring(math.floor(args.position.y)))
      message:fragment({ "fa.spidertron-autopilot-queue-count", tostring(args.state.waypoint_count) })
      args.router_ctx.message:fragment(message:build())

      -- Keep going to allow multiple waypoints
      return { result_kind = MultipointSelector.RESULT_KIND.KEEP_GOING }
   end

   return { result_kind = MultipointSelector.RESULT_KIND.KEEP_GOING }
end

mod.spidertron_autopilot_selector = MultipointSelector.declare_multipoint_selector({
   ui_name = UiRouter.UI_NAMES.SPIDERTRON_AUTOPILOT,
   intro_message = { "fa.spidertron-autopilot-intro" },
   point_selected_callback = on_point_selected,
})

UiRouter.register_ui(mod.spidertron_autopilot_selector)

return mod
