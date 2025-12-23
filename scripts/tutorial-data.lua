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
declare_tutorial_chapter({ "fa.tutorial-ch8-title" }, {
   example_blueprints = {
      {
         "fa.tutorial-example-blueprint-chest-inserter-chest",
         "0eNqdkdtqhDAQhl8lzHVcuuuB1VdZSlEz1AGdSDLWLpJ3bzR0KXTpRe8m8OfjP2zQjQvOjlig2cCg7x3NQpahAVmtWq01yKof0ItXK8mgWtUtjtEpYo9O4tGhrBhVMuAEGqi37KG5beDpndtxJ3M7YUQmXHbgIEQpG/yE5hxeNSALCWH6eTzub7xMHboo0E8JGmbrKdndIIKyKj+VGu77VZ3KEPQv1OWBSjGy7xh/08pI02DIYZ8U1yfs/B82i91mjE8Sy2t+7KFhbDuM7cGj6JaN2ldJc0TFBzp/YMvqUhd1XV7PeV2/FCF8AcPTnZg=",
      },
      {
         "fa.tutorial-example-blueprint-drill-and-belts",
         "0eNqdkttqwzAMhl/F6Nopy2k0eZUxhpNorcBRgg9jJfjd59gwRtdtdBcGGev/9EvyBoP2uBpiB/0GE9rR0OpoYejBIgp3jse7xZDSYjyr1aEBCTQubKF/2sDSiZXexaxmjKrBG0ZTzMTEp2IypDWEqOAJ36Evg7yhcUaxXRfjigG1+5JehWcJyI4cYa6XLpcX9vMQnfSl/IEhYV0s5U42iKjiWB1aCZcY1Yc2lpjI4JgTmt3VFbn6DzkG4QarllfTIbZo8ii/wco/YM0dxsq7Wm7lb0u81XeGl2FfEzmcd+nnh5KgVTSWfpJ+Lay3TiWgyHiR8SLhhbfpJTZio/INjU2V2seqa7quPZZ11z00IXwAdYLm0A==",
      },
   },
})
declare_tutorial_chapter({ "fa.tutorial-ch9-title" }, {})
declare_tutorial_chapter({ "fa.tutorial-ch10-title" }, {
   example_blueprints = {
      {
         "fa.tutorial-example-blueprint-2-assemblers-and-lab",
         "0eNqVk2GPgjAMhv8K6efNyAQV/ooxZsxGmxuF2+A8Y/jvt4me5kLM+Ymsa5+3b1cuUNkeW0fcQXkBMg17KDcX8HRgbWOMdY1QgvYe68oSH2StzZEYZQqDAOI9fkOZDmKiyOrqKUcNWwHIHXWEo8r1cN5xX1foAkTcC32trZVo0XSOjGwbiyCgbXyobTgqBJ7MlrNcwBnK1SwfYgN/eOpdnnrNW4iX05gArm/A8A1zcGiojeXkGpYH1E6ejogW7le7z17boBhSuHGhZ5joIvvtgtij60LsxWhG5T0FgfE+VRPM/G1n2bQz3XdNrWOm9IaQDcpWm4/3HC7/5VC95XAlnpdyAjd/wsVFPQVg3NJNKnKhRL4NMeqwDoTHPyMiLTxgCSp5TC65Tc4nmveJTkbFL3T+KpgvVZEVRb5OF0Uxz4bhBw9XJwU=",
      },
      {
         "fa.tutorial-example-blueprint-4-steam-and-poles",
         "0eNqV0s1ugzAMAOBXQT6HakBCCa9SVVOgVmUphIqk2yqUd58BrT2MreWWWPbn/HiExl7xMpALUI9Abe881IcRPJ2dsVPMmQ6hBh/QdCm6MzmEKIDcCb+gzuJRALpAgXCpnDe3d3ftGhw4QawKAi6956LeTT0YSnW5UwJuvNrvVIzil5S/LBVPpOIhdcbaFC22YaA2vfR2Fax+QLkOyq1g9gRU218tX5fK7a/2h7S/S01PliP/nCZbA6oXgOIB8GB90jBP1aEQSkihjhyjgN1E3OdWgDUN8qxCniywF4lM5usmy3U5YNwpmX7Dc/4Hp8xNVZlrqbWqskLrNxnjN22M/Ek=",
      },
   },
})
declare_tutorial_chapter({ "fa.tutorial-ch11-title" }, {
   example_blueprints = {
      {
         "fa.tutorial-example-blueprint-tileable-smelter",
         "0eNqd1O1uwiAUBuBbMec3GKGtlt6KWRZazxwJhQZw0Zje+2hddIk01v7rBzwHXj6uUOsTdk6ZANUVVGONh2p/Ba+ORurhm5EtQgXBSeM76wKtUQfoCShzwDNUrP8ggCaooPDWd3y5fJpTW6OLDciEQaCzPnazZqgTKSrEuiBwiU/Zuuh78mTxJRZPW9kbVvnCypdYE3Ms7pa25ki/Zcz5QJXx6EL8nxB3/0UCB+WwuTVgPFFgey8wC+Wz0N0sNH8PLe+oD9Yg/To5IxtMydu/BFKJijdWJ5vMskzIbLOE5rPoReeGpfcU40s26BT2ODm+lVpT1HEiTjW0szq9OK/EfEmM7DnGeBWpgG10HvcaAS2jNdhKo6w1rnwbbXQrPMu2G4f8g86PRrHlIheiKFkmxCbv+1/VxKuF",
      },
   },
})

return mod
