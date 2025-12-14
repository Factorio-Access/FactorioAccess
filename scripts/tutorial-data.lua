--[[
Tutorial chapter data declarations.

Each chapter consists of:
- A title (localised string)
- Chapter text (message list at locale/en/tutorial/chN.txt)
- Optional exercise (message list at locale/en/tutorial/chN-exercise.txt)
- Optional example blueprints

Usage:
   declare_tutorial_chapter({"your-title-key-here"}, {
      exercise = true,  -- If true, looks for chN-exercise message list
      example_blueprints = {
         {"your-blueprint-title-key", "blueprint-import-string"},
      }
   })
]]

local mod = {}

---@class fa.tutorial.Chapter
---@field title LocalisedString
---@field chapter_number number
---@field has_exercise boolean
---@field example_blueprints { title: LocalisedString, blueprint: string }[]?

---@type fa.tutorial.Chapter[]
local chapters = {}

---Declare a tutorial chapter
---@param title LocalisedString The chapter title
---@param options { exercise: boolean?, example_blueprints: { [1]: LocalisedString, [2]: string }[]? }?
local function declare_tutorial_chapter(title, options)
   options = options or {}

   local chapter_number = #chapters + 1

   local example_blueprints = nil
   if options.example_blueprints then
      example_blueprints = {}
      for _, bp in ipairs(options.example_blueprints) do
         table.insert(example_blueprints, {
            title = bp[1],
            blueprint = bp[2],
         })
      end
   end

   table.insert(chapters, {
      title = title,
      chapter_number = chapter_number,
      has_exercise = options.exercise or false,
      example_blueprints = example_blueprints,
   })
end

--------------------------------------------------------------------------------
-- Tutorial Chapters
--------------------------------------------------------------------------------

-- Chapter 1: Getting Started
declare_tutorial_chapter({ "fa.tutorial-ch1-title" }, {
   exercise = true,
})

-- Chapter 2: Movement and Cursor
declare_tutorial_chapter({ "fa.tutorial-ch2-title" }, {
   exercise = true,
})

-- Chapter 3: Mining and Placing
declare_tutorial_chapter({ "fa.tutorial-ch3-title" }, {
   exercise = true,
})

--------------------------------------------------------------------------------
-- Module API
--------------------------------------------------------------------------------

---Get all tutorial chapters
---@return fa.tutorial.Chapter[]
function mod.get_chapters()
   return chapters
end

---Get a specific chapter by number
---@param chapter_number number
---@return fa.tutorial.Chapter?
function mod.get_chapter(chapter_number)
   return chapters[chapter_number]
end

---Get the number of chapters
---@return number
function mod.get_chapter_count()
   return #chapters
end

---Get the message list name for a chapter's text
---@param chapter_number number
---@return string
function mod.get_chapter_text_list(chapter_number)
   return "ch" .. chapter_number
end

---Get the message list name for a chapter's exercise
---@param chapter_number number
---@return string
function mod.get_chapter_exercise_list(chapter_number)
   return "ch" .. chapter_number .. "-exercise"
end

return mod
