--[[
Logistic point descriptors mapping entity prototypes to their logistic member indices and metadata.

This provides centralized metadata for displaying and managing logistic points in the UI.
The structure is: prototype_type -> logistic_member_index -> metadata

Metadata fields:
- label: LocalisedString - The human-readable label for this logistic point type
- allows_active_toggle: boolean - Whether this point type supports the active toggle (default: true)
]]

local mod = {}

---Metadata for a logistic point type
---@class LogisticPointDescriptor
---@field label LocalisedString Human-readable label
---@field allows_active_toggle boolean Whether active toggle is supported

---@type table<string, table<defines.logistic_member_index, LogisticPointDescriptor>>
mod.DESCRIPTORS = {
   ["character"] = {
      [defines.logistic_member_index.character_requester] = {
         label = { "fa.logistics-point-character-requester" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.character_provider] = {
         label = { "fa.logistics-point-character-provider" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.character_storage] = {
         label = { "fa.logistics-point-character-storage" },
         allows_active_toggle = true,
      },
   },

   ["spider-vehicle"] = {
      [defines.logistic_member_index.spidertron_requester] = {
         label = { "fa.logistics-point-spidertron-requester" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.spidertron_provider] = {
         label = { "fa.logistics-point-spidertron-provider" },
         allows_active_toggle = true,
      },
   },

   ["car"] = {
      [defines.logistic_member_index.car_requester] = {
         label = { "fa.logistics-point-car-requester" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.car_provider] = {
         label = { "fa.logistics-point-car-provider" },
         allows_active_toggle = true,
      },
   },

   ["logistic-container"] = {
      [defines.logistic_member_index.logistic_container] = {
         label = { "fa.logistics-point-container" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.logistic_container_trash_provider] = {
         label = { "fa.logistics-point-container-trash-provider" },
         allows_active_toggle = true,
      },
   },

   ["roboport"] = {
      [defines.logistic_member_index.roboport_requester] = {
         label = { "fa.logistics-point-roboport-requester" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.roboport_provider] = {
         label = { "fa.logistics-point-roboport-provider" },
         allows_active_toggle = true,
      },
   },

   ["rocket-silo"] = {
      [defines.logistic_member_index.rocket_silo_requester] = {
         label = { "fa.logistics-point-rocket-silo-requester" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.rocket_silo_provider] = {
         label = { "fa.logistics-point-rocket-silo-provider" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.rocket_silo_trash_provider] = {
         label = { "fa.logistics-point-rocket-silo-trash-provider" },
         allows_active_toggle = true,
      },
   },

   ["space-platform-hub"] = {
      [defines.logistic_member_index.space_platform_hub_requester] = {
         label = { "fa.logistics-point-space-platform-requester" },
         allows_active_toggle = true,
      },
      [defines.logistic_member_index.space_platform_hub_provider] = {
         label = { "fa.logistics-point-space-platform-provider" },
         allows_active_toggle = true,
      },
   },
}

---Get descriptor for a specific logistic point
---@param entity_type string The entity type (e.g., "character", "spider-vehicle")
---@param member_index defines.logistic_member_index The logistic member index
---@return LogisticPointDescriptor?
function mod.get_descriptor(entity_type, member_index)
   local type_descriptors = mod.DESCRIPTORS[entity_type]
   if not type_descriptors then return nil end
   return type_descriptors[member_index]
end

---Get all descriptors for an entity type
---@param entity_type string The entity type
---@return table<defines.logistic_member_index, LogisticPointDescriptor>?
function mod.get_all_for_type(entity_type)
   return mod.DESCRIPTORS[entity_type]
end

return mod
