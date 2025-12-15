--[[
Tutorial UI viewer.

Displays tutorial chapters with text, exercises, and example blueprints.
The tutorial state persists across close/reopen operations.
]]

local Menu = require("scripts.ui.menu")
local MessageLists = require("scripts.message-lists")
local Router = require("scripts.ui.router")
local Speech = require("scripts.speech")
local StorageManager = require("scripts.storage-manager")
local TabList = require("scripts.ui.tab-list")
local TutorialData = require("scripts.tutorial-data")
local UiKeyGraph = require("scripts.ui.key-graph")
local UiSounds = require("scripts.ui.sounds")

local mod = {}

-- Persistent tutorial state
local tutorial_storage = StorageManager.declare_storage_module("tutorial", {
   -- Last viewed chapter and subtab
   last_chapter = 1,
   last_subtab = 1,
})

---Build the chapter text subtab
---@param chapter fa.tutorial.Chapter
---@return fa.ui.TabDescriptor
local function build_chapter_text_tab(chapter)
   local list_name = TutorialData.get_chapter_text_list(chapter.chapter_number)

   return UiKeyGraph.declare_graph({
      name = "ch" .. chapter.chapter_number .. "-text",
      title = { "fa.tutorial-subtab-text" },
      render_callback = function(ctx)
         local menu = Menu.MenuBuilder.new()

         local result = MessageLists.get_message_list_meta(ctx.pindex, list_name)

         if result.status == MessageLists.STATUS.NOT_FOUND then
            menu:add_label("not-found", { "fa.tutorial-text-not-found" })
         elseif result.status == MessageLists.STATUS.PENDING then
            menu:add_label("pending", { "fa.tutorial-loading" })
         elseif result.status == MessageLists.STATUS.READY then
            if #result.messages == 0 then
               menu:add_label("empty", { "fa.tutorial-text-empty" })
            else
               for i, message in ipairs(result.messages) do
                  menu:add_label("msg_" .. i, message)
               end
            end
         end

         return menu:build()
      end,
   })
end

---Build the chapter exercise subtab
---@param chapter fa.tutorial.Chapter
---@return fa.ui.TabDescriptor
local function build_chapter_exercise_tab(chapter)
   local list_name = TutorialData.get_chapter_exercise_list(chapter.chapter_number)

   return UiKeyGraph.declare_graph({
      name = "ch" .. chapter.chapter_number .. "-exercise",
      title = { "fa.tutorial-subtab-exercise" },
      render_callback = function(ctx)
         local menu = Menu.MenuBuilder.new()

         if not chapter.has_exercise then
            menu:add_label("no-exercise", { "fa.tutorial-no-exercise" })
            return menu:build()
         end

         local result = MessageLists.get_message_list_meta(ctx.pindex, list_name)

         if result.status == MessageLists.STATUS.NOT_FOUND then
            menu:add_label("not-found", { "fa.tutorial-exercise-not-found" })
         elseif result.status == MessageLists.STATUS.PENDING then
            menu:add_label("pending", { "fa.tutorial-loading" })
         elseif result.status == MessageLists.STATUS.READY then
            if #result.messages == 0 then
               menu:add_label("empty", { "fa.tutorial-exercise-empty" })
            else
               for i, message in ipairs(result.messages) do
                  menu:add_label("msg_" .. i, message)
               end
            end
         end

         return menu:build()
      end,
   })
end

---Build the example blueprints subtab
---@param chapter fa.tutorial.Chapter
---@return fa.ui.TabDescriptor
local function build_chapter_blueprints_tab(chapter)
   return UiKeyGraph.declare_graph({
      name = "ch" .. chapter.chapter_number .. "-blueprints",
      title = { "fa.tutorial-subtab-blueprints" },
      render_callback = function(ctx)
         local menu = Menu.MenuBuilder.new()

         if not chapter.example_blueprints or #chapter.example_blueprints == 0 then
            menu:add_label("no-blueprints", { "fa.tutorial-no-blueprints" })
            return menu:build()
         end

         -- Add each blueprint as a clickable item
         for i, bp in ipairs(chapter.example_blueprints) do
            local bp_data = bp -- Capture for closure
            menu:add_clickable("bp_" .. i, bp_data.title, {
               on_click = function(click_ctx)
                  -- Import the blueprint to clipboard
                  local player = game.get_player(click_ctx.pindex)
                  if player then
                     local result = player.import_blueprint_string(bp_data.blueprint)
                     if result then
                        UiSounds.play_menu_move(click_ctx.pindex)
                        click_ctx.controller.message:fragment({ "fa.tutorial-blueprint-imported" })
                     else
                        UiSounds.play_ui_edge(click_ctx.pindex)
                        click_ctx.controller.message:fragment({ "fa.tutorial-blueprint-failed" })
                     end
                  end
               end,
            })
         end

         return menu:build()
      end,
   })
end

---Build tabs for the tutorial UI
---@param pindex number
---@return fa.ui.TabstopDescriptor[]?
local function build_tutorial_tabs(pindex)
   local chapters = TutorialData.get_chapters()
   if #chapters == 0 then return nil end

   local sections = {}

   for _, chapter in ipairs(chapters) do
      local chapter_tabs = {
         build_chapter_text_tab(chapter),
         build_chapter_exercise_tab(chapter),
         build_chapter_blueprints_tab(chapter),
      }

      table.insert(sections, {
         name = "chapter_" .. chapter.chapter_number,
         title = chapter.title,
         tabs = chapter_tabs,
      })
   end

   return sections
end

-- Create the tutorial TabList
mod.tutorial_ui = TabList.declare_tablist({
   ui_name = Router.UI_NAMES.TUTORIAL,
   resets_to_first_tab_on_open = false, -- Preserve position
   persist_state = true,
   tabs_callback = build_tutorial_tabs,
})

-- Register with router
Router.register_ui(mod.tutorial_ui)

return mod
