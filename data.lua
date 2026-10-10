--Data changes: Including vanilla prototype changes, new prototypes, new sound files, new custom input events

--Vanilla prototype changes--

---New radar type: This radar scans a new sector every 5 seconds instead of 33, and it refreshes its short range every 5 seconds (precisely fast enough) instead of 1 second, but the short range is smaller and the radar costs double the power.
local ar_tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.9 }
local access_radar = table.deepcopy(data.raw["radar"]["radar"])
access_radar.icons = {
   {
      icon = assert(access_radar.icon),
      icon_size = access_radar.icon_size,
      tint = ar_tint,
   },
}
access_radar.name = "access-radar"
access_radar.energy_usage = "600kW" --Default: "300kW"
access_radar.energy_per_sector = "3MJ" --Default: "10MJ"
access_radar.energy_per_nearby_scan = "3MJ" --Default: "250kJ"
access_radar.max_distance_of_sector_revealed = 32 --Default: 14, now scans up to 1024 tiles away instead of 448
access_radar.max_distance_of_nearby_sector_revealed = 2 --Default: 3
access_radar.rotation_speed = 0.01 --Default: 0.01
access_radar.minable.result = "access-radar"
access_radar.pictures.layers[1].tint = ar_tint --grey
access_radar.pictures.layers[2].tint = ar_tint --grey

local access_radar_item = table.deepcopy(data.raw["item"]["radar"])
access_radar_item.name = "access-radar"
access_radar_item.place_result = "access-radar"
access_radar_item.icons = {
   {
      icon = assert(access_radar_item.icon),
      icon_size = access_radar_item.icon_size,
      tint = ar_tint,
   },
}

local access_radar_recipe = table.deepcopy(data.raw["recipe"]["radar"])
access_radar_recipe.enabled = true
access_radar_recipe.name = "access-radar"
access_radar_recipe.results = { { type = "item", name = "access-radar", amount = 1 } }
access_radar_recipe.ingredients = {
   { type = "item", name = "electronic-circuit", amount = 10 },
   { type = "item", name = "iron-gear-wheel", amount = 10 },
   { type = "item", name = "iron-plate", amount = 20 },
}

data:extend({ access_radar, access_radar_item })
data:extend({ access_radar_item, access_radar_recipe })

---New presets for map generation (deprecated?)
resource_def = { richness = 4 }

data.raw["map-gen-presets"].default["faccess-compass-valley"] = {
   order = "_A",
   basic_settings = {
      autoplace_controls = {
         coal = resource_def,
         ["copper-ore"] = resource_def,
         ["crude-oil"] = resource_def,
         ["iron-ore"] = resource_def,
         stone = resource_def,
         ["uranium-ore"] = resource_def,
      },
      seed = 2703463849,
      starting_area = 4,
      peaceful_mode = true,
      cliff_settings = {
         name = "cliff",
         cliff_elevation_0 = 10,
         cliff_elevation_interval = 240,
         richness = 0.1666666716337204,
      },
   },
   advanced_settings = {
      enemy_evolution = {
         enabled = true,
         time_factor = 0,
         destroy_factor = 0.006,
         pollution_factor = 1e-07,
      },
      enemy_expansion = {
         enabled = false,
      },
   },
}

data.raw["map-gen-presets"].default["faccess-enemies-off"] = {
   order = "_B",
   basic_settings = {
      autoplace_controls = {
         ["enemy-base"] = { frequency = 0 },
      },
   },
}

data.raw["map-gen-presets"].default["faccess-peaceful"] = {
   order = "_C",
   basic_settings = {
      peaceful_mode = true,
   },
}

--New sound files--
data:extend({
   {
      type = "sound",
      name = "fa-battle-notice",
      category = "alert",
      filename = "__FactorioAccess__/audio/battle-notice.ogg", -- TODO: Add sound file
      volume = 0.7,
      preload = true,
   },

   {
      type = "sound",
      name = "audio-ruler-at-definition",
      category = "gui-effect",
      filename = "__base__/sound/programmable-speaker/kit-07.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "audio-ruler-aligned",
      category = "gui-effect",
      filename = "__base__/sound/programmable-speaker/plucked-14.ogg",
      volume = 0.5,
      preload = true,
   },

   {
      type = "sound",
      name = "audio-ruler-close",
      category = "gui-effect",
      filename = "__base__/sound/programmable-speaker/plucked-12.ogg",
      volume = 0.5,
      preload = true,
   },

   {
      type = "sound",
      name = "Open-Inventory-Sound",
      category = "gui-effect",
      filename = "__core__/sound/gui-green-button.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "Close-Inventory-Sound",
      category = "gui-effect",
      filename = "__core__/sound/gui-green-confirm.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "Change-Menu-Tab-Sound",
      category = "gui-effect",
      filename = "__core__/sound/gui-switch.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "inventory-edge",
      category = "gui-effect",
      filename = "__FactorioAccess__/audio/inventory-edge-zapsplat_vehicles_car_roof_light_switch_click_002_80933.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "Inventory-Move",
      category = "gui-effect",
      filename = "__FactorioAccess__/audio/inventory-move.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "inventory-wrap-around",
      category = "gui-effect",
      filename = "__FactorioAccess__/audio/inventory-wrap-around-zapsplat_leisure_toy_plastic_wind_up_003_13198.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-bump-stuck-alert",
      category = "alert",
      filename = "__FactorioAccess__/audio/player-bump-stuck-alert-zapsplat_multimedia_game_sound_synth_digital_tone_beep_005_38537.wav",
      volume = 0.75,
      preload = true,
   },

   {
      type = "sound",
      name = "player-bump-slide",
      category = "alert",
      filename = "__FactorioAccess__/audio/player-bump-slide-zapsplat_foley_footstep_boot_kick_gravel_stones_out_002.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-bump-trip",
      category = "alert",
      filename = "__FactorioAccess__/audio/player-bump-trip-zapsplat-trimmed_industrial_tool_pick_axe_single_hit_strike_wood_tree_trunk_001_103466.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-crafting",
      category = "gui-effect",
      filename = "__FactorioAccess__/audio/player-crafting-zapsplat-modified_industrial_mechanical_wind_up_manual_001_86125.wav",
      volume = 0.25,
      preload = true,
   },

   {
      type = "sound",
      name = "player-mine",
      category = "gui-effect",
      filename = "__FactorioAccess__/audio/player-mine_02.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-teleported",
      category = "game-effect",
      filename = "__FactorioAccess__/audio/player-teleported-zapsplat_science_fiction_computer_alarm_single_medium_ring_beep_fast_004_84296.wav",
      volume = 0.5,
      preload = true,
   },

   {
      type = "sound",
      name = "Rotate-Hand-Sound",
      category = "gui-effect",
      filename = "__core__/sound/gui-back.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "scanner-pulse",
      category = "game-effect",
      filename = "__FactorioAccess__/audio/scanner-pulse-zapsplat_science_fiction_computer_alarm_single_medium_ring_beep_fast_001_84293.wav",
      volume = 0.2,
      preload = true,
   },
})

--New custom input events--
require("data.input")
