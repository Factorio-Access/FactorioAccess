--[[
Tutorial chapter data declarations.

Each chapter consists of:
- A title (localised string)
- Chapter text (message list at locale/en/tutorial/chN.txt)
- Optional example blueprints

Usage:
   declare_tutorial_chapter({"your-title-key-here"}, {
      example_blueprints = {
         {"your-blueprint-title-key", "blueprint-import-string"},
      }
   })
]]

local mod = {}

---@class fa.tutorial.Chapter
---@field title LocalisedString
---@field chapter_number number
---@field example_blueprints { title: LocalisedString, blueprint: string }[]?

---@type fa.tutorial.Chapter[]
local chapters = {}

---Declare a tutorial chapter
---@param title LocalisedString The chapter title
---@param options { example_blueprints: { [1]: LocalisedString, [2]: string }[]? }?
local function declare_tutorial_chapter(title, options)
   options = options or {}

   local chapter_number = #chapters + 1

   local example_blueprints = nil
   if options.example_blueprints then
      example_blueprints = {}
      for _, bp in ipairs(options.example_blueprints) do
         -- Wrap the title key as a LocalisedString if it's a plain string
         local bp_title = bp[1]
         if type(bp_title) == "string" then bp_title = { bp_title } end

         table.insert(example_blueprints, {
            title = bp_title,
            blueprint = bp[2],
         })
      end
   end

   table.insert(chapters, {
      title = title,
      chapter_number = chapter_number,
      example_blueprints = example_blueprints,
   })
end

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

--------------------------------------------------------------------------------
-- Tutorial Chapters
--------------------------------------------------------------------------------

-- Chapter 1: Getting Started
declare_tutorial_chapter({ "fa.tutorial-ch1-title" })

declare_tutorial_chapter({ "fa.tutorial-ch2-title" })

-- Chapter 3: Mining and Placing
declare_tutorial_chapter({ "fa.tutorial-ch3-title" })

declare_tutorial_chapter({ "fa.tutorial-ch4-title" })
declare_tutorial_chapter({ "fa.tutorial-ch5-title" })
declare_tutorial_chapter({ "fa.tutorial-ch6-title" })
declare_tutorial_chapter({ "fa.tutorial-ch7-title" }, {
   example_blueprints = {
      {
         "fa.tutorial-example-blueprint-power-and-lab",
         "0eNp90dtqhDAQBuBXCXMdl/W0rb5KKSXqIAPJKEksu0jevYm2thTZqxz48yUzWaHTC86W2EO7woCutzR7mhhaUKKbSKOVwnlURiCPxCgFauy9pV7Mk45LxYPQqgMJ1E/soH1bwdHISieSlcFobUK2CxBilAe8Q5sHeRJO2m+mCO8SkD15wl3fFo8PXkyHNiLy70EJ8+RoL2GFeD4rb+WllvCI0/xSh3TlP6E4BGeU1tlPhVmq8FSsvsXrOVjK08Kfva08l6pD2j/jqfESUq/Io0n542dlagzGDgPelZk1Ckc8xiFuC4d+mWPkE63b0PpWNFXT1K952TTXKoQvPAay+w==",
      },
      {
         "fa.tutorial-example-blueprint-single-pipe-to-ground",
         "0eNqdkd1KxDAQRl8lzHW62F+3vfM5RCRth+5AMwlpql1K3t10K7jKroh3Ezic75vMCu04o3XEHpoVepw6R9aTYWjgSViyKLwRgzMz90J5odVCetbCKR5QinfyJ6GEw2Eeldt5wwJVdxLIPUigzvAEzfMKEw2sxi2Glcbo32gIEeEeF2jSIO9AiTfJXuEKz8KLBGRPnnAPuDzOrzzrFl30yW9BEqyZaF9thShI8io9lBLOcSwOZdjifygyeafGr7L8tiz/e5/H24biP3Wq6JLQk8NuB47bx5FHHT1f15cwqhbHT/fV0XFR2o5b3zd008VQVlld1HV5TPO6fihC+AAtm75h",
      },
   },
})

return mod
