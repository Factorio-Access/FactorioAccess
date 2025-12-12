--[[
Combat data extraction.

This module is used both at data-final-fixes stage (to extract prototype data)
and at runtime (to access the computed data).

At data stage, call build_map() to extract and store weapon/ammo/enemy properties.
At runtime, call load_map() to get the precomputed data.
]]

local DataToRuntimeMap = require("scripts.data-to-runtime-map")
local Functools = require("scripts.functools")

local mod = {}

local MAP_NAME = "combat-data"

---@enum fa.AimingType
mod.AimingType = {
   ENTITY = "entity", -- Auto-aims at entities
   POSITION = "position", -- Fires at a position
   DIRECTION = "direction", -- Fires in a direction (no aiming)
}

---@class fa.AmmoData
---@field target_type fa.AimingType How the ammo is aimed
---@field min_range number? Hard minimum range (won't fire closer)
---@field max_range number Max firing range
---@field range_modifier number? Multiplier applied to gun's range (default 1)
---@field soft_min_range number? Effective minimum range before self-damage
---@field has_area_damage boolean Whether this ammo deals area damage
---@field area_radius number? Radius of area damage if applicable
---@field can_damage_self boolean Whether the player can damage themselves with this ammo
---@field force_condition string? The force condition on triggers ("enemy", "all", etc)

---@class fa.GunData
---@field attack_parameters_type string "projectile", "stream", "beam"
---@field min_range number? Hard minimum range
---@field max_range number Max firing range
---@field ammo_categories string[] Which ammo categories this gun accepts

---@class fa.CapsuleData
---@field action_type string "throw", "use-on-self", "equipment-remote", "destroy-cliffs", "artillery-remote"
---@field min_range number? Hard minimum range
---@field max_range number? Max range for thrown capsules
---@field soft_min_range number? Effective minimum range before self-damage
---@field has_area_damage boolean Whether this capsule deals area damage
---@field area_radius number? Radius of area damage
---@field can_damage_self boolean Whether the player can damage themselves
---@field heals_player boolean Whether this heals the player
---@field spawns_entity string? Entity spawned by this capsule (combat robots, etc.)

---@class fa.EnemyData
---@field entity_type string "unit", "turret", "unit-spawner", "spider-unit", "segmented-unit"
---@field max_health number Maximum health
---@field attack_range number? Attack range (nil for spawners)
---@field attack_damage number? Base damage per hit (nil for spawners)
---@field damage_type string? Type of damage dealt (nil for spawners)
---@field damage_modifier number? Multiplier on damage (from attack_parameters)
---@field attack_type string? "projectile", "stream", "beam" (nil for spawners)
---@field movement_speed number? Movement speed (nil for turrets/spawners)

---@class fa.CombatDataMap
---@field guns table<string, fa.GunData>
---@field ammo table<string, fa.AmmoData>
---@field capsules table<string, fa.CapsuleData>
---@field enemies table<string, fa.EnemyData>

---@class fa.TriggerAnalysis
---@field radius number?
---@field has_area boolean
---@field force string?
---@field total_damage number? Total damage from all damage effects
---@field damage_type string? Primary damage type

---Recursively search triggers for area damage, damage values, and compute the maximum radius
---@param triggers table[]?
---@param force_condition string?
---@return fa.TriggerAnalysis
local function analyze_triggers(triggers, force_condition)
   if not triggers then
      return { radius = nil, has_area = false, force = force_condition, total_damage = nil, damage_type = nil }
   end

   -- Handle single trigger vs array of triggers
   if triggers.type then triggers = { triggers } end

   local max_radius = nil
   local has_area = false
   local final_force = force_condition
   local total_damage = 0
   local primary_damage_type = nil

   for _, trigger in ipairs(triggers) do
      -- Check force condition
      if trigger.force then final_force = trigger.force end

      -- Check if this is an area trigger
      if trigger.type == "area" then
         has_area = true
         local r = trigger.radius or 0
         if not max_radius or r > max_radius then max_radius = r end
      end

      -- Check for nested-result which contains more actions
      if trigger.action_delivery then
         local deliveries = trigger.action_delivery
         if deliveries.type then deliveries = { deliveries } end

         for _, delivery in ipairs(deliveries) do
            -- Check target_effects for damage and nested triggers
            if delivery.target_effects then
               local effects = delivery.target_effects
               if effects.type then effects = { effects } end

               for _, effect in ipairs(effects) do
                  -- Extract damage from damage effects
                  if effect.type == "damage" and effect.damage then
                     local dmg = effect.damage.amount or 0
                     total_damage = total_damage + dmg
                     -- Track the first damage type as primary
                     if not primary_damage_type and effect.damage.type then primary_damage_type = effect.damage.type end
                  end

                  if effect.type == "nested-result" and effect.action then
                     -- Recurse into nested action
                     local nested = analyze_triggers(effect.action, final_force)
                     if nested.has_area then
                        has_area = true
                        if nested.radius and (not max_radius or nested.radius > max_radius) then
                           max_radius = nested.radius
                        end
                     end
                     if nested.force then final_force = nested.force end
                     if nested.total_damage then total_damage = total_damage + nested.total_damage end
                     if nested.damage_type and not primary_damage_type then primary_damage_type = nested.damage_type end
                  end
               end
            end
         end
      end
   end

   return {
      radius = max_radius,
      has_area = has_area,
      force = final_force,
      total_damage = total_damage > 0 and total_damage or nil,
      damage_type = primary_damage_type,
   }
end

---Check if triggers can damage the player themselves (not just "their team")
---@param force_condition string?
---@return boolean
local function can_damage_self(force_condition)
   -- nil defaults to damaging everything
   if not force_condition then return true end
   -- These conditions include the player's own force
   if force_condition == "all" then return true end
   if force_condition == "ally" then return true end
   if force_condition == "friend" then return true end
   if force_condition == "same" then return true end
   -- These exclude the player
   -- "enemy", "not-friend", "not-same"
   return false
end

---Analyze a smoke-with-trigger entity's action for area damage info
---@param smoke_name string
---@return fa.TriggerAnalysis
local function analyze_smoke_entity(smoke_name)
   local smoke_proto = data.raw["smoke-with-trigger"] and data.raw["smoke-with-trigger"][smoke_name]
   if not smoke_proto or not smoke_proto.action then
      return { radius = nil, has_area = false, force = nil, total_damage = nil, damage_type = nil }
   end
   return analyze_triggers(smoke_proto.action, nil)
end

---Search triggers for create-smoke effects and return the smoke entity name
---@param triggers table[]?
---@return string? smoke_entity_name
local function find_smoke_entity_in_triggers(triggers)
   if not triggers then return nil end

   -- Handle single trigger vs array
   if triggers.type then triggers = { triggers } end

   for _, trigger in ipairs(triggers) do
      if trigger.action_delivery then
         local deliveries = trigger.action_delivery
         if deliveries.type then deliveries = { deliveries } end

         for _, delivery in ipairs(deliveries) do
            if delivery.target_effects then
               local effects = delivery.target_effects
               if effects.type then effects = { effects } end

               for _, effect in ipairs(effects) do
                  if effect.type == "create-smoke" and effect.entity_name then return effect.entity_name end
               end
            end
         end
      end
   end
   return nil
end

---@class fa.AttackParamsData
---@field min_range number?
---@field max_range number
---@field attack_type string

---Extract attack parameters data
---@param attack_params table?
---@return fa.AttackParamsData
local function extract_attack_params(attack_params)
   if not attack_params then return { min_range = nil, max_range = 0, attack_type = "projectile" } end

   return {
      min_range = attack_params.min_range,
      max_range = attack_params.range or 0,
      attack_type = attack_params.type or "projectile",
   }
end

---Extract damage info from attack parameters
---@param attack_params table?
---@return number? damage, string? damage_type
local function extract_attack_damage(attack_params)
   if not attack_params then return nil, nil end

   local ammo_type = attack_params.ammo_type
   if not ammo_type then return nil, nil end

   local action = ammo_type.action
   if not action then return nil, nil end

   local analysis = analyze_triggers(action, nil)
   return analysis.total_damage, analysis.damage_type
end

---Process enemy entity prototypes
---@param entity_type string
---@param protos table
---@param enemies table
local function process_enemy_prototypes(entity_type, protos, enemies)
   for name, proto in pairs(protos or {}) do
      local attack_params = proto.attack_parameters
      local attack_damage, damage_type = extract_attack_damage(attack_params)

      enemies[name] = {
         entity_type = entity_type,
         max_health = proto.max_health or 0,
         attack_range = attack_params and attack_params.range or nil,
         attack_damage = attack_damage,
         damage_type = damage_type,
         damage_modifier = attack_params and attack_params.damage_modifier or nil,
         attack_type = attack_params and attack_params.type or nil,
         movement_speed = proto.speed or proto.movement_speed or nil,
      }
   end
end

---Build the combat data map in data stage
function mod.build_map()
   local combat_data = {
      guns = {},
      ammo = {},
      capsules = {},
      enemies = {},
   }

   -- Process all gun items
   for name, proto in pairs(data.raw["gun"] or {}) do
      local attack_params = proto.attack_parameters
      local params = extract_attack_params(attack_params)

      -- Get ammo categories
      local ammo_categories = {}
      if attack_params and attack_params.ammo_category then
         table.insert(ammo_categories, attack_params.ammo_category)
      elseif attack_params and attack_params.ammo_categories then
         for _, cat in ipairs(attack_params.ammo_categories) do
            table.insert(ammo_categories, cat)
         end
      end

      combat_data.guns[name] = {
         attack_parameters_type = params.attack_type,
         min_range = params.min_range,
         max_range = params.max_range,
         ammo_categories = ammo_categories,
      }
   end

   -- Process all ammo items
   for name, proto in pairs(data.raw["ammo"] or {}) do
      local ammo_type = proto.ammo_type

      -- ammo_type can be a single table or an array of AmmoTypes (with source_type fields)
      -- When it's an array, each entry has a source_type ("player", "turret", "vehicle", "default")
      -- We want the "player" entry since this mod is for player use, falling back to "default"
      if ammo_type then
         -- Detect array form: arrays have source_type on entries, single AmmoType does not
         if ammo_type[1] and ammo_type[1].source_type then
            local player_type = nil
            local default_type = nil
            for _, at in ipairs(ammo_type) do
               if at.source_type == "player" then
                  player_type = at
                  break
               elseif at.source_type == "default" then
                  default_type = at
               end
            end
            ammo_type = player_type or default_type or ammo_type[1]
         end

         local target_type = ammo_type.target_type or "entity"
         local range_modifier = ammo_type.range_modifier or 1
         local action = ammo_type.action

         -- Analyze triggers
         local analysis = analyze_triggers(action, nil)
         local area_radius = analysis.radius
         local has_area = analysis.has_area
         local force_cond = analysis.force

         -- Check if projectile has additional effects
         local projectile_name = nil
         if action then
            -- Handle single action vs array of actions
            local actions = action
            if action.type then actions = { action } end

            for _, trigger in ipairs(actions) do
               if trigger.action_delivery then
                  -- Handle single delivery vs array
                  local deliveries = trigger.action_delivery
                  if deliveries.type then deliveries = { deliveries } end

                  for _, delivery in ipairs(deliveries) do
                     if delivery.type == "projectile" and delivery.projectile then
                        projectile_name = delivery.projectile
                     end
                  end
               end
            end
         end

         -- Look up projectile prototype for additional area damage info
         if projectile_name then
            local proj_proto = data.raw["projectile"] and data.raw["projectile"][projectile_name]
            if proj_proto then
               -- Check both action and final_attack_result for explosions
               -- action is used for impact effects (like explosive rockets)
               -- final_attack_result is used for effects when projectile expires
               local proj_analysis = analyze_triggers(proj_proto.action, force_cond)
               if proj_analysis.has_area then
                  has_area = true
                  if proj_analysis.radius and (not area_radius or proj_analysis.radius > area_radius) then
                     area_radius = proj_analysis.radius
                  end
               end
               if proj_analysis.force then force_cond = proj_analysis.force end

               -- Also check final_attack_result
               local final_analysis = analyze_triggers(proj_proto.final_attack_result, force_cond)
               if final_analysis.has_area then
                  has_area = true
                  if final_analysis.radius and (not area_radius or final_analysis.radius > area_radius) then
                     area_radius = final_analysis.radius
                  end
               end
               if final_analysis.force then force_cond = final_analysis.force end

               -- Check if the projectile creates a smoke-with-trigger entity
               local smoke_name = find_smoke_entity_in_triggers(proj_proto.action)
               if smoke_name then
                  local smoke_analysis = analyze_smoke_entity(smoke_name)
                  if smoke_analysis.has_area then
                     has_area = true
                     if smoke_analysis.radius and (not area_radius or smoke_analysis.radius > area_radius) then
                        area_radius = smoke_analysis.radius
                     end
                  end
                  if smoke_analysis.force then force_cond = smoke_analysis.force end
               end
            end
         end

         -- Compute soft min range (if area damage, radius is the danger zone)
         local soft_min = nil
         if has_area and area_radius and can_damage_self(force_cond) then soft_min = area_radius end

         combat_data.ammo[name] = {
            target_type = target_type,
            min_range = ammo_type.min_range,
            max_range = ammo_type.range or 0,
            range_modifier = range_modifier,
            soft_min_range = soft_min,
            has_area_damage = has_area,
            area_radius = area_radius,
            can_damage_self = has_area and can_damage_self(force_cond),
            force_condition = force_cond,
         }
      end
   end

   -- Process all capsule items
   for name, proto in pairs(data.raw["capsule"] or {}) do
      local capsule_action = proto.capsule_action
      if capsule_action then
         local action_type = capsule_action.type
         local min_range = nil
         local max_range = nil
         local soft_min = nil
         local has_area = false
         local area_radius = nil
         local can_damage = false
         local heals = false
         local spawns = nil

         if action_type == "throw" then
            local attack_params = capsule_action.attack_parameters
            if attack_params then
               min_range = attack_params.min_range
               max_range = attack_params.range

               -- Analyze the ammo_type action for area damage
               local ammo_type = attack_params.ammo_type
               if ammo_type then
                  local action = ammo_type.action
                  local analysis = analyze_triggers(action, nil)
                  area_radius = analysis.radius
                  has_area = analysis.has_area
                  local force_cond = analysis.force

                  -- Check if projectile has additional effects (same as ammo processing)
                  local projectile_name = nil
                  if action then
                     local actions = action
                     if action.type then actions = { action } end

                     for _, trigger in ipairs(actions) do
                        if trigger.action_delivery then
                           local deliveries = trigger.action_delivery
                           if deliveries.type then deliveries = { deliveries } end

                           for _, delivery in ipairs(deliveries) do
                              if delivery.type == "projectile" and delivery.projectile then
                                 projectile_name = delivery.projectile
                              end
                              -- Check for spawned entities
                              if delivery.target_effects then
                                 local effects = delivery.target_effects
                                 if effects.type then effects = { effects } end
                                 for _, effect in ipairs(effects) do
                                    if effect.type == "create-entity" and effect.entity_name then
                                       spawns = effect.entity_name
                                    end
                                 end
                              end
                           end
                        end
                     end
                  end

                  -- Look up projectile prototype for area damage info
                  if projectile_name then
                     local proj_proto = data.raw["projectile"] and data.raw["projectile"][projectile_name]
                     if proj_proto then
                        local proj_analysis = analyze_triggers(proj_proto.action, force_cond)
                        if proj_analysis.has_area then
                           has_area = true
                           if proj_analysis.radius and (not area_radius or proj_analysis.radius > area_radius) then
                              area_radius = proj_analysis.radius
                           end
                        end
                        if proj_analysis.force then force_cond = proj_analysis.force end

                        -- Check if the projectile creates a smoke-with-trigger entity
                        local smoke_name = find_smoke_entity_in_triggers(proj_proto.action)
                        if smoke_name then
                           local smoke_analysis = analyze_smoke_entity(smoke_name)
                           if smoke_analysis.has_area then
                              has_area = true
                              if smoke_analysis.radius and (not area_radius or smoke_analysis.radius > area_radius) then
                                 area_radius = smoke_analysis.radius
                              end
                           end
                           if smoke_analysis.force then force_cond = smoke_analysis.force end
                        end
                     end
                  end

                  if has_area and area_radius and can_damage_self(force_cond) then
                     soft_min = area_radius
                     can_damage = true
                  end
               end
            end
         elseif action_type == "use-on-self" then
            -- These typically heal or buff
            local attack_params = capsule_action.attack_parameters
            if attack_params and attack_params.ammo_type then
               local action = attack_params.ammo_type.action
               if action then
                  for _, trigger in ipairs(action) do
                     if trigger.action_delivery then
                        for _, delivery in ipairs(trigger.action_delivery) do
                           if delivery.target_effects then
                              for _, effect in ipairs(delivery.target_effects) do
                                 if effect.type == "damage" then
                                    -- Negative damage = healing
                                    if effect.damage and effect.damage.amount and effect.damage.amount < 0 then
                                       heals = true
                                    end
                                 end
                              end
                           end
                        end
                     end
                  end
               end
            end
            -- Raw fish and similar items heal
            heals = true
         elseif action_type == "equipment-remote" then
            -- These activate equipment like discharge defense
         elseif action_type == "destroy-cliffs" then
            -- Cliff explosives
            has_area = true
            area_radius = capsule_action.radius or 1.5
            can_damage = false -- cliff explosives don't damage player
         elseif action_type == "artillery-remote" then
            -- Artillery targeting flare
         end

         combat_data.capsules[name] = {
            action_type = action_type,
            min_range = min_range,
            max_range = max_range,
            soft_min_range = soft_min,
            has_area_damage = has_area,
            area_radius = area_radius,
            can_damage_self = can_damage,
            heals_player = heals,
            spawns_entity = spawns,
         }
      end
   end

   -- Process enemy entity prototypes
   process_enemy_prototypes("unit", data.raw["unit"], combat_data.enemies)
   process_enemy_prototypes("turret", data.raw["turret"], combat_data.enemies)
   process_enemy_prototypes("unit-spawner", data.raw["unit-spawner"], combat_data.enemies)
   process_enemy_prototypes("spider-unit", data.raw["spider-unit"], combat_data.enemies)
   process_enemy_prototypes("segmented-unit", data.raw["segmented-unit"], combat_data.enemies)

   DataToRuntimeMap.build(MAP_NAME, combat_data)
end

---@type fun(): fa.CombatDataMap
local load_map_cached = Functools.cached(function()
   return DataToRuntimeMap.load(MAP_NAME)
end)

---Load the combat data map at runtime (memoized)
---@return fa.CombatDataMap
function mod.load_map()
   return load_map_cached()
end

---Get gun data by name
---@param name string
---@return fa.GunData?
function mod.get_gun_data(name)
   local map = mod.load_map()
   return map.guns[name]
end

---Get ammo data by name
---@param name string
---@return fa.AmmoData?
function mod.get_ammo_data(name)
   local map = mod.load_map()
   return map.ammo[name]
end

---Get capsule data by name
---@param name string
---@return fa.CapsuleData?
function mod.get_capsule_data(name)
   local map = mod.load_map()
   return map.capsules[name]
end

---Get enemy data by prototype name
---@param name string
---@return fa.EnemyData?
function mod.get_enemy_data(name)
   local map = mod.load_map()
   return map.enemies[name]
end

return mod
