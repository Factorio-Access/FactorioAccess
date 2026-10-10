--Here: Functions related to ghosts, blueprints and blueprint books
--Does not include event handlers

local FaUtils = require("scripts.fa-utils")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local MessageBuilder = Speech.MessageBuilder

local mod = {}

--todo cleanup blueprint calls in control.lua so that blueprint data editing calls happen only within this module

function mod.get_blueprint_label(stack)
   if stack.is_blueprint_book then
      -- For blueprint books, get the label of the active blueprint
      local book_inv = stack.get_inventory(defines.inventory.item_main)
      if book_inv and stack.active_index then
         local active_bp = book_inv[stack.active_index]
         if active_bp and active_bp.valid_for_read then return active_bp.label or "no name" end
      end
      return "no name"
   elseif stack.is_blueprint then
      return stack.label or "no name"
   end
   return "no name"
end

function mod.get_bp_data_for_edit(stack)
   return helpers.json_to_table(assert(helpers.decode_string(string.sub(stack.export_stack(), 2))))
end

--Works for blueprints and also books too
function mod.set_stack_bp_from_data(stack, bp_data)
   stack.import_stack("0" .. helpers.encode_string(helpers.table_to_json(bp_data)))
end

--Export and import the same blueprint so that its parameters reset, e.g. rotation.
function mod.refresh_blueprint_in_hand(pindex)
   local p = game.get_player(pindex)
   if p.cursor_stack.is_blueprint_setup() == false then return end
   local bp_data = mod.get_bp_data_for_edit(p.cursor_stack)
   mod.set_stack_bp_from_data(p.cursor_stack, bp_data)
end

--Basic info for when the blueprint item is read.
function mod.get_blueprint_info(stack, in_hand, pindex)
   --Not a blueprint
   if stack.is_blueprint == false then return "" end
   --Empty blueprint
   if not stack.is_blueprint_setup() then return { "fa.blueprints-empty" } end

   local message = MessageBuilder.new()

   --Get name
   local name = mod.get_blueprint_label(stack)
   if name == nil then name = "" end

   --Add intro
   if in_hand then
      message:fragment({ "fa.blueprints-name-in-hand-features", name })
   else
      message:fragment({ "fa.blueprints-name-features", name })
   end

   --Use icons as extra info (in case it is not named)
   local icons = stack.preview_icons
   if icons == nil or #icons == 0 then
      message:fragment({ "fa.blueprints-no-details" })
      return message:build()
   end

   for i, signal in ipairs(icons) do
      if signal.index > 1 then message:fragment({ "fa.blueprints-and" }) end

      if signal.signal.name ~= nil then
         local proto = FaUtils.find_prototype(signal.signal.name)
         if proto then
            message:fragment(Localising.get_localised_name_with_fallback(proto))
         else
            message:fragment(signal.signal.name)
         end
      else
         message:fragment({ "fa.blueprints-unknown-icon" })
      end
   end

   message:fragment({ "fa.blueprints-entities-total", tostring(stack.get_blueprint_entity_count()) })

   return message:build()
end

--Basic info for when the blueprint book item is read (using inventory API)
function mod.get_blueprint_book_info(stack, in_hand)
   if not stack or not stack.is_blueprint_book then return "" end

   local label = stack.label or "unnamed book"
   local book_inv = stack.get_inventory(defines.inventory.item_main)
   local item_count = book_inv and #book_inv or 0

   local result = { "" }
   if in_hand then
      table.insert(result, { "fa.blueprints-book-label-in-hand", label })
   else
      table.insert(result, { "fa.blueprints-book-label", label })
   end
   table.insert(result, ", ")
   table.insert(result, { "fa.blueprints-with-items", tostring(item_count) })

   return result
end

return mod
