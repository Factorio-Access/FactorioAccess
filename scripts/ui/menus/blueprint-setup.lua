--[[
Blueprint setup parent UI.

Opens the blueprint area selector as a child, then either:
- Creates the blueprint directly (left bracket on second point)
- Opens the config UI for options (right bracket on second point)
]]

local StorageManager = require("scripts.storage-manager")
local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")

local mod = {}

---@class fa.ui.BlueprintSetup.StorageState
---@field parameters fa.ui.BlueprintSetup.Parameters?

---@type fa.ui.BlueprintSetup.StorageState
local blueprint_setup_storage = StorageManager.declare_storage_module("blueprint_setup", {
   parameters = nil,
})

---Compute the blueprint area from the box selection result
---@param result table The box selection result
---@return BoundingBox
local function compute_area(result)
   -- Create the area from the box. Careful! Positive y is south, and additionally if we grab the edges of the tiles
   -- sometimes this grabs entities outside the blueprint. SO, offset to the center of tiles.
   return {
      left_top = {
         x = math.floor(result.box.left_top.x) + 0.5,
         y = math.floor(result.box.left_top.y) + 0.5,
      },
      right_bottom = {
         x = math.ceil(result.box.right_bottom.x + 0.5) - 0.5,
         y = math.ceil(result.box.right_bottom.y + 0.5) - 0.5,
      },
   }
end

---@class fa.ui.BlueprintSetup.Parameters
---@field first_point? {x: number, y: number} Optional initial position
---@field intro_message? LocalisedString Custom intro message
---@field second_message? LocalisedString|false Custom second message
---@field permanent? boolean Whether to make the blueprint permanent

---@class fa.ui.BlueprintSetup : fa.ui.UiPanelBase
---@field ui_name fa.ui.UiName
local BlueprintSetup = {}
local BlueprintSetup_meta = { __index = BlueprintSetup }

---Open the blueprint setup - opens the area selector as a child
---@param pindex number
---@param parameters fa.ui.BlueprintSetup.Parameters
---@param controller fa.ui.RouterController
function BlueprintSetup:open(pindex, parameters, controller)
   -- Store parameters for later use in on_child_result
   blueprint_setup_storage[pindex].parameters = parameters

   -- Open the area selector as a child
   controller:open_child_ui(UiRouter.UI_NAMES.BLUEPRINT_AREA_SELECTOR, {
      first_point = parameters.first_point,
      intro_message = parameters.intro_message,
      second_message = parameters.second_message,
   })
end

---Handle result from child UIs (area selector or config)
---@param pindex number
---@param result any The result from the child UI
---@param context any The context
---@param controller fa.ui.RouterController
function BlueprintSetup:on_child_result(pindex, result, context, controller)
   -- Get stored parameters
   local params = blueprint_setup_storage[pindex].parameters or {}

   -- Check if this is a result from the config UI
   if result == "created" then
      -- Config UI created the blueprint, just close
      controller:close()
      return
   end

   -- This is a result from the area selector
   if not result or not result.box then
      -- Selection was cancelled
      controller:close()
      return
   end

   local p = game.get_player(pindex)
   if not p then
      controller:close()
      return
   end

   local blueprint = p.cursor_stack
   if not blueprint or not blueprint.valid_for_read or not blueprint.is_blueprint then
      Speech.speak(pindex, { "fa.planner-wrong-item" })
      controller:close()
      return
   end

   local area = compute_area(result)

   -- If second click was right bracket, open config UI
   if result.second_click and result.second_click.is_right_click then
      controller:open_child_ui(UiRouter.UI_NAMES.BLUEPRINT_SETUP_CONFIG, {
         area = area,
         permanent = params.permanent,
      })
      return
   end

   -- Left bracket - create blueprint directly with default options
   blueprint.create_blueprint({
      surface = p.surface,
      force = p.force,
      area = area,
   })

   -- If permanent param is set, mark the blueprint as permanent
   if params.permanent then p.cursor_stack_temporary = false end

   -- Provide feedback about what was captured
   local entity_count = blueprint.get_blueprint_entity_count()
   local tiles = blueprint.get_blueprint_tiles()
   local tile_count = tiles and #tiles or 0
   if entity_count > 0 then
      controller.message:fragment({ "fa.planner-blueprint-created", entity_count })
   elseif tile_count > 0 then
      controller.message:fragment({ "fa.planner-blueprint-created-tiles", tile_count })
   else
      controller.message:fragment({ "fa.planner-blueprint-created-empty" })
   end

   controller:close()
end

-- Create and register the UI instance
mod.blueprint_setup_ui = setmetatable({
   ui_name = UiRouter.UI_NAMES.BLUEPRINT_SETUP,
}, BlueprintSetup_meta)

UiRouter.register_ui(mod.blueprint_setup_ui)

return mod
