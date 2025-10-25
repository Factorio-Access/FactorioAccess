--[[
Spidertron follow entity selector.

Allows selecting an entity for the spidertron to follow.
]]
local MultipointSelector = require("scripts.ui.selectors.multipoint-selector")
local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")
local Localising = require("scripts.localising")
local MessageBuilder = Speech.MessageBuilder
local UiSounds = require("scripts.ui.sounds")

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
      if not args.entity then
         -- No entity at cursor
         UiSounds.play_ui_edge(args.router_ctx.pindex)
         args.router_ctx.message:fragment({ "fa.spidertron-follow-no-entity" })
         return { result_kind = MultipointSelector.RESULT_KIND.KEEP_GOING }
      end

      if not args.entity.valid then
         -- Invalid entity
         UiSounds.play_ui_edge(args.router_ctx.pindex)
         args.router_ctx.message:fragment({ "fa.spidertron-follow-invalid-entity" })
         return { result_kind = MultipointSelector.RESULT_KIND.KEEP_GOING }
      end

      -- Set the follow target
      spidertron.follow_target = args.entity

      local message = MessageBuilder.new()
      message:fragment({ "fa.spidertron-follow-set" })
      message:fragment(Localising.get_localised_name_with_fallback(args.entity))
      args.router_ctx.message:fragment(message:build())

      return { result_kind = MultipointSelector.RESULT_KIND.STOP }
   end

   return { result_kind = MultipointSelector.RESULT_KIND.KEEP_GOING }
end

mod.spidertron_follow_selector = MultipointSelector.declare_multipoint_selector({
   ui_name = UiRouter.UI_NAMES.SPIDERTRON_FOLLOW,
   intro_message = { "fa.spidertron-follow-intro" },
   point_selected_callback = on_point_selected,
})

UiRouter.register_ui(mod.spidertron_follow_selector)

return mod
