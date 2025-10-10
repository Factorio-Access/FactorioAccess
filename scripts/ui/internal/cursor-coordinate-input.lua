---UI for entering cursor coordinates.
---Opens a textbox directly and parses the result to move the cursor.
local UiRouter = require("scripts.ui.router")
local Speech = require("scripts.speech")
local Viewpoint = require("scripts.viewpoint")

local mod = {}

---@type fa.ui.UiPanelBase
local cursor_coordinate_ui = {
   ui_name = "cursor_coordinate_input",
   open = nil, -- Defined below
   on_child_result = nil, -- Defined below
}

---Open the cursor coordinate input
---@param pindex number
---@param parameters table
---@param controller fa.ui.RouterController
function cursor_coordinate_ui:open(pindex, parameters, controller)
   -- Open textbox for coordinate input with intro message
   controller:open_textbox("", "cursor_coordinate_input", { "fa.cursor-coordinate-enter" })
end

---Handle textbox result
---@param pindex number
---@param result any The coordinates entered by the user (nil if cancelled)
---@param context any The context (should be "cursor_coordinate_input")
---@param controller fa.ui.RouterController
function cursor_coordinate_ui:on_child_result(pindex, result, context, controller)
   -- If cancelled or empty, just close
   if not result or result == "" then
      controller:close()
      return
   end

   -- Parse the input - accept space or comma as separator
   -- Remove any extra whitespace and normalize commas to spaces
   local normalized = result:gsub(",", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

   -- Split into two parts
   local parts = {}
   for part in normalized:gmatch("[^ ]+") do
      table.insert(parts, part)
   end

   -- Must have exactly two parts
   if #parts ~= 2 then
      Speech.speak(pindex, { "fa.cursor-coordinate-invalid" })
      controller:close()
      return
   end

   -- Convert to numbers
   local x = tonumber(parts[1])
   local y = tonumber(parts[2])

   if not x or not y then
      Speech.speak(pindex, { "fa.cursor-coordinate-invalid" })
      controller:close()
      return
   end

   -- Set cursor position
   local viewpoint = Viewpoint.get_viewpoint(pindex)
   viewpoint:set_cursor_pos({ x = x, y = y })

   -- Announce success
   Speech.speak(pindex, { "fa.cursor-moved" })

   -- Close this UI
   controller:close()
end

-- Register the UI
UiRouter.register_ui(cursor_coordinate_ui)

return mod
