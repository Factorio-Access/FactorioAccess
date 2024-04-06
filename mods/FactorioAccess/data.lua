--Data:

--Universal belt immunity:
data.raw.character.character.has_belt_immunity = true

--Create resource map node entities as aggregate entities
local resource_map_node = table.deepcopy(data.raw.container) 
resource_map_node.name = "map-node"
resource_map_node.type = "simple-entity-with-force"
--resource_map_node.inventory_size = 0

resource_map_node.collision_box = {{-0, -0}, {0, 0}}
resource_map_node.collision_mask = {}
resource_map_node.selection_box = nil
resource_map_node.order = "z"
resource_map_node.max_health = 2147483648
resource_map_node.picture = {
	filename = "__FactorioAccess__/Graphics/invisible.png",
	width = 1,
	height = 1,
	direction_count = 1
}

--Make selected vanilla objects not collide with players
--  Pipes
local pipe = data.raw.pipe.pipe
pipe.collision_mask = {"object-layer", "floor-layer", "water-tile"}
local pipe_to_ground = data.raw["pipe-to-ground"]["pipe-to-ground"]
pipe_to_ground.collision_mask = {"object-layer", "floor-layer", "water-tile"}

--  Small & medium electric poles
local small_electric_pole = data.raw["electric-pole"]["small-electric-pole"]
small_electric_pole.collision_mask = {"object-layer", "floor-layer", "water-tile"}
local medium_electric_pole = data.raw["electric-pole"]["medium-electric-pole"]
medium_electric_pole.collision_mask = {"object-layer", "floor-layer", "water-tile"}

--  Constant combinators (because of when they are placed to explain transport belts)
local constant_combinator = data.raw["constant-combinator"]["constant-combinator"]
constant_combinator.collision_mask = {"object-layer", "floor-layer", "water-tile"}

--  Inserters
local inserter = data.raw["inserter"]["inserter"]
inserter.collision_mask = {"object-layer", "floor-layer", "water-tile"}
local burner_inserter = data.raw["inserter"]["burner-inserter"]
burner_inserter.collision_mask = {"object-layer", "floor-layer", "water-tile"}
local fast_inserter = data.raw["inserter"]["fast-inserter"]
fast_inserter.collision_mask = {"object-layer", "floor-layer", "water-tile"}
local long_handed_inserter = data.raw["inserter"]["long-handed-inserter"]
long_handed_inserter.collision_mask = {"object-layer", "floor-layer", "water-tile"}
local stack_inserter = data.raw["inserter"]["stack-inserter"]
stack_inserter.collision_mask = {"object-layer", "floor-layer", "water-tile"}

--  Filter inserters
local filter_inserter = data.raw["inserter"]["filter-inserter"]
filter_inserter.collision_mask = {"object-layer", "floor-layer", "water-tile"}
local stack_filter_inserter = data.raw["inserter"]["stack-filter-inserter"]
stack_filter_inserter.collision_mask = {"object-layer", "floor-layer", "water-tile"}


--Add new radar type that does long distance scanning
local ar_tint = {r=0.5,g=0.5,b=0.5,a=0.9}
local access_radar = table.deepcopy(data.raw["radar"]["radar"])
access_radar.icons = {
  {
    icon = access_radar.icon,
    icon_size = access_radar.icon_size,
    tint = ar_tint
  }
}
--New building: This radar scans a new sector every 5 seconds instead of 33, and it refreshes its short range every 5 seconds (precisely fast enough) instead of 1 second, but the short range is smaller and the radar costs double the power.
access_radar.name = "access-radar"
access_radar.energy_usage = "600kW"  --Default: "300kW"
access_radar.energy_per_sector = "3MJ" --Default: "10MJ"
access_radar.energy_per_nearby_scan = "3MJ" --Default: "250kJ"
access_radar.max_distance_of_sector_revealed = 32 --Default: 14, now scans up to 1024 tiles away instead of 448
access_radar.max_distance_of_nearby_sector_revealed = 2 --Default: 3
access_radar.rotation_speed = 0.01 --Default: 0.01
access_radar.tint = ar_tint
access_radar.minable.result = "access-radar"
access_radar.pictures.layers[1].tint = ar_tint--grey
access_radar.pictures.layers[2].tint = ar_tint--grey

local access_radar_item = table.deepcopy(data.raw["item"]["radar"])
access_radar_item.name = "access-radar"
access_radar_item.place_result = "access-radar"
access_radar_item.icons = {
  {
    icon = access_radar_item.icon,
    icon_size = access_radar_item.icon_size,
    tint = ar_tint
  }
}

local access_radar_recipe = table.deepcopy(data.raw["recipe"]["radar"])
access_radar_recipe.enabled = true
access_radar_recipe.name = "access-radar"
access_radar_recipe.result = "access-radar"
access_radar_recipe.ingredients = {{"electronic-circuit", 10}, {"iron-gear-wheel", 10}, {"iron-plate", 20}}

data:extend{access_radar,access_radar_item}
data:extend{access_radar_item,access_radar_recipe}

--Map generation preset attempts
resource_def={richness = 4}

data.raw["map-gen-presets"].default["faccess-compass-valley"] = {
    order="_A",
    basic_settings={
        autoplace_controls = {
            coal = resource_def,
            ["copper-ore"] = resource_def,
            ["crude-oil"] = resource_def,
            ["iron-ore"] = resource_def,
            stone = resource_def,
            ["uranium-ore"] = resource_def
        },
        seed = 3814061204,
        starting_area = 4,
        peaceful_mode = true,
        cliff_settings = {
            name = "cliff",
            cliff_elevation_0 = 10,
            cliff_elevation_interval = 240,
            richness = 0.1666666716337204
        }
    },
    advanced_settings ={
        enemy_evolution = {
            enabled = true,
            time_factor = 0,
            destroy_factor = 0.006,
            pollution_factor = 1e-07
         },
         enemy_expansion ={
            enabled = false
         }
    }
}



data.raw["map-gen-presets"].default["faccess-enemies-off"] = {
    order="_B",
    basic_settings={
        autoplace_controls = {
            ["enemy-base"] = {frequency=0} 
        }
    }
}

data.raw["map-gen-presets"].default["faccess-peaceful"] = {
    order="_C",
    basic_settings={
        peaceful_mode = true,
    }
}

data:extend({
 resource_map_node,

{
   type = "sound",
   name = "alert-enemy-presence-high",
   filename = "__FactorioAccess__/Audio/alert-enemy-presence-high-zapsplat-trimmed-science_fiction_alarm_fast_high_pitched_warning_tone_emergency_003_60104.wav",
   volume = 0.4,
   preload = true
},

{
   type = "sound",
   name = "alert-enemy-presence-low",
   filename = "__FactorioAccess__/Audio/alert-enemy-presence-low-zapsplat-modified_multimedia_game_tone_short_bright_futuristic_beep_action_tone_002_59161.wav",
   volume = 0.4,
   preload = true
},

{
   type = "sound",
   name = "alert-structure-damaged",
   filename = "__FactorioAccess__/Audio/alert-structure-damaged-zapsplat-modified-emergency_alarm_003.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Open-Inventory-Sound",
   filename = "__core__/sound/gui-green-button.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Close-Inventory-Sound",
   filename = "__core__/sound/gui-green-confirm.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Change-Menu-Tab-Sound",
   filename = "__core__/sound/gui-switch.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "inventory-edge",
   filename = "__FactorioAccess__/Audio/inventory-edge-zapsplat_vehicles_car_roof_light_switch_click_002_80933.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Inventory-Move",
   filename = "__FactorioAccess__/Audio/inventory-move.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "inventory-wrap-around",
   filename = "__FactorioAccess__/Audio/inventory-wrap-around-zapsplat_leisure_toy_plastic_wind_up_003_13198.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "player-aim-locked",
   filename = "__FactorioAccess__/Audio/player-aim-locked-zapsplat_multimedia_game_beep_high_pitched_generic_002_25862.wav", 
   volume = 0.5,
   preload = true
},

{
   type = "sound",
   name = "player-bump-alert",
   filename = "__FactorioAccess__/Audio/player-bump-alert-zapsplat-trimmed_multimedia_game_sound_synth_digital_tone_beep_001_38533.wav", 
   volume = 0.75,
   preload = true
},

{
   type = "sound",
   name = "player-bump-stuck-alert",
   filename = "__FactorioAccess__/Audio/player-bump-stuck-alert-zapsplat_multimedia_game_sound_synth_digital_tone_beep_005_38537.wav", 
   volume = 0.75,
   preload = true
},

{
   type = "sound",
   name = "player-bump-slide",
   filename = "__FactorioAccess__/Audio/player-bump-slide-zapsplat_foley_footstep_boot_kick_gravel_stones_out_002.wav", 
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "player-bump-trip",
   filename = "__FactorioAccess__/Audio/player-bump-trip-zapsplat-trimmed_industrial_tool_pick_axe_single_hit_strike_wood_tree_trunk_001_103466.wav", 
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "player-crafting",
   filename = "__FactorioAccess__/Audio/player-crafting-zapsplat-modified_industrial_mechanical_wind_up_manual_001_86125.wav",
   volume = 0.25,
   preload = true
},

{
   type = "sound",
   name = "player-damaged-character",
   filename = "__FactorioAccess__/Audio/player-damaged-character-zapsplat-modified_multimedia_beep_harsh_synth_single_high_pitched_87498.wav",
   volume = 0.75,
   preload = true
},

{
   type = "sound",
   name = "player-damaged-shield",
   filename = "__FactorioAccess__/Audio/player-damaged-shield-zapsplat_multimedia_game_sound_sci_fi_futuristic_beep_action_tone_001_64989.wav",
   volume = 0.75,
   preload = true
},

{
   type = "sound",
   name = "player-mine",
   filename = "__FactorioAccess__/Audio/player-mine_02.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "player-teleported",
   filename = "__FactorioAccess__/Audio/player-teleported-zapsplat_science_fiction_computer_alarm_single_medium_ring_beep_fast_004_84296.wav",
   volume = 0.75,
   preload = true
},

{
   type = "sound",
   name = "player-turned",
   filename = "__FactorioAccess__/Audio/player-turned-1face_dir.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "player-walk",
   filename = "__FactorioAccess__/Audio/player-walk-zapsplat-little_robot_sound_factory_fantasy_Footstep_Dirt_001.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "Rotate-Hand-Sound",
   filename = "__core__/sound/gui-back.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "scanner-pulse",
   filename = "__FactorioAccess__/Audio/scanner-pulse-zapsplat_science_fiction_computer_alarm_single_medium_ring_beep_fast_001_84293.wav",
   volume = 0.3,
   preload = true
},

{
   type = "sound",
   name = "train-alert-high",
   filename = "__FactorioAccess__/Audio/train-alert-high-zapsplat-trimmed_science_fiction_alarm_warning_buzz_harsh_large_reverb_60111.wav",
   volume = 0.3,
   preload = true
},

{
   type = "sound",
   name = "train-alert-low",
   filename = "__FactorioAccess__/Audio/train-alert-low-zapsplat_multimedia_beep_digital_high_tech_electronic_001_87483.wav",
   volume = 0.3,
   preload = true
},

{
   type = "sound",
   name = "train-clack",
   filename = "__FactorioAccess__/Audio/train-clack-zapsplat-cut-transport_steam_train_arrive_at_station_with_tannoy_announcement.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "train-honk-short",
   filename = "__FactorioAccess__/Audio/train-honk-short-2x-GotLag.ogg",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "train-honk-long",
   filename = "__FactorioAccess__/Audio/train-honk-long-pixabay-modified-diesel-horn-02-98042.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "train-honk-low-long",
   filename = "__FactorioAccess__/Audio/train-honk-long-pixabay-modified-lower-diesel-horn-02-98042.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "car-honk",
   filename = "__FactorioAccess__/Audio/car-horn-zapsplat_transport_car_horn_single_beep_external_toyota_corolla_002_18246.wav",
   volume = 1,
   preload = true
},

{
   type = "sound",
   name = "tank-honk",
   filename = "__FactorioAccess__/Audio/tank-horn-zapsplat-Blastwave_FX_FireTruckHornHonk_SFXB.458.wav",
   volume = 1,
   preload = true
},

{
    type = "custom-input",
    name = "pause-game-fa",
    key_sequence = "ESCAPE",
    linked_game_control = "toggle-menu",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-up",
    key_sequence = "W",
    linked_game_control = "move-up",
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-down",
    key_sequence = "S",
    linked_game_control = "move-down",
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-left",
    key_sequence = "A",
    linked_game_control = "move-left",
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-right",
    key_sequence = "D",
    linked_game_control = "move-right",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-skip-north",
    key_sequence = "SHIFT + W", 
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-skip-south",
    key_sequence = "SHIFT + S", 
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-skip-west",
    key_sequence = "SHIFT + A", 
    consuming = "none"
},
{
    type = "custom-input",
    name = "cursor-skip-east",
    key_sequence = "SHIFT + D", 
    consuming = "none"
},

{
    type = "custom-input",
    name = "nudge-up",
    key_sequence = "CONTROL + SHIFT + W",
    consuming = "none"
},
{
    type = "custom-input",
    name = "nudge-down",
    key_sequence = "CONTROL + SHIFT + S",
    consuming = "none"
},
{
    type = "custom-input",
    name = "nudge-left",
    key_sequence = "CONTROL + SHIFT + A",
    consuming = "none"
},
{
    type = "custom-input",
    name = "nudge-right",
    key_sequence = "CONTROL + SHIFT + D",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-cursor-coords",
    key_sequence = "K",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-cursor-distance-and-direction",
    key_sequence = "SHIFT + K",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-cursor-distance-vector",
    key_sequence = "ALT + K",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-character-coords",
    key_sequence = "CONTROL + K",
    consuming = "none"
},

{
    type = "custom-input",
    name = "return-cursor-to-player",
    key_sequence = "J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "release-cursor",
    key_sequence = "CONTROL + J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-bookmark-save",
    key_sequence = "SHIFT + B",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-bookmark-load",
    key_sequence = "B",
    consuming = "none"
},

{
    type = "custom-input",
    name = "type-cursor-target",
    key_sequence = "ALT + T",
    consuming = "none"
},

{
    type = "custom-input",
    name = "teleport-to-cursor",
    key_sequence = "SHIFT + T",
    consuming = "none"
},

{
    type = "custom-input",
    name = "teleport-to-cursor-forced",
    key_sequence = "CONTROL + SHIFT + T",
    consuming = "none"
},

{
    type = "custom-input",
    name = "teleport-to-alert-forced",
    key_sequence = "CONTROL + SHIFT + P",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-cursor",
    key_sequence = "I",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-size-increment",
    key_sequence = "SHIFT + I",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-size-decrement",
    key_sequence = "CONTROL + I",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-inventory-bar-by-1",
    key_sequence = "PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-inventory-bar-by-5",
    key_sequence = "SHIFT + PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-inventory-bar-by-100",
    key_sequence = "CONTROL + PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-inventory-bar-by-1",
    key_sequence = "PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-inventory-bar-by-5",
    key_sequence = "SHIFT + PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-inventory-bar-by-100",
    key_sequence = "CONTROL + PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-train-wait-times-by-5",
    key_sequence = "PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "increase-train-wait-times-by-60",
    key_sequence = "CONTROL + PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-train-wait-times-by-5",
    key_sequence = "PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "decrease-train-wait-times-by-60",
    key_sequence = "CONTROL + PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-rail-structure-ahead",
    key_sequence = "SHIFT + J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-driving-structure-ahead",
    key_sequence = "J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-rail-structure-behind",
    key_sequence = "CONTROL + J",
    consuming = "none"
},

{
    type = "custom-input",
    name = "rescan",
    key_sequence = "END",
    alternative_key_sequence = "RCTRL",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-facing-direction",
    key_sequence = "SHIFT + END",
    alternative_key_sequence = "SHIFT + RCTRL",
    consuming = "none"
},

{
    type = "custom-input",
    name = "a-scan-list-main-up-key",
    key_sequence = "PAGEUP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "a-scan-list-main-down-key",
    key_sequence = "PAGEDOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-list-up",
    key_sequence = "PAGEUP",
    alternative_key_sequence = "UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-list-down",
    key_sequence = "PAGEDOWN",
    alternative_key_sequence = "DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-list-middle",
    key_sequence = "HOME",
    alternative_key_sequence = "RSHIFT",
    consuming = "none"
},
{
    type = "custom-input",
    name = "jump-to-scan",
    key_sequence = "CONTROL + HOME",
    alternative_key_sequence = "CONTROL + RSHIFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-category-up",
    key_sequence = "CONTROL + PAGEUP",
    alternative_key_sequence = "CONTROL + UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-category-down",
    key_sequence = "CONTROL + PAGEDOWN",
    alternative_key_sequence = "CONTROL + DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-sort-by-count",
    key_sequence = "SHIFT + N",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-sort-by-distance",
    key_sequence = "N",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-selection-up",
    key_sequence = "SHIFT + PAGEUP",
    alternative_key_sequence = "SHIFT + UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "scan-selection-down",
    key_sequence = "SHIFT + PAGEDOWN",
    alternative_key_sequence = "SHIFT + DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "repeat-last-spoken",
    key_sequence = "CONTROL + TAB",
    consuming = "none"
},

{
    type = "custom-input",
    name = "tile-cycle",
    key_sequence = "SHIFT + F",
    consuming = "none"
},

{
    type = "custom-input",
    name = "pickup-items-info",
    key_sequence = "F",
    linked_game_control = "pick-items",
    consuming = "none" 
},

{
    type = "custom-input",
    name = "open-inventory",
    key_sequence = "E",
    consuming = "none"
},

{
    type = "custom-input",
    name = "close-menu-access",
    key_sequence = "E",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-menu-name",
    key_sequence = "SHIFT + E",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-1",
    key_sequence = "1",
    linked_game_control = "quick-bar-button-1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-2",
    key_sequence = "2",
    linked_game_control = "quick-bar-button-2",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-3",
    key_sequence = "3",
    linked_game_control = "quick-bar-button-3",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-4",
    key_sequence = "4",
    linked_game_control = "quick-bar-button-4",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-5",
    key_sequence = "5",
    linked_game_control = "quick-bar-button-5",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-6",
    key_sequence = "6",
    linked_game_control = "quick-bar-button-6",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-7",
    key_sequence = "7",
    linked_game_control = "quick-bar-button-7",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-8",
    key_sequence = "8",
    linked_game_control = "quick-bar-button-8",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-9",
    key_sequence = "9",
    linked_game_control = "quick-bar-button-9",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-10",
    key_sequence = "0",
    linked_game_control = "quick-bar-button-10",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-1",
    key_sequence = "CONTROL + 1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-2",
    key_sequence = "CONTROL + 2",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-3",
    key_sequence = "CONTROL + 3",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-4",
    key_sequence = "CONTROL + 4",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-5",
    key_sequence = "CONTROL + 5",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-6",
    key_sequence = "CONTROL + 6",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-7",
    key_sequence = "CONTROL + 7",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-8",
    key_sequence = "CONTROL + 8",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-9",
    key_sequence = "CONTROL + 9",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-quickbar-10",
    key_sequence = "CONTROL + 0",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-1",
    key_sequence = "SHIFT + 1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-2",
    key_sequence = "SHIFT + 2",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-3",
    key_sequence = "SHIFT + 3",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-4",
    key_sequence = "SHIFT + 4",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-5",
    key_sequence = "SHIFT + 5",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-6",
    key_sequence = "SHIFT + 6",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-7",
    key_sequence = "SHIFT + 7",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-8",
    key_sequence = "SHIFT + 8",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-9",
    key_sequence = "SHIFT + 9",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quickbar-page-10",
    key_sequence = "SHIFT + 0",
    consuming = "none"
},

{
    type = "custom-input",
    name = "switch-menu-or-gun",
    key_sequence = "TAB",
    consuming = "none"
},

{
    type = "custom-input",
    name = "reverse-switch-menu-or-gun",
    key_sequence = "SHIFT + TAB",
    consuming = "none"
},

{
    type = "custom-input",
    name = "mine-access-sounds",
    key_sequence = "X",
    linked_game_control = "mine",
    consuming = "none"
},

{
    type = "custom-input",
    name = "mine-tiles",
    key_sequence = "X",
    linked_game_control = "mine",
    consuming = "none"
},

{
    type = "custom-input",
    name = "flush-fluid",
    key_sequence = "X",
    linked_game_control = "mine",
    consuming = "none"
},

{
    type = "custom-input",
    name = "mine-area",
    key_sequence = "SHIFT + X",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cut-paste-tool-comment",
    key_sequence = "CONTROL + X",
    consuming = "none"
},

{
    type = "custom-input",
    name = "leftbracket-key-id",
    key_sequence = "LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "rightbracket-key-id",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-menu",
    key_sequence = "LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-menu-right",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-hand",
    key_sequence = "LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-hand-right",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "click-entity",
    key_sequence = "LEFTBRACKET",
    alternative_key_sequence = "mouse-button-1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-circuit-menu",
    key_sequence = "N",
    consuming = "none"
},

{
    type = "custom-input",
    name = "repair-area",
    key_sequence = "CONTROL + SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "crafting-all",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "transfer-one-stack",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "equip-item",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-rail-builder",
    key_sequence = "SHIFT + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quick-build-rail-left-turn",
    key_sequence = "CONTROL + LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "quick-build-rail-right-turn",
    key_sequence = "CONTROL + RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "transfer-all-stacks",
    key_sequence = "CONTROL + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-alternate-build",
    key_sequence = "CONTROL + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "transfer-half-of-all-stacks",
    key_sequence = "CONTROL + RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "crafting-5",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "menu-clear-filter",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-entity-status",
    key_sequence = "RIGHTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "rotate-building",
    key_sequence = "R",
    linked_game_control = "rotate",
    consuming = "none"
},

{
    type = "custom-input",
    name = "reverse-rotate-building",
    key_sequence = "SHIFT + R",
    linked_game_control = "reverse-rotate",
    consuming = "none"
},

{
    type = "custom-input",
    name = "flip-blueprint-horizontal-info",
    key_sequence = "F",
    linked_game_control = "flip-blueprint-horizontal",
    consuming = "none"
},

{
    type = "custom-input",
    name = "flip-blueprint-vertical-info",
    key_sequence = "G",
    linked_game_control = "flip-blueprint-vertical",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-read-weapons-data",
    key_sequence = "R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-reload-weapons",
    key_sequence = "SHIFT + R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-remove-all-weapons-and-ammo",
    key_sequence = "CONTROL + SHIFT + R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "item-info",
    key_sequence = "Y",
    consuming = "none"
},

{
    type = "custom-input",
    name = "item-info-last-indexed",
    key_sequence = "SHIFT + Y",
    consuming = "none"
},

{
    type = "custom-input",
    name = "item-production-info",
    key_sequence = "U",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-time-and-research-progress",
    key_sequence = "T",
    consuming = "none"
},

{
    type = "custom-input",
    name = "save-game-manually",
    key_sequence = "F1",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-walk",
    key_sequence = "CONTROL + W",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-build-lock",
    key_sequence = "CONTROL + B",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-vanilla-mode",
    key_sequence = "CONTROL + ALT + V",
    consuming = "none"
},

{
    type = "custom-input",
    name = "toggle-cursor-hiding",
    key_sequence = "CONTROL + ALT + C",
    consuming = "none"
},

{
    type = "custom-input",
    name = "clear-renders",
    key_sequence = "CONTROL + ALT + R",
    consuming = "none"
},

{
    type = "custom-input",
    name = "recalibrate-zoom",
    key_sequence = "CONTROL + END",
    alternative_key_sequence = "CONTROL + RCTRL",
    consuming = "none"
},

{
    type = "custom-input",
    name = "enable-mouse-update-entity-selection",
    key_sequence = "mouse-button-3",
    consuming = "none"
},

{
    type = "custom-input",
    name = "pipette-tool-info",
    key_sequence = "Q",
    linked_game_control = "smart-pipette",
    consuming = "none"
},

{
    type = "custom-input",
    name = "copy-entity-settings-info",
    key_sequence = "SHIFT + RIGHTBRACKET",
    linked_game_control = "copy-entity-settings",
    consuming = "none"
},

{
    type = "custom-input",
    name = "paste-entity-settings-info",
    key_sequence = "SHIFT + LEFTBRACKET",
    linked_game_control = "paste-entity-settings",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fast-entity-transfer-info",
    key_sequence = "CONTROL + LEFTBRACKET",
    linked_game_control = "fast-entity-transfer",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fast-entity-split-info",
    key_sequence = "CONTROL + RIGHTBRACKET",
    linked_game_control = "fast-entity-split",
    consuming = "none"
},

{
    type = "custom-input",
    name = "drop-cursor-info",
    key_sequence = "Z",
    linked_game_control = "drop-cursor",
    consuming = "none"
},

{
    type = "custom-input",
    name = "read-hand",
    key_sequence = "SHIFT + Q",
    consuming = "none"
},

{
    type = "custom-input",
    name = "locate-hand-in-inventory",
    key_sequence = "CONTROL + Q",
    consuming = "none"
},

{
    type = "custom-input",
    name = "locate-hand-in-crafting-menu",
    key_sequence = "CONTROL + SHIFT + Q",
    consuming = "none"
},

{
    type = "custom-input",
    name = "menu-search-open",
    key_sequence = "CONTROL + F",
    linked_game_control = "focus-search",
    consuming = "game-only"
},

{
    type = "custom-input",
    name = "menu-search-get-next",
    key_sequence = "SHIFT + ENTER",
    consuming = "none"
},

{
    type = "custom-input",
    name = "menu-search-get-last",
    key_sequence = "CONTROL + ENTER",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-warnings-menu",
    key_sequence = "P",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-fast-travel-menu",
    key_sequence = "V",
    consuming = "none"
},

{
    type = "custom-input",
    name = "open-structure-travel-menu",
    key_sequence = "CONTROL + S",
    consuming = "none"
},

{
    type = "custom-input",
    name = "alternative-menu-up",
    key_sequence = "UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "alternative-menu-down",
    key_sequence = "DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "alternative-menu-left",
    key_sequence = "LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "alternative-menu-right",
    key_sequence = "RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-north",
    key_sequence = "UP",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-south",
    key_sequence = "DOWN",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-east",
    key_sequence = "RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "cursor-one-tile-west",
    key_sequence = "LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-input-priority-left",
    key_sequence = "SHIFT + LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-input-priority-right",
    key_sequence = "SHIFT + RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-output-priority-left",
    key_sequence = "CONTROL + LEFT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-splitter-output-priority-right",
    key_sequence = "CONTROL + RIGHT",
    consuming = "none"
},

{
    type = "custom-input",
    name = "set-entity-filter-from-hand",
    key_sequence = "CONTROL + LEFTBRACKET",
    consuming = "none"
},

{
    type = "custom-input",
    name = "connect-rail-vehicles",
    key_sequence = "G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "disconnect-rail-vehicles",
    key_sequence = "SHIFT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-read-armor-stats",
    key_sequence = "G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-read-equipment-list",
    key_sequence = "SHIFT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "inventory-remove-all-equipment-and-armor",
    key_sequence = "CONTROL + SHIFT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "shoot-weapon-fa",
    key_sequence = "SPACE",
    --linked_game_control = "shoot-enemy",
    consuming = "none"
},

{
    type = "custom-input",
    name = "honk",
    key_sequence = "V",
    consuming = "none"
},

{
    type = "custom-input",
    name = "launch-rocket",
    key_sequence = "SPACE",
    consuming = "none"
},

{
    type = "custom-input",
    name = "help-read",
    key_sequence = "H",
    consuming = "none"
},

{
    type = "custom-input",
    name = "help-next",
    key_sequence = "CONTROL + H",
    consuming = "none"
},

{
    type = "custom-input",
    name = "help-back",
    key_sequence = "SHIFT + H",
    consuming = "none"
},

{
    type = "custom-input",
    name = "help-chapter-next",
    key_sequence = "CONTROL + ALT + H",
    consuming = "none"
},

{
    type = "custom-input",
    name = "help-chapter-back",
    key_sequence = "SHIFT + ALT + H",
    consuming = "none"
},

{
    type = "custom-input",
    name = "help-toggle-header-mode",
    key_sequence = "CONTROL + SHIFT + H",
    consuming = "none"
},

{
    type = "custom-input",
    name = "help-get-other",
    key_sequence = "ALT + H",
    consuming = "none"
},

{
    type = "custom-input",
    name = "debug-test-key",
    key_sequence = "ALT + G",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-alt-zoom-in",
    key_sequence = "X",
    linked_game_control = "alt-zoom-in",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-alt-zoom-out",
    key_sequence = "X",
    linked_game_control = "alt-zoom-out",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-zoom-out",
    key_sequence = "X",
    linked_game_control = "zoom-out",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-zoom-in",
    key_sequence = "X",
    linked_game_control = "zoom-in",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-debug-reset-zoom-2x",
    key_sequence = "X",
    linked_game_control = "debug-reset-zoom-2x",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-debug-reset-zoom",
    key_sequence = "X",
    linked_game_control = "debug-reset-zoom",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-read",
    key_sequence = "L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-increment-min",
    key_sequence = "SHIFT + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-decrement-min",
    key_sequence = "CONTROL + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-increment-max",
    key_sequence = "SHIFT + ALT + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-decrement-max",
    key_sequence = "CONTROL + ALT + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "logistic-request-toggle-personal-logistics",
    key_sequence = "CONTROL + SHIFT + L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "send-selected-stack-to-logistic-trash",
    key_sequence = "O",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-pda-driving-assistant-info",
    key_sequence = "L",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-pda-cruise-control-info",
    key_sequence = "O",
    consuming = "none"
},

{
    type = "custom-input",
    name = "fa-pda-cruise-control-set-speed-info",
    key_sequence = "CONTROL + O",
    consuming = "none"
},

{
    type = "custom-input",
    name = "access-config-version1-DO-NOT-EDIT",
    key_sequence = "A",
    consuming = "none"
},

{
    type = "custom-input",
    name = "access-config-version2-DO-NOT-EDIT",
    key_sequence = "A",
    consuming = "none"
}

})

--*Additions below for removing tips and tricks to prevent screen clutter*
vanilla_tip_and_tricks_item_table=
{
   "introduction",
      "game-interaction",
      "show-info",
      --"e-confirm",
      "clear-cursor",
      "pipette",
      "stack-transfers",
      
      "entity-transfers",
      "z-dropping",
      "shoot-targeting",
      "bulk-crafting",
   
   
   "inserters",
      "burner-inserter-refueling",
      "long-handed-inserters",
      "move-between-labs",
      "insertion-limits",
      "limit-chests",
   
   
   "transport-belts",--in category "belt"
      "belt-lanes",
      "splitters",
      "splitter-filters",
      "underground-belts",
   
   
   "electric-network",
      "steam-power",
      "low-power",
      "electric-pole-connections",
      "connect-switch",
   
   
   "copy-entity-settings",--in category "copy-paste"
      "copy-paste-trains",
      "copy-paste-filters",
      "copy-paste-requester-chest",
      "copy-paste-spidertron",
   
   
   "drag-building",
      "drag-building-poles",
      "pole-dragging-coverage",
      "drag-building-underground-belts",
      "fast-belt-bending",
      "fast-obstacle-traversing",
   
   
   "trains",
      "rail-building",
      "train-stops",
      "rail-signals-basic",
      "rail-signals-advanced",
      "gate-over-rail",
      
      "pump-connection",
      "train-stop-same-name",
   
   
   "logistic-network",
      "personal-logistics",
      "construction-robots",
      "passive-provider-chest",
      "storage-chest",
      "requester-chest",
   
      "active-provider-chest",
      "buffer-chest",
   
   
   "ghost-building",
      "ghost-rail-planner",
      "copy-paste",
   
   
   "fast-replace",
      "fast-replace-direction",
      "fast-replace-belt-splitter",
      "fast-replace-belt-underground",
   
   --no category
      "rotating-assemblers",
      "circuit-network",
   
};

function remove_tip_and_tricks_item(inname)
   data.raw["tips-and-tricks-item"][inname]=nil;
   for _,item in pairs(data.raw["tips-and-tricks-item"]) do
      if(item.dependencies) then
         local backup=table.deepcopy(item.dependencies);
         item.dependencies={"e-confirm"};
         for _,str in pairs(backup) do
            if(str~=inname) then table.insert(item.dependencies,str); end
         end
      end
   end
end

data.raw["tips-and-tricks-item"]["introduction"].category="game-interaction";
data.raw["tips-and-tricks-item"]["introduction"].trigger=nil;

data.raw["tips-and-tricks-item"]["show-info"].starting_status="unlocked";
data.raw["tips-and-tricks-item"]["show-info"].dependencies=nil;

data.raw["tips-and-tricks-item"]["e-confirm"].starting_status="unlocked";
data.raw["tips-and-tricks-item"]["e-confirm"].trigger=nil;
data.raw["tips-and-tricks-item"]["e-confirm"].skip_trigger={type="use-confirm"};--**nil
data.raw["tips-and-tricks-item"]["e-confirm"].dependencies=nil;


for _,item in pairs(vanilla_tip_and_tricks_item_table) do
   remove_tip_and_tricks_item(item);
end
--*Additions above for removing tips and tricks*