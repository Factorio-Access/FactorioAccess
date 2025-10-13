--[[
Programmable speaker UI for Factorio 2.0.

Provides a TabList UI for programmable speakers with:
- Main tabstop: Configuration form (all speaker settings) + Circuit network signals
- Circuit network tabstop: Standard circuit network configuration
]]

local TabList = require("scripts.ui.tab-list")
local Router = require("scripts.ui.router")
local FormBuilder = require("scripts.ui.form-builder")
local KeyGraph = require("scripts.ui.key-graph")
local CircuitNetworkSignals = require("scripts.ui.tabs.circuit-network-signals")
local CircuitNetwork = require("scripts.ui.tabs.circuit-network")
local Localising = require("scripts.localising")

local mod = {}

---Render the speaker configuration form
---@param ctx fa.ui.graph.Ctx
---@return fa.ui.graph.Render?
local function render_speaker_config(ctx)
   local entity = ctx.global_parameters and ctx.global_parameters.entity
   assert(entity and entity.valid, "render_speaker_config: entity is nil or invalid")
   assert(entity.type == "programmable-speaker", "render_speaker_config: entity is not a programmable-speaker")

   local cb = entity.get_control_behavior() --[[@as LuaProgrammableSpeakerControlBehavior]]
   if not cb then
      ctx.controller.message:fragment({ "fa.speaker-no-control-behavior" })
      return nil
   end

   local instruments = entity.prototype.instruments
   local builder = FormBuilder.FormBuilder.new()

   -- Set form-wide accelerator handler for preview
   builder:set_accelerator_handler(function(ctx, accelerator_name)
      if accelerator_name == Router.ACCELERATORS.PREVIEW_SPEAKER then
         local params = cb.circuit_parameters
         local instrument_id = params.instrument_id
         local note_id = params.note_id
         if instrument_id ~= 0 and note_id ~= 0 then entity.play_note(instrument_id, note_id) end
      end
   end)

   -- Instructions label
   builder:add_label("instructions", { "fa.speaker-instructions" })

   -- Circuit condition or label (depends on signal_value_is_pitch)
   if cb.circuit_parameters.signal_value_is_pitch then
      builder:add_label("condition_disabled", { "fa.speaker-signal-controls-pitch-no-condition" })
   else
      builder:add_condition("circuit_condition", function()
         return cb.circuit_condition
      end, function(value)
         cb.circuit_condition = value
      end)
   end

   -- Instrument selection
   local instrument_choices = {}
   for i, inst in ipairs(instruments) do
      table.insert(instrument_choices, {
         label = Localising.get_localised_name_with_fallback(inst),
         -- Confusingly this is the only thing I know of in the API that's zero based, but it is.
         value = i - 1,
      })
   end
   instrument_choices[1].default = true

   builder:add_choice_field("instrument", { "fa.speaker-instrument" }, function()
      return cb.circuit_parameters.instrument_id
   end, function(value)
      local params = cb.circuit_parameters
      params.instrument_id = value
      cb.circuit_parameters = params
   end, instrument_choices)

   -- Pitch/Note selection (choice)
   local pitch_choices = {}
   local current_instrument_id = cb.circuit_parameters.instrument_id
   if current_instrument_id > 0 and current_instrument_id <= #instruments then
      local notes = instruments[current_instrument_id].notes
      for i, note_name in ipairs(notes) do
         table.insert(pitch_choices, {
            label = note_name,
            value = i,
            default = (i == 1),
         })
      end
   else
      -- No instrument selected, add placeholder
      table.insert(pitch_choices, {
         label = { "fa.speaker-pitch-no-instrument" },
         value = 0,
         default = true,
      })
   end

   builder:add_choice_field("pitch", { "fa.speaker-pitch" }, function()
      return cb.circuit_parameters.note_id
   end, function(value)
      local params = cb.circuit_parameters
      params.note_id = value
      cb.circuit_parameters = params
   end, pitch_choices)

   -- Signal controls pitch checkbox
   builder:add_checkbox("signal_controls_pitch", { "fa.speaker-signal-controls-pitch" }, function()
      return cb.circuit_parameters.signal_value_is_pitch
   end, function(value)
      local params = cb.circuit_parameters
      params.signal_value_is_pitch = value
      cb.circuit_parameters = params
   end)

   -- Pitch signal selector (only when signal controls pitch)
   if cb.circuit_parameters.signal_value_is_pitch then
      builder:add_signal("pitch_signal", { "fa.speaker-pitch-signal" }, function()
         return cb.circuit_condition.first_signal
      end, function(value)
         local condition = cb.circuit_condition
         condition.first_signal = value
         cb.circuit_condition = condition
      end)
   end

   -- Volume (choice: 0-10 representing 0.0-1.0)
   local volume_choices = {}
   for i = 0, 10 do
      table.insert(volume_choices, {
         label = tostring(i),
         value = i,
      })
   end

   builder:add_choice_field("volume", { "fa.speaker-volume" }, function()
      return math.floor(entity.parameters.playback_volume * 10 + 0.5)
   end, function(value)
      local params = entity.parameters
      params.playback_volume = value / 10
      entity.parameters = params
   end, volume_choices)

   -- Volume controlled by signal checkbox
   builder:add_checkbox("volume_controlled_by_signal", { "fa.speaker-volume-controlled-by-signal" }, function()
      return entity.parameters.volume_controlled_by_signal
   end, function(value)
      local params = entity.parameters
      params.volume_controlled_by_signal = value
      entity.parameters = params
   end)

   -- Volume signal picker
   builder:add_signal("volume_signal", { "fa.speaker-volume-signal" }, function()
      return entity.parameters.volume_signal_id
   end, function(value)
      local params = entity.parameters
      params.volume_signal_id = value
      entity.parameters = params
   end)

   -- Playback mode (local/surface/global)
   local mode_choices = {
      { label = { "fa.speaker-mode-local" }, value = "local" },
      { label = { "fa.speaker-mode-surface" }, value = "surface" },
      { label = { "fa.speaker-mode-global" }, value = "global" },
   }

   builder:add_choice_field("playback_mode", { "fa.speaker-playback-mode" }, function()
      return entity.parameters.playback_mode
   end, function(value)
      local params = entity.parameters
      params.playback_mode = value
      entity.parameters = params
   end, mode_choices)

   -- Allow polyphony checkbox
   builder:add_checkbox("allow_polyphony", { "fa.speaker-allow-polyphony" }, function()
      return entity.parameters.allow_polyphony
   end, function(value)
      local params = entity.parameters
      params.allow_polyphony = value
      entity.parameters = params
   end)

   -- Show alert checkbox
   builder:add_checkbox("show_alert", { "fa.speaker-show-alert" }, function()
      return entity.alert_parameters.show_alert
   end, function(value)
      local params = entity.alert_parameters
      params.show_alert = value
      entity.alert_parameters = params
   end)

   -- Alert message textfield
   builder:add_textfield("alert_message", { "fa.speaker-alert-message" }, function()
      return entity.alert_parameters.alert_message
   end, function(value)
      local params = entity.alert_parameters
      params.alert_message = value
      entity.alert_parameters = params
   end)

   -- Alert icon signal picker
   builder:add_signal("alert_icon", { "fa.speaker-alert-icon" }, function()
      return entity.alert_parameters.icon_signal_id
   end, function(value)
      local params = entity.alert_parameters
      params.icon_signal_id = value
      entity.alert_parameters = params
   end)

   -- Show on map checkbox
   builder:add_checkbox("show_on_map", { "fa.speaker-show-on-map" }, function()
      return entity.alert_parameters.show_on_map
   end, function(value)
      local params = entity.alert_parameters
      params.show_on_map = value
      entity.alert_parameters = params
   end)

   return builder:build()
end

---Build tabs for the programmable speaker
---@param pindex number
---@param parameters any
---@return fa.ui.TabstopDescriptor[]
local function build_speaker_tabs(pindex, parameters)
   assert(parameters, "build_speaker_tabs: parameters is nil")
   local entity = parameters.entity
   assert(entity, "build_speaker_tabs: entity is nil")
   assert(entity.valid, "build_speaker_tabs: entity is not valid")
   assert(entity.type == "programmable-speaker", "build_speaker_tabs: entity is not a programmable-speaker")

   -- Tabstop 1: Main (Configuration + Circuit signals)
   local main_tabs = {}

   -- Configuration tab
   table.insert(
      main_tabs,
      KeyGraph.declare_graph({
         name = "config",
         title = { "fa.speaker-config-title" },
         render_callback = render_speaker_config,
      })
   )

   -- Circuit network signals tabs (red and green)
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-red" },
         false,
         defines.wire_connector_id.circuit_red
      )
   )
   table.insert(
      main_tabs,
      CircuitNetworkSignals.create_signals_tab(
         { "fa.circuit-network-signals-green" },
         false,
         defines.wire_connector_id.circuit_green
      )
   )

   -- Tabstop 2: Circuit network configuration (if available)
   local circuit_tabs = {}
   if CircuitNetwork.is_available(entity) then table.insert(circuit_tabs, CircuitNetwork.get_tab()) end

   return {
      {
         name = "main",
         tabs = main_tabs,
      },
      {
         name = "circuit_network",
         title = { "fa.section-circuit-network" },
         tabs = circuit_tabs,
      },
   }
end

---Create and register the programmable speaker UI
mod.programmable_speaker_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.PROGRAMMABLE_SPEAKER,
   resets_to_first_tab_on_open = true,
   tabs_callback = build_speaker_tabs,
})

Router.register_ui(mod.programmable_speaker_ui)

return mod
