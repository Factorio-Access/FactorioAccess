local Blueprints = require("scripts.blueprints")
local Functools = require("scripts.functools")
local Localising = require("scripts.localising")
local Speech = require("scripts.speech")
local UiRouter = require("scripts.ui.router")
local TabList = require("scripts.ui.tab-list")
local Menu = require("scripts.ui.menu")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")
local Help = require("scripts.ui.help")

local mod = {}

---Get the blueprint book inventory
---@param ctx fa.ui.graph.Ctx
---@return LuaInventory?
local function get_book_inventory(ctx)
   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   local stack = p.cursor_stack
   if not (stack and stack.valid_for_read and stack.is_blueprint_book) then return nil end

   return stack.get_inventory(defines.inventory.item_main)
end

---Get the blueprint book stack
---@param ctx fa.ui.graph.Ctx
---@return LuaItemStack?
local function get_book_stack(ctx)
   local p = game.get_player(ctx.pindex)
   if not p then return nil end

   local stack = p.cursor_stack
   if not (stack and stack.valid_for_read and stack.is_blueprint_book) then return nil end

   return stack
end

---Render the blueprints list tab
---@type fun(fa.ui.graph.Ctx): fa.ui.graph.Render?
local function render_blueprints_list(ctx)
   local book_inv = get_book_inventory(ctx)
   local book_stack = get_book_stack(ctx)
   if not book_inv or not book_stack then return nil end

   local builder = Menu.MenuBuilder.new()

   if #book_inv == 0 then
      builder:add_label("empty", { "fa.ui-blueprint-book-empty" })
      return builder:build()
   end

   for i = 1, #book_inv do
      local bp_stack = book_inv[i]
      if bp_stack.valid_for_read then
         local idx = i
         builder:start_row("bp")

         -- Main item: clicking sets active index
         builder:add_clickable("item-" .. idx, function(c)
            if bp_stack.is_blueprint then
               c.message:fragment(Blueprints.get_blueprint_info(bp_stack, false, c.pindex))
            elseif bp_stack.is_blueprint_book then
               c.message:fragment(bp_stack.label or "unnamed book")
            else
               c.message:fragment("unknown item")
            end
         end, {
            on_click = function(c)
               book_stack.active_index = idx
               c.message:fragment({ "fa.ui-blueprint-book-activated", bp_stack.label or "unnamed" })
            end,
            on_drag_up = function(c)
               if idx == 1 then
                  c.message:fragment({ "fa.ui-blueprint-book-already-first" })
                  return
               end

               -- Swap with previous item
               book_inv.swap_stack(idx, idx - 1)
               local moved_bp = book_inv[idx - 1]
               c.message:fragment({ "fa.ui-blueprint-book-moved-to-row", idx - 1, moved_bp.label or "unnamed" })
            end,
            on_drag_down = function(c)
               if idx == #book_inv then
                  c.message:fragment({ "fa.ui-blueprint-book-already-last" })
                  return
               end

               -- Swap with next item
               book_inv.swap_stack(idx, idx + 1)
               local moved_bp = book_inv[idx + 1]
               c.message:fragment({ "fa.ui-blueprint-book-moved-to-row", idx + 1, moved_bp.label or "unnamed" })
            end,
         })

         -- Rename option
         builder:add_clickable("rename-" .. idx, { "fa.ui-blueprint-book-rename" }, {
            on_click = function(c)
               c.controller:open_textbox(bp_stack.label or "", "rename-" .. idx)
            end,
            on_child_result = function(c, result)
               bp_stack.label = result
               c.message:fragment({ "fa.ui-blueprint-book-renamed", result })
            end,
         })

         -- Copy blueprint to inventory
         builder:add_clickable("copy-" .. idx, { "fa.ui-blueprint-book-copy-to-hand" }, {
            on_click = function(c)
               local p = game.get_player(c.pindex)
               if not p then return end
               local player_inv = p.get_main_inventory()
               if not player_inv then return end

               local inserted = player_inv.insert(bp_stack)
               if inserted > 0 then
                  c.message:fragment({ "fa.ui-blueprint-book-copied", bp_stack.label or "unnamed" })
               else
                  c.message:fragment({ "fa.ui-blueprint-book-inventory-full" })
               end
            end,
         })

         -- Remove from book (places in character's inventory)
         builder:add_clickable("remove-" .. idx, { "fa.ui-blueprint-book-remove" }, {
            on_click = function(c)
               local p = game.get_player(c.pindex)
               if not p then return end

               -- Create a copy in inventory
               local inserted = p.insert(bp_stack)
               if inserted > 0 then
                  -- Clear the slot
                  bp_stack.clear()
                  c.message:fragment({ "fa.ui-blueprint-book-removed" })
               else
                  c.message:fragment({ "fa.ui-blueprint-book-inventory-full" })
               end
            end,
         })

         builder:end_row()
      else
         -- Empty slot - just show it but don't allow actions
         builder:add_label("empty-" .. i, { "fa.ui-blueprint-book-empty-slot" })
      end
   end

   return builder:build()
end

---Render the settings tab
---@type fun(fa.ui.graph.Ctx): fa.ui.graph.Render?
local function render_settings(ctx)
   local book_stack = get_book_stack(ctx)
   if not book_stack then return nil end

   local builder = Menu.MenuBuilder.new()

   builder:add_clickable("rename-book", { "fa.ui-blueprint-book-rename-book" }, {
      on_click = function(c)
         c.controller:open_textbox(book_stack.label or "", "rename-book")
      end,
      on_child_result = function(c, result)
         book_stack.label = result
         c.message:fragment({ "fa.ui-blueprint-book-book-renamed", result })
      end,
   })

   builder:add_clickable("export", { "fa.ui-blueprint-book-export" }, {
      on_click = function(c)
         local export_string = book_stack.export_stack()
         c.controller:open_textbox(export_string, "export")
         c.message:fragment({ "fa.ui-blueprint-book-export-string-shown" })
      end,
   })

   builder:add_clickable("import", { "fa.ui-blueprint-book-import" }, {
      on_click = function(c)
         c.controller:open_textbox("", "import")
         c.message:fragment({ "fa.ui-blueprint-book-paste-string" })
      end,
      on_child_result = function(c, result)
         local import_result = book_stack.import_stack(result)
         if import_result == 0 then
            c.message:fragment({ "fa.ui-blueprint-book-import-success" })
         elseif import_result == -1 then
            c.message:fragment({ "fa.ui-blueprint-book-import-errors" })
         else
            c.message:fragment({ "fa.ui-blueprint-book-import-failed" })
         end
      end,
   })

   return builder:build()
end

---@type fa.ui.UiPanelBase
local blueprint_book_ui = TabList.declare_tablist({
   ui_name = UiRouter.UI_NAMES.BLUEPRINT_BOOK,
   tabs_callback = Functools.functionize({
      {
         name = "main",
         tabs = {
            UiKeyGraph.declare_graph({
               name = "blueprints-list",
               render_callback = render_blueprints_list,
               title = { "fa.ui-blueprint-book-tab-list" },
               get_help_metadata = function(ctx)
                  return {
                     Help.message_list("blueprint-book-help"),
                     Help.message_list("menu-help"),
                  }
               end,
            }),
            UiKeyGraph.declare_graph({
               name = "settings",
               render_callback = render_settings,
               title = { "fa.ui-blueprint-book-tab-settings" },
               get_help_metadata = function(ctx)
                  return {
                     Help.message_list("blueprint-book-help"),
                     Help.message_list("menu-help"),
                  }
               end,
            }),
         },
      },
   }),
})

UiRouter.register_ui(blueprint_book_ui)

return mod
