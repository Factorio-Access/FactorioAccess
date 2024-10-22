--Data changes: Including vanilla prototype changes, new prototypes, new sound files, new custom input events

--Vanilla prototype changes--

---New radar type: This radar scans a new sector every 5 seconds instead of 33, and it refreshes its short range every 5 seconds (precisely fast enough) instead of 1 second, but the short range is smaller and the radar costs double the power.
local ar_tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.9 }
local access_radar = table.deepcopy(data.raw["radar"]["radar"])
access_radar.icons = {
   {
      icon = access_radar.icon,
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
      icon = access_radar_item.icon,
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
      seed = 3814061204,
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
      name = "alert-enemy-presence-high",
      category = "alert",
      filename = "__FactorioAccess__/Audio/alert-enemy-presence-high-zapsplat-trimmed-science_fiction_alarm_fast_high_pitched_warning_tone_emergency_003_60104.wav",
      volume = 0.4,
      preload = true,
   },

   {
      type = "sound",
      name = "alert-enemy-presence-low",
      category = "alert",
      filename = "__FactorioAccess__/Audio/alert-enemy-presence-low-zapsplat-modified_multimedia_game_tone_short_bright_futuristic_beep_action_tone_002_59161.wav",
      volume = 0.4,
      preload = true,
   },

   {
      type = "sound",
      name = "alert-structure-damaged",
      category = "alert",
      filename = "__FactorioAccess__/Audio/alert-structure-damaged-zapsplat-modified-emergency_alarm_003.wav",
      volume = 1,
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
      filename = "__FactorioAccess__/Audio/inventory-edge-zapsplat_vehicles_car_roof_light_switch_click_002_80933.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "Inventory-Move",
      category = "gui-effect",
      filename = "__FactorioAccess__/Audio/inventory-move.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "inventory-wrap-around",
      category = "gui-effect",
      filename = "__FactorioAccess__/Audio/inventory-wrap-around-zapsplat_leisure_toy_plastic_wind_up_003_13198.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-aim-locked",
      category = "alert",
      filename = "__FactorioAccess__/Audio/player-aim-locked-zapsplat_multimedia_game_beep_high_pitched_generic_002_25862.wav",
      volume = 0.5,
      preload = true,
   },

   {
      type = "sound",
      name = "player-bump-alert",
      category = "alert",
      filename = "__FactorioAccess__/Audio/player-bump-alert-zapsplat-trimmed_multimedia_game_sound_synth_digital_tone_beep_001_38533.wav",
      volume = 0.75,
      preload = true,
   },

   {
      type = "sound",
      name = "player-bump-stuck-alert",
      category = "alert",
      filename = "__FactorioAccess__/Audio/player-bump-stuck-alert-zapsplat_multimedia_game_sound_synth_digital_tone_beep_005_38537.wav",
      volume = 0.75,
      preload = true,
   },

   {
      type = "sound",
      name = "player-bump-slide",
      category = "alert",
      filename = "__FactorioAccess__/Audio/player-bump-slide-zapsplat_foley_footstep_boot_kick_gravel_stones_out_002.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-bump-trip",
      category = "alert",
      filename = "__FactorioAccess__/Audio/player-bump-trip-zapsplat-trimmed_industrial_tool_pick_axe_single_hit_strike_wood_tree_trunk_001_103466.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-crafting",
      category = "gui-effect",
      filename = "__FactorioAccess__/Audio/player-crafting-zapsplat-modified_industrial_mechanical_wind_up_manual_001_86125.wav",
      volume = 0.25,
      preload = true,
   },

   {
      type = "sound",
      name = "player-damaged-character",
      category = "alert",
      filename = "__FactorioAccess__/Audio/player-damaged-character-zapsplat-modified_multimedia_beep_harsh_synth_single_high_pitched_87498.wav",
      volume = 0.75,
      preload = true,
   },

   {
      type = "sound",
      name = "player-damaged-shield",
      category = "alert",
      filename = "__FactorioAccess__/Audio/player-damaged-shield-zapsplat_multimedia_game_sound_sci_fi_futuristic_beep_action_tone_001_64989.wav",
      volume = 0.75,
      preload = true,
   },

   {
      type = "sound",
      name = "player-mine",
      category = "gui-effect",
      filename = "__FactorioAccess__/Audio/player-mine_02.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-teleported",
      category = "game-effect",
      filename = "__FactorioAccess__/Audio/player-teleported-zapsplat_science_fiction_computer_alarm_single_medium_ring_beep_fast_004_84296.wav",
      volume = 0.5,
      preload = true,
   },

   {
      type = "sound",
      name = "player-turned",
      category = "gui-effect",
      filename = "__FactorioAccess__/Audio/player-turned-1face_dir.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "player-walk",
      category = "walking",
      filename = "__FactorioAccess__/Audio/player-walk-zapsplat-little_robot_sound_factory_fantasy_Footstep_Dirt_001.wav",
      volume = 1,
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
      filename = "__FactorioAccess__/Audio/scanner-pulse-zapsplat_science_fiction_computer_alarm_single_medium_ring_beep_fast_001_84293.wav",
      volume = 0.2,
      preload = true,
   },

   {
      type = "sound",
      name = "train-alert-high",
      category = "alert",
      filename = "__FactorioAccess__/Audio/train-alert-high-zapsplat-trimmed_science_fiction_alarm_warning_buzz_harsh_large_reverb_60111.wav",
      volume = 0.3,
      preload = true,
   },

   {
      type = "sound",
      name = "train-alert-low",
      category = "alert",
      filename = "__FactorioAccess__/Audio/train-alert-low-zapsplat_multimedia_beep_digital_high_tech_electronic_001_87483.wav",
      volume = 0.3,
      preload = true,
   },

   {
      type = "sound",
      name = "train-clack",
      category = "walking",
      filename = "__FactorioAccess__/Audio/train-clack-zapsplat-cut-transport_steam_train_arrive_at_station_with_tannoy_announcement.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "train-honk-short",
      category = "game-effect",
      filename = "__FactorioAccess__/Audio/train-honk-short-2x-GotLag.ogg",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "train-honk-long",
      category = "game-effect",
      filename = "__FactorioAccess__/Audio/train-honk-long-pixabay-modified-diesel-horn-02-98042.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "train-honk-low-long",
      category = "game-effect",
      filename = "__FactorioAccess__/Audio/train-honk-long-pixabay-modified-lower-diesel-horn-02-98042.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "car-honk",
      category = "game-effect",
      filename = "__FactorioAccess__/Audio/car-horn-zapsplat_transport_car_horn_single_beep_external_toyota_corolla_002_18246.wav",
      volume = 1,
      preload = true,
   },

   {
      type = "sound",
      name = "tank-honk",
      category = "game-effect",
      filename = "__FactorioAccess__/Audio/tank-horn-zapsplat-Blastwave_FX_FireTruckHornHonk_SFXB.458.wav",
      volume = 1,
      preload = true,
   },
})

--New custom input events--
data:extend({
   {
      type = "custom-input",
      name = "pause-game-fa",
      key_sequence = "ESCAPE",
      linked_game_control = "toggle-menu",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-up",
      key_sequence = "W",
      linked_game_control = "move-up",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-down",
      key_sequence = "S",
      linked_game_control = "move-down",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-left",
      key_sequence = "A",
      linked_game_control = "move-left",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-right",
      key_sequence = "D",
      linked_game_control = "move-right",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-skip-north",
      key_sequence = "SHIFT + W",
      alternative_key_sequence = "KP_8",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-skip-south",
      key_sequence = "SHIFT + S",
      alternative_key_sequence = "KP_2",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-skip-west",
      key_sequence = "SHIFT + A",
      alternative_key_sequence = "KP_4",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-skip-east",
      key_sequence = "SHIFT + D",
      alternative_key_sequence = "KP_6",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-skip-by-preview-north",
      key_sequence = "CONTROL + W",
      alternative_key_sequence = "CONTROL + KP_8",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-skip-by-preview-south",
      key_sequence = "CONTROL + S",
      alternative_key_sequence = "CONTROL + KP_2",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-skip-by-preview-west",
      key_sequence = "CONTROL + A",
      alternative_key_sequence = "CONTROL + KP_4",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "cursor-skip-by-preview-east",
      key_sequence = "CONTROL + D",
      alternative_key_sequence = "CONTROL + KP_6",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "nudge-building-up",
      key_sequence = "SHIFT + UP",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "nudge-building-down",
      key_sequence = "SHIFT + DOWN",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "nudge-building-left",
      key_sequence = "SHIFT + LEFT",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "nudge-building-right",
      key_sequence = "SHIFT + RIGHT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "nudge-character-up",
      key_sequence = "CONTROL + UP",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "nudge-character-down",
      key_sequence = "CONTROL + DOWN",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "nudge-character-left",
      key_sequence = "CONTROL + LEFT",
      consuming = "none",
   },
   {
      type = "custom-input",
      name = "nudge-character-right",
      key_sequence = "CONTROL + RIGHT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-cursor-coords",
      key_sequence = "K",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-cursor-distance-and-direction",
      key_sequence = "SHIFT + K",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-cursor-distance-vector",
      key_sequence = "ALT + K",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-character-coords",
      key_sequence = "CONTROL + K",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "return-cursor-to-player",
      key_sequence = "J",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-bookmark-save",
      key_sequence = "SHIFT + B",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-bookmark-load",
      key_sequence = "B",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "ruler-save",
      key_sequence = "CONTROL + ALT + B",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "ruler-clear",
      key_sequence = "SHIFT + ALT + B",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "blueprint-book-create",
      key_sequence = "CONTROL + SHIFT + ALT + B",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "type-cursor-target",
      key_sequence = "ALT + T",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "teleport-to-cursor",
      key_sequence = "SHIFT + T",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "teleport-to-cursor-forced",
      key_sequence = "CONTROL + SHIFT + T",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "teleport-to-alert-forced",
      key_sequence = "CONTROL + SHIFT + P",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-cursor",
      key_sequence = "I",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-size-increment",
      key_sequence = "SHIFT + I",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-size-decrement",
      key_sequence = "CONTROL + I",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-remote-view",
      key_sequence = "ALT + I",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "increase-inventory-bar-by-1",
      key_sequence = "PAGEUP",
      alternative_key_sequence = "ALT + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "increase-inventory-bar-by-5",
      key_sequence = "SHIFT + PAGEUP",
      alternative_key_sequence = "SHIFT + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "increase-inventory-bar-by-100",
      key_sequence = "CONTROL + PAGEUP",
      alternative_key_sequence = "CTRL + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "decrease-inventory-bar-by-1",
      key_sequence = "PAGEDOWN",
      alternative_key_sequence = "ALT + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "decrease-inventory-bar-by-5",
      key_sequence = "SHIFT + PAGEDOWN",
      alternative_key_sequence = "SHIFT + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "decrease-inventory-bar-by-100",
      key_sequence = "CONTROL + PAGEDOWN",
      alternative_key_sequence = "CTRL + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "increase-train-wait-times-by-5",
      key_sequence = "PAGEUP",
      alternative_key_sequence = "ALT + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "increase-train-wait-times-by-60",
      key_sequence = "CONTROL + PAGEUP",
      alternative_key_sequence = "CTRL + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "decrease-train-wait-times-by-5",
      key_sequence = "PAGEDOWN",
      alternative_key_sequence = "ALT + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "decrease-train-wait-times-by-60",
      key_sequence = "CONTROL + PAGEDOWN",
      alternative_key_sequence = "CTRL + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "inserter-hand-stack-size-up",
      key_sequence = "PAGEUP",
      alternative_key_sequence = "ALT + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "inserter-hand-stack-size-down",
      key_sequence = "PAGEDOWN",
      alternative_key_sequence = "ALT + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-rail-structure-ahead",
      key_sequence = "SHIFT + J",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-driving-structure-ahead",
      key_sequence = "J",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-rail-structure-behind",
      key_sequence = "CONTROL + J",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "rescan",
      key_sequence = "END",
      alternative_key_sequence = "RCTRL",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-facing-direction",
      key_sequence = "SHIFT + END",
      alternative_key_sequence = "SHIFT + RCTRL",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-list-up",
      key_sequence = "PAGEUP",
      alternative_key_sequence = "ALT + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-list-down",
      key_sequence = "PAGEDOWN",
      alternative_key_sequence = "ALT + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-list-middle",
      key_sequence = "HOME",
      alternative_key_sequence = "RSHIFT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-category-up",
      key_sequence = "CONTROL + PAGEUP",
      alternative_key_sequence = "CONTROL + ALT + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-category-down",
      key_sequence = "CONTROL + PAGEDOWN",
      alternative_key_sequence = "CONTROL + ALT + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-sort-by-distance",
      key_sequence = "N",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-selection-up",
      key_sequence = "SHIFT + PAGEUP",
      alternative_key_sequence = "SHIFT + ALT + UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "scan-selection-down",
      key_sequence = "SHIFT + PAGEDOWN",
      alternative_key_sequence = "SHIFT + ALT + DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "repeat-last-spoken",
      key_sequence = "CONTROL + TAB",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "tile-cycle",
      key_sequence = "SHIFT + F",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "pickup-items-info",
      key_sequence = "F",
      linked_game_control = "pick-items",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "open-inventory",
      key_sequence = "E",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "close-menu-access",
      key_sequence = "E",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-menu-name",
      key_sequence = "SHIFT + E",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-1",
      key_sequence = "1",
      linked_game_control = "quick-bar-button-1",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-2",
      key_sequence = "2",
      linked_game_control = "quick-bar-button-2",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-3",
      key_sequence = "3",
      linked_game_control = "quick-bar-button-3",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-4",
      key_sequence = "4",
      linked_game_control = "quick-bar-button-4",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-5",
      key_sequence = "5",
      linked_game_control = "quick-bar-button-5",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-6",
      key_sequence = "6",
      linked_game_control = "quick-bar-button-6",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-7",
      key_sequence = "7",
      linked_game_control = "quick-bar-button-7",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-8",
      key_sequence = "8",
      linked_game_control = "quick-bar-button-8",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-9",
      key_sequence = "9",
      linked_game_control = "quick-bar-button-9",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-10",
      key_sequence = "0",
      linked_game_control = "quick-bar-button-10",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-1",
      key_sequence = "CONTROL + 1",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-2",
      key_sequence = "CONTROL + 2",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-3",
      key_sequence = "CONTROL + 3",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-4",
      key_sequence = "CONTROL + 4",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-5",
      key_sequence = "CONTROL + 5",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-6",
      key_sequence = "CONTROL + 6",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-7",
      key_sequence = "CONTROL + 7",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-8",
      key_sequence = "CONTROL + 8",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-9",
      key_sequence = "CONTROL + 9",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-quickbar-10",
      key_sequence = "CONTROL + 0",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-1",
      key_sequence = "SHIFT + 1",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-2",
      key_sequence = "SHIFT + 2",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-3",
      key_sequence = "SHIFT + 3",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-4",
      key_sequence = "SHIFT + 4",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-5",
      key_sequence = "SHIFT + 5",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-6",
      key_sequence = "SHIFT + 6",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-7",
      key_sequence = "SHIFT + 7",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-8",
      key_sequence = "SHIFT + 8",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-9",
      key_sequence = "SHIFT + 9",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quickbar-page-10",
      key_sequence = "SHIFT + 0",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "switch-menu-or-gun",
      key_sequence = "TAB",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "reverse-switch-menu-or-gun",
      key_sequence = "SHIFT + TAB",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "delete",
      key_sequence = "DELETE",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "mine-access-sounds",
      key_sequence = "X",
      linked_game_control = "mine",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "mine-tiles",
      key_sequence = "X",
      linked_game_control = "mine",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "flush-fluid",
      key_sequence = "X",
      linked_game_control = "mine",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "mine-area",
      key_sequence = "SHIFT + X",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cut-paste-tool-comment",
      key_sequence = "CONTROL + X",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "super-mine-area",
      key_sequence = "CONTROL + SHIFT + X",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "leftbracket-key-id",
      key_sequence = "LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "rightbracket-key-id",
      key_sequence = "RIGHTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "click-menu",
      key_sequence = "LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "click-menu-right",
      key_sequence = "RIGHTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "click-hand",
      key_sequence = "LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "click-hand-right",
      key_sequence = "RIGHTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "click-entity",
      key_sequence = "LEFTBRACKET",
      alternative_key_sequence = "mouse-button-1",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "open-circuit-menu",
      key_sequence = "N",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "repair-area",
      key_sequence = "CONTROL + SHIFT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "crafting-all",
      key_sequence = "SHIFT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "transfer-one-stack",
      key_sequence = "SHIFT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "equip-item",
      key_sequence = "SHIFT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "open-rail-builder",
      key_sequence = "SHIFT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quick-build-rail-left-turn",
      key_sequence = "ALT + LEFT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "quick-build-rail-right-turn",
      key_sequence = "ALT + RIGHT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "transfer-all-stacks",
      key_sequence = "CONTROL + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-alternate-build",
      key_sequence = "CONTROL + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "transfer-half-of-all-stacks",
      key_sequence = "CONTROL + RIGHTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "crafting-5",
      key_sequence = "RIGHTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "menu-clear-filter",
      key_sequence = "RIGHTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-entity-status",
      key_sequence = "RIGHTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-health-and-armor-stats",
      key_sequence = "G",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "rotate-building",
      key_sequence = "R",
      linked_game_control = "rotate",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "reverse-rotate-building",
      key_sequence = "SHIFT + R",
      linked_game_control = "reverse-rotate",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "flip-blueprint-horizontal-info",
      key_sequence = "F",
      --linked_game_control = "flip-blueprint-horizontal",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "flip-blueprint-vertical-info",
      key_sequence = "G",
      --linked_game_control = "flip-blueprint-vertical",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "inventory-read-weapons-data",
      key_sequence = "R",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "inventory-reload-weapons",
      key_sequence = "SHIFT + R",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "inventory-remove-all-weapons-and-ammo",
      key_sequence = "CONTROL + SHIFT + R",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "item-info",
      key_sequence = "Y",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "item-info-last-indexed",
      key_sequence = "SHIFT + Y",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "item-production-info",
      key_sequence = "U",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-pollution-info",
      key_sequence = "SHIFT + U",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-time-and-research-progress",
      key_sequence = "T",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "add-to-research-queue-start",
      key_sequence = "SHIFT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "add-to-research-queue-end",
      key_sequence = "CONTROL + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-research-queue",
      key_sequence = "ALT + Q",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "clear-research-queue",
      key_sequence = "CONTROL + SHIFT + ALT + Q",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "save-game-manually",
      key_sequence = "F1",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-walk",
      key_sequence = "ALT + W",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-build-lock",
      key_sequence = "CONTROL + B",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-vanilla-mode",
      key_sequence = "CONTROL + ALT + V",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-cursor-hiding",
      key_sequence = "CONTROL + ALT + C",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "clear-renders",
      key_sequence = "CONTROL + ALT + R",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "recalibrate-zoom",
      key_sequence = "CONTROL + END",
      alternative_key_sequence = "CONTROL + RCTRL",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-standard-zoom",
      key_sequence = "ALT + Z",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-closest-zoom",
      key_sequence = "SHIFT + ALT + Z",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-furthest-zoom",
      key_sequence = "CONTROL + ALT + Z",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "enable-mouse-update-entity-selection",
      key_sequence = "mouse-button-3",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "pipette-tool-info",
      key_sequence = "Q",
      --linked_game_control = "smart-pipette",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "copy-entity-settings-info",
      key_sequence = "SHIFT + RIGHTBRACKET",
      linked_game_control = "copy-entity-settings",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "paste-entity-settings-info",
      key_sequence = "SHIFT + LEFTBRACKET",
      linked_game_control = "paste-entity-settings",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fast-entity-transfer-info",
      key_sequence = "CONTROL + LEFTBRACKET",
      linked_game_control = "fast-entity-transfer",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fast-entity-split-info",
      key_sequence = "CONTROL + RIGHTBRACKET",
      linked_game_control = "fast-entity-split",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "drop-cursor-info",
      key_sequence = "Z",
      linked_game_control = "drop-cursor",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "read-hand",
      key_sequence = "SHIFT + Q",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "locate-hand-in-inventory",
      key_sequence = "CONTROL + Q",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "locate-hand-in-crafting-menu",
      key_sequence = "CONTROL + SHIFT + Q",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "menu-search-open",
      key_sequence = "CONTROL + F",
      linked_game_control = "focus-search",
      consuming = "game-only",
   },

   {
      type = "custom-input",
      name = "menu-search-get-next",
      key_sequence = "SHIFT + ENTER",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "menu-search-get-last",
      key_sequence = "CONTROL + ENTER",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "console",
      key_sequence = "GRAVE",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "open-warnings-menu",
      key_sequence = "P",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "nearest-damaged-ent-info",
      key_sequence = "SHIFT + P",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "open-fast-travel-menu",
      key_sequence = "V",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "alternative-menu-up",
      key_sequence = "UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "alternative-menu-down",
      key_sequence = "DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "alternative-menu-left",
      key_sequence = "LEFT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "alternative-menu-right",
      key_sequence = "RIGHT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-one-tile-north",
      key_sequence = "UP",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-one-tile-south",
      key_sequence = "DOWN",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-one-tile-east",
      key_sequence = "RIGHT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "cursor-one-tile-west",
      key_sequence = "LEFT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-splitter-input-priority-left",
      key_sequence = "SHIFT + ALT + LEFT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-splitter-input-priority-right",
      key_sequence = "SHIFT + ALT + RIGHT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-splitter-output-priority-left",
      key_sequence = "CONTROL + ALT + LEFT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-splitter-output-priority-right",
      key_sequence = "CONTROL + ALT + RIGHT",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-inventory-slot-filter",
      key_sequence = "ALT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "set-entity-filter-from-hand",
      key_sequence = "ALT + LEFTBRACKET",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "connect-rail-vehicles",
      key_sequence = "CONTROL + G",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "disconnect-rail-vehicles",
      key_sequence = "SHIFT + G",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "inventory-read-equipment-list",
      key_sequence = "SHIFT + G",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "inventory-remove-all-equipment-and-armor",
      key_sequence = "CONTROL + SHIFT + G",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "shoot-weapon-fa",
      key_sequence = "SPACE",
      --linked_game_control = "shoot-enemy",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "honk",
      key_sequence = "ALT + W",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "launch-rocket",
      key_sequence = "SPACE",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "toggle-auto-launch-with-cargo",
      key_sequence = "CONTROL + SPACE",
      alternative_key_sequence = "SHIFT + SPACE",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "help-read",
      key_sequence = "H",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "help-next",
      key_sequence = "CONTROL + H",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "help-back",
      key_sequence = "SHIFT + H",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "help-chapter-next",
      key_sequence = "CONTROL + ALT + H",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "help-chapter-back",
      key_sequence = "SHIFT + ALT + H",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "help-toggle-header-mode",
      key_sequence = "CONTROL + SHIFT + H",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "help-get-other",
      key_sequence = "ALT + H",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "debug-test-key",
      key_sequence = "ALT + G",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-zoom-out",
      key_sequence = "X",
      linked_game_control = "zoom-out",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-zoom-in",
      key_sequence = "X",
      linked_game_control = "zoom-in",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-debug-reset-zoom-2x",
      key_sequence = "X",
      linked_game_control = "debug-reset-zoom-2x",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-debug-reset-zoom",
      key_sequence = "X",
      linked_game_control = "debug-reset-zoom",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "logistic-request-read",
      key_sequence = "L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "logistic-request-increment-min",
      key_sequence = "SHIFT + L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "logistic-request-decrement-min",
      key_sequence = "CONTROL + L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "logistic-request-increment-max",
      key_sequence = "SHIFT + ALT + L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "logistic-request-decrement-max",
      key_sequence = "CONTROL + ALT + L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "logistic-request-clear",
      key_sequence = "CONTROL + SHIFT + ALT + L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "vanilla-toggle-personal-logistics-info",
      key_sequence = "ALT + L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "logistic-request-toggle-personal-logistics",
      key_sequence = "CONTROL + SHIFT + L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "send-selected-stack-to-logistic-trash",
      key_sequence = "O",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-pda-driving-assistant-info",
      key_sequence = "L",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-pda-cruise-control-info",
      key_sequence = "O",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-pda-cruise-control-set-speed-info",
      key_sequence = "CONTROL + O",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "access-config-version1-DO-NOT-EDIT",
      key_sequence = "A",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "access-config-version2-DO-NOT-EDIT",
      key_sequence = "A",
      consuming = "none",
   },

   {
      type = "custom-input",
      name = "fa-kk-start",
      key_sequence = "CONTROL + ALT + RIGHTBRACKET",
      consuming = "none",
   },

   {
      name = "fa-kk-cancel",
      type = "custom-input",
      linked_game_control = "toggle-driving",
      consuming = "none",
      key_sequence = "",
   },
})
