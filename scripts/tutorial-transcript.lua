--[[
Tutorial transcript generator.

Writes a markdown version of the tutorial to script-output/tutorial-transcript.md.
Uses Factorio's file writing API with localised strings, so the transcript is
generated in whatever language the player has configured.

Usage: /fa-tutorial-transcript
]]

local MessageLists = require("scripts.message-lists")
local TutorialData = require("scripts.tutorial-data")

local mod = {}

---Generate the tutorial transcript for a player.
---@param pindex integer
---@return boolean success
---@return string? error_message
function mod.generate_transcript(pindex)
   local chapters = TutorialData.get_chapters()
   if #chapters == 0 then return false, "No tutorial chapters found" end

   -- First pass: check all chapter text lists are ready
   for _, chapter in ipairs(chapters) do
      local list_name = TutorialData.get_chapter_text_list(chapter.chapter_number)
      local result = MessageLists.get_message_list_meta(pindex, list_name)

      if result.status == MessageLists.STATUS.PENDING then
         return false, "Message list metadata not yet available, try again in a moment"
      elseif result.status == MessageLists.STATUS.NOT_FOUND then
         return false, "Message list not found: " .. list_name
      end
   end

   -- All ready, generate the transcript
   local total_chapters = #chapters

   for i, chapter in ipairs(chapters) do
      local is_first = i == 1
      local list_name = TutorialData.get_chapter_text_list(chapter.chapter_number)
      local result = MessageLists.get_message_list_meta(pindex, list_name)

      -- Build chapter header: ## Chapter N: Title
      ---@type LocalisedString
      local chapter_header = {
         "",
         "## ",
         { "fa.transcript-chapter-heading", chapter.chapter_number, total_chapters },
         ": ",
         chapter.title,
         "\n\n",
      }
      helpers.write_file("tutorial-transcript.md", chapter_header, not is_first, pindex)

      -- Chapter text section
      helpers.write_file("tutorial-transcript.md", "### Chapter Text\n\n", true, pindex)

      if result.messages and #result.messages > 0 then
         for _, message in ipairs(result.messages) do
            ---@type LocalisedString
            local line = { "", message, "\n\n" }
            helpers.write_file("tutorial-transcript.md", line, true, pindex)
         end
      else
         helpers.write_file("tutorial-transcript.md", "(no text)\n\n", true, pindex)
      end

      -- Example blueprints section
      helpers.write_file("tutorial-transcript.md", "### Example Blueprints\n\n", true, pindex)

      if chapter.example_blueprints and #chapter.example_blueprints > 0 then
         for _, bp in ipairs(chapter.example_blueprints) do
            ---@type LocalisedString
            local bp_line = { "", bp.title, ": ", bp.blueprint, "\n\n" }
            helpers.write_file("tutorial-transcript.md", bp_line, true, pindex)
         end
      else
         helpers.write_file("tutorial-transcript.md", "No blueprints\n\n", true, pindex)
      end
   end

   return true
end

return mod
