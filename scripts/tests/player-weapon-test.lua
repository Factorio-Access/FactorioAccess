--- Tests for player-weapon module

local TestRegistry = require("scripts.test-registry")
local describe, it = TestRegistry.describe, TestRegistry.it
local PlayerWeapon = require("scripts.combat.player-weapon")
local CombatData = require("scripts.combat.combat-data")

local AimingType = PlayerWeapon.AimingType

describe("Weapon Ammo Utils", function()
   describe("Prototype Data Access", function()
      it("should have gun data for pistol", function(ctx)
         ctx:init(function()
            local gun_data = CombatData.get_gun_data("pistol")
            ctx:assert_not_nil(gun_data, "Pistol gun data should exist")
            ctx:assert(gun_data.max_range > 0, "Pistol should have positive max range")
         end)
      end)

      it("should have ammo data for firearm-magazine", function(ctx)
         ctx:init(function()
            local ammo_data = CombatData.get_ammo_data("firearm-magazine")
            ctx:assert_not_nil(ammo_data, "Firearm magazine ammo data should exist")
            ctx:assert_equals(AimingType.ENTITY, ammo_data.target_type, "Firearm magazine should auto-aim at entities")
         end)
      end)

      it("should have ammo data for rocket", function(ctx)
         ctx:init(function()
            local ammo_data = CombatData.get_ammo_data("rocket")
            ctx:assert_not_nil(ammo_data, "Rocket ammo data should exist")
            -- Rockets in vanilla Factorio default to "entity" (auto-aim)
            -- They don't explicitly set target_type, so it defaults to "entity"
            ctx:assert_equals(AimingType.ENTITY, ammo_data.target_type, "Rockets should auto-aim at entities")
         end)
      end)

      it("should detect explosive rocket as dangerous", function(ctx)
         ctx:init(function()
            local ammo_data = CombatData.get_ammo_data("explosive-rocket")
            ctx:assert_not_nil(ammo_data, "Explosive rocket ammo data should exist")
            ctx:assert(ammo_data.has_area_damage, "Explosive rockets should have area damage")
            ctx:assert(ammo_data.can_damage_self, "Explosive rockets can damage self")
            ctx:assert(
               ammo_data.soft_min_range and ammo_data.soft_min_range > 0,
               "Explosive rockets should have soft min range"
            )
            ctx:assert_equals(6.5, ammo_data.area_radius, "Explosive rockets should have 6.5 tile blast radius")
         end)
      end)

      it("should have capsule data for grenade", function(ctx)
         ctx:init(function()
            local capsule_data = CombatData.get_capsule_data("grenade")
            ctx:assert_not_nil(capsule_data, "Grenade capsule data should exist")
            -- Debug output
            print("Grenade capsule data:")
            print("  action_type=" .. tostring(capsule_data.action_type))
            print("  has_area_damage=" .. tostring(capsule_data.has_area_damage))
            print("  area_radius=" .. tostring(capsule_data.area_radius))
            print("  can_damage_self=" .. tostring(capsule_data.can_damage_self))
            ctx:assert_equals("throw", capsule_data.action_type, "Grenades should be thrown")
         end)
      end)

      it("should detect raw-fish as healing", function(ctx)
         ctx:init(function()
            local capsule_data = CombatData.get_capsule_data("raw-fish")
            ctx:assert_not_nil(capsule_data, "Raw fish capsule data should exist")
            ctx:assert_equals("use-on-self", capsule_data.action_type, "Raw fish should be use-on-self")
            ctx:assert(capsule_data.heals_player, "Raw fish should heal the player")
         end)
      end)
   end)

   describe("Player Weapon Detection", function()
      it("should detect equipped pistol and ammo", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            -- Give the player a pistol and ammo
            player.insert({ name = "pistol", count = 1 })
            player.insert({ name = "firearm-magazine", count = 10 })
         end)

         ctx:at_tick(5, function()
            local gun_name = PlayerWeapon.get_selected_gun(1)
            local ammo_name = PlayerWeapon.get_selected_ammo(1)

            ctx:assert_equals("pistol", gun_name, "Should detect pistol as selected gun")
            ctx:assert_equals("firearm-magazine", ammo_name, "Should detect firearm-magazine as selected ammo")
         end)
      end)

      it("should return correct max range for pistol", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            player.clear_items_inside()
            player.insert({ name = "pistol", count = 1 })
            player.insert({ name = "firearm-magazine", count = 10 })
         end)

         ctx:at_tick(5, function()
            local max_range = PlayerWeapon.get_max_range(1)
            ctx:assert_not_nil(max_range, "Should have a max range")
            ctx:assert(max_range > 0, "Max range should be positive")
            print("Pistol max range: " .. tostring(max_range))
         end)
      end)

      it("should detect auto-aim for pistol+magazine", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            player.clear_items_inside()
            player.insert({ name = "pistol", count = 1 })
            player.insert({ name = "firearm-magazine", count = 10 })
         end)

         ctx:at_tick(5, function()
            local aiming_type = PlayerWeapon.get_aiming_type(1)
            local auto_aims = PlayerWeapon.does_auto_aim(1)

            ctx:assert_equals(AimingType.ENTITY, aiming_type, "Pistol+magazine should aim at entities")
            ctx:assert(auto_aims, "Pistol+magazine should auto-aim")
         end)
      end)

      it("should not detect player damage for regular bullets", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            player.clear_items_inside()
            player.insert({ name = "pistol", count = 1 })
            player.insert({ name = "firearm-magazine", count = 10 })
         end)

         ctx:at_tick(5, function()
            local can_damage = PlayerWeapon.can_damage_self(1)
            ctx:assert_equals(false, can_damage, "Regular bullets should not damage self")
         end)
      end)
   end)

   describe("Rocket Launcher Tests", function()
      it("should detect rocket launcher properties", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            player.clear_items_inside()
            player.insert({ name = "rocket-launcher", count = 1 })
            player.insert({ name = "rocket", count = 10 })
         end)

         ctx:at_tick(5, function()
            local gun_name = PlayerWeapon.get_selected_gun(1)
            local ammo_name = PlayerWeapon.get_selected_ammo(1)
            local aiming_type = PlayerWeapon.get_aiming_type(1)

            ctx:assert_equals("rocket-launcher", gun_name, "Should detect rocket-launcher")
            ctx:assert_equals("rocket", ammo_name, "Should detect rocket ammo")
            -- Rockets in vanilla default to ENTITY (auto-aim) - they don't specify target_type
            ctx:assert_equals(AimingType.ENTITY, aiming_type, "Rockets should auto-aim at entities")
         end)
      end)

      it("should detect explosive rocket danger", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            player.clear_items_inside()
            player.insert({ name = "rocket-launcher", count = 1 })
            player.insert({ name = "explosive-rocket", count = 10 })
         end)

         ctx:at_tick(5, function()
            local can_damage = PlayerWeapon.can_damage_self(1)
            local soft_min = PlayerWeapon.get_soft_min_range(1)
            local area_radius = PlayerWeapon.get_area_damage_radius(1)

            ctx:assert(can_damage, "Explosive rockets should be able to damage self")
            ctx:assert_not_nil(soft_min, "Explosive rockets should have soft min range")
            ctx:assert_not_nil(area_radius, "Explosive rockets should have area damage radius")
            ctx:assert_equals(6.5, area_radius, "Explosive rockets should have 6.5 tile blast radius")
         end)
      end)
   end)

   describe("Capsule Detection", function()
      it("should detect grenade in cursor as weapon capsule", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            player.clear_items_inside()
            player.cursor_stack.set_stack({ name = "grenade", count = 5 })
         end)

         ctx:at_tick(5, function()
            local is_weapon, name = PlayerWeapon.is_holding_weapon_capsule(1)
            ctx:assert(is_weapon, "Grenade should be detected as weapon capsule")
            ctx:assert_equals("grenade", name, "Should identify grenade by name")
         end)

         ctx:at_tick(10, function()
            -- Cleanup
            player.cursor_stack.clear()
         end)
      end)

      it("should get grenade properties", function(ctx)
         ctx:init(function()
            local max_range = PlayerWeapon.get_max_range_from_capsule("grenade")
            local soft_min = PlayerWeapon.get_soft_min_range_from_capsule("grenade")
            local area_radius = PlayerWeapon.get_area_damage_radius_from_capsule("grenade")
            local can_damage = PlayerWeapon.can_damage_self_from_capsule("grenade")

            ctx:assert_not_nil(max_range, "Grenade should have max range")
            ctx:assert(max_range > 0, "Grenade max range should be positive")
            ctx:assert(can_damage, "Grenade can damage self")
            print("Grenade max range: " .. tostring(max_range))
            print("Grenade soft min range: " .. tostring(soft_min))
            print("Grenade area radius: " .. tostring(area_radius))
         end)
      end)

      it("should detect raw fish as healing not weapon", function(ctx)
         local player

         ctx:init(function()
            player = game.get_player(1)
            player.cursor_stack.set_stack({ name = "raw-fish", count = 5 })
         end)

         ctx:at_tick(5, function()
            local is_weapon, name = PlayerWeapon.is_holding_weapon_capsule(1)
            -- Raw fish is use-on-self, not thrown, so may not be considered "weapon-like"
            -- depending on our definition
            local heals = PlayerWeapon.capsule_heals_player("raw-fish")
            ctx:assert(heals, "Raw fish should heal player")
            print("Raw fish is_weapon_capsule: " .. tostring(is_weapon))
         end)

         ctx:at_tick(10, function()
            player.cursor_stack.clear()
         end)
      end)

      it("should detect poison capsule area damage from smoke entity", function(ctx)
         ctx:init(function()
            local capsule_data = CombatData.get_capsule_data("poison-capsule")
            ctx:assert_not_nil(capsule_data, "Poison capsule data should exist")
            ctx:assert_equals("throw", capsule_data.action_type, "Poison capsule should be thrown")
            ctx:assert(capsule_data.has_area_damage, "Poison capsule should have area damage")
            ctx:assert_equals(
               11,
               capsule_data.area_radius,
               "Poison capsule should have 11 tile radius from smoke cloud"
            )
            ctx:assert(capsule_data.can_damage_self, "Poison capsule can damage self (player breathes air)")
            ctx:assert(
               capsule_data.soft_min_range and capsule_data.soft_min_range > 0,
               "Poison capsule should have soft min range"
            )
            print("Poison capsule data:")
            print("  has_area_damage=" .. tostring(capsule_data.has_area_damage))
            print("  area_radius=" .. tostring(capsule_data.area_radius))
            print("  can_damage_self=" .. tostring(capsule_data.can_damage_self))
            print("  soft_min_range=" .. tostring(capsule_data.soft_min_range))
         end)
      end)

      it("should detect slowdown capsule does not damage self", function(ctx)
         ctx:init(function()
            local capsule_data = CombatData.get_capsule_data("slowdown-capsule")
            ctx:assert_not_nil(capsule_data, "Slowdown capsule data should exist")
            ctx:assert_equals("throw", capsule_data.action_type, "Slowdown capsule should be thrown")
            -- Slowdown capsule has force="enemy" so it won't damage the player
            ctx:assert_equals(false, capsule_data.can_damage_self, "Slowdown capsule should not damage self")
            print("Slowdown capsule data:")
            print("  has_area_damage=" .. tostring(capsule_data.has_area_damage))
            print("  can_damage_self=" .. tostring(capsule_data.can_damage_self))
         end)
      end)
   end)

   describe("Prototype-only Functions", function()
      it("should get max range from gun prototype", function(ctx)
         ctx:init(function()
            local pistol_range = PlayerWeapon.get_max_range_from_prototype("pistol")
            local rocket_range = PlayerWeapon.get_max_range_from_prototype("rocket-launcher")
            local smg_range = PlayerWeapon.get_max_range_from_prototype("submachine-gun")

            ctx:assert_not_nil(pistol_range, "Pistol should have range")
            ctx:assert_not_nil(rocket_range, "Rocket launcher should have range")
            ctx:assert_not_nil(smg_range, "SMG should have range")

            print("Pistol range: " .. tostring(pistol_range))
            print("Rocket launcher range: " .. tostring(rocket_range))
            print("SMG range: " .. tostring(smg_range))
         end)
      end)

      it("should get aiming type from ammo prototype", function(ctx)
         ctx:init(function()
            local bullet_aim = PlayerWeapon.get_aiming_type_from_prototype("firearm-magazine")
            local rocket_aim = PlayerWeapon.get_aiming_type_from_prototype("rocket")
            local shotgun_aim = PlayerWeapon.get_aiming_type_from_prototype("shotgun-shell")

            ctx:assert_equals(AimingType.ENTITY, bullet_aim, "Bullets should aim at entities")
            -- Rockets default to ENTITY (auto-aim) in vanilla - no explicit target_type
            ctx:assert_equals(AimingType.ENTITY, rocket_aim, "Rockets should auto-aim at entities")
            -- Shotgun shells explicitly set target_type = DIRECTION
            ctx:assert_equals(AimingType.DIRECTION, shotgun_aim, "Shotgun shells should fire in direction")
         end)
      end)

      it("should get capsule action types", function(ctx)
         ctx:init(function()
            local grenade_action = PlayerWeapon.get_capsule_action_type("grenade")
            local fish_action = PlayerWeapon.get_capsule_action_type("raw-fish")
            local cliff_action = PlayerWeapon.get_capsule_action_type("cliff-explosives")

            ctx:assert_equals("throw", grenade_action, "Grenade should be throw")
            ctx:assert_equals("use-on-self", fish_action, "Fish should be use-on-self")
            ctx:assert_equals("destroy-cliffs", cliff_action, "Cliff explosives should be destroy-cliffs")
         end)
      end)
   end)

   describe("Enemy Data Extraction", function()
      it("should have data for small-biter", function(ctx)
         ctx:init(function()
            local enemy = CombatData.get_enemy_data("small-biter")
            ctx:assert_not_nil(enemy, "Small biter data should exist")
            ctx:assert_equals("unit", enemy.entity_type, "Small biter should be a unit")
            ctx:assert_equals(15, enemy.max_health, "Small biter should have 15 health")
            ctx:assert_equals(7, enemy.attack_damage, "Small biter should deal 7 damage")
            ctx:assert_equals("physical", enemy.damage_type, "Small biter should deal physical damage")
            ctx:assert(enemy.movement_speed > 0, "Small biter should have movement speed")
         end)
      end)

      it("should have data for behemoth-biter", function(ctx)
         ctx:init(function()
            local enemy = CombatData.get_enemy_data("behemoth-biter")
            ctx:assert_not_nil(enemy, "Behemoth biter data should exist")
            ctx:assert_equals("unit", enemy.entity_type, "Behemoth biter should be a unit")
            ctx:assert_equals(3000, enemy.max_health, "Behemoth biter should have 3000 health")
            ctx:assert_equals(90, enemy.attack_damage, "Behemoth biter should deal 90 damage")
         end)
      end)

      it("should have data for small-spitter", function(ctx)
         ctx:init(function()
            local enemy = CombatData.get_enemy_data("small-spitter")
            ctx:assert_not_nil(enemy, "Small spitter data should exist")
            ctx:assert_equals("unit", enemy.entity_type, "Small spitter should be a unit")
            ctx:assert(enemy.attack_range and enemy.attack_range > 5, "Small spitter should have ranged attack")
         end)
      end)

      it("should have data for small-worm-turret", function(ctx)
         ctx:init(function()
            local enemy = CombatData.get_enemy_data("small-worm-turret")
            ctx:assert_not_nil(enemy, "Small worm data should exist")
            ctx:assert_equals("turret", enemy.entity_type, "Small worm should be a turret")
            ctx:assert_equals(200, enemy.max_health, "Small worm should have 200 health")
            ctx:assert(enemy.attack_range and enemy.attack_range > 20, "Small worm should have long range")
            ctx:assert_nil(enemy.movement_speed, "Worm turret should not have movement speed")
         end)
      end)

      it("should have data for biter-spawner", function(ctx)
         ctx:init(function()
            local enemy = CombatData.get_enemy_data("biter-spawner")
            ctx:assert_not_nil(enemy, "Biter spawner data should exist")
            ctx:assert_equals("unit-spawner", enemy.entity_type, "Biter spawner should be a unit-spawner")
            ctx:assert_equals(350, enemy.max_health, "Biter spawner should have 350 health")
            ctx:assert_nil(enemy.attack_damage, "Spawner should not have attack damage")
         end)
      end)

      it("should have increasing damage across biter grades", function(ctx)
         ctx:init(function()
            local small = CombatData.get_enemy_data("small-biter")
            local medium = CombatData.get_enemy_data("medium-biter")
            local big = CombatData.get_enemy_data("big-biter")
            local behemoth = CombatData.get_enemy_data("behemoth-biter")

            -- Damage should increase with grade
            ctx:assert(small.attack_damage < medium.attack_damage, "Small should deal less damage than medium")
            ctx:assert(medium.attack_damage < big.attack_damage, "Medium should deal less damage than big")
            ctx:assert(big.attack_damage < behemoth.attack_damage, "Big should deal less damage than behemoth")
         end)
      end)
   end)
end)
